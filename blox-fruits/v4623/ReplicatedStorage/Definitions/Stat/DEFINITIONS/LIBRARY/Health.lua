local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Health"):setValueForm("AddOrMultiplyFavorAdd"):setDescription("Increases your maximum Health."):setEffectSuffix("maximum Health"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Health):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()