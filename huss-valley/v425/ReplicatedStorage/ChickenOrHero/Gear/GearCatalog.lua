local GearCatalog = {
	Enabled = true,
	SalesEnabled = true,
	MaxInventory = 1000000,
	PackSize = 3,
	Order = {
		"BananaPeel",
		"RescueKit",
		"Adrenaline",
		"InflatableDecoy",
		"EmergencyAirhorn",
		"PocketDoor",
		"RufusLeash",
		"BowlingBall",
		"RocketShoes",
		"BigDagger",
		"Cloak"
	},
	Items = {
		BigDagger = {
			IconImage = "rbxassetid://111671278699403",
			Kind = "Ability",
			Cooldown = 25,
			Name = "BIG DAGGER",
			Tag = "A LITTLE EXTRA REACH",
			Description = "Double your melee reach for your next hit. Expires after 5 seconds.",
			Role = "CHASER",
			UseRole = "Catcher",
			RoleItem = true,
			Gems = 900,
			Coins = 0,
			ProductId = 3715925637,
			Accent = Color3.fromRGB(255, 180, 98),
			Preview = "BigDagger"
		},
		Cloak = {
			IconImage = "rbxassetid://73781834929672",
			Kind = "Ability",
			Cooldown = 25,
			Name = "CLOAK",
			Tag = "BLINK AND I'M GONE",
			Description = "Disappear for 3 seconds. You can still be hit. Using an item ends the cloak.",
			Role = "RUNNER",
			UseRole = "Runner",
			RoleItem = true,
			Gems = 1000,
			Coins = 0,
			ProductId = 3715925800,
			Accent = Color3.fromRGB(170, 150, 245),
			Preview = "Cloak"
		},
		InflatableDecoy = {
			IconImage = "rbxassetid://129293392144023",
			Kind = "Ability",
			Cooldown = 30,
			Name = "INFLATABLE DECOY",
			Tag = "DOUBLE TROUBLE",
			Description = "Send an inflatable copy running straight ahead for 7 seconds. It pops when caught.",
			Role = "RUNNER",
			UseRole = "Runner",
			RoleItem = true,
			Coins = 840,
			Gems = 750,
			ProductId = 3715705958,
			Accent = Color3.fromRGB(118, 212, 242),
			Preview = "InflatableDecoy"
		},
		EmergencyAirhorn = {
			IconImage = "rbxassetid://116268308218108",
			Kind = "Ability",
			Cooldown = 18,
			Name = "EMERGENCY AIRHORN",
			Tag = "SMALL HORN. BIG PANIC.",
			Description = "Blast nearby chasers backward in every direction.",
			Role = "RUNNER",
			UseRole = "Runner",
			RoleItem = true,
			Coins = 630,
			Gems = 1000,
			ProductId = 3715705962,
			Accent = Color3.fromRGB(255, 190, 92),
			Preview = "EmergencyAirhorn"
		},
		PocketDoor = {
			IconImage = "rbxassetid://91558112029977",
			Kind = "Ability",
			Cooldown = 25,
			Name = "POCKET DOOR",
			Tag = "NOT TODAY",
			Description = "Slam a temporary door in front of you. Chasers smash through or go around. Lasts 6 seconds.",
			Role = "RUNNER",
			UseRole = "Runner",
			RoleItem = true,
			Coins = 840,
			Gems = 400,
			ProductId = 3715705964,
			Accent = Color3.fromRGB(177, 152, 245),
			Preview = "PocketDoor"
		},
		RufusLeash = {
			HitRadius = 2.8,
			ThrowRange = 10,
			IconImage = "rbxassetid://123560947340742",
			Kind = "Ability",
			Cooldown = 20,
			Name = "RUFUS’S LEASH",
			Tag = "COME BACK HERE",
			Description = "Throw a leash up to 10 studs ahead. A hit pulls a runner up to 6 studs toward you.",
			Role = "CHASER",
			UseRole = "Catcher",
			RoleItem = true,
			Coins = 840,
			Gems = 1200,
			ProductId = 3715705971,
			Accent = Color3.fromRGB(240, 168, 114),
			Preview = "RufusLeash"
		},
		BowlingBall = {
			IconImage = "rbxassetid://95438074463345",
			Kind = "Ability",
			Cooldown = 20,
			Name = "BOWLING BALL",
			Tag = "STRIKE!",
			Description = "Roll a ball along the ground. A direct hit briefly trips a runner.",
			Role = "CHASER",
			UseRole = "Catcher",
			RoleItem = true,
			Coins = 630,
			Gems = 750,
			ProductId = 3715705976,
			Accent = Color3.fromRGB(168, 142, 240),
			Preview = "BowlingBall"
		},
		RocketShoes = {
			IconImage = "rbxassetid://81361668939419",
			Kind = "Ability",
			Cooldown = 18,
			Name = "ROCKET SHOES",
			Tag = "BRAKES SOLD SEPARATELY",
			Description = "Dash in your movement direction, or camera-forward while standing still.",
			Role = "CHASER",
			UseRole = "Catcher",
			RoleItem = true,
			Coins = 420,
			Gems = 850,
			ProductId = 3715705981,
			Accent = Color3.fromRGB(255, 136, 103),
			Preview = "RocketShoes"
		},
		BananaPeel = {
			Kind = "Item",
			Cooldown = 12,
			Name = "BANANA PEEL",
			Tag = "A LITTLE SLIP-UP",
			Description = "Throw a peel that lasts 15 seconds. The first opponent slips, falls, then quickly gets back up.",
			Role = "RUNNER / CATCHER",
			Coins = 135,
			Gems = 60,
			ProductId = 3715698235,
			Accent = Color3.fromRGB(242, 207, 105),
			Preview = "BananaPeel"
		},
		RescueKit = {
			Kind = "Item",
			Cooldown = 12,
			Name = "RESCUE KIT",
			Tag = "BACK ON YOUR FEET",
			Description = "Revive yourself when downed during a crossing. Use while rescue is available.",
			Role = "RUNNER",
			UseRole = "Runner",
			Coins = 203,
			Gems = 90,
			ProductId = 3715698237,
			Accent = Color3.fromRGB(128, 218, 180),
			Preview = "RescueKit"
		},
		Adrenaline = {
			Kind = "Item",
			Cooldown = 12,
			Name = "ADRENALINE",
			Tag = "FIND YOUR SECOND WIND",
			Description = "Accelerate 60% faster and retain more speed through turns for 5 seconds.",
			Role = "RUNNER / CATCHER",
			Coins = 135,
			Gems = 60,
			ProductId = 3715698239,
			Accent = Color3.fromRGB(137, 192, 246),
			Preview = "Adrenaline"
		}
	},
	ProductGrants = {
		[3715925637] = {
			UniverseId = 10764627709,
			Item = "BigDagger",
			Amount = 1
		},
		[3715925800] = {
			UniverseId = 10764627709,
			Item = "Cloak",
			Amount = 1
		},
		[3715705958] = {
			UniverseId = 10764627709,
			Item = "InflatableDecoy",
			Amount = 1
		},
		[3715705962] = {
			UniverseId = 10764627709,
			Item = "EmergencyAirhorn",
			Amount = 1
		},
		[3715705964] = {
			UniverseId = 10764627709,
			Item = "PocketDoor",
			Amount = 1
		},
		[3715705971] = {
			UniverseId = 10764627709,
			Item = "RufusLeash",
			Amount = 1
		},
		[3715705976] = {
			UniverseId = 10764627709,
			Item = "BowlingBall",
			Amount = 1
		},
		[3715705981] = {
			UniverseId = 10764627709,
			Item = "RocketShoes",
			Amount = 1
		},
		[3715702794] = {
			UniverseId = 10764627709,
			Item = "InflatableDecoy",
			Amount = 3
		},
		[3715702796] = {
			UniverseId = 10764627709,
			Item = "EmergencyAirhorn",
			Amount = 3
		},
		[3715702799] = {
			UniverseId = 10764627709,
			Item = "PocketDoor",
			Amount = 3
		},
		[3715702801] = {
			UniverseId = 10764627709,
			Item = "RufusLeash",
			Amount = 3
		},
		[3715702805] = {
			UniverseId = 10764627709,
			Item = "BowlingBall",
			Amount = 3
		},
		[3715702806] = {
			UniverseId = 10764627709,
			Item = "RocketShoes",
			Amount = 3
		},
		[3715698235] = {
			UniverseId = 10764627709,
			Item = "BananaPeel",
			Amount = 3
		},
		[3715698237] = {
			UniverseId = 10764627709,
			Item = "RescueKit",
			Amount = 3
		},
		[3715698239] = {
			UniverseId = 10764627709,
			Item = "Adrenaline",
			Amount = 3
		}
	}
}

function GearCatalog.get(value)
	return type(value) == "string" and GearCatalog.Items[value] or nil
end

function GearCatalog.equippedForRole(p, p2)
	if not p then
		return ""
	end

	if type(p.equippedAbilities) == "table" then
		return p.equippedAbilities[p2] or ""
	end

	local v = GearCatalog.get(p.equippedAbility)
	return v and v.UseRole == p2 and p.equippedAbility or ""
end

return GearCatalog