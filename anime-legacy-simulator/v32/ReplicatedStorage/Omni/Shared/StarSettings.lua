local module = require("@game/ReplicatedStorage/Omni/Shared/Fighters")
require("@game/ReplicatedStorage/Omni/DataTemplate")
local v = {
	AvailableStates = {
		"None",
		"Auto Sell",
		"Auto Lock",
		"Auto Deconstruct"
	},
	AvailableOptions = {
		{
			Name = "Announce"
		},
		{
			Name = "Auto Sell"
		},
		{
			Name = "Auto Lock"
		},
		{
			Name = "Auto Deconstruct"
		}
	},
	RarityDefaults = {
		Secret = {
			Announce = true,
			State = "Auto Lock"
		}
	}
}

function v.GetSettings(p: string, flag: boolean, p2)
	local v2 = module.List[p]

	if flag then
		p ..= " Shiny"
	end

	local clone = p2.Stars.Settings[p] or v2 and v.RarityDefaults[v2.Rarity] or {
		Announce = false,
		State = "None"
	}

	if clone.State == "Auto Fuse" then
		clone = table.clone(clone)
		clone.State = "Auto Deconstruct"
	end

	return clone
end

return table.freeze(v)