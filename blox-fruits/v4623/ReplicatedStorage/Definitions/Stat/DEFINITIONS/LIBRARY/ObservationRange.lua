local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Instinct Vision Range"):setValueForm("RawMultiply"):setDescription("Increases the range of your Instinct vision."):setEffectSuffix("larger Instinct vision"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All["Instinct Small"]):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()