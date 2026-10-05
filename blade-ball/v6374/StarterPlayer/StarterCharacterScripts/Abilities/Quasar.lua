local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local humanoid = character:WaitForChild("Humanoid")
game:GetService("Debris")
local SettingsController = require(ReplicatedStorage3:WaitForChild("Controllers"):WaitForChild("SettingsController"))
local ThreadSafeTargetingHelper = require(ReplicatedStorage3.Shared.ThreadSafeTargetingHelper)
local Utils = require(ReplicatedStorage.Common.Utils)
local AbilityUtils = require(ReplicatedStorage.Shared.AbilityUtils)
local Abilities = require(ReplicatedStorage.Shared.Abilities)
local flag = false
local thread = nil
local currentCamera = workspace.CurrentCamera
local mouse = game.Players.LocalPlayer:GetMouse()
local mouseButton2 = Enum.UserInputType.MouseButton2
local vector = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
local module = require(game.ReplicatedStorage.Shared.Abilities[script.Name])
vector.Image = module and module.iconId or ""
local track = humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(script:WaitForChild("Grab"))

local function ability()
	if flag or not workspace:GetAttribute("GameActive") or (localPlayer.Character.Parent ~= workspace.Alive or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false) then
		return
	end

	if localPlayer.Character:GetAttribute("Dead") then
		return
	end

	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, script.Name)
	local v = 1e999
	local v2 = nil

	for _, child in workspace.Alive:GetChildren() do
		if not (child ~= localPlayer.Character and ThreadSafeTargetingHelper.AreCharactersEnemies(
			child,
			localPlayer.Character
		)) then
			continue
		end

		if child:GetAttribute("IsEncryptedClone") or child:GetAttribute("IsDoppelganger") or child:GetAttribute("Invisible") then
			continue
		end

		local worldToScreenPoint = currentCamera:WorldToScreenPoint(child.HumanoidRootPart.Position)
		local magnitude = Vector2.new(worldToScreenPoint.X - mouse.X, worldToScreenPoint.Y - mouse.Y).Magnitude

		if not (magnitude < v) then
			continue
		end

		v2 = child
		v = magnitude
	end

	if not v2 then
		return
	end

	flag = true
	ReplicatedStorage3.Remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
	AbilityUtils.playAnimationTrack(track, script.Name, 0.867)
	ReplicatedStorage3.Remotes.PlrQuasared:FireServer(v2)
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