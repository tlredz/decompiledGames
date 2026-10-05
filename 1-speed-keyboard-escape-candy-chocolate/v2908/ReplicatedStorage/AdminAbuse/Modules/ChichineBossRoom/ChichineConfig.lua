return {
	bossName = "Chichine",
	sseChannelName = "ChichineBossRoom",
	mapModelName = "ChichineBossRoom",
	bossIcon = "rbxthumb://type=AvatarHeadShot&id=18298071&w=150&h=150",
	DefaultSenderId = 18298071,
	BossUseTheatreHp = true,
	BossTheatreDurationSec = 720,
	BossTheatreDisplayMaxHp = 100000000000000,
	openingCutsceneDurationSec = 3,
	endingCutsceneDurationSec = 38,
	LokiiSenderId = 3845375404,
	attackIntervalMinSec = 1,
	attackIntervalMaxSec = 3,
	phaseIntervalMult = {
		1,
		0.88,
		0.76,
		0.65,
		0.55,
		0.47,
		0.42,
		0.38
	},
	maxConcurrentByPhase = {
		1,
		1,
		1,
		1,
		2,
		2,
		3,
		3
	},
	BossZoneAttackHalfExtents = vector.create(14, 45, 14),
	BossZoneWarnTimeSec = 1.4,
	PHASE_THRESHOLDS = {
		0.13,
		0.25,
		0.38,
		0.5,
		0.63,
		0.75,
		0.88
	},
	MessageConfigByPhase = {
		[2] = {
			Message = "HM. What's about Nextune's powers?"
		},
		[3] = {
			Message = "FoeCakes' power. That's funny."
		},
		[4] = {
			Message = "Sano's & Xern's Miguel... hahaha."
		},
		[5] = {
			Message = "0V3RDRIVE's anti-cheat powers..."
		},
		[6] = {
			Message = "Last are Lucky's noobs!"
		},
		[7] = {
			Message = "Fine that was fun I'll use my own powers now."
		},
		[8] = {
			Message = "Hahaha!"
		}
	},
	TimelineCues = {
		{
			Time = 5,
			Message = "WELCOME TO THE VOID.",
			SenderId = 18298071,
			SpawnOrbs = 7
		},
		{
			Time = 15,
			Message = "This is the space I created... enjoy the VOID ADMIN ABUSE TREADMILL.",
			SenderId = 18298071,
			SpawnOrbs = 11
		},
		{
			Time = 25,
			Message = "Let's create World 3!",
			SenderId = 18298071,
			SpawnOrbs = 11
		},
		{
			Time = 35,
			Message = "I know you guys want the World 3! But first, we need to break the other worlds!",
			SenderId = 18298071,
			SpawnOrbs = 11
		},
		{
			Time = 45,
			Message = "Break everything!",
			SenderId = 18298071,
			SpawnOrbs = 11
		},
		{
			Time = 55,
			Message = "We need World 3!",
			SenderId = 18298071,
			SpawnOrbs = 11
		},
		{
			Time = 65,
			Message = "WHAT ARE YOU TALKING ABOUT? WORLD 3?",
			SenderId = 175193570,
			SpawnOrbs = 7
		},
		{
			Time = 70,
			Message = "I want a new World! ",
			SenderId = 18298071,
			SpawnGiantOrbs = 2,
			SpawnOrbs = 16
		},
		{
			Time = 75,
			Message = "This will destroy everything!",
			SenderId = 3845375404,
			SpawnOrbs = 7
		},
		{
			Time = 80,
			Message = "I don't mind, as long as a new world is born!",
			SenderId = 18298071,
			SpawnOrbs = 11
		},
		{
			Time = 85,
			Message = "WE SPENT MONTHS BUILDING THIS GAME TOGETHER!",
			SenderId = 175193570,
			SpawnOrbs = 7
		},
		{
			Time = 95,
			Message = "You can't do this!",
			SenderId = 3845375404,
			SpawnOrbs = 7
		},
		{
			Time = 100,
			Message = "You're going to destroy everything if you keep going!",
			SenderId = 3845375404,
			SpawnOrbs = 7
		},
		{
			Time = 105,
			Message = "I don't need your approval! My power is absolute here.",
			SenderId = 18298071,
			SpawnOrbs = 18
		},
		{
			Time = 110,
			Message = "WE CAN'T RELEASE WORLD 3 WITHOUT DESTROYING THE OTHERS.",
			SenderId = 175193570,
			SpawnOrbs = 7
		},
		{
			Time = 115,
			Message = "And? World 3 is the better one.",
			SenderId = 18298071,
			SpawnOrbs = 16
		},
		{
			Time = 120,
			Message = "To build, one must first break. That is destiny.",
			SenderId = 18298071,
			SpawnOrbs = 16
		},
		{
			Time = 125,
			Message = "Feel the weight of the Void!",
			SenderId = 18298071,
			SpawnGiantOrbs = 2,
			SpawnOrbs = 11
		},
		{
			Time = 130,
			Message = "He's spawning way too much wins!",
			SenderId = 3845375404,
			SpawnOrbs = 7
		},
		{
			Time = 135,
			Message = "THIS PLACE IS TEARING THE MULTIVERSE APART!",
			SenderId = 175193570,
			SpawnOrbs = 11
		},
		{
			Time = 140,
			Message = "IS THAT WHY YOU BROUGHT US HERE?",
			SenderId = 175193570,
			SpawnOrbs = 7
		},
		{
			Time = 150,
			Message = "I brought you here to witness.",
			SenderId = 18298071,
			SpawnOrbs = 18
		},
		{
			Time = 155,
			Message = "This is perfect, players. Keep going.",
			SenderId = 18298071,
			SpawnOrbs = 16
		},
		{
			Time = 160,
			Message = "Players want all worlds!",
			SenderId = 3845375404,
			SpawnOrbs = 7
		},
		{
			Time = 165,
			Message = "They do not need it.",
			SenderId = 18298071,
			SpawnOrbs = 18
		},
		{
			Time = 170,
			Message = "We must stop him!",
			SenderId = 3845375404,
			SpawnOrbs = 11
		},
		{
			Time = 180,
			Message = "I can feel the energy overloading...",
			SenderId = 3845375404,
			SpawnOrbs = 7
		},
		{
			Time = 185,
			Message = "Let it overload. We won't need the old worlds anyway.",
			SenderId = 18298071,
			SpawnOrbs = 23
		},
		{
			Time = 190,
			Message = "ARE YOU INSANE?! YOU WANT TO DESTROY THE MULTIVERSE!",
			SenderId = 175193570,
			SpawnOrbs = 11
		},
		{
			Time = 195,
			Message = "World 3 is eternal.",
			SenderId = 18298071,
			SpawnOrbs = 23
		},
		{
			Time = 200,
			Message = "It's time. Let's start with the speed.",
			SenderId = 18298071,
			SpawnOrbs = 16
		},
		{
			Time = 205,
			Message = "WAIT, MY CONTROLS... WHAT ARE YOU DOING?!",
			SenderId = 175193570,
			SpawnOrbs = 7
		},
		{
			Time = 210,
			Message = "You can't do anything anymore.",
			SenderId = 18298071,
			SpawnGiantOrbs = 5,
			SpawnOrbs = 16
		},
		{
			Time = 215,
			Message = "WAIT WHAT DID YOU DO?",
			SenderId = 175193570,
			SpawnOrbs = 7
		},
		{
			Time = 225,
			Message = "Your powers...",
			SenderId = 18298071,
			SpawnOrbs = 16
		},
		{
			Time = 230,
			Message = "He's stealing our developer powers!",
			SenderId = 3845375404,
			SpawnOrbs = 11
		},
		{
			Time = 235,
			Message = "We need to stop him!",
			SenderId = 3845375404,
			SpawnOrbs = 11
		},
		{
			Time = 240,
			Message = "I'M TRYING, BUT I CAN'T!",
			SenderId = 175193570,
			SpawnOrbs = 7
		},
		{
			Time = 245,
			Message = "It's useless. Just watch.",
			SenderId = 18298071,
			SpawnOrbs = 18
		},
		{
			Time = 250,
			Message = "We need more Wins! HERE ARE MORE BIG WINS!",
			SenderId = 18298071,
			SpawnGiantOrbs = 3,
			SpawnOrbs = 16
		},
		{
			Time = 255,
			Message = "He's absorbing everything!",
			SenderId = 3845375404,
			SpawnOrbs = 11
		},
		{
			Time = 260,
			Message = "WE CAN'T DO ANYTHING!",
			SenderId = 175193570,
			SpawnOrbs = 7
		},
		{
			Time = 265,
			Message = "All that speed... this is perfect for World 3.",
			SenderId = 18298071,
			SpawnOrbs = 23
		},
		{
			Time = 275,
			Message = "Stop!",
			SenderId = 3845375404,
			SpawnOrbs = 7
		},
		{
			Time = 280,
			Message = "It's too late now.",
			SenderId = 18298071,
			SpawnOrbs = 16
		},
		{
			Time = 285,
			Message = "We will break everything.",
			SenderId = 18298071,
			SpawnOrbs = 18
		},
		{
			Time = 290,
			Message = "Keep going everyone we can stop him!",
			SenderId = 3845375404,
			SpawnOrbs = 11
		},
		{
			Time = 295,
			Message = "WHAT SHOULD WE DO?",
			SenderId = 175193570,
			SpawnOrbs = 7
		},
		{
			Time = 300,
			Message = "Remember everyone getting crazy? All simple experiments.",
			SenderId = 18298071,
			SpawnOrbs = 18
		},
		{
			Time = 305,
			Message = "All the previous bosses... they were just ways to get more speed and wins.",
			SenderId = 18298071,
			SpawnOrbs = 18
		},
		{
			Time = 315,
			Message = "WAIT... YOU PLANNED ALL OF THOSE FIGHTS?!",
			SenderId = 175193570,
			SpawnOrbs = 11
		},
		{
			Time = 325,
			Message = "Don't let him get in your head!",
			SenderId = 3845375404,
			SpawnOrbs = 11
		},
		{
			Time = 330,
			Message = "I needed to test the players. And now, the final test is here. HERE ARE MORE BIG WINS!",
			SenderId = 18298071,
			SpawnGiantOrbs = 5,
			SpawnOrbs = 16
		},
		{
			Time = 335,
			Message = "THAT'S TOO MUCH!",
			SenderId = 175193570,
			SpawnOrbs = 11
		},
		{
			Time = 340,
			Message = "MORE.",
			SenderId = 18298071,
			SpawnOrbs = 18
		},
		{
			Time = 345,
			Message = "No, it's going to destroy everything!",
			SenderId = 3845375404,
			SpawnOrbs = 11
		},
		{
			Time = 350,
			Message = "You manipulated all of us from the very beginning!",
			SenderId = 3845375404,
			SpawnOrbs = 16
		},
		{
			Time = 360,
			Message = "HAHAHA. It took you this long to figure it out?",
			SenderId = 18298071,
			SpawnOrbs = 23
		},
		{
			Time = 370,
			Message = "You should thank me for this opportunity.",
			SenderId = 18298071,
			SpawnOrbs = 18
		},
		{
			Time = 380,
			Message = "WHY DO YOU WANT WORLD 3?",
			SenderId = 175193570,
			SpawnOrbs = 11
		},
		{
			Time = 385,
			Message = "I want to build a perfect world. But I need more power. I need more wins.",
			SenderId = 18298071,
			SpawnOrbs = 23
		},
		{
			Time = 390,
			Message = "BUT THIS IS CRAZY!",
			SenderId = 175193570,
			SpawnOrbs = 11
		},
		{
			Time = 395,
			Message = "WHY DESTROY EVERYTHING WE BUILT?",
			SenderId = 175193570,
			SpawnOrbs = 11
		},
		{
			Time = 400,
			Message = "Because what we built is too small. World 3 needs everything we have.",
			SenderId = 18298071,
			SpawnOrbs = 23
		},
		{
			Time = 405,
			Message = "You're going to replace World 1 and 2?!",
			SenderId = 3845375404,
			SpawnOrbs = 16
		},
		{
			Time = 410,
			Message = "I want a new World. This is the only way.",
			SenderId = 18298071,
			SpawnOrbs = 23
		},
		{
			Time = 415,
			Message = "This is not going to work!",
			SenderId = 3845375404,
			SpawnOrbs = 16
		},
		{
			Time = 420,
			Message = "WHAT ABOUT ALL THE PLAYERS WHO LOVE THIS GAME?!",
			SenderId = 175193570,
			SpawnOrbs = 16
		},
		{
			Time = 425,
			Message = "I am doing this for them!",
			SenderId = 18298071,
			SpawnOrbs = 23
		},
		{
			Time = 430,
			Message = "There's other ways! You don't have to do this!",
			SenderId = 3845375404,
			SpawnOrbs = 16
		},
		{
			Time = 435,
			Message = "We won't let you destroy this world!",
			SenderId = 3845375404,
			SpawnOrbs = 16
		},
		{
			Time = 440,
			Message = "I'M TRYING TO STOP HIM, BUT I CAN'T DO ANYTHING!",
			SenderId = 175193570,
			SpawnOrbs = 11
		},
		{
			Time = 445,
			Message = "60%...",
			SenderId = 18298071,
			SpawnOrbs = 18
		},
		{
			Time = 455,
			Message = "Wait... he's not resetting our wins... he's giving us more?!",
			SenderId = 3845375404,
			SpawnOrbs = 16
		},
		{
			Time = 460,
			Message = "LOOK AT THE WIN COUNT! IT'S SKYROCKETING!",
			SenderId = 175193570,
			SpawnOrbs = 16
		},
		{
			Time = 465,
			Message = "Yes! Win more, run faster! Feed the rift! HERE ARE MORE BIG WINS!",
			SenderId = 18298071,
			SpawnGiantOrbs = 4,
			SpawnOrbs = 18
		},
		{
			Time = 470,
			Message = "IT'S MAKING THE GAME LAG!",
			SenderId = 175193570,
			SpawnOrbs = 16
		},
		{
			Time = 475,
			Message = "We have to defeat him before the portal opens completely!",
			SenderId = 3845375404,
			SpawnOrbs = 16
		},
		{
			Time = 480,
			Message = "Defeat me? In my own space, I am unstoppable.",
			SenderId = 18298071,
			SpawnOrbs = 23
		},
		{
			Time = 485,
			Message = "WE CAN'T EVEN HIT HIM...",
			SenderId = 175193570,
			SpawnOrbs = 16
		},
		{
			Time = 490,
			Message = "70%...",
			SenderId = 18298071,
			SpawnGiantOrbs = 8,
			SpawnOrbs = 23
		},
		{
			Time = 495,
			Message = "75%...",
			SenderId = 18298071,
			SpawnOrbs = 23
		},
		{
			Time = 500,
			Message = "WE NEED TO STOP THIS, IT WILL DESTROY EVERYONE'S DATA!",
			SenderId = 175193570,
			SpawnOrbs = 16
		},
		{
			Time = 505,
			Message = "I'm trying to redirect everything!",
			SenderId = 3845375404,
			SpawnOrbs = 16
		},
		{
			Time = 510,
			Message = "Let's speed this up! HERE ARE MORE BIG WINS!",
			SenderId = 18298071,
			SpawnGiantOrbs = 6,
			SpawnOrbs = 23
		},
		{
			Time = 515,
			Message = "It's useless, I can't do anything!",
			SenderId = 3845375404,
			SpawnOrbs = 16
		},
		{
			Time = 520,
			Message = "I have lost my developer controls...",
			SenderId = 3845375404,
			SpawnOrbs = 16
		},
		{
			Time = 525,
			Message = "THEY ARE COMPLETELY GONE! WE CAN'T EDIT ANYTHING!",
			SenderId = 175193570,
			SpawnOrbs = 11
		},
		{
			Time = 530,
			Message = "No more development power. You are just spectators now.",
			SenderId = 18298071,
			SpawnOrbs = 23
		},
		{
			Time = 540,
			Message = "This is not how it ends!",
			SenderId = 3845375404,
			SpawnOrbs = 16
		},
		{
			Time = 545,
			Message = "WE HAVE TO BEAT HIM BEFORE THE WINS OVERLOAD THE DATA!",
			SenderId = 175193570,
			SpawnOrbs = 16
		},
		{
			Time = 550,
			Message = "PLAYERS WILL DEFEAT YOU BEFORE THE WORLD BREAKS!",
			SenderId = 175193570,
			SpawnOrbs = 16
		},
		{
			Time = 555,
			Message = "They are strong, but it helps me.",
			SenderId = 18298071,
			SpawnOrbs = 23
		},
		{
			Time = 560,
			Message = "We won't let you break the rules of this game!",
			SenderId = 3845375404,
			SpawnOrbs = 16
		},
		{
			Time = 565,
			Message = "I am the rules now.",
			SenderId = 18298071,
			SpawnOrbs = 23
		},
		{
			Time = 570,
			Message = "The players? They are HELPING me.",
			SenderId = 18298071,
			SpawnOrbs = 23
		},
		{
			Time = 575,
			Message = "WE CAN'T TELL THE PLAYERS TO STOP GATHERING WINS!",
			SenderId = 175193570,
			SpawnOrbs = 16
		},
		{
			Time = 580,
			Message = "There's no way!",
			SenderId = 3845375404,
			SpawnOrbs = 16
		},
		{
			Time = 585,
			Message = "Your persistence is... admirable, but useless.",
			SenderId = 18298071,
			SpawnOrbs = 23
		},
		{
			Time = 590,
			Message = "That's too much wins!",
			SenderId = 3845375404,
			SpawnOrbs = 16
		},
		{
			Time = 595,
			Message = "I CAN FEEL WORLD 3 ARRIVING, BUT IT WILL DESTROY THE GAME!",
			SenderId = 175193570,
			SpawnOrbs = 16
		},
		{
			Time = 600,
			Message = "No way!",
			SenderId = 3845375404,
			SpawnOrbs = 16
		},
		{
			Time = 605,
			Message = "YES! COLLECT EVERY SINGLE WIN! LET'S OVERLOAD THE RIFT!",
			SenderId = 175193570,
			SpawnOrbs = 18
		},
		{
			Time = 610,
			Message = "EVERYONE, GATHER ALL THE ORBS! GO AS FAST AS YOU CAN!",
			SenderId = 175193570,
			SpawnOrbs = 23
		},
		{
			Time = 615,
			Message = "Speed won't save you from the new world. 85%...",
			SenderId = 18298071,
			SpawnOrbs = 23
		},
		{
			Time = 620,
			Message = "I am trying to get inside the commands!",
			SenderId = 3845375404,
			SpawnOrbs = 16
		},
		{
			Time = 625,
			Message = "Futile attempts. 90%...",
			SenderId = 18298071,
			SpawnOrbs = 23
		},
		{
			Time = 630,
			Message = "IT IS TOO LATE!",
			SenderId = 175193570,
			SpawnOrbs = 18
		},
		{
			Time = 640,
			Message = "MORE WINS! HERE ARE MORE BIG WINS!",
			SenderId = 18298071,
			SpawnGiantOrbs = 10,
			SpawnOrbs = 29
		},
		{
			Time = 645,
			Message = "I will open World 3 right now!",
			SenderId = 18298071,
			SpawnGiantOrbs = 5,
			SpawnOrbs = 23
		},
		{
			Time = 650,
			Message = "HE'S GOING CRAZY!",
			SenderId = 175193570,
			SpawnOrbs = 18
		},
		{
			Time = 655,
			Message = "The whole data is overloading! Stop!",
			SenderId = 3845375404,
			SpawnOrbs = 18
		},
		{
			Time = 660,
			Message = "The Void is fracturing!",
			SenderId = 3845375404,
			SpawnOrbs = 18
		},
		{
			Time = 665,
			Message = "Good. Break it all.",
			SenderId = 18298071,
			SpawnOrbs = 29
		},
		{
			Time = 670,
			Message = "HAHAHA.",
			SenderId = 18298071,
			SpawnOrbs = 29
		},
		{
			Time = 675,
			Message = "Quick, I have got an idea!",
			SenderId = 3845375404,
			SpawnOrbs = 18
		},
		{
			Time = 680,
			Message = "Nothing will work.",
			SenderId = 18298071,
			SpawnOrbs = 29
		},
		{
			Time = 685,
			Message = "WE CAN DO IT.",
			SenderId = 175193570,
			SpawnOrbs = 18
		},
		{
			Time = 690,
			Message = "THE PORTAL IS AT 95%!",
			SenderId = 175193570,
			SpawnOrbs = 18
		},
		{
			Time = 695,
			Message = "There's one way!",
			SenderId = 3845375404,
			SpawnOrbs = 18
		},
		{
			Time = 700,
			Message = "I GOT THE COMMAND!",
			SenderId = 3845375404,
			SpawnOrbs = 23
		},
		{
			Time = 705,
			Message = "BUT...",
			SenderId = 175193570,
			SpawnOrbs = 23
		},
		{
			Time = 710,
			Message = "This is too late.",
			SenderId = 18298071,
			SpawnGiantOrbs = 15,
			SpawnOrbs = 38
		}
	},
	AttackPerPhase = {
		{ "ZoneSweet" },
		{ "ZoneSweet", "BoulderRain" },
		{ "ZoneSweet", "BoulderRain", "GlassShatter" },
		{
			"ZoneSweet",
			"BoulderRain",
			"GlassShatter",
			"MiguelSwarm"
		},
		{
			"ZoneSweet",
			"BoulderRain",
			"GlassShatter",
			"MiguelSwarm",
			"HammerSmash",
			"SwordTango"
		},
		{
			"ZoneSweet",
			"BoulderRain",
			"GlassShatter",
			"MiguelSwarm",
			"HammerSmash",
			"SwordTango",
			"SpawnNoobWave"
		},
		{
			"ZoneSweet",
			"BoulderRain",
			"GlassShatter",
			"MiguelSwarm",
			"HammerSmash",
			"SwordTango",
			"SpawnNoobWave",
			"ShootingKeycaps"
		}
	},
	Soundtracks = {
		{
			ID = "rbxassetid://94760249776190",
			DisplayName = "X3LL3N - The Last Gambit"
		}
	},
	useDeferredMapLoad = true,
	deferredLoadTimeBudgetSec = 0.006,
	deferredUnloadTimeBudgetSec = 0.0025,
	SkipDoorTransition = true,
	SkipDoorCamera = true,
	LobbyDoorSlideStuds = 0,
	MobWins = {
		ClassicNoob = 1,
		MiguelNPC = 1.5,
		GlassShatterOrb = 1
	},
	NoobWave = {
		waveSize = 50,
		spawnIntervalSec = 0.12,
		archetypes = {
			Basic = {
				scale = 1.5,
				walkSpeed = 26,
				maxHealth = 100,
				damage = 15
			},
			Giant = {
				scale = 3.5,
				walkSpeed = 10,
				maxHealth = 500,
				damage = 35
			}
		},
		weights = {
			Basic = 0.75,
			Giant = 0.25
		}
	},
	MiguelSwarm = {
		waveSize = 6,
		spawnIntervalSec = 0.2,
		archetypes = {
			Miguel = {
				scale = 1,
				walkSpeed = 16,
				maxHealth = 300,
				damage = 25
			}
		},
		weights = {
			Miguel = 1
		}
	},
	HammerSmash = {
		spawnHeight = 50,
		hoverSec = 3,
		wanderSteps = 3,
		warnSec = 2.5,
		prepareSec = 0.5,
		smashSec = 0.5,
		damage = 100,
		damageRadius = 50
	},
	SwordTango = {
		concurrentCap = 1,
		damage = 40,
		damageCooldown = 1
	},
	BoulderRain = {
		count = 7,
		countByPhase = {
			[2] = 7,
			[3] = 9,
			[4] = 11,
			[5] = 13,
			[6] = 16,
			[7] = 20,
			[8] = 20
		},
		diameter = 30,
		damage = 50,
		spawnStaggerSec = 0.15,
		lifeMin = 4,
		lifeMax = 9,
		warnSec = 1.5,
		spawnHeight = 200,
		fallSpeed = 15
	},
	ShootingKeycaps = {
		count = 14,
		countByPhase = {
			[7] = 14,
			[8] = 20
		},
		spawnStaggerSec = 0.08,
		warnSec = 1.2,
		damage = 80,
		landingRadius = 25,
		spawnHeight = 140,
		spawnSideOffset = 350
	},
	healCrates = {
		spawnIntervalSec = 15,
		maxAlivePerPlayer = 1,
		despawnSec = 20,
		playerDebounceSec = 8
	},
	GlassShatter = {
		portalCountMin = 6,
		portalCountMax = 12,
		orbsPerPortal = 2,
		portalLifetimeSec = 9,
		portalIndividualLifetime = 6,
		orbDespawnSec = 12,
		spawnStaggerSec = 0.25,
		orbCollectCooldownSec = 0.3,
		timeshiftFadeIn = 0.6,
		timeshiftFadeOut = 0.5,
		timeshiftDistortAudio = false,
		phaseCountMult = {
			[3] = 1,
			[4] = 1.1,
			[5] = 1.2,
			[6] = 1.4,
			[7] = 1.6,
			[8] = 1.8
		}
	}
}