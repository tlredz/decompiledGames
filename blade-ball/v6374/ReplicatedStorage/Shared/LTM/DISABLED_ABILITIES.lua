local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function allowedAbilities(list)
	local names = {}

	for _, child in ReplicatedStorage.Misc.DataAbilities:GetChildren() do
		if not table.find(list, child.Name) then
			table.insert(names, child.Name)
		end
	end

	return names
end

return {
	Shark = { "Doppelganger" },
	FloodSurvival = {
		"Scopophobia",
		"Quasar",
		"Platform",
		"Serpent Shadow Clone",
		"Freeze Trap",
		"Quad Jump",
		"Swap",
		"Phantom",
		"Waypoint",
		"Super Jump",
		"Flash Counter",
		"Quantum Arena",
		"Wind Cloak",
		"Force",
		"Hell Hook"
	},
	Rebirth = { "Absolute Confidence" },
	Storm = {
		"Hell Hook",
		"Waypoint",
		"Swap",
		"Phantom",
		"Flash Counter",
		"Serpent Shadow Clone",
		"Freeze Trap",
		"Force",
		"Quantum Arena",
		"Quasar"
	},
	Flying = {
		"Serpent Shadow Clone",
		"Bunny Leap",
		"Platform",
		"Hell Hook",
		"Waypoint",
		"Quantum Arena",
		"Super Jump",
		"Quad Jump"
	},
	FallingPlate = {
		"Platform",
		"Quad Jump",
		"Swap",
		"Phantom",
		"Waypoint",
		"Super Jump",
		"Flash Counter",
		"Quantum Arena",
		"Wind Cloak",
		"Hell Hook",
		"Quasar",
		"Slash of Duality",
		"Freeze Trap",
		"Displace",
		"Force"
	},
	LavaFloor = {
		"Scopophobia",
		"Quasar",
		"Platform",
		"Serpent Shadow Clone",
		"Freeze Trap",
		"Quad Jump",
		"Swap",
		"Phantom",
		"Waypoint",
		"Super Jump",
		"Flash Counter",
		"Quantum Arena",
		"Wind Cloak",
		"Force",
		"Hell Hook",
		"Slash of Duality"
	},
	Infected = { "Absolute Confidence" },
	Juggernaut = {
		"Thunder Dash",
		"Quantum Arena",
		"Flash Counter",
		"Phantom",
		"Blink",
		"Swap"
	},
	Dodgeball = {
		"Phantom",
		"Hell Hook",
		"Swap",
		"Flash Counter",
		"Thunder Dash",
		"Quantum Arena",
		"Blink",
		"Absolute Confidence",
		"Slash of Duality",
		"Displace",
		"Doppelganger"
	},
	HotPotato = {
		"Necromancer",
		"Serpent Shadow Clone",
		"Doppelganger",
		"Encrypted Clone",
		"Invisibility",
		"Guardian Angel",
		"Dribble",
		"Platform",
		"Infinity",
		"Martyrdom",
		"Blade Trap",
		"Super Jump",
		"Swap",
		"Dragon Spirit",
		"Phantom"
	},
	HalloweenEvent = allowedAbilities({
		"Dash",
		"Super Jump",
		"Quad Jump",
		"Blink",
		"Titan Blade",
		"Platform",
		"Freeze",
		"Tact",
		"Rapture",
		"Telekinesis",
		"Forcefield",
		"Raging Deflection",
		"Absolute Confidence",
		"Pull",
		"Thunder Dash",
		"Shadow Step",
		"Reaper",
		"Wind Cloak",
		"Phase Bypass",
		"Phantom"
	}),
	MysteryBall = {},
	CrownClash = {
		"Invisibility",
		"Infinity",
		"Doppelganger",
		"Necromancer",
		"Forcefield",
		"Guardian Angel",
		"Luck",
		"Misfortune",
		"Death Slash",
		"Slashes of Fury",
		"Absolute Confidence",
		"Encrypted Clone",
		"Serpent Shadow Clone",
		"Singularity",
		"Quantum Arena",
		"Time Hole"
	},
	WinterRoyale = {},
	Fates = {},
	AbilityGame = {},
	SquadRoyale = {},
	Tag = {
		"Necromancer",
		"Absolute Confidence",
		"Pull",
		"Guardian Angel",
		"Martyrdom"
	},
	Rebound = allowedAbilities({
		"Event Horizon",
		"Continuity Zero",
		"Scopophobia",
		"Hell Hook",
		"Blink",
		"Dash",
		"Force",
		"Chieftain's Totem",
		"Freeze Trap",
		"Phase Bypass",
		"Quasar",
		"Wind Cloak",
		"Waypoint",
		"Thunder Dash",
		"Swap",
		"Shadow Step",
		"Quad Jump"
	}),
	SheriffsVsOutlaws = allowedAbilities({}),
	Soccer = allowedAbilities({ "Dash" })
}