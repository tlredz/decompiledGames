require(script.Parent.Parent.modules.Worlds)
local v = {
	[0] = "Angler",
	"Barracuda",
	"Caster",
	"Drifter",
	"Eel",
	"Fisherman",
	"Grouper",
	"Harpoon",
	"Isopod",
	"Jellyfish",
	"Kraken",
	"Lobster",
	"Marlin",
	"Nautilus",
	"Orca",
	"Piranha"
}
local v2 = {
	["0"] = 0,
	["1"] = 1,
	["2"] = 2,
	["3"] = 3,
	["4"] = 4,
	["5"] = 5,
	["6"] = 6,
	["7"] = 7,
	["8"] = 8,
	["9"] = 9,
	a = 10,
	b = 11,
	c = 12,
	d = 13,
	e = 14,
	f = 15
}
return {
	REFRESH_INTERVAL = 60,
	EXPIRATION = 120,
	WRITE_DEBOUNCE = 5,
	CLIENT_POLL_COOLDOWN = 10,
	CACHE_TTL = 10,
	MAX_SERVERS_PER_QUERY = 200,
	MAP_PREFIX = "SB",
	BrowsablePlaces = {
		{
			name = "Trade Plaza",
			placeIds = { 99519129453387 }
		}
	},
	generateServerName = function(value: string)
		local v3 = string.gsub(string.lower(value), "-", "")
		local v4 = v2[string.sub(v3, 1, 1)] or 0
		local v5 = v2[string.sub(v3, 2, 2)] or 0
		local v6 = v2[string.sub(v3, 3, 3)] or 0
		local v7 = string.sub(v3, 4, 11)
		return (`{v[v4]} {v[v5]} {v[v6]} # {v7}`)
	end
}