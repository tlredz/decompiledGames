local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Quests = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.Quests)
return function(list)
	for _, v in ipairs(list) do
		local data = Utility.GetData(v)

		if data == nil then
			continue
		end

		for _, child in ipairs(data.Quests.Holder:GetChildren()) do
			Quests.DeleteQuest(v, child)
		end

		local completed = data.Quests:FindFirstChild("Completed")

		if completed == nil then
			continue
		end

		for _, child in ipairs(completed:GetChildren()) do
			child:Destroy()
		end
	end
end