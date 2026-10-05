local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
character:WaitForChild("Humanoid")
game:GetService("Debris")
local _ = game.Workspace.CurrentCamera.FieldOfView
local SettingsController = require(ReplicatedStorage3:WaitForChild("Controllers"):WaitForChild("SettingsController"))
local Utils = require(ReplicatedStorage.Common.Utils)
local Abilities = require(ReplicatedStorage.Shared.Abilities)
local flag = false
local thread = nil
local mouseButton2 = Enum.UserInputType.MouseButton2
local vector = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
local module = require(game.ReplicatedStorage.Shared.Abilities[script.Name])
vector.Image = module and module.iconId or ""

local function ability()
	if localPlayer.Character.Parent ~= workspace.Alive or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false or flag or localPlayer.PlayerGui.Hotbar.Ability.UIGradient.Offset.Y < 0.5 then
		return
	end

	local formatted = `WaypointFor_{localPlayer.Name}`

	if localPlayer.Character.PrimaryPart:FindFirstChild("FREEZER") then
		ReplicatedStorage3.Misc.error:Play()
		return
	end

	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, script.Name)
	local child = workspace.Runtime:FindFirstChild(formatted)
	print(child)

	if child then
		if child:GetAttribute("Destroyed") then
			return
		end

		local formatted2 = `WaypointFor_{localPlayer.Name}`
		workspace.Runtime:FindFirstChild(formatted2)
		ReplicatedStorage3.Remotes.WaypointCombust:FireServer()
		flag = true
		ReplicatedStorage3.Remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
		thread = task.delay(abilityCooldown, function()
			flag = false
			thread = nil
		end)
	else
		ReplicatedStorage3.Remotes.PlrWaypointed:FireServer()
		flag = true
		local v = 0.1
		ReplicatedStorage3.Remotes.VisualBindableCD:Fire(false, true, v)
		thread = task.delay(v, function()
			flag = false
			thread = nil
		end)
	end
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