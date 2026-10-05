local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Variant.Builder.new(script.Name, script.Parent.Parent.Name):setDescription("Increases your Damage with Blox Fruit attacks."):setEffectSuffix("Damage with Blox Fruit attacks"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Fruit):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()