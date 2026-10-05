local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local humanoid = character:WaitForChild("Humanoid")
game:GetService("Debris")
local _ = game.Workspace.CurrentCamera.FieldOfView
local SettingsController = require(ReplicatedStorage3:WaitForChild("Controllers"):WaitForChild("SettingsController"))
local Utils = require(ReplicatedStorage.Common.Utils)
local Abilities = require(ReplicatedStorage.Shared.Abilities)
local flag = false
local v = false
local thread = nil
local mouseButton2 = Enum.UserInputType.MouseButton2
local v2 = nil
local vector = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
local module = require(game.ReplicatedStorage.Shared.Abilities[script.Name])
vector.Image = module and module.iconId or ""

local function ability()
	if flag or (localPlayer.Character.Parent ~= workspace.Alive or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false) then
		return
	end

	flag = true
	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, script.Name)
	local total = 10
	local value = localPlayer.Upgrades[script.Name].Value
	total += total / 5 * value
	ReplicatedStorage3.Remotes.WindCloak:FireServer()
	ReplicatedStorage3.Remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
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
UserInputService.JumpRequest:Connect(function()
	if localPlayer.Character.Torso:FindFirstChild("Whirlwinds") or localPlayer.Character.Torso:FindFirstChild("MaxWhirlwinds") then
		local now = os.clock()
		local v3 = v2 and now - v2 < 0.1 and true or false
		v2 = now

		if v3 then
			return
		end

		if humanoid.FloorMaterial ~= Enum.Material.Air and not v then
			ReplicatedStorage3.Remotes.CloakJump:FireServer()
			v = true
			task.wait(0.33)
			v = false
		end
	end
end)