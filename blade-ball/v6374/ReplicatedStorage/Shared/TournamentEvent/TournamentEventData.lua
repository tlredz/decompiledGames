local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("RunService")
require3(ReplicatedStorage2.Common.RewardInfo)
local v = require3(ReplicatedStorage2.ServerInfo)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local medalServer = v.isMedalServer()
local unixTimestamp = DateTime.fromUniversalTime(2024, 10, 27, 12, 0).UnixTimestamp
local v3 = {
	EndTime = DateTime.fromUniversalTime(2026, 6, 6, 17, 0),
	GroupsPerTournament = 2,
	PlayersPerParty = NumberRange.new(1, 1),
	AllowNonFullPartiesToQueue = false,
	PartyReplionChannel = "TournamentEventParty",
	FFAMode = "FFA",
	TeamsMode = "2Teams",
	DisplayName = "FFA Tournament",
	ShowBrackets = false,
	Strikes = {
		Enabled = true,
		MaxStrikes = 5,
		ResetEvery = 43200
	},
	EnabledAbilities = { "Tsunami" },
	ForcedAbility = "Tsunami",
	AbilityUpgrade = 1,
	PastTournaments = {
		"SuperGlobal",
		"SquadRoyale",
		"Haunted",
		"SpookyShowdown",
		"SerpentShowdown",
		"GalacticClash",
		"SpringClash",
		"Sunkissed",
		"FloodEscape",
		"FallingPlatforms",
		"FFA1",
		"GenericTournament_1",
		"GenericTournament_2",
		"GenericTournament_3",
		"GenericDuoTournament_1",
		"DuoJanuary2026",
		"GenericDuoTournament_2",
		"GenericDuoTournament_3"
	},
	TournamentId = "GenericTournament_5",
	Currency = {
		Name = "Trophies",
		DisplayName = "Trophies",
		SingularDisplayName = "Trophy",
		Color = Color3.fromRGB(255, 200, 0)
	},
	AllowedRegions = { "US", "EU", "ASIA" },
	RegionMap = {
		MENA = "EU",
		LATAM = "US",
		ASEAN = "ASIA",
		AF = "EU",
		OCE = "ASIA"
	},
	CANCELLED_SYMBOL = "/0",
	MedalQualifierEnd = unixTimestamp
}

if not medalServer then
	return table.freeze(v3)
end

local timeoutFFlag = v2.FFlag.TimeoutFFlag("MedalTournamentEnabled", 10, false)

if DateTime.now().UnixTimestamp <= unixTimestamp or not timeoutFFlag then
	v3.GroupsPerTournament = 2
	v3.Strikes.Enabled = false
	v3.TournamentId = "MedalQualifier"
elseif timeoutFFlag then
	v3.GroupsPerTournament = 13
	v3.Strikes.Enabled = false
	v3.TournamentId = "Medal"
end

return table.freeze(v3)