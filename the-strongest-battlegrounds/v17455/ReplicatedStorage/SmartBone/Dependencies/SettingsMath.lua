local function Clamp(min, max)
	return function(value)
		return (math.clamp(value, min, max))
	end
end

local function Floor(p)
	return (math.floor(p))
end

local function Offset(p)
	return function(p2)
		return p2 + p
	end
end

local v = 0
local v2 = 1
local SettingsMath = {
	Damping = function(value)
		return (math.clamp(value, v, v2))
	end,
	AnchorDepth = Floor,
	Stiffness = 0,
	Inertia = 0,
	Elasticity = 0,
	BlendWeight = 0,
	UpdateRate = 0,
	WindStrength = 0,
	Gravity = 0
}
local v3 = 0
local v4 = 1

function SettingsMath.Stiffness(value)
	return (math.clamp(value, v3, v4))
end

local v5 = 0
local v6 = 1

function SettingsMath.Inertia(value)
	return (math.clamp(value, v5, v6))
end

local v7 = 0
local v8 = 1

function SettingsMath.Elasticity(value)
	return (math.clamp(value, v7, v8))
end

local v9 = 0
local v10 = 1

function SettingsMath.BlendWeight(value)
	return (math.clamp(value, v9, v10))
end

local v11 = 0
local v12 = 165

function SettingsMath.UpdateRate(value)
	return (math.clamp(value, v11, v12))
end

local v13 = 0
local v14 = 10

function SettingsMath.WindStrength(value)
	return (math.clamp(value, v13, v14))
end

local v15 = vector.create(0, -0.01, 0)

function SettingsMath.Gravity(p)
	return p + v15
end

return SettingsMath