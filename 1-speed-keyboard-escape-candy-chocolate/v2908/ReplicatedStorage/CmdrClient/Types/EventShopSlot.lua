local ReplicatedStorage = game:GetService("ReplicatedStorage")
local eventShops = require(ReplicatedStorage._FRAMEWORK.Features.eventShops)
return function(registry)
	registry:RegisterType(
		"eventShopSlot",
		registry.Cmdr.Util.MakeEnumType("eventShopSlot", eventShops.getBaseSlotIds())
	)
end