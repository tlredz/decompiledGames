local v = {
	Pirate = {
		"Dinghy",
		"PirateSloop",
		"PirateBrigade",
		"PirateGrandBrigade"
	},
	Marine = {
		"Dinghy",
		"MarineSloop",
		"MarineBrigade",
		"MarineGrandBrigade"
	},
	Marine2 = { "MarineSloop", "MarineBrigade", "MarineGrandBrigade" }
}
local v2 = {
	"Miracle",
	"The Sentinel",
	"Guardian",
	"Lantern",
	"Sleigh",
	"Beast Hunter"
}
return {
	List = {
		Dinghy = {
			DisplayName = "Dinghy",
			Cost = 0
		},
		PirateSloop = {
			DisplayName = "Sloop",
			Cost = 300
		},
		MarineSloop = {
			DisplayName = "Sloop",
			Cost = 150
		},
		PirateBrigade = {
			DisplayName = "Brigade",
			Cost = 1000
		},
		MarineBrigade = {
			DisplayName = "Brigade",
			Cost = 600
		},
		PirateGrandBrigade = {
			DisplayName = "Grand Brigade",
			Cost = 4000,
			Unlockable = "PirateBrigade"
		},
		MarineGrandBrigade = {
			DisplayName = "Grand Brigade",
			Cost = 2000,
			Unlockable = "MarineBrigade"
		},
		Miracle = {
			DisplayName = "Miracle",
			Cost = 0,
			RequiresFastBoat = true
		},
		["The Sentinel"] = {
			DisplayName = "The Sentinel",
			Cost = 1000,
			RequiresFastBoat = true
		},
		Guardian = {
			DisplayName = "Guardian",
			Cost = 5000,
			Unlockable = "SwanShip"
		},
		Lantern = {
			DisplayName = "Lantern",
			Cost = 5000,
			Unlockable = "FlowerShip"
		},
		Sleigh = {
			DisplayName = "Sleigh",
			Cost = 5000,
			Unlockable = "Sleigh"
		},
		["Beast Hunter"] = {
			DisplayName = "Beast Hunter",
			Cost = 5000,
			Unlockable = "BeastHunter"
		}
	},
	getForDealer = function(p: string)
		local clone = table.clone(v[p] or {})

		for _, v3 in v2 do
			table.insert(clone, v3)
		end

		return clone
	end
}