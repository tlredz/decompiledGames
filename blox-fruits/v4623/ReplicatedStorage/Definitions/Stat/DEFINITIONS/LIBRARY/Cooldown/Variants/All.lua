local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Variant.Builder.new(script.Name, script.Parent.Parent.Name):setDescription("Reduces the cooldown time of all your skills."):setEffectSuffix("cooldown for all your skills"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.Cooldown):setModifier(
	SpriteMap.All["Down Arrow"],
	color
):build()):build()