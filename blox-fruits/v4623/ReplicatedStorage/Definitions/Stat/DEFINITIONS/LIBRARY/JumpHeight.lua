local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Jump Height"):setValueForm("AddOrMultiply"):setDescription("Increases your jump height."):setEffectSuffix("Jump height increase"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Misc):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()