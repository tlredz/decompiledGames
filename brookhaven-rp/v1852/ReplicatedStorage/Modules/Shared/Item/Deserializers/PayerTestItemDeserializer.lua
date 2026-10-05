local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemDeserializer = require(ReplicatedStorage.Modules.Shared.Item.ItemDeserializer)
require(ReplicatedStorage.Modules.Shared.Item.Items.PayerTestItem)
require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
require(ReplicatedStorage.Modules.Shared.PlayerData.Gamepasses)
ItemDeserializer.RegisterDeserializer("PayerTestItem", {}, function(_)
	error("not implemented")
end)
return {}