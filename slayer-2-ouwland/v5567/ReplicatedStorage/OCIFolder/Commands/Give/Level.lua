local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Exp = require(ServerStorage.SAM.Services.Adders.Exp)
local gameSettings = require(ReplicatedStorage.CAM.Global.gameSettings)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
return function(p, p2: number)
	if p then
		local data = Utility.GetData(p)

		if data == nil then
			return
		end

		local v = data.Exp.Goal.Value / gameSettings.expPerLevel
		local v2 = math.max(1 - v, p2)
		Exp(p, data, gameSettings.expPerLevel / 2 * v2 * (2 * v + v2 - 1) - data.Exp.Current.Value, "Admin")
	end
end