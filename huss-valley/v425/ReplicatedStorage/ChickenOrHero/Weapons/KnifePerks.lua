local FantasySkinCatalog = require(script.Parent.FantasySkinCatalog)
local v = {}
local frozen = table.freeze({
	Key = "None",
	SpeedBonus = 0,
	CooldownReduction = 0
})
local v2 = {
	Epic = table.freeze({
		Key = "Epic",
		SpeedBonus = 0.35,
		CooldownReduction = 0.35
	}),
	Legendary = table.freeze({
		Key = "Legendary",
		SpeedBonus = 0.85,
		CooldownReduction = 0.85
	})
}

function v.forSkin(value)
	local v3

	if type(value) == "string" then
		v3 = FantasySkinCatalog.Skins[value]
	else
		v3 = false
	end

	return v3 and v2[v3.Rarity] or frozen
end

function v.get(instance)
	return v.forSkin(instance and instance:GetAttribute("EquippedKnife"))
end

function v.cooldown(p, p2)
	return (math.max(0, p - v.get(p2).CooldownReduction))
end

return table.freeze(v)