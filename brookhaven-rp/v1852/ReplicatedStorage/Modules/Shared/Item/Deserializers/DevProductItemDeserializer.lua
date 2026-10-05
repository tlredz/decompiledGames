local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemDeserializer = require(ReplicatedStorage.Modules.Shared.Item.ItemDeserializer)
local DevProductItem = require(ReplicatedStorage.Modules.Shared.Item.Items.DevProductItem)
local DevProducts = require(ReplicatedStorage.Modules.Shared.PlayerData.DevProducts)
local t = require(ReplicatedStorage.Packages.t)
ItemDeserializer.RegisterDeserializer("DevProductItem", {
	"Name",
	"DevProduct",
	"DisplayName",
	"Event",
	"Icon",
	"Unlockable",
	"Enabled",
	"Message",
	"Flag",
	"AdCategory"
}, function(p, p2, p3, p4, p5, p6, p7, p8, p9, p10)
	assert(t.optional(t.string)(p10))
	local v = assert(DevProducts.All[p2], "dev product does not exist")
	return DevProductItem.new(p, v, p3, p4, p5, p6, p7 == true, p8, p9, p10)
end)
return {}