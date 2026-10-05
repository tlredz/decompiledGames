local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Sword Points"):setValueForm("Add"):setDescription("Increases your Sword Points."):setEffectSuffix("Sword stat points"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Sword):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()