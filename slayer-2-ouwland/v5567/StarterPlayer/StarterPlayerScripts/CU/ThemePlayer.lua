if ({
	[17047024836] = true
})[game.PlaceId] then
	return
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ThemePlaylist = require(ReplicatedStorage.CAM.Client.Controllers.ThemePlaylist)
local areaLocator = game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Subsets"):WaitForChild("Areas"):WaitForChild("AreaLocator")
local module = require(areaLocator)
local InCombat = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.InCombat)
local v = false
local v2 = nil

local function Tracks(defaultCombatThemes)
	local sounds = {}

	if defaultCombatThemes == nil then
		return sounds
	end

	for _, sound in ipairs(defaultCombatThemes:GetChildren()) do
		if sound:IsA("Sound") then
			table.insert(sounds, sound)
		end
	end

	return sounds
end

function update(childName: string, childName2: string)
	local defaultCombatThemes = nil
	local v3 = nil

	if v then
		defaultCombatThemes = areaLocator.SoundTracks.DefaultCombatThemes
		v3 = Tracks(defaultCombatThemes)
	else
		local child = areaLocator.SoundTracks:FindFirstChild(childName)

		if child then
			if childName2 ~= childName then
				defaultCombatThemes = child:FindFirstChild(childName2)

				if defaultCombatThemes ~= nil and defaultCombatThemes:IsA("Sound") then
					defaultCombatThemes = nil
				end

				v3 = Tracks(defaultCombatThemes)
			end

			if defaultCombatThemes == nil or #v3 == 0 then
				defaultCombatThemes = child:FindFirstChild(childName)

				if defaultCombatThemes == nil or defaultCombatThemes:IsA("Sound") then
					defaultCombatThemes = child
				end

				v3 = Tracks(defaultCombatThemes)
			end
		end

		if defaultCombatThemes == nil or #v3 == 0 then
			defaultCombatThemes = areaLocator.SoundTracks.DefaultTracks
			v3 = Tracks(defaultCombatThemes)
		end
	end

	if v2 ~= defaultCombatThemes then
		ThemePlaylist.SetPlaylist(v3)
		v2 = defaultCombatThemes
	end
end

update(module.AreaEquipped.Parent, module.AreaEquipped.Sub)
module.AreaEquipped.Update:Connect(update)
local localPlayer = game.Players.LocalPlayer

while true do
	if localPlayer.Character == nil then
		task.wait(2)
	else
		local regularIncludeAI = InCombat.RegularIncludeAI(localPlayer.Character)

		if regularIncludeAI ~= v then
			v = regularIncludeAI
			update(module.AreaEquipped.Parent, module.AreaEquipped.Sub)
		end

		task.wait(0.5)
	end
end