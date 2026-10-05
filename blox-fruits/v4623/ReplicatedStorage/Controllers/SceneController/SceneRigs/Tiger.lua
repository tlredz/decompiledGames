local SceneControllerUtil = require(game.ReplicatedStorage.Controllers.SceneController.SceneControllerUtil)
local Yeti = require(game.ReplicatedStorage.Controllers.SceneController.SceneRigs.Yeti)
return {
	Prewarm = function()
		SceneControllerUtil.prewarmVFX({ "Tiger" })
		SceneControllerUtil.prewarmVFX({ "Werewolf (Tiger)-Werewolf (Tiger)" })
	end,
	new = Yeti.new
}