local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
local FuseMachineData = require(ReplicatedStorage.Datas.FuseMachineData)
local v = {}

for k, luckMultiplier in FuseMachineData.LuckMultipliers do
	if luckMultiplier ~= 1 then
		v[tostring(luckMultiplier)] = k
	end
end

return Conch.register_type("FuseMachineLuck", Conch.args.enum_map(v))