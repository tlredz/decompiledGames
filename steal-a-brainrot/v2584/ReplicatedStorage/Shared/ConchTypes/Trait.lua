local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
require(ReplicatedStorage.Datas.Animals)
local Traits = require(ReplicatedStorage.Datas.Traits)
local v = {}

for k in Traits do
	table.insert(v, k)
end

return Conch.register_type("Trait", Conch.args.enum_new(v))