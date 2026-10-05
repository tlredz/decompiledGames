game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local common = ReplicatedStorage.Common
local controllers = ReplicatedStorage.Controllers
local _ = ReplicatedStorage.Packages
local remotes = ReplicatedStorage.Remotes
local shared = ReplicatedStorage.Shared
local name = script.Name
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local v = 8
local track = character:WaitForChild("Humanoid"):WaitForChild("Animator"):LoadAnimation(script.Pose)
local flag = false
local thread = nil
local Abilities = require(shared.Abilities)
local AbilityUtils = require(shared.AbilityUtils)
local SettingsController = require(controllers.SettingsController)
local Utils = require(common.Utils)
local module = require(shared.Abilities[name])
local hotbar = localPlayer.PlayerGui.Hotbar
hotbar.Ability.Vector.Image = module and module.iconId or ""

local function ability()
	if flag or (character.Parent ~= workspace.Alive or hotbar.Ability.Red.Visible ~= false) then
		return
	end

	flag = true
	v = Abilities.getAbilityCooldown(localPlayer, script.Name)
	AbilityUtils.playAnimationTrack(track, script.Name, 0.75)
	remotes.PlrConfidenceTaunted:FireServer()
	remotes.VisualBindableCD:Fire(false, true, v)
	thread = task.delay(v, function()
		flag = false
		thread = nil
	end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") then
		ability()
	end
end)
remotes.AbilityButtonPress.Event:Connect(function()
	ability()
end)
remotes.EndCD.OnClientEvent:Connect(function()
	flag = false

	if thread then
		Utils.Thread.SafeCancel(thread)
		thread = nil
	end
end)