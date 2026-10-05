local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local Promise = require(ReplicatedStorage.Utilities.Promise)
local v = {}
local v2 = {}
local v3 = {}

local function copyContainerMetadata(folder, folder2)
	folder2.Name = folder.Name
	folder2.Archivable = folder.Archivable

	for k, v4 in folder:GetAttributes() do
		folder2:SetAttribute(k, v4)
	end

	for _, tag in folder:GetTags() do
		folder2:AddTag(tag)
	end
end

local prepareReplicationUnits

prepareReplicationUnits = function(instance, parent, cframe: CFrame, list)
	for _, folder in instance:GetChildren() do
		if folder:IsA("Folder") then
			local folder2 = Instance.new("Folder")
			copyContainerMetadata(folder, folder2)
			folder2.Parent = parent
			prepareReplicationUnits(folder, folder2, cframe, list)
		else
			table.insert(list, {
				instance = folder,
				targetParent = parent,
				placementTransform = cframe
			})
		end
	end
end

local collectRemovalUnits

collectRemovalUnits = function(instance, folders)
	for _, folder in instance:GetChildren() do
		table.insert(folders, folder)

		if folder:IsA("Folder") then
			collectRemovalUnits(folder, folders)
		end
	end
end

local function freezeMapParts(folder)
	local parts = {}

	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") or part.Anchored then
			continue
		end

		table.insert(parts, part)
		part.Anchored = true
	end

	return parts
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreMapParts(items)
	for _, item in items do
		if item.Parent then
			item.Anchored = false
		end
	end
end

local function cancelReplicationState(state)
	state.cancelled = true

	if state.replicationThread then
		pcall(task.cancel, state.replicationThread)
		state.replicationThread = nil
	end

	if state.sourceContainers then
		for _, sourceContainer in state.sourceContainers do
			sourceContainer:Destroy()
		end

		state.sourceContainers = nil
	end
end

local function slowlyReplicateMap(clone, model, mapParent, cframe: CFrame, fn)
	local v4 = {}
	prepareReplicationUnits(clone, model, cframe, v4)
	local v5 = freezeMapParts(clone)
	local primaryPart = clone.PrimaryPart
	model.Parent = mapParent
	local sourceContainers = { clone }
	local v7 = {
		cancelled = false,
		replicationThread = nil,
		sourceContainers = sourceContainers
	}
	v7.replicationThread = task.defer(function()
		local count = #v4
		local lastTime = os.clock()
		local v8 = 1

		while v8 <= count and not v7.cancelled do
			local v9 = math.max(1, (math.floor(math.clamp((os.clock() - lastTime) / 5, 0, 1) * count)))

			while v8 <= v9 and v8 <= count do
				local v10 = v4[v8]

				if v10.instance:IsA("Model") then
					v10.instance:PivotTo(v10.placementTransform * v10.instance:GetPivot())
				elseif v10.instance:IsA("BasePart") then
					v10.instance.CFrame = v10.placementTransform * v10.instance.CFrame
				end

				v10.instance.Parent = v10.targetParent
				v8 += 1
			end

			if v8 <= count then
				RunService.Heartbeat:Wait()
			end
		end

		if v7.cancelled then
			return
		end

		if primaryPart and primaryPart:IsDescendantOf(model) then
			model.PrimaryPart = primaryPart
		end

		restoreMapParts(v5) -- equivalent call inferred; original call site unknown

		for _, v9 in sourceContainers do
			v9:Destroy()
		end

		v7.sourceContainers = nil
		v7.replicationThread = nil
		fn()
	end)
	return v7
end

-- equivalent calls inferred from this helper; original call sites unknown
local function slowlyRemoveMap(state)
	return Promise.defer(function(callback, _, callback2)
		local mapClone = state.mapClone
		local v4 = {}
		collectRemovalUnits(mapClone, v4)
		local flag = false
		callback2(function()
			flag = true
			mapClone:Destroy()
			v2[state] = nil
		end)
		local count = #v4
		local lastTime = os.clock()
		local count2 = 0

		while count2 < count and not flag do
			local v5 = math.max(1, (math.floor(math.clamp((os.clock() - lastTime) / 5, 0, 1) * count)))

			while count2 < v5 and count2 < count do
				local v6 = v4[count - count2]

				if v6:IsDescendantOf(mapClone) then
					v6.Parent = nil
					v6:Destroy()
				end

				count2 += 1
			end

			if count2 < count then
				RunService.Heartbeat:Wait()
			end
		end

		if flag then
			return
		end

		mapClone:Destroy()
		v2[state] = nil
		callback()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startKeycapLoad(streamedKeycapsFolderName: string, source, cframe: CFrame)
	local KeycapMapLoader = require(ServerScriptService._FRAMEWORK.ServerLibraries.KeycapMapLoader)
	return KeycapMapLoader.load({
		id = streamedKeycapsFolderName,
		source = source,
		worldTransform = cframe
	})
end

local function checkAddMapReady(p)
	if p.templateName == "" then
		return false, nil, "AdminAbuseUtils.Map.addMap requires a templateName"
	end

	local adminAbuseMaps = ServerStorage:FindFirstChild("AdminAbuseMaps")

	if not adminAbuseMaps then
		return false, nil, "ServerStorage.AdminAbuseMaps was not found"
	end

	local model = adminAbuseMaps:FindFirstChild(p.templateName)

	if not (model and model:IsA("Model")) then
		return false, nil, string.format("AdminAbuseMaps.%s must be a Model", p.templateName)
	end

	local adminAbuse = Workspace:FindFirstChild("AdminAbuse")

	if not adminAbuse then
		return false, nil, "Workspace.AdminAbuse was not found"
	end

	local map = adminAbuse:FindFirstChild("Map")

	if not map then
		return false, nil, "Workspace.AdminAbuse.Map was not found"
	end

	local bossRoomRootPosition = adminAbuse:FindFirstChild("BossRoomRootPosition")

	if bossRoomRootPosition and bossRoomRootPosition:IsA("BasePart") then
		return true, {
			mapTemplate = model,
			mapParent = map,
			bossRoomRootPosition = bossRoomRootPosition
		}, ""
	end

	return false, nil, "Workspace.AdminAbuse.BossRoomRootPosition must be a BasePart"
end

local function applyAddMap(data, data2)
	local clone = data2.mapTemplate:Clone()
	local worldTransform = data2.bossRoomRootPosition.CFrame * clone:GetPivot():Inverse()

	if data.prepareSource then
		data.prepareSource(clone, worldTransform)
	end

	local model = Instance.new("Model")
	model.Name = data.liveName or `{data.templateName}_Live`
	model:PivotTo(data2.bossRoomRootPosition.CFrame)

	for k, v5 in clone:GetAttributes() do
		model:SetAttribute(k, v5)
	end

	for _, tag in clone:GetTags() do
		model:AddTag(tag)
	end

	local v5 = nil

	if data.streamedKeycapsFolderName then
		local keycaps = clone:FindFirstChild("Keycaps")

		if keycaps then
			keycaps.Parent = nil
			v5 = keycaps
		else
			warn(string.format("[AdminAbuseUtils] Map folder '%s' was not found; keycaps were not streamed", "Keycaps"))
		end
	end

	local v6 = nil
	v6 = {
		mapClone = model,
		streamedKeycapsFolder = nil,
		mapLoaded = Promise.defer(function(callback, _, callback2)
			local v7 = nil
			local v8 = nil
			local v9 = false
			local v10 = true
			local v11 = false

			-- equivalent calls inferred from this helper; original call sites unknown
			local function tryResolve()
				if v9 and v10 and not v11 then
					v11 = true
					callback()
				end
			end

			if callback2(function()
				if v7 then
					cancelReplicationState(v7)
				else
					clone:Destroy()
					model:Destroy()
				end

				if v8 then
					v8.cancel()
				elseif v5 then
					v5:Destroy()
				end
			end) then
				return
			end

			if v5 and data.streamedKeycapsFolderName then
				v8 = startKeycapLoad(data.streamedKeycapsFolderName, v5, worldTransform)

				if v8 then
					v10 = false
					v6.streamedKeycapsFolder = v8.folder
					v3[v6] = v8
					v8.loaded:andThen(function()
						v10 = true
						tryResolve() -- equivalent call inferred; original call site unknown
					end)
				else
					v5:Destroy()
				end
			end

			v7 = slowlyReplicateMap(clone, model, data2.mapParent, worldTransform, function()
				v9 = true
				tryResolve() -- equivalent call inferred; original call site unknown
			end)
			v[v6] = v7
		end)
	}
	return v6
end

local Map = {}

function Map.getMap(childName: string)
	local adminAbuse = Workspace:FindFirstChild("AdminAbuse")

	if not adminAbuse then
		return nil
	end

	local map = adminAbuse:FindFirstChild("Map")

	if not map then
		return nil
	end

	local model = map:FindFirstChild(childName)

	if model and model:IsA("Model") then
		return model
	end

	return nil
end

function Map.getTaggedInstances(tag: string, map)
	local result = {}
	local adminAbuse = Workspace:FindFirstChild("AdminAbuse")

	if not map then
		if adminAbuse then
			map = adminAbuse:FindFirstChild("Map")
		else
			map = nil
		end
	end

	if not map then
		warn("[AdminAbuseUtils.Map] Couldn't find map for getTaggedInstances call:", debug.traceback())
		return result
	end

	for _, v4 in CollectionService:GetTagged(tag) do
		if v4 ~= map and v4:IsDescendantOf(map) then
			table.insert(result, v4)
		end
	end

	return result
end

function Map.addMap(p)
	if RunService:IsClient() then
		return nil
	end

	local v4, v5, v6 = checkAddMapReady(p)

	if v4 and v5 then
		return (applyAddMap(p, v5))
	end

	error(v6)
end

function Map.removeMap(state)
	if RunService:IsClient() or state == nil then
		return
	end

	local v4 = v2[state]

	if v4 then
		return v4
	end

	state.mapLoaded:cancel()
	local v5 = v[state]

	if v5 then
		cancelReplicationState(v5)
		v[state] = nil
	end

	local v6 = v3[state]

	if v6 then
		v6.unload()
		v3[state] = nil
		state.streamedKeycapsFolder = nil
	end

	if state.mapClone.Parent == nil then
		return Promise.resolve()
	end

	local v7 = slowlyRemoveMap(state) -- equivalent call inferred; original call site unknown
	v2[state] = v7
	return v7
end

return Map