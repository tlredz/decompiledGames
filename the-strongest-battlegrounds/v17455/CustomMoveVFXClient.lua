local RunService = game:GetService("RunService")

local function isliveserver()
	if RunService:IsStudio() or game.PrivateServerOwnerId ~= 0 then
		return true
	end

	return workspace:GetAttribute("CustomServerOwnerId") ~= nil or workspace:GetAttribute("VIPServer") ~= nil
end

if not RunService:IsStudio() and game.PrivateServerOwnerId == 0 and workspace:GetAttribute("CustomServerOwnerId") == nil and workspace:GetAttribute("VIPServer") == nil then
	local v = os.clock() + 10

	repeat
		task.wait(1)
	until RunService:IsStudio() or game.PrivateServerOwnerId ~= 0 or workspace:GetAttribute("CustomServerOwnerId") ~= nil or workspace:GetAttribute("VIPServer") ~= nil or v < os.clock()

	if not RunService:IsStudio() and game.PrivateServerOwnerId == 0 and workspace:GetAttribute("CustomServerOwnerId") == nil and workspace:GetAttribute("VIPServer") == nil then
		script:Destroy()
		return
	end
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local customMoveVFX = ReplicatedStorage:WaitForChild("CustomMoveVFX")
local cast = customMoveVFX:WaitForChild("Cast")
local livePlayCastEvent = cast:WaitForChild("LivePlayCastEvent")
local branchActivateEvent = cast:WaitForChild("BranchActivateEvent")
local fetchMoveData = cast:WaitForChild("FetchMoveData")
local HeadlessPlayback = require(customMoveVFX:WaitForChild("HeadlessPlayback"))
local MoveContentHash = require(customMoveVFX:WaitForChild("MoveContentHash"))
local MovePreloader = require(customMoveVFX:WaitForChild("MovePreloader"))
local fetchMoveAssets = cast:WaitForChild("FetchMoveAssets")
local moveEditorReq = ReplicatedStorage:WaitForChild("MoveEditorReq")

moveEditorReq.OnClientInvoke = function(p, p2)
	if p ~= "getFreshMouseWorld" then
		return nil
	end

	local success, result = pcall(function()
		return Players.LocalPlayer:GetMouse()
	end)

	if not (success and result) then
		return {
			Ok = false,
			Reason = "local_mouse_missing"
		}
	end

	local hit = result.Hit

	if typeof(hit) ~= "CFrame" then
		return {
			Ok = false,
			Reason = "local_mouse_hit_missing"
		}
	end

	local v = {
		Ok = true,
		Position = hit.Position,
		CFrame = hit,
		Source = "cmvfx_client_invoke",
		RequestSource = 0
	}
	local requestSource

	if type(p2) == "table" then
		requestSource = p2.RequestSource or nil
	end

	v.RequestSource = requestSource
	return v
end

local moveDataSchema = nil

local function getMoveSchema()
	if moveDataSchema ~= nil then
		return moveDataSchema
	end

	local schemas = ReplicatedStorage:FindFirstChild("Schemas") or ReplicatedStorage:WaitForChild("Schemas", 10)

	if not schemas then
		return nil
	end

	local success, result = pcall(require, schemas)

	if success and type(result) == "table" and type(result.moveDataSchema) == "table" then
		moveDataSchema = result.moveDataSchema
	end

	return moveDataSchema
end

local function decodeMoveBuffer(result)
	if typeof(result) ~= "buffer" then
		return nil, "not_buffer"
	end

	local moveSchema = getMoveSchema()

	if not moveSchema then
		return nil, "schema_unavailable"
	end

	local success, result2 = pcall(moveSchema.decode, moveSchema, result)

	if not success then
		return nil, "decode_err:" .. tostring(result2)
	end

	local selected = result2 and result2[1]

	if type(selected) == "table" and type(selected.Data) == "table" then
		return selected
	end

	return nil, "no_move"
end

local function _entryVariantId(data, p)
	local __MoveVariantId = nil

	if type(data) == "table" then
		local properties = data.Data and data.Data.Properties

		if type(properties) == "table" then
			__MoveVariantId = properties.__MoveVariantId
		end

		if __MoveVariantId == nil and type(data.Properties) == "table" then
			__MoveVariantId = data.Properties.__MoveVariantId
		end

		if __MoveVariantId == nil then
			__MoveVariantId = data.__MoveVariantId
		end

		if __MoveVariantId == nil then
			__MoveVariantId = data.MoveVariantId
		end
	end

	local v = tonumber(__MoveVariantId)

	if v and v >= 1 then
		return (math.floor(v + 0.5))
	end

	return p
end

local function variantFilterMove(p, p2)
	if type(p) ~= "table" or type(p.Data) ~= "table" then
		return p
	end

	local v = {}

	for _, v2 in ipairs(p.Data) do
		if _entryVariantId(v2, p2) == p2 then
			v[#v + 1] = v2
		end
	end

	if #v == #p.Data then
		return p
	end

	local result = {}

	for k, v2 in pairs(p) do
		result[k] = v2
	end

	result.Data = v
	return result
end

task.spawn(function()
	local moveEditorCli = customMoveVFX:FindFirstChild("MoveEditorCli") or customMoveVFX:WaitForChild(
		"MoveEditorCli",
		60
	)
	local animReplication = moveEditorCli and (moveEditorCli:FindFirstChild("AnimReplication") or moveEditorCli:WaitForChild(
		"AnimReplication",
		60
	))

	if not animReplication then
		return
	end

	local clone = animReplication:Clone()
	clone.Disabled = false
	clone.Parent = Players.LocalPlayer:WaitForChild("PlayerScripts")
end)
task.spawn(function()
	if rawget(_G, "playMoveEditorImpactFrames") ~= nil then
		return
	end

	local moveEditorCli = customMoveVFX:FindFirstChild("MoveEditorCli") or customMoveVFX:WaitForChild(
		"MoveEditorCli",
		60
	)
	local moveEditorCliHelper = moveEditorCli and (moveEditorCli:FindFirstChild("MoveEditorCliHelper") or moveEditorCli:WaitForChild(
		"MoveEditorCliHelper",
		60
	))
	local success, result = pcall(require, moveEditorCliHelper)

	if not success or type(result) ~= "table" or type(result.newImpactFramesController) ~= "function" then
		return
	end

	local function ensureFxGui()
		local localPlayer = Players.LocalPlayer
		local playerGui = localPlayer and (localPlayer:FindFirstChildOfClass("PlayerGui") or localPlayer:WaitForChild(
			"PlayerGui",
			10
		))

		if not playerGui then
			return nil
		end

		local v = playerGui:FindFirstChild("CMVFXImpactFramesGui")

		if v then
			return v
		end

		v = Instance.new("ScreenGui")
		v.Name = "CMVFXImpactFramesGui"
		v.ResetOnSpawn = false
		v.IgnoreGuiInset = true
		v.DisplayOrder = 10000
		v.ZIndexBehavior = Enum.ZIndexBehavior.Global
		v.Parent = playerGui
		return v
	end

	local success2, result2 = pcall(result.newImpactFramesController, {
		ensureFxGui = ensureFxGui
	})

	if not success2 or type(result2) ~= "table" or type(result2.bindGlobals) ~= "function" then
		return
	end

	result2.bindGlobals()
	local replication = ReplicatedStorage:FindFirstChild("Replication") or ReplicatedStorage:WaitForChild(
		"Replication",
		30
	)

	if replication then
		replication.OnClientEvent:Connect(function(p)
			if type(p) == "table" and p.Effect == "MoveEditorImpactFrames" then
				local v = rawget(_G, "playMoveEditorImpactFrames")

				if type(v) == "function" then
					pcall(v, p)
				end
			end
		end)
	end
end)
local v = {}
local v2 = {}

local function cacheTouch(p)
	for i, v3 in ipairs(v2) do
		if v3 ~= p then
			continue
		end

		table.remove(v2, i)
		break
	end

	v2[#v2 + 1] = p
end

local function cacheGet(p)
	local v3 = v[p]

	if v3 ~= nil then
		cacheTouch(p)
	end

	return v3
end

local function cacheStore(p, p2)
	if v[p] == nil then
		v2[#v2 + 1] = p

		while #v2 > 30 do
			local v3 = table.remove(v2, 1)
			v[v3] = nil
		end
	else
		cacheTouch(p)
	end

	v[p] = p2
end

local deepCopy

deepCopy = function(items)
	if type(items) ~= "table" then
		return items
	end

	local result = {}

	for k, item in pairs(items) do
		result[k] = deepCopy(item)
	end

	return result
end

local localPlayer = Players.LocalPlayer
local nowsByRunToken = {}
local serverT0sByRunToken = {}
local v3 = {}

local function prefetchMove(name, moveCreatorId)
	if type(name) ~= "string" or name == "" then
		return
	end

	local v4 = tonumber(moveCreatorId)

	if not v4 then
		return
	end

	local v5 = tostring(v4) .. ":" .. name

	if v3[v5] then
		return
	end

	v3[v5] = true
	task.spawn(function()
		local success, result = pcall(function()
			return fetchMoveData:InvokeServer(name, v4)
		end)

		if not success or typeof(result) ~= "buffer" then
			v3[v5] = nil
			return
		end

		local hashBuffer = MoveContentHash.hashBuffer(result)

		if hashBuffer then
			local v6 = v[hashBuffer]

			if v6 ~= nil then
				cacheTouch(hashBuffer)
			end

			if v6 == nil then
				local v7 = decodeMoveBuffer(result)

				if v7 then
					cacheStore(hashBuffer, v7)
					MovePreloader.preloadMove(v7, hashBuffer)
				end
			end
		end
	end)
end

local function _watchMoveTool(tool)
	if typeof(tool) ~= "Instance" or not tool:IsA("Tool") then
		return
	end

	tool.Equipped:Connect(function()
		local moveCreatorId = tonumber(tool:GetAttribute("MoveCreatorId"))

		if moveCreatorId then
			prefetchMove(tool.Name, moveCreatorId)
		end
	end)
end

task.spawn(function()
	local function hookContainer(instance)
		if not instance then
			return
		end

		for _, tool in ipairs(instance:GetChildren()) do
			if not (typeof(tool) == "Instance" and tool:IsA("Tool")) then
				continue
			end

			local v4 = tool
			tool.Equipped:Connect(function()
				local moveCreatorId = tonumber(v4:GetAttribute("MoveCreatorId"))

				if moveCreatorId then
					prefetchMove(v4.Name, moveCreatorId)
				end
			end)
		end

		instance.ChildAdded:Connect(_watchMoveTool)
	end

	hookContainer(localPlayer:WaitForChild("Backpack", 30))

	if localPlayer.Character then
		hookContainer(localPlayer.Character)
	end

	localPlayer.CharacterAdded:Connect(hookContainer)
end)
task.spawn(function()
	local v4 = {}

	local function specPrefetch(name, moveCreatorId)
		if type(name) ~= "string" or name == "" then
			return
		end

		local v5 = tonumber(moveCreatorId)

		if not v5 then
			return
		end

		local v6 = tostring(v5) .. ":" .. name

		if v4[v6] then
			return
		end

		v4[v6] = true
		task.spawn(function()
			local success, result = pcall(function()
				return fetchMoveAssets:InvokeServer(name, v5)
			end)

			if success and type(result) == "table" then
				MovePreloader.preloadList(result)
			else
				v4[v6] = nil
			end
		end)
	end

	local function onTool(tool)
		local moveCreatorId = typeof(tool) == "Instance" and tool:IsA("Tool") and tool:GetAttribute("MoveCreatorId")

		if moveCreatorId then
			specPrefetch(tool.Name, moveCreatorId)
		end
	end

	local function watchChar(character)
		if typeof(character) ~= "Instance" then
			return
		end

		for _, tool in ipairs(character:GetChildren()) do
			if not (typeof(tool) == "Instance" and tool:IsA("Tool")) then
				continue
			end

			local moveCreatorId = tool:GetAttribute("MoveCreatorId")

			if moveCreatorId then
				specPrefetch(tool.Name, moveCreatorId)
			end
		end

		character.ChildAdded:Connect(onTool)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function watchPlayer(player)
		if player == localPlayer then
			return
		end

		if player.Character then
			watchChar(player.Character)
		end

		player.CharacterAdded:Connect(watchChar)
	end

	for _, v5 in ipairs(Players:GetPlayers()) do
		watchPlayer(v5) -- equivalent call inferred; original call site unknown
	end

	Players.PlayerAdded:Connect(watchPlayer)
end)
task.spawn(function()
	-- equivalent calls inferred from this helper; original call sites unknown
	local function onChar(p, character)
		if typeof(character) ~= "Instance" then
			return
		end

		task.spawn(function()
			local v4 = os.clock() + 8

			while character:GetAttribute("CustomCharacter") == nil and os.clock() < v4 and character.Parent do
				task.wait(0.25)
			end

			local customCharacter = character:GetAttribute("CustomCharacter")

			if customCharacter ~= nil and customCharacter ~= "" then
				MovePreloader.preloadCharacter(character, tostring(p.UserId) .. ":" .. tostring(customCharacter))
			end
		end)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function watchPlayer(player)
		if player.Character then
			onChar(player, player.Character) -- equivalent call inferred; original call site unknown
		end

		player.CharacterAdded:Connect(function(character)
			onChar(player, character) -- equivalent call inferred; original call site unknown
		end)
	end

	for _, v4 in ipairs(Players:GetPlayers()) do
		watchPlayer(v4) -- equivalent call inferred; original call site unknown
	end

	Players.PlayerAdded:Connect(watchPlayer)
end)
livePlayCastEvent.OnClientEvent:Connect(function(data)
	if type(data) ~= "table" then
		return
	end

	local moveName = data.moveName
	local moveCreatorId = data.moveCreatorId
	local character = data.character
	local tempo = tonumber(data.tempo) or 1
	local victim = data.victim
	local serverT0 = tonumber(data.serverT0)
	local runToken = data.runToken

	if type(runToken) == "string" then
		serverT0sByRunToken[runToken] = serverT0
	end

	if typeof(character) == "Instance" then
		local _ = character == (localPlayer and localPlayer.Character)
	end

	if type(moveName) ~= "string" or moveName == "" or (typeof(character) ~= "Instance" or not character:IsA("Model")) then
		return
	end

	task.spawn(function()
		local bufHash

		if type(data.bufHash) == "string" then
			bufHash = data.bufHash ~= "" and data.bufHash or nil
		end

		local variantId = tonumber(data.variantId) or 1
		local v4 = variantId < 1 and 1 or math.floor(variantId + 0.5)
		local v5

		if bufHash then
			local v6 = v[bufHash]

			if v6 ~= nil then
				cacheTouch(bufHash)
			end

			v5 = v6 or nil
		end

		local result, v6

		if v5 == nil then
			local success
			success, result = pcall(function()
				return fetchMoveData:InvokeServer(moveName, moveCreatorId, character)
			end)
			local typeName = typeof(result)

			if not success then
				return
			end

			if typeName == "buffer" then
				local v7 = decodeMoveBuffer(result)

				if not v7 then
					return
				end

				if bufHash then
					cacheStore(bufHash, v7)
				end

				local v8 = deepCopy((variantFilterMove(v7, v4)))
				v6 = string.format("MISS-buffer(%dB)", buffer.len(result))

				if shared.CrepCache then
					shared.CrepCache.movemiss += 1
				end

				result = v8
			else
				if type(result) ~= "table" then
					return
				end

				v6 = "MISS-table(uncached)"

				if shared.CrepCache then
					shared.CrepCache.movemiss += 1
				end
			end
		else
			result = deepCopy((variantFilterMove(v5, v4)))
			v6 = "HIT(net~0)"

			if shared.CrepCache then
				shared.CrepCache.movehit += 1
			end
		end

		local _ = "cmvfx move cast, move " .. tostring(moveName) .. ", bufhash " .. tostring(bufHash) .. ", source " .. tostring(v6) .. ", cached moves held " .. tostring(#v2)
		local count = 0
		local count2 = 0
		local count3 = 0
		local count4 = 0
		local count5 = 0
		local v7 = {}

		if type(result.Data) == "table" then
			for _, v8 in ipairs(result.Data) do
				if not (type(v8) == "table" and (v8.EventType == "Particle" or v8.EventType == "Preset Mesh")) then
					continue
				end

				count += 1
				local v9 = type(v8.Properties) ~= "table" and {} or v8.Properties or {}
				local __GeneratedParticleId = v9.__GeneratedParticleId
				local __GeneratedParticleSourceSnapshot = v9.__GeneratedParticleSourceSnapshot
				local v10

				if type(__GeneratedParticleId) == "string" then
					v10 = __GeneratedParticleId ~= ""
				else
					v10 = false
				end

				local v11

				if type(__GeneratedParticleSourceSnapshot) == "string" then
					v11 = #__GeneratedParticleSourceSnapshot > 0
				else
					v11 = false
				end

				if v10 or v11 then
					count2 += 1

					if v11 then
						count3 += 1
					else
						count4 += 1
						local __GeneratedParticleDisplayName = v9.__GeneratedParticleDisplayName or v9.Name or v9.ParticleName or "?"

						if #v7 < 12 then
							table.insert(v7, (tostring(__GeneratedParticleDisplayName)))
						end
					end
				else
					count5 += 1
				end
			end
		end

		local count6 = 0
		local count7 = 0
		local count8 = 0
		local count9 = 0
		local count10 = 0
		local v8 = {}

		if type(result.Data) == "table" then
			for _, v9 in ipairs(result.Data) do
				if not (type(v9) == "table" and v9.EventType == "Particle" and type(v9.Properties) == "table") then
					continue
				end

				local properties = v9.Properties
				local presetName = properties.PresetName

				if not (type(presetName) == "string" and presetName ~= "") then
					continue
				end

				count6 += 1
				local emitterSpec = properties.EmitterSpec
				local v10

				if type(emitterSpec) == "string" then
					v10 = #emitterSpec > 0
				else
					v10 = false
				end

				local __DeepSearchSourcePath = properties.__DeepSearchSourcePath

				if v10 then
					count7 += 1
				end

				if type(__DeepSearchSourcePath) == "string" and #__DeepSearchSourcePath > 0 then
					count8 += 1
				end

				if tostring(properties.PresetRootFolder or "") == "MoveEditorCustomPresetAttachments" then
					count9 += 1
				end

				local __MoveEditorCompositePresetPayload = properties.__MoveEditorCompositePresetPayload

				if type(__MoveEditorCompositePresetPayload) == "string" and #__MoveEditorCompositePresetPayload > 0 then
					count10 += 1
				end

				if v10 or not (#v8 < 14) then
					continue
				end

				table.insert(v8, tostring(presetName):sub(1, 28))
			end
		end

		local v9 = {}
		local v10 = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function add(k)
			if not v9[k] then
				v9[k] = true

				if #v10 < 500 then
					v10[#v10 + 1] = k
				end
			end
		end

		local scanAssets

		scanAssets = function(value, p)
			if p > 8 then
				return
			end

			local typeName = type(value)

			if typeName == "string" then
				for k in value:gmatch("rbxassetid://%d+") do
					add(k) -- equivalent call inferred; original call site unknown
				end

				for k in value:gmatch("rbxasset://[%w%./_%-]+") do
					add(k) -- equivalent call inferred; original call site unknown
				end
			elseif typeName == "table" then
				for k, v11 in pairs(value) do
					scanAssets(k, p + 1)
					scanAssets(v11, p + 1)
				end
			end
		end

		if type(result.Data) == "table" then
			for _, v11 in ipairs(result.Data) do
				scanAssets(v11, 0)
			end
		end

		local ContentProvider = game:GetService("ContentProvider")
		local count11 = 0
		local count12 = 0

		for _, v11 in ipairs(v10) do
			if v11:match("^%d+$") then
				v11 = "rbxassetid://" .. v11 or v11
			end

			local v12 = v11
			local success, result2 = pcall(function()
				return ContentProvider:GetAssetFetchStatus(v12)
			end)

			if success and result2 == Enum.AssetFetchStatus.Success then
				count11 += 1
			else
				count12 += 1
			end
		end

		local _ = "cmvfx assets this cast, move " .. tostring(moveName) .. ", distinct " .. tostring(#v10) .. ", cold " .. tostring(count12) .. ", warm " .. tostring(count11)
		MovePreloader.preloadMove(result, bufHash or moveName)
		local Stats = game:GetService("Stats")
		local instanceCount = Stats.InstanceCount
		local _ = "instance accounting, move " .. tostring(moveName) .. " START count " .. tostring(instanceCount)
		HeadlessPlayback.start(result, character, victim, tempo, result.Metadata or result.Settings, serverT0, runToken)

		if type(runToken) == "string" then
			nowsByRunToken[runToken] = os.clock()
		end

		if type(runToken) == "string" and runToken ~= "" then
			local v11 = os.clock() + 3
			local v12 = nil

			while true do
				for _, child in ipairs(character:GetChildren()) do
					if not (child.Name == "__CMVFXMoveBind" and tostring(child:GetAttribute("RunToken")) == runToken) then
						continue
					end

					v12 = child
					break
				end

				if not v12 then
					task.wait(0.05)

					if not (v11 < os.clock()) then
						continue
					end
				end

				if not v12 then
					break
				end

				local ancestryChangedConnection = nil
				ancestryChangedConnection = v12.AncestryChanged:Connect(function(_, parent)
					if parent == nil then
						if ancestryChangedConnection then
							ancestryChangedConnection:Disconnect()
						end

						local v14

						if typeof(character) == "Instance" then
							v14 = character.Parent ~= nil
						else
							v14 = false
						end

						HeadlessPlayback.stop(runToken, not v14)
						task.spawn(function()
							local Stats2 = game:GetService("Stats")
							local instanceCount2 = Stats2.InstanceCount
							task.wait(5)
							local instanceCount3 = Stats2.InstanceCount
							local _ = "instance accounting, move " .. tostring(moveName) .. " END count " .. tostring(instanceCount2) .. " (spawned " .. tostring(instanceCount2 - instanceCount) .. "), 5s after end count " .. tostring(instanceCount3) .. " (net leaked since start " .. tostring(instanceCount3 - instanceCount) .. ")"
						end)
					end
				end)
				break
			end
		end
	end)
end)
branchActivateEvent.OnClientEvent:Connect(function(data)
	if type(data) ~= "table" then
		return
	end

	local runToken = data.runToken
	local branchName = data.branchName
	local serverTime = tonumber(data.serverTime)
	local branchStartTime = tonumber(data.branchStartTime)
	local activeSet

	if type(data.activeSet) == "table" then
		activeSet = data.activeSet or nil
	end

	local branchOrdinal = tonumber(data.branchOrdinal)

	if type(runToken) ~= "string" or type(branchName) ~= "string" then
		return
	end

	local collisionPos = data.collisionPos
	local proxyCF = data.proxyCF
	local isExplosion = data.isExplosion == true
	local isProjectile = data.isProjectile == true
	local v4

	if typeof(collisionPos) == "Vector3" or typeof(proxyCF) == "CFrame" or isExplosion or isProjectile or data.victim ~= nil then
		v4 = {
			ForcedCollisionPosition = 0,
			ProxyCF = 0,
			IsExplosion = 0,
			IsProjectile = 0,
			ProjectileVfxId = 0,
			Victim = 0
		}

		if typeof(collisionPos) ~= "Vector3" or not collisionPos then
			if typeof(proxyCF) == "CFrame" then
				collisionPos = proxyCF.Position or nil
			else
				collisionPos = nil
			end
		end

		v4.ForcedCollisionPosition = collisionPos
		v4.ProxyCF = typeof(proxyCF) == "CFrame" and proxyCF or nil
		v4.IsExplosion = isExplosion
		v4.IsProjectile = isProjectile
		v4.ProjectileVfxId = data.projVfxId
		v4.Victim = data.victim
	end

	HeadlessPlayback.activateBranch(runToken, branchName, serverTime, v4, branchStartTime, activeSet, branchOrdinal)
end)