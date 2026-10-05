local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage:WaitForChild("UserInputService"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
game:GetService("Debris")
local currentCamera = workspace.CurrentCamera
local fieldOfView = currentCamera.FieldOfView
local localPlayer = Players.LocalPlayer;
(localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("Humanoid")
local SettingsController = require(ReplicatedStorage2:WaitForChild("Controllers"):WaitForChild("SettingsController"))
local Net = require(ReplicatedStorage2.Packages.Net)
local Utils = require(ReplicatedStorage2.Common.Utils)
local Abilities = require(ReplicatedStorage2.Shared.Abilities)
local remoteEvent = Net:RemoteEvent("Displace")
local flag = false
local thread = nil
local vector = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
local name = script.Name
local module = require((ReplicatedStorage2.Shared.Abilities:WaitForChild(name)))
vector.Image = module and module.iconId or ""

local function ability(_)
	if flag or (localPlayer.Character.Parent ~= workspace.Alive or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false) or #workspace.Balls:GetChildren() == 0 then
		return
	end

	flag = true
	TweenService:Create(
		currentCamera,
		TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0),
		{
			FieldOfView = fieldOfView * 1.08
		}
	):Play()
	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, script.Name)
	remoteEvent:FireServer()
	ReplicatedStorage2.Remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
	thread = task.delay(abilityCooldown, function()
		flag = false
		thread = nil
	end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
	if gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") then
		ability(input.UserInputType)
	end
end)
ReplicatedStorage2.Remotes.AbilityButtonPress.Event:Connect(function()
	ability()
end)
ReplicatedStorage2.Remotes.EndCD.OnClientEvent:Connect(function()
	flag = false

	if thread then
		Utils.Thread.SafeCancel(thread)
		thread = nil
	end
end)