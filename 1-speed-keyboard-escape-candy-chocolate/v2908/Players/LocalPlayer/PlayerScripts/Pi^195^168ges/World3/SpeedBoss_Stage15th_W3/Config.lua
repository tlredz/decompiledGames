return {
	CoreConfig = {
		entryTriggerPartName = "Stage15thStart",
		leaveTriggerPartName = "Stage15thEnd",
		voidPartTagName = "Stage15VoidPart",
		voidFinishTagName = "VoidFinish",
		rigPositionsTagName = "RigPositions",
		introRigPositionName = "RigIntroPosition",
		outroRigPositionName = "RigOutroPosition"
	},
	Animations = {
		CutsceneIntro = {
			Camera = "rbxassetid://110798756044387",
			BossRig = "rbxassetid://137909136616394"
		},
		CutsceneOutro = {
			Camera = "rbxassetid://107144056103112",
			BossRig = "rbxassetid://89592862217015"
		},
		Chase = {
			Idle = "rbxassetid://109208008438167",
			Emotes = {}
		}
	},
	Audio = {
		dialog = "rbxassetid://76395722432571",
		dialogOutro = "rbxassetid://133528790354646",
		stageMusic = "rbxassetid://80926846815524",
		speedBoost = "rbxassetid://127199850989931"
	},
	NpcDialog = {
		senderName = "Twisted Lokii",
		duration = 3,
		outroDuration = 12,
		icon = "rbxassetid://76708154332458"
	},
	VoidChase = {
		speed = 100,
		speedAfterStep = 200,
		speedStep = 5,
		startDelay = 2.5,
		warningText = "The void is consuming the stage behind you! RUN!",
		warningDuration = 5
	},
	VisualBoss = {
		waypointsFolderName = "VisualBossWaypoints",
		stageNumber = 15,
		speedLead = 50,
		speedPartTagName = "World3Stage15SpeedPart"
	},
	ChaseEmote = {
		minInterval = 8,
		maxInterval = 18
	},
	SpeedIncrease = {
		templateName = "SpeedIncrease",
		debrisSeconds = 10
	}
}