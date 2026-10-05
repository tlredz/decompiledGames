local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Power = require(ServerStorage.SAM.Services.Removers.Power)
return function(list)
	for _, v in ipairs(list) do
		local data = Utility.GetData(v)

		if data ~= nil then
			Power(v, data, "DemonArt")
		end
	end
end