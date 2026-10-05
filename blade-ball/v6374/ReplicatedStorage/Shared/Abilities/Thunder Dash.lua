local createVector = vector.create
local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
require3(script.Parent._Types)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
game:GetService("TweenService")
game:GetService("RunService")
require3(ReplicatedStorage2.Shared.ShockwaveEffect)
local v = require3(ReplicatedStorage2.Shared.PlaceGhost)

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

local ThunderDash = {}
ThunderDash.cooldown = 4
ThunderDash.cooldownReductionPerUpgrade = 0.5
ThunderDash.iconId = "rbxassetid://14520169908"

function ThunderDash.canBeUsed(p)
	local moveDirection = getMoveDirection(p.humanoid) -- equivalent call inferred; original call site unknown
	return moveDirection.Magnitude ~= 0
end

function ThunderDash.validateArguments(p)
	assert(typeof(p) == "table", "Bad arguments")
	assert(typeof(p.originalPivot) == "CFrame", "Bad originalPivot")
	assert(typeof(p.newPivot) == "CFrame", "Bad newPivot")
end

function ThunderDash.localOwnerActivation(data)
	local moveDirection = getMoveDirection(data.humanoid) -- equivalent call inferred; original call site unknown
	local v2 = 20 + 10 * data.upgradeLevel
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = {
		workspace.Runtime,
		workspace.Alive,
		workspace.Dead,
		workspace.Balls,
		workspace.TrainingBalls
	}
	local pivot = data.character:GetPivot()
	local raycastResult = workspace:Raycast(data.rootPart.Position, moveDirection * v2, raycastParams)

	if raycastResult then
		data.character:PivotTo(data.character:GetPivot().Rotation + raycastResult.Position)
	else
		data.character:PivotTo(data.character:GetPivot() + moveDirection * v2)
	end

	return {
		originalPivot = pivot,
		newPivot = data.character:GetPivot()
	}
end

function ThunderDash.anyClientActivationAsync(p, _, p2)
	local clone = script.ThunderDash:Clone()
	local clone2 = script.ThunderDashAddon:Clone()
	clone.Position = p2.newPivot.Position
	clone2.Position = p2.originalPivot.Position
	clone.Parent = workspace.Runtime
	clone2.Parent = workspace.Runtime
	clone.sound1:Play()

	if p.upgradeLevel >= 2 then
		clone.sound2.PlaybackSpeed = 1.5
	end

	clone.sound2:Play()
	Debris:AddItem(clone, 3)
	Debris:AddItem(clone2, 3)

	if p.upgradeLevel >= 2 then
		clone.Attachment.L1.Color = ColorSequence.new(Color3.fromRGB(179, 0, 255))
		clone2.Attachment.L1.Color = ColorSequence.new(Color3.fromRGB(179, 0, 255))
	end

	clone.Attachment.L1:Emit(10)
	clone2.Attachment.L1:Emit(10)
	task.spawn(function()
		for i = 0, 0.1, 0.1 do
			task.wait(i)
			local character = p.character
			local color

			if p.upgradeLevel >= 2 then
				color = Color3.fromRGB(179, 0, 255)
			else
				color = Color3.fromRGB(255, 246, 120)
			end

			v(character, {
				color = color,
				lifetime = 1,
				animationDelay = 0.5
			})
		end
	end)
	clone.Attachment.L1:Emit(10)
	task.wait(0.15)
	clone.WeldConstraint:Destroy()
	clone.Anchored = true
end

return ThunderDash