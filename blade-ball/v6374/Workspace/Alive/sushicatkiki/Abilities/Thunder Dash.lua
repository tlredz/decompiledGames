local createVector = vector.create
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
local thread = nil
local mouseButton2 = Enum.UserInputType.MouseButton2
local vector2 = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
local module = require(game.ReplicatedStorage.Shared.Abilities[script.Name])
vector2.Image = module and module.iconId or ""

local function ability()
	if flag or (localPlayer.Character.Parent ~= workspace.Alive or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false) then
		return
	end

	if humanoid.MoveDirection == createVector(0, 0, 0) then
		ReplicatedStorage3.Misc.error:Play()
		return
	end

	if localPlayer.Character.PrimaryPart:FindFirstChild("FREEZER") then
		ReplicatedStorage3.Misc.error:Play()
		return
	end

	flag = true
	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, script.Name)
	local v = 22 + 10 * localPlayer.Upgrades[script.Name].Value
	local position = character.HumanoidRootPart.Position
	local v2 = {
		character.Head.CFrame,
		character["Left Arm"].CFrame,
		character["Right Arm"].CFrame,
		character["Right Leg"].CFrame,
		character["Left Leg"].CFrame,
		character.Torso.CFrame
	}
	ReplicatedStorage3.Remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
	ReplicatedStorage3.Remotes.ThunderDash:FireServer(position, v2)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {
		workspace.Runtime,
		workspace.Alive,
		workspace.Dead,
		workspace.Balls,
		workspace.TrainingBalls
	}
	local raycastResult = workspace:Raycast(position, humanoid.MoveDirection.Unit * v, raycastParams)

	if raycastResult then
		if raycastResult.Instance then
			character.HumanoidRootPart.CFrame = CFrame.new(raycastResult.Position)
		else
			character.HumanoidRootPart.CFrame += humanoid.MoveDirection.Unit * v
		end
	else
		character.HumanoidRootPart.CFrame += humanoid.MoveDirection.Unit * v
	end

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