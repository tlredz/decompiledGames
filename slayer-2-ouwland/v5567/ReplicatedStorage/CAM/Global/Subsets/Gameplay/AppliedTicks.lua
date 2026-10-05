local list = {
	{
		Name = "Flame",
		Value = "Flame Tick",
		Vfx = "FlameTick"
	},
	{
		Name = "Frost",
		Value = "Frost Tick",
		Vfx = "FrostTick"
	},
	{
		Name = "Poison",
		Value = "Poison Tick",
		Vfx = "PoisonTick"
	},
	{
		Name = "Venom",
		Value = "Venom Tick",
		Vfx = "VenomTick"
	},
	{
		Name = "Bleed",
		Value = "Bleed Tick",
		Vfx = "BleedTick"
	},
	{
		Name = "Viral Decay",
		Value = "Viral Decay Tick",
		Vfx = "ViralDecay"
	},
	{
		Name = "Neurotoxin Slow",
		Value = "Neurotoxin Slow",
		Vfx = "NeurotoxinSlow"
	},
	{
		Name = "Enhanced Hearing",
		Value = "Enhanced Hearing Mark",
		Vfx = "EnhancedHearingMark"
	},
	{
		Name = "Pharmaceutical Skills",
		Value = "Healing Ring",
		Vfx = "HealthRegen"
	},
	{
		Name = "Damage",
		Value = "Damage Tick",
		Vfx = nil
	}
}
local names = {}
local byName = {}

for _, v3 in list do
	table.insert(names, v3.Name)
	byName[v3.Name] = v3
	byName[v3.Name:lower()] = v3
	byName[v3.Value] = v3
	byName[v3.Value:lower()] = v3
end

return {
	List = list,
	Names = names,
	ByName = byName
}