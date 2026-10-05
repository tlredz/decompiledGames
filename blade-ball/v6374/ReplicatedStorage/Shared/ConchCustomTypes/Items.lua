local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Shared.ItemInfo)
local v2 = require3(ReplicatedStorage2.Shared.UpdateCrate)
local Items = {
	Names = {}
}

for k, _ in v.Sword do
	table.insert(Items.Names, k)
end

for k, _ in v.Explosion do
	table.insert(Items.Names, k)
end

for k, v3 in v.Emote do
	table.insert(Items.Names, v3.DisplayName or k)
end

table.insert(Items.Names, v2.CurrentCrate)
return Items