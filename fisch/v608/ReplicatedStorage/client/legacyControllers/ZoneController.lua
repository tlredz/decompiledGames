game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Signal = require(ReplicatedStorage.packages.Signal)
local ZoneController = {
	CurrentZoneName = "Ocean",
	CurrentZone = nil,
	IsUnderground = false,
	IsIndoors = false,
	IsFakeUnderwater = false,
	ZoneChanged = Signal.new()
}

local function updateZone(currentZone)
	local zonename = currentZone and currentZone:FindFirstChild("zonename")
	local currentZoneName = zonename and zonename.Value or not currentZone and "Ocean" or currentZone.Name or "Ocean"
	local underground = currentZone and currentZone:FindFirstChild("underground")
	local indoors = currentZone and currentZone:FindFirstChild("indoors")
	local value3

	if underground == nil then
		value3 = false
	else
		value3 = underground:IsA("BoolValue") and underground.Value
	end

	if not value3 then
		if indoors == nil then
			value3 = false
		else
			value3 = indoors:IsA("BoolValue") and indoors.Value
		end
	end

	ZoneController.CurrentZoneName = currentZoneName
	ZoneController.CurrentZone = currentZone
	ZoneController.IsUnderground = value3
	ZoneController.IsIndoors = value3
	ZoneController.IsFakeUnderwater = currentZone ~= nil and currentZone:HasTag("FakeUnderwaterZone")
	ZoneController.ZoneChanged:Fire(currentZoneName, currentZone, value3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setupCharacter(character)
	local zone = character:WaitForChild("zone")
	updateZone(zone.Value)
	zone.Changed:Connect(updateZone)
end

function ZoneController.ObserveZone(_, onZoneChanged)
	task.spawn(onZoneChanged, ZoneController.CurrentZoneName, ZoneController.CurrentZone)
	return ZoneController.ZoneChanged:Connect(onZoneChanged)
end

function ZoneController.Start(_)
	localPlayer.CharacterAdded:Connect(setupCharacter)

	if localPlayer.Character then
		setupCharacter(localPlayer.Character) -- equivalent call inferred; original call site unknown
	end
end

return ZoneController