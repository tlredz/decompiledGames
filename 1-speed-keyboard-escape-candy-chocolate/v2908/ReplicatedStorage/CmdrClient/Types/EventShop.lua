local ReplicatedStorage = game:GetService("ReplicatedStorage")
local eventShops = require(ReplicatedStorage._FRAMEWORK.Features.eventShops)
return function(registry)
	registry:RegisterType("eventShop", registry.Cmdr.Util.MakeEnumType("eventShop", eventShops.getShopIds()))
end