game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.packages.Trove)
local Hook = require(ReplicatedStorage.shared.modules.Hook)
local fish = require(ReplicatedStorage.shared.modules.library.fish)
require("../Types")
local FishMovement = {}
FishMovement.__index = FishMovement

function FishMovement.new(current)
	local object = setmetatable({}, FishMovement)
	object.current = current
	object.trove = current.trove:Extend()
	object.MovementBehaviorEnabled = true
	object.random = current:GetRandom(1)
	local movementBehavior = fish[current.fish.Name] and fish[current.fish.Name].MovementBehavior or "Default"
	object.OriginalMovementBehaviorName = movementBehavior
	object:SetMovementBehavior(movementBehavior)
	object.CurrentTarget = 0.5
	object.CurrentVelocity = 0
	object.CurrentMoveTime = 1
	object.CurrentMaxSpeed = 1e999
	object.MovementPaused = false
	object.OnMovementAttempted = object.trove:Add(Hook.new(function(p: number, p2: number, p3: number?)
		return true, p, p2, p3
	end))
	return object
end

function FishMovement.Start(_) end

function FishMovement:Disable()
	self.Disabled = true
end

function FishMovement.Stop(p)
	p.trove:Clean()
end

function FishMovement:Tick(p: number)
	if self.Disabled or self.MovementPaused or self.current.frozenUntil > tick() then
		return
	end

	local v = p / self.current.movementfactor

	if self.MovementBehaviorEnabled then
		self.MovementBehavior:Tick(v)
	end

	local current = self.current
	local smoothDamp, currentVelocity = TweenService:SmoothDamp(
		self.current.fishPosition,
		self.CurrentTarget,
		self.CurrentVelocity,
		self.CurrentMoveTime,
		self.CurrentMaxSpeed,
		v
	)
	current.fishPosition = smoothDamp
	self.CurrentVelocity = currentVelocity

	if self.current.fishPosition >= 1 then
		self.current.fishPosition = 1

		if self.CurrentVelocity > 0 then
			self.CurrentVelocity = 0
		end
	elseif self.current.fishPosition <= 0 then
		self.current.fishPosition = 0

		if self.CurrentVelocity < 0 then
			self.CurrentVelocity = 0
		end
	end
end

function FishMovement:SetMovementBehavior(childName: string)
	if self.MovementBehavior and childName == self.MovementBehavior.Name then
		return self.MovementBehavior
	end

	local default = script:FindFirstChild(childName)

	if not default then
		warn((`Unknown MovementBehavior "{childName}"! Using Default instead.`))
		default = script:FindFirstChild("Default")
	end

	local module = require(default)
	local movementBehavior = module.new(self.current, self)
	self.MovementBehavior = movementBehavior
	return movementBehavior
end

function FishMovement:ApplyImpulse(p2: number)
	self.CurrentVelocity += p2
end

function FishMovement:ForceMoveTo(currentTarget: number, p2: number, currentVelocity: number?)
	self.CurrentTarget = currentTarget
	self.CurrentMoveTime = p2 * self.current.movementfactor

	if currentVelocity then
		self.CurrentVelocity = currentVelocity
	end

	self.current.OnFishMove:Fire(currentTarget, p2)
end

function FishMovement:MoveTo(p: number, p2: number, p3: number?)
	if self.current.frozenUntil > tick() then
		return false
	end

	local v, v2, v3, v4 = self.OnMovementAttempted:InvokeAsync(p, p2, p3)

	if v then
		self:ForceMoveTo(v2, v3, v4)
	end

	return v
end

function FishMovement:DelayNextMovement(p2: number)
	self.MovementBehavior:DelayNextMovement(p2)
end

function FishMovement:RawDelayNextMovement(p2: number)
	self.MovementBehavior:RawDelayNextMovement(p2)
end

function FishMovement:MoveRandom()
	self.MovementBehavior:MoveRandom()
end

function FishMovement:PauseMovement()
	self.MovementPaused = true
end

function FishMovement:ResumeMovement()
	self.MovementPaused = false
end

function FishMovement:CancelMovement(flag: boolean?)
	self.CurrentTarget = self.current.fishPosition

	if flag then
		self.CurrentVelocity = 0
	end
end

return FishMovement