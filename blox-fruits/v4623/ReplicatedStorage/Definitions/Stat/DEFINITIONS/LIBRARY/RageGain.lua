local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Fruit Meter Boost"):setValueForm("Add1Multiply"):setDescription("Increases the rate at which your Fruit Meter fills up."):setEffectSuffix("Fruit Meter gain"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Fruit):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):setVariant(SpriteMap.All.RageGain):build()):build()