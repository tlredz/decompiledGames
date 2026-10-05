return {
	Btn = 1,
	SortOrder = 1,
	Val = "AutoUse",
	Desc = "Automatically use skills when pressing keys",
	Callback = function(_)
		local Knit = require(game.ReplicatedStorage.Knit.Knit)
		local getController = Knit.GetController("ToolController")
		getController.Selected.Value = nil
	end
}