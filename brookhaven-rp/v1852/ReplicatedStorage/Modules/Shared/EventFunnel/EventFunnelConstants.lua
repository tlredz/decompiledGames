local EventFunnelConstants = {
	LoadingEvents = {
		beginIntroScript = "beginIntroScript",
		waitingForPlayerGui = "waitingForPlayerGui",
		loadingModules = "loadingModules",
		waitingForInstances = "waitingForInstances",
		waitingForGameSettingsModule = "waitingForGameSettingsModule",
		waitingForCharacter = "waitingForCharacter",
		waitingForCharacterInstances = "waitingForCharacterInstances",
		openingIntroGui = "openingIntroGui",
		playButtonShown = "playButtonShown",
		playButtonClicked = "playButtonClicked"
	}
}
EventFunnelConstants.LoadingOrder = {
	EventFunnelConstants.LoadingEvents.beginIntroScript,
	EventFunnelConstants.LoadingEvents.waitingForPlayerGui,
	EventFunnelConstants.LoadingEvents.loadingModules,
	EventFunnelConstants.LoadingEvents.waitingForInstances,
	EventFunnelConstants.LoadingEvents.waitingForGameSettingsModule,
	EventFunnelConstants.LoadingEvents.waitingForCharacter,
	EventFunnelConstants.LoadingEvents.waitingForCharacterInstances,
	EventFunnelConstants.LoadingEvents.openingIntroGui,
	EventFunnelConstants.LoadingEvents.playButtonShown,
	EventFunnelConstants.LoadingEvents.playButtonClicked
}
EventFunnelConstants.GeneralEvents = {
	playInitiated = "playInitiated"
}
return EventFunnelConstants