local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local Players = game:GetService("Players")
game:GetService("Debris")
local Net = require(ReplicatedStorage.Packages.Net)
local Utils = require(ReplicatedStorage.Common.Utils)
local SettingsController = require(ReplicatedStorage.Controllers.SettingsController)
local Abilities = require(ReplicatedStorage.Shared.Abilities)
local localPlayer = Players.LocalPlayer;
(localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
local v = false
local thread = nil
local remoteEvent = Net:RemoteEvent("ChieftainsTotemActivate")
local ability = localPlayer.PlayerGui:WaitForChild("Hotbar"):WaitForChild("Ability")
local module = require(ReplicatedStorage.Shared.Abilities[script.Name])
local vector = ability:WaitForChild("Vector")
vector.Image = not module and "" or module.iconId
local cooldown = module.cooldown

local function ability2()
	if v or localPlayer.Character.Parent ~= workspace.Alive or ability.Red.Visible ~= false then
		return
	end

	v = true
	cooldown = Abilities.getAbilityCooldown(nil, script.Name)
	remoteEvent:FireServer()
	ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, cooldown)
	thread = task.delay(cooldown, function()
		v = false
		thread = nil
	end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") then
		ability2()
	end
end)
ReplicatedStorage.Remotes.AbilityButtonPress.Event:Connect(ability2)
ReplicatedStorage.Remotes.EndCD.OnClientEvent:Connect(function()
	v = false

	if thread then
		Utils.Thread.SafeCancel(thread)
		thread = nil
	end
end)