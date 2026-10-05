local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Assets = require(ReplicatedStorage.Data.Assets)
local personalities = Assets.Personalities
local v = {}

for k in pairs(personalities.Personalities) do
	table.insert(v, k)
end

table.sort(v)
return function(registry)
	registry:RegisterType("personality", registry.Cmdr.Util.MakeEnumType("Personality", v))
end