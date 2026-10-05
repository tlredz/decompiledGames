require(script.Parent.Types)
local v = {
	{
		id = "Main",
		label = "MAIN"
	},
	{
		id = "Bbno2026",
		label = "BBNO$"
	},
	{
		id = "SummerEvent",
		label = "SUMMER"
	},
	{
		id = "SteakEvent",
		label = "STEAK"
	},
	{
		id = "CruzVsSplinkAdminAbuse",
		label = "CRUZ VS SPLINK"
	},
	{
		id = "RIAAdminAbuse2026",
		label = "RIA"
	},
	{
		id = "Halloween2026",
		label = "HALLOWEEN"
	}
}
local ids = {}

for _, v2 in v do
	if v2.id ~= "Main" then
		table.insert(ids, v2.id)
	end
end

return {
	ENABLED = true,
	BUTTON_EMOJI = "📖",
	BUTTON_COLOR = Color3.fromRGB(86, 108, 214),
	BUTTON_LAYOUT_ORDER = 11,
	MODAL_VISIBLE_Y = 0.45,
	STAT_LABEL = "XP",
	MAIN_CATEGORY = "Main",
	ITEM_CATEGORIES = v,
	CATEGORIES = {
		{
			id = "all",
			label = "ALL"
		},
		{
			id = "main",
			label = "MAIN",
			categories = { "Main" }
		},
		{
			id = "events",
			label = "EVENTS",
			categories = ids
		}
	},
	OWNERSHIP_POLL_SECONDS = 2
}