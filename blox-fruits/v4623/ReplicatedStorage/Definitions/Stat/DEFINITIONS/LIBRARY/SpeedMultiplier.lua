local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Movement Speed"):setValueForm("Add1Multiply"):setDescription("Increases your Movement Speed."):setEffectSuffix("Movement Speed"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.SpeedMultiplier):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()