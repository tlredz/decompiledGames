local RollingPumpkinCore = {
	Handover = {
		Tag = "RollingPumpkinRolling",
		Body = "RollBody",
		Radians = "RollRadians",
		Forward = "RollForward",
		Facing = "RollFacing",
		Grown = "RollGrown",
		DoorwayWidth = "RollDoorwayWidth",
		FullWidth = "RollFullWidth",
		GrowDistance = "RollGrowDistance",
		ExtentsPerWidth = "RollExtentsPerWidth",
		FaceTurn = "RollFaceTurn",
		HandedOverAt = "RollHandedOverAt"
	},
	HEADING_RESPONSE = 0.16,
	HEADING_MIN_STEP = 0.02,
	RUMBLE_RADIANS = 1.5707963267948966,
	BurstTag = "RollingPumpkinBurst",
	flatForward = function(p: number, p2: number)
		local v = math.sqrt(p * p + p2 * p2)

		if v < 0.001 then
			return nil, nil
		end

		return p / v, p2 / v
	end,
	deltaRadians = function(p: number, p2: number)
		if p2 <= 0 or p <= 0 then
			return 0
		end

		return p / p2
	end
}

function RollingPumpkinCore.consumeRumble(p: number, p2: number)
	local v = p + math.max(p2, 0)

	if RollingPumpkinCore.RUMBLE_RADIANS <= v then
		return v % RollingPumpkinCore.RUMBLE_RADIANS, true
	end

	return v, false
end

function RollingPumpkinCore.rumbleFalloff(p: number, p2: number)
	if p2 <= 0 or p2 <= p then
		return 0
	end

	return (1 - math.max(p, 0) / p2) ^ 1.5
end

function RollingPumpkinCore.supportHeight(p: number, p2: number, p3: number)
	local v = math.cos(p3)
	local v2 = math.sin(p3)
	return (math.sqrt((p * v) ^ 2 + (p2 * v2) ^ 2))
end

function RollingPumpkinCore.rollRadius(p: number, p2: number)
	return (p + p2) / 2
end

function RollingPumpkinCore.rampedSpeed(p: number, p2: number, p3: number)
	if p3 <= 0 then
		return p2
	end

	return p2 * math.clamp(p / p3, 0, 1)
end

function RollingPumpkinCore.widthAt(p: number, p2: number, p3: number, p4: number)
	if p4 <= 0 then
		return p3
	end

	local v = math.clamp(p / p4, 0, 1)
	local v2 = v * v * (3 - v * 2)
	return p2 + (p3 - p2) * v2
end

function RollingPumpkinCore.rockRadians(value: number, p: number)
	local v = math.clamp(value, 0, 1)
	return -p * v * math.sin(9.42477796076938 * v)
end

function RollingPumpkinCore.glowAt(value: number)
	local v = math.clamp(value, 0, 1)
	return v * (0.5 - math.cos(9.42477796076938 * v) * 0.5)
end

function RollingPumpkinCore.collapseScale(value: number, p: number)
	local v = math.clamp(value, 0, 1)
	return 1 - (1 - p) * v * v
end

function RollingPumpkinCore.turnToward(p: number, p2: number, p3: number, p4: number, p5: number)
	local v = math.sqrt(p3 * p3 + p4 * p4)
	local v2 = math.sqrt(p * p + p2 * p2)

	if v < 0.001 or v2 < 0.001 or p5 <= 0 then
		return p, p2
	end

	local v3 = p3 / v
	local v4 = p4 / v
	local v5 = p / v2
	local v6 = p2 / v2
	local v7 = math.atan2(v5 * v4 - v6 * v3, (math.clamp(v5 * v3 + v6 * v4, -1, 1)))

	if math.abs(v7) <= p5 then
		return v3, v4
	end

	local v8 = p5 * (v7 < 0 and -1 or 1)
	local v9 = math.cos(v8)
	local v10 = math.sin(v8)
	return v5 * v9 - v6 * v10, v5 * v10 + v6 * v9
end

function RollingPumpkinCore.stepHeadings(p: number, p2: number, p3: number, p4: number, p5: number, p6: number, p7: number, p8: number)
	local v = math.sqrt(p5 * p5 + p6 * p6)

	if v <= RollingPumpkinCore.HEADING_MIN_STEP then
		return p, p2, p3, p4
	end

	local v2 = 1 - math.exp(-p7 / RollingPumpkinCore.HEADING_RESPONSE)
	local v3 = p + (p5 / v - p) * v2
	local v4 = p2 + (p6 / v - p2) * v2
	local v5 = math.sqrt(v3 * v3 + v4 * v4)

	if v5 > 0.001 then
		p = v3 / v5
		p2 = v4 / v5
	end

	local turnToward, v6 = RollingPumpkinCore.turnToward(p3, p4, p, p2, p8 * p7)
	return p, p2, turnToward, v6
end

function RollingPumpkinCore.shouldRetarget(p: number, p2: number, p3: number, p4: number, p5: number)
	return not (p3 < p4) and p2 + p5 < p
end

function RollingPumpkinCore.rampedBetween(p: number, p2: number, p3: number, p4: number)
	if p4 <= 0 then
		return p2
	end

	local v = math.clamp(p3 / p4, 0, 1)
	return p + (p2 - p) * v
end

function RollingPumpkinCore.isRouteStale(p: number, p2: number)
	return p ~= p2
end

function RollingPumpkinCore.newHitLedger(p: number)
	return {
		limit = math.max(p, 0),
		count = 0,
		hit = {}
	}
end

function RollingPumpkinCore.wasHit(p, p2)
	return p2 ~= nil and p.hit[p2] == true
end

function RollingPumpkinCore.isFull(p)
	return p.count >= p.limit
end

function RollingPumpkinCore.canHit(p, p2)
	return p2 ~= nil and not RollingPumpkinCore.isFull(p) and not p.hit[p2]
end

function RollingPumpkinCore:registerHit(p)
	if not RollingPumpkinCore.canHit(self, p) then
		return false
	end

	self.hit[p] = true
	self.count += 1
	return true
end

function RollingPumpkinCore.anyUnhit(p, list)
	for _, v in ipairs(list) do
		if v ~= nil and not p.hit[v] then
			return true
		end
	end

	return false
end

function RollingPumpkinCore.lateUrgency(p: number, value: number)
	local v = math.clamp(value, 0, 1)
	local v2 = 1 - v

	if v2 <= 0 then
		if p >= 1 then
			return 1
		end

		return 0
	else
		return (math.clamp((p - v) / v2, 0, 1))
	end
end

return RollingPumpkinCore