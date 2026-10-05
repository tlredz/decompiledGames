local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FastFlags = require(ReplicatedStorage.UserGenerated.FastFlags)
local ScrambleRules = require(ReplicatedStorage.Shared.Util.ScrambleRules)
local offers = {
	{
		ProductId = 3713243987,
		EventId = "DrScrambleOutbreak",
		Amount = 100,
		Label = "Sample Pack 1"
	},
	{
		ProductId = 3713244009,
		EventId = "DrScrambleOutbreak",
		Amount = 500,
		Label = "Sample Pack 2"
	},
	{
		ProductId = 3713244032,
		EventId = "DrScrambleOutbreak",
		Amount = 1500,
		Label = "Sample Pack 3"
	},
	{
		ProductId = 3714309175,
		EventId = "DrScrambleOutbreak",
		Amount = 3000,
		Label = "Sample Pack 4"
	}
}

local function validateCatalog(list)
	local v2

	if type(list) == "table" then
		v2 = #list <= 32
	else
		v2 = false
	end

	assert(v2, "Scramble: invalid pack catalog")
	local v3 = {}

	for _, v4 in list do
		assert(type(v4) == "table", "Scramble: invalid Sample pack")
		assert(
			ScrambleRules.Integer(v4.ProductId, 1, 9000000000000) and not v3[v4.ProductId],
			"Scramble: invalid product ID"
		)
		assert(ScrambleRules.Integer(v4.Amount, 1, ScrambleRules.MAX_SAMPLES), "Scramble: invalid Sample pack amount")
		local v5

		if type(v4.EventId) == "string" and #v4.EventId > 0 then
			v5 = #v4.EventId <= 64
		else
			v5 = false
		end

		assert(v5, "Scramble: invalid pack event")
		local v6

		if type(v4.Label) == "string" then
			v6 = #v4.Label <= 80
		else
			v6 = false
		end

		assert(v6, "Scramble: invalid pack label")
		v3[v4.ProductId] = true
	end

	return list
end

local replicated = FastFlags.Replicated("Game.Scramble.SamplePacks", validateCatalog, offers)
local v2 = {
	Offers = offers,
	Get = function()
		local result = {}
		local v3 = {}

		for _, v4 in replicated:Get() do
			table.insert(result, v4)
			v3[v4.ProductId] = true
		end

		for _, v4 in offers do
			if not v3[v4.ProductId] then
				table.insert(result, v4)
			end
		end

		return result
	end
}

function v2.Find(p: number)
	for _, v3 in v2.Get() do
		if v3.ProductId == p then
			return v3
		end
	end

	return nil
end

function v2.getChangedSignal()
	return replicated.Changed
end

return table.freeze(v2)