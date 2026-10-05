local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(script.Parent.Types)
local CruzVsSplinkAdminAbuseConfig = require(ReplicatedStorage.AdminAbuse.Modules.CruzVsSplinkAdminAbuse.CruzVsSplinkAdminAbuseConfig)
local runAnimations = {
	[Enum.HumanoidRigType.R6] = "rbxassetid://180426354",
	[Enum.HumanoidRigType.R15] = "rbxassetid://507767714"
}
return {
	hosts = {
		{
			moduleName = "CruzVsSplinkAdminAbuse",
			mapLiveName = CruzVsSplinkAdminAbuseConfig.MAP_LIVE_NAME,
			mapLoadedAttribute = CruzVsSplinkAdminAbuseConfig.MAP_LOADED_ATTRIBUTE
		}
	},
	defaultRigsPath = "Scriptables/NPCs",
	defaultRigNames = { "YoSplink", "ReallyCruz" },
	defaultZoneName = "ChaseZone",
	mapSettleSec = 6,
	chaserArchetypeId = "SurvivalChaser",
	chaserScale = 1,
	chaserScaleRelativeToSource = true,
	chaserSpawnOffsetStuds = 15,
	chaserSpeedBonus = 2,
	chaserFallbackWalkSpeed = 16,
	chaserShowHighlight = true,
	chaserCollisionGroup = "SurvivalChaser",
	chaserCollidableGroups = { "Default" },
	chaseUpdateSec = 0.2,
	catchPartNames = {
		"Torso",
		"Left Leg",
		"Right Leg",
		"UpperTorso",
		"LowerTorso",
		"LeftLowerLeg",
		"RightLowerLeg",
		"LeftFoot",
		"RightFoot"
	},
	catchMaxPartsPerQuery = 12,
	targetHoldSec = 4,
	chaseTickSec = 0.5,
	respawnDelaySec = 3,
	zoneShrinkFactor = 1,
	zoneMarginStuds = 3,
	fallRescueStuds = 60,
	zoneDebugVisible = false,
	floorDetectDepthStuds = 20,
	floorLevelToleranceStuds = 0.5,
	zoneHeightStuds = 60,
	zoneExtendDownStuds = 10,
	floorProbeUpStuds = 4,
	floorProbeDepthStuds = 30,
	moveNoiseAmplitudeStuds = 6,
	moveNoiseFrequency = 0.7,
	moveNoiseFadeDistanceStuds = 14,
	rewardFillSeconds = 5,
	rewardOutsideDepleteSeconds = 10,
	rewardAwardDivisor = 100,
	rewardStreakMultipliers = {
		{
			afterSeconds = 0,
			multiplier = 1
		},
		{
			afterSeconds = 15,
			multiplier = 1.5
		},
		{
			afterSeconds = 30,
			multiplier = 2
		},
		{
			afterSeconds = 45,
			multiplier = 2.5
		},
		{
			afterSeconds = 60,
			multiplier = 3
		},
		{
			afterSeconds = 75,
			multiplier = 4
		},
		{
			afterSeconds = 90,
			multiplier = 6
		},
		{
			afterSeconds = 120,
			multiplier = 10
		}
	},
	rewardSource = "SurvivalChase:Survival",
	mapPollIntervalSec = 0.25,
	mapWaitTimeoutSec = 90,
	npcTag = "AABossNpc",
	runAnimations = runAnimations,
	runAnimationReferenceSpeed = 16,
	runAnimationMinSpeed = 0.5,
	AAFw_AutoPreloadEnabled = false,
	AAFw_AutoPreloadIDs = {
		animations = { runAnimations[Enum.HumanoidRigType.R6], runAnimations[Enum.HumanoidRigType.R15] }
	}
}