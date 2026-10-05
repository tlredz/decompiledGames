local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
require(ReplicatedStorage.Datas.Animals)
require(ReplicatedStorage.Datas.Items)
local names = {}

for _, child in ReplicatedStorage.Items:GetChildren() do
	table.insert(names, child.Name)
end

return Conch.register_type("Item", Conch.args.enum_new(names))