local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Variant.Builder.new(script.Name, script.Parent.Parent.Name):setDescription("Increases your Damage with all attacks against Sea Events."):setEffectSuffix("Damage with attacks against Sea Events"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Sea):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()