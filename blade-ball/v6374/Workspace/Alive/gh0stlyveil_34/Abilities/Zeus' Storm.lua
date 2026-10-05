local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
character:WaitForChild("Humanoid")
game:GetService("Debris")
local SettingsController = require(ReplicatedStorage3:WaitForChild("Controllers"):WaitForChild("SettingsController"))
require(ReplicatedStorage.Shared.GetAbilityCooldownMultiplier)
local Utils = require(ReplicatedStorage.Common.Utils)
require(ReplicatedStorage.Shared.AbilityUtils)
local Abilities = require(ReplicatedStorage.Shared.Abilities)
local packages = ReplicatedStorage.Packages
local Net = require(packages.Net)
local name = script.Name
local flag = false
local remoteFunction = Net:RemoteFunction("NewAbilities/ActivePrimarySlot")
local vector = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
local module = require(game.ReplicatedStorage.Shared.Abilities[name])
vector.Image = module and module.iconId or ""

local function ability()
	if flag or (localPlayer.Character.Parent ~= workspace.Alive or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false) then
		return
	end

	flag = true
	local _ = localPlayer.Upgrades[name].Value
	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, name)
	cooldownThread = task.delay(abilityCooldown, function()
		flag = false
		cooldownThread = nil
	end)
	ReplicatedStorage3.Remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
	remoteFunction:InvokeServer(name)
	task.wait(0.4)
end

UserInputService.InputBegan:Connect(function(input, _)
	if SettingsController:UseBind(input, "Ability") then
		ability()
	end
end)
ReplicatedStorage3.Remotes.AbilityButtonPress.Event:Connect(function()
	ability()
end)
ReplicatedStorage3.Remotes.EndCD.OnClientEvent:Connect(function()
	flag = false

	if cooldownThread then
		Utils.Thread.SafeCancel(cooldownThread)
		cooldownThread = nil
	end
end)