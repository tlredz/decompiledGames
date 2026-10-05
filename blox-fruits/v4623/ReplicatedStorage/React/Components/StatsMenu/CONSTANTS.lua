local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.React.Components.StatsMenu.Types)
return {
	STATS = {
		{
			Key = "Melee",
			Name = "Melee",
			Description = "Increases Melee damage & Energy",
			Icon = SpriteMap.Stats.Melee,
			IconOutline = SpriteMap.Stats.Melee_Outline,
			NameColor = Color3.fromRGB(255, 146, 146),
			FadeColor = Color3.fromRGB(255, 123, 123)
		},
		{
			Key = "Defense",
			Name = "Defense",
			Description = "Increases Health",
			Icon = SpriteMap.Stats.Resist,
			IconOutline = SpriteMap.Stats.Resist_Outline,
			NameColor = Color3.fromRGB(115, 178, 255),
			FadeColor = Color3.fromRGB(88, 138, 255)
		},
		{
			Key = "Sword",
			Name = "Sword",
			Description = "Increases Sword damage",
			Icon = SpriteMap.Stats.Sword,
			IconOutline = SpriteMap.Stats.Sword_Outline,
			NameColor = Color3.fromRGB(173, 255, 106),
			FadeColor = Color3.fromRGB(141, 255, 92),
			IsLocked = true
		},
		{
			Key = "Gun",
			Name = "Gun",
			Description = "Increases Gun damage",
			Icon = SpriteMap.Stats.Gun,
			IconOutline = SpriteMap.Stats.Gun_Outline,
			NameColor = Color3.fromRGB(255, 217, 65),
			FadeColor = Color3.fromRGB(255, 217, 65)
		},
		{
			Key = "Demon Fruit",
			Name = "Blox Fruit",
			Description = "Increases Blox Fruits damage",
			Icon = SpriteMap.Stats.Fruit,
			IconOutline = SpriteMap.Stats.Fruit_Outline,
			NameColor = Color3.fromRGB(220, 164, 255),
			FadeColor = Color3.fromRGB(205, 125, 255)
		}
	}
}