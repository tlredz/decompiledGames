local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Asserts = require(ReplicatedStorage.UserGenerated.Lang.Asserts)
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)

local function bounded(p: number, p2: number)
	return function(p3)
		Asserts.FiniteNonNegative(p3)
		local v

		if p <= p3 then
			v = p3 <= p2
		else
			v = false
		end

		assert(v, "Shrine fusion flag out of range")
		return p3
	end
end

local v = {
	Enabled = FastFlags.Replicated("Game.ShrineFusion.Enabled", Asserts.Boolean, true),
	Recipes = FastFlags.Replicated(
		"Game.ShrineFusion.Recipes",
		Asserts.Map(Asserts.String, Asserts.Map(Asserts.String, Asserts.String)),
		{
			Divine = {
				Light = "ArchAngel",
				Dark = "World Burner",
				Fused = "Aetheron"
			},
			Eternal = {
				Light = "Pegasus",
				Dark = "Skeleton Horse",
				Fused = "Equinox"
			}
		}
	),
	RitualSeconds = 0,
	RetrySeconds = 0,
	EggInventoryLimit = 0,
	AllowStolenDNA = 0,
	PreserveMutations = 0,
	PreservePersonality = 0,
	PreserveInputScale = 0,
	RewardNeverEarnsLess = 0,
	FixedRewardScale = 0,
	RewardScaleMultiplier = 0
}
local v2 = 1
local v3 = 60
v.RitualSeconds = FastFlags.Replicated("Game.ShrineFusion.RitualSeconds", function(p)
	Asserts.FiniteNonNegative(p)
	local v4

	if v2 <= p then
		v4 = p <= v3
	else
		v4 = false
	end

	assert(v4, "Shrine fusion flag out of range")
	return p
end, 5)
local v4 = 1
local v5 = 120
v.RetrySeconds = FastFlags.Replicated("Game.ShrineFusion.RetrySeconds", function(p)
	Asserts.FiniteNonNegative(p)
	local v6

	if v4 <= p then
		v6 = p <= v5
	else
		v6 = false
	end

	assert(v6, "Shrine fusion flag out of range")
	return p
end, 5)
v.EggInventoryLimit = FastFlags.Replicated("Game.ShrineFusion.EggInventoryLimit", Asserts.IntegerPositive, 115)
v.AllowStolenDNA = FastFlags.Replicated("Game.ShrineFusion.AllowStolenDNA", Asserts.Boolean, false)
v.PreserveMutations = FastFlags.Replicated("Game.ShrineFusion.PreserveMutations", Asserts.Boolean, true)
v.PreservePersonality = FastFlags.Replicated("Game.ShrineFusion.PreservePersonality", Asserts.Boolean, true)
v.PreserveInputScale = FastFlags.Replicated("Game.ShrineFusion.PreserveInputScale", Asserts.Boolean, true)
v.RewardNeverEarnsLess = FastFlags.Replicated("Game.ShrineFusion.RewardNeverEarnsLess", Asserts.Boolean, true)
local v6 = 0.01
local v7 = 100
v.FixedRewardScale = FastFlags.Replicated("Game.ShrineFusion.FixedRewardScale", Asserts.Map(Asserts.String, function(p)
	Asserts.FiniteNonNegative(p)
	local v8

	if v6 <= p then
		v8 = p <= v7
	else
		v8 = false
	end

	assert(v8, "Shrine fusion flag out of range")
	return p
end), {
	Divine = 1,
	Eternal = 1
})
local v8 = 0.01
local v9 = 100
v.RewardScaleMultiplier = FastFlags.Replicated(
	"Game.ShrineFusion.RewardScaleMultiplier",
	Asserts.Map(Asserts.String, function(p)
		Asserts.FiniteNonNegative(p)
		local v10

		if v8 <= p then
			v10 = p <= v9
		else
			v10 = false
		end

		assert(v10, "Shrine fusion flag out of range")
		return p
	end),
	{
		Divine = 1,
		Eternal = 1
	}
)
return table.freeze(v)