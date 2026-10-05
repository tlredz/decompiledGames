local v = {
	MoonIcon = "rbxassetid://123238464128459",
	SunIcon = "rbxassetid://130840067449110",
	SleepIconFadeSeconds = 0.2,
	NightIconFadeOutSeconds = 1,
	NightLightingTransitionSeconds = 5,
	NightLightingStartDelaySeconds = 2,
	DayLightingTransitionSeconds = 5,
	WallCountdownDelayAfterDayStartsSeconds = 2,
	WallCountdownSeconds = 3,
	WallServerEntryGuardStartDelaySeconds = 0.25,
	WallEntryPenetrationBufferStuds = 3,
	WallEntryReturnBufferStuds = 3,
	WallEntryRollbackSampleMaxAgeSeconds = 1,
	TeleportFadeSeconds = 0.2,
	TeleportFadeHoldSeconds = 0.2,
	MusicTransitionSeconds = 1,
	LightingModifierPriority = 100,
	NightLighting = {
		Ambient = Color3.fromRGB(210, 210, 210),
		Brightness = 3,
		ClockTime = 3.1,
		ColorShift_Bottom = Color3.fromRGB(41, 50, 171),
		ColorShift_Top = Color3.fromRGB(154, 204, 250),
		OutdoorAmbient = Color3.fromRGB(89, 107, 102)
	},
	NightMusic = {
		Id = 130775373,
		Volume = 0.5
	},
	DayTransitionSoundId = nil
}
return table.freeze(v)