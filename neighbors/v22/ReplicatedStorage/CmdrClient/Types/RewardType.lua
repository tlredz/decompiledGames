return function(registry)
	registry:RegisterType("rewardtype", registry.Cmdr.Util.MakeEnumType("Credits", {
		"Credits",
		"Tool",
		"Points",
		"Playtime",
		"CandyCanes"
	}))
end