local statKeys = {
	"Max Health",
	"Health Regen Speed",
	"Max Stamina",
	"Stamina Regen Speed",
	"Movement Speed Factor",
	"Additional Damage",
	"Additional Damage Factor",
	"Damage Reduction",
	"Damage Reduction Factor",
	"Block Points",
	"Block Regen",
	"Illumination",
	"Stamina Drain Rate",
	"Burn Damage Factor",
	"Poison Damage Factor",
	"Attack Speed Factor",
	"Cooldown Reduction Factor",
	"Stamina Cost Factor",
	"Max Health Factor",
	"Wind Damage Factor",
	"Thunder Damage Factor",
	"Serpent Damage Factor",
	"Water Damage Factor",
	"Insect Damage Factor",
	"Sword Damage Factor",
	"Breathing Damage Factor",
	"Run Speed Factor",
	"Dash Speed Factor",
	"Jump Power Factor",
	"Evil Art Damage Factor",
	"Water Stamina Cost Factor",
	"Drop Luck Factor",
	"Exp Factor",
	"Quest Exp Factor",
	"Breath Duration Factor",
	"Fishing Luck Factor",
	"Bite Speed Factor",
	"Sun Immunity",
	"Cold Immunity"
}
local statKeyLookup = {}

for _, v3 in statKeys do
	statKeyLookup[v3] = true
end

local function STAT_TO_ATTRIBUTE(value: string)
	return (string.gsub(value, " ", "_"))
end

local function ATTRIBUTE_TO_STAT(value: string)
	return (string.gsub(value, "_", " "))
end

local function IS_META_ATTRIBUTE(value: string)
	return string.sub(value, 1, 1) == "_"
end

local classes = {
	"Duelist",
	"Technician",
	"Tank",
	"Sentinel",
	"Phantom",
	"Titan",
	"Ascendant"
}
local classLookup = {}

for _, v6 in classes do
	classLookup[v6] = true
end

return {
	StatKeys = statKeys,
	StatKeyLookup = statKeyLookup,
	HighestOnlyStats = {
		Illumination = true
	},
	ValueStatTag = "Stats",
	StatToAttribute = STAT_TO_ATTRIBUTE,
	AttributeToStat = ATTRIBUTE_TO_STAT,
	MetaAttributePrefix = "_",
	IsMetaAttribute = IS_META_ATTRIBUTE,
	Classes = classes,
	ClassLookup = classLookup
}