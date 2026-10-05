local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Dash Speed"):setValueForm("Add1Multiply"):setDescription("Increases your Dash Speed."):setEffectSuffix("Dash speed"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.SpeedMultiplier):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()