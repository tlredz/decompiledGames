local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Energy Regeneration"):setValueForm("Add1Multiply"):setDescription("Increases your Energy Regeneration rate."):setEffectSuffix("Energy per second"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Energy):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):setVariant(
	SpriteMap.All.Plus,
	color
):build()):build()