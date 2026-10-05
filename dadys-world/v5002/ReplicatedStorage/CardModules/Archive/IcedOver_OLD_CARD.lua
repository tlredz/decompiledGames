local IcedOverOLDCARD = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local cardModifiers = workspace.Info.CardModifiers
local IceSkatingConfig = require(ReplicatedStorage.Modules.Zones.IceSkatingConfig)
IcedOverOLDCARD.Name = "Iced Over"
IcedOverOLDCARD.Icon = "rbxassetid://98655003103626"
IcedOverOLDCARD.Description = "The next floor freezes over! Guaranteed Holiday Twisted spawn with ice skating and winter atmosphere."
IcedOverOLDCARD.SingleUse = true
IcedOverOLDCARD.MinimumFloor = 5

function IcedOverOLDCARD.ApplyCardEffects()
	if cardModifiers:FindFirstChild("IcedOver") then
		return
	end

	local boolValue = Instance.new("BoolValue")
	boolValue.Name = "IcedOver"
	boolValue.Value = true
	boolValue.Parent = cardModifiers
	local boolValue2 = Instance.new("BoolValue")
	boolValue2.Name = "IcedOverUsed"
	boolValue2.Value = true
	boolValue2.Parent = cardModifiers
	local boolValue3 = Instance.new("BoolValue")
	boolValue3.Name = "ForceHolidayTwisted"
	boolValue3.Value = true
	boolValue3.Parent = cardModifiers
	local boolValue4 = Instance.new("BoolValue")
	boolValue4.Name = "BlockIchorLeaks"
	boolValue4.Value = true
	boolValue4.Parent = cardModifiers

	if not cardModifiers:FindFirstChild("IceSkatingEnabled") then
		local boolValue5 = Instance.new("BoolValue")
		boolValue5.Name = "IceSkatingEnabled"
		boolValue5.Value = true
		boolValue5.Parent = cardModifiers
	end

	local iceSkatingPreset = cardModifiers:FindFirstChild("IceSkatingPreset")

	if iceSkatingPreset then
		iceSkatingPreset.Value = "CharlieBrown"
	else
		local stringValue = Instance.new("StringValue")
		stringValue.Name = "IceSkatingPreset"
		stringValue.Value = "CharlieBrown"
		stringValue.Parent = cardModifiers
	end

	if not cardModifiers:FindFirstChild("IceSkatingUseSounds") then
		local boolValue5 = Instance.new("BoolValue")
		boolValue5.Name = "IceSkatingUseSounds"
		boolValue5.Value = true
		boolValue5.Parent = cardModifiers
	end

	if not cardModifiers:FindFirstChild("IceSkatingFreezeFloors") then
		local boolValue5 = Instance.new("BoolValue")
		boolValue5.Name = "IceSkatingFreezeFloors"
		boolValue5.Value = true
		boolValue5.Parent = cardModifiers
	end

	local v = ReplicatedStorage:FindFirstChild("IceSkatingToggle")

	if not v then
		v = Instance.new("RemoteEvent")
		v.Name = "IceSkatingToggle"
		v.Parent = ReplicatedStorage
	end

	for _, v2 in pairs(Players:GetPlayers()) do
		if v2.Character then
			v2.Character:SetAttribute("IceSkatingMode", true)
		end

		IceSkatingConfig.ApplyAntiCheatExceptions(v2, "CharlieBrown")
	end

	task.wait(0.1)
	v:FireAllClients("Activate", "CharlieBrown")
	v:FireAllClients("FreezeLevel")
	print("[IcedOver] Card activated - CharlieBrown preset with Holiday Twisted spawn on next floor!")
end

function IcedOverOLDCARD.Cleanup()
	for _, v in pairs(Players:GetPlayers()) do
		IceSkatingConfig.ClearAntiCheatExceptions(v)
	end
end

function IcedOverOLDCARD.CanAppearInVote(p)
	if cardModifiers:FindFirstChild("IcedOverUsed") or p < IcedOverOLDCARD.MinimumFloor then
		return false
	end

	local v = p + 1
	local v2 = nil

	if not (pcall(function()
		local HolidayEventConfig = require(ReplicatedStorage.SharedData.HolidayEventConfig)
		v2 = HolidayEventConfig
	end) and v2 and v2.ENABLED) or v % (v2.EventFloorInterval or 5) ~= 0 then
		return true
	end

	local MAP_NAMES_LIST = v2.MAP_NAMES_LIST or v2.HolidayMaps or {}

	for _, v3 in ipairs(MAP_NAMES_LIST) do
		if v3 == "ChristmasMap2" or v3 == "SkateMap" then
			return false
		end
	end

	return true
end

return IcedOverOLDCARD