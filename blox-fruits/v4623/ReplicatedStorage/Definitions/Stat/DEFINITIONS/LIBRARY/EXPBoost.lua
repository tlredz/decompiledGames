local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Experience Boost"):setValueForm("Multiply"):setDescription("Increases the amount of Leveling and Mastery Experience you gain."):setEffectSuffix("Leveling and Mastery Experience gain"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.EXPBoost):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()