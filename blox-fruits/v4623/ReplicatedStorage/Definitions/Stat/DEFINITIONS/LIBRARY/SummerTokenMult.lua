local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("\"Summer Token\" Multiplier"):setValueForm("Add1Multiply"):setDescription("Increases the number of \"Summer Token\" materials you gain during the Summer 2025 Event."):setEffectSuffix("\"Summer Token\" gain"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All["Summer Token1"]):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()