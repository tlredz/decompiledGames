local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
require(ReplicatedStorage.Datas.Index)
local names = {}

for _, child in ReplicatedStorage.Models.TsunamiWaves:GetChildren() do
	table.insert(names, child.Name)
end

return Conch.register_type("Tsunami Wave", Conch.args.enum_new(names))