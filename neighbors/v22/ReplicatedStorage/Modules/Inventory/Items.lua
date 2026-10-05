local Items = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items2 = require(ReplicatedStorage.Assets.Data.Store.Items)
require(ReplicatedStorage.Modules.Stats)
Items.Items = {}

function Items.GetItem(_, p: string)
	return Items.Items[p]
end

for k, item in next, Items2, nil do
	local clone = table.clone(item)
	clone.IsOwned = true
	clone.IsEquipped = true
	clone.Skins = {}
	Items.Items[k] = clone
end

return Items