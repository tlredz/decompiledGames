local createVector = vector.create
local rad = math.rad
local sin = math.sin
local cos = math.cos
local random = Random.new()
local speeds = {}
local intensities = {}
local rotationMultipliers = {}
local v = {}
local v2 = {}
local C0s = {}
local instances = {}
local v3 = {}
local v4 = {}
local count = 0

local function newEntity()
	count += 1
	return count
end

local Sway = {}

function Sway.Create(instance, options)
	local v5 = options or {}
	count += 1
	local v6 = count
	speeds[v6] = v5.Speed or 1
	intensities[v6] = v5.Intensity or createVector(1, 1, 1)
	rotationMultipliers[v6] = v5.RotationMultiplier or 1
	v[v6] = random:NextNumber(0, 6.283185307179586)
	v2[v6] = random:NextNumber(0, 6.283185307179586)
	local v7 = instance:IsA("Motor6D") or instance:IsA("Weld")
	instances[v6] = instance
	C0s[v6] = v7 and instance.C0 or instance.CFrame
	v3[v6] = v7
	v4[v6] = true
	return v6
end

function Sway.Step(p: number)
	for k in v4 do
		local v5 = v[k] + p * speeds[k]
		v[k] = v5
		local v6 = sin(v5)
		local v7 = cos(v5)
		local v9 = sin(v5 + v2[k])
		local v10 = rotationMultipliers[k]
		local v11 = intensities[k]
		local v18 = C0s[k] * CFrame.Angles(rad(v6 * v10), rad(v9 * v10), (rad(v7 * v10))) + vector.create(
			v6 * v11.x,
			v9 * v11.y,
			v7 * v11.z
		)

		if v3[k] then
			instances[k].C0 = v18
		else
			instances[k].CFrame = v18
		end
	end
end

return Sway