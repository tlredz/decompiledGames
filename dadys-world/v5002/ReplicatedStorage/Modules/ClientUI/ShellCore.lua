local ShellCore = {
	DEFAULTS = {
		altitude = 7,
		hipOffset = 2.5,
		ceilingClearance = 2,
		fallbackCeiling = 14,
		posOmega = 6,
		yawOmega = 8,
		bankGain = 0.35,
		bankMax = 0.44,
		pitchGain = 0.03,
		pitchMax = 0.35,
		diveTime = 0.55,
		climbTime = 0.9,
		diveScoop = 1,
		shadowRadius = 3
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function clamp(p: number, p2: number, p3: number)
	return (math.max(p2, (math.min(p3, p))))
end

function ShellCore.wrapAngle(p: number)
	local v = p % 6.283185307179586

	if v > 3.141592653589793 then
		return v - 6.283185307179586
	end

	return v
end

function ShellCore.spring1(p: number, p2: number, p3: number, p4: number, p5: number)
	local v = p2 + (p4 * p4 * (p3 - p) - p4 * 2 * p2) * p5
	return p + v * p5, v
end

function ShellCore.bezier(data, data2, data3, p: number)
	local v = 1 - p
	local v2 = v * v
	local v3 = v * 2 * p
	local v4 = p * p
	return {
		x = v2 * data.x + v3 * data2.x + v4 * data3.x,
		y = v2 * data.y + v3 * data2.y + v4 * data3.y,
		z = v2 * data.z + v3 * data2.z + v4 * data3.z
	}
end

local function bezierDerivative(diveFrom, data, diveAt, p: number)
	local v = (1 - p) * 2
	local v2 = p * 2
	return {
		x = v * (data.x - diveFrom.x) + v2 * (diveAt.x - data.x),
		y = v * (data.y - diveFrom.y) + v2 * (diveAt.y - data.y),
		z = v * (data.z - diveFrom.z) + v2 * (diveAt.z - data.z)
	}
end

function ShellCore.newState(data, yaw: number)
	return {
		pos = {
			x = data.x,
			y = data.y,
			z = data.z
		},
		vel = {
			x = 0,
			y = 0,
			z = 0
		},
		yaw = yaw,
		yawVel = 0,
		phase = "Hover",
		phaseT = 0,
		diveFrom = nil
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hoverHeight(data, data2)
	local ceilingY = data.ceilingY or data.floorY + data2.fallbackCeiling

	if data.mode == "Ceiling" then
		return ceilingY - data2.hipOffset
	end

	return (math.min(data.floorY + data2.altitude, ceilingY - data2.ceilingClearance))
end

function ShellCore:step(data, data2, p: number)
	local v = clamp(p, 0, 0.1) -- equivalent call inferred; original call site unknown
	local flipped = data.mode == "Ceiling"
	local angle = ShellCore.wrapAngle(data.bodyYaw - self.yaw)
	local spring1, yawVel = ShellCore.spring1(0, self.yawVel, angle, data2.yawOmega, v)
	self.yaw = ShellCore.wrapAngle(self.yaw + spring1)
	self.yawVel = yawVel

	if data.phase == "Dive" and data.diveAt then
		if self.phase ~= "Dive" or not self.diveFrom then
			self.phase = "Dive"
			self.phaseT = 0
			self.diveFrom = {
				x = self.pos.x,
				y = self.pos.y,
				z = self.pos.z
			}
		end

		self.phaseT += v
		local v4 = clamp(self.phaseT / data2.diveTime, 0, 1) -- equivalent call inferred; original call site unknown
		local diveFrom = self.diveFrom
		local diveAt = data.diveAt
		local v5 = {
			x = (diveFrom.x + diveAt.x) * 0.5,
			y = diveAt.y + data2.diveScoop,
			z = (diveFrom.z + diveAt.z) * 0.5
		}
		local bezier = ShellCore.bezier(diveFrom, v5, diveAt, v4)
		local v6 = bezierDerivative(diveFrom, v5, diveAt, v4)
		self.vel = {
			x = v6.x / data2.diveTime,
			y = v6.y / data2.diveTime,
			z = v6.z / data2.diveTime
		}
		self.pos = bezier
	else
		if self.phase == "Dive" then
			self.vel = {
				x = 0,
				y = data2.altitude / data2.climbTime,
				z = 0
			}
			self.diveFrom = nil
		end

		self.phase = data.phase
		local v4 = hoverHeight(data, data2) -- equivalent call inferred; original call site unknown
		local spring12, v5 = ShellCore.spring1(self.pos.x, self.vel.x, data.body.x, data2.posOmega, v)
		local spring13, v6 = ShellCore.spring1(self.pos.y, self.vel.y, v4, data2.posOmega, v)
		local spring14, v7 = ShellCore.spring1(self.pos.z, self.vel.z, data.body.z, data2.posOmega, v)
		self.pos = {
			x = spring12,
			y = spring13,
			z = spring14
		}
		self.vel = {
			x = v5,
			y = v6,
			z = v7
		}
	end

	local roll

	if flipped then
		roll = 0
	else
		local v5 = -data2.bankGain * self.yawVel
		roll = math.max(-data2.bankMax, (math.min(data2.bankMax, v5)))
	end

	local pitch

	if flipped then
		pitch = 0
	else
		local v6 = data2.pitchGain * self.vel.y
		pitch = math.max(-data2.pitchMax, (math.min(data2.pitchMax, v6)))
	end

	return {
		pos = self.pos,
		yaw = self.yaw,
		pitch = pitch,
		roll = roll,
		flipped = flipped
	}
end

function ShellCore.shadow(data, p: number, p2: number, p3: number)
	local v = clamp((data.y - p) / math.max(p2, 0.01), 0, 1) -- equivalent call inferred; original call site unknown
	local v2 = (1 - v) * 0.6 + 0.25
	return {
		pos = {
			x = data.x,
			y = p,
			z = data.z
		},
		radius = p3 * (v * 0.4 + 0.6),
		transparency = 1 - v2
	}
end

return ShellCore