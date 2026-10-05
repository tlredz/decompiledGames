local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
localPlayer:WaitForChild("Upgrades")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local humanoid = character:WaitForChild("Humanoid")
local SettingsController = require(ReplicatedStorage:WaitForChild("Controllers"):WaitForChild("SettingsController"))
require(ReplicatedStorage.Shared.ThreadSafeTargetingHelper)
local charge = script:WaitForChild("charge")
local track = humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(charge)
local charge_hold = script:WaitForChild("charge_hold")
humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(charge_hold)
local swinga = script:WaitForChild("swinga")
local track2 = humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(swinga)
local Replion = require(ReplicatedStorage.Packages.Replion)
local AbilityUtils = require(ReplicatedStorage.Shared.AbilityUtils)
local Abilities = require(ReplicatedStorage.Shared.Abilities)
require(ReplicatedStorage.Shared.SpeedModifiers)
require(ReplicatedStorage.Shared.JumpModifiers)
local Utils = require(ReplicatedStorage.Common.Utils)
local flag = false
local thread = nil
local _ = workspace.CurrentCamera
game.Players.LocalPlayer:GetMouse()
local vector = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
require(game.ReplicatedStorage.Shared.Abilities[script.Name])
local v = Replion.Client:WaitReplion("Data")

local function updateIcon()
	local child = ReplicatedStorage.Misc.DataAbilities:FindFirstChild(script.Name)

	if not child then
		return
	end

	local attributes = child:GetAttributes()
	local v2 = v:Get({ "AbilityUpgrades", script.Name })
	local icon = attributes.Icon

	for i = 1, v2 or 0 do
		icon = attributes["Icon" .. i] or attributes.Icon
	end

	vector.Image = icon or ""
end

updateIcon()
v:OnChange({ "AbilityUpgrades", script.Name }, function()
	updateIcon()
end)
local DualityChoice = require(script.DualityChoice)
DualityChoice.toggleOff()
ReplicatedStorage.Remotes.M1Stop:Fire(false)

local function ability()
	if flag then
		return
	end

	if localPlayer.Character.Parent ~= workspace.Alive or localPlayer.Character:GetAttribute("DualityDualEnd") or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false or DualityChoice.opened or not DualityChoice.getAvailable() then
		return
	end

	local _ = character.Humanoid
	local targetByCamera = DualityChoice.getTargetByCamera()

	if not targetByCamera then
		return
	end

	DualityChoice.toggleOn()
	AbilityUtils.playAnimationTrack(track, script.Name, 0.64)
	ReplicatedStorage.Remotes.DualityInitialActivation:FireServer(targetByCamera)
	local ancestryChangedConnection = targetByCamera.AncestryChanged:Connect(function()
		if targetByCamera.Parent == workspace.Alive then
			return
		end

		DualityChoice.toggleOff(true)
	end)
	local v2, v3 = DualityChoice.select(2.5, 1, function(_)
		AbilityUtils.playAnimationTrack(track2, script.Name, 0.533)
	end)
	ancestryChangedConnection:Disconnect()

	if not v2 then
		return
	end

	if v3 == targetByCamera then
		v3 = DualityChoice.getTargetByCamera(targetByCamera)
	end

	ReplicatedStorage.Remotes.DualityShootActivation:FireServer(v2, targetByCamera, v3)
	DualityChoice.toggleOff()
	AbilityUtils.playAnimationTrack(track2, script.Name, 0.533)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	if SettingsController:UseBind(input, "Ability") and not SettingsController:UseBind(input, "Block") then
		ability()
	end
end)
ReplicatedStorage.Remotes.AbilityButtonPress.Event:Connect(function()
	ability()
end)
ReplicatedStorage.Remotes.EndCD.OnClientEvent:Connect(function()
	task.spawn(function()
		flag = false

		if thread then
			Utils.Thread.SafeCancel(thread)
			thread = nil
		end
	end)
end)
DualityChoice.onChoiceChange:Connect(function(_, p)
	if not p then
		return
	end

	flag = true

	if DualityChoice.opened then
		DualityChoice.toggleOff()
	end

	local v2 = 2

	if localPlayer.Upgrades["Slash of Duality"].Value < 1 then
		v2 = Abilities.getAbilityCooldown(localPlayer, "Slash of Duality")
	elseif DualityChoice.isBothInCooldow() then
		local lowestCooldown = DualityChoice.getLowestCooldown()

		if lowestCooldown and v2 < lowestCooldown then
			v2 = lowestCooldown
		end
	end

	ReplicatedStorage.Remotes.VisualBindableCD:Fire(false, true, v2)

	if thread then
		Utils.Thread.SafeCancel(thread)
		thread = nil
	end

	thread = task.delay(v2, function()
		flag = nil
		thread = nil
	end)
end)
script.Parent.AncestryChanged:Connect(function()
	DualityChoice.toggleOff(true)
end)
task.spawn(function()
	script:GetPropertyChangedSignal("Enabled"):Connect(function()
		if not script.Enabled then
			DualityChoice.toggleOff(true)
		end
	end)
end)
localPlayer:GetAttributeChangedSignal("CurrentlyEquippedAbility"):Connect(function()
	if localPlayer:GetAttribute("CurrentlyEquippedAbility") ~= "Slash of Duality" then
		DualityChoice.toggleOff(true)
	end
end)