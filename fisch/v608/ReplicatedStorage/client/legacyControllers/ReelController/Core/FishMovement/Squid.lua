game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
game:GetService("ReplicatedStorage")
require("../../Types")
local Squid = {}
Squid.__index = Squid
Squid.Name = "Default"

function Squid.new(current, fish)
	local self = setmetatable({}, Squid)
	self.current = current
	self.fish = fish
	local v = math.max(self.current.resilience, 20) / 100
	self.NextMovement = self.fish.random:NextNumber(v * 2, v * 2.5)
	self.Elapsed = 0
	return self
end

function Squid:Tick(p: number)
	if self.fish.MovementPaused or self.fish.Disabled or not self.current.active then
		return
	end

	local v = math.max(self.current.resilience, 20) / 100
	local v2 = math.clamp(v / 5, 0.4, 1)
	self.Elapsed += p
	local value = TweenService:GetValue((v2 - self.Elapsed % v2) / v2, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
	local v3 = self.Elapsed < 0 and 0 or value
	self.current.core.fish.CurrentMaxSpeed = v3 * 0.5
	self.NextMovement -= p

	if self.NextMovement <= 0 then
		if tick() > self.current.fishmove then
			self:MoveRandom()
		end

		self.NextMovement = math.max(self.NextMovement, self.current.fishmove - tick()) + self.fish.random:NextNumber(
			v * 2,
			v * 2.5
		) / self.current.moveIntervalFactor
	end
end

function Squid:MoveRandom()
	local v = math.max(self.current.resilience, 20) / 100
	local number = self.fish.random:NextNumber(self.current.minFishPosition, self.current.maxFishPosition)
	local number2 = self.fish.random:NextNumber(v * 1.3, v * 2.5)
	local v2 = number - self.current.fishPosition
	self.fish:MoveTo(number, number2, v2 * (1 / v))
end

function Squid:DelayNextMovement(p: number)
	local v = math.max(self.current.resilience, 20) / 100
	self.NextMovement = math.max(self.NextMovement, self.current.fishmove - tick()) + self.fish.random:NextNumber(
		v * 2,
		v * 2.5
	) / self.current.moveIntervalFactor + p
	self.Elapsed = -p
end

function Squid:RawDelayNextMovement(p: number)
	self.NextMovement = math.max(self.NextMovement, self.current.fishmove - tick()) + p
end

return Squid