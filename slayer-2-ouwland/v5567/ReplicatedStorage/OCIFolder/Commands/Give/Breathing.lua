local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Resolve = require(ReplicatedStorage.CAM.Global.Powers.Resolve)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Power = require(ServerStorage.SAM.Services.Adders.Power)
return function(p, p2)
	local resolved, v = Resolve.Resolve(p2)

	if resolved ~= "Breathing" or v.CustomPower == true then
		error((`"{tostring(p2)}" is not a Breathing`))
	end

	local data = Utility.GetData(p)

	if data == nil then
		return
	end

	Power(p, data, p2, "Admin")
end