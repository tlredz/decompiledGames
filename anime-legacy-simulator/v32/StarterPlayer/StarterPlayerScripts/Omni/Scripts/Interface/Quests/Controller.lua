local module = require("@game/ReplicatedStorage/Omni")
local Controller = {
	CurrentQuest = nil,
	CurrentCategory = "Main",
	QuestChanged = module.Libs.GoodSignal.new(),
	CategoryChanged = module.Libs.GoodSignal.new()
}

function Controller.SetCategory(currentCategory: string)
	if currentCategory == Controller.CurrentCategory then
		return
	end

	Controller.CurrentQuest = nil
	Controller.CurrentCategory = currentCategory
	Controller.CategoryChanged:Fire()
end

function Controller.SetQuest(currentQuest: string)
	if Controller.CurrentQuest == currentQuest then
		Controller.CurrentQuest = nil
	else
		Controller.CurrentQuest = currentQuest
	end

	Controller.QuestChanged:Fire()
end

return Controller