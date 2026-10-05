local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Air Jump Efficiency"):setValueForm("RawMultiply"):setDescription("Decreases the Energy cost of Air Jumps."):setEffectSuffix("Air Jump efficiency"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Energy):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):setVariant(SpriteMap.All["AirJump Small"]):build()):build()