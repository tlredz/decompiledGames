local createVector = vector.create
require(script.Parent._Types)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ShockwaveEffect = require(ReplicatedStorage.Shared.ShockwaveEffect)

-- equivalent calls inferred from this helper; original call sites unknown
local function getMoveDirection(humanoid)
	if not humanoid.RootPart then
		return createVector(0, 0, 0)
	end

	local moveDirection = createVector(0, 0, 0)

	if humanoid.MoveDirection.Magnitude == 0 then
		if humanoid.WalkToPoint.Magnitude ~= 0 then
			moveDirection = humanoid.WalkToPoint - humanoid.RootPart.Position
		end
	else
		moveDirection = humanoid.MoveDirection
	end

	return moveDirection * createVector(1, 0, 1)
end

local Dash = {}
Dash.cooldown = 8
Dash.cooldownReductionPerUpgrade = 0.125
Dash.iconId = "rbxassetid://13735989240"

function Dash.canBeUsed(p)
	if not p.character:FindFirstChildWhichIsA("Animator", true) then
		return false
	end

	local moveDirection = getMoveDirection(p.humanoid) -- equivalent call inferred; original call site unknown
	return moveDirection.Magnitude ~= 0
end

function Dash.localOwnerActivation(data, _)
	local animator = data.character:FindFirstChildWhichIsA("Animator", true)
	local moveDirection = getMoveDirection(data.humanoid) -- equivalent call inferred; original call site unknown
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {
		workspace.Alive,
		workspace.Runtime,
		workspace.Balls,
		workspace.TrainingBalls
	}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	if workspace:Raycast(data.rootPart.Position, moveDirection * 2, raycastParams) or workspace:Raycast(
		data.rootPart.Position,
		createVector(0, 4, 0),
		raycastParams
	) then
		return
	end

	local character = data.character
	local rightVector = character.HumanoidRootPart.CFrame.rightVector
	local lookVector = character.HumanoidRootPart.CFrame.lookVector
	local v = math.clamp(moveDirection:Dot(lookVector), -1, 1)
	local v2 = math.clamp(moveDirection:Dot(rightVector), -1, 1)
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Name = "Dash"
	bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
	bodyVelocity.Parent = character.HumanoidRootPart
	bodyVelocity.Velocity = lookVector * v * (160 + 40 * data.upgradeLevel) + rightVector * v2 * (160 + 40 * data.upgradeLevel)
	task.spawn(function()
		Debris:AddItem(bodyVelocity, 0.03333333333333333)
		local v3 = 0.016666666666666666

		repeat
			v3 -= task.wait()
		until v3 <= 0.004166666666666667

		bodyVelocity:Destroy()
	end)
	animator:LoadAnimation(script.Animation):Play()

	if RunService:IsClient() then
		TweenService:Create(
			workspace.CurrentCamera,
			TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
			{
				FieldOfView = 87.5
			}
		):Play()
		local postSimulationConnection = RunService.PostSimulation:Connect(function()
			local UserGameSettings = UserSettings():GetService("UserGameSettings")
			UserGameSettings.RotationType = Enum.RotationType.MovementRelative
		end)
		task.delay(0.4, function()
			postSimulationConnection:Disconnect()
		end)
	end

	return nil
end

function Dash.anyClientActivationAsync(p)
	local clone = script.Dash:Clone()
	clone.Position = p.rootPart.Position
	clone.WeldConstraint.Part1 = p.rootPart
	clone.Parent = workspace.Runtime
	Debris:AddItem(clone, 2)
	clone.Swoosh:Play()

	if p.upgradeLevel >= 2 then
		clone.maxswos:Play()
	end

	for i = 0, 0.2, 0.1 do
		task.delay(i, function()
			local v2 = {
				cframe = p.rootPart.CFrame,
				orientation = "Vertical",
				color = 0,
				diameter = 25
			}
			local color

			if p.upgradeLevel >= 2 then
				color = Color3.new(1, 1, 0)
			else
				color = Color3.new(1, 1, 1)
			end

			v2.color = color
			ShockwaveEffect(v2)
		end)
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {
		workspace.Alive,
		workspace.Runtime,
		workspace.Balls,
		workspace.TrainingBalls
	}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	local raycastResult = workspace:Raycast(p.rootPart.Position, createVector(-0, -10, -0), raycastParams)

	if raycastResult then
		clone.Attachment.dust.Color = ColorSequence.new(raycastResult.Instance.Color)
		clone.Attachment.dust.Enabled = true
		task.delay(0.2, function()
			clone.Attachment.dust.Enabled = false
		end)
	end
end

return Dash