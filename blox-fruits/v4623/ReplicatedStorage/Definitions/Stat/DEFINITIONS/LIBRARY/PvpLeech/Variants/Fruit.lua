local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Variant.Builder.new(script.Name, script.Parent.Parent.Name):setDescription("Increases your Life Leech on Blox Fruit attacks against other Players."):setEffectSuffix("Life Leech on Blox Fruit attacks against other Players"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.LifeLeech):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):setVariant(SpriteMap.All.Fruit):build()):build()