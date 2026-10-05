local EXTENSIONS = {
	SECRETS = 200
}
local total = 2800

for _, v2 in EXTENSIONS do
	if type(v2) == "number" then
		total += v2
	end
end

return {
	LEVELS_PER_BONUS_MOMENT = 5,
	LEVEL_CAP = {
		ATTR_KEY = "LevelCap",
		BASE = 2800,
		EXTENSIONS = EXTENSIONS,
		THEORETICAL_MAX = total
	}
}