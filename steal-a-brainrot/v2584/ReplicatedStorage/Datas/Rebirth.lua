local ReplicatedStorage = game:GetService("ReplicatedStorage")
local shared = ReplicatedStorage:WaitForChild("Shared")
require(shared.Updates)
return {
	{
		Name = "Rebirth 1",
		RebirthNumber = 1,
		Rewards = {
			Cash = 5000,
			Multiplier = 0.5,
			AdditionalLockTime = 10,
			FriendController = true,
			Items = { "Iron Slap", "Gravity Coil", "Bee Launcher" }
		},
		Requirements = {
			Cash = 1000000,
			RequiredCharacters = { "Trippi Troppi", "Gangster Footera" }
		}
	},
	{
		Name = "Rebirth 2",
		RebirthNumber = 2,
		Rewards = {
			Cash = 10000,
			Multiplier = 1,
			AdditionalLockTime = 20,
			AnimalSlot = 1,
			Items = { "Gold Slap", "Coil Combo", "Rage Table" }
		},
		Requirements = {
			Cash = 3000000,
			RequiredCharacters = { "Boneca Ambalabu", "Brr Brr Patapim" }
		}
	},
	{
		Name = "Rebirth 3",
		RebirthNumber = 3,
		Rewards = {
			Cash = 25000,
			Multiplier = 2,
			AdditionalLockTime = 30,
			AnimalSlot = 1,
			Items = { "Diamond Slap", "Grapple Hook", "Taser Gun" }
		},
		Requirements = {
			Cash = 12500000,
			RequiredCharacters = { "Trulimero Trulicina", "Chimpanzini Bananini" }
		}
	},
	{
		Name = "Rebirth 4",
		RebirthNumber = 4,
		Rewards = {
			Cash = 50000,
			Multiplier = 3,
			AdditionalLockTime = 40,
			AnimalSlot = 1,
			Items = { "Emerald Slap", "Invisibility Cloak", "Boogie Bomb" }
		},
		Requirements = {
			Cash = 35000000,
			RequiredCharacters = { "Chef Crabracadabra", "Glorbo Fruttodrillo" }
		}
	},
	{
		Name = "Rebirth 5",
		RebirthNumber = 5,
		Rewards = {
			Cash = 100000,
			Multiplier = 4,
			AdditionalLockTime = 50,
			AnimalSlot = 1,
			Items = { "Ruby Slap", "Medusa's Head" }
		},
		Requirements = {
			Cash = 100000000,
			RequiredCharacters = { "Frigo Camelo", "Orangutini Ananassini" }
		}
	},
	{
		Name = "Rebirth 6",
		RebirthNumber = 6,
		Rewards = {
			Cash = 250000,
			Multiplier = 5,
			AdditionalLockTime = 60,
			AnimalSlot = 1,
			Items = { "Dark Matter Slap", "Web Slinger" }
		},
		Requirements = {
			Cash = 350000000,
			RequiredCharacters = { "Bombardiro Crocodilo" }
		}
	},
	{
		Name = "Rebirth 7",
		RebirthNumber = 7,
		Rewards = {
			Cash = 500000,
			Multiplier = 6,
			AdditionalLockTime = 70,
			AnimalSlot = 1,
			Items = { "Flame Slap", "Quantum Cloner", "All Seeing Sentry" }
		},
		Requirements = {
			Cash = 1000000000,
			RequiredCharacters = { "Bombombini Gusini" }
		}
	},
	{
		Name = "Rebirth 8",
		RebirthNumber = 8,
		Rewards = {
			Cash = 1000000,
			Multiplier = 7,
			AdditionalLockTime = 80,
			AnimalSlot = 1,
			Items = { "Nuclear Slap", "Rainbowrath Sword" }
		},
		Requirements = {
			Cash = 5000000000,
			RequiredCharacters = { "Te Te Te Sahur" }
		}
	},
	{
		Name = "Rebirth 9",
		RebirthNumber = 9,
		Rewards = {
			Cash = 5000000,
			Multiplier = 8,
			AdditionalLockTime = 90,
			AnimalSlot = 1,
			Items = { "Galaxy Slap", "Laser Cape" }
		},
		Requirements = {
			Cash = 25000000000,
			RequiredCharacters = { "Cocofanto Elefanto" }
		}
	},
	{
		Name = "Rebirth 10",
		RebirthNumber = 10,
		Rewards = {
			Cash = 25000000,
			Multiplier = 9,
			AdditionalLockTime = 100,
			AnimalSlot = 1,
			Items = { "Glitched Slap", "Body Swap Potion" }
		},
		Requirements = {
			Cash = 250000000000,
			RequiredCharacters = { "Girafa Celestre" }
		}
	},
	{
		Name = "Rebirth 11",
		RebirthNumber = 11,
		Rewards = {
			Cash = 100000000,
			Multiplier = 10,
			AdditionalLockTime = 110,
			AnimalSlot = 1,
			Items = { "Splatter Slap", "Paintball Gun" }
		},
		Requirements = {
			Cash = 1000000000000,
			RequiredCharacters = { "Tralalero Tralala" }
		}
	},
	{
		Name = "Rebirth 12",
		RebirthNumber = 12,
		Rewards = {
			Cash = 500000000,
			Multiplier = 11,
			AdditionalLockTime = 120,
			AnimalSlot = 1,
			Items = { "Heart Balloon", "Magnet" }
		},
		Requirements = {
			Cash = 7000000000000,
			RequiredCharacters = { "Odin Din Din Dun" }
		}
	},
	{
		Name = "Rebirth 13",
		RebirthNumber = 13,
		Rewards = {
			Cash = 1000000000,
			Multiplier = 12,
			AdditionalLockTime = 130,
			AnimalSlot = 1,
			Items = { "Megaphone", "BeeHive" }
		},
		Requirements = {
			Cash = 35000000000000,
			RequiredCharacters = { "Trenostruzzo Turbo 3000" }
		}
	},
	{
		Name = "Rebirth 14",
		RebirthNumber = 14,
		Rewards = {
			Cash = 2500000000000,
			Multiplier = 13,
			AdditionalLockTime = 140,
			AnimalSlot = 1,
			Items = { "Gummy Bear", "Subspace Mine" }
		},
		Requirements = {
			Cash = 100000000000000,
			RequiredCharacters = { "Trippi Troppi Troppa Trippa" }
		}
	},
	{
		Name = "Rebirth 15",
		RebirthNumber = 15,
		Rewards = {
			Cash = 10000000000000,
			Multiplier = 15,
			AdditionalLockTime = 150,
			AnimalSlot = 1,
			Items = { "Heatseeker" }
		},
		Requirements = {
			Cash = 500000000000000,
			RequiredCharacters = { "Pakrahmatmamat" }
		}
	},
	{
		Name = "Rebirth 16",
		RebirthNumber = 16,
		Rewards = {
			Cash = 25000000000000,
			Multiplier = 16,
			AdditionalLockTime = 160,
			AnimalSlot = 1,
			Items = { "Attack Doge" }
		},
		Requirements = {
			Cash = 1000000000000000,
			RequiredCharacters = { "Los Tralaleritos" }
		}
	},
	{
		Name = "Rebirth 17",
		RebirthNumber = 17,
		Rewards = {
			Cash = 50000000000000,
			Multiplier = 17,
			AdditionalLockTime = 170,
			AnimalSlot = 1,
			Items = { "Giant Potion" }
		},
		Requirements = {
			Cash = 2000000000000000,
			RequiredCharacters = { "Job Job Job Sahur", "Chicleteira Bicicleteira" }
		}
	},
	{
		Name = "Rebirth 18",
		RebirthNumber = 18,
		Rewards = {
			Cash = 100000000000000,
			Multiplier = 18,
			AdditionalLockTime = 180,
			AnimalSlot = 1,
			Items = { "Flash Teleport" }
		},
		Requirements = {
			Cash = 1e16,
			RequiredCharacters = { "Graipuss Medussi" }
		}
	},
	{
		Name = "Rebirth 19",
		RebirthNumber = 19,
		Rewards = {
			Cash = 250000000000000,
			Multiplier = 19,
			AdditionalLockTime = 190,
			AnimalSlot = 1,
			Items = { "Grief Shield" }
		},
		Requirements = {
			Cash = 3e16,
			RequiredCharacters = { "La Grande Combinasion" }
		}
	}
}