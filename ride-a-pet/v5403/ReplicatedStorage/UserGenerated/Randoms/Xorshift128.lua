local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.UserGenerated.Randoms.Base)
local GenerateSeed = require(ReplicatedStorage.UserGenerated.IO.Crypto.GenerateSeed)
local Theory = require(script.Theory)
local bxor = bit32.bxor
local bor = bit32.bor
local band = bit32.band
local lshift = bit32.lshift
local rshift = bit32.rshift
local floor = math.floor
local ldexp = math.ldexp
local sqrt = math.sqrt
local log = math.log
local max = math.max
local sin = math.sin
local cos = math.cos
local clamp = math.clamp
local format = string.format
local new = Vector2.new
local new2 = Vector3.new
assert(true)
local random = Random.new()

local function Mul32(p: number, p2: number)
	local v = rshift(p, 16)
	local v2 = band(p, 65535)
	local v3 = rshift(p2, 16)
	local v4 = band(p2, 65535)
	return lshift(band(v * v4 + v2 * v3, 65535), 16) + v2 * v4
end

local function IsInteger(value: number)
	return type(value) == "number" and floor(value) == value and value ~= 1e999 and value ~= -1e999
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AssertInteger(value: number)
	local v

	if type(value) == "number" and floor(value) == value and value ~= 1e999 then
		v = value ~= -1e999
	else
		v = false
	end

	if not v then
		error("Integer", 2)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AssertIntegerNonNegative(value: number)
	AssertInteger(value) -- equivalent call inferred; original call site unknown

	if not (value >= 0) then
		error("NonNegative", 2)
	end
end

local function Seed(p, value)
	local v = value == nil and {} or type(value) == "number" and { value } or value
	local v2 = v[1]
	local v3 = v[2]
	local v4 = v[3]
	local v5 = v[4]
	local v7 = bor(v2 or random:NextInteger(0, 4294967295), 0)

	if not v3 then
		local v8 = rshift(v7, 16)
		local v9 = band(v7, 65535)
		v3 = lshift(band(v9 * 27655 + v8 * 35173, 65535), 16) + v9 * 35173 + 1
	end

	local v8 = bor(v3, 0)

	if not v4 then
		local v9 = rshift(v8, 16)
		local v10 = band(v8, 65535)
		v4 = lshift(band(v10 * 27655 + v9 * 35173, 65535), 16) + v10 * 35173 + 1
	end

	local v9 = bor(v4, 0)

	if not v5 then
		local v10 = rshift(v9, 16)
		local v11 = band(v9, 65535)
		v5 = lshift(band(v11 * 27655 + v10 * 35173, 65535), 16) + v11 * 35173 + 1
	end

	local v10 = bor(v5, 0)
	p.x = v7
	p.y = v8
	p.z = v9
	p.w = v10
end

local frozen = table.freeze({
	NextU32 = function(state)
		local x = state.x
		local w = state.w
		local v2 = bxor(x, (lshift(x, 11)))
		local v7 = bxor(bxor(bxor(v2, (rshift(v2, 8))), w), (rshift(w, 19)))
		local y = state.y
		local z = state.z
		state.x = y
		state.y = z
		state.z = w
		state.w = v7
		return v7
	end,
	NextU64 = function(state)
		local x = state.x
		local w = state.w
		local v2 = bxor(x, (lshift(x, 11)))
		local v7 = bxor(bxor(bxor(v2, (rshift(v2, 8))), w), (rshift(w, 19)))
		local y = state.y
		local z = state.z
		state.x = y
		state.y = z
		state.z = w
		state.w = v7
		local v8 = ldexp(v7, 32)
		local x2 = state.x
		local w2 = state.w
		local v10 = bxor(x2, (lshift(x2, 11)))
		local v15 = bxor(bxor(bxor(v10, (rshift(v10, 8))), w2), (rshift(w2, 19)))
		local y2 = state.y
		local z2 = state.z
		state.x = y2
		state.y = z2
		state.z = w2
		state.w = v15
		return v8 + v15
	end,
	NextFloat = function(state)
		local x = state.x
		local w = state.w
		local v2 = bxor(x, (lshift(x, 11)))
		local v7 = bxor(bxor(bxor(v2, (rshift(v2, 8))), w), (rshift(w, 19)))
		local y = state.y
		local z = state.z
		state.x = y
		state.y = z
		state.z = w
		state.w = v7
		return (ldexp(v7, -32))
	end,
	NextDouble = function(state)
		local x = state.x
		local w = state.w
		local v2 = bxor(x, (lshift(x, 11)))
		local v7 = bxor(bxor(bxor(v2, (rshift(v2, 8))), w), (rshift(w, 19)))
		local y = state.y
		local z = state.z
		state.x = y
		state.y = z
		state.z = w
		state.w = v7
		local v8 = ldexp(v7, 32)
		local x2 = state.x
		local w2 = state.w
		local v10 = bxor(x2, (lshift(x2, 11)))
		local v15 = bxor(bxor(bxor(v10, (rshift(v10, 8))), w2), (rshift(w2, 19)))
		local y2 = state.y
		local z2 = state.z
		state.x = y2
		state.y = z2
		state.z = w2
		state.w = v15
		return (ldexp(v8 + v15, -64))
	end,
	NextNumber = function(state, p: number, p2: number)
		local v = p2 - p
		local x = state.x
		local w = state.w
		local v3 = bxor(x, (lshift(x, 11)))
		local v8 = bxor(bxor(bxor(v3, (rshift(v3, 8))), w), (rshift(w, 19)))
		local y = state.y
		local z = state.z
		state.x = y
		state.y = z
		state.z = w
		state.w = v8
		local v9 = ldexp(v8, 32)
		local x2 = state.x
		local w2 = state.w
		local v11 = bxor(x2, (lshift(x2, 11)))
		local v16 = bxor(bxor(bxor(v11, (rshift(v11, 8))), w2), (rshift(w2, 19)))
		local y2 = state.y
		local z2 = state.z
		state.x = y2
		state.y = z2
		state.z = w2
		state.w = v16
		return p + v * ldexp(v9 + v16, -64)
	end,
	NextInteger = function(self, p: number, p2: number)
		local v = p2 - p + 1
		local x = self.x
		local w = self.w
		local v3 = bxor(x, (lshift(x, 11)))
		local v8 = bxor(bxor(bxor(v3, (rshift(v3, 8))), w), (rshift(w, 19)))
		local y = self.y
		local z = self.z
		self.x = y
		self.y = z
		self.z = w
		self.w = v8
		local v9 = ldexp(v8, 32)
		local x2 = self.x
		local w2 = self.w
		local v11 = bxor(x2, (lshift(x2, 11)))
		local v16 = bxor(bxor(bxor(v11, (rshift(v11, 8))), w2), (rshift(w2, 19)))
		local y2 = self.y
		local z2 = self.z
		self.x = y2
		self.y = z2
		self.z = w2
		self.w = v16
		return (floor(p + v * ldexp(v9 + v16, -64)))
	end,
	NextNormal = function(state, value: number?, value2: number?)
		local x = state.x
		local w = state.w
		local v2 = bxor(x, (lshift(x, 11)))
		local v7 = bxor(bxor(bxor(v2, (rshift(v2, 8))), w), (rshift(w, 19)))
		local y = state.y
		local z = state.z
		state.x = y
		state.y = z
		state.z = w
		state.w = v7
		local v8 = ldexp(v7, 32)
		local x2 = state.x
		local w2 = state.w
		local v10 = bxor(x2, (lshift(x2, 11)))
		local v15 = bxor(bxor(bxor(v10, (rshift(v10, 8))), w2), (rshift(w2, 19)))
		local y2 = state.y
		local z2 = state.z
		state.x = y2
		state.y = z2
		state.z = w2
		state.w = v15
		local v20 = sqrt(log((max(2.2250738585072014e-308, (ldexp(v8 + v15, -64))))) * -2) * (value2 or 0)
		local x3 = state.x
		local w3 = state.w
		local v22 = bxor(x3, (lshift(x3, 11)))
		local v27 = bxor(bxor(bxor(v22, (rshift(v22, 8))), w3), (rshift(w3, 19)))
		local y3 = state.y
		local z3 = state.z
		state.x = y3
		state.y = z3
		state.z = w3
		state.w = v27
		local v28 = ldexp(v27, 32)
		local x4 = state.x
		local w4 = state.w
		local v30 = bxor(x4, (lshift(x4, 11)))
		local v35 = bxor(bxor(bxor(v30, (rshift(v30, 8))), w4), (rshift(w4, 19)))
		local y4 = state.y
		local z4 = state.z
		state.x = y4
		state.y = z4
		state.z = w4
		state.w = v35
		local v37 = 6.283185307179586 * ldexp(v28 + v35, -64)
		local v38 = value or 0
		return cos(v37) * v20 + v38, sin(v37) * v20 + v38
	end,
	NextBoolean = function(state, value: number?)
		local x = state.x
		local w = state.w
		local v2 = bxor(x, (lshift(x, 11)))
		local v7 = bxor(bxor(bxor(v2, (rshift(v2, 8))), w), (rshift(w, 19)))
		local y = state.y
		local z = state.z
		state.x = y
		state.y = z
		state.z = w
		state.w = v7
		local v8 = ldexp(v7, 32)
		local x2 = state.x
		local w2 = state.w
		local v10 = bxor(x2, (lshift(x2, 11)))
		local v15 = bxor(bxor(bxor(v10, (rshift(v10, 8))), w2), (rshift(w2, 19)))
		local y2 = state.y
		local z2 = state.z
		state.x = y2
		state.y = z2
		state.z = w2
		state.w = v15
		return ldexp(v8 + v15, -64) < (value or 0.5)
	end,
	NextVector2 = function(state, value: number?)
		local v = value or 1
		local x = state.x
		local w = state.w
		local v3 = bxor(x, (lshift(x, 11)))
		local v8 = bxor(bxor(bxor(v3, (rshift(v3, 8))), w), (rshift(w, 19)))
		local y = state.y
		local z = state.z
		state.x = y
		state.y = z
		state.z = w
		state.w = v8
		local v9 = ldexp(v8, 32)
		local x2 = state.x
		local w2 = state.w
		local v11 = bxor(x2, (lshift(x2, 11)))
		local v16 = bxor(bxor(bxor(v11, (rshift(v11, 8))), w2), (rshift(w2, 19)))
		local y2 = state.y
		local z2 = state.z
		state.x = y2
		state.y = z2
		state.z = w2
		state.w = v16
		local v18 = 6.283185307179586 * ldexp(v9 + v16, -64)
		return new(cos(v18) * v, sin(v18) * v)
	end,
	NextVector3 = function(state, value: number?)
		local v = value or 1
		local x = state.x
		local w = state.w
		local v3 = bxor(x, (lshift(x, 11)))
		local v8 = bxor(bxor(bxor(v3, (rshift(v3, 8))), w), (rshift(w, 19)))
		local y = state.y
		local z = state.z
		state.x = y
		state.y = z
		state.z = w
		state.w = v8
		local v9 = ldexp(v8, 32)
		local x2 = state.x
		local w2 = state.w
		local v11 = bxor(x2, (lshift(x2, 11)))
		local v16 = bxor(bxor(bxor(v11, (rshift(v11, 8))), w2), (rshift(w2, 19)))
		local y2 = state.y
		local z2 = state.z
		state.x = y2
		state.y = z2
		state.z = w2
		state.w = v16
		local v18 = 6.283185307179586 * ldexp(v9 + v16, -64)
		local x3 = state.x
		local w3 = state.w
		local v20 = bxor(x3, (lshift(x3, 11)))
		local v25 = bxor(bxor(bxor(v20, (rshift(v20, 8))), w3), (rshift(w3, 19)))
		local y3 = state.y
		local z3 = state.z
		state.x = y3
		state.y = z3
		state.z = w3
		state.w = v25
		local v26 = ldexp(v25, 32)
		local x4 = state.x
		local w4 = state.w
		local v28 = bxor(x4, (lshift(x4, 11)))
		local v33 = bxor(bxor(bxor(v28, (rshift(v28, 8))), w4), (rshift(w4, 19)))
		local y4 = state.y
		local z4 = state.z
		state.x = y4
		state.y = z4
		state.z = w4
		state.w = v33
		local v35 = ldexp(v26 + v33, -64) * 2 - 1
		local v37 = sqrt(1 - v35 * v35)
		return (new2(cos(v18) * v37 * v, sin(v18) * v37 * v, v35 * v))
	end,
	NextUUIDv4 = function(state)
		local x = state.x
		local w = state.w
		local v3 = bxor(x, (lshift(x, 11)))
		local v8 = bxor(bxor(bxor(v3, (rshift(v3, 8))), w), (rshift(w, 19)))
		local y = state.y
		local z = state.z
		state.x = y
		state.y = z
		state.z = w
		state.w = v8
		local x2 = state.x
		local w2 = state.w
		local v10 = bxor(x2, (lshift(x2, 11)))
		local v15 = bxor(bxor(bxor(v10, (rshift(v10, 8))), w2), (rshift(w2, 19)))
		local y2 = state.y
		local z2 = state.z
		state.x = y2
		state.y = z2
		state.z = w2
		state.w = v15
		local v17 = bor(band(v15, 4294905855), 16384)
		local x3 = state.x
		local w3 = state.w
		local v19 = bxor(x3, (lshift(x3, 11)))
		local v24 = bxor(bxor(bxor(v19, (rshift(v19, 8))), w3), (rshift(w3, 19)))
		local y3 = state.y
		local z3 = state.z
		state.x = y3
		state.y = z3
		state.z = w3
		state.w = v24
		local v26 = bor(band(v24, 1073741823), 2147483648)
		local x4 = state.x
		local w4 = state.w
		local v28 = bxor(x4, (lshift(x4, 11)))
		local v33 = bxor(bxor(bxor(v28, (rshift(v28, 8))), w4), (rshift(w4, 19)))
		local y4 = state.y
		local z4 = state.z
		state.x = y4
		state.y = z4
		state.z = w4
		state.w = v33
		return format("%08x%08x%08x%08x", v8, v17, v26, v33)
	end,
	Seed = Seed,
	Shuffle = function(state, list)
		assert(type(list) == "table")

		for i = #list, 2, -1 do
			local x = state.x
			local w = state.w
			local v3 = bxor(x, (lshift(x, 11)))
			local v8 = bxor(bxor(bxor(v3, (rshift(v3, 8))), w), (rshift(w, 19)))
			local y = state.y
			local z = state.z
			state.x = y
			state.y = z
			state.z = w
			state.w = v8
			local v9 = ldexp(v8, 32)
			local x2 = state.x
			local w2 = state.w
			local v11 = bxor(x2, (lshift(x2, 11)))
			local v16 = bxor(bxor(bxor(v11, (rshift(v11, 8))), w2), (rshift(w2, 19)))
			local y2 = state.y
			local z2 = state.z
			state.x = y2
			state.y = z2
			state.z = w2
			state.w = v16
			local v17 = v9 + v16
			local v19 = floor((i - 1 + 1) * ldexp(v17, -64) + 1)
			local v20 = list[v19]
			local v21 = list[i]
			list[i] = v20
			list[v19] = v21
		end
	end,
	Clone = function(data)
		return (setmetatable({
			x = data.x,
			y = data.y,
			z = data.z,
			w = data.w
		}, (getmetatable(data))))
	end,
	GetState = function(data)
		return {
			data.x,
			data.y,
			data.z,
			data.w
		}
	end,
	Skip = function(state, value: number)
		AssertInteger(value) -- equivalent call inferred; original call site unknown
		local transformed, v, v2, v3 = Theory.Transform(state.x, state.y, state.z, state.w, value)
		state.x = transformed
		state.y = v
		state.z = v2
		state.w = v3
	end
})
local frozen2 = table.freeze({
	__index = frozen
})
local v = {
	new = function(p)
		local v2 = {
			x = 0,
			y = 0,
			z = 0,
			w = 0
		}
		Seed(v2, p)
		return (setmetatable(v2, frozen2))
	end
}

function v.Unique(value: number?)
	if value ~= nil then
		AssertIntegerNonNegative(value) -- equivalent call inferred; original call site unknown
	end

	local v2 = clamp(value or 4, 0, 4)
	return v.new(GenerateSeed(v2))
end

v.R = v.Unique()
return table.freeze(v)