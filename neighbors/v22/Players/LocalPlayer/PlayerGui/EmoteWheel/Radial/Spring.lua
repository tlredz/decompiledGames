-- equivalent calls inferred from this helper; original call sites unknown
local function getAbsDist(p, t)
	local v = t - p

	if type(v) == "number" then
		return (math.abs(v))
	end

	return v.Magnitude
end

local Spring = {}
Spring.__index = Spring
Spring.__type = "Spring"

function Spring.__tostring(_)
	return Spring.__type
end

function Spring.new(p, p2, value, p3)
	local self = setmetatable({}, Spring)
	self.instant = false
	self.marginOfError = 1e-6
	local v = value or 1
	local v2 = p2 * p2 / (4 * p * v * v)
	self.k = p / v2
	self.d = -p2 / v2
	self.x = p3
	self.t = p3
	self.v = p3 * 0
	return self
end

function Spring:Update(p)
	if not self.instant then
		local t = self.t
		local k = self.k
		local d = self.d
		local x = self.x
		local v = self.v
		local v2 = k * (t - x) + v * d
		local v3 = v + v2 * (p / 2)
		local v4 = k * (t - (x + v * (p / 2))) + v3 * d
		local v5 = v + v4 * (p / 2)
		local v6 = k * (t - (x + v3 * (p / 2))) + v5 * d
		local v7 = v + v6 * p
		local v8 = x + (v + 2 * (v3 + v5) + v7) * (p / 6)
		local v9 = v + (v2 + 2 * (v4 + v6) + k * (t - (x + v5 * p)) + v7 * d) * (p / 6)
		self.x = v8
		self.v = v9
		local absDist = getAbsDist(v8, self.t) -- equivalent call inferred; original call site unknown

		if self.marginOfError < absDist then
			return v8
		end
	end

	local t = self.t
	local v = self.v * 0
	self.x = t
	self.v = v
	return self.x
end

return Spring