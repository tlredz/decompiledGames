return function(registry)
	registry:RegisterType("scrambleAction", registry.Cmdr.Util.MakeEnumType("Scramble action", {
		"status",
		"start",
		"stop",
		"drops",
		"scrap",
		"reactor",
		"augmented",
		"quest",
		"drone",
		"reset",
		"complete"
	}))
end