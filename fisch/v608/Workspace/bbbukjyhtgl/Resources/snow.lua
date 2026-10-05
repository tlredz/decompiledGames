local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v = {
	["Boreal Pines"] = true
}

local function updateSnow(instance)
	local zone = instance:FindFirstChild("zone")

	if not (zone and zone:IsA("ObjectValue")) then
		return
	end

	if zone.Value and v[zone.Value.Name] == true then
		instance:SetAttribute("SnowSlow", -3)
	else
		instance:SetAttribute("SnowSlow", nil)
	end
end

local function onCharacterAdded(character)
	local zone = character:WaitForChild("zone", 10)

	if not zone then
		return
	end

	updateSnow(character)
	zone:GetPropertyChangedSignal("Value"):Connect(function()
		if character.Parent then
			updateSnow(character)
		end
	end)
end

localPlayer.CharacterAdded:Connect(onCharacterAdded)

if localPlayer.Character then
	onCharacterAdded(localPlayer.Character)
end