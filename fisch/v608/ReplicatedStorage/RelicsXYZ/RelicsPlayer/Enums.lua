local v = {
	WindowTab = {
		Collect = 0,
		Library = 1,
		Customize = 2,
		Upsell = 3
	},
	WindowState = {
		Full = 0,
		Compact = 1,
		Minimized = 2,
		Hidden = 3
	},
	UserStatus = {
		None = 0,
		Freemium = 1,
		TrialMode = 2,
		BoomboxPurchased = 3
	}
}
local v2 = {}

for _, v3 in pairs(v) do
	v2[v3] = {}

	for k, v4 in pairs(v3) do
		v2[v3][v4] = k
	end
end

function v.GetName(p, p2: number)
	local v3 = v2[p]
	return v3 and v3[p2] or nil
end

return table.freeze(v)