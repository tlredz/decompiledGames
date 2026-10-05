local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
local Animals = require(ReplicatedStorage.Datas.Animals)
local v = {}

for k, _ in Animals do
	table.insert(v, k)
end

return Conch.register_type("Brainrot or Lucky Block", Conch.args.enum_new(v))