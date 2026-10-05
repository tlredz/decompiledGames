local v = {
	TestAttributeKey = "ExpandedLobby.Group",
	ServerTypeAttributeKey = "ExpandedLobby.ServerType",
	Groups = table.freeze({
		Control = "Control",
		Variant = "Variant"
	}),
	UnlockedValue = "None",
	ServerAttribute = "ExpandedLobbyServerGroup",
	TeleportDataKey = "ExpandedLobbyGroup",
	StudioForceAttribute = "ExpandedLobbyForceGroup",
	RemovalTag = "ExpandedLobbyABTestRemoval",
	JobAttributeWaitSeconds = 15,
	ApplyDeadlineSeconds = 120,
	PlotSpread = table.freeze({
		CenterZ = -364.1,
		ZScale = 1.35,
		WestColumnXOffset = -20,
		WestColumnMaxX = 500
	})
}

function v.IsValidGroup(p)
	return p == v.Groups.Control or p == v.Groups.Variant
end

return table.freeze(v)