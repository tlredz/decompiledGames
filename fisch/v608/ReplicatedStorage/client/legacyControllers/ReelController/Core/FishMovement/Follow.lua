game:GetService("UserInputService")
game:GetService("TweenService")
game:GetService("ReplicatedStorage")
require("../../Types")
local Follow = {}
Follow.__index = Follow
Follow.Name = "Follow"

function Follow.new(current, fish)
	local self = setmetatable({}, Follow)
	self.current = current
	self.fish = fish
	self.FollowSpeed = 1
	self.CurrentDelay = 0
	fish.CurrentMaxSpeed = 1e999
	return self
end

function Follow:Tick(p: number)
	if self.fish.MovementPaused or self.fish.Disabled or not self.current.active then
		return
	end

	self.CurrentDelay = math.max(self.CurrentDelay - p, 0)

	if self.CurrentDelay > 0 then
		return
	end

	self.fish.CurrentTarget = math.clamp(
		self.current.barPosition,
		self.current.minFishPosition,
		self.current.maxFishPosition
	)
	self.fish.CurrentMoveTime = self.current.movementfactor / self.FollowSpeed
end

function Follow.MoveRandom(_) end

function Follow:DelayNextMovement(p2: number)
	self.CurrentDelay += p2
end

function Follow:RawDelayNextMovement(p2: number)
	self.CurrentDelay += p2
end

return Follow