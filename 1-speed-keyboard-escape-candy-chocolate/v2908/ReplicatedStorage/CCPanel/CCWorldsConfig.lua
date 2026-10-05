local CCWorldsConfig = {
	MAX_SET_LEVEL = 2000,
	MAX_SET_WINS = 100000000000000,
	INVITES_ENABLED = true,
	INVITE_TTL = 90,
	INVITE_SEND_COOLDOWN = 5,
	INVITE_MAX_INBOX = 3,
	INVITE_ACK_WINDOW = 8,
	INVITE_NAME_MAX = 20,
	CATEGORIES = {
		{
			id = "auras",
			label = "Give all Auras",
			tabLabel = "Auras"
		},
		{
			id = "trails",
			label = "Give all Trails",
			tabLabel = "Trails"
		},
		{
			id = "items",
			label = "Give all Items",
			tabLabel = "Items"
		},
		{
			id = "treadmills",
			label = "Give all Treadmills + Skins",
			tabLabel = "Treadmills"
		}
	}
}
local v = {}

for _, v2 in CCWorldsConfig.CATEGORIES do
	v[v2.id] = v2
end

CCWorldsConfig.BY_ID = v
return CCWorldsConfig