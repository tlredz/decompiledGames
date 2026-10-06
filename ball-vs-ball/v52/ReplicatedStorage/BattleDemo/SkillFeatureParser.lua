local SkillFeatureParser = {
	FEATURE_KEY_MAP = {
		VerityForms = {
			["一阶段基础伤害"] = "stage1Damage",
			["二阶段基础伤害"] = "stage2Damage",
			["三阶段基础伤害"] = "stage3Damage",
			["二阶段移动速度"] = "stage2Speed",
			["三阶段移动速度"] = "stage3Speed",
			["升二阶段概率"] = "stage2Chance",
			["升三阶段概率"] = "stage3Chance",
			["升级冷却秒数"] = "upgradeCooldown"
		},
		Interval = {
			["触发间隔秒数"] = "interval",
			["持续时间"] = "duration",
			["伤害倍率"] = "multiplier",
			["伤害减免比例"] = "damageReduction",
			["碰撞伤害加成"] = "boostCollisionDamage",
			["本体基础伤害"] = "attack"
		},
		ChessPath = {
			["触发间隔秒数"] = "interval",
			["同目标命中冷却秒数"] = "targetHitCooldown",
			["中心入场速度"] = "centerEntrySpeed",
			["定轨移动速度"] = "pathSpeed",
			["边界安全边距"] = "edgePadding",
			["路线预览秒数"] = "previewDuration",
			["红线淡入秒数"] = "lineFadeInDuration",
			["红线淡出秒数"] = "lineFadeOutDuration",
			["棋盘淡出秒数"] = "boardFadeOutDuration",
			["棋子悬浮高度"] = "pieceHoverHeight",
			["本体基础伤害"] = "attack"
		},
		OnePunch = {
			["最短冷却秒数"] = "cooldownMin",
			["最长冷却秒数"] = "cooldownMax",
			["冲刺速度"] = "dashSpeed",
			["落空权重"] = "missWeight",
			["普通权重"] = "normalWeight",
			["秒杀权重"] = "killWeight",
			["普通伤害下限"] = "normalDamageMin",
			["普通伤害上限"] = "normalDamageMax"
		},
		WDC = {
			["本体基础伤害"] = "attack",
			["棋盘生成间隔秒数"] = "interval",
			["棋盘维持时间秒数"] = "duration",
			["格子数字下限"] = "minCellValue",
			["格子数字上限"] = "maxCellValue",
			["权重衰减系数"] = "weightDecayExponent",
			["棋盘淡入时长"] = "boardFadeInDuration",
			["棋盘淡出时长"] = "boardFadeOutDuration",
			["命中闪烁时长"] = "cellFlashDuration"
		},
		NoCollisionCharge = {
			["基础伤害倍率"] = "baseMultiplier",
			["蓄力间隔秒数"] = "chargeInterval",
			["单次蓄力增量"] = "chargeStep",
			["最大倍率"] = "maxMultiplier",
			["体型放大步长"] = "scaleStep",
			["本体基础伤害"] = "attack"
		},
		DeathSplit = {
			["成长时间秒数"] = "growthTime",
			["成长体型倍率"] = "growthScale",
			["本体基础伤害"] = "attack",
			["分裂数量"] = "splitCount",
			["最大累计分裂数"] = "maxTotalSplitCount",
			["出生保护秒数"] = "spawnProtectionDuration"
		},
		Passive = {
			["最大刀片数"] = "maxBladeCount",
			["初始刀片数"] = "startingBladeCount",
			["刀片增长间隔秒数"] = "growthInterval",
			["环绕半径"] = "orbitRadius",
			["旋转速度"] = "rotationSpeed",
			["单刀片伤害"] = "bladeDamage",
			["刀片命中冷却秒数"] = "bladeHitCooldown"
		},
		PassiveAxe = {
			["满血每圈时长秒数"] = "fullHealthCircleDuration",
			["残血每圈时长秒数"] = "lowHealthCircleDuration",
			["残血阈值"] = "lowHealthThreshold",
			["满血击中伤害"] = "fullHealthDamage",
			["残血击中伤害"] = "lowHealthDamage",
			["同目标判定刷新圈数"] = "hitRefreshTurns"
		},
		PassiveSword = {
			["初始旋转速度"] = "startingRotationSpeed",
			["当前旋转速度"] = "rotationSpeed",
			["最大旋转速度"] = "maxRotationSpeed",
			["旋转加速度"] = "rotationAcceleration",
			["长剑伤害"] = "swordDamage",
			["长剑命中冷却秒数"] = "swordHitCooldown"
		},
		GlassShards = {
			["玻璃渣伤害"] = "shardDamage",
			["玻璃渣最大数量"] = "maxShardCount",
			["撞墙生成冷却秒数"] = "wallShardCooldown",
			["撞敌方生成冷却秒数"] = "enemyCollisionShardCooldown",
			["受伤生成冷却秒数"] = "damageShardCooldown",
			["玻璃渣朝向随机范围度"] = "randomAngleRange",
			["玻璃渣墙内偏移"] = "wallInwardOffset",
			["掉渣概率"] = "dropChance"
		},
		MachineGun = {
			["发射冷却"] = "fireCooldown",
			["发射持续时间"] = "fireDuration",
			["子弹发射初始间隔"] = "initialBulletInterval",
			["子弹发射结束间隔"] = "finalBulletInterval",
			["子弹移动速度"] = "bulletSpeed",
			["子弹基础伤害"] = "bulletDamage",
			["最大扩散角度"] = "maxSpreadAngle"
		},
		OrbitSatellite = {
			["环1卫星上限"] = "ring1Capacity",
			["环2卫星上限"] = "ring2Capacity",
			["环3卫星上限"] = "ring3Capacity",
			["环4卫星上限"] = "ring4Capacity",
			["基础环半径"] = "radiusBase",
			["环半径递增步长"] = "radiusStep",
			["基础环绕周期秒数"] = "periodBase",
			["环绕周期递增步长秒数"] = "periodStep",
			["卫星生成间隔秒数"] = "spawnInterval",
			["卫星撞击伤害"] = "satelliteDamage",
			["轨道环粗细"] = "ringThickness"
		},
		ThiefKnives = {
			["满血刀数"] = "fullHealthKnifeCount",
			["残血刀数"] = "lowHealthKnifeCount",
			["残血生命阈值"] = "lowHealthThreshold",
			["满血蓄力时长秒数"] = "fullHealthChargeDuration",
			["残血蓄力时长秒数"] = "lowHealthChargeDuration",
			["满血投掷间隔秒数"] = "fullHealthThrowInterval",
			["残血投掷间隔秒数"] = "lowHealthThrowInterval",
			["单刀伤害"] = "knifeDamage",
			["飞刀移动速度"] = "knifeSpeed",
			["扇形总角度"] = "fanTotalAngle"
		},
		SnakeTail = {
			["最大尾节数"] = "maxTailSegments",
			["开局完全尾节数"] = "startingFullyGrownSegments",
			["尾节基础伤害"] = "tailBaseDamage",
			["尾节命中冷却秒数"] = "tailHitCooldown",
			["初始充能门槛"] = "initialGrowthThreshold",
			["每节门槛增量"] = "growthThresholdIncrement",
			["未完全最小尺寸倍率"] = "incompleteMinScale",
			["尾端完整尺寸倍率"] = "tailEndFullScale",
			["尾巴抖动振幅倍率"] = "tailWaveAmplitudeMultiplier",
			["尾巴抖动频率"] = "tailWaveFrequency",
			["相邻关节相位差弧度"] = "tailSegmentPhaseOffset",
			["尾节间距倍率"] = "tailSpacingMultiplier",
			["尾节转向速度"] = "tailTurnSpeed",
			["尾节绷直速度"] = "tailTurnSpeed"
		},
		IceConeTrail = {
			["安放间隔秒数"] = "placeInterval",
			["爆炸倒计时秒数"] = "bombFuseDuration",
			["最大同时存在炸弹数"] = "maxBombCount",
			["冰锥数量"] = "iceConeCount",
			["单冰锥伤害"] = "iceConeDamage",
			["冰锥移动速度"] = "iceConeSpeed",
			["冰锥最大距离"] = "iceConeMaxDistance"
		},
		DiceBarrage = {
			["安放间隔秒数"] = "placeInterval",
			["骰子命中半径"] = "diceHitRadius",
			["骰子滚动时长秒数"] = "diceRollTweenDuration"
		},
		ThomasUpgrade = {
			["托马斯速度"] = "thomasSpeed",
			["初始伤害"] = "baseDamage",
			["每级伤害提升"] = "damagePerLevel",
			["最大等级"] = "maxLevel",
			["每级体型提升比例"] = "scaleStep",
			["每级体型增加比例"] = "scaleStep",
			["最大体型比例"] = "maxScale",
			["体型上限比例"] = "maxScale",
			["命中冷却秒数"] = "hitCooldown",
			["升级冷却秒数"] = "upgradeCooldown",
			["每级伤害增加"] = "damagePerLevel",
			thomasSpeed = "thomasSpeed",
			baseDamage = "baseDamage",
			damagePerLevel = "damagePerLevel",
			maxLevel = "maxLevel",
			scaleStep = "scaleStep",
			maxScale = "maxScale",
			hitCooldown = "hitCooldown",
			upgradeCooldown = "upgradeCooldown"
		},
		VampireAttach = {
			["贴附持续时间"] = "duration",
			["吸血结算间隔秒数"] = "tickInterval",
			["每次扣血量"] = "drainDamage",
			["每次回血量"] = "healPerTick",
			["减速倍率"] = "slowMultiplier",
			["贴附距离微调"] = "attachPadding",
			["重新贴附冷却秒数"] = "reattachCooldown",
			["本体基础伤害"] = "attack"
		},
		SpiderWeb = {
			["蛛丝伤害"] = "webDamage",
			["蛛丝跳伤间隔秒数"] = "webTickInterval"
		},
		VampireWeb = {
			["蛛丝伤害"] = "webDamage",
			["蛛丝吸血量"] = "webHeal",
			["蛛丝跳伤间隔秒数"] = "webTickInterval"
		},
		ZoneField = {
			["红区持续时间"] = "zoneDuration",
			["红区跳伤间隔秒数"] = "zoneTickInterval",
			["每次跳伤伤害"] = "zoneDamagePerTick",
			["最小区域占比"] = "zoneMinAreaRatio"
		},
		LaserWall = {
			["激光伤害"] = "laserDamage",
			["最大连线数"] = "maxLaserCount"
		},
		PoisonSpikeWall = {
			["毒刺接触伤害"] = "spikeContactDamage",
			["中毒持续时间"] = "poisonDuration",
			["中毒跳伤间隔秒数"] = "poisonTickInterval",
			["中毒每次跳伤伤害"] = "poisonTickDamage",
			["中毒减速倍率"] = "poisonSlowMultiplier",
			["毒刺最大数量"] = "maxSpikeCount",
			["生成保护间隔秒数"] = "spawnGraceDuration",
			["毒刺间最小间距"] = "minWallSpawnSpacing"
		},
		BigSpikeWall = {
			["毒刺接触伤害"] = "spikeContactDamage",
			["中毒持续时间"] = "poisonDuration",
			["中毒跳伤间隔秒数"] = "poisonTickInterval",
			["中毒每次跳伤伤害"] = "poisonTickDamage",
			["中毒减速倍率"] = "poisonSlowMultiplier",
			["毒刺最大数量"] = "maxSpikeCount",
			["生成保护间隔秒数"] = "spawnGraceDuration",
			["毒刺间最小间距"] = "minWallSpawnSpacing"
		},
		VoltaicShock = {
			["充能时长秒数"] = "chargeDuration",
			["电击控制持续秒数"] = "shockDuration",
			["电击跳伤间隔秒数"] = "shockTickInterval",
			["每次电击伤害"] = "shockDamagePerTick",
			["抽搐幅度"] = "twitchAmplitude",
			["本体基础伤害"] = "attack"
		},
		HookGrapple = {
			["低速旋转每圈时长秒数"] = "idleCircleDuration",
			["高速旋转每圈时长秒数"] = "captureCircleDuration",
			["高速旋转持续时间"] = "captureDuration",
			["撞墙伤害"] = "wallDamage",
			["撞墙伤害判定冷却秒数"] = "wallDamageCooldown",
			["抓取冷却秒数"] = "captureCooldown",
			["钩住移速加成倍率"] = "moveSpeedMultiplier"
		},
		AppleThrow = {
			["抛出间隔秒数"] = "throwInterval",
			["苹果弹丸速度"] = "appleSpeed",
			["最小抛掷距离"] = "minThrowDistance",
			["最大抛掷距离"] = "maxThrowDistance",
			["苹果驻留时间"] = "appleResidueDuration",
			["苹果拾取半径"] = "appleContactRadius",
			["敌方吃苹果扣血"] = "enemyDamageAmount",
			["己方吃苹果回血"] = "selfHealAmount",
			["己方加速持续时间"] = "hasteDuration",
			["己方加速倍率"] = "hasteMultiplier",
			["敌方减速持续时间"] = "slowDuration",
			["敌方减速倍率"] = "slowMultiplier"
		},
		AcidSpit = {
			["喷吐间隔秒数"] = "spitInterval",
			["液滴飞行速度"] = "dropletSpeed",
			["最小喷吐距离"] = "minSpitDistance",
			["最大喷吐距离"] = "maxSpitDistance",
			["落点边界安全边距"] = "arenaEdgePadding",
			["酸液滩驻留时间"] = "puddleResidueDuration",
			["酸液滩最小半径"] = "minPuddleRadius",
			["酸液滩最大半径"] = "maxPuddleRadius",
			["酸液滩缩放时长秒数"] = "puddleGrowDuration",
			["同时存在酸液滩上限"] = "maxActivePuddleCount",
			["中毒持续时间"] = "poisonDuration",
			["中毒扣血次数"] = "poisonTickCount",
			["中毒每次扣血伤害"] = "poisonTickDamage",
			["中毒命中瞬间移速倍率"] = "poisonInitialSlowMultiplier"
		},
		CannonTurret = {
			["炮台间最小间距"] = "minWallSpawnSpacing",
			["炮台最大数量"] = "maxTurretCount",
			["炮台驻留时间"] = "turretResidueDuration",
			["炮台射速间隔秒数"] = "turretFireInterval",
			["炮台射程"] = "turretRange",
			["炮台子弹速度"] = "bulletSpeed",
			["炮台子弹伤害"] = "bulletDamage"
		},
		LaserTurretV3 = {
			["炮台间最小间距"] = "minWallSpawnSpacing",
			["炮台驻留时间"] = "turretResidueDuration",
			["激光发射间隔秒数"] = "laserFireInterval",
			["激光伤害"] = "laserDamage",
			["激光闪光持续时间"] = "laserFlashDuration"
		},
		TrainTrack = {
			["技能触发间隔秒数"] = "interval",
			["轨道节点数量"] = "nodeCount",
			["轨道节点最小间距"] = "minNodeSpacing",
			["轨道采样间距"] = "trackSampleSpacing",
			["轨道点数组防御上限"] = "maxTrackPointCount",
			["铺设完成等待秒数"] = "trainSpawnDelay",
			["火车速度"] = "trainSpeed",
			["火车车身节数"] = "bodyCarCount",
			["车厢间距"] = "carSpacing",
			["火车碰撞伤害"] = "trainDamage",
			["同目标命中冷却秒数"] = "targetHitCooldown",
			["轨距"] = "railGauge",
			["铁轨粗细"] = "railThickness",
			["枕木间距"] = "sleeperSpacing",
			["轨道渲染折角阈值度数"] = "railAngleThresholdDeg",
			["轨道转角圆滑半径"] = "railCornerRadius",
			["轨道转角180度分段数"] = "railCornerSegments"
		},
		ElectroKingGrid = {
			["节点间最小生成间距"] = "minWallSpawnSpacing",
			["节点驻留时间"] = "nodeResidueDuration",
			["每个节点连接最近节点数"] = "nearestNeighborCount",
			["节点数组防御上限"] = "maxNodeCount",
			["电击触发间隔秒数"] = "shockInterval",
			["单次电击持续时间"] = "shockActiveDuration",
			["电击伤害频率秒数"] = "shockTickInterval",
			["电击每次伤害"] = "shockDamagePerTick"
		},
		ChargedBow = {
			["移动蓄力间隔秒数"] = "moveIntervalBeforeCharge",
			["蓄力所需时间"] = "chargeDuration",
			["拉弓阶段比例"] = "drawStageRatio",
			["箭矢速度"] = "arrowSpeed",
			["箭矢伤害"] = "arrowDamage",
			["最低蓄力伤害倍率"] = "minChargeDamageRatio",
			["箭矢反弹次数"] = "arrowBounceCount",
			["箭矢存活时间"] = "arrowLifetime"
		},
		Harpoon = {
			["发射间隔秒数"] = "throwInterval",
			["鱼叉飞行速度"] = "harpoonSpeed",
			["最大反弹次数"] = "maxBounceCount",
			["拉回速度"] = "pullSpeed",
			["命中判定半径"] = "hitRadius",
			["拖拽跳伤间隔秒数"] = "captureTickInterval",
			["拖拽每次跳伤伤害"] = "captureTickDamage"
		},
		HiveSwarm = {
			["发射间隔秒数"] = "emitInterval",
			["单波数量封顶"] = "maxBeesPerWave",
			["波内错峰基准间隔秒数"] = "waveReleaseBaseInterval",
			["波内错峰最小间隔秒数"] = "waveMinReleaseInterval",
			["小蜜蜂速度"] = "beeSpeed",
			["小蜜蜂转向角速度度每秒"] = "beeTurnRateDegrees",
			["命中判定半径"] = "beeHitRadius",
			["小蜜蜂最大存活时长秒数"] = "beeLifetime",
			["消失阶段匀减速时长秒数"] = "deathDecelDuration",
			["中毒跳伤次数"] = "poisonTickCount",
			["中毒跳伤间隔秒数"] = "poisonTickInterval",
			["中毒每次跳伤伤害"] = "poisonTickDamage",
			["场上小蜜蜂数量上限"] = "maxActiveBees",
			["单目标中毒实例数量上限"] = "maxPoisonStacksPerTarget"
		},
		RobuxBarrage = {
			["满血射击间隔秒数"] = "fullHealthShotInterval",
			["无血射击间隔秒数"] = "lowHealthShotInterval",
			["子弹基础伤害"] = "bulletDamage",
			["发射间隔秒数"] = "emitInterval",
			["单波释放时长秒数"] = "waveReleaseDuration",
			["高血量发射数量"] = "highHpCount",
			["二档血量阈值"] = "hpThreshold2",
			["二档发射数量"] = "waveCount2",
			["三档血量阈值"] = "hpThreshold3",
			["三档发射数量"] = "waveCount3",
			["四档血量阈值"] = "hpThreshold4",
			["四档发射数量"] = "waveCount4",
			["弹幕飞行速度"] = "projectileSpeed",
			["基础命中判定半径"] = "baseHitRadius",
			["最大存活时长秒数"] = "maxLifetime",
			["一阶命中伤害"] = "level1Damage",
			["二阶命中伤害"] = "level2Damage",
			["三阶命中伤害"] = "level3Damage",
			["一阶体型倍率"] = "level1Scale",
			["二阶体型倍率"] = "level2Scale",
			["三阶体型倍率"] = "level3Scale",
			["单球弹幕数量上限"] = "maxActiveProjectiles"
		},
		Shuriken = {
			["发射间隔秒数"] = "emitInterval",
			["单波数量封顶"] = "maxPerWave",
			["波内错峰基础间隔秒数"] = "waveReleaseBaseInterval",
			["波内错峰最小间隔秒数"] = "waveMinReleaseInterval",
			["手里剑飞行速度"] = "shurikenSpeed",
			["命中判定半径"] = "hitRadius",
			["最大存活时长秒数"] = "maxLifetime",
			["空中自转速度度每秒"] = "flightSpinSpeed",
			["命中伤害"] = "hitDamage",
			["场上手里剑数量上限"] = "maxActiveShurikens"
		},
		MedicBarrage = {
			["发射间隔秒数"] = "emitInterval",
			["弹幕飞行速度"] = "bulletSpeed",
			["最大反弹次数"] = "maxBounces",
			["命中判定半径"] = "hitRadius",
			["敌方命中伤害"] = "enemyDamage",
			["己方回血量"] = "allyHeal",
			["场上弹幕数量上限"] = "maxActiveBullets"
		},
		MathEquation = {
			["充能时长秒数"] = "chargeDuration",
			["字符冒出间隔秒数"] = "tokenInterval",
			["结果揭晓前停顿秒数"] = "resultRevealDelay",
			["发射前停顿秒数"] = "fireDelay",
			["加法操作数下限"] = "addOperandMin",
			["加法操作数上限"] = "addOperandMax",
			["乘法操作数下限"] = "mulOperandMin",
			["乘法操作数上限"] = "mulOperandMax",
			["乘法概率"] = "multiplyChance",
			["追踪弹速度"] = "bulletSpeed",
			["追踪弹转向角速度度每秒"] = "bulletTurnRateDegrees",
			["命中判定半径"] = "bulletHitRadius",
			["追踪弹最大存活时长秒数"] = "bulletLifetime",
			["场上追踪弹数量上限"] = "maxActiveBullets"
		},
		PoisonOnHit = {
			["中毒持续时间"] = "poisonDuration",
			["中毒跳伤间隔秒数"] = "poisonTickInterval",
			["中毒每次跳伤伤害"] = "poisonTickDamage",
			["中毒减速倍率"] = "poisonSlowMultiplier"
		},
		VirusOnHit = {
			["中毒持续时间"] = "poisonDuration",
			["中毒跳伤间隔秒数"] = "poisonTickInterval",
			["中毒每次跳伤伤害"] = "poisonTickDamage",
			["中毒减速倍率"] = "poisonSlowMultiplier",
			["本体基础伤害"] = "attack"
		},
		SlowOnHit = {
			["减速持续时间"] = "slowDuration",
			["减速倍率"] = "slowMultiplier"
		},
		FreezeOnHit = {
			["冻结持续时间"] = "slowDuration"
		},
		ElectromagneticParalysis = {
			["触发命中次数"] = "hitCount",
			["冻结持续时间"] = "slowDuration"
		},
		DamageAmplification = {
			["伤害倍率"] = "damageMultiplier"
		},
		Knockback = {
			["加速持续时间"] = "duration",
			["速度倍率"] = "speedMultiplier"
		},
		StrongParalysis = {
			["冻结持续时间"] = "slowDuration"
		},
		Gravity = {
			["牵引加速度"] = "pullAcceleration",
			["最大牵引速度"] = "maxPullSpeed"
		},
		LowHpArmor = {
			["生命阈值"] = "hpThreshold",
			["减伤比例"] = "damageReduction"
		},
		GamblerStrike = {
			["生命阈值"] = "hpThreshold",
			["伤害加成比例"] = "damageBonus"
		},
		ArmorBreaker = {
			["目标生命阈值"] = "hpThreshold",
			["伤害加成比例"] = "damageBonus"
		},
		AllIn = {
			["最大生命降低比例"] = "maxHpPenalty",
			["攻击力提升比例"] = "attackBonus",
			["速度提升比例"] = "speedBonus"
		},
		LuckyCrit = {
			["暴击概率"] = "critChance",
			["暴击倍率"] = "critMultiplier"
		},
		WallCharge = {
			["蓄力伤害倍率"] = "bonusMultiplier"
		},
		SprintStart = {
			["持续时间"] = "duration",
			["速度倍率"] = "speedMultiplier"
		},
		BounceAccel = {
			["加速持续时间"] = "duration",
			["速度倍率"] = "speedMultiplier"
		},
		BallHitAccel = {
			["加速持续时间"] = "duration",
			["速度倍率"] = "speedMultiplier"
		},
		ComboStrike = {
			["连击窗口秒数"] = "comboWindow",
			["每层加成"] = "bonusPerHit",
			["最大层数"] = "maxStacks"
		},
		Execute = {
			["目标生命阈值"] = "hpThreshold",
			["伤害倍率"] = "damageMultiplier"
		},
		SelfRepair = {
			["回复间隔秒数"] = "tickInterval",
			["每次回复量"] = "healAmount"
		},
		CollisionHeal = {
			["每次回复量"] = "healAmount"
		},
		Shield = {
			["每场护盾层数"] = "charges"
		},
		AntiFreeze = {
			["减速持续时间降低比例"] = "slowDurationReduction"
		},
		Fireproof = {
			["中毒持续时间降低比例"] = "poisonDurationReduction"
		},
		GrievousWounds = {
			["治疗降低持续时间"] = "healReductionDuration",
			["治疗效果降低比例"] = "healReduction"
		},
		ExpandingAura = {
			["初始范围半径"] = "initialRadius",
			["范围半径上限"] = "maxRadius",
			["攻击间隔秒数"] = "attackInterval",
			["每次跳伤伤害"] = "attackDamagePerTick",
			["每次攻击范围增长量"] = "radiusGrowthPerTick"
		},
		FrostTrail = {
			["尾迹生成间隔秒数"] = "trailSpawnInterval",
			["单块冰霜存在时间"] = "trailDuration",
			["冰霜数组防御上限"] = "maxTrailCount",
			["冻结生效缓冲秒数"] = "slowDuration",
			["冻伤等级增长速度"] = "frostChargeRate",
			["冻伤等级上限"] = "frostMaxLevel",
			["一阶冻伤等级阈值"] = "frostTier1Threshold",
			["一阶跳伤间隔秒数"] = "frostTier1TickInterval",
			["一阶每次伤害"] = "frostTier1Damage",
			["二阶冻伤等级阈值"] = "frostTier2Threshold",
			["二阶跳伤间隔秒数"] = "frostTier2TickInterval",
			["二阶每次伤害"] = "frostTier2Damage",
			["三阶冻伤等级阈值"] = "frostTier3Threshold",
			["三阶跳伤间隔秒数"] = "frostTier3TickInterval",
			["三阶每次伤害"] = "frostTier3Damage"
		},
		AlchemistGasTrail = {
			["尾迹生成间隔秒数"] = "trailSpawnInterval",
			["单块毒气存在时间"] = "trailDuration",
			["毒气数组防御上限"] = "maxTrailCount",
			["中毒持续时间"] = "poisonDuration",
			["中毒跳伤间隔秒数"] = "poisonTickInterval",
			["中毒每次跳伤伤害"] = "poisonTickDamage",
			["中毒减速倍率"] = "poisonSlowMultiplier"
		},
		DogCannon = {
			["蓄力时长秒数"] = "chargeDuration",
			["蓄力初始粒子间隔秒数"] = "particleIntervalStart",
			["蓄满粒子间隔秒数"] = "particleIntervalEnd",
			["单次粒子数量"] = "particleEmitCount",
			["光束持续时间秒数"] = "beamDuration",
			["光束跳伤间隔秒数"] = "beamTickInterval",
			["光束单次跳伤伤害"] = "beamDamagePerTick",
			["光束转一圈秒数"] = "beamTurnPeriod"
		},
		TimeBomb = {
			["安放间隔秒数"] = "placeInterval",
			["最大同时存在炸弹数"] = "maxBombCount",
			["爆炸倒计时秒数"] = "bombFuseDuration",
			["爆炸伤害"] = "explosionDamage",
			["击飞初速度"] = "explosionImpulseSpeed",
			["击飞衰减时长秒数"] = "explosionImpulseDuration"
		},
		PotionThrow = {
			["抛掷间隔秒数"] = "throwInterval",
			["预警晃动秒数"] = "windupDuration",
			["飞行时长秒数"] = "flightDuration",
			["抛物线弧高"] = "flightArcHeight",
			["空中自转速度度每秒"] = "flightSpinSpeed",
			["预警阶段贴附距离微调"] = "holdOffset",
			["预警晃动频率"] = "windupWobbleFrequency",
			["预警晃动幅度度数"] = "windupWobbleAmplitude",
			["同时存在药水区域上限"] = "maxActivePotionCount",
			["落点边界安全边距"] = "arenaEdgePadding",
			["区域到期后残留清理秒数"] = "regionResidueLifetime",
			["红色区域持续时间"] = "redRegionDuration",
			["红色跳伤间隔秒数"] = "redTickInterval",
			["红色每次跳伤伤害"] = "redTickDamage",
			["绿色区域持续时间"] = "greenRegionDuration",
			["中毒刷新间隔秒数"] = "greenReapplyInterval",
			["中毒持续时间"] = "poisonDuration",
			["中毒跳伤间隔秒数"] = "poisonTickInterval",
			["中毒每次跳伤伤害"] = "poisonTickDamage",
			["中毒减速倍率"] = "poisonSlowMultiplier",
			["蓝色区域持续时间"] = "blueRegionDuration",
			["冻结生效缓冲秒数"] = "slowDuration",
			["冻伤等级增长速度"] = "potionFrostChargeRate",
			["冻伤等级上限"] = "potionFrostMaxLevel",
			["一阶冻伤等级阈值"] = "potionFrostTier1Threshold",
			["一阶跳伤间隔秒数"] = "potionFrostTier1TickInterval",
			["一阶每次伤害"] = "potionFrostTier1Damage",
			["二阶冻伤等级阈值"] = "potionFrostTier2Threshold",
			["二阶跳伤间隔秒数"] = "potionFrostTier2TickInterval",
			["二阶每次伤害"] = "potionFrostTier2Damage",
			["三阶冻伤等级阈值"] = "potionFrostTier3Threshold",
			["三阶跳伤间隔秒数"] = "potionFrostTier3TickInterval",
			["三阶每次伤害"] = "potionFrostTier3Damage"
		},
		CactusThrow = {
			["抛出间隔秒数"] = "throwInterval",
			["单轮抛出数量"] = "cactusCount",
			["飞行时长秒数"] = "flightDuration",
			["抛物线弧高"] = "flightArcHeight",
			["仙人掌存在时长秒数"] = "cactusDuration",
			["同时存在上限"] = "maxActiveCactusCount",
			["落点边界安全边距"] = "arenaEdgePadding",
			["仙人掌间最小间距"] = "minCactusSpacing",
			["区域残留清理秒数"] = "regionResidueLifetime",
			["接触伤害"] = "touchDamage",
			["同目标再次判定冷却秒数"] = "hitCooldown"
		},
		TrapRelease = {
			["释放间隔秒数"] = "releaseInterval",
			["单轮释放数量"] = "trapCount",
			["生成范围半径"] = "spawnRadius",
			["陷阱存在时长秒数"] = "trapDuration",
			["同时存在上限"] = "maxActiveTrapCount",
			["落点边界安全边距"] = "arenaEdgePadding",
			["陷阱间最小间距"] = "minTrapSpacing",
			["到期后残留清理秒数"] = "regionResidueLifetime",
			["碰撞反弹每次扣血"] = "bounceDamage",
			["同目标再次判定冷却秒数"] = "bounceCooldown",
			["陷阱边界环粗细"] = "ringThickness"
		},
		SpearThrust = {
			["移动加速度"] = "speedGrowthPerSecond",
			["最大移动速度"] = "maxSpeed",
			["收起就绪判定阈值"] = "readyDotThreshold",
			["姿态过渡时长秒数"] = "poseTransitionDuration",
			["长矛命中冷却秒数"] = "spearHitCooldown",
			["长矛基础伤害"] = "spearBaseDamage"
		},
		Fibonacci = {
			["最大命中序号"] = "maxHitIndex"
		},
		VolcanoEruption = {
			["移动时长秒数"] = "moveDuration",
			["前摇时长秒数"] = "windupDuration",
			["喷发持续时间秒数"] = "eruptDuration",
			["最少火焰条数"] = "flameCountMin",
			["最多火焰条数"] = "flameCountMax",
			["扇形总角度"] = "fanAngleDegrees",
			["火焰延伸速度"] = "flameGrowSpeed",
			["火焰中减速倍率"] = "flameSlowMultiplier",
			["着火持续时间秒数"] = "burnDuration",
			["着火跳伤间隔秒数"] = "burnTickInterval",
			["着火每次跳伤伤害"] = "burnTickDamage"
		}
	}
}
local v = {
	VerityForms = {
		["二阶段模型"] = "stage2Model",
		["三阶段模型"] = "stage3Model",
		["进入二阶段特效"] = "stage2Effect",
		["进入三阶段特效"] = "stage3Effect"
	}
}

function SkillFeatureParser.parse(value, p, p2)
	local result = {}

	if typeof(value) == "table" then
		for k, item in value do
			local v2 = p2 and p2[k]

			if v2 then
				local v3

				if typeof(item) == "string" then
					v3 = item:match("%S")
				else
					v3 = false
				end

				assert(v3, "[SkillFeatureParser] 素材名称必须是非空字符串: " .. k)
				result[v2] = item:match("^%s*(.-)%s*$")
			else
				local v3 = p[k]

				if v3 then
					if typeof(item) == "number" then
						result[v3] = item
					else
						warn((`[SkillFeatureParser] feature 表字段不是数值: {k} = {tostring(item)}`))
					end
				else
					warn((`[SkillFeatureParser] 未登记的 feature key: {k}`))
				end
			end
		end
	else
		if typeof(value) ~= "string" then
			return result
		end

		for k in value:gmatch("[^,]+") do
			local match, v2 = k:match("^%s*(.-)%s*:%s*(.-)%s*$")

			if not (match and v2) then
				continue
			end

			local v3 = p2 and p2[match]

			if v3 then
				assert(v2:match("%S"), "[SkillFeatureParser] 素材名称不能为空: " .. match)
				result[v3] = v2
			else
				local v4 = p[match]

				if v4 then
					local v5

					if v2:sub(-1) == "%" then
						local v6 = tonumber(v2:sub(1, -2))
						v5 = v6 and v6 / 100 or nil
					else
						v5 = tonumber(v2)
					end

					if v5 then
						result[v4] = v5
					else
						warn((`[SkillFeatureParser] 无法解析数值: {match} = {v2}`))
					end
				else
					warn((`[SkillFeatureParser] 未登记的 feature key: {match}`))
				end
			end
		end
	end

	return result
end

function SkillFeatureParser.overlayTraits(items, p)
	if typeof(p) ~= "table" or typeof(p.byCnId) ~= "table" then
		warn("[SkillFeatureParser] Config.skill 为空，traits 保持代码默认值")
		return
	end

	for k, item in items do
		local v2 = SkillFeatureParser.FEATURE_KEY_MAP[k]
		local cnId = item.cnId

		if not (v2 and typeof(cnId) == "string") then
			continue
		end

		local v3 = p.byCnId[cnId]

		if v3 then
			if typeof(v3.feature) == "string" or typeof(v3.feature) == "table" then
				local parsed = SkillFeatureParser.parse(v3.feature, v2, v[k])

				for k2, v4 in parsed do
					item[k2] = v4
				end

				item.rawFeature = SkillFeatureParser.parseRaw(v3.feature)
			end

			item.displayName = v3.displayName or item.displayName
			item.displayNameCN = v3.displayNameCN or item.displayNameCN
			item.desc = v3.desc or item.desc
			item.descCN = v3.descCN or item.descCN
			item.assetName = v3.assetName or item.assetName
		else
			warn((`[SkillFeatureParser] 飞书 skill 表找不到: {cnId}`))
		end
	end
end

function SkillFeatureParser.parseRaw(value)
	local result = {}

	if typeof(value) == "table" then
		for k, item in value do
			result[k] = tostring(item)
		end
	else
		if typeof(value) ~= "string" then
			return result
		end

		for k in value:gmatch("[^,]+") do
			local match, v2 = k:match("^%s*(.-)%s*:%s*(.-)%s*$")

			if match and v2 then
				result[match] = v2
			end
		end
	end

	return result
end

function SkillFeatureParser.formatDescription(value: string?, options)
	if typeof(value) ~= "string" then
		return ""
	end

	local v2 = options or {}
	return (value:gsub("{([^{}]+)}", function(p: string)
		return v2[p] or "{" .. p .. "}"
	end))
end

return SkillFeatureParser