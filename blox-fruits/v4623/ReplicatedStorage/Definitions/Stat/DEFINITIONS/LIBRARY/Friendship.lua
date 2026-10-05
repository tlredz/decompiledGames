local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Friendship Boost"):setValueForm("Multiply"):setDescription("Increases the amount of Friendship you gain during the Valentines event"):setEffectSuffix("Friendship boost"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Hearts1):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()