local JourneySeasons = require(script.Parent.JourneySeasons)
local season = JourneySeasons.Seasons[JourneySeasons.ActiveSeason]
local JourneyConfig = {
	Enabled = true,
	Visible = true,
	Name = "VALLEY JOURNEY",
	SeasonId = JourneySeasons.ActiveSeason,
	SeasonNumber = season.Number,
	SeasonName = season.Name,
	TrackId = season.TrackId,
	PremiumPassId = season.PremiumPassId,
	MaxTier = season.MaxTier,
	MaxLevel = season.MaxTier,
	FirstTierXP = season.FirstTierXP,
	TierStepXP = season.TierStepXP,
	PurchasesEnabledUniverses = {
		[10764627709] = true
	},
	Badges = {
		FirstSteps = {
			Name = "FIRST STEPS",
			Color = Color3.fromRGB(123, 199, 217),
			Icon = "I"
		},
		QuickFeet = {
			Name = "QUICK FEET",
			Color = Color3.fromRGB(107, 214, 176),
			Icon = "II"
		},
		CornerArtist = {
			Name = "CORNER ARTIST",
			Color = Color3.fromRGB(114, 176, 242),
			Icon = "III"
		},
		Untouchable = {
			Name = "UNTOUCHABLE",
			Color = Color3.fromRGB(179, 145, 234),
			Icon = "IV"
		},
		ValleyVeteran = {
			Name = "VALLEY VETERAN",
			Color = Color3.fromRGB(227, 188, 116),
			Icon = "V"
		},
		ValleyElite = {
			Name = "VALLEY ELITE",
			Color = Color3.fromRGB(247, 214, 133),
			Icon = "VI"
		},
		NightRunner = {
			Name = "NIGHT RUNNER",
			Color = Color3.fromRGB(196, 157, 255),
			Icon = "✦"
		},
		CrownChaser = {
			Name = "CROWN CHASER",
			Color = Color3.fromRGB(244, 207, 119),
			Icon = "✦"
		},
		ValleyRoyalty = {
			Name = "VALLEY ROYALTY",
			Color = Color3.fromRGB(249, 199, 145),
			Icon = "✦"
		}
	},
	Rewards = require(script.Parent:WaitForChild(season.RewardsModule))
}

function JourneyConfig.reward(p)
	for k, reward in JourneyConfig.Rewards do
		for k2, v in reward do
			if v.Key == p then
				return v, k, k2
			end
		end
	end
end

return JourneyConfig