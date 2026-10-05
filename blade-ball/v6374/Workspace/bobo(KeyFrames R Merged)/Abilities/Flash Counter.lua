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
local SpeedModifiers = require(ReplicatedStorage3.Shared.SpeedModifiers)
local attempt = script:WaitForChild("attempt")
local track = humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(attempt)
local success = script:WaitForChild("success")
humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(success)
local flag = false
local thread = nil
local _ = workspace.CurrentCamera
game.Players.LocalPlayer:GetMouse()
local mouseButton2 = Enum.UserInputType.MouseButton2
local vector = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
local module = require(game.ReplicatedStorage.Shared.Abilities[script.Name])
vector.Image = module and module.iconId or ""

local function ability()
	if flag or (localPlayer.Character.Parent ~= workspace.Alive or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false) then
		return
	end

	local children = workspace.Balls:GetChildren()

	if #children <= 0 then
		ReplicatedStorage3.Misc.error:Play()
		return
	end

	local v = false

	for _, v3 in next, children, nil do
		if not (v3:GetAttribute("realBall") and v3:GetAttribute("from")) then
			continue
		end

		v = true
		break
	end

	if not v then
		ReplicatedStorage3.Misc.error:Play()
		return
	end

	flag = true
	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, script.Name)
	thread = task.delay(abilityCooldown, function()
		flag = false
		thread = nil
	end)
	ReplicatedStorage3.Remotes.PlrFlashCountered:FireServer()
	ReplicatedStorage3.Remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
	local v3 = SpeedModifiers:SetModifierFor(
		character,
		"Initial Flash Counter Debuff",
		SpeedModifiers.Utils.MinDebuff(character, 0),
		SpeedModifiers.Priority.DEBUFF
	)
	AbilityUtils.playAnimationTrack(track, script.Name, 1)
	task.wait(1)
	track:Stop(0.2)
	v3()
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