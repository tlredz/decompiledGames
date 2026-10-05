local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return function(list, p: string)
	for _, v in ipairs(list) do
		local getData = Utility.GetData(v, true)
		getData.Race.Value = p
	end
end