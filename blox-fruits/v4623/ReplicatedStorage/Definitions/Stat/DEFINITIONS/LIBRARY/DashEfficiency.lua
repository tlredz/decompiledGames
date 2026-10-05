local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Dash Efficiency"):setValueForm("RawMultiply"):setDescription("Decreases the Energy cost of Dashing."):setEffectSuffix("Dash efficiency"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Energy):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):setVariant(SpriteMap.All.DashLength):build()):build()