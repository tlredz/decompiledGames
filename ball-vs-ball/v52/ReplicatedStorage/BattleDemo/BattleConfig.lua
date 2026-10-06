local createVector = vector.create
local BattleConfig = {
	seed = {
		useFixedSeed = true,
		value = 20260613
	},
	debug = {
		glassShardRendering = true
	},
	arena = {
		size = Vector2.new(25, 25),
		boardAssetName = "",
		wallThickness = 1,
		wallHeight = 8,
		floorHeight = 1,
		worldCenter = createVector(0, 10, 0),
		planeRotation = createVector(-90, 0, 0),
		backgroundColor = Color3.fromRGB(16, 18, 24),
		wallColor = Color3.fromRGB(214, 220, 235),
		floorColor = Color3.fromRGB(35, 39, 52)
	},
	camera = {
		position = createVector(12, 50, 0),
		lookAt = createVector(0, 10, 0),
		fieldOfView = 48
	},
	battle = {
		contactCooldown = 0.45,
		autoRestartDelay = 3,
		rolePool = {},
		playerRolePool = {},
		analyzeRolePool = {},
		allowMirrorMatch = false
	},
	duelLod = {
		farDistanceThreshold = 90,
		farRenderInterval = 6,
		frozenRenderInterval = 1000000,
		reevaluateInterval = 0.4
	},
	replay = {
		countdown = 0.4,
		fixedDt = 0.016666666666666666,
		snapshotInterval = 0.05,
		maxDuration = 60,
		finalDisplaySecs = 30,
		candidateCount = 100,
		yieldEveryTrials = 5,
		excitementSweetSpotDuration = 20,
		parallelCompute = true,
		parallelActorCount = 16
	},
	lobby = {
		tableCount = 4,
		countdownDuration = 3,
		identificationDuration = 3,
		cooldownDuration = 3,
		seatPromptDistance = 10,
		replayArenaScale = 0.3,
		cameraTweenDuration = 0.5,
		spectatorAudio = {
			minDistance = 8,
			maxDistance = 40,
			emitterHeight = 2.2
		},
		layout = {
			origin = createVector(0, 0, 0),
			spacingX = 44,
			spacingZ = 34,
			rows = 2
		},
		table = {
			topSize = createVector(24, 2, 16),
			baseSize = createVector(12, 6, 10),
			topHeight = 7,
			seatSize = createVector(4, 1.2, 4),
			seatOffset = 12,
			arenaYOffset = 1.45,
			uiHeight = 8
		}
	},
	tournament = {
		gatherCountdown = 3,
		pickDuration = 30,
		pickCandidateCount = 3,
		matchCooldown = 4,
		circleRadius = 10,
		circleCheckInterval = 0.25,
		tableSpacing = 30,
		tableSeatOffset = 8,
		arenaScale = 1,
		upgradeDuration = 20,
		upgradeCandidateCount = 3,
		aimDuration = 30
	},
	slots = {
		Blue = {
			id = "Blue",
			displayName = "Blue",
			spawnPosition = Vector2.new(-8, 0)
		},
		Yellow = {
			id = "Yellow",
			displayName = "Yellow",
			spawnPosition = Vector2.new(8, 0)
		}
	},
	visual = {
		ballHeight = 2.6,
		ballMaterial = Enum.Material.SmoothPlastic,
		bladeTemplateName = "刀片",
		swordTemplateName = "长剑",
		axeTemplateName = "重斧",
		hookTemplateName = "钩爪",
		machineGunBulletTemplateName = "机枪子弹",
		iceConeTemplateName = "冰锥",
		diceTemplateName = "骰子模型",
		diceHeight = 0.26,
		glassShardTemplateName = "玻璃渣",
		voltaicTemplateName = "十万伏特",
		attackBuffTemplateName = "攻击上升",
		defenseBuffTemplateName = "防御上升",
		wallBounceDuration = 0.12,
		hitFlashDuration = 0.5,
		hitHighlightDuration = 0.25,
		cameraShake = {
			maxOffset = 0.02,
			duration = 0.25,
			minFrequency = 8,
			maxFrequency = 18,
			referenceSpeed = 30,
			hookWallHitStrength = 0.75
		},
		killDeathSettlement = {
			ballKillShakeDuration = 0.5,
			ballKillShakeAmplitude = 0.35,
			ballKillShakeMinFrequency = 7,
			ballKillShakeMaxFrequency = 13,
			killEffectTemplateName = "结算击杀特效",
			deathEffectTemplateName = "结算死亡特效",
			deathParticleWaitDuration = 1,
			jumpKillWindupDuration = 0.4,
			jumpKillEffectTemplateName = "结算跳杀特效"
		},
		duelSettlement = {
			flightDuration = 1.3,
			flightArcHeight = 6,
			flightEaseBezierX1 = 0.5,
			flightEaseBezierY1 = 0.7,
			flightEaseBezierX2 = 0.9,
			flightEaseBezierY2 = 0,
			flightCameraBulge = 6,
			cameraFocusFovScale = 1,
			cameraHoldDuration = 1.5,
			cameraReturnDuration = 0.3,
			cameraFocusMixFactor = 0.8,
			nextRoundGapDuration = 0.5,
			jumpKillTrailTemplateName = "结算跳杀拖尾"
		},
		speedBurstDuration = 0.25,
		mathTokenPopDuration = 0.18,
		mathTokenPopOvershoot = 1.2,
		mathRingGap = 0.25,
		mathRingThickness = 0.12,
		mathRingChargingColor = Color3.fromRGB(200, 230, 210),
		mathRingReadyColor = Color3.fromRGB(255, 215, 90),
		bladeHitFlashDuration = 0.12,
		spiderWebTemplateName = "蜘蛛丝",
		spiderWebHeight = 2.2,
		spiderWebHitFlashDuration = 0.1,
		vampireWebTemplateName = "吸血蛛丝",
		laserTemplateName = "激光",
		laserHeight = 2.2,
		laserHitFlashDuration = 0.1,
		electroKingTemplateName = "电王激光",
		electroKingHeight = 2.2,
		electroKingHitFlashDuration = 0.1,
		laserTurretV3BeamTemplateName = "激光V3光束",
		dogCannonTemplateName = "大狗光炮",
		bombTemplateName = "炸弹",
		bombExplosionTemplateName = "炸弹爆炸特效",
		potionRedFlyTemplateName = "红色药水",
		potionGreenFlyTemplateName = "绿色药水",
		potionBlueFlyTemplateName = "蓝色药水",
		potionRedImpactTemplateName = "红色药水触发特效",
		potionGreenImpactTemplateName = "绿色药水触发特效",
		potionBlueImpactTemplateName = "蓝色药水触发特效",
		potionRedRegionTemplateName = "红色药水区域",
		potionGreenRegionTemplateName = "绿色药水区域",
		potionBlueRegionTemplateName = "蓝色药水区域",
		cactusThrowEffectTemplateName = "仙人掌抛掷特效",
		trapReleaseEffectTemplateName = "陷阱释放特效",
		spearDashEffectTemplateName = "长矛冲刺特效",
		spearHitEffectTemplateName = "长矛命中特效",
		volcanoWarningTemplateName = "火山预警线",
		volcanoBurnTemplateName = "火山着火效果",
		volcanoFlameFadeDuration = 0.35,
		onePunchIdleEffectTemplateName = "一拳待机特效",
		onePunchWindupEffectTemplateName = "一拳蓄力特效",
		onePunchHitEffectTemplateNames = { "一拳命中特效_一档", "一拳命中特效_二档", "一拳命中特效_三档" },
		onePunchVictimEffectTemplateName = "一拳受击特效",
		onePunchIdleEffectInterval = 2.5,
		onePunchTier2Shake = {
			strength = 1,
			amplitudeScale = 3,
			duration = 0.35
		},
		onePunchTier3Shake = {
			strength = 1,
			amplitudeScale = 6,
			duration = 0.6
		},
		poisonSpikeTemplateName = "毒刺",
		poisonSpikeWallHeight = 2.6,
		poisonSpikeCreateFlashDuration = 0.16,
		poisonSpikeHitFlashDuration = 0.12,
		poisonTickFlashDuration = 0.12,
		bigSpikeTemplateName = "大刺",
		redStringTemplateName = "区域边界线",
		thomasTemplateName = "托马斯",
		zoneLineHeight = 2.2,
		zoneFillColor = Color3.fromRGB(255, 72, 72),
		zoneFillTransparency = 0.68,
		zoneFillSliceCount = 24,
		bladeMaterial = Enum.Material.Metal,
		bladeSize = createVector(0.45, 0.45, 1.7),
		damageFloat = {
			duration = 0.5,
			riseSpeed = 10,
			gravity = 30,
			horizontalSpeed = 3.5,
			fadeOutDuration = 0.3,
			worldHeight = 2.6,
			size = Vector2.new(4.4, 2),
			textColor = Color3.fromRGB(255, 72, 72),
			textStrokeColor = Color3.fromRGB(35, 0, 0),
			textStrokeTransparency = 0.3,
			endTextTransparency = 0.2,
			endTextStrokeTransparency = 0.55,
			font = Enum.Font.GothamBlack
		},
		healFloat = {
			duration = 1,
			fadeOutDuration = 0.18,
			offsetDistance = 1.4,
			worldHeight = 3.1,
			floatUpDistance = 2.2,
			size = Vector2.new(4.2, 1.9),
			textColor = Color3.fromRGB(102, 255, 151),
			textStrokeColor = Color3.fromRGB(12, 56, 22),
			textStrokeTransparency = 0.24,
			endTextTransparency = 0.18,
			endTextStrokeTransparency = 0.5,
			font = Enum.Font.GothamBlack
		}
	},
	audio = {
		roundStart = {
			soundId = "rbxassetid://109196746870031",
			volume = 0.35,
			playbackSpeed = 1.45,
			playbackSpeedJitter = 0.04,
			minInterval = 0.12,
			spatial = false
		},
		battleEnd = {
			soundId = "rbxassetid://126396290599122",
			volume = 0.42,
			playbackSpeed = 0.9,
			playbackSpeedJitter = 0.03,
			minInterval = 0.5,
			spatial = false
		},
		ballHit = {
			soundId = "rbxassetid://139876082768250",
			volume = 0.38,
			playbackSpeed = 1.2,
			playbackSpeedJitter = 0.08,
			minInterval = 0.1,
			spatial = false
		},
		bladeHit = {
			soundId = "rbxassetid://125856818464345",
			volume = 0.3,
			playbackSpeed = 1.15,
			playbackSpeedJitter = 0.08,
			minInterval = 0.06,
			spatial = false
		},
		bladeGrowth = {
			soundId = "rbxassetid://120397186043923",
			volume = 0.24,
			playbackSpeed = 1.4,
			playbackSpeedJitter = 0.05,
			minInterval = 0.12,
			spatial = false
		},
		snakeTailGrowth = {
			soundId = "rbxassetid://120397186043923",
			volume = 0.24,
			playbackSpeed = 1.4,
			playbackSpeedJitter = 0.05,
			minInterval = 0.12,
			spatial = false
		},
		chargeGain = {
			soundId = "rbxassetid://122727057760577",
			volume = 0.2,
			playbackSpeed = 2.6,
			playbackSpeedJitter = 0.08,
			minInterval = 0.12,
			spatial = false
		},
		chargeRelease = {
			soundId = "rbxassetid://138837782673055",
			volume = 0.34,
			playbackSpeed = 1.05,
			playbackSpeedJitter = 0.05,
			minInterval = 0.12,
			spatial = false
		},
		spiderWebHit = {
			soundId = "rbxassetid://125856818464345",
			volume = 0.18,
			playbackSpeed = 1.9,
			playbackSpeedJitter = 0.06,
			minInterval = 0.05,
			spatial = false
		},
		poisonSpikeCreate = {
			soundId = "rbxassetid://120397186043923",
			volume = 0.22,
			playbackSpeed = 1.7,
			playbackSpeedJitter = 0.06,
			minInterval = 0.04,
			spatial = false
		},
		poisonSpikeHit = {
			soundId = "rbxassetid://125856818464345",
			volume = 0.2,
			playbackSpeed = 1.35,
			playbackSpeedJitter = 0.06,
			minInterval = 0.05,
			spatial = false
		},
		zoneTick = {
			soundId = "rbxassetid://125856818464345",
			volume = 0.14,
			playbackSpeed = 1.1,
			playbackSpeedJitter = 0.05,
			minInterval = 0.08,
			spatial = false
		},
		potionRedTick = {
			soundId = "rbxassetid://125856818464345",
			volume = 0.14,
			playbackSpeed = 1.1,
			playbackSpeedJitter = 0.05,
			minInterval = 0.08,
			spatial = false
		},
		potionBlueTick = {
			soundId = "rbxassetid://125856818464345",
			volume = 0.14,
			playbackSpeed = 1.3,
			playbackSpeedJitter = 0.05,
			minInterval = 0.08,
			spatial = false
		}
	},
	traits = {
		VerityForms = {
			cnId = "Verity变身",
			displayName = "Verity Forms",
			displayNameCN = "Verity变身",
			behaviorKey = "VerityForms",
			attack = 1,
			stage1Damage = 1,
			stage2Damage = 10,
			stage3Damage = 25,
			stage2Speed = 12,
			stage3Speed = 14,
			stage2Chance = 0.2,
			stage3Chance = 0.2,
			upgradeCooldown = 1,
			stage2Model = "Verity球阶段2",
			stage3Model = "Verity球阶段3",
			stage2Effect = "Verity球变身特效1",
			stage3Effect = "Verity球变身特效2"
		},
		Interval = {
			cnId = "爆发冲刺",
			displayName = "Burst Drive",
			behaviorKey = "Interval",
			interval = 5,
			duration = 2,
			multiplier = 2,
			boostCollisionDamage = 20,
			damageReduction = 0.25,
			attack = 5,
			assetName = ""
		},
		ChessPath = {
			cnId = "象棋定轨",
			displayName = "Chess Path Assault",
			behaviorKey = "ChessPath",
			interval = 5,
			targetHitCooldown = 0.2,
			centerEntrySpeed = 50,
			pathSpeed = 40,
			edgePadding = 0.25,
			previewDuration = 0.6,
			lineFadeInDuration = 0.25,
			lineFadeOutDuration = 0.3,
			boardFadeOutDuration = 0.4,
			pieceHoverHeight = 2.2,
			attack = 5,
			assetName = "象棋素材"
		},
		TrainTrack = {
			cnId = "铺设轨道",
			displayName = "Rail Layer",
			displayNameCN = "铺设轨道",
			behaviorKey = "TrainTrack",
			interval = 8,
			nodeCount = 4,
			minNodeSpacing = 8,
			trackSampleSpacing = 1,
			maxTrackPointCount = 2000,
			trainSpawnDelay = 2,
			trainSpeed = 40,
			bodyCarCount = 1,
			carSpacing = 0.2,
			trainDamage = 5,
			targetHitCooldown = 0.4,
			railGauge = 2,
			railThickness = 0.15,
			sleeperSpacing = 1.5,
			railAngleThresholdDeg = 10,
			railCornerRadius = 1,
			railCornerSegments = 6,
			assetName = ""
		},
		WDC = {
			cnId = "WDC",
			displayName = "WDC",
			behaviorKey = "WDC",
			attack = 5,
			interval = 5,
			duration = 3.5,
			minCellValue = 1,
			maxCellValue = 100,
			weightDecayExponent = 1,
			boardFadeInDuration = 0.3,
			boardFadeOutDuration = 0.3,
			cellFlashDuration = 0.15,
			assetName = "WDC素材"
		},
		NoCollisionCharge = {
			cnId = "蓄力",
			displayName = "Charged Impact",
			behaviorKey = "NoCollisionCharge",
			baseMultiplier = 1,
			chargeInterval = 1.5,
			chargeStep = 0.3,
			maxMultiplier = 3,
			scaleStep = 0.2,
			attack = 10,
			assetName = ""
		},
		DeathSplit = {
			cnId = "死亡分裂",
			displayName = "Death Split",
			behaviorKey = "DeathSplit",
			growthTime = 3,
			growthScale = 1.5,
			attack = 5,
			splitCount = 3,
			maxTotalSplitCount = 20,
			spawnProtectionDuration = 0.2
		},
		Passive = {
			cnId = "环绕刀片",
			displayName = "Orbit Blades",
			behaviorKey = "Passive",
			maxBladeCount = 5,
			startingBladeCount = 1,
			growthInterval = 5,
			orbitRadius = 6,
			rotationSpeed = 3,
			bladeDamage = 10,
			bladeHitCooldown = 0.55,
			bladeColor = Color3.fromRGB(228, 242, 232),
			bladeHighlightColor = Color3.fromRGB(245, 255, 248)
		},
		OrbitSatellite = {
			cnId = "轨道卫星",
			displayName = "Orbit Satellites",
			displayNameCN = "轨道卫星",
			behaviorKey = "OrbitSatellite",
			ring1Capacity = 1,
			ring2Capacity = 3,
			ring3Capacity = 5,
			ring4Capacity = 7,
			radiusBase = 2.5,
			radiusStep = 1.2,
			periodBase = 2.5,
			periodStep = 0.8,
			spawnInterval = 0.6,
			satelliteDamage = 3,
			ringThickness = 0.08,
			assetName = "轨道卫星"
		},
		PassiveAxe = {
			cnId = "旋转重斧",
			displayName = "Berserker Axe",
			behaviorKey = "PassiveAxe",
			fullHealthCircleDuration = 1.5,
			lowHealthCircleDuration = 0.75,
			lowHealthThreshold = 0.5,
			fullHealthDamage = 4,
			lowHealthDamage = 6,
			hitRefreshTurns = 0.5
		},
		PassiveSword = {
			cnId = "旋转长剑",
			displayName = "Rising Sword",
			behaviorKey = "PassiveSword",
			swordLengthScale = 3,
			swordThicknessScale = 0.45,
			startingRotationSpeed = 3,
			rotationSpeed = 3,
			maxRotationSpeed = 12.5,
			rotationAcceleration = 1,
			swordDamage = 15,
			swordHitCooldown = 0.25,
			swordColor = Color3.fromRGB(216, 239, 255),
			swordHighlightColor = Color3.fromRGB(255, 255, 255)
		},
		MachineGun = {
			cnId = "机枪发射",
			displayName = "Machine Gun Fire",
			behaviorKey = "MachineGun",
			fireCooldown = 3,
			fireDuration = 3,
			initialBulletInterval = 1,
			finalBulletInterval = 0.25,
			bulletSpeed = 20,
			bulletDamage = 0.5,
			maxSpreadAngle = 10
		},
		ThiefKnives = {
			cnId = "盗贼飞刀",
			displayName = "Thief Knives",
			displayNameCN = "盗贼飞刀",
			behaviorKey = "ThiefKnives",
			fullHealthKnifeCount = 3,
			lowHealthKnifeCount = 8,
			lowHealthThreshold = 0.2,
			fullHealthChargeDuration = 2.4,
			lowHealthChargeDuration = 0.9,
			fullHealthThrowInterval = 0.28,
			lowHealthThrowInterval = 0.12,
			knifeDamage = 4,
			knifeSpeed = 35,
			fanTotalAngle = 24,
			assetName = ""
		},
		SnakeTail = {
			cnId = "蛇尾生长",
			displayName = "Growing Serpent Tail",
			displayNameCN = "蛇尾生长",
			behaviorKey = "SnakeTail",
			maxTailSegments = 12,
			startingFullyGrownSegments = 2,
			tailBaseDamage = 5,
			tailHitCooldown = 0.35,
			initialGrowthThreshold = 2,
			growthThresholdIncrement = 1,
			incompleteMinScale = 0.25,
			tailEndFullScale = 0.5,
			tailWaveAmplitudeMultiplier = 0.06,
			tailWaveFrequency = 4.5,
			tailSegmentPhaseOffset = 1,
			tailSpacingMultiplier = 1,
			tailTurnSpeed = 8,
			assetName = ""
		},
		IceConeTrail = {
			cnId = "冰锥尾迹",
			displayName = "Ice Cone Trail",
			displayNameCN = "冰锥尾迹",
			behaviorKey = "IceConeTrail",
			placeInterval = 1.5,
			bombFuseDuration = 1.5,
			maxBombCount = 3,
			iceConeCount = 6,
			iceConeDamage = 5,
			iceConeSpeed = 25,
			iceConeMaxDistance = 8
		},
		DiceBarrage = {
			cnId = "骰子弹幕",
			displayName = "Dice Barrage",
			displayNameCN = "骰子弹幕",
			behaviorKey = "DiceBarrage",
			placeInterval = 3,
			diceHitRadius = 0.25,
			diceRollTweenDuration = 0.35
		},
		GlassShards = {
			cnId = "玻璃渣",
			displayName = "Glass Shards",
			behaviorKey = "GlassShards",
			shardDamage = 1,
			maxShardCount = 100,
			wallShardCooldown = 0.1,
			enemyCollisionShardCooldown = 0.1,
			damageShardCooldown = 0.1,
			dropChance = 0.8,
			randomAngleRange = 360,
			wallInwardOffset = 0.05
		},
		ThomasUpgrade = {
			cnId = "升级托马斯",
			displayName = "Thomas Upgrade",
			behaviorKey = "ThomasUpgrade",
			thomasSpeed = 12,
			baseDamage = 1,
			damagePerLevel = 1,
			maxLevel = 100,
			scaleStep = 0.1,
			maxScale = 3,
			hitCooldown = 0.1,
			upgradeCooldown = 0.15
		},
		VampireAttach = {
			cnId = "吸附吸血",
			displayName = "Vampire Bite",
			behaviorKey = "VampireAttach",
			duration = 1.5,
			tickInterval = 0.5,
			drainDamage = 5,
			healPerTick = 5,
			slowMultiplier = 0.5,
			attachPadding = -0.12,
			reattachCooldown = 1
		},
		SpiderWeb = {
			cnId = "碰墙蛛丝",
			displayName = "Wall Web",
			behaviorKey = "SpiderWeb",
			webDamage = 2,
			webTickInterval = 0.5
		},
		VampireWeb = {
			cnId = "碰墙吸血蛛丝",
			displayName = "Vampire Web",
			behaviorKey = "VampireWeb",
			webDamage = 1,
			webHeal = 1,
			webTickInterval = 0.5
		},
		ZoneField = {
			cnId = "伤害红区",
			displayName = "Split Zone",
			behaviorKey = "ZoneField",
			zoneDuration = 10,
			zoneTickInterval = 0.5,
			zoneDamagePerTick = 5,
			zoneMinAreaRatio = 0.005
		},
		LaserWall = {
			cnId = "碰墙激光",
			displayName = "Laser Wall",
			behaviorKey = "LaserWall",
			laserDamage = 2,
			maxLaserCount = 64
		},
		PoisonSpikeWall = {
			cnId = "碰墙毒刺",
			displayName = "Poison Spike Field",
			behaviorKey = "PoisonSpikeWall",
			spikeContactDamage = 3,
			poisonDuration = 3,
			poisonTickInterval = 0.5,
			poisonTickDamage = 1,
			poisonSlowMultiplier = 0.5,
			maxSpikeCount = 32,
			spawnGraceDuration = 0.1,
			minWallSpawnSpacing = 1
		},
		BigSpikeWall = {
			cnId = "碰墙大刺",
			displayName = "Big Spike Field",
			behaviorKey = "BigSpikeWall",
			spikeContactDamage = 6,
			poisonDuration = 0,
			maxSpikeCount = 32,
			spawnGraceDuration = 0.1,
			minWallSpawnSpacing = 1
		},
		VoltaicShock = {
			cnId = "十万伏特电击",
			displayName = "Hundred Thousand Volts",
			displayNameCN = "十万伏特电击",
			behaviorKey = "VoltaicShock",
			chargeDuration = 3,
			shockDuration = 3.5,
			shockTickInterval = 0.5,
			shockDamagePerTick = 3,
			twitchAmplitude = 0.08,
			attack = 10
		},
		HookGrapple = {
			cnId = "钩爪",
			displayName = "Hook Grapple",
			displayNameCN = "钩爪",
			behaviorKey = "HookGrapple",
			idleCircleDuration = 3,
			captureCircleDuration = 0.6,
			captureDuration = 3,
			wallDamage = 1,
			wallDamageCooldown = 0.15,
			captureCooldown = 1.5,
			moveSpeedMultiplier = 1.15
		},
		AppleThrow = {
			cnId = "抛苹果",
			displayName = "Apple Toss",
			behaviorKey = "AppleThrow",
			assetName = "苹果",
			throwInterval = 4,
			appleSpeed = 18,
			minThrowDistance = 6,
			maxThrowDistance = 16,
			appleResidueDuration = 6,
			appleContactRadius = 1.5,
			enemyDamageAmount = 5,
			selfHealAmount = 3,
			hasteDuration = 3,
			hasteMultiplier = 1.4,
			slowDuration = 3,
			slowMultiplier = 0.6
		},
		AcidSpit = {
			cnId = "喷吐酸液",
			displayName = "Acid Spit",
			displayNameCN = "喷吐酸液",
			behaviorKey = "AcidSpit",
			assetName = "酸液",
			spitInterval = 2.2,
			dropletSpeed = 16,
			minSpitDistance = 4,
			maxSpitDistance = 10,
			arenaEdgePadding = 1,
			puddleResidueDuration = 12,
			minPuddleRadius = 1,
			maxPuddleRadius = 1.6,
			puddleGrowDuration = 0.25,
			maxActivePuddleCount = 6,
			poisonDuration = 3,
			poisonTickCount = 3,
			poisonTickDamage = 3,
			poisonInitialSlowMultiplier = 0.5
		},
		CannonTurret = {
			cnId = "碰墙炮台",
			displayName = "Wall Cannon",
			behaviorKey = "CannonTurret",
			assetName = "炮台",
			minWallSpawnSpacing = 3,
			maxTurretCount = 3,
			turretResidueDuration = 8,
			turretFireInterval = 1.2,
			turretRange = 40,
			bulletSpeed = 26,
			bulletDamage = 4
		},
		LaserTurretV3 = {
			cnId = "碰墙激光V3",
			displayName = "Wall Laser V3",
			behaviorKey = "LaserTurretV3",
			assetName = "激光V3炮台",
			minWallSpawnSpacing = 2,
			turretResidueDuration = 100,
			laserFireInterval = 3,
			laserDamage = 8,
			laserFlashDuration = 0.15
		},
		ElectroKingGrid = {
			cnId = "电王电网",
			displayName = "Electro King Grid",
			behaviorKey = "ElectroKingGrid",
			assetName = "电王激光",
			minWallSpawnSpacing = 1,
			nodeResidueDuration = 10,
			nearestNeighborCount = 2,
			maxNodeCount = 32,
			shockInterval = 3,
			shockActiveDuration = 1.2,
			shockTickInterval = 0.3,
			shockDamagePerTick = 2
		},
		ChargedBow = {
			cnId = "蓄力射箭",
			displayName = "Charged Bow",
			behaviorKey = "ChargedBow",
			assetName = "弓",
			moveIntervalBeforeCharge = 4,
			chargeDuration = 2,
			drawStageRatio = 0.35,
			arrowSpeed = 30,
			arrowDamage = 8,
			minChargeDamageRatio = 0.4,
			arrowBounceCount = 2,
			arrowLifetime = 4
		},
		Harpoon = {
			cnId = "鱼叉",
			displayName = "Harpoon",
			displayNameCN = "鱼叉",
			behaviorKey = "Harpoon",
			assetName = "鱼叉",
			throwInterval = 5,
			harpoonSpeed = 22,
			maxBounceCount = 6,
			pullSpeed = 22,
			hitRadius = 0.6,
			captureTickInterval = 0.4,
			captureTickDamage = 3
		},
		HiveSwarm = {
			cnId = "蜂群追猎",
			displayName = "Hive Swarm",
			displayNameCN = "蜂群追猎",
			behaviorKey = "HiveSwarm",
			assetName = "蜂巢蜜蜂",
			emitInterval = 4,
			maxBeesPerWave = 5,
			waveReleaseBaseInterval = 0.5,
			waveMinReleaseInterval = 0.08,
			beeSpeed = 16,
			beeTurnRateDegrees = 240,
			beeHitRadius = 0.5,
			beeLifetime = 8,
			deathDecelDuration = 0.6,
			poisonTickCount = 3,
			poisonTickInterval = 0.4,
			poisonTickDamage = 2,
			maxActiveBees = 40,
			maxPoisonStacksPerTarget = 20
		},
		RobuxBarrage = {
			cnId = "Robux弹幕",
			displayName = "Robux Barrage",
			displayNameCN = "Robux弹幕",
			behaviorKey = "RobuxBarrage",
			assetName = "Robux弹体",
			fullHealthShotInterval = 1,
			lowHealthShotInterval = 0.05,
			projectileSpeed = 18,
			maxLifetime = 8,
			bulletDamage = 3
		},
		Shuriken = {
			cnId = "手里剑",
			displayName = "Shuriken",
			displayNameCN = "手里剑",
			behaviorKey = "Shuriken",
			assetName = "手里剑",
			emitInterval = 5,
			maxPerWave = 5,
			waveReleaseBaseInterval = 1.2,
			waveMinReleaseInterval = 0.15,
			shurikenSpeed = 18,
			hitRadius = 0.5,
			maxLifetime = 6,
			flightSpinSpeed = 720,
			hitDamage = 5,
			maxActiveShurikens = 30
		},
		MedicBarrage = {
			cnId = "医疗弹幕",
			displayName = "Medic Barrage",
			displayNameCN = "医疗弹幕",
			behaviorKey = "MedicBarrage",
			assetName = "医疗弹幕",
			emitInterval = 3,
			bulletSpeed = 16,
			maxBounces = 3,
			hitRadius = 0.5,
			enemyDamage = 4,
			allyHeal = 3,
			maxActiveBullets = 40
		},
		MathEquation = {
			cnId = "算式追踪",
			displayName = "Equation Missile",
			displayNameCN = "算式追踪",
			behaviorKey = "MathEquation",
			assetName = "数学追踪弹",
			chargeDuration = 3,
			tokenInterval = 0.35,
			resultRevealDelay = 0.4,
			fireDelay = 0.5,
			addOperandMin = 1,
			addOperandMax = 9,
			mulOperandMin = 2,
			mulOperandMax = 5,
			multiplyChance = 0.4,
			bulletSpeed = 16,
			bulletTurnRateDegrees = 240,
			bulletHitRadius = 0.5,
			bulletLifetime = 6,
			maxActiveBullets = 10
		},
		OnePunch = {
			cnId = "随机一拳",
			displayName = "One Punch",
			displayNameCN = "随机一拳",
			behaviorKey = "OnePunch",
			assetName = "一拳冲刺拖尾",
			attack = 10,
			cooldownMin = 2,
			cooldownMax = 6,
			dashSpeed = 40,
			missWeight = 50,
			normalWeight = 40,
			killWeight = 10,
			normalDamageMin = 1,
			normalDamageMax = 50,
			windupDuration = 0.4,
			killDamage = 999,
			knockbackSpeedScale = 2.5,
			knockbackMinRatio = 0.2,
			knockbackDuration = 0.8,
			dashTimeoutScale = 1.5
		},
		PoisonOnHit = {
			cnId = "命中中毒",
			displayName = "Venom Strike",
			behaviorKey = "PoisonOnHit",
			poisonDuration = 3,
			poisonTickInterval = 0.5,
			poisonTickDamage = 1,
			poisonSlowMultiplier = 0.6
		},
		VirusOnHit = {
			cnId = "接触中毒",
			displayName = "Viral Touch",
			behaviorKey = "VirusOnHit",
			attack = 8,
			poisonDuration = 3,
			poisonTickInterval = 0.5,
			poisonTickDamage = 1,
			poisonSlowMultiplier = 0.6
		},
		SlowOnHit = {
			cnId = "命中减速",
			displayName = "Chilling Strike",
			behaviorKey = "SlowOnHit",
			slowDuration = 2,
			slowMultiplier = 0.6
		},
		FreezeOnHit = {
			cnId = "冰冻",
			displayName = "Freeze",
			behaviorKey = "FreezeOnHit",
			slowDuration = 1,
			slowMultiplier = 0,
			assetName = "冻结效果"
		},
		ElectromagneticParalysis = {
			cnId = "电磁麻痹",
			displayName = "Electromagnetic Paralysis",
			behaviorKey = "ElectromagneticParalysis",
			hitCount = 3,
			slowDuration = 1,
			slowMultiplier = 0,
			assetName = "电麻效果"
		},
		DamageAmplification = {
			cnId = "伤害增强",
			displayName = "Damage Amplification",
			displayNameCN = "伤害增强",
			behaviorKey = "DamageAmplification",
			damageMultiplier = 1.2
		},
		Knockback = {
			cnId = "击退",
			displayName = "Knockback",
			displayNameCN = "击退",
			behaviorKey = "Knockback",
			duration = 0.5,
			speedMultiplier = 1.2
		},
		StrongParalysis = {
			cnId = "强力麻痹",
			displayName = "Strong Paralysis",
			displayNameCN = "强力麻痹",
			behaviorKey = "StrongParalysis",
			slowDuration = 1,
			slowMultiplier = 0,
			assetName = "强力麻痹效果"
		},
		Gravity = {
			cnId = "引力",
			displayName = "Gravity",
			displayNameCN = "引力",
			behaviorKey = "Gravity",
			pullAcceleration = 24,
			maxPullSpeed = 8,
			assetName = ""
		},
		LowHpArmor = {
			cnId = "残血护甲",
			displayName = "Last Stand",
			behaviorKey = "LowHpArmor",
			hpThreshold = 0.35,
			damageReduction = 0.2
		},
		GamblerStrike = {
			cnId = "赌命一击",
			displayName = "Desperate Gambit",
			behaviorKey = "GamblerStrike",
			hpThreshold = 0.3,
			damageBonus = 0.5
		},
		ArmorBreaker = {
			cnId = "破甲撞击",
			displayName = "Armor Breaker",
			behaviorKey = "ArmorBreaker",
			hpThreshold = 0.7,
			damageBonus = 0.3
		},
		AllIn = {
			cnId = "孤注一掷",
			displayName = "All In",
			behaviorKey = "AllIn",
			maxHpPenalty = 0.15,
			attackBonus = 0.2,
			speedBonus = 0.1
		},
		LuckyCrit = {
			cnId = "幸运暴击",
			displayName = "Lucky Strike",
			behaviorKey = "LuckyCrit",
			critChance = 0.15,
			critMultiplier = 2
		},
		WallCharge = {
			cnId = "墙面蓄力",
			displayName = "Wall Charge",
			behaviorKey = "WallCharge",
			bonusMultiplier = 1.5
		},
		SprintStart = {
			cnId = "冲刺启动",
			displayName = "Sprint Start",
			behaviorKey = "SprintStart",
			duration = 5,
			speedMultiplier = 2,
			assetName = "短暂加速效果"
		},
		BounceAccel = {
			cnId = "反弹加速",
			displayName = "Bounce Accel",
			behaviorKey = "BounceAccel",
			duration = 1.5,
			speedMultiplier = 1.3,
			assetName = "短暂加速效果"
		},
		BallHitAccel = {
			cnId = "撞球加速",
			displayName = "Collision Accel",
			behaviorKey = "BallHitAccel",
			duration = 1.5,
			speedMultiplier = 1.3,
			assetName = "短暂加速效果"
		},
		ComboStrike = {
			cnId = "连撞奖励",
			displayName = "Combo Strike",
			behaviorKey = "ComboStrike",
			comboWindow = 2,
			bonusPerHit = 0.15,
			maxStacks = 3
		},
		Execute = {
			cnId = "斩杀",
			displayName = "Execute",
			behaviorKey = "Execute",
			hpThreshold = 0.2,
			damageMultiplier = 2
		},
		SelfRepair = {
			cnId = "自我修复",
			displayName = "Self Repair",
			behaviorKey = "SelfRepair",
			tickInterval = 3,
			healAmount = 3
		},
		CollisionHeal = {
			cnId = "撞击治疗",
			displayName = "Collision Heal",
			behaviorKey = "CollisionHeal",
			healAmount = 1
		},
		Shield = {
			cnId = "护盾",
			displayName = "Shield",
			behaviorKey = "Shield",
			charges = 1,
			assetName = "无敌护盾"
		},
		AntiFreeze = {
			cnId = "抗冻涂层",
			displayName = "Anti-Freeze Coating",
			behaviorKey = "AntiFreeze",
			slowDurationReduction = 0.5
		},
		Fireproof = {
			cnId = "防火外壳",
			displayName = "Fireproof Shell",
			behaviorKey = "Fireproof",
			poisonDurationReduction = 0.5
		},
		GrievousWounds = {
			cnId = "重伤",
			displayName = "Grievous Wounds",
			behaviorKey = "GrievousWounds",
			healReductionDuration = 3,
			healReduction = 0.5
		},
		ExpandingAura = {
			cnId = "领域扩张",
			displayName = "Expanding Field",
			behaviorKey = "ExpandingAura",
			assetName = "领域扩张",
			initialRadius = 4,
			maxRadius = 12,
			attackInterval = 1,
			attackDamagePerTick = 3,
			radiusGrowthPerTick = 0.5
		},
		FrostTrail = {
			cnId = "冰霜尾迹",
			displayName = "Frost Trail",
			behaviorKey = "FrostTrail",
			assetName = "冰霜尾迹",
			trailSpawnInterval = 0.3,
			trailDuration = 4,
			maxTrailCount = 40,
			slowDuration = 0.2,
			slowMultiplier = 0,
			frostChargeRate = 1,
			frostMaxLevel = 10,
			frostTier1Threshold = 3,
			frostTier1TickInterval = 1.2,
			frostTier1Damage = 1,
			frostTier2Threshold = 6,
			frostTier2TickInterval = 0.8,
			frostTier2Damage = 2,
			frostTier3Threshold = 9,
			frostTier3TickInterval = 0.4,
			frostTier3Damage = 3
		},
		AlchemistGasTrail = {
			cnId = "毒气尾迹",
			displayName = "Toxic Gas Trail",
			displayNameCN = "毒气尾迹",
			behaviorKey = "AlchemistGasTrail",
			assetName = "毒气尾迹",
			trailSpawnInterval = 0.1,
			trailDuration = 3,
			maxTrailCount = 40,
			poisonDuration = 5,
			poisonTickInterval = 0.32,
			poisonTickDamage = 1,
			poisonSlowMultiplier = 0.6
		},
		DogCannon = {
			cnId = "大狗光炮",
			displayName = "Dog Cannon",
			displayNameCN = "大狗光炮",
			behaviorKey = "DogCannon",
			assetName = "大狗光炮",
			chargeDuration = 3,
			particleIntervalStart = 0.6,
			particleIntervalEnd = 0.12,
			particleEmitCount = 12,
			beamDuration = 2.5,
			beamTickInterval = 0.15,
			beamDamagePerTick = 4,
			beamTurnPeriod = 8
		},
		TimeBomb = {
			cnId = "定时炸弹",
			displayName = "Time Bomb",
			displayNameCN = "定时炸弹",
			behaviorKey = "TimeBomb",
			attack = 8,
			placeInterval = 2,
			maxBombCount = 3,
			bombFuseDuration = 4,
			explosionDamage = 8,
			explosionImpulseSpeed = 20,
			explosionImpulseDuration = 0.6
		},
		PotionThrow = {
			cnId = "抛药水",
			displayName = "Potion Toss",
			displayNameCN = "抛药水",
			behaviorKey = "PotionThrow",
			throwInterval = 3,
			windupDuration = 0.6,
			flightDuration = 0.9,
			flightArcHeight = 3,
			flightSpinSpeed = 540,
			holdOffset = 0.3,
			windupWobbleFrequency = 8,
			windupWobbleAmplitude = 8,
			maxActivePotionCount = 4,
			arenaEdgePadding = 1,
			regionResidueLifetime = 2,
			redRegionDuration = 4,
			redTickInterval = 0.5,
			redTickDamage = 2,
			greenRegionDuration = 4,
			greenReapplyInterval = 0.5,
			poisonDuration = 3,
			poisonTickInterval = 0.5,
			poisonTickDamage = 1,
			poisonSlowMultiplier = 0.6,
			blueRegionDuration = 4,
			slowDuration = 0.2,
			slowMultiplier = 0,
			potionFrostChargeRate = 3,
			potionFrostMaxLevel = 10,
			potionFrostTier1Threshold = 2,
			potionFrostTier1TickInterval = 0.5,
			potionFrostTier1Damage = 2,
			potionFrostTier2Threshold = 4,
			potionFrostTier2TickInterval = 0.3,
			potionFrostTier2Damage = 2,
			potionFrostTier3Threshold = 7,
			potionFrostTier3TickInterval = 0.1,
			potionFrostTier3Damage = 2
		},
		CactusThrow = {
			cnId = "抛仙人掌",
			displayName = "Cactus Toss",
			displayNameCN = "抛仙人掌",
			behaviorKey = "CactusThrow",
			assetName = "仙人掌",
			throwInterval = 4,
			cactusCount = 3,
			flightDuration = 1,
			flightArcHeight = 3,
			cactusDuration = 6,
			maxActiveCactusCount = 9,
			arenaEdgePadding = 1,
			minCactusSpacing = 2.5,
			regionResidueLifetime = 1.5,
			touchDamage = 8,
			hitCooldown = 0.3
		},
		TrapRelease = {
			cnId = "定时布陷",
			displayName = "Trap Release",
			displayNameCN = "定时布陷",
			behaviorKey = "TrapRelease",
			assetName = "陷阱",
			releaseInterval = 5,
			trapCount = 3,
			spawnRadius = 6,
			trapDuration = 8,
			maxActiveTrapCount = 6,
			arenaEdgePadding = 1,
			minTrapSpacing = 1.5,
			regionResidueLifetime = 1,
			bounceDamage = 1,
			bounceCooldown = 0.15,
			ringThickness = 0.12
		},
		SpearThrust = {
			cnId = "长矛突刺",
			displayName = "Spear Thrust",
			displayNameCN = "长矛突刺",
			behaviorKey = "SpearThrust",
			assetName = "长矛",
			attack = 10,
			speedGrowthPerSecond = 3,
			maxSpeed = 22,
			readyDotThreshold = 0.5,
			poseTransitionDuration = 0.35,
			spearHitCooldown = 0.3,
			spearBaseDamage = 8
		},
		Fibonacci = {
			cnId = "斐波那契连击",
			displayName = "Fibonacci Combo",
			displayNameCN = "斐波那契连击",
			behaviorKey = "Fibonacci",
			assetName = "斐波那契撞击特效_一阶",
			attack = 1,
			maxHitIndex = 15
		},
		VolcanoEruption = {
			cnId = "火山喷涌",
			displayName = "Volcano Eruption",
			displayNameCN = "火山喷涌",
			behaviorKey = "VolcanoEruption",
			assetName = "火山火焰",
			attack = 8,
			moveDuration = 3,
			windupDuration = 0.8,
			eruptDuration = 2,
			flameCountMin = 3,
			flameCountMax = 6,
			fanAngleDegrees = 180,
			flameGrowSpeed = 40,
			flameSlowMultiplier = 0.5,
			burnDuration = 3,
			burnTickInterval = 0.5,
			burnTickDamage = 2
		}
	},
	tournament_upgrade = {
		basicStats = {
			speed = {
				cnId = "轻盈",
				displayName = "Light Body",
				amount = 0.12
			},
			hp = {
				cnId = "厚皮",
				displayName = "Thick Skin",
				amount = 0.18
			},
			attack = {
				cnId = "重击",
				displayName = "Heavy Strike",
				amount = 0.15
			}
		}
	},
	roles = {}
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SkillFeatureParser = require(script.Parent.SkillFeatureParser)
local RoleBuilder = require(script.Parent.RoleBuilder)
local Config = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("Config"))
local v = math.max(1, Config.misc.logicFPS or 60)
local v2 = math.max(1, Config.misc.dataFPS or 20)
BattleConfig.replay.fixedDt = 1 / v
BattleConfig.replay.snapshotInterval = 1 / v2

if typeof(Config.misc.maxSimSecs) == "number" and Config.misc.maxSimSecs > 0 then
	BattleConfig.replay.maxDuration = Config.misc.maxSimSecs
end

if typeof(Config.misc.finalDisplaySecs) == "number" and Config.misc.finalDisplaySecs > 0 then
	BattleConfig.replay.finalDisplaySecs = Config.misc.finalDisplaySecs
end

SkillFeatureParser.overlayTraits(BattleConfig.traits, Config.skill)
local part = ReplicatedStorage:WaitForChild("美术素材"):WaitForChild("模型效果"):WaitForChild(BattleConfig.traits.RobuxBarrage.assetName):FindFirstChild("碰撞箱")
assert(part and part:IsA("BasePart"), "[BattleConfig] Robux弹体缺少 BasePart 碰撞箱")
BattleConfig.traits.RobuxBarrage.hitboxSize = Vector2.new(part.Size.X, part.Size.Y)
local BattleSkill_RobuxBarrage = require(script.Parent.BattleSkill_RobuxBarrage)
BattleSkill_RobuxBarrage.validate(BattleConfig.traits.RobuxBarrage)
local BattleSkill_VerityForms = require(script.Parent.BattleSkill_VerityForms)
BattleSkill_VerityForms.validate(BattleConfig.traits.VerityForms)
BattleConfig.traits.VerityForms.attack = BattleConfig.traits.VerityForms.stage1Damage
local v3 = Config.board.byCnId[Config.misc.defaultBoardId]
assert(
	v3 ~= nil,
	string.format("[BattleConfig] 飞书 board 表找不到 defaultBoardId: %s", (tostring(Config.misc.defaultBoardId)))
)
BattleConfig.arena.size = Vector2.new(v3.xSize, v3.ySize)
BattleConfig.arena.boardAssetName = v3.assetName
local child = ReplicatedStorage:WaitForChild("美术素材"):WaitForChild("棋盘"):WaitForChild(v3.assetName)
local part2 = child:FindFirstChild("绑定箱")
assert(part2 and part2:IsA("BasePart"), string.format("[BattleConfig] 棋盘 '%s' 缺少绑定箱", v3.assetName))
local _1 = child:FindFirstChild("球位置1")
local _2 = child:FindFirstChild("球位置2")
assert(_1 and _1:IsA("BasePart"), string.format("[BattleConfig] 棋盘 '%s' 缺少球位置1", v3.assetName))
assert(_2 and _2:IsA("BasePart"), string.format("[BattleConfig] 棋盘 '%s' 缺少球位置2", v3.assetName))

-- equivalent calls inferred from this helper; original call sites unknown
local function boardLocalSpawnPosition(p)
	local pointToObjectSpace = part2.CFrame:PointToObjectSpace(p.Position)
	return Vector2.new(pointToObjectSpace.X, pointToObjectSpace.Y)
end

local blue = BattleConfig.slots.Blue
blue.spawnPosition = boardLocalSpawnPosition(_1)
local yellow = BattleConfig.slots.Yellow
yellow.spawnPosition = boardLocalSpawnPosition(_2)
local halfSize = BattleConfig.arena.size / 2
local v5 = halfSize.X * 0.62
local v6 = halfSize.Y * 0.62
BattleConfig.slots.Blue.spawnPositionCorners = { Vector2.new(-v5, -v6), Vector2.new(-v5, v6) }
BattleConfig.slots.Yellow.spawnPositionCorners = { Vector2.new(v5, -v6), Vector2.new(v5, v6) }
BattleConfig.replay.enableExcitementSelection = Config.misc.enableBattleExcitement == nil or Config.misc.enableBattleExcitement
local v7 = {
	hp = {
		["血量提升比例"] = "amount"
	},
	speed = {
		["速度提升比例"] = "amount"
	},
	attack = {
		["伤害提升比例"] = "amount"
	}
}

for k, basicStat in BattleConfig.tournament_upgrade.basicStats do
	local v8 = v7[k]
	local v9

	if v8 then
		if typeof(Config.upgrade) == "table" and typeof(Config.upgrade.byCnId) == "table" then
			v9 = Config.upgrade.byCnId[basicStat.cnId]
		else
			v9 = false
		end
	else
		v9 = v8
	end

	if v9 then
		local parsed = SkillFeatureParser.parse(v9.feature, v8)

		for k2, v10 in parsed do
			basicStat[k2] = v10
		end

		basicStat.displayName = v9.displayName or basicStat.displayName
	else
		warn((`[BattleConfig] 飞书 upgrade 表找不到: {tostring(basicStat.cnId)}`))
	end
end

local battle = BattleConfig.battle
local battle2 = BattleConfig.battle
local battle3 = BattleConfig.battle
local roles, rolePool, playerRolePool, analyzeRolePool = RoleBuilder.build(BattleConfig.traits, Config.ball)
BattleConfig.roles = roles
battle.rolePool = rolePool
battle2.playerRolePool = playerRolePool
battle3.analyzeRolePool = analyzeRolePool

if BattleConfig.roles["象棋球"] == nil then
	local BallVisualRegistry = require(script.Parent.BallVisualRegistry)
	local v12 = BallVisualRegistry.get("象棋球")
	BattleConfig.roles["象棋球"] = {
		roleId = "象棋球",
		displayName = "Chess Ball",
		displayNameCN = "象棋球",
		color = v12.color,
		highlightColor = v12.highlightColor,
		templateName = "象棋球",
		maxHp = 100,
		attack = BattleConfig.traits.ChessPath.attack,
		speed = 13,
		skill = table.clone(BattleConfig.traits.ChessPath)
	}
	BattleConfig.roles["象棋球"].skill.trigger = "ChessPath"
	table.insert(BattleConfig.battle.rolePool, "象棋球")
end

if BattleConfig.roles.WDC ~= nil then
	return BattleConfig
end

local BallVisualRegistry = require(script.Parent.BallVisualRegistry)
local WDC = BallVisualRegistry.get("WDC")
BattleConfig.roles.WDC = {
	roleId = "WDC",
	displayName = "WDC",
	displayNameCN = "WDC",
	color = WDC.color,
	highlightColor = WDC.highlightColor,
	templateName = "WDC",
	maxHp = 100,
	attack = BattleConfig.traits.WDC.attack,
	speed = 13,
	skill = table.clone(BattleConfig.traits.WDC)
}
BattleConfig.roles.WDC.skill.trigger = "WDC"
table.insert(BattleConfig.battle.rolePool, "WDC")
return BattleConfig