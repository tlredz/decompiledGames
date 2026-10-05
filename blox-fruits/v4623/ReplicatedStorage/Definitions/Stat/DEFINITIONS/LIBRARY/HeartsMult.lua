local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("\"Hearts\" Multiplier"):setValueForm("Multiply"):setDescription("Increases the number of \"Hearts\" material you gain."):setEffectSuffix("\"Hearts\" gain"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Hearts1):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()