local TreatPumpkinCore = {
	Tag = "TreatPumpkin",
	Attr = {
		From = "TreatPumpkinFrom",
		LaunchAt = "TreatPumpkinLaunchAt",
		Flight = "TreatPumpkinFlight",
		Arc = "TreatPumpkinArc",
		FlyIn = "TreatPumpkinFlyIn",
		CollectedBy = "TreatPumpkinCollectedBy"
	},
	DoorLink = "TreatPumpkinDoor",
	splitAmount = function(p: number, p2: number)
		local v = math.max(0, (math.floor(p)))
		local v2 = math.clamp(math.floor(p2), 1, (math.max(v, 1)))
		local v3 = v // v2
		local v4 = v - v3 * v2
		local result = table.create(v2, v3)

		for i = 1, v4 do
			result[i] += 1
		end

		return result
	end,
	ROLL_SECONDS = 0.5,
	ROLL_DEPTH = 6,
	rollAlpha = function(value: number)
		return math.clamp(value, 0, 1) ^ 1.35
	end,
	LAUNCH_SCALE = 0.8,
	POP_FRACTION = 0.3,
	arcHeight = function(value: number, p: number)
		local v = math.clamp(value, 0, 1)
		return p * 4 * v * (1 - v)
	end
}

function TreatPumpkinCore.launchScale(p: number)
	local v = math.clamp(p / TreatPumpkinCore.POP_FRACTION, 0, 1) - 1
	local v2 = v ^ 3 * 2.70158 + 1 + v ^ 2 * 1.70158
	return TreatPumpkinCore.LAUNCH_SCALE + (1 - TreatPumpkinCore.LAUNCH_SCALE) * v2
end

TreatPumpkinCore.BOUNCES = {
	{
		seconds = 0.22,
		height = 0.9
	},
	{
		seconds = 0.14,
		height = 0.3
	}
}
TreatPumpkinCore.LAND_PUNCH = 0.18

function TreatPumpkinCore.bounceSeconds()
	local total = 0

	for _, v in ipairs(TreatPumpkinCore.BOUNCES) do
		total += v.seconds
	end

	return total
end

function TreatPumpkinCore.bounceAt(p: number)
	if p < 0 then
		return 0, 1
	end

	local total = 0

	for i, v in ipairs(TreatPumpkinCore.BOUNCES) do
		if p < total + v.seconds then
			local v2 = (p - total) / v.seconds
			local v3 = TreatPumpkinCore.LAND_PUNCH / i * (1 - v2)
			return 4 * v.height * v2 * (1 - v2), 1 + v3
		else
			total += v.seconds
		end
	end

	return 0, 1
end

TreatPumpkinCore.BOB_HEIGHT = 0.3
TreatPumpkinCore.BOB_SPEED = 3.2
TreatPumpkinCore.IDLE_TURN = 1.2217304763960306

function TreatPumpkinCore.bobAt(p: number)
	return TreatPumpkinCore.BOB_HEIGHT * 0.5 * (1 - math.cos(math.max(p, 0) * TreatPumpkinCore.BOB_SPEED))
end

TreatPumpkinCore.HOP_FRACTION = 0.3
TreatPumpkinCore.HOP_HEIGHT = 2.2
TreatPumpkinCore.HOP_SCALE = 1.3
TreatPumpkinCore.ARRIVE_SCALE = 0.25

function TreatPumpkinCore.flyInAt(value: number)
	local v = math.clamp(value, 0, 1)
	local HOP_FRACTION = TreatPumpkinCore.HOP_FRACTION

	if v < HOP_FRACTION then
		local v2 = v / HOP_FRACTION
		local v3 = 1 - (1 - v2) * (1 - v2)
		return TreatPumpkinCore.HOP_HEIGHT * v3, 0, 1 + (TreatPumpkinCore.HOP_SCALE - 1) * v3
	else
		local v2 = (v - HOP_FRACTION) / (1 - HOP_FRACTION)
		local v3 = v2 * v2
		local v4 = TreatPumpkinCore.HOP_SCALE + (TreatPumpkinCore.ARRIVE_SCALE - TreatPumpkinCore.HOP_SCALE) * v3
		return TreatPumpkinCore.HOP_HEIGHT, v3, v4
	end
end

return TreatPumpkinCore