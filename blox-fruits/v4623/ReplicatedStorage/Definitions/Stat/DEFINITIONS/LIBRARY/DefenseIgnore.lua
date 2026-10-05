local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Ignore Defense"):setValueForm("Add1Multiply"):setDescription("Increases the amount of Defense you ignore on attacks."):setEffectSuffix("Defense ignored"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Misc):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()