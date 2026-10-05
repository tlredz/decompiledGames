local soundtracks = {
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
}
local assetIds = {}
local v2 = { "rbxassetid://89299104253711", "rbxassetid://137482818664239" }

for _, v3 in soundtracks do
	table.insert(assetIds, v3.AssetId)
end

return {
	mapTemplateName = "RIAMap2026",
	liveMapName = "RIAAdminAbuse2026_Live",
	keycapLoadId = "RIAAdminAbuse2026_Keycaps",
	npcDanceCollisionGroup = "NPCDanceRigs",
	npcDanceAnimationIds = v2,
	soundtracks = soundtracks,
	AAFw_AutoPreloadEnabled = false,
	AAFw_AutoPreloadIDs = {
		music = assetIds,
		animations = v2
	},
	mapWaitTimeoutSeconds = 15,
	useDoorOpeningCutscene = true
}