local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuideArrow = require(ReplicatedStorage:WaitForChild("SharedUtils"):WaitForChild("GuideArrow"))
local MyDataController = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("ClientUI"):WaitForChild("MyDataController"))
local localPlayer = Players.LocalPlayer
local floorActive = workspace:WaitForChild("Info"):WaitForChild("FloorActive")
local panic = workspace:WaitForChild("Info"):WaitForChild("Panic")
local thread = nil
local v = nil

local function getInRoundCharacter()
	local character = localPlayer.Character

	if not (character and character.Parent) then
		return nil
	end

	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if inGamePlayers and character.Parent == inGamePlayers then
		return character
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCurrentFloor()
	local info = workspace:FindFirstChild("Info")
	local floor = info and info:FindFirstChild("Floor")

	if floor and floor:IsA("IntValue") then
		return floor.Value
	end

	return 0
end

local function isPlayerEligible()
	local character = localPlayer.Character

	if character and character.Parent then
		local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

		if not inGamePlayers or character.Parent ~= inGamePlayers then
			character = nil
		end
	else
		character = nil
	end

	if not (character and character:FindFirstChild("HumanoidRootPart")) then
		return false
	end

	local currentFloor = getCurrentFloor() -- equivalent call inferred; original call site unknown

	if currentFloor < 1 or currentFloor > 20 or (MyDataController:getDataFromPath("DandysBud.Missions.PickingUpThePace") or 0) ~= 0 or localPlayer:GetAttribute("IsBud") ~= true then
		return false
	end

	return not (localPlayer.Character and localPlayer.Character:GetAttribute("_GenTeleportPart"))
end

local function getCurrentRoomGenerators()
	local currentRoom = workspace:FindFirstChild("CurrentRoom")

	if not currentRoom then
		return {}
	end

	local result = {}

	for _, v2 in pairs(CollectionService:GetTagged("Generator")) do
		if v2:IsDescendantOf(currentRoom) then
			result[#result + 1] = v2
		end
	end

	return result
end

local function isQualifyingGen(folder)
	local stats = folder:FindFirstChild("Stats")
	local completed = stats and stats:FindFirstChild("Completed")

	if completed and completed:IsA("BoolValue") and completed.Value then
		return false
	end

	for _, proximityPrompt in ipairs(folder:GetDescendants()) do
		if proximityPrompt:IsA("ProximityPrompt") and proximityPrompt.Enabled then
			return true
		end
	end

	return false
end

local function nearestQualifyingGen(position: Vector3)
	local currentRoomGenerators = getCurrentRoomGenerators()
	local v2 = 1e999
	local v3 = nil
	local position2 = nil

	for _, model in ipairs(currentRoomGenerators) do
		if not model:IsA("Model") then
			continue
		end

		local primaryPart = model.PrimaryPart

		if not (primaryPart and isQualifyingGen(model)) then
			continue
		end

		local magnitude = (primaryPart.Position - position).Magnitude

		if not (magnitude < v2) then
			continue
		end

		position2 = primaryPart.Position
		v3 = model
		v2 = magnitude
	end

	return v3, position2
end

local function shouldTearDown()
	return not isPlayerEligible()
end

local function tick()
	if isPlayerEligible() then
		local character = localPlayer.Character

		if character and character.Parent then
			local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

			if not inGamePlayers or character.Parent ~= inGamePlayers then
				character = nil
			end
		else
			character = nil
		end

		local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local v2, v3 = nearestQualifyingGen(humanoidRootPart.Position)

		if v2 and v3 then
			if v2 ~= v then
				v = v2
				GuideArrow:SetDestinationUntil(v3, shouldTearDown, "Normal")
				print(string.format("[NewbieGuide] target=%s floor=%d", v2.Name, getCurrentFloor()))
			end
		elseif v then
			GuideArrow:SetDestinationUntil(nil)
			v = nil
		end
	elseif v then
		GuideArrow:SetDestinationUntil(nil)
		v = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startPolling()
	if thread then
		return
	end

	print("[NewbieGuide] startPolling")
	thread = task.spawn(function()
		while true do
			tick()
			task.wait(0.5)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopPolling()
	if thread then
		print("[NewbieGuide] stopPolling")
		task.cancel(thread)
		thread = nil
	end

	v = nil
end

local function shouldListen()
	return (MyDataController:getDataFromPath("DandysBud.Missions.PickingUpThePace") or 0) == 0
end

local function shouldPoll(instance)
	return not not floorActive.Value and not panic.Value and not instance:GetAttribute("_GenTeleportPart")
end

return {
	setupAll = function()
		local v2 = nil
		local v3 = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function evaluate()
			local v4 = v3
			local v5

			if floorActive.Value and not panic.Value then
				v5 = not v4:GetAttribute("_GenTeleportPart")
			else
				v5 = false
			end

			if v5 then
				startPolling() -- equivalent call inferred; original call site unknown
			else
				stopPolling() -- equivalent call inferred; original call site unknown
			end
		end

		local function stopListening()
			if v2 then
				for _, connection in pairs(v2) do
					connection:Disconnect()
				end

				v2 = nil
				stopPolling() -- equivalent call inferred; original call site unknown
			end
		end

		local function checkListening()
			if (MyDataController:getDataFromPath("DandysBud.Missions.PickingUpThePace") or 0) ~= 0 and v2 then
				for _, connection in pairs(v2) do
					connection:Disconnect()
				end

				v2 = nil
				stopPolling() -- equivalent call inferred; original call site unknown
			end
		end

		MyDataController:onReplicaReady(function(object)
			if (MyDataController:getDataFromPath("DandysBud.Missions.PickingUpThePace") or 0) ~= 0 then
				return
			end

			v2 = {}
			local character = localPlayer.Character

			if character and character.Parent then
				local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

				if not inGamePlayers or character.Parent ~= inGamePlayers then
					character = nil
				end
			else
				character = nil
			end

			v3 = character
			v2[#v2 + 1] = floorActive:GetPropertyChangedSignal("Value"):Connect(evaluate)
			v2[#v2 + 1] = panic:GetPropertyChangedSignal("Value"):Connect(evaluate)

			if not v3 then
				task.spawn(function()
					while true do
						local character2 = localPlayer.Character

						if character2 and character2.Parent then
							local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

							if not inGamePlayers or character2.Parent ~= inGamePlayers then
								character2 = nil
							end
						else
							character2 = nil
						end

						v3 = character2
						task.wait(1)

						if not v3 then
							continue
						end

						v2[#v2 + 1] = v3:GetAttributeChangedSignal("_GenTeleportPart"):Connect(evaluate)
						break
					end
				end)
			end

			v2[#v2 + 1] = object:ListenToChange("DandysBud.Missions.PickingUpThePace", checkListening)
			evaluate() -- equivalent call inferred; original call site unknown
		end, function()
			warn("[NewbieGuide] replica unavailable; guide will not run this session")
		end)
	end
}