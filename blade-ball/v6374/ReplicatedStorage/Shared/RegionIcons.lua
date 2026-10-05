return (setmetatable({
	GLOBAL = "🌎",
	NA = "🇺🇸",
	EU = "🇪🇺",
	LATAM = "🇧🇷",
	MENA = "🇸🇦",
	OCE = "🇦🇺",
	ASEAN = "🇮🇩",
	ASIA = "🇨🇳",
	AF = "🇳🇬",
	[""] = ""
}, {
	__index = function()
		return "📍 LOCAL: "
	end
}))