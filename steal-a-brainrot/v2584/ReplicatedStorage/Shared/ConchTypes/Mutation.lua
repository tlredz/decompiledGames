local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
local Mutations = require(ReplicatedStorage.Datas.Mutations)
local v = { "Normal" }

for k in Mutations do
	table.insert(v, k)
end

return Conch.register_type("Mutation", Conch.args.enum_new(v))