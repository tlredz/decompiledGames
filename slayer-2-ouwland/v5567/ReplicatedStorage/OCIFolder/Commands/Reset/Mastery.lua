local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return function(list, childName: string?)
	for _, v in ipairs(list) do
		local data = Utility.GetData(v)

		if data == nil then
			continue
		end

		local masteryProgressionList = data:FindFirstChild("MasteryProgressionList")

		if masteryProgressionList == nil then
			continue
		end

		if childName == nil or childName == "" then
			for _, child in ipairs(masteryProgressionList:GetChildren()) do
				child:Destroy()
			end
		else
			local child = masteryProgressionList:FindFirstChild(childName)

			if child ~= nil then
				child:Destroy()
			end
		end
	end
end