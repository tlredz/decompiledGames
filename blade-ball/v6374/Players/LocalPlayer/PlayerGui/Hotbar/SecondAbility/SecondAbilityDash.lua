local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require(ReplicatedStorage2:WaitForChild("UserInputService"))
local Players = game:GetService("Players")

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

local LTM = require(ReplicatedStorage.Shared.LTM)
local DeviceListener = require(ReplicatedStorage.ClientGameModules.DeviceListener)
local GamepadIconController = require(ReplicatedStorage.Controllers.GamepadIconController)
local playerGui = Players.LocalPlayer.PlayerGui
local parent = script.Parent
local mobileDashButton = playerGui.MobileDashButton
local dashButton = mobileDashButton.TouchControlFrame.DashButton
local currentLTM = LTM.getCurrentLTM()

if not currentLTM or currentLTM.Id ~= "OneAbility" or not currentLTM.IsActive() then
	return
end

local buttonL2 = Enum.KeyCode.ButtonL2

-- equivalent calls inferred from this helper; original call sites unknown
local function updateVisibility()
	local v = workspace:GetAttribute("CurrentlySelectedMode") == "OneAbility"
	local isMobile = DeviceListener:IsMobile()
	local visible = DeviceListener.Device == "Console"
	parent.HotkeyFrame.Q.Visible = not visible
	parent.HotkeyFrame.ControllerIcon.Visible = visible
	parent.Visible = v and not isMobile
	mobileDashButton.Enabled = v and isMobile
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateControllerIcon()
	local mappedImageForKeyCode = GamepadIconController:GetMappedImageForKeyCode(buttonL2) or ""

	if mappedImageForKeyCode then
		parent.HotkeyFrame.ControllerIcon.Image = mappedImageForKeyCode
	end
end

workspace:GetAttributeChangedSignal("CurrentlySelectedMode"):Connect(updateVisibility)
updateVisibility() -- equivalent call inferred; original call site unknown
updateControllerIcon() -- equivalent call inferred; original call site unknown
DeviceListener.OnChange:Connect(function()
	print("Haha")
	updateVisibility() -- equivalent call inferred; original call site unknown
	updateControllerIcon() -- equivalent call inferred; original call site unknown
end)
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local localPlayer = game.Players.LocalPlayer
local v = nil
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local UserInputService = require(ReplicatedStorage4:WaitForChild("UserInputService"))
local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
local humanoid = nil
local Debris = game:GetService("Debris")
require(ReplicatedStorage5:WaitForChild("Controllers"):WaitForChild("SettingsController"))
require(ReplicatedStorage3.Shared.GetAbilityCooldownMultiplier)
local Utils = require(ReplicatedStorage3.Common.Utils)
local AbilityUtils = require(ReplicatedStorage3.Shared.AbilityUtils)
local Abilities = require(ReplicatedStorage3.Shared.Abilities)
local dash = script:WaitForChild("Dash")
local track = nil
local flag = false
local v2 = false
local thread = nil

local function ability()
	if v2 or not humanoid or (localPlayer.Character.Parent ~= workspace.Alive or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false) then
		return
	end

	if humanoid.MoveDirection == createVector(0, 0, 0) then
		return
	end

	v2 = true
	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, "Dash")
	thread = task.delay(abilityCooldown, function()
		v2 = false
		thread = nil
	end)
	local v3 = {
		FieldOfView = game.Workspace.CurrentCamera.FieldOfView * 1.25
	}
	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0)
	local TweenService = game:GetService("TweenService")
	TweenService:Create(game.Workspace.CurrentCamera, tweenInfo, v3):Play()
	local moveDirection = humanoid.MoveDirection
	math.deg(humanoid.MoveDirection.X)
	math.deg(humanoid.MoveDirection.Y)
	math.deg(humanoid.MoveDirection.Z)
	local v4 = 160
	local scale = v:GetScale()

	if scale > 1 then
		v4 *= scale
	end

	flag = true
	ReplicatedStorage5.Remotes.DashFired:Fire()
	ReplicatedStorage5.Remotes.SecondaryVisualBindableCD:Fire(false, true, abilityCooldown)
	ReplicatedStorage5.Remotes.PlrDashed:FireServer()
	AbilityUtils.playAnimationTrack(track, script.Name, 0.567)
	local rightVector = v.HumanoidRootPart.CFrame.rightVector
	local lookVector = v.HumanoidRootPart.CFrame.lookVector
	local dot = moveDirection:Dot(lookVector)
	local dot2 = moveDirection:Dot(rightVector)
	local v5 = 1 - math.random() / 100000000
	local v6 = math.clamp(dot, -1, v5)
	local v7 = math.clamp(dot2, -1, v5)
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Name = "Dash"
	bodyVelocity.MaxForce = createVector(100000, 0, 100000)
	bodyVelocity.Parent = v.HumanoidRootPart
	bodyVelocity.Velocity = lookVector * v6 * v4 + rightVector * v7 * v4
	Debris:AddItem(bodyVelocity, 0.01)
	local descendantAddedConnection = nil
	task.defer(function()
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
	task.delay(0.3, function()
		for _, descendant in ipairs(localPlayer.Character:GetDescendants()) do
			if not descendant:GetAttribute("DashSetMassless") then
				continue
			end

			descendant:SetAttribute("DashSetMassless", nil)
			descendant.Massless = false
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

ReplicatedStorage5.Remotes.DashFired.Event:Connect(function()
	task.spawn(function()
		while flag do
			local RunService = game:GetService("RunService")
			RunService.RenderStepped:Wait()
			local UserGameSettings = UserSettings():GetService("UserGameSettings")
			UserGameSettings.RotationType = Enum.RotationType.MovementRelative
		end
	end)
end)
ReplicatedStorage5.Remotes.SecondaryEndCD.OnClientEvent:Connect(function()
	flag = false
	v2 = false

	if thread then
		Utils.Thread.SafeCancel(thread)
		thread = nil
	end
end)

local function activate()
	if workspace:GetAttribute("CurrentlySelectedMode") ~= "OneAbility" or (not v or not v.Parent or v.Parent ~= workspace.Alive) then
		return
	end

	ability()
end

parent.Activated:Connect(activate)
dashButton.Activated:Connect(activate)
UserInputService.InputBegan:Connect(function(input, gameProcessed: boolean)
	if gameProcessed then
		return
	end

	if input.KeyCode == Enum.KeyCode.E or input.KeyCode == buttonL2 then
		if workspace:GetAttribute("CurrentlySelectedMode") ~= "OneAbility" then
			return
		end

		if v and v.Parent then
			if v.Parent ~= workspace.Alive then
				return
			end

			ability()
		end
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function setupCharacter(character)
	v = character
	humanoid = v:WaitForChild("Humanoid")
	track = humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(dash)
end

if localPlayer.Character then
	setupCharacter(localPlayer.Character) -- equivalent call inferred; original call site unknown
end

localPlayer.CharacterAdded:Connect(setupCharacter)