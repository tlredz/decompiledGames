local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
character:WaitForChild("Humanoid")
game:GetService("Debris")
local fieldOfView = game.Workspace.CurrentCamera.FieldOfView
local SettingsController = require(ReplicatedStorage3:WaitForChild("Controllers"):WaitForChild("SettingsController"))
local Utils = require(ReplicatedStorage.Common.Utils)
local Abilities = require(ReplicatedStorage.Shared.Abilities)
local FastUtils = require(ReplicatedStorage.Shared.FastUtils)
local flag = false
local thread = nil
local mouseButton2 = Enum.UserInputType.MouseButton2
local vector = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
local module = require(game.ReplicatedStorage.Shared.Abilities[script.Name])
vector.Image = module and module.iconId or ""

local function ability()
	if flag or (localPlayer.Character.Parent ~= workspace.Alive or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false) then
		return
	end

	flag = true
	FastUtils.fastTween(
		workspace.CurrentCamera,
		TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
		{
			FieldOfView = fieldOfView * 1.5
		}
	)
	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, script.Name)
	local v = 1.7 + 0.24285714285714285 * localPlayer.Upgrades[script.Name].Value
	ReplicatedStorage3.Remotes.ShadowFollow:FireServer()
	thread = task.delay(abilityCooldown, function()
		flag = false
		thread = nil
	end)
	ReplicatedStorage3.Remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
	task.wait(v)
	FastUtils.fastTween(
		workspace.CurrentCamera,
		TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0),
		{
			FieldOfView = fieldOfView
		}
	)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") then
		ability()
	end
end)
ReplicatedStorage3.Remotes.AbilityButtonPress.Event:Connect(function()
	ability()
end)
ReplicatedStorage3.Remotes.EndCD.OnClientEvent:Connect(function()
	flag = false

	if thread then
		Utils.Thread.SafeCancel(thread)
		thread = nil
	end
end)
ReplicatedStorage3.Remotes.KeybindM2.OnClientEvent:Connect(function(p)
	if p then
		mouseButton2 = nil
	else
		mouseButton2 = Enum.UserInputType.MouseButton2
	end
end)