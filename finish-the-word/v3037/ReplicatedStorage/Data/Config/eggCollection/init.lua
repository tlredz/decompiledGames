local createVector = vector.create
return {
	Starter = {
		DisplayName = "Starter Block",
		Rarity = "Common",
		Pet = "Goobat",
		UnlockCost = 100,
		Cost = 150,
		Currency = "Cash",
		Pity = {
			Soft = 90,
			Hard = 180
		},
		Height = 4.75,
		Orientation = createVector(90, 180, 0),
		Pets = {
			Eraser = 0.5,
			Books = 0.31,
			Axolotl = 0.13,
			Goobat = 0.045,
			Bee = 0.01,
			Frosty = 0.005
		}
	},
	Expensive = {
		DisplayName = "Secret Block",
		Rarity = "Legendary",
		Pet = "Robot",
		Robux = true,
		UnlockCost = 100,
		Cost = 1,
		Currency = "SpecialKey",
		Pity = {
			Soft = 90,
			Hard = 180
		},
		Orientation = createVector(0, 0, 0),
		Pets = {
			Imp = 0.51,
			Robot = 0.31,
			Alien = 0.13,
			Glacielle = 0.04,
			Glitch = 0.01
		}
	},
	New = {
		DisplayName = "Rare Block",
		Rarity = "Legendary",
		Pet = "Shark",
		UnlockCost = 4000,
		Cost = 250,
		Currency = "Cash",
		Pity = {
			Soft = 90,
			Hard = 180
		},
		Orientation = createVector(90, 180, 0),
		Pets = {
			Shark = 0.5,
			Bunny = 0.31,
			Hydra = 0.13,
			HeartDragon = 0.045,
			Void = 0.01,
			Lily = 0.005
		}
	},
	Furry = {
		DisplayName = "Furry Block",
		Rarity = "Legendary",
		Pet = "Lumi",
		UnlockCost = 8000,
		Cost = 250,
		Currency = "Cash",
		Pity = {
			Soft = 90,
			Hard = 180
		},
		Orientation = createVector(90, 180, 0),
		Pets = {
			Scoob = 0.5,
			CatEmoji = 0.31,
			Chip = 0.13,
			Rime = 0.045,
			Lumi = 0.01,
			EasterFairy = 0.005
		}
	},
	Summer = {
		DisplayName = "Summer Block",
		Rarity = "Legendary",
		GradientColor = ColorSequence.new(Color3.fromRGB(255, 210, 0), Color3.fromRGB(255, 105, 0)),
		Pet = "SandCastle",
		UnlockCost = 8000,
		Cost = 250,
		Currency = "Cash",
		Pity = {
			Soft = 90,
			Hard = 180
		},
		Orientation = createVector(90, 180, 0),
		Pets = {
			SoccerBall = 0.5,
			Clock = 0.31,
			Seagull = 0.13,
			SandCastle = 0.045,
			Fireworks = 0.01,
			Bomb = 0.005
		}
	}
}