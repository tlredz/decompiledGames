local Builders = require(game.ReplicatedStorage.Definitions.Stat.Builders)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
require(game.ReplicatedStorage.Definitions.Stat.Types)
local color = Color3.fromHex("#03FF2D")
return Builders.Stat.Builder.new(script.Name):setDisplayName("Terror Level Vision Improvement"):setValueForm("Add1Multiply"):setDescription("Enhances your vision while at Sea Danger Level 6."):setEffectSuffix("enhanced vision at Sea Danger Level 6"):setIcon(Builders.Icon.Builder.new():setMain(SpriteMap.All.TerrorReducer):setModifier(
	SpriteMap.All["Down Arrow"],
	color
):build()):build()