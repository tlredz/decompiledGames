local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = require(ReplicatedStorage.Data.Assets)
local v = {}

for k in pairs(Assets.Directory) do
	table.insert(v, k)
end

table.sort(v)
return function(registry)
	registry:RegisterType("assetName", registry.Cmdr.Util.MakeEnumType("AssetName", v))
end