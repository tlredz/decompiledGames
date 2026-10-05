local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
character:WaitForChild("Humanoid")
local Debris = game:GetService("Debris")
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

local function shockwave(humanoidRootPart, p, value, color, p2, p3, p4)
	local clone = ReplicatedStorage3.Misc.Wave:Clone()
	clone.Parent = workspace.Runtime

	if p3 then
		clone.Transparency = 1
		clone.Size = Vector3.new(p, 0.25, p)
	else
		clone.Size = createVector(0.01, 0.5, 0.01)
	end

	if p2 then
		clone.CFrame = humanoidRootPart.CFrame
	else
		clone.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.51, 0, 0)
	end

	if p4 then
		clone.CFrame *= CFrame.new(0, -2.5, 0)
	end

	if color then
		clone.Color = color
	end

	local vector3 = Vector3.new(p, 0.5, p)
	local v = value or 0.3
	local v2 = game.TweenService:Create(
		clone,
		TweenInfo.new(v, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = p3 and createVector(0.01, 0.25, 0.01) or vector3
		}
	)
	local v3 = game.TweenService:Create(
		clone,
		TweenInfo.new(v / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
		{
			Transparency = 1
		}
	)

	if p3 then
		game.TweenService:Create(
			clone,
			TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0),
			{
				Transparency = 0
			}
		):Play()
	end

	v2:Play()
	Debris:AddItem(clone, v)
	task.spawn(function()
		task.wait(v / 2)
		v3:Play()
	end)
end

local function ability()
	if flag or (localPlayer.Character.Parent ~= workspace.Alive or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false) then
		return
	end

	flag = true
	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, script.Name)
	local value = localPlayer.Upgrades[script.Name].Value
	local _ = 22 + 10 * value
	thread = task.delay(abilityCooldown, function()
		flag = false
		thread = nil
	end)
	ReplicatedStorage3.Remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
	ReplicatedStorage3.Remotes.ForceAbilityActivate:FireServer()

	local function USEFORCE(p)
		local humanoidRootPart = character.HumanoidRootPart
		local clone

		if value == 0 then
			clone = ReplicatedStorage3.Misc.forcePart:Clone()
			shockwave(humanoidRootPart, 80, 0.4, Color3.new(0, 0.45098, 1), true)
		elseif value == 1 then
			clone = ReplicatedStorage3.Misc.forcePart2:Clone()
			shockwave(humanoidRootPart, 90, 0.4, Color3.new(0, 0.45098, 1), true)
		else
			clone = ReplicatedStorage3.Misc.forcePart3:Clone()
			shockwave(humanoidRootPart, 100, 0.4, Color3.new(1, 0, 0), true)
		end

		clone.Parent = game.Players.LocalPlayer.Character.HumanoidRootPart
		clone.Position = clone.Parent.Position
		clone.hit.PlaybackSpeed -= p
		clone.hit:Play()

		for _, child in pairs(clone.At2:GetChildren()) do
			if tonumber(child.Name) then
				child:Emit((tonumber(child.Name)))
			end
		end

		Debris:AddItem(clone, 2)
	end

	task.spawn(function()
		USEFORCE(0)
		task.wait(0.5)
		USEFORCE(0.5)
		task.wait(0.5)
		USEFORCE(1)
	end)
	ReplicatedStorage3.Remotes.ForceAbilityActivate:FireServer(value)
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