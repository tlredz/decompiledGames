local createVector = vector.create
game:GetService("RunService")
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShockwaveEffect = require(ReplicatedStorage.Shared.ShockwaveEffect)
local dash = script.Dash
local animation = script.Animation
local Dash = {
	AbilityName = "Dash",
	AbilityCooldown = 4,
	CanUseAbility = function(_, instance)
		if not instance.PrimaryPart or instance:GetAttribute("PULSED") and not instance:GetAttribute("teamVIP") then
			return false
		end

		return not instance:GetAttribute("AbilityCooldown")
	end
}

function Dash:RegisterCooldown(instance, _: number)
	instance:SetAttribute("AbilityCooldown", true)
	task.delay(Dash.AbilityCooldown, function()
		if instance:IsDescendantOf(workspace) then
			instance:SetAttribute("AbilityCooldown", nil)
		end
	end)
end

function Dash.ServerInit(_, p, p2: number, flag: boolean)
	if not flag then
		Dash:RegisterCooldown(p, p2)
	end
end

function Dash.ServerStart(_, instance, p: number)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local humanoid = instance:FindFirstChildWhichIsA("Humanoid")
	local moveDirection = humanoid.MoveDirection

	if moveDirection == createVector(0, 0, 0) then
		moveDirection = humanoidRootPart.CFrame.LookVector * 20
	end

	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = {
		workspace.Alive,
		workspace.Runtime,
		workspace.Balls,
		workspace.TrainingBalls
	}
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	if workspace:Raycast(humanoidRootPart.Position, moveDirection * 2, raycastParams) or workspace:Raycast(
		humanoidRootPart.Position,
		createVector(0, 4, 0),
		raycastParams
	) then
		return
	end

	humanoid:MoveTo(humanoidRootPart.Position + moveDirection)
	local rightVector = humanoidRootPart.CFrame.rightVector
	local lookVector = humanoidRootPart.CFrame.lookVector
	local v = math.clamp(moveDirection:Dot(lookVector), -1, 1)
	local v2 = math.clamp(moveDirection:Dot(rightVector), -1, 1)
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Name = "Dash"
	bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
	bodyVelocity.Parent = humanoidRootPart
	bodyVelocity.Velocity = lookVector * v * (p * 40 + 160) + rightVector * v2 * (p * 40 + 160)
	task.spawn(function()
		task.delay(0.03333333333333333, function()
			bodyVelocity:Destroy()
		end)
		local v3 = 0.016666666666666666

		while v3 <= 0.004166666666666667 do
			v3 -= task.wait()
		end

		bodyVelocity:Destroy()
	end)
	local animator = instance:FindFirstChildWhichIsA("Animator", true)

	if animator then
		animator:LoadAnimation(animation):Play()
	end
end

function Dash.ClientStart(_, instance, p: number)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if instance:FindFirstChildWhichIsA("Humanoid").MoveDirection == createVector(0, 0, 0) then
		local _ = humanoidRootPart.CFrame.LookVector * 10
	end

	local clone = dash:Clone()
	clone.Position = humanoidRootPart.Position
	clone.WeldConstraint.Part1 = humanoidRootPart
	clone.Parent = workspace.Runtime
	task.delay(2, function()
		clone:Destroy()
	end)

	for i = 0, 0.2, 0.1 do
		task.delay(i, function()
			local v2 = {
				cframe = humanoidRootPart.CFrame,
				orientation = "Vertical",
				color = 0,
				diameter = 25
			}
			local color

			if p >= 2 then
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
	local raycastResult = workspace:Raycast(humanoidRootPart.Position, createVector(-0, -10, -0), raycastParams)

	if raycastResult then
		clone.Attachment.dust.Color = ColorSequence.new(raycastResult.Instance.Color)
		clone.Attachment.dust.Enabled = true
		task.delay(0.2, function()
			clone.Attachment.dust.Enabled = false
		end)
	end
end

return Dash