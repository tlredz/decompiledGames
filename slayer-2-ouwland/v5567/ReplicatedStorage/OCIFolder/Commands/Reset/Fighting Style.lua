local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Power = require(ServerStorage.SAM.Services.Removers.Power)
return function(list, value: string?)
	for _, v in ipairs(list) do
		local data = Utility.GetData(v)

		if data == nil then
			continue
		end

		local fightingStyle = data.Powers.FightingStyle

		if not (value == nil or fightingStyle.Value:lower() == value:lower()) then
			continue
		end

		Power(v, data, "FightingStyle")
	end
end