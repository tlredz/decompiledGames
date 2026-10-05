local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Variant.Builder.new(script.Name, script.Parent.Parent.Name):setDescription("Increases your Damage Resistance against all attack types."):setEffectSuffix("Damage Resistance against all attacks"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Resist):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()