local CachedUserInfo = {}

for _, v in pairs({
	{
		Name = "Roblox",
		DisplayName = "Roblox",
		UserId = 1
	},
	{
		Name = "rip_indra",
		DisplayName = "rip_indra",
		UserId = 3095250
	},
	{
		Name = "mygame43",
		DisplayName = "mygame43",
		UserId = 912348
	},
	{
		Name = "KittGaming",
		DisplayName = "StarCode_kitt",
		UserId = 2333758830
	},
	{
		Name = "enyoo",
		DisplayName = "EnyuZee",
		UserId = 2590193767
	},
	{
		Name = "Uzoth",
		DisplayName = "Uzoth",
		UserId = 17884881
	},
	{
		Name = "rip_zioles",
		DisplayName = "Zioles",
		UserId = 120173604
	}
}) do
	CachedUserInfo[tostring(v.UserId)] = v
	CachedUserInfo[v.DisplayName:lower()] = v
	CachedUserInfo[v.Name:lower()] = v
end

return CachedUserInfo