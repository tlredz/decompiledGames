local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage2:WaitForChild("UserInputService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local humanoid = character:WaitForChild("Humanoid")
local Debris = game:GetService("Debris")
local SettingsController = require(ReplicatedStorage3:WaitForChild("Controllers"):WaitForChild("SettingsController"))
require(ReplicatedStorage.Shared.GetAbilityCooldownMultiplier)
local Utils = require(ReplicatedStorage.Common.Utils)
local AbilityUtils = require(ReplicatedStorage.Shared.AbilityUtils)
local Abilities = require(ReplicatedStorage.Shared.Abilities)
local Net = require(ReplicatedStorage.Packages.Net)
local remoteEvent = Net:RemoteEvent("NinjaDash")
local dash = script:WaitForChild("Dash")
local track = humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(dash)
local flag = false
local flag2 = false
local vector2 = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
local module = require(game.ReplicatedStorage.Shared.Abilities[script.Name])
vector2.Image = module and module.iconId or ""

local function ability()
	if flag2 or (localPlayer.Character.Parent ~= workspace.Alive or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false) or humanoid.MoveDirection == createVector(
		0,
		0,
		0
	) then
		return
	end

	flag2 = true
	local value = localPlayer.Upgrades[script.Name].Value
	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, script.Name)
	cooldownThread = task.delay(abilityCooldown, function()
		flag2 = false
		cooldownThread = nil
	end)
	local v = {
		FieldOfView = game.Workspace.CurrentCamera.FieldOfView * 1.25
	}
	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0)
	local TweenService = game:GetService("TweenService")
	TweenService:Create(game.Workspace.CurrentCamera, tweenInfo, v):Play()
	local moveDirection = humanoid.MoveDirection
	math.deg(humanoid.MoveDirection.X)
	math.deg(humanoid.MoveDirection.Y)
	math.deg(humanoid.MoveDirection.Z)
	local v2 = (160 + 20 * value) * math.max(character:GetScale(), 1)
	flag = true
	ReplicatedStorage3.Remotes.DashFired:Fire()
	ReplicatedStorage3.Remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
	remoteEvent:FireServer()
	AbilityUtils.playAnimationTrack(track, script.Name, 0.567)
	local rightVector = character.HumanoidRootPart.CFrame.rightVector
	local lookVector = character.HumanoidRootPart.CFrame.lookVector
	local dot = moveDirection:Dot(lookVector)
	local dot2 = moveDirection:Dot(rightVector)
	local v3 = 1 - math.random() / 100000000
	local v4 = math.clamp(dot, -1, v3)
	local v5 = math.clamp(dot2, -1, v3)
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Name = "Dash"
	bodyVelocity.MaxForce = createVector(100000, 0, 100000)
	bodyVelocity.Parent = character.HumanoidRootPart
	bodyVelocity.Velocity = lookVector * v4 * v2 + rightVector * v5 * v2
	Debris:AddItem(bodyVelocity, 0.01)
	local descendantAddedConnection = nil
	task.spawn(function()
		for _, part in ipairs(localPlayer.Character:GetDescendants()) do
			if not part:IsA("BasePart") or part.Massless then
				continue
			end

			part.Massless = true
			part:SetAttribute("DashSetMassless", true)
		end

		descendantAddedConnection = localPlayer.Character.DescendantAdded:Connect(function(part)
			if part:IsA("BasePart") then
				part.Massless = true
				part:SetAttribute("DashSetMassless", true)
			end
		end)
	end)
	local colliders = character:FindFirstChild("Colliders")
	local pin = colliders and colliders:FindFirstChild("Pin")
	local rigidConstraint = pin and pin:FindFirstChildWhichIsA("RigidConstraint")

	if rigidConstraint then
		rigidConstraint.Enabled = false
	end

	task.delay(0.3, function()
		for _, descendant in ipairs(localPlayer.Character:GetDescendants()) do
			if not descendant:GetAttribute("DashSetMassless") then
				continue
			end

			descendant:SetAttribute("DashSetMassless", nil)
			descendant.Massless = false
		end

		if rigidConstraint then
			rigidConstraint.Enabled = true
		end

		if descendantAddedConnection then
			descendantAddedConnection:Disconnect()
		end

		local primaryPart = localPlayer.Character.PrimaryPart

		if primaryPart then
			primaryPart.AssemblyLinearVelocity = createVector(0, 0, 0)
			primaryPart.AssemblyAngularVelocity = createVector(0, 0, 0)
		end
	end)
	task.wait(0.4)
	flag = false
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
ReplicatedStorage3.Remotes.DashFired.Event:Connect(function()
	task.spawn(function()
		while flag do
			local RunService = game:GetService("RunService")
			RunService.RenderStepped:Wait()
			local UserGameSettings = UserSettings():GetService("UserGameSettings")
			UserGameSettings.RotationType = Enum.RotationType.MovementRelative
		end
	end)
end)
ReplicatedStorage3.Remotes.EndCD.OnClientEvent:Connect(function()
	flag = false
	flag2 = false

	if cooldownThread then
		Utils.Thread.SafeCancel(cooldownThread)
		cooldownThread = nil
	end
end)