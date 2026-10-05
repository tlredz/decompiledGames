local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Damage To Energy Rate"):setValueForm("RawMultiply"):setDescription("Takes a portion of damage and passively convertes it to Energy."):setEffectSuffix("Damage to Energy Rate"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Energy):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):setVariant(SpriteMap.All.Resist):build()):build()