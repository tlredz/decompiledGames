require(script.Parent.Types)
return {
	Free = {
		order = 1,
		displayName = "Free",
		unlock = {
			type = "Free"
		},
		sounds = {
			"Creamy",
			"Chocolate",
			"Candy",
			"Clacky"
		}
	},
	Premium = {
		order = 3,
		displayName = "Premium Sound Pack",
		unlock = {
			type = "Gamepass",
			gamepassKey = "SOUNDPACK_ACCESS"
		},
		sounds = {
			"Premium",
			"Water",
			"Bubble",
			"Christmas",
			"Lava",
			"Honey",
			"Snow",
			"Slime"
		}
	},
	BBNO = {
		order = 2,
		displayName = "bbno$ Sound Pack",
		unlock = {
			type = "Gamepass",
			gamepassKey = "BBNO_SOUND_PACK"
		},
		sounds = {
			"BBNO_OOF",
			"BBNO_BOTTLE",
			"BBNO_TAK",
			"BBNO_POP",
			"BBNO_PAH",
			"BBNO_UHH",
			"BBNO_GOOFY",
			"BBNO_YAP"
		}
	}
}