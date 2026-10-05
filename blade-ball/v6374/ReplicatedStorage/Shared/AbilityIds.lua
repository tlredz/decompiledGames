local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local idsToAbilities = {
	"Dash",
	"Forcefield",
	"Freeze",
	"Infinity",
	"Invisibility",
	"Phase Bypass",
	"Platform",
	"Pull",
	"Raging Deflection",
	"Rapture",
	"Shadow Step",
	"Super Jump",
	"Swap",
	"Telekenisis",
	"Thunder Dash",
	"Waypoint",
	"Wind Cloak",
	"Reaper",
	"Force",
	"Death Slash",
	"Blink",
	"Calming Deflection",
	"Dribble",
	"Flash Counter",
	"Freeze Trap",
	"Phantom",
	"Pulse",
	"Quad Jump",
	"Titan Blade",
	"Continuity Zero",
	"Tact",
	"Serpent Shadow Clone",
	"Quantum Arena",
	"Telekinesis",
	"Martyrdom",
	"Absolute Confidence",
	"Time Hole",
	"Hell Hook",
	"Qi-Charge",
	"Bunny Leap",
	"Dragon Spirit",
	"Singularity",
	"Quasar",
	"Slash of Duality",
	"Chieftain's Totem",
	"Luck",
	"Scopophobia",
	"Water Dragon",
	"Encrypted Clone",
	"Bulk Up",
	"Bounty",
	"Blade Trap",
	"Slashes of Fury",
	"Aerodynamic Slash",
	"Doppelganger",
	"Guardian Angel",
	"Necromancer",
	"Nab",
	"Pinpoint",
	"Misfortune",
	"Golden Ball",
	"Fracture",
	"Parry Counter",
	"Gale's Edge",
	"Ninja Dash",
	"Displace",
	"Event Horizon",
	"Zeus' Storm",
	"Tsunami",
	"Virus"
}
local abilitiesToIds = {}

for k, v3 in next, idsToAbilities, nil do
	abilitiesToIds[v3] = k
end

if RunService:IsServer() and RunService:IsStudio() then
	for _, child in ReplicatedStorage.Misc.DataAbilities:GetChildren() do
		if not table.find(idsToAbilities, child.Name) then
			warn((`Ability {child.Name} is missing from AbilityIds`))
		end
	end
end

return {
	AbilitiesToIds = abilitiesToIds,
	IdsToAbilities = idsToAbilities
}