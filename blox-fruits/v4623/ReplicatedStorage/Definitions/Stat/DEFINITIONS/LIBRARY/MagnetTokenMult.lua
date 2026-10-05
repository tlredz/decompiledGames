local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("`Magnet Token` Multiplier"):setValueForm("Multiply"):setDescription("Increases the number of \"Magnet Token\" materials you gain during the Summer 2026 Magnet Event."):setEffectSuffix("\"Magnet Token\" gain"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All["Magnet Token1"]):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()