local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Packages.Net)
local Replion = require(ReplicatedStorage.Packages.Replion)
require(ReplicatedStorage.ServerInfo)
require(ReplicatedStorage.Shared.Abilities.Nab)
local localPlayer = Players.LocalPlayer

if not localPlayer.Character then
	localPlayer.CharacterAdded:Wait()
end

local ability = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability")
Replion.Client:AwaitReplion("Data", function(object)
	local function updateIcon()
		local child = ReplicatedStorage.Misc.DataAbilities:FindFirstChild(script.Name)

		if not child then
			return
		end

		local attributes = child:GetAttributes()
		local v = object:Get({ "AbilityUpgrades", script.Name })
		local icon = attributes.Icon

		for i = 1, v or 0 do
			icon = attributes[`Icon{i}`] or attributes.Icon
		end

		local vector = ability:WaitForChild("Vector")
		vector.Image = icon or ""
	end

	updateIcon()
	object:OnChange({ "AbilityUpgrades", script.Name }, updateIcon)
end)