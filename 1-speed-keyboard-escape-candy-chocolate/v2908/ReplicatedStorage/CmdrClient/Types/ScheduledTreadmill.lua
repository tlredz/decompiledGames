local v = { "Hourly", "Daily" }
return function(registry)
	registry:RegisterType("scheduledTreadmill", registry.Cmdr.Util.MakeEnumType("scheduledTreadmill", v))
end