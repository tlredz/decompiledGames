local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Air Jumps"):setValueForm("Add"):setDescription("Increases the number of successive Air Jumps you can perform."):setEffectSuffix("Air Jumps"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All["AirJump Small"]):setModifier(
	SpriteMap.All["Up Arrow"],
	color
):build()):build()