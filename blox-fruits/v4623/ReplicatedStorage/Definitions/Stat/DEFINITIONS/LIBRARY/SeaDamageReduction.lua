local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Sea Damage Reduction"):setValueForm("Add1Multiply"):setDescription("Reduces the damage you take while in the sea with an active Blox Fruit."):setEffectSuffix("Damage reduction from being in the sea with an active Blox Fruit."):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Sea):setModifier(
	SpriteMap.All["Down Arrow"],
	color
):setVariant(SpriteMap.All.LifeLeech):build()):build()