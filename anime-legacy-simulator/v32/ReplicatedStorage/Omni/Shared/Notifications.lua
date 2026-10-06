local v = {
	DropTime = 5,
	MaximumDrops = 8,
	MaximumPendingDrops = 32,
	ResumedDropMinimumTime = 2,
	MaximumTexts = 5,
	AdminTime = 10,
	MaximumPendingAdmins = 20,
	MaximumMessageLength = 200,
	AnnouncementCooldown = 5,
	AnnouncementLifetime = 120,
	MaximumSeenAnnouncements = 512,
	Colors = {
		White = Color3.new(1, 1, 1),
		Blue = Color3.new(0, 0, 1),
		Red = Color3.new(1, 0, 0),
		Green = Color3.new(0, 1, 0),
		Yellow = Color3.new(1, 1, 0),
		Purple = Color3.new(0.5, 0, 1),
		Orange = Color3.new(1, 0.5, 0),
		Pink = Color3.new(1, 0.5, 1),
		Brown = Color3.new(0.5, 0.25, 0),
		Gray = Color3.new(0.5, 0.5, 0.5),
		Black = Color3.new(0, 0, 0)
	},
	Types = {
		Currency = "Currency",
		Currencies = "Currency",
		Item = "Item",
		Items = "Item",
		Fighter = "Fighter",
		Fighters = "Fighter",
		Weapon = "Weapon",
		Weapons = "Weapon",
		Accessory = "Accessory",
		Accessories = "Accessory",
		Mount = "Mount",
		Mounts = "Mount",
		SacredArtefact = "SacredArtefact",
		SacredArtefacts = "SacredArtefact",
		Gacha = "Gacha",
		Trait = "Trait",
		Traits = "Trait",
		Breathing = "Breathing",
		Breathings = "Breathing"
	},
	IsFinite = function(value)
		return typeof(value) == "number" and math.isfinite(value)
	end,
	Escape = function(value: string)
		return (value:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
	end
}

function v.NormalizeDrop(data)
	if typeof(data) ~= "table" or (typeof(data.Type) ~= "string" or typeof(data.Name) ~= "string") then
		return
	end

	if #data.Name == 0 or #data.Name > 200 or (not v.IsFinite(data.Amount) or data.Amount <= 0) then
		return
	end

	local type = v.Types[data.Type]

	if not type or type == "Gacha" and (typeof(data.GachaName) ~= "string" or #data.GachaName == 0 or #data.GachaName > 200) then
		return
	end

	local v2 = {
		Type = type,
		Name = data.Name,
		Amount = data.Amount,
		Shiny = data.Shiny == true,
		Time = v.IsFinite(data.Time) and math.clamp(data.Time, 1, 30) or v.DropTime
	}

	if typeof(data.Rarity) == "string" then
		v2.Rarity = data.Rarity
	end

	if type == "Gacha" then
		v2.GachaName = data.GachaName
	end

	if type == "Fighter" and (data.Status == "Sold" or data.Status == "Deconstructed" or data.Status == "Deleted") then
		v2.Status = data.Status
	end

	if v.IsFinite(data.Chance) and data.Chance >= 0 and data.Chance <= 100 then
		v2.Chance = data.Chance
	end

	return v2
end

function v.DropIdentifier(data)
	local gachaName = data.GachaName or ""
	return string.format(
		"%s:%d:%s:%d:%s:%s:%s:%s:%s",
		data.Type,
		#gachaName,
		gachaName,
		#data.Name,
		data.Name,
		tostring(data.Shiny),
		data.Rarity or "Common",
		tostring(data.Chance),
		data.Status or ""
	)
end

function v.IsMessage(value)
	if typeof(value) ~= "string" or not value:find("%S") then
		return false
	end

	local v2 = utf8.len(value)
	return v2 ~= nil and v2 <= v.MaximumMessageLength
end

return table.freeze(v)