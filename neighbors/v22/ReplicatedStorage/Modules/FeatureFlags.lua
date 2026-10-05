local v = {
	FFlagEnableGameModeSelection = false,
	FFlagCustomServerNotifications = false,
	FFlagHandleFullCustomServer = false,
	FFlagHouseCustomization = true,
	FFlagUserTransferAPI = true,
	FFlagParentInactivePrefabs = true,
	FFlagUseClientBaseModels = true,
	FFlagGroupHousesIntoChunks = true,
	FFlagTestAllowTestersAllCommands = false,
	FFlagTestAllowPartyInvitesFromAll = false,
	FFlagTestAwardAllSkinsInTestGame = true
}
return {
	IsEnabled = function(_, p: string)
		return v[p] and true or false
	end
}