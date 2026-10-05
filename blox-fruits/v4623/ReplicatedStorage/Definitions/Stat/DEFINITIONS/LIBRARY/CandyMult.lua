local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("\"Candy\" Multiplier"):setValueForm("Multiply"):setDescription("Increases the number of \"Candy\" materials you gain."):setEffectSuffix("\"Candy\" gain"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Candy1):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()