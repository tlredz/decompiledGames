local ReplicatedStorage = game:GetService("ReplicatedStorage")
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return function(p, _: string, p2)
	local name

	if type(p2) == "table" then
		name = p2.name or p2
	else
		name = p2
	end

	local incrementAmount = type(p2) == "table" and p2.incrementAmount or gameSettings.expPerMasteryDefault
	local data = Utility.GetData(p)

	if data == nil then
		return 0
	end

	local child = data.MasteryProgressionList:FindFirstChild(name)

	if child == nil then
		return 0
	end

	local goal = child:FindFirstChild("Goal")

	if goal == nil then
		return 0
	end

	return (math.floor(goal.Value / incrementAmount))
end