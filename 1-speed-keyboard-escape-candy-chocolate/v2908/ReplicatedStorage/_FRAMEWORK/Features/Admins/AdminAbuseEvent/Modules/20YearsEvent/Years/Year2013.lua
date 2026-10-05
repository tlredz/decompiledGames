local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local AdminAbuseUtils = require(script.Parent.Parent.Parent.Parent.AdminAbuseUtils)
local DefaultYearMap = require(script.Parent.DefaultYearMap)
local LoggerManager = require(ReplicatedStorage._FRAMEWORK.Libraries.LoggerManager)
local MeleeRagdollTool = require(ReplicatedStorage._FRAMEWORK.Libraries.MeleeRagdollTool)
require(ReplicatedStorage._FRAMEWORK.Libraries.MeleeRagdollTool.Types)
require(script.Parent.Parent.Types)
local logger = LoggerManager.createLogger(script.Name, {
	feature = script:GetFullName()
})
local v = {
	horizontalSpeed = 37,
	verticalSpeed = 23,
	angularSpeed = 8,
	tripDurationSeconds = 1.25
}
local v2 = v.tripDurationSeconds + 1.5
local v3 = {
	rewardSource = "TwentyYearsEvent:Sword",
	reward = {
		multiplier = 10
	},
	swingCooldownSeconds = 1,
	fling = {
		horizontalSpeed = 120,
		verticalSpeed = 70,
		angularSpeed = 18,
		tripDurationSeconds = 2
	},
	slashAnimationId = "rbxassetid://522635514",
	lungeAnimationId = "rbxassetid://522638767",
	lungeComboWindowSeconds = 0.2,
	lungeDurationSeconds = 0.6
}
local color = Color3.fromRGB(150, 255, 140)
local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function getAssetTemplate(p, p2: number, childName: string)
	local yearAssets = p.yearAssets
	local child

	if yearAssets then
		child = yearAssets:FindFirstChild((tostring(p2)))
	end

	local child2

	if child then
		child2 = child:FindFirstChild(childName)
	end

	if not child2 then
		logger:warn(string.format("20th Anniversary Year %d is missing its %s asset", p2, childName))
	end

	return child2
end

local function giveToolToPlayer(p, instance, clones, list)
	local clone = instance:Clone()
	clone.Parent = p.Backpack
	table.insert(clones, clone)
	table.insert(list, MeleeRagdollTool.attach(clone, v3))
end

local function prepareZombieTemplate(model)
	local clone = model:Clone()

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = false
		elseif descendant:IsA("LuaSourceContainer") then
			descendant:Destroy()
		end
	end

	local humanoid = clone:FindFirstChildOfClass("Humanoid")

	if humanoid and not humanoid:FindFirstChildOfClass("Animator") then
		local animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	return clone
end

local function prepareZombieTemplates(assetTemplate)
	local result = {}

	for _, model in assetTemplate:GetChildren() do
		if model:IsA("Model") then
			table.insert(result, (prepareZombieTemplate(model)))
		end
	end

	return result
end

local function getZombieSpawns(map)
	local scriptables = map:FindFirstChild("Scriptables")
	local zones

	if scriptables then
		zones = scriptables:FindFirstChild("Zones")
	end

	local zombieSpawn

	if zones then
		zombieSpawn = zones:FindFirstChild("ZombieSpawn")
	end

	local parts = {}

	if zombieSpawn then
		for _, part in zombieSpawn:GetDescendants() do
			if part:IsA("BasePart") then
				table.insert(parts, part)
			end
		end
	end

	return parts
end

local function getRandomSpawnCFrame(zombieSpawns, random)
	local v4 = zombieSpawns[random:NextInteger(1, #zombieSpawns)]
	local v5 = v4.Size * 0.5
	local vector = Vector3.new(random:NextNumber(-v5.X, v5.X), -v5.Y + 3, random:NextNumber(-v5.Z, v5.Z))
	return v4.CFrame * CFrame.new(vector) * CFrame.Angles(0, random:NextNumber(0, 6.283185307179586), 0)
end

local function getKillers(humanoid)
	local result = {}

	for _, objectValue in humanoid:GetChildren() do
		if not objectValue:IsA("ObjectValue") then
			continue
		end

		local value = objectValue.Value

		if not value or not value:IsA("Player") or table.find(result, value) then
			continue
		end

		table.insert(result, value)
	end

	return result
end

local Year2013 = {}

function Year2013.load(p, p2: number)
	local loaded, v4 = DefaultYearMap.load(p, 2013)

	if not loaded then
		return nil, v4
	end

	local v5 = {}
	local v6 = {}
	local connections = {}
	local connections2 = {}
	local nowsByUserId = {}
	local assetTemplate = getAssetTemplate(p, p2, "Sword")

	if assetTemplate and assetTemplate:IsA("Tool") then
		-- equivalent calls inferred from this helper; original call sites unknown
		local function grant(p3)
			local success, result = pcall(giveToolToPlayer, p3, assetTemplate, v5, v6)

			if not success then
				logger:warn(result)
			end
		end

		for _, v7 in Players:GetPlayers() do
			if v7.Character then
				grant(v7) -- equivalent call inferred; original call site unknown
			end

			local v8 = v7
			table.insert(connections2, v7.CharacterAdded:Connect(function()
				grant(v8) -- equivalent call inferred; original call site unknown
			end))
		end

		table.insert(connections2, Players.PlayerAdded:Connect(function(player)
			table.insert(connections2, player.CharacterAdded:Connect(function()
				grant(player) -- equivalent call inferred; original call site unknown
			end))
		end))
	end

	local assetTemplate2 = getAssetTemplate(p, p2, "ZombieModels")
	local v7 = not assetTemplate2 and {} or prepareZombieTemplates(assetTemplate2)
	local zombieSpawns = getZombieSpawns(loaded.map)
	local fn = nil

	if #zombieSpawns == 0 then
		logger:warn("20th Anniversary Year 2013 map requires Scriptables.Zones.ZombieSpawn (Folder of BaseParts)")
	elseif #v7 == 0 then
		logger:warn("20th Anniversary Year 2013 ZombieModels folder contains no Models")
	else
		local NpcEngine = require(ServerScriptService._FRAMEWORK.ServerLibraries.NpcEngine)
		local winReward = MeleeRagdollTool.createWinReward("TwentyYearsEvent:Zombie", 1)
		local random = Random.new()
		local v8 = NpcEngine.new({
			rootModel = loaded.map,
			boundsZoneName = "Zone",
			rng = random,
			maxNpcs = 50
		})
		local v9 = {
			source = "template",
			templateModel = v7[1],
			walkSpeed = 14,
			maxHealth = 100,
			namePrefix = "Zombie2013",
			damageCooldownSec = 1,
			onTouchPlayer = function(instance, p3, p4, p5)
				local now = os.clock()
				local v10 = nowsByUserId[p3.UserId]

				if v10 == nil then
					nowsByUserId[p3.UserId] = now
					MeleeRagdollTool.fling(p3, instance:FindFirstChild("HumanoidRootPart"), p5, p4, v)
					p.fireToPlayer(p3, {
						kind = "zombieGrab"
					})
				elseif v2 <= now - v10 then
					nowsByUserId[p3.UserId] = now
					MeleeRagdollTool.fling(p3, instance:FindFirstChild("HumanoidRootPart"), p5, p4, v)
					p.fireToPlayer(p3, {
						kind = "zombieGrab"
					})
				end
			end,
			onDied = function(instance)
				local humanoid = instance:FindFirstChildOfClass("Humanoid")

				if humanoid then
					for _, v10 in getKillers(humanoid) do
						local success, result = pcall(winReward, v10)

						if not success then
							logger:warn(string.format(
								"Zombie kill reward failed for %s: %s",
								v10.Name,
								(tostring(result))
							))
						end
					end
				end
			end
		}

		local function topUpZombies()
			for _ = v8:getNpcCount() + 1, 50 do
				v9.templateModel = v7[random:NextInteger(1, #v7)]
				local npc = v8:spawnNpc(v9, (getRandomSpawnCFrame(zombieSpawns, random)))

				if npc then
					CollectionService:AddTag(npc, "AABossNpc")
				end
			end
		end

		topUpZombies()
		local now = os.clock()
		table.insert(connections, RunService.Heartbeat:Connect(function()
			local now2 = os.clock()

			if now2 - now >= 1.5 then
				now = now2
				topUpZombies()
			end
		end))

		fn = function()
			v8:teardown()
		end
	end

	local function stopTools()
		for _, connection in connections2 do
			connection:Disconnect()
		end

		table.clear(connections2)

		for _, v8 in v6 do
			v8.destroy()
		end

		table.clear(v6)

		for _, v8 in v5 do
			v8:Destroy()
		end

		table.clear(v5)
	end

	local cleanup = loaded.cleanup
	return {
		map = loaded.map,
		spawn = loaded.spawn,
		stopTools = stopTools,
		cleanup = function()
			stopTools()

			for _, connection in connections do
				connection:Disconnect()
			end

			table.clear(connections)

			if fn then
				fn()
				fn = nil
			end

			table.clear(nowsByUserId)

			for _, v8 in v7 do
				v8:Destroy()
			end

			cleanup()
		end
	}
end

function Year2013.loadClient(p, _: number)
	local v4 = {}
	local v5 = {}
	local v6 = {}
	local connections = {}
	local v7 = true
	local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
	colorCorrectionEffect.Name = "Zombie2013GrabTint"
	colorCorrectionEffect.Parent = Lighting
	local blurEffect = Instance.new("BlurEffect")
	blurEffect.Name = "Zombie2013GrabBlur"
	blurEffect.Size = 0
	blurEffect.Parent = Lighting

	local function playGrabEffect()
		colorCorrectionEffect.TintColor = color
		colorCorrectionEffect.Saturation = -0.35
		blurEffect.Size = 14
		TweenService:Create(colorCorrectionEffect, tweenInfo, {
			TintColor = Color3.new(1, 1, 1),
			Saturation = 0
		}):Play()
		TweenService:Create(blurEffect, tweenInfo, {
			Size = 0
		}):Play()
	end

	table.insert(connections, p.serverMessage:Connect(function(p2)
		if p2.kind == "zombieGrab" then
			playGrabEffect()
		end
	end))

	-- equivalent calls inferred from this helper; original call sites unknown
	local function isZombieRig(model)
		return model:IsA("Model") and string.sub(model.Name, 1, 11) == "Zombie2013_"
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function stopTrack(p2)
		v5[p2] = nil
		local connection = v6[p2]

		if connection then
			connection:Disconnect()
			v6[p2] = nil
		end

		local v8 = v4[p2]

		if v8 then
			v8:Stop(0)
			v8:Destroy()
			v4[p2] = nil
		end
	end

	local function playWalk(instance)
		if v4[instance] or v5[instance] then
			return
		end

		v5[instance] = true
		task.spawn(function()
			local humanoid = instance:FindFirstChildOfClass("Humanoid") or instance:WaitForChild("Humanoid", 5)

			if humanoid and humanoid:IsA("Humanoid") and not humanoid:FindFirstChildOfClass("Animator") then
				humanoid:WaitForChild("Animator", 5)
			end

			v5[instance] = nil

			if v7 and not v4[instance] and instance.Parent then
				local success, result = pcall(
					AdminAbuseUtils.Animations.loadAnimation,
					instance,
					"rbxassetid://138045145352450"
				)

				if success then
					result.Looped = true
					result.Priority = Enum.AnimationPriority.Movement
					result:Play(0)
					v4[instance] = result
					local humanoid2 = instance:FindFirstChildOfClass("Humanoid")

					if humanoid2 then
						v6[instance] = humanoid2.Died:Once(function()
							result:Stop(0.2)
						end)
					end
				else
					logger:warn(string.format("Zombie walk animation failed: %s", (tostring(result))))
				end
			end
		end)
	end

	table.insert(connections, CollectionService:GetInstanceAddedSignal("AABossNpc"):Connect(function(model)
		if isZombieRig(model) and not v4[model] then
			if v5[model] then
				return
			end

			v5[model] = true
			task.spawn(function()
				local humanoid = model:FindFirstChildOfClass("Humanoid") or model:WaitForChild("Humanoid", 5)

				if humanoid and humanoid:IsA("Humanoid") and not humanoid:FindFirstChildOfClass("Animator") then
					humanoid:WaitForChild("Animator", 5)
				end

				v5[model] = nil

				if v7 and not v4[model] and model.Parent then
					local success, result = pcall(
						AdminAbuseUtils.Animations.loadAnimation,
						model,
						"rbxassetid://138045145352450"
					)

					if success then
						result.Looped = true
						result.Priority = Enum.AnimationPriority.Movement
						result:Play(0)
						v4[model] = result
						local humanoid2 = model:FindFirstChildOfClass("Humanoid")

						if humanoid2 then
							v6[model] = humanoid2.Died:Once(function()
								result:Stop(0.2)
							end)
						end
					else
						logger:warn(string.format("Zombie walk animation failed: %s", (tostring(result))))
					end
				end
			end)
		end
	end))
	table.insert(connections, CollectionService:GetInstanceRemovedSignal("AABossNpc"):Connect(function(model)
		if model:IsA("Model") then
			stopTrack(model) -- equivalent call inferred; original call site unknown
		end
	end))

	for _, model in CollectionService:GetTagged("AABossNpc") do
		if not isZombieRig(model) or not model:IsDescendantOf(workspace) or (v4[model] or v5[model]) then
			continue
		end

		v5[model] = true
		local v8 = model
		task.spawn(function()
			local humanoid = v8:FindFirstChildOfClass("Humanoid") or v8:WaitForChild("Humanoid", 5)

			if humanoid and humanoid:IsA("Humanoid") and not humanoid:FindFirstChildOfClass("Animator") then
				humanoid:WaitForChild("Animator", 5)
			end

			v5[v8] = nil

			if v7 and not v4[v8] and v8.Parent then
				local success, result = pcall(
					AdminAbuseUtils.Animations.loadAnimation,
					v8,
					"rbxassetid://138045145352450"
				)

				if success then
					result.Looped = true
					result.Priority = Enum.AnimationPriority.Movement
					result:Play(0)
					v4[v8] = result
					local humanoid2 = v8:FindFirstChildOfClass("Humanoid")

					if humanoid2 then
						v6[v8] = humanoid2.Died:Once(function()
							result:Stop(0.2)
						end)
					end
				else
					logger:warn(string.format("Zombie walk animation failed: %s", (tostring(result))))
				end
			end
		end)
	end

	return function()
		v7 = false

		for _, connection in connections do
			connection:Disconnect()
		end

		table.clear(connections)

		for k in v4 do
			stopTrack(k) -- equivalent call inferred; original call site unknown
		end

		for k in v6 do
			stopTrack(k) -- equivalent call inferred; original call site unknown
		end

		table.clear(v5)
		colorCorrectionEffect:Destroy()
		blurEffect:Destroy()
	end
end

return Year2013