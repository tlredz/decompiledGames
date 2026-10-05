game:GetService("UserInputService")
game:GetService("TweenService")
game:GetService("ReplicatedStorage")
require("../../Types")
local Default = {}
Default.__index = Default
Default.Name = "Default"

function Default.new(current, fish)
	local self = setmetatable({}, Default)
	self.current = current
	self.fish = fish
	local v = math.max(self.current.resilience, 20) / 100
	self.NextMovement = self.fish.random:NextNumber(v * 2, v * 2.5)
	fish.CurrentMaxSpeed = 1e999
	return self
end

function Default:Tick(p: number)
	if self.fish.MovementPaused or self.fish.Disabled or not self.current.active then
		return
	end

	self.NextMovement -= p

	if self.NextMovement <= 0 then
		if tick() > self.current.fishmove then
			self:MoveRandom()
		end

		local v = math.max(self.current.resilience, 20) / 100
		self.NextMovement = math.max(self.NextMovement, self.current.fishmove - tick()) + self.fish.random:NextNumber(
			v * 2,
			v * 2.5
		) / self.current.moveIntervalFactor
	end
end

function Default:MoveRandom()
	local v = math.max(self.current.resilience, 20) / 100
	local v2 = math.max(v, 0.8) * 0.8
	local minFishPosition = math.max(self.current.minFishPosition, self.current.fishPosition - v2 / 2)
	local maxFishPosition = math.min(self.current.maxFishPosition, self.current.fishPosition + v2 / 2)
	local v3 = self.current.maxFishPosition - self.current.minBarPosition
	local v4 = self.current.minFishPosition + v3 / 2

	if maxFishPosition - minFishPosition < v2 and maxFishPosition - minFishPosition < v3 then
		if v3 <= v2 then
			minFishPosition = self.current.minFishPosition
			maxFishPosition = self.current.maxFishPosition
		else
			local v5 = v2 - (maxFishPosition - minFishPosition)

			if v4 < self.current.fishPosition then
				maxFishPosition = math.min(self.current.maxFishPosition, maxFishPosition + v5)
			else
				minFishPosition = math.max(self.current.minFishPosition, minFishPosition - v5)
			end
		end
	end

	local number = self.fish.random:NextNumber(minFishPosition, maxFishPosition)
	local number2 = self.fish.random:NextNumber(v * 1.3, v * 3.5)
	local v5 = number - self.current.fishPosition
	self.fish:MoveTo(number, number2, v5 * (1 / v))
end

function Default:DelayNextMovement(p: number)
	local v = math.max(self.current.resilience, 20) / 100
	self.NextMovement = math.max(self.NextMovement, self.current.fishmove - tick()) + self.fish.random:NextNumber(
		v * 2,
		v * 2.5
	) / self.current.moveIntervalFactor + p
end

function Default:RawDelayNextMovement(p: number)
	self.NextMovement = math.max(self.NextMovement, self.current.fishmove - tick()) + p
end

return Default