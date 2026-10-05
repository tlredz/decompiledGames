local v = {
	Base = {
		Name = "Base",
		PresetHouse = "Base",
		MenuLogoId = "rbxassetid://15618049034"
	},
	BTS = {
		Name = "BTS",
		PresetHouse = "BTS",
		MenuLogoId = "rbxassetid://108358479510132",
		Banner = "BTS",
		TitlePack = "Back to School",
		Deadline = {
			Start = {
				year = 2026,
				month = 8,
				day = 20,
				hour = 0,
				min = 0,
				sec = 0
			},
			End = {
				year = 2026,
				month = 9,
				day = 15,
				hour = 0,
				min = 0,
				sec = 0
			}
		},
		Items = {}
	},
	Summer = {
		Name = "Summer",
		PresetHouse = "Summer26",
		MenuLogoId = "rbxassetid://90222176355836",
		Banner = "Summer",
		Deadline = {
			Start = {
				year = 2026,
				month = 7,
				day = 18,
				hour = 0,
				min = 0,
				sec = 0
			},
			End = {
				year = 2026,
				month = 9,
				day = 1,
				hour = 0,
				min = 0,
				sec = 0
			}
		},
		Hub = {
			Titles = "Summer Titles 3",
			Bundle = "Summer Bundle 4"
		},
		Items = {}
	},
	July = {
		Name = "July",
		PresetHouse = "IndependenceHouse",
		MenuLogoId = "rbxassetid://103569024939812",
		Banner = "July",
		Items = {},
		Hub = {
			Titles = "July Pack",
			Bundle = "4th of July Bundle"
		}
	},
	Patty = {
		Name = "Patty",
		PresetHouse = "Patty",
		Banner = "St. Patrick's Day",
		Items = {},
		Hub = {
			Titles = "St. Patricks Day Pack 2",
			Bundle = "St Patrick Bundle 3"
		}
	},
	Easter = {
		Name = "Easter",
		PresetHouse = "Easter",
		Deadline = {
			Start = {
				year = 2026,
				month = 3,
				day = 31,
				hour = 0,
				min = 0,
				sec = 0
			},
			End = {
				year = 2026,
				month = 4,
				day = 1,
				hour = 22,
				min = 30,
				sec = 0
			}
		},
		Items = {},
		Skins = {
			"Coco Smashers",
			"Bunny Booster",
			"Sundae Thruster",
			"Hatch Smackers",
			"Hare Zapper",
			"Bunny Beater",
			"Harey Brush",
			"Hop Shot",
			"Egg Roller",
			"Chick Trimmer",
			"Bunny Capsule"
		},
		Hub = {
			Titles = "Easter Pack 2",
			Bundle = "Easter Bundle 3"
		},
		MenuLogoId = "rbxassetid://114729475994680"
	}
}
local Holiday = {}

function Holiday.GetCurrentHoliday(_)
	return v.BTS or v.Base
end

function Holiday.GetAllHolidays(_)
	return v
end

return Holiday