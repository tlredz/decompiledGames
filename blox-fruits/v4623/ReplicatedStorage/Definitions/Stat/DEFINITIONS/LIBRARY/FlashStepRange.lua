local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Flash Step Range"):setValueForm("RawMultiply"):setDescription("Increases the Flash Step distance."):setEffectSuffix("increased Flash Step range"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All["Flash Step"]):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()