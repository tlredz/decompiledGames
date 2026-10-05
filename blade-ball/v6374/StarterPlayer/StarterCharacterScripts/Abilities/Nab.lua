local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
game:GetService("Debris")
require(ReplicatedStorage.Packages.Net)
local Replion = require(ReplicatedStorage.Packages.Replion)
require(ReplicatedStorage.ServerInfo)
local Nab = require(ReplicatedStorage.Shared.Abilities.Nab)
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local playerGui = localPlayer:WaitForChild("PlayerGui")
local ability = playerGui:WaitForChild("Hotbar"):WaitForChild("Ability")
local flag = false
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

local function update()
	local nabCharge = character:GetAttribute("NabCharge") or 0
	local v = workspace.ShowdownActive.Value and 0 or nabCharge

	if v < Nab.abilityData.minCharge or workspace.ShowdownActive.Value then
		if not flag then
			flag = true
			ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, 0, true)
		end
	elseif flag then
		flag = false
		ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, 1, true)
	end

	local counts = playerGui:WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("ready"):WaitForChild("counts")

	if counts then
		counts.Text = tostring(v)
	end
end

task.spawn(update)
workspace.ShowdownActive:GetPropertyChangedSignal("Value"):Connect(update)
character:GetAttributeChangedSignal("NabCharge"):Connect(update)