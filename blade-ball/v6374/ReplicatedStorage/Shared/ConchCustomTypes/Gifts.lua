local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Shared.GiftProductsId)
local Gifts = {
	Names = {},
	Ids = {},
	NameToId = {}
}

for k, v2 in v do
	table.insert(Gifts.Names, k)
	table.insert(Gifts.Ids, v2.productId)
end

return Gifts