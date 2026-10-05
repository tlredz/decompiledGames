local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return function(list)
	for _, v in ipairs(list) do
		local _, v2 = Utility.GetData(v)

		if v2 == nil then
			continue
		end

		for _, child in ipairs(v2.PlayerTitles.Progress:GetChildren()) do
			child:Destroy()
		end

		for _, child in ipairs(v2.PlayerTitles.Unlocked:GetChildren()) do
			child:Destroy()
		end

		for _, child in ipairs(v2.slots:GetChildren()) do
			child.EquippedTitles.Vanity.Value = ""

			for _, child2 in ipairs(child.EquippedTitles.Boost:GetChildren()) do
				child2.Value = ""
			end
		end
	end
end