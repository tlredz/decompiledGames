local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Conch = require(ReplicatedStorage.Packages.Conch)
local Index = require(ReplicatedStorage.Datas.Index)
local v = { "Normal" }

for k, v2 in Index do
	if v2.BaseColors then
		table.insert(v, k)
	end
end

return Conch.register_type("Base Skin", Conch.args.enum_new(v))