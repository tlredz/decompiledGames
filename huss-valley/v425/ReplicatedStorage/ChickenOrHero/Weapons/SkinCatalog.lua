local ShopConfig = require(script.Parent.ShopConfig)
local OfferRules = require(script.Parent.OfferRules)
local SkinCatalog = {
	Default = "BaseDagger",
	Order = {
		"BaseDagger",
		"VIPDagger",
		"DevelopersPencil",
		"SecretPencil",
		"CloneDagger",
		"GhostScythe",
		"SpoonDagger",
		"IceCreamDagger",
		"BalloonDagger",
		"TopWinsDagger",
		"OwnersTrident"
	},
	Skins = {
		CloneDagger = {
			Name = "CLONE DAGGER",
			Subtitle = "One of you was already a problem.",
			Description = "Split into three for 12 seconds. Runner decoys distract; catcher clones earn catches for you. 45-second recharge; refreshes when you become a catcher and each match.",
			Model = "CloneDagger",
			SoundProfile = "CloneDagger",
			Accent = Color3.fromRGB(104, 172, 255),
			Collection = "THE VALLEY EXCLUSIVE",
			Available = false,
			EquipReady = true
		},
		GhostScythe = {
			Name = "GHOST SCYTHE",
			Subtitle = "Here one moment. Gone the next.",
			Description = "Fade to 80% invisibility and become fully immune for 2 seconds. 45-second recharge; refreshes each match.",
			Model = "GhostScythe",
			SoundProfile = "GhostScythe",
			Accent = Color3.fromRGB(166, 242, 232),
			Collection = "HALLOWEEN EXCLUSIVE",
			Available = false,
			EquipReady = true
		},
		OwnersTrident = {
			Name = "OWNER’S TRIDENT",
			Subtitle = "A heavenly problem.",
			Description = "Three points. One judgement. The owner’s signature trident, crowned in gold and choir.",
			Model = "OwnersTrident",
			SoundProfile = "OwnersTrident",
			Accent = Color3.fromRGB(255, 205, 106),
			Collection = "OWNER’S SIGNATURE",
			Available = false,
			EquipReady = true
		},
		BaseDagger = {
			Name = "VALLEY ORIGINAL",
			Subtitle = "The one that started it.",
			Description = "Clean steel. A familiar grip. Your first knife, ready for every crossing.",
			Model = "BaseDagger",
			SoundProfile = "BaseDagger",
			Accent = Color3.fromRGB(224, 213, 176),
			Collection = "STANDARD ISSUE",
			Available = true,
			DefaultOwned = true
		},
		VIPDagger = {
			Name = "VIP DAGGER",
			Subtitle = "A little extra edge.",
			Description = "Gold finish. Blue jewel. A sharp welcome to the VIP club. Included with VIP.",
			Model = "VIPDagger",
			SoundProfile = "VIPDagger",
			Accent = Color3.fromRGB(237, 190, 77),
			Collection = "VIP EXCLUSIVE",
			Available = false,
			EquipReady = true
		},
		DevelopersPencil = {
			Name = "DEVELOPER’S PENCIL",
			Subtitle = "Making a few pointed changes.",
			Description = "For crossing out bugs. And occasionally, runners.",
			Model = "DevelopersPencil",
			SoundProfile = "DevelopersPencil",
			Accent = Color3.fromRGB(245, 198, 71),
			Collection = "EARNED IN THE VALLEY",
			Available = false,
			EquipReady = true
		},
		SecretPencil = {
			Name = "SECRET PENCIL",
			Subtitle = "A surprise with a sharp point.",
			Description = "A secret knife won from the spin wheel. Yours to keep forever.",
			Model = "SecretPencil",
			SoundProfile = "DevelopersPencil",
			Accent = Color3.fromRGB(255, 211, 78),
			Collection = "SPIN WHEEL EXCLUSIVE",
			Available = false,
			EquipReady = true
		},
		SpoonDagger = {
			Name = "THE SPOON",
			Subtitle = "A different kind of sharp.",
			Description = "Someone brought a spoon to a knife fight. Breakfast is cancelled.",
			Model = "SpoonDagger",
			SoundProfile = "SpoonDagger",
			Accent = Color3.fromRGB(137, 211, 196),
			Collection = "THE VALLEY SPECIAL",
			Available = false,
			EquipReady = true
		},
		IceCreamDagger = {
			Name = "ICE CREAM SCYTHE",
			Subtitle = "Your last scoop.",
			Description = "An oversized dessert with a dangerous curve. A frosty finish, served with a side of chaos.",
			Model = "IceCreamDagger",
			SoundProfile = "IceCreamDagger",
			Accent = Color3.fromRGB(186, 167, 255),
			Collection = "SEASON 1 PREMIUM · TIER 30",
			Available = false,
			EquipReady = true
		},
		BalloonDagger = {
			Name = "PARTY POPPER",
			Subtitle = "Inflated ego. Inflated knife.",
			Description = "Invite a friend who joins through your invite. Unlock this oversized balloon dagger forever.",
			Model = "BalloonDagger",
			SoundProfile = "BalloonDagger",
			Accent = Color3.fromRGB(255, 128, 185),
			Collection = "BRING A FRIEND",
			Available = false,
			EquipReady = true,
			RewardKey = "FriendReferral"
		},
		TopWinsDagger = {
			Name = "THE NUMBER ONE",
			Subtitle = "You reached the summit.",
			Description = "Reach #1 on the global Wins leaderboard. The title belongs to today's leader. This trophy stays yours forever.",
			Model = "TopWinsDagger",
			SoundProfile = "TopWinsDagger",
			Accent = Color3.fromRGB(255, 215, 107),
			Collection = "GLOBAL WINS TROPHY",
			Available = false,
			EquipReady = true,
			RewardKey = "TopWins"
		}
	}
}
local FantasySkinCatalog = require(script.Parent.FantasySkinCatalog)

for _, v in FantasySkinCatalog.Order do
	table.insert(SkinCatalog.Order, v)
	SkinCatalog.Skins[v] = FantasySkinCatalog.Skins[v]
end

local ComedySkinCatalog = require(script.Parent.ComedySkinCatalog)

for _, v in ComedySkinCatalog.Order do
	table.insert(SkinCatalog.Order, v)
	SkinCatalog.Skins[v] = ComedySkinCatalog.Skins[v]
end

local skin = SkinCatalog.Skins[ShopConfig.Earnable.SkinId]

if skin then
	skin.Offer = {
		Currency = "gems",
		Price = ShopConfig.Earnable.Price,
		StartsAt = ShopConfig.Earnable.StartsAt,
		EndsAt = ShopConfig.Earnable.EndsAt
	}
end

function SkinCatalog.canBuy(p, p2)
	local v = SkinCatalog.get(p)

	if v == nil or v.Available ~= true or v.EquipReady == false or v.Offer == nil or type(v.Offer.Price) ~= "number" or not (v.Offer.Price > 0) or v.Offer.Price % 1 ~= 0 then
		return false
	else
		return (OfferRules.active(v.Offer, p2 or os.time()))
	end
end

SkinCatalog.SoundEvents = {
	"Equip",
	"Windup",
	"Swing",
	"Dive",
	"Hit",
	"Sheath",
	"Cancel"
}

function SkinCatalog.get(value)
	return type(value) == "string" and SkinCatalog.Skins[value] or nil
end

return SkinCatalog