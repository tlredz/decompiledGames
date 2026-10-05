local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Melee Points"):setValueForm("Add"):setDescription("Increases your Melee Points."):setEffectSuffix("Melee stat points"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Melee):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()