local SoftPity = require(script.Parent.SoftPity)
local Gacha = require(script.Parent.Gacha)
local Probability = require(script.Parent.Parent.Utils.Probability)
local module = require("@game/ReplicatedStorage/Omni/Utils/Number")
local v = {
	List = {}
}

function v.Register(p: string, p2)
	p2.Price.Amount = module:Unformat(p2.Price.Amount)
	v.List[p] = p2
end

function v.GetRarityMultipliers(p)
	local PlayerStats = require(script.Parent.Parent.Utils.PlayerStats)
	return {
		Mythical = PlayerStats.RarityChance(p, nil, "Mythical"),
		Secret = PlayerStats.RarityChance(p, nil, "Secret")
	}
end

function v.GetPreview(data, p: number, p2, p3, p4, p5)
	local pityPreview, v2 = Gacha.GetPityPreview(data.Pity, p2)

	if not pityPreview then
		return nil, v2
	end

	local preview, v3 = SoftPity.GetPreview(data.SoftPity, p3)

	if not preview then
		return nil, v3
	end

	local chances, v4 = Probability.GetChances(data.List, p, true)

	if not chances then
		return nil, v4
	end

	local groups = {}

	for k, v6 in data.List do
		groups[v6.Name] = k
	end

	if p4 then
		local v6 = p5 or v.GetRarityMultipliers(p4)
		local total = 0

		for k, chance in chances do
			local v7 = groups[k]

			if v6[v7] then
				chance.Chance *= v6[v7]
			end

			total += chance.Chance
		end

		for _, chance in chances do
			chance.Chance = chance.Chance / total * 100
		end
	end

	if not pityPreview.Result then
		chances = SoftPity.Apply(chances, groups, preview)
		return {
			Chances = chances,
			Groups = groups,
			Pity = pityPreview,
			SoftPity = preview
		}
	end

	local v6 = data.List[pityPreview.Result]

	if not v6 or v6.Chance <= 0 then
		return nil, "The Star pity target is unavailable."
	end

	for k, chance in chances do
		chance.Chance = k == v6.Name and 100 or 0
	end

	return {
		Chances = chances,
		Groups = groups,
		Pity = pityPreview,
		SoftPity = preview
	}
end

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	if v[moduleScript.Name] then
		warn((`Repeated Star Module: {moduleScript.Name}!`))
	else
		local module2 = require(moduleScript)

		if module2 then
			v.Register(moduleScript.Name, module2)
		end
	end
end

return table.freeze(v)