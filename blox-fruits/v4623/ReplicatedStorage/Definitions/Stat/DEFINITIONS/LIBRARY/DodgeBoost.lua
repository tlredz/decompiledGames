local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Instinct Dodge Boost"):setValueForm("Add"):setDescription("Increases the number of successive Dodges you can perform with Instinct."):setEffectSuffix("Instinct Dodge"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.DodgeBoost):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()