local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.packages
local Replion = require(packages.Replion)
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local modules = ReplicatedStorage.shared.modules
local QuestShared = require(modules.QuestShared)
require(modules.Quests)
local QuestTypes = require(modules.QuestTypes)
local utils = ReplicatedStorage.shared.utils
local FischUtils = require(utils.FischUtils)
local legacyControllers = ReplicatedStorage.client.legacyControllers
local DataController = require(legacyControllers.DataController)
local remoteEvent = Net:RemoteEvent("Quests/RequestNavigate", -1)
local color = Color3.new(1, 1, 1)
local NavigationController = {
	localData = nil,
	globalData = nil,
	nodes = {},
	groupNodes = {},
	activeTrove = Trove.new(),
	activeMarkers = {}
}

local function makeNode(group)
	local v = {
		Group = group,
		Neighbors = {},
		F = 0,
		G = 0,
		H = 0,
		Parent = nil
	}
	table.insert(NavigationController.nodes, v)
	NavigationController.groupNodes[group] = v
	return v
end

function NavigationController:AddNode(p)
	local groupNode = NavigationController.groupNodes[p.to]
	local groupNode2 = NavigationController.groupNodes[p.from]
	local v = groupNode or makeNode(p.to)
	local v2 = groupNode2 or makeNode(p.from)

	if not table.find(v2.Neighbors, v) then
		table.insert(v2.Neighbors, v)
	end
end

function NavigationController:RemoveNode(p)
	local teleports = NavigationController.globalData:Get("teleports")

	for _, teleport in teleports do
		if teleport ~= p and teleport.from == p.to and teleport.from == p.from then
			return
		end
	end

	local groupNode = NavigationController.groupNodes[p.to]
	local groupNode2 = NavigationController.groupNodes[p.from]
	local index = groupNode and table.find(groupNode.Neighbors, groupNode2)

	if index then
		table.remove(groupNode.Neighbors, index)
	end

	local index2 = groupNode2 and table.find(groupNode2.Neighbors, groupNode)

	if index2 then
		table.remove(groupNode2.Neighbors, index2)
	end
end

function NavigationController:BuildNodes()
	local teleports = NavigationController.globalData:Get("teleports")

	for _, teleport in teleports do
		NavigationController:AddNode(teleport)
	end
end

function NavigationController:FindGroupPath(p: string, p2: string)
	if p == p2 then
		return nil
	end

	local groupNode = NavigationController.groupNodes[p]
	local parent = NavigationController.groupNodes[p2]

	if not (groupNode and parent) then
		return nil
	end

	local v = {
		[groupNode] = true
	}

	local function FindLowestFNode()
		local F = 1e999
		local v2 = nil

		for k in pairs(v) do
			if not (k.F < F) then
				continue
			end

			F = k.F
			v2 = k
		end

		return v2
	end

	local v2 = {}
	local flag = false
	local result = {}

	while next(v) do
		local F = 1e999
		local parent2 = nil

		for k in pairs(v) do
			if not (k.F < F) then
				continue
			end

			F = k.F
			parent2 = k
		end

		v[parent2] = nil
		v2[parent2] = true

		if parent2 == parent then
			flag = true
			break
		end

		for _, neighbor in ipairs(parent2.Neighbors) do
			if v2[neighbor] then
				continue
			end

			if v[neighbor] then
				if neighbor.G < parent2.G then
					neighbor.Parent = parent2
					neighbor.G = parent2.G + 1
					neighbor.F = neighbor.G + neighbor.H
				end
			else
				v[neighbor] = true
				neighbor.Parent = parent2
				neighbor.G = parent2.G + 1
				neighbor.H = 1
				neighbor.F = neighbor.G + neighbor.H
			end
		end
	end

	if flag then
		while parent do
			table.insert(result, 1, parent.Group)
			parent = parent.Parent
		end
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function ResetNodeDictionary(items)
		for k in pairs(items) do
			k.F = 0
			k.G = 0
			k.H = 0
			k.Parent = nil
		end
	end

	ResetNodeDictionary(v) -- equivalent call inferred; original call site unknown
	ResetNodeDictionary(v2) -- equivalent call inferred; original call site unknown

	if flag then
		return result
	end

	return nil
end

function NavigationController:GetNextTarget(vector: Vector3, data)
	local zoneMeta = FischUtils.GetZoneMeta(vector)
	local group = zoneMeta.Group or zoneMeta.Name

	if group == (data.group or data.zone) then
		if data.maxdist and not ((data.at - vector).Magnitude < data.maxdist) then
			return nil
		end

		return data.at
	else
		local groupPath = NavigationController:FindGroupPath(zoneMeta.Group or zoneMeta.Name, data.group or data.zone)

		if groupPath then
			local teleports = NavigationController.globalData:Get("teleports")
			local v = 1e999
			local at = nil

			for _, teleport in teleports do
				if not (teleport.from == group and teleport.to == groupPath[2]) then
					continue
				end

				local magnitude = (teleport.at - vector).Magnitude

				if not (magnitude < v) then
					continue
				end

				at = teleport.at
				v = magnitude
			end

			return at
		elseif data.maxdist and not ((data.at - vector).Magnitude < data.maxdist) then
			return nil
		else
			return data.at
		end
	end
end

function NavigationController:UpdateDistances()
	local primaryPart = localPlayer.Character and localPlayer.Character.PrimaryPart

	if not primaryPart then
		return
	end

	local position = primaryPart.Position

	for _, activeMarker in NavigationController.activeMarkers do
		if not activeMarker.Parent then
			continue
		end

		local magnitude = math.round((activeMarker.StudsOffsetWorldSpace - position).Magnitude)
		activeMarker.distanceLabel.Text = `{magnitude}m`

		if not (activeMarker:GetAttribute("AutoStop") and (activeMarker:GetAttribute("AutoStop") - position).Magnitude < 12) then
			continue
		end

		remoteEvent:FireServer(nil, "autostop")
	end
end

function NavigationController:GetActiveTargets()
	local data = DataController.PlayerDataReplicator.Data

	if not (data and data.Navigation.Mode and data.Navigation.Target) then
		return {}
	end

	if data.Navigation.Mode == "quest" then
		local target = data.Navigation.Target
		local questData = target and QuestShared:GetQuestData(localPlayer, target)
		local active = NavigationController.localData:Get("active")

		if not questData or not questData.NavigationTargets or not active or #active == 0 then
			return {}
		end

		local questType = QuestTypes[questData.QuestType]
		local result = table.create(#active)

		for k, v in active do
			local navigationTarget = questData.NavigationTargets[v]

			if not navigationTarget then
				continue
			end

			if not navigationTarget.Icon then
				navigationTarget.Icon = questType.IconBillboard
			end

			if not navigationTarget.Color then
				navigationTarget.Color = questType.Color:ToHex()
			end

			result[k] = questData.NavigationTargets[v]
		end

		return result
	else
		if data.Navigation.Mode == "custom" then
			return data.Navigation.Target
		end

		warn((`[NavigationController] Unknown navigation mode "{data.Navigation.Mode}"!`))
		return {}
	end
end

function NavigationController:Update()
	NavigationController.activeTrove:Clean()
	table.clear(NavigationController.activeMarkers)
	local primaryPart = localPlayer.Character and localPlayer.Character.PrimaryPart

	if not primaryPart then
		return
	end

	local position = primaryPart.Position
	local activeTargets = NavigationController:GetActiveTargets()
	local data = DataController.PlayerDataReplicator.Data
	local targets = NavigationController.globalData:Get("targets")
	local v = {}

	for _, activeTarget in activeTargets do
		local tags = activeTarget.Tags

		if not tags then
			continue
		end

		local targets2 = {}
		local v2 = 1e999
		local v3 = nil

		for _, tag in tags do
			for _, target in targets do
				if target.tag ~= tag or target.uid and NavigationController.localData:Find("hidden", target.uid) then
					continue
				end

				table.insert(targets2, target)
				local magnitude = (target.at - position).Magnitude

				if not (magnitude < v2) then
					continue
				end

				v3 = target
				v2 = magnitude
			end
		end

		if #targets2 == 0 then
			continue
		end

		local v4 = activeTarget.OnlyNearest and { v3 } or targets2
		local color2 = Color3.fromHex(activeTarget.Color or "ffffff")

		for _, v5 in v4 do
			local nextTarget = NavigationController:GetNextTarget(position, v5)

			if not nextTarget or v[nextTarget] then
				continue
			end

			v[nextTarget] = true
			local clone = script.NavTarget:Clone()
			clone.StudsOffsetWorldSpace = nextTarget
			clone.typeIcon.Image = activeTarget.Icon or ""
			clone.typeIcon.ImageColor3 = color2
			clone.distanceLabel.UIGradient.Color = ColorSequence.new(color2:Lerp(color, 0.35), color)
			clone.Name = `NavMarker_{v5.tag}_{v5.uid}`

			if v5.maxdist and (v5.at - nextTarget).Magnitude < 1 then
				clone.MaxDistance = v5.maxdist
			end

			clone.Enabled = true
			clone.Parent = localPlayer.PlayerGui
			table.insert(NavigationController.activeMarkers, clone)
			NavigationController.activeTrove:Add(clone)

			if data and data.Navigation.AutoStop then
				clone:SetAttribute("AutoStop", v5.at)
			end
		end
	end
end

function NavigationController.Start(_)
	NavigationController.localData = Replion.Client:WaitReplion("QuestNavigation")
	NavigationController.globalData = Replion.Client:WaitReplion("QuestNavigationGlobal")
	NavigationController.localData:OnDataChange(function()
		NavigationController:Update()
	end)
	DataController.PlayerDataReplicator:Observe({ "Navigation" }, function()
		NavigationController:Update()
	end)
	NavigationController.globalData:OnArrayInsert("teleports", function(_, p)
		NavigationController:AddNode(p)
	end)
	NavigationController.globalData:OnArrayRemove("teleports", function(_, p)
		NavigationController:RemoveNode(p)
	end)
	NavigationController.globalData:OnChange("targets", function()
		NavigationController:Update()
	end)
	NavigationController:BuildNodes()
	local maid = Trove.new()

	local function onZoneVal(objectValue)
		if objectValue.Name ~= "zone" or not objectValue:IsA("ObjectValue") then
			return
		end

		maid:Add(objectValue.Changed:Connect(function()
			NavigationController:Update()
		end))
		NavigationController:Update()
	end

	local function onCharacter(character)
		maid:Clean()
		local zone = character:FindFirstChild("zone")

		if zone and zone:IsA("ObjectValue") then
			onZoneVal(zone)
		else
			maid:Add(character.ChildAdded:Connect(onZoneVal))
		end
	end

	if localPlayer.Character then
		onCharacter(localPlayer.Character)
	end

	localPlayer.CharacterAdded:Connect(onCharacter)
	RunService.Heartbeat:Connect(function()
		NavigationController:UpdateDistances()
	end)
	task.spawn(function()
		while true do
			task.spawn(NavigationController.Update, NavigationController)
			task.wait(5)
		end
	end)
end

return NavigationController