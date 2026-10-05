local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local humanoid = character:WaitForChild("Humanoid")
game:GetService("Debris")
local SettingsController = require(ReplicatedStorage3:WaitForChild("Controllers"):WaitForChild("SettingsController"))
local Utils = require(ReplicatedStorage.Common.Utils)
local AbilityUtils = require(ReplicatedStorage.Shared.AbilityUtils)
local Abilities = require(ReplicatedStorage.Shared.Abilities)
local pull = script:WaitForChild("Pull")
local track = humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(pull)
local flag = false
local thread = nil
local currentCamera = workspace.CurrentCamera
local mouse = game.Players.LocalPlayer:GetMouse()
local mouseButton2 = Enum.UserInputType.MouseButton2
local vector = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
local module = require(game.ReplicatedStorage.Shared.Abilities[script.Name])
vector.Image = module and module.iconId or ""

local function ability()
	if flag or #workspace.Balls:GetChildren() == 0 or (localPlayer.Character.Parent ~= workspace.Alive or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false) then
		return
	end

	local v = {
		FieldOfView = game.Workspace.CurrentCamera.FieldOfView * 1.15
	}
	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In, 0, true, 0)
	local TweenService = game:GetService("TweenService")
	TweenService:Create(game.Workspace.CurrentCamera, tweenInfo, v):Play()
	local v2 = 1e999
	local v3 = nil

	for _, child in workspace.Balls:GetChildren() do
		if child:GetAttribute("realBall") then
			continue
		end

		local worldToScreenPoint = currentCamera:WorldToScreenPoint(child.Position)
		local magnitude = Vector2.new(worldToScreenPoint.X - mouse.X, worldToScreenPoint.Y - mouse.Y).Magnitude

		if not (magnitude < v2) then
			continue
		end

		v3 = character
		v2 = magnitude
	end

	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, script.Name)
	flag = true
	local plrPulled = ReplicatedStorage3.Remotes.PlrPulled
	local v4

	if v3 then
		v4 = v3.Name
	end

	plrPulled:FireServer(v4)
	ReplicatedStorage3.Remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
	AbilityUtils.playAnimationTrack(track, script.Name, 0.7)
	thread = task.delay(abilityCooldown, function()
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