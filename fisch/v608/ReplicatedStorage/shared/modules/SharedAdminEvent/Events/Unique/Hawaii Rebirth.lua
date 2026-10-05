local sharedAdminEvent = script:FindFirstAncestor("SharedAdminEvent")
require(sharedAdminEvent.Types)
return {
	Identity = "Hawaii Rebirth",
	DisplayName = "Hawaii Rebirth Event",
	Duration = 300,
	RunGlobally = true,
	Issueable = true,
	RunInTradePlaza = true,
	Actions = {
		"Announcement",
		"Multiplier",
		"Lighting",
		"Fish",
		"Mutation",
		"StatusEffect",
		"StartSound",
		"Icon"
	},
	Arguments = {
		"<b><font color='#ffffff'>Hawaii</font></b> is reborn!",
		{
			luck = 2500,
			xp = 10,
			length = 5
		},
		"HawaiiRebirthLight",
		{
			["Crowned Anglerfish"] = 20,
			["Styx Angler"] = 10,
			Cloud = 20,
			Moon = 10,
			["Palm Tree"] = 10,
			["Sandiest Dollar"] = 10
		},
		{
			Prismatic = 60,
			Rainbow = 20,
			Mythical = 10,
			Serene = 10
		},
		{
			Duration = 1800,
			Effects = {
				LullabyQuickening = {
					StatBoosts = {
						Lure = 20,
						ProgressSpeed = 20
					}
				},
				LullabyStrengthening = {
					StatBoosts = {
						Strength = 75000,
						LineDistance = 75,
						XpMultiply = 0.5,
						Disturbance = 4
					}
				},
				LullabyFortuitous = {
					StatBoosts = {
						Luck = 40,
						WeightBoost = 10
					}
				},
				LullabyResistant = {
					StatBoosts = {
						Resilience = 20,
						Control = 0.05
					}
				},
				LullabyPrismatic = {
					StatBoosts = {
						Lure = 10,
						ProgressSpeed = 10,
						Strength = 25000,
						LineDistance = 25,
						XpMultiply = 0.25,
						Luck = 20,
						WeightBoost = 5,
						Resilience = 10,
						Control = 0.025,
						ShinyChance = 3,
						SparklingChance = 3,
						Disturbance = 2
					},
					MutationPool = {
						Prismatic = 12,
						Mythical = 3
					}
				},
				LullabySerenity = {
					StatBoosts = {
						Resilience = 45
					},
					MutationPool = {
						Serene = 10
					}
				}
			}
		},
		136489888824290,
		107053722317246,
		"Hawaii Rebirth"
	}
}