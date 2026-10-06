local v = {
	{
		Tier = "Common",
		Weight = 50
	},
	{
		Tier = "Uncommon",
		Weight = 25
	},
	{
		Tier = "Rare",
		Weight = 15
	},
	{
		Tier = "Epic",
		Weight = 9
	},
	{
		Tier = "Legendary",
		Weight = 1
	},
	{
		Tier = "Mythical",
		Weight = 0.1
	}
}
local total = 0

for _, v2 in ipairs(v) do
	total += v2.Weight
end

local function GetRandomTier()
	local v2 = math.random() * total
	local total2 = 0

	for _, v3 in ipairs(v) do
		total2 += v3.Weight

		if v2 <= total2 then
			return v3.Tier
		end
	end

	return v[#v].Tier
end

return GetRandomTier