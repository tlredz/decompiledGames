local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Variant.Builder.new(script.Name, script.Parent.Parent.Name):setDescription("Increases your Material Drop Rate for enemies killed in Sea Events."):setEffectSuffix("Material Drop Rate for enemies killed in Sea Events"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Material):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):setVariant(SpriteMap.All.Sea):build()):build()