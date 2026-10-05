local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local t = require(ReplicatedStorage.Packages.t)
local strict = t.strict(t.string)
local strict2 = t.strict(t.optional(t.intersection(t.numberMin(1), t.numberMaxExclusive(1e999))))
local v = {
	SPEED = "Speed",
	EARNINGS = "Earnings",
	EGG_SIZE = "EggSize",
	EGG_SPAWN_LUCK = "EggSpawnLuck",
	MUTATION_LUCK = "MutationLuck",
	TREADMILL = "Treadmill"
}
local v2 = {}

for _, v3 in v do
	v2[v3] = true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function attributeFor(p: string)
	strict(p)
	assert(v2[p], (`there is no admin boost named "{p}"`))
	return "AdminBoost_" .. p
end

function v.ReadMultiplier(p: string)
	local attribute = Workspace:GetAttribute(attributeFor(p))

	if type(attribute) == "number" and attribute == attribute then
		return (math.max(attribute, 1))
	end

	return 1
end

function v.Observe(p: string)
	return Workspace:GetAttributeChangedSignal(attributeFor(p))
end

function v.Assign(p: string, p2: number?)
	assert(RunService:IsServer(), "admin boosts can only be assigned on the server")
	strict2(p2)
	local v3 = attributeFor(p) -- equivalent call inferred; original call site unknown

	if p2 == nil or p2 <= 1 then
		Workspace:SetAttribute(v3, nil)
	else
		Workspace:SetAttribute(v3, p2)
	end
end

return table.freeze(v)