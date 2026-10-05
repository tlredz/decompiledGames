local module = require("../localizedevents")
local EventFlags = {
	SovereignBeam = {
		Prefix = "in",
		DisplayName = "Sovereign Beams"
	},
	ApolloLightBeam = {
		Prefix = "in",
		DisplayName = "Light Beams"
	},
	ChargedZeusPool = {
		Prefix = "in",
		DisplayName = "Fully-Charged Water Bodies"
	},
	CursedStorm = {
		Prefix = "in",
		DisplayName = "Cursed Storms"
	},
	SoulScourge = {
		Prefix = "during",
		DisplayName = "Soul Scourge"
	},
	SoulPool = {
		Prefix = "in",
		DisplayName = "Soul Pools"
	},
	WispHauntZone = {
		Prefix = "in",
		DisplayName = "Wisp Haunts"
	},
	PoseidonWhirlpool = {
		Prefix = "in",
		DisplayName = "Poseidon's Whirlpools"
	}
}

for k, v in module do
	if not EventFlags[k] then
		EventFlags[k] = {
			Prefix = "during",
			DisplayName = v.DisplayName
		}
	end
end

local module2 = require("../weathers")

for k, v in module2 do
	if EventFlags[k] then
		continue
	end

	local displayName

	if v.Group == "main" then
		displayName = `{v.DisplayName} Weather`
	else
		displayName = v.DisplayName
	end

	EventFlags[k] = {
		Prefix = "during",
		DisplayName = displayName
	}
end

return EventFlags