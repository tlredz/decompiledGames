return {
	CurrentEvent = "",
	Events = {
		["Golden Tide"] = {
			Version = 1,
			StartTime = DateTime.fromUniversalTime(2025, 1, 11, 12),
			EndTime = DateTime.fromUniversalTime(2025, 1, 25, 12),
			StartMessage = "<font color='#FFD700'>Golden Tide</font> <font color='#FFFFFF'>event has just started, check Limited Bestiaries!</font>",
			BestiaryCompletedMessage = "You've discovered all 5 fish! you unlocked a new title <font color=\"#ff5500\">Tidal Master</font>!",
			Rewards = {
				Title = "Tidal Master"
			},
			ZoneModifications = {},
			Bestiary = {
				"Tidal Pike",
				"Confetti Shark",
				"Countdown Perch",
				"Eternal Frostwhale",
				"Hourglass Bass"
			}
		},
		["Winter's Edge"] = {
			Version = 1,
			StartTime = DateTime.fromUniversalTime(2024, 12, 28, 15),
			EndTime = DateTime.fromUniversalTime(2024, 12, 30, 5),
			StartMessage = "<font color='#FFD700'>Winter's Edge</font> <font color='#FFFFFF'>has just started, check Limited Bestiaries!</font>",
			ZoneModifications = {
				{
					AffectedAreas = { "Ocean", "Deep Ocean" },
					Insert = {
						"Glacier Glowfish",
						"Frozen Fangfish",
						"Hollow Flake Catfish",
						"Crystal Carp",
						"Hollyscale Trout"
					},
					Remove = {}
				}
			}
		},
		Archaeologist = {
			Version = 1,
			StartTime = DateTime.fromUniversalTime(2024, 11, 30, 13, 0, 0),
			EndTime = DateTime.fromUniversalTime(2024, 11, 30, 13, 0, 0),
			Bestiary = {
				"Barracuda's Spine",
				"Fossil Fan",
				"Claw Gill",
				"Spine Bone",
				"Spine Blade",
				"Shark Fang",
				"Nessie's Spine",
				"Spined Fin",
				"Ancient Serpent Spine",
				"Ancient Serpent Skull"
			},
			BestiaryCompletedMessage = "You've fished all 10 bones! Talk to <font color=\"#5DE2E7\">Dr. Finneus</font> at <font color=\"#FF0000\">Moosewood</font> to find out the next steps!",
			ZoneModifications = {
				{
					AffectedAreas = {
						"Moosewood Ocean",
						"Moosewood Ocean Mythical",
						"Moosewood Docks",
						"Moosewood Pond"
					},
					Insert = { "Barracuda's Spine", "Fossil Fan", "Claw Gill" },
					Remove = {}
				},
				{
					AffectedAreas = {
						"Roslit Pond",
						"Roslit Pond Seaweed",
						"Roslit Bay",
						"Roslit Bay Ocean"
					},
					Insert = { "Spine Bone", "Spine Blade", "Shark Fang" },
					Remove = {}
				},
				{
					AffectedAreas = { "Mushgrove Water" },
					Insert = { "Nessie's Spine" },
					Remove = {}
				},
				{
					AffectedAreas = { "Snowcap Pond", "Snowcap Ocean" },
					Insert = { "Spined Fin" },
					Remove = {}
				},
				{
					AffectedAreas = { "Forsaken Shores", "Forsaken Shores Ocean", "Forsaken Shores Pond" },
					Insert = { "Ancient Serpent Spine", "Ancient Serpent Skull" },
					Remove = {}
				}
			}
		}
	}
}