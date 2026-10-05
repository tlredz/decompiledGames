local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local packages = ReplicatedStorage:WaitForChild("packages")
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local Timer = require(packages.Timer)
local modules = ReplicatedStorage.shared.modules
require(modules.character.quest)
local zones = require(modules.library.fish.zones)
local fish = require(modules.library.fish)
local crabzone = require(modules.library.fish.zones.crabzone)
local QuestLine = require(modules.QuestLine)
local legacyLocalPlayerData = require(ReplicatedStorage.client.modules.legacyLocalPlayerData)
local DataController = require(ReplicatedStorage.client.legacyControllers.DataController)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local fetched = legacyLocalPlayerData.fetch()
local quests = fetched:WaitForChild("Quests")
local questActive = fetched:WaitForChild("QuestActive")
fetched:WaitForChild("QuestFinished")
local stats = fetched:WaitForChild("Stats")
local tracker_quests = stats:WaitForChild("tracker_quests")
local tracker_anglerquests = stats:WaitForChild("tracker_anglerquests")
local ABTestController = require(ReplicatedStorage.client.legacyControllers.ABTests.ABTestController)
local remoteFunction = Net:RemoteFunction("QuestCompassService/RequestNereastAngler")
local maid = Trove.new()
local maid2 = Trove.new()
local v = nil
local QuestCompassController = {}

local function GetCharacter()
	local character = localPlayer.Character

	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return character, humanoidRootPart
	end
end

local function IsPlayerElegible(_)
	local v2 = RunService:IsStudio() and 5 or 12
	local serverTimeNow = workspace:GetServerTimeNow()

	while not ABTestController:IsLoaded() and workspace:GetServerTimeNow() - serverTimeNow < v2 do
		task.wait()
	end

	return true
end

function QuestCompassController:GetNereastFishingZone(vector: Vector3, p: string?)
	local v2 = {}
	local v3 = {}
	local v4 = nil
	local v5 = nil

	for _, part in workspace:WaitForChild("zones"):WaitForChild("fishing"):GetChildren() do
		if not part:IsA("BasePart") then
			continue
		end

		local v6 = true

		if p then
			local name = part.Name

			if v2[name] == nil then
				local zone = zones[name]
				local pool = zone and zone.Pool

				if not pool then
					continue
				end

				if table.find(pool, p) then
					v2[name] = true
				else
					v2[name] = false
					v6 = false
				end
			else
				v6 = v2[name]
			end
		end

		if v6 == false then
			local crabZone = part:FindFirstChild("CrabZone")

			if crabZone then
				if v3[crabZone.Value] == nil then
					local v7 = crabzone[crabZone.Value]

					if not v7 then
						continue
					end

					if table.find(v7.Pool, p) then
						v3[crabZone.Value] = true
						v6 = true
					else
						v2[crabZone.Value] = false
						v6 = false
					end
				else
					v6 = v2[crabZone.Value]
				end
			end
		end

		if v6 ~= true then
			continue
		end

		local magnitude = (part.Position - vector).Magnitude

		if not (magnitude <= (v4 or 1e999)) then
			continue
		end

		v5 = part
		v4 = magnitude
	end

	return v5
end

function QuestCompassController:GetNextQuest()
	if #quests:GetChildren() >= 1 then
		return nil
	end

	for i = 1, #QuestLine.List do
		local v2 = QuestLine.List[i]

		if (v2.QuestTracker ~= "Angler" or not (tracker_anglerquests.Value >= 1)) and not tracker_quests:FindFirstChild(v2.QuestTracker) then
			return i
		end
	end

	return nil
end

function QuestCompassController:Setup()
	maid:Clean()
	local humanoidRootPart = localPlayer.Character:WaitForChild("HumanoidRootPart")
	local questCompass = playerGui:WaitForChild("hud"):WaitForChild("safezone").questCompass
	local pointer = questCompass.Pointer
	local value = nil
	local v2 = nil
	local position = nil
	local v3 = nil

	local function OnQuestAdded(child)
		local v4 = string.split(child.Name, "_")[1]

		if v4 == "Angler Quest" then
			local name = nil

			for _, boolValue in child:GetChildren() do
				if not (boolValue:IsA("BoolValue") and fish[boolValue.Name]) then
					continue
				end

				name = boolValue.Name
				break
			end

			if not name then
				return
			end

			local nereastFishingZone = QuestCompassController:GetNereastFishingZone(humanoidRootPart.Position, name)

			if not nereastFishingZone then
				return
			end

			maid2:Clean()
			position = nereastFishingZone.Position
			value = v4
			v3 = "Quest"
			v2 = nil

			if DataController.HasItem(name, nil, true) then
				position = remoteFunction:InvokeServer()
			end

			maid2:Add(DataController.InventoryReplicator:Listen({ "Inventory" }, function(_, items)
				if value ~= nil then
					return
				end

				for _, item in items do
					if item.name ~= name then
						continue
					end

					position = remoteFunction:InvokeServer()
					break
				end
			end))
		else
			local track = child:FindFirstChild("Track") or child:FindFirstChild("TypeOfQuest")

			if not track or tracker_quests:FindFirstChild(track.Value) then
				return
			end

			for _, v5 in QuestLine.List do
				if v5.QuestTracker ~= track.Value then
					continue
				end

				value = track.Value
				position = QuestLine.Positions[v5.TargetPosition]
				v3 = "Quest"
				v2 = v5
			end
		end
	end

	maid:Add(quests.ChildAdded:Connect(function(child)
		task.wait(3)
		OnQuestAdded(child)
	end))
	maid:Add(questActive.ChildAdded:Connect(function(_)
		value = nil
		v2 = nil
		position = nil
		v3 = nil
		maid2:Clean()
	end))
	maid:Add(tracker_quests.ChildAdded:Connect(function(child)
		task.wait(2)

		if value and child.Name == v2.QuestTracker then
			value = nil
			v2 = nil
			position = nil
			v3 = nil
			maid2:Clean()
		end

		task.wait(3)

		if not value then
			for _, child2 in quests:GetChildren() do
				OnQuestAdded(child2)
			end

			local nextQuest = not value and QuestCompassController:GetNextQuest()

			if nextQuest then
				local v4 = QuestLine.List[nextQuest]
				value = v4.QuestTracker
				v2 = v4
				position = QuestLine.Positions[v4.GivePosition]
				v3 = "Give"
			end
		end
	end))
	maid:Add(quests.ChildRemoved:Connect(function(child)
		local value2 = string.split(child.Name, "_")[1]
		local track = child:FindFirstChild("Track")

		if track then
			value2 = track.Value
		else
			local typeOfQuest = child:FindFirstChild("TypeOfQuest")

			if typeOfQuest then
				value2 = typeOfQuest.Value
			end
		end

		if value2 == value then
			value = nil
			v2 = nil
			position = nil
			v3 = nil
			maid2:Clean()
			task.wait(3)

			for _, child2 in quests:GetChildren() do
				OnQuestAdded(child2)
			end

			local nextQuest = not value and QuestCompassController:GetNextQuest()

			if nextQuest then
				local v4 = QuestLine.List[nextQuest]
				value = v4.QuestTracker
				v2 = v4
				position = QuestLine.Positions[v4.GivePosition]
				v3 = "Give"
			end
		end
	end))

	for _, child in quests:GetChildren() do
		OnQuestAdded(child)
	end

	local nextQuest = not value and QuestCompassController:GetNextQuest()

	if nextQuest then
		local v4 = QuestLine.List[nextQuest]
		value = v4.QuestTracker
		v2 = v4
		position = QuestLine.Positions[v4.GivePosition]
		v3 = "Give"
	end

	maid:Add(RunService.RenderStepped:Connect(function(_: number)
		if position then
			local currentCamera = workspace.CurrentCamera

			if not currentCamera then
				return
			end

			local cFrame = currentCamera.CFrame
			local lookVector = cFrame.LookVector
			local vector = Vector3.new(lookVector.X, 0, lookVector.Z)
			local unit = (Vector3.new(position.X, 0, position.Z) - cFrame.Position).unit
			pointer.Rotation = -math.deg(math.atan2(unit.X, unit.Z) - math.atan2(vector.X, vector.Z)) - 218
		end

		local visible = position ~= nil

		if visible == true and v2 and v2.HideTargetTracker == true and v3 == "Quest" then
			visible = false
		end

		if visible == true then
			local character = localPlayer.Character
			local humanoidRootPart2

			if character then
				humanoidRootPart2 = character:FindFirstChild("HumanoidRootPart")

				if not humanoidRootPart2 then
					character = nil
					humanoidRootPart2 = nil
				end
			else
				character = nil
			end

			if character and (position - humanoidRootPart2.Position).Magnitude <= 10 then
				visible = false
			end
		end

		if visible == true and #quests:GetChildren() >= 1 then
			visible = false
		end

		questCompass.Visible = visible
	end))
	local v4 = Timer.new(5)
	maid:Add(v4, "Destroy")
	maid:Add(v4.Tick:Connect(function()
		for _, child in quests:GetChildren() do
			OnQuestAdded(child)
		end

		if #questActive:GetChildren() >= 1 then
			value = nil
			v2 = nil
			position = nil
			v3 = nil
			maid2:Clean()
		else
			local nextQuest2 = not value and QuestCompassController:GetNextQuest()

			if nextQuest2 then
				local v5 = QuestLine.List[nextQuest2]
				value = v5.QuestTracker
				v2 = v5
				position = QuestLine.Positions[v5.GivePosition]
				v3 = "Give"
			end
		end
	end))

	if #questActive:GetChildren() >= 1 then
		value = nil
		v2 = nil
		position = nil
		v3 = nil
		maid2:Clean()
	end

	v4:Start()
end

function QuestCompassController:Start()
	while ReplicatedStorage:GetAttribute("CurrentWorld") == nil do
		task.wait(0.1)
	end

	if ReplicatedStorage:GetAttribute("CurrentWorld") ~= "Sea 1" then
		return
	end

	if IsPlayerElegible(localPlayer) == true then
		localPlayer.CharacterAdded:Connect(function(character)
			if character ~= v then
				v = character
				QuestCompassController:Setup()
			end
		end)
		local character = localPlayer.Character

		if character and character ~= v then
			v = character
			QuestCompassController:Setup()
		end
	end
end

return QuestCompassController