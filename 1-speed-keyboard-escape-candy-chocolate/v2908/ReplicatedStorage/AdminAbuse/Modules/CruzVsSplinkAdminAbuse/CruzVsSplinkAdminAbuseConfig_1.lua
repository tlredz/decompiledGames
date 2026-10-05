local v = { "rbxassetid://139017509042833", "rbxassetid://77428789421999", "rbxassetid://90333854759835" }
return {
	MAP_TEMPLATE_NAME = "CruzVsSplinkAdminAbuse",
	MAP_LIVE_NAME = "CruzVsSplinkAdminAbuse_Live",
	STREAMED_KEYCAPS_FOLDER_NAME = "CruzVsSplinkAdminAbuse_Keycaps",
	MAP_LOADED_ATTRIBUTE = "CruzVsSplinkMapLoaded",
	AUDIO_FOLDER_NAME = "CruzVsSplinkAdminAbuseAudio",
	SSE_CHANNEL = "CruzVsSplinkAdminAbuse",
	SSE_RATE_HZ = 20,
	DisplayName = "Cruz Vs Splink AdminAbuse",
	NeedsDuration = false,
	SkipDoorTransition = false,
	IsAdminAbuse = true,
	RequiresRespawnRefire = true,
	HasPrioritySoundtrack = true,
	LIGHTING_CLOCK_TIME_ACTIVE = 14.5,
	LIGHTING_CLOCK_TIME_RESTORE = 14.5,
	LIGHTING_TWEEN_SEC = 3,
	NPC_DANCE_SWITCH_MIN_SEC = 6,
	NPC_DANCE_SWITCH_MAX_SEC = 14,
	NPC_DANCE_COLLISION_GROUP = "NPCDanceRigs",
	NPC_DANCES = { "rbxassetid://89299104253711", "rbxassetid://137482818664239" },
	RIG_DANCES = {
		YoSplink = v,
		ReallyCruz = v
	},
	GRANT_AURA_KEYS = { "CruzAura", "SplinkAura" },
	SUPPORTER_ZONE_TAG = "SplinkVsCruzSupporterZone",
	SUPPORTER_TEAM_ATTRIBUTE = "Team",
	SUPPORTER_BILLBOARD_NAME = "CruzVsSplinkSupporterBillboard",
	SUPPORTER_TEAMS = {
		Cruz = {
			label = "Cruz Fan",
			color = Color3.fromRGB(255, 196, 58),
			stroke = Color3.fromRGB(92, 48, 8)
		},
		Splink = {
			label = "Splink Fan",
			color = Color3.fromRGB(240, 248, 255),
			stroke = Color3.fromRGB(72, 96, 120)
		}
	},
	SOUNDTRACKS = {
		{
			Name = "Reflekt - We've Only Just Begun",
			AssetId = "rbxassetid://81789245198334"
		},
		{
			Name = "Axtasia - Let It Go",
			AssetId = "rbxassetid://104695245037953"
		},
		{
			Name = "Axtasia - The View",
			AssetId = "rbxassetid://94627193867884"
		},
		{
			Name = "TACACHO - Black Swan",
			AssetId = "rbxassetid://120007441962737"
		},
		{
			Name = "Haven - Ding",
			AssetId = "rbxassetid://93970609264491"
		},
		{
			Name = "Echofate & SPOT - Take Me Higher",
			AssetId = "rbxassetid://98090122284200"
		},
		{
			Name = "ROY - Paris Night Walk",
			AssetId = "rbxassetid://81888427712271"
		},
		{
			Name = "ROY - Mily",
			AssetId = "rbxassetid://127176623684925"
		},
		{
			Name = "ROY - Stay",
			AssetId = "rbxassetid://71016572563090"
		},
		{
			Name = "Tobu - Such Fun",
			AssetId = "rbxassetid://100910937626709"
		}
	},
	CROSSFADE_DURATION_SEC = 0.5
}