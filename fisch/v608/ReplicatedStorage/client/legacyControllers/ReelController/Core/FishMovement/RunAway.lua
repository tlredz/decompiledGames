game:GetService("UserInputService")
game:GetService("TweenService")
game:GetService("ReplicatedStorage")
require("../../Types")
local RunAway = {}
RunAway.__index = RunAway
RunAway.Name = "RunAway"

function RunAway.new(current, fish)
	local self = setmetatable({}, RunAway)
	self.current = current
	self.fish = fish
	self.NextMovement = 0
	self.DelayTimer = 0
	fish.CurrentMaxSpeed = 1e999
	return self
end

function RunAway:Tick(p: number)
	if self.fish.MovementPaused or self.fish.Disabled or not self.current.active then
		return
	end

	self.NextMovement -= p
	self.DelayTimer -= p
	local v = math.max(self.current.resilience, 20) / 100

	if self.current.onbar and self.fish.CurrentVelocity < 0.01 and self.DelayTimer <= 0 then
		self.NextMovement -= p * 4
	end

	if self.NextMovement <= 0 and tick() > self.current.fishmove then
		if tick() > self.current.fishmove then
			self:MoveRandom()
		end

		self.NextMovement += self.fish.random:NextNumber(v * 3, v * 5) / self.current.moveIntervalFactor
	end
end

function RunAway:MoveRandom()
	local v = self.current.barPosition - self.current.barSize / 2
	local v2 = self.current.barPosition + self.current.barSize / 2
	local v3 = math.min(v - self.current.minFishPosition, 0) + math.min(self.current.maxFishPosition - v2, 0)
	local v4 = self.current.barSize - v3
	local v5 = self.current.maxFishPosition - self.current.minBarPosition
	local v6 = math.max(self.current.resilience, 20) / 100

	if v5 <= v4 then
		local number = self.fish.random:NextNumber(self.current.minFishPosition, self.current.maxFishPosition)
		local v7 = number - self.current.fishPosition
		self.fish:MoveTo(number, v6, v7 * (1 / v6))
	else
		local v7

		if self.current.fishPosition < self.current.barPosition and self.current.minFishPosition < v or self.current.maxFishPosition <= v2 then
			v7 = self.fish.random:NextNumber(self.current.minFishPosition, v)
		else
			v7 = self.fish.random:NextNumber(v2, self.current.maxFishPosition)
		end

		self.fish.random:NextNumber(v6 * 2, v6 * 3.5)
		local v8 = v7 - self.current.fishPosition
		self.fish:MoveTo(v7, v6, v8 * (1 / v6))
	end
end

function RunAway:DelayNextMovement(p: number)
	local v = math.max(self.current.resilience, 20) / 100
	self.NextMovement = math.max(self.NextMovement, self.current.fishmove - tick()) + self.fish.random:NextNumber(
		v * 2,
		v * 2.5
	) / self.current.moveIntervalFactor + p
	self.DelayTimer = math.max(self.DelayTimer, p)
end

function RunAway:RawDelayNextMovement(p: number)
	self.NextMovement = math.max(self.NextMovement, self.current.fishmove - tick()) + p
	self.DelayTimer = math.max(self.DelayTimer, p)
end

return RunAway