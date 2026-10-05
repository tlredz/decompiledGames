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
local Utils = require(ReplicatedStorage.Common.Utils)
local AbilityUtils = require(ReplicatedStorage.Shared.AbilityUtils)
local Abilities = require(ReplicatedStorage.Shared.Abilities)
local superJump = script:WaitForChild("SuperJump")
local track = humanoid:FindFirstChildOfClass("Animator"):LoadAnimation(superJump)
local flag = false
local thread = nil
local mouseButton2 = Enum.UserInputType.MouseButton2
local vector2 = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Hotbar"):WaitForChild("Ability"):WaitForChild("Vector")
local module = require(game.ReplicatedStorage.Shared.Abilities[script.Name])
vector2.Image = module and module.iconId or ""
local raycastParams = RaycastParams.new()
raycastParams.CollisionGroup = "Players"

local function ability()
	if flag or (localPlayer.Character.Parent ~= workspace.Alive or localPlayer.PlayerGui.Hotbar.Ability.Red.Visible ~= false) then
		return
	end

	if workspace:Spherecast(
		localPlayer.Character.PrimaryPart:GetPivot().Position,
		1.25,
		createVector(0, 20, 0),
		raycastParams
	) then
		print("things above")
		return
	end

	flag = true
	local abilityCooldown = Abilities.getAbilityCooldown(localPlayer, script.Name)
	local value = localPlayer.Upgrades[script.Name].Value
	local v = value == 1 and 225 or value == 2 and 250 or 200
	AbilityUtils.playAnimationTrack(track, script.Name, 0.567)
	local v2 = {
		FieldOfView = game.Workspace.CurrentCamera.FieldOfView * 1.2
	}
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, true, 0)
	local TweenService = game:GetService("TweenService")
	TweenService:Create(game.Workspace.CurrentCamera, tweenInfo, v2):Play()
	ReplicatedStorage3.Remotes.PlrSuperJumped:FireServer()
	ReplicatedStorage3.Remotes.VisualBindableCD:Fire(false, true, abilityCooldown)
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Name = "Dash"
	bodyVelocity.Parent = character.HumanoidRootPart
	bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
	bodyVelocity.Velocity = Vector3.new(0, v, 0)
	Debris:AddItem(bodyVelocity, 0.001)
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