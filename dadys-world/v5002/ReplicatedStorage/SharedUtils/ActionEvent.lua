local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Network = require(ReplicatedStorage.SharedUtils.Network)
local Signal = require(ReplicatedStorage.SharedUtils.Signal)
local Universe = require(ReplicatedStorage.SharedUtils.Universe)
local isClient = RunService:IsClient()
local triggered = Signal.new()
local ActionEvent = {
	Triggered = triggered
}
local v2 = {
	ExtractBegin = function(_, _) end,
	ExtractStopped = function(_, _) end,
	ExtractContinue = function(_, _) end,
	ExtractFailed = function(_, _) end,
	ExtractCompleted = function(_, _) end,
	ExctractionSkillCheck = function(_, _) end,
	SpottedByTwisted = function(_, _) end,
	EncounterTwisted = function(_, _) end,
	HurtByTwisted = function(_, _) end,
	KilledByTwisted = function(_, _) end,
	ExtinguishedTwisted = function(_, _) end,
	ExperiencedBlackout = function(_, _) end,
	ExperiencedIchorSpill = function(_, _) end,
	ExperiencedFloorEvent = function(_, _) end,
	UseItem = function(_, _) end,
	PickUpItem = function(_, _) end,
	PurchaseItem = function(_, _) end,
	PickupHolidayCurrency = function(_, _) end,
	ReceiveItem = function(_, _) end,
	StashRetrieve = function(_, _) end,
	UseActiveAbility = function(_, _) end,
	UsePassiveAbility = function(_, _) end,
	ReceiveActiveAbility = function(_, _) end,
	MachineBuffed = function(_, _) end,
	EnterFloor = function(_, _) end,
	CompleteFloor = function(_, _) end,
	VoteCard = function(_, _) end,
	UseSticker = function(_, _) end,
	EarnedIchor = function(_, _) end,
	PurchaseToon = function(_, _) end,
	PickupTapes = function(_, _) end,
	TriggerDialog = function(_, _) end,
	VisitStoryTrigger = function(_, _) end,
	TriggerTrinket = function(_, _) end,
	PickupResearchCapsule = function(_, _) end,
	OpenTrickOrTreatDoor = function(_, _) end,
	EnterIchorPuddle = function(_, _) end,
	ProtectToon = function(_, _) end
}

local function getPlayerCharacters(playerFromCharacter)
	local toonNames = {}
	local count = 0

	for _, v3 in pairs(Players:GetPlayers()) do
		if not (v3 ~= playerFromCharacter and v3 and v3.Parent and v3.Character) then
			continue
		end

		if not v3.Character.Parent then
			continue
		end

		local toonName = v3.Character:GetAttribute("ToonName")

		if not toonName then
			continue
		end

		toonNames[v3] = toonName
		count += 1
	end

	return toonNames, count
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getMapName()
	local currentRoom = workspace:WaitForChild("CurrentRoom")
	local v3 = currentRoom:GetChildren()[1] or currentRoom:FindFirstChildWhichIsA("Model")

	if v3 then
		return v3.Name
	end

	return "Elevator"
end

local function getActiveFloorEvents()
	local v3 = {}
	local info = workspace:FindFirstChild("Info")

	if not info then
		return v3
	end

	local blackOut = info:FindFirstChild("BlackOut")

	if blackOut and blackOut.Value == true then
		table.insert(v3, "Blackout")
	end

	local currentRoom = workspace:FindFirstChild("CurrentRoom")
	local currentRoomModel = currentRoom and currentRoom:FindFirstChildOfClass("Model")

	if currentRoomModel and currentRoomModel:FindFirstChild("Puddles") then
		table.insert(v3, "IchorSpill")
	end

	if info:GetAttribute("SpringFeverActive") then
		table.insert(v3, "SpringFever")
	end

	if info:GetAttribute("HauntedGalaActive") then
		table.insert(v3, "HauntedGala")
	end

	local cardModifiers = info:FindFirstChild("CardModifiers")
	local iceSkatingEnabled = cardModifiers and cardModifiers:FindFirstChild("IceSkatingEnabled")

	if iceSkatingEnabled and iceSkatingEnabled.Value == true then
		table.insert(v3, "IcedOver")
	end

	table.sort(v3)
	return v3
end

local v3 = {}

function ActionEvent.ListenForEvent(_, value: string, callback)
	if not value or typeof(value) ~= "string" then
		return
	end

	if not v3[value] then
		v3[value] = {}
	end

	table.insert(v3[value], callback)
end

local function RecordAction(playerFromCharacter, value: string, ...)
	if playerFromCharacter and typeof(playerFromCharacter) == "Instance" and playerFromCharacter:IsA("Model") then
		playerFromCharacter = Players:GetPlayerFromCharacter(playerFromCharacter)
	end

	if not playerFromCharacter or typeof(playerFromCharacter) ~= "Instance" or not (playerFromCharacter:IsA("Player") and playerFromCharacter.Parent) then
		return
	end

	if not value or typeof(value) ~= "string" then
		return
	end

	local v4 = v2[value]
	local character = playerFromCharacter.Character

	if not (character and character.Parent) then
		return
	end

	local playerCharacters, v5 = getPlayerCharacters(playerFromCharacter)
	local mapName, floorNumber, activeFloorEvents

	if Universe:IsGame() then
		mapName = getMapName()
		floorNumber = workspace:WaitForChild("Info"):WaitForChild("Floor").Value
		activeFloorEvents = getActiveFloorEvents()
	else
		activeFloorEvents = {}
		mapName = "N/A"
		floorNumber = 0
	end

	local v8 = {
		Args = { ... },
		Type = value,
		Player = playerFromCharacter,
		PlayingWith = playerCharacters,
		PlayerCount = v5 + 1,
		ActiveFloorEvents = activeFloorEvents,
		MapName = mapName,
		FloorNumber = floorNumber,
		ToonName = character:GetAttribute("ToonName"),
		Trinket1 = character:GetAttribute("EquippedTrinket1"),
		Trinket2 = character:GetAttribute("EquippedTrinket2"),
		CurrentSkin = character:GetAttribute("CurrentSkin")
	}

	if v4 then
		v4(playerFromCharacter, v8)
	end

	triggered:Fire(playerFromCharacter, v8)
end

if not isClient then
	Network:AddAction("ActionEventRecord", function(...) end)
end

function ActionEvent.Record(_, p, p2: string, ...)
	if isClient and p == Players.LocalPlayer then
		return
	end

	if not isClient then
		RecordAction(p, p2, ...)
	end
end

if not isClient then
	triggered:Connect(function(p, p2)
		local v4 = v3[p2.Type]

		if v4 and #v4 > 0 then
			for _, callback in pairs(v4) do
				task.spawn(callback, p, p2)
			end
		end
	end)
end

return ActionEvent