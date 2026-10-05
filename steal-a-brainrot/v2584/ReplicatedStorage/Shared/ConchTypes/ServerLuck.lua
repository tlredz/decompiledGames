local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
local ServerLuck = require(ReplicatedStorage.Datas.ServerLuck)
local v = {}

for k, v2 in ServerLuck do
	v[tostring(v2.Multiplier)] = k
end

return Conch.register_type("ServerLuck", Conch.args.enum_map(v))