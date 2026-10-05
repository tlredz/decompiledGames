local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Character_info_provider = require(ReplicatedStorage.CAM.Global.Character_info_provider)
local Items = require(ReplicatedStorage.CAM.Global.Collectibles.Items)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Series = {
	MaxTier = 3,
	VfxTier = 2,
	TierMultiplier = { 1, 1.15, 1.3 },
	PassiveTier = 3,
	Passives = {
		Firstlight = {
			Name = "Daybreak Guard",
			Description = "Blocking a hit heals you and bites the attacker, at most once every 1.5 seconds."
		},
		Nightfall = {
			Name = "Nightfall Bleed",
			Description = "Every strike opens a bleed that stacks up to three times and fades once you let up."
		}
	},
	OutfitPassives = {
		Firstlight = {
			Name = "First Light",
			Description = "With the Firstlight Top and Bottom worn: when a hit drops you to low health, you heal and take less damage for a few seconds. Recharges slowly."
		},
		Nightfall = {
			Name = "Nightfall Hunt",
			Description = "With the Nightfall Top and Bottom worn: your strikes hit harder against enemies at low health."
		}
	},
	SetOf = function(p: string)
		local item = Items[p]

		if item == nil then
			return nil
		end

		return item.Series
	end,
	Materials = function()
		local result = {}

		for k, item in Items do
			if item.SetMaterial ~= nil then
				table.insert(result, k)
			end
		end

		table.sort(result)
		return result
	end,
	Capstones = function(p: string)
		local result = {}

		for k, item in Items do
			if item.Series == p and item.SeriesCapstone == true then
				table.insert(result, k)
			end
		end

		return result
	end,
	CapstoneGate = function(p: string)
		local result = {}

		for k, item in Items do
			if item.Series == p and item.SeriesCapstone ~= true and item.SeriesFished ~= true then
				table.insert(result, k .. " Schematic")
			end
		end

		return result
	end
}

function Series.TierOf(instance)
	local tier

	if instance ~= nil then
		tier = instance:FindFirstChild("Tier")
	end

	if tier == nil then
		return 1
	end

	return (math.clamp(tier.Value, 1, Series.MaxTier))
end

function Series.Multiplier(p)
	return Series.TierMultiplier[Series.TierOf(p)]
end

function Series.WornEntry(p, p2: string)
	local data = Utility.GetData(p)
	local stats

	if data ~= nil then
		stats = data.Inventory.Accessories:FindFirstChild("Stats")
	end

	if stats == nil then
		return nil
	end

	local v = nil

	for _, child in stats:GetChildren() do
		if child.Value == 0 then
			continue
		end

		local item = Character_info_provider.GetItemFromId(p, child.Value)

		if not (item ~= nil and item.Name == p2 and (v == nil or Series.TierOf(item) > Series.TierOf(v))) then
			continue
		end

		v = item
	end

	return v
end

return Series