local OfferRules = require(script.Parent.OfferRules)
local ShopConfig = {
	WeekEnding = {
		Year = 2026,
		Month = 9,
		Day = 26
	}
}
local weekEnding = ShopConfig.WeekEnding
local ukSaturdayDeadline = OfferRules.ukSaturdayDeadline(weekEnding.Year, weekEnding.Month, weekEnding.Day)
ShopConfig.FlagshipWeekEnding = {
	Year = 2026,
	Month = 10,
	Day = 3
}
local flagshipWeekEnding = ShopConfig.FlagshipWeekEnding
local ukSaturdayDeadline2 = OfferRules.ukSaturdayDeadline(
	flagshipWeekEnding.Year,
	flagshipWeekEnding.Month,
	flagshipWeekEnding.Day
)
ShopConfig.Earnable = {
	SkinId = "DevelopersPencil",
	Price = 2000,
	StartsAt = 0,
	EndsAt = ukSaturdayDeadline,
	Eyebrow = "EARNED IN THE VALLEY",
	Title = "YOUR NEXT FIND",
	Tagline = "Cross. Collect. Claim.",
	Description = "A new gem-earned knife will appear here.",
	Footnote = "Collect gems during crossings."
}
ShopConfig.Display = {
	MaxDistance = 50,
	PromptDistance = 11,
	AnimationDistance = 90,
	SoundDistance = 12
}
ShopConfig.Flagship = {
	SkinId = "CloneDagger",
	StartsAt = 0,
	EndsAt = ukSaturdayDeadline2,
	OfferKey = "Clone",
	Eyebrow = "THE VALLEY EXCLUSIVE",
	Title = "CLONE DAGGER",
	Tagline = "One of you was already a problem.",
	Description = "Blue energy. Gold trim. A few extra yous, for emotional support.",
	Footnote = "2 clones · 12 seconds · 45-second cooldown. Refreshes on becoming a chaser and each match."
}
ShopConfig.GhostFlagship = {
	SkinId = "GhostScythe",
	StartsAt = 1791043200,
	EndsAt = 1791648000,
	OfferKey = "Ghost",
	Eyebrow = "HALLOWEEN EXCLUSIVE",
	Title = "GHOST SCYTHE",
	Tagline = "Here one moment. Gone the next.",
	Description = "Fade to 80% invisibility and become fully immune for 2 seconds.",
	Footnote = "2-second spectral escape · 45-second cooldown. Refreshes each match."
}

if game.GameId == 10768621983 then
	local ReplicatedStorage = game:GetService("ReplicatedStorage")

	-- equivalent calls inferred from this helper; original call sites unknown
	local function syncTestSwap()
		local ghostTestSwapAt = ReplicatedStorage:GetAttribute("GhostTestSwapAt")

		if type(ghostTestSwapAt) ~= "number" or ghostTestSwapAt <= 0 then
			ghostTestSwapAt = workspace:GetServerTimeNow() + 120
		end

		ShopConfig.Flagship.EndsAt = ghostTestSwapAt
		ShopConfig.GhostFlagship.StartsAt = ghostTestSwapAt
	end

	syncTestSwap() -- equivalent call inferred; original call site unknown
	ReplicatedStorage:GetAttributeChangedSignal("GhostTestSwapAt"):Connect(syncTestSwap)
end

function ShopConfig.featured(p)
	return (p or os.time()) >= ShopConfig.GhostFlagship.StartsAt and ShopConfig.GhostFlagship or ShopConfig.Flagship
end

ShopConfig.AdditionalKnives = {}
ShopConfig.Passes = {
	Clone = {
		Name = "Clone Dagger",
		SkinId = "CloneDagger"
	},
	Ghost = {
		Name = "Ghost Scythe",
		SkinId = "GhostScythe"
	},
	IceCream = {
		Name = "Ice Cream Scythe",
		SkinId = "IceCreamDagger"
	},
	Spoon = {
		Name = "The Spoon",
		SkinId = "SpoonDagger"
	},
	DoubleXP = {
		Name = "2× XP",
		Multiplier = 2
	},
	VIP = {
		Name = "VIP",
		Multiplier = 1.25,
		RewardSkinId = "VIPDagger"
	}
}
ShopConfig.Packs = {
	{
		Key = "Coins1",
		Currency = "coins",
		Amount = 100,
		Label = "POCKET CHANGE"
	},
	{
		Key = "Coins2",
		Currency = "coins",
		Amount = 250,
		Label = "A LITTLE EXTRA"
	},
	{
		Key = "Coins3",
		Currency = "coins",
		Amount = 600,
		Label = "THE STASH"
	},
	{
		Key = "Coins4",
		Currency = "coins",
		Amount = 1400,
		Label = "FULL POCKETS"
	},
	{
		Key = "Coins5",
		Currency = "coins",
		Amount = 3200,
		Label = "THE VAULT"
	},
	{
		Key = "Coins6",
		Currency = "coins",
		Amount = 7500,
		Label = "VALLEY RESERVES"
	},
	{
		Key = "Gems1",
		Currency = "gems",
		Amount = 50,
		Label = "FIRST FIND"
	},
	{
		Key = "Gems2",
		Currency = "gems",
		Amount = 120,
		Label = "A GOOD HAUL"
	},
	{
		Key = "Gems3",
		Currency = "gems",
		Amount = 275,
		Label = "THE CACHE"
	},
	{
		Key = "Gems4",
		Currency = "gems",
		Amount = 600,
		Label = "HIDDEN TREASURE"
	},
	{
		Key = "Gems5",
		Currency = "gems",
		Amount = 1300,
		Label = "DEEP POCKETS"
	},
	{
		Key = "Gems6",
		Currency = "gems",
		Amount = 2800,
		Label = "VALLEY TREASURE"
	}
}
ShopConfig.Universes = {
	[10764627709] = {
		PassIds = {
			Clone = 1998944863,
			Ghost = 2007002633,
			IceCream = 0,
			Spoon = 1990226321,
			DoubleXP = 1989662291,
			VIP = 1990310290
		},
		ProductIds = {
			Coins1 = 3715700196,
			Coins2 = 3715700200,
			Coins3 = 3715700203,
			Coins4 = 3715700204,
			Coins5 = 3715700205,
			Coins6 = 3715700208,
			Gems1 = 3715700211,
			Gems2 = 3715700216,
			Gems3 = 3715700220,
			Gems4 = 3715700223,
			Gems5 = 3715700226,
			Gems6 = 3715700228
		},
		PurchasesEnabled = true
	},
	[10767420607] = {
		PassIds = {
			Clone = 1998944863,
			Ghost = 0,
			IceCream = 0,
			Spoon = 1990226321,
			DoubleXP = 1989662291,
			VIP = 1990310290
		},
		ProductIds = {},
		PurchasesEnabled = false
	},
	[10768621983] = {
		PassIds = {
			Ghost = 2004908616
		},
		ProductIds = {},
		PurchasesEnabled = true
	}
}
ShopConfig.ProductGrants = {
	[3715700196] = {
		UniverseId = 10764627709,
		Currency = "coins",
		Amount = 100
	},
	[3715700200] = {
		UniverseId = 10764627709,
		Currency = "coins",
		Amount = 250
	},
	[3715700203] = {
		UniverseId = 10764627709,
		Currency = "coins",
		Amount = 600
	},
	[3715700204] = {
		UniverseId = 10764627709,
		Currency = "coins",
		Amount = 1400
	},
	[3715700205] = {
		UniverseId = 10764627709,
		Currency = "coins",
		Amount = 3200
	},
	[3715700208] = {
		UniverseId = 10764627709,
		Currency = "coins",
		Amount = 7500
	},
	[3715700211] = {
		UniverseId = 10764627709,
		Currency = "gems",
		Amount = 50
	},
	[3715700216] = {
		UniverseId = 10764627709,
		Currency = "gems",
		Amount = 120
	},
	[3715700220] = {
		UniverseId = 10764627709,
		Currency = "gems",
		Amount = 275
	},
	[3715700223] = {
		UniverseId = 10764627709,
		Currency = "gems",
		Amount = 600
	},
	[3715700226] = {
		UniverseId = 10764627709,
		Currency = "gems",
		Amount = 1300
	},
	[3715700228] = {
		UniverseId = 10764627709,
		Currency = "gems",
		Amount = 2800
	}
}
ShopConfig.Promotion = {
	Enabled = false,
	StartsAt = 0,
	EndsAt = 0,
	Text = "WEEKEND AT THE VALLEY"
}

function ShopConfig.binding(p)
	return ShopConfig.Universes[p] or {
		PassIds = {},
		ProductIds = {},
		PurchasesEnabled = false
	}
end

function ShopConfig.promotionActive(p)
	local promotion = ShopConfig.Promotion
	local enabled = promotion.Enabled

	if enabled then
		if promotion.StartsAt == 0 or promotion.StartsAt <= p then
			enabled = promotion.EndsAt == 0 or p < promotion.EndsAt
		else
			enabled = false
		end
	end

	return enabled
end

return ShopConfig