local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.UserGenerated.Randoms.Base)
local GenerateSeed = require(ReplicatedStorage.UserGenerated.IO.Crypto.GenerateSeed)
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
local create = table.create
local clone = table.clone
local format = string.format
local new = Vector2.new
local new2 = Vector3.new
assert(true)
local random = Random.new()

local function IsInteger(value: number)
	return type(value) == "number" and floor(value) == value and value ~= 1e999 and value ~= -1e999
end

-- equivalent calls inferred from this helper; original call sites unknown
local function AssertIntegerNonNegative(value: number)
	local v

	if type(value) == "number" and floor(value) == value and value ~= 1e999 then
		v = value ~= -1e999
	else
		v = false
	end

	if not v then
		error("Integer", 2)
	end

	if not (value >= 0) then
		error("NonNegative", 2)
	end
end

local function IsaacMix(list)
	local v = list[1]
	local v2 = list[2]
	local v3 = list[3]
	local v4 = list[4]
	local v5 = list[5]
	local v6 = list[6]
	local v7 = list[7]
	local v8 = list[8]
	local v10 = bxor(v, (lshift(v2, 11)))
	local v12 = bor(v4 + v10, 0)
	local v16 = bxor(bor(v2 + v3, 0), (rshift(v3, 2)))
	local v18 = bor(v5 + v16, 0)
	local v22 = bxor(bor(v3 + v12, 0), (lshift(v12, 8)))
	local v24 = bor(v6 + v22, 0)
	local v28 = bxor(bor(v12 + v18, 0), (rshift(v18, 16)))
	local v30 = bor(v7 + v28, 0)
	local v34 = bxor(bor(v18 + v24, 0), (lshift(v24, 10)))
	local v36 = bor(v8 + v34, 0)
	local v40 = bxor(bor(v24 + v30, 0), (rshift(v30, 4)))
	local v42 = bor(v10 + v40, 0)
	local v46 = bxor(bor(v30 + v36, 0), (lshift(v36, 8)))
	local v48 = bor(v16 + v46, 0)
	local v52 = bxor(bor(v36 + v42, 0), (rshift(v42, 9)))
	local v54 = bor(v22 + v52, 0)
	list[1] = bor(v42 + v48, 0)
	list[2] = v48
	list[3] = v54
	list[4] = v28
	list[5] = v34
	list[6] = v40
	list[7] = v46
	list[8] = v52
end

local function Isaac(state)
	local AA = state.AA
	local BB = state.BB
	local CC = state.CC
	local MM = state.MM
	local RSL = state.RSL
	local CC2 = bor(CC + 1, 0)
	local BB2 = bor(BB + CC2, 0)

	for i = 1, 256 do
		local v5 = MM[i]
		local v6 = band(i, 3)

		if v6 == 0 then
			AA = bxor(AA, (rshift(AA, 16)))
		elseif v6 == 1 then
			AA = bxor(AA, (lshift(AA, 13)))
		elseif v6 == 2 then
			AA = bxor(AA, (rshift(AA, 6)))
		elseif v6 == 3 then
			AA = bxor(AA, (lshift(AA, 2)))
		end

		AA = bor(MM[band(i + 127, 255) + 1] + AA, 0)
		local v11 = bor(MM[band(rshift(v5, 2), 255) + 1] + AA + BB2, 0)
		MM[i] = v11
		BB2 = bor(MM[band(rshift(v11, 10), 255) + 1] + v5, 0)
		RSL[i] = BB2
	end

	state.AA = AA
	state.BB = BB2
	state.CC = CC2
end

local function IsaacInit(state, flag: boolean)
	state.AA = 0
	state.BB = 0
	state.CC = 0
	state.Count = 256
	local MM = state.MM
	local RSL = state.RSL
	local v = create(8, 2654435769)
	IsaacMix(v)
	IsaacMix(v)
	IsaacMix(v)
	IsaacMix(v)

	for i = 0, 255, 8 do
		if flag then
			for i2 = 1, 8 do
				v[i2] = bor(v[i2] + RSL[i + i2], 0)
			end
		end

		IsaacMix(v)
		MM[i + 1] = v[1]
		MM[i + 2] = v[2]
		MM[i + 3] = v[3]
		MM[i + 4] = v[4]
		MM[i + 5] = v[5]
		MM[i + 6] = v[6]
		MM[i + 7] = v[7]
		MM[i + 8] = v[8]
	end

	if flag then
		for i = 0, 255, 8 do
			for i2 = 1, 8 do
				v[i2] = bor(v[i2] + MM[i + i2], 0)
			end

			IsaacMix(v)
			MM[i + 1] = v[1]
			MM[i + 2] = v[2]
			MM[i + 3] = v[3]
			MM[i + 4] = v[4]
			MM[i + 5] = v[5]
			MM[i + 6] = v[6]
			MM[i + 7] = v[7]
			MM[i + 8] = v[8]
		end
	end
end

local function Seed(p, value, flag: boolean?)
	if value == nil then
		value = { random:NextInteger(0, 4294967295) }
	elseif type(value) == "number" then
		value = { value }
	else
		assert(type(value) == "table")
	end

	if flag == nil then
		flag = true
	else
		assert(type(flag) == "boolean")
	end

	local v = math.min(256, #value)
	local MM = p.MM
	local RSL = p.RSL

	for i = 1, 256 do
		MM[i] = 0
		RSL[i] = 0
	end

	for i = 1, v do
		RSL[i] = bor(value[i], 0)
	end

	IsaacInit(p, flag)
end

local frozen = table.freeze({
	NextU32 = function(state)
		local count = state.Count + 1

		if count > 256 then
			Isaac(state)
			count = 1
		end

		state.Count = count
		return state.RSL[count]
	end,
	NextU64 = function(state)
		local count = state.Count + 1

		if count > 256 then
			Isaac(state)
			count = 1
		end

		state.Count = count
		local v3 = ldexp(state.RSL[count], 32)
		local count2 = state.Count + 1

		if count2 > 256 then
			Isaac(state)
			count2 = 1
		end

		state.Count = count2
		return v3 + state.RSL[count2]
	end,
	NextFloat = function(state)
		local count = state.Count + 1

		if count > 256 then
			Isaac(state)
			count = 1
		end

		state.Count = count
		return (ldexp(state.RSL[count], -32))
	end,
	NextDouble = function(state)
		local count = state.Count + 1

		if count > 256 then
			Isaac(state)
			count = 1
		end

		state.Count = count
		local v3 = ldexp(state.RSL[count], 32)
		local count2 = state.Count + 1

		if count2 > 256 then
			Isaac(state)
			count2 = 1
		end

		state.Count = count2
		return (ldexp(v3 + state.RSL[count2], -64))
	end,
	NextNumber = function(state, p: number, p2: number)
		local v = p2 - p
		local count = state.Count + 1

		if count > 256 then
			Isaac(state)
			count = 1
		end

		state.Count = count
		local v4 = ldexp(state.RSL[count], 32)
		local count2 = state.Count + 1

		if count2 > 256 then
			Isaac(state)
			count2 = 1
		end

		state.Count = count2
		return p + v * ldexp(v4 + state.RSL[count2], -64)
	end,
	NextInteger = function(self, p: number, p2: number)
		local v = p2 - p + 1
		local count = self.Count + 1

		if count > 256 then
			Isaac(self)
			count = 1
		end

		self.Count = count
		local v4 = ldexp(self.RSL[count], 32)
		local count2 = self.Count + 1

		if count2 > 256 then
			Isaac(self)
			count2 = 1
		end

		self.Count = count2
		return (floor(p + v * ldexp(v4 + self.RSL[count2], -64)))
	end,
	NextNormal = function(state, value: number?, value2: number?)
		local count = state.Count + 1

		if count > 256 then
			Isaac(state)
			count = 1
		end

		state.Count = count
		local v4 = ldexp(state.RSL[count], 32)
		local count2 = state.Count + 1

		if count2 > 256 then
			Isaac(state)
			count2 = 1
		end

		state.Count = count2
		local v10 = sqrt(log((max(2.2250738585072014e-308, (ldexp(v4 + state.RSL[count2], -64))))) * -2) * (value2 or 0)
		local count3 = state.Count + 1

		if count3 > 256 then
			Isaac(state)
			count3 = 1
		end

		state.Count = count3
		local v14 = ldexp(state.RSL[count3], 32)
		local count4 = state.Count + 1

		if count4 > 256 then
			Isaac(state)
			count4 = 1
		end

		state.Count = count4
		local v17 = 6.283185307179586 * ldexp(v14 + state.RSL[count4], -64)
		local v18 = value or 0
		return cos(v17) * v10 + v18, sin(v17) * v10 + v18
	end,
	NextBoolean = function(state, value: number?)
		local count = state.Count + 1

		if count > 256 then
			Isaac(state)
			count = 1
		end

		state.Count = count
		local v3 = ldexp(state.RSL[count], 32)
		local count2 = state.Count + 1

		if count2 > 256 then
			Isaac(state)
			count2 = 1
		end

		state.Count = count2
		return ldexp(v3 + state.RSL[count2], -64) < (value or 0.5)
	end,
	NextVector2 = function(state, value: number?)
		local v = value or 1
		local count = state.Count + 1

		if count > 256 then
			Isaac(state)
			count = 1
		end

		state.Count = count
		local v5 = ldexp(state.RSL[count], 32)
		local count2 = state.Count + 1

		if count2 > 256 then
			Isaac(state)
			count2 = 1
		end

		state.Count = count2
		local v8 = 6.283185307179586 * ldexp(v5 + state.RSL[count2], -64)
		return new(cos(v8) * v, sin(v8) * v)
	end,
	NextVector3 = function(state, value: number?)
		local v = value or 1
		local count = state.Count + 1

		if count > 256 then
			Isaac(state)
			count = 1
		end

		state.Count = count
		local v5 = ldexp(state.RSL[count], 32)
		local count2 = state.Count + 1

		if count2 > 256 then
			Isaac(state)
			count2 = 1
		end

		state.Count = count2
		local v8 = 6.283185307179586 * ldexp(v5 + state.RSL[count2], -64)
		local count3 = state.Count + 1

		if count3 > 256 then
			Isaac(state)
			count3 = 1
		end

		state.Count = count3
		local v11 = ldexp(state.RSL[count3], 32)
		local count4 = state.Count + 1

		if count4 > 256 then
			Isaac(state)
			count4 = 1
		end

		state.Count = count4
		local v14 = ldexp(v11 + state.RSL[count4], -64) * 2 - 1
		local v16 = sqrt(1 - v14 * v14)
		return (new2(cos(v8) * v16 * v, sin(v8) * v16 * v, v14 * v))
	end,
	NextUUIDv4 = function(state)
		local count = state.Count + 1

		if count > 256 then
			Isaac(state)
			count = 1
		end

		state.Count = count
		local v4 = state.RSL[count]
		local count2 = state.Count + 1

		if count2 > 256 then
			Isaac(state)
			count2 = 1
		end

		state.Count = count2
		local v8 = bor(band(state.RSL[count2], 4294905855), 16384)
		local count3 = state.Count + 1

		if count3 > 256 then
			Isaac(state)
			count3 = 1
		end

		state.Count = count3
		local v12 = bor(band(state.RSL[count3], 1073741823), 2147483648)
		local count4 = state.Count + 1

		if count4 > 256 then
			Isaac(state)
			count4 = 1
		end

		state.Count = count4
		return format("%08x%08x%08x%08x", v4, v8, v12, state.RSL[count4])
	end,
	Seed = Seed,
	Shuffle = function(state, list)
		assert(type(list) == "table")

		for i = #list, 2, -1 do
			local count = state.Count + 1

			if count > 256 then
				Isaac(state)
				count = 1
			end

			state.Count = count
			local v4 = ldexp(state.RSL[count], 32)
			local count2 = state.Count + 1

			if count2 > 256 then
				Isaac(state)
				count2 = 1
			end

			state.Count = count2
			local v6 = v4 + state.RSL[count2]
			local v8 = floor((i - 1 + 1) * ldexp(v6, -64) + 1)
			local v9 = list[v8]
			local v10 = list[i]
			list[i] = v9
			list[v8] = v10
		end
	end,
	Clone = function(data)
		return (setmetatable({
			RSL = clone(data.RSL),
			Count = data.Count,
			MM = clone(data.MM),
			AA = data.AA,
			BB = data.BB,
			CC = data.CC
		}, (getmetatable(data))))
	end
})
local frozen2 = table.freeze({
	__index = frozen
})
local v = {
	new = function(p, flag: boolean?)
		local v2 = {
			RSL = create(256, 0),
			Count = 0,
			MM = create(256, 0),
			AA = 0,
			BB = 0,
			CC = 0
		}
		Seed(v2, p, flag)
		return (setmetatable(v2, frozen2))
	end
}

function v.Unique(value: number?)
	if value ~= nil then
		AssertIntegerNonNegative(value) -- equivalent call inferred; original call site unknown
	end

	local v2 = clamp(value or 32, 0, 256)
	return v.new(GenerateSeed(v2), true)
end

v.R = v.Unique()
return table.freeze(v)