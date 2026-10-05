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
local Utils = require(ReplicatedStorage2.Common.Utils)
local Abilities = require(ReplicatedStorage2.Shared.Abilities)
local flag = false
local thread = nil
local vector = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
local name = script.Name
local module = require((ReplicatedStorage2.Shared.Abilities:WaitForChild(name)))
vector.Image = module and module.iconId or ""

local function ability(p)
	if flag or (localPlayer.Character.Parent ~= workspace.Alive or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false) then
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
	local v

	if p and (p == Enum.UserInputType.MouseButton1 or p == Enum.UserInputType.Keyboard or p == Enum.UserInputType.MouseButton2) then
		local mouseLocation = UserInputService:GetMouseLocation()
		v = { mouseLocation.X, mouseLocation.Y }
	else
		v = { currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y / 2 }
	end

	local v2 = {}

	for _, child in ipairs(workspace.Alive:GetChildren()) do
		if child:GetAttribute("Dead") or child:GetAttribute("Invisible") or child:GetAttribute("DoNotTarget") or child:GetAttribute("IsEncryptedClone") or child:GetAttribute("IsBoss") then
			continue
		end

		if child == localPlayer.Character then
			continue
		end

		local humanoidRootPart = child:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			v2[{
				Character = child
			}] = currentCamera:WorldToScreenPoint(humanoidRootPart.Position)
		end
	end

	local vector2 = Vector2.new(v[1], v[2])
	local v3 = {
		Distance = nil,
		Player = nil
	}

	for k, v4 in v2 do
		local character = k.Character

		if not (character and character:FindFirstChild("HumanoidRootPart")) then
			continue
		end

		local magnitude = (vector2 - Vector2.new(v4.X, v4.Y)).Magnitude

		if not (v3.Player == nil or v3.Distance and magnitude < v3.Distance) then
			continue
		end

		v3.Distance = magnitude
		v3.Player = k
	end

	if not v3.Player then
		thread = task.delay(1, function()
			flag = false
			thread = nil
		end)
		return
	end

	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, script.Name)
	ReplicatedStorage2.Remotes.Swapped:FireServer(v3.Player.Character.Name)
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