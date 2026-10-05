local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Gun Points"):setValueForm("Add"):setDescription("Increases your Gun Points."):setEffectSuffix("Gun stat points"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Gun):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()