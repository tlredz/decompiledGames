local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Max Stats"):setValueForm("Boolean"):setDescription("Swaps stat value with level."):setEffectSuffix("swaps stat value with level."):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Misc):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()