local RunService = game:GetService("RunService")
local random = Random.new(os.clock() * 100)
local jobId = game.JobId

if RunService:IsStudio() and (game.JobId == "00000000-0000-0000-0000-000000000000" or game.JobId == "") then
	if RunService:IsServer() then
		jobId = tostring(math.random(-2147483647, 2147483647))
		script:SetAttribute("StudioSeedThing", jobId)
	else
		if not script:GetAttribute("StudioSeedThing") then
			script:GetAttributeChangedSignal("StudioSeedThing"):Wait()
		end

		jobId = script:GetAttribute("StudioSeedThing")
	end
end

local RngUtil = {}

function RngUtil.FromChanceInt(p)
	return RngUtil.FromChanceFloat(p / 100)
end

function RngUtil.FromChanceFloat(p)
	return random:NextNumber(0, 1) <= p
end

function RngUtil.RandomSign()
	if random:NextInteger(1, 2) == 1 then
		return -1
	end

	return 1
end

function RngUtil.PointInCircleVector2(p)
	local vector

	repeat
		vector = Vector2.new(random:NextNumber(-p, p), random:NextNumber(-p, p))
	until vector.Magnitude < p

	return vector
end

function RngUtil.PointInPart(instance, value: number?)
	local v = instance.Size / 2 * (value or 1)
	return instance.CFrame * Vector3.new(
		random:NextNumber(-v.X, v.X),
		random:NextNumber(-v.Y, v.Y),
		random:NextNumber(-v.Z, v.Z)
	)
end

function RngUtil.PointInCircleVector3(p)
	local vector

	repeat
		vector = Vector3.new(random:NextNumber(-p, p), 0, random:NextNumber(-p, p))
	until vector.Magnitude < p

	return vector
end

function RngUtil.UnitVector2()
	local unitVector = random:NextUnitVector()
	return Vector2.new(unitVector.X, unitVector.Y).Unit
end

function RngUtil.UnitVector3()
	return random:NextUnitVector()
end

local function GetWeight(p, p2)
	if p2 then
		return p[p2]
	end

	return p
end

function RngUtil.RandomArrayValue(list)
	return list[random:NextInteger(1, #list)]
end

function RngUtil.RandomChild(instance)
	return RngUtil.RandomArrayValue(instance:GetChildren())
end

function RngUtil.SelectRandom(items, p: string?)
	local v = 0

	for _, item in items do
		if p then
			item = item[p]
		end

		v += item
	end

	local number = random:NextNumber(0, v)

	for k, item in items do
		if p then
			item = item[p]
		end

		v -= item

		if v < number then
			return k
		end
	end

	error("Invalid table to select from")
end

function RngUtil.SumWeight(items, p: string?)
	local total = 0

	for _, item in items do
		if p then
			item = item[p]
		end

		total += item
	end

	return total
end

function RngUtil.GetChance(p, p2, p3: string?)
	local v = p2[p]

	if not v then
		return 0
	end

	if p3 then
		v = v[p3]
	end

	return v / RngUtil.SumWeight(p2, p3) * 100
end

function RngUtil.SimpleHash(value: string)
	local v = 0

	for i = 1, #value do
		local v2 = string.byte(value, i)
		v = (v * 31 + v2) % 2147483647
	end

	return v
end

function RngUtil.DeterministicRandom(value: string, value2)
	if type(value) ~= "string" then
		error("First parameter must be a string")
	end

	if type(value2) ~= "number" or value2 < 1 or value2 ~= math.floor(value2) then
		error("Second parameter must be a positive integer")
	end

	return RngUtil.SimpleHash(value) % value2 + 1
end

function RngUtil.StringSeedRandom(value: string)
	if type(value) ~= "string" then
		error("First parameter must be a string")
	end

	local simpleHash = RngUtil.SimpleHash(value)
	return Random.new(simpleHash)
end

function RngUtil.ServerSharedRandom(p: string)
	return RngUtil.StringSeedRandom(p .. jobId)
end

return RngUtil