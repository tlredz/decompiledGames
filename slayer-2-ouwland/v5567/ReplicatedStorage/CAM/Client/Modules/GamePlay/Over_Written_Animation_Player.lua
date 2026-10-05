local Run_Handler = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Client"):WaitForChild("Modules"):WaitForChild("GamePlay"):WaitForChild("Run_Handler"))
return {
	Curernt_Anims_Playing = {
		Run = {},
		Idles = {}
	},
	Weights = {
		Run = 2,
		Idles = 1,
		Walks = 1.5
	},
	Movement_Weight_Equipped = "None",
	Get_movement_anim_eq = function()
		if Run_Handler.Is_Running == true then
			return "run"
		end

		return ""
	end
}