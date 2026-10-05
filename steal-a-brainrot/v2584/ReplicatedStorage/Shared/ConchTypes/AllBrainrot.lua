local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
local Animals = require(ReplicatedStorage.Datas.Animals)
local v = {}

for k, animal in Animals do
	if not animal.LuckyBlock then
		table.insert(v, k)
	end
end

return Conch.register_type("AllBrainrot", Conch.args.enum_new(v))