local ReplicatedStorage = game:GetService("ReplicatedStorage")
local _ = workspace.CurrentCamera
local Util = require(ReplicatedStorage.Util)
local Effect = require(ReplicatedStorage.Effect)
local misc = Util.Misc
local doughMiscDripGeneric = Effect.new("Dough.Misc.Drip.Generic")
return function(data)
	local cFrame = data.CFrame
	local scale = data.Scale or 1
	local spread = data.Spread or Vector2.new(360, 360)
	local lifetime = data.Lifetime
	local distance = data.Distance or 10
	local gravity = data.Gravity or 1
	local time = data.Time or 0.9
	local drag = data.Drag or 5
	local rate = data.Rate or 10
	local dropLifetime = data.DropLifetime or 2
	local speed = data.Speed or 12
	local influence = data.Influence or { 1, 1 }
	local v = 0
	local v2 = 0

	if typeof(influence) == "table" then
		v = influence[1]
		v2 = influence[2]
	elseif typeof(influence) == "number" then
		v2 = influence
		v = v2
		v2 = v
	end

	local random = Random.new()

	for _ = 1, rate do
		local number = random:NextNumber(v, v2)
		local spreadAngleFromCFrame, v3 = misc.SpreadAngleFromCFrame(cFrame, spread)
		local v4 = v3 * misc.CalculateVelocity(distance, time, drag)
		doughMiscDripGeneric:replicate({
			Type = "Trajectory",
			CFrame = spreadAngleFromCFrame,
			Drag = drag,
			Scale = scale * number,
			Velocity = v4 * number,
			Gravity = gravity * number,
			PastryLifetime = lifetime,
			DropLifetime = dropLifetime,
			Speed = speed,
			Force = data.Force
		})
	end
end