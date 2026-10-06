local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DuelAudioController = require(ReplicatedStorage:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("DuelAudioController"))
local TweenService = game:GetService("TweenService")
game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("GeometryService")
local RenderMath = require(script.Parent.RenderMath)
local TemplateLibrary = require(script.Parent.TemplateLibrary)
local TraitVisual_VerityForms = require(script.Parent.TraitVisual_VerityForms)
local EventEffects = require(script.Parent.EventEffects)
local EffectPlayer = require(ReplicatedStorage2:WaitForChild("Engine"):WaitForChild("Service"):WaitForChild("EffectPlayer"))
local TraitVisual_Zone = require(script.Parent.TraitVisual_Zone)
local TraitVisual_Laser = require(script.Parent.TraitVisual_Laser)
local TraitVisual_SpiderWeb = require(script.Parent.TraitVisual_SpiderWeb)
local TraitVisual_PoisonSpike = require(script.Parent.TraitVisual_PoisonSpike)
local TraitVisual_BigSpike = require(script.Parent.TraitVisual_BigSpike)
local TraitVisual_Blade = require(script.Parent.TraitVisual_Blade)
local TraitVisual_ThomasUpgrade = require(script.Parent.TraitVisual_ThomasUpgrade)
local TraitVisual_Shield = require(script.Parent.TraitVisual_Shield)
local TraitVisual_Poison = require(script.Parent.TraitVisual_Poison)
local TraitVisual_BurstDrive = require(script.Parent.TraitVisual_BurstDrive)
local TraitVisual_NoCollisionCharge = require(script.Parent.TraitVisual_NoCollisionCharge)
local TraitVisual_Gravity = require(script.Parent.TraitVisual_Gravity)
local TraitVisual_BuffAura = require(script.Parent.TraitVisual_BuffAura)
local TraitVisual_ChessPath = require(script.Parent.TraitVisual_ChessPath)
local TraitVisual_WDC = require(script.Parent.TraitVisual_WDC)
local TraitVisual_SpeedEffect = require(script.Parent.TraitVisual_SpeedEffect)
local TraitVisual_FreezeEffect = require(script.Parent.TraitVisual_FreezeEffect)
local TraitVisual_ElectromagneticParalysis = require(script.Parent.TraitVisual_ElectromagneticParalysis)
local TraitVisual_StrongParalysis = require(script.Parent.TraitVisual_StrongParalysis)
local TraitVisual_SlowOnHit = require(script.Parent.TraitVisual_SlowOnHit)
local TraitVisual_GlassShards = require(script.Parent.TraitVisual_GlassShards)
local TraitVisual_MachineGun = require(script.Parent.TraitVisual_MachineGun)
local TraitVisual_ThiefKnives = require(script.Parent.TraitVisual_ThiefKnives)
local TraitVisual_OrbitSatellite = require(script.Parent.TraitVisual_OrbitSatellite)
local TraitVisual_SnakeTail = require(script.Parent.TraitVisual_SnakeTail)
local TraitVisual_IceConeTrail = require(script.Parent.TraitVisual_IceConeTrail)
local TraitVisual_TimeBomb = require(script.Parent.TraitVisual_TimeBomb)
local TraitVisual_PotionThrow = require(script.Parent.TraitVisual_PotionThrow)
local TraitVisual_CactusThrow = require(script.Parent.TraitVisual_CactusThrow)
local TraitVisual_TrapRelease = require(script.Parent.TraitVisual_TrapRelease)
local TraitVisual_SpearThrust = require(script.Parent.TraitVisual_SpearThrust)
local TraitVisual_OnePunch = require(script.Parent.TraitVisual_OnePunch)
local TraitVisual_Fibonacci = require(script.Parent.TraitVisual_Fibonacci)
local TraitVisual_DiceBarrage = require(script.Parent.TraitVisual_DiceBarrage)
local TraitVisual_VoltaicShock = require(script.Parent.TraitVisual_VoltaicShock)
local TraitVisual_Haste = require(script.Parent.TraitVisual_Haste)
local TraitVisual_Apple = require(script.Parent.TraitVisual_Apple)
local TraitVisual_AcidSpit = require(script.Parent.TraitVisual_AcidSpit)
local TraitVisual_CannonTurret = require(script.Parent.TraitVisual_CannonTurret)
local TraitVisual_LaserTurretV3 = require(script.Parent.TraitVisual_LaserTurretV3)
local TraitVisual_ChargedBow = require(script.Parent.TraitVisual_ChargedBow)
local TraitVisual_Harpoon = require(script.Parent.TraitVisual_Harpoon)
local TraitVisual_HiveSwarm = require(script.Parent.TraitVisual_HiveSwarm)
local TraitVisual_Shuriken = require(script.Parent.TraitVisual_Shuriken)
local TraitVisual_RobuxBarrage = require(script.Parent.TraitVisual_RobuxBarrage)
local TraitVisual_MedicBarrage = require(script.Parent.TraitVisual_MedicBarrage)
local TraitVisual_MathEquation = require(script.Parent.TraitVisual_MathEquation)
local TraitVisual_ElectroKing = require(script.Parent.TraitVisual_ElectroKing)
local TraitVisual_TrainTrack = require(script.Parent.TraitVisual_TrainTrack)
local TraitVisual_DogCannon = require(script.Parent.TraitVisual_DogCannon)
local TraitVisual_VolcanoEruption = require(script.Parent.TraitVisual_VolcanoEruption)
local TraitVisual_Burn = require(script.Parent.TraitVisual_Burn)
local TraitVisual_ExpandingAura = require(script.Parent.TraitVisual_ExpandingAura)
local TraitVisual_FrostTrail = require(script.Parent.TraitVisual_FrostTrail)
local TraitVisual_AlchemistGasTrail = require(script.Parent.TraitVisual_AlchemistGasTrail)
local v = ReplicatedStorage2:WaitForChild("美术素材"):WaitForChild("杂项"):WaitForChild("发射方向箭头")
local VisualRenderer = {}
VisualRenderer.__index = VisualRenderer

function VisualRenderer.new(ctx)
	local object = setmetatable({}, VisualRenderer)
	object._ctx = ctx
	object.config = ctx.config
	object.instanceId = ctx.instanceId
	object.arenaCFrame = ctx.arenaCFrame
	object.effectArenaRotation = RenderMath.getEffectArenaRotation(ctx.arenaCFrame)
	object.arenaScale = ctx.arenaScale
	object.rootFolder = nil
	object._audio = nil
	object._identity = nil
	object.localParticipantSlotId = nil
	object.forceHighlightAllEnemies = false
	object.currentRoleIds = {}
	object.sameMaterialEnemyHighlightTemplate = nil
	object.ballModels = {}
	object.ballModelRoleIds = {}
	object.ballModelStages = {}
	object._verityVisual = TraitVisual_VerityForms.new(object)
	object.ballParts = {}
	object._dogCannonLastPhase = {}
	object._dogCannonFacingEase = {}
	object._latestBallStates = {}
	object._hookHandles = {}
	object.ballTeams = {}
	object.lastVanishedBallPositions = {}
	object.ballOwnerIds = {}
	object.ballHealthLabels = {}
	object.ballHealthBillboards = {}
	object.ballHitHighlights = {}
	object.ballHitFlashTweens = {}
	object.launchArrowModels = {}
	object.launchArrowDirections = {}
	object.launchArrowCleared = {}
	object.launchArrowSpawnedAt = {}
	object.ballTemplateBundles = {}
	object.redStringTemplateBundle = nil
	object.spiderWebTemplateBundle = nil
	object.vampireWebTemplateBundle = nil
	object.poisonSpikeTemplateBundle = nil
	object.bigSpikeTemplateBundle = nil
	object.boardTemplate = nil
	object.boardModel = nil
	local loaded = TemplateLibrary.load(ReplicatedStorage2, object.config)
	object.sameMaterialEnemyHighlightTemplate = loaded.sameMaterialEnemyHighlightTemplate
	object.ballTemplateBundles = loaded.ballTemplateBundles
	object.redStringTemplateBundle = loaded.redStringTemplateBundle
	object.spiderWebTemplateBundle = loaded.spiderWebTemplateBundle
	object.vampireWebTemplateBundle = loaded.vampireWebTemplateBundle
	object.poisonSpikeTemplateBundle = loaded.poisonSpikeTemplateBundle
	object.bigSpikeTemplateBundle = loaded.bigSpikeTemplateBundle
	object.boardTemplate = loaded.boardTemplate
	object.effectAssetRoot = loaded.effectAssetRoot
	object:_buildScene()
	local audio = {
		playCue = function(self, p, p2)
			if object._audio then
				object._audio:playCue(p, p2)
			end
		end
	}

	function object.onHitFlash(p)
		object:_flashHitHighlight(p)
	end

	function object.onCameraImpact(p, p2)
		local onCameraImpact = object._ctx.onCameraImpact

		if onCameraImpact then
			onCameraImpact(p, p2)
		end
	end

	object._eventEffects = EventEffects.new(object)
	object._zoneVisual = TraitVisual_Zone.new({
		rootFolder = object.rootFolder,
		config = object.config,
		arenaCFrame = object.arenaCFrame,
		arenaScale = object.arenaScale,
		redStringTemplateBundle = object.redStringTemplateBundle,
		zoneStyleTemplate = loaded.zoneStyleTemplate,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		getBallMarkerHeight = function(p)
			return object:_getBallMarkerHeight(p)
		end,
		audio = audio
	})
	object._laserVisual = TraitVisual_Laser.new({
		rootFolder = object.rootFolder,
		laserTemplate = loaded.laserTemplate,
		effectArenaRotation = object.effectArenaRotation,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		getBallMarkerHeight = function(p)
			return object:_getBallMarkerHeight(p)
		end
	})
	object._electroKingVisual = TraitVisual_ElectroKing.new({
		rootFolder = object.rootFolder,
		electroKingTemplate = loaded.electroKingTemplate,
		effectArenaRotation = object.effectArenaRotation,
		config = object.config,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		getBallMarkerHeight = function(p)
			return object:_getBallMarkerHeight(p)
		end
	})
	object._trainTrackVisual = TraitVisual_TrainTrack.new({
		rootFolder = object.rootFolder,
		config = object.config,
		arenaCFrame = object.arenaCFrame,
		arenaScale = object.arenaScale,
		trainHeadTemplateBundle = loaded.trainHeadTemplateBundle,
		trainBodyTemplateBundle = loaded.trainBodyTemplateBundle,
		trackSleeperTemplateBundle = loaded.trackSleeperTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		setTemplateModelVisibility = function(p, p2)
			object:_setTemplateModelVisibility(p, p2)
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		getBallMarkerHeight = function(p)
			return object:_getBallMarkerHeight(p)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end
	})
	object._dogCannonVisual = TraitVisual_DogCannon.new({
		rootFolder = object.rootFolder,
		config = object.config.traits.DogCannon,
		dogCannonTemplate = loaded.dogCannonTemplate,
		dogChargeTemplateBundle = loaded.dogChargeTemplateBundle,
		effectArenaRotation = object.effectArenaRotation,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		getBallMarkerHeight = function(p)
			return object:_getBallMarkerHeight(p)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end
	})
	object._volcanoEruptionVisual = TraitVisual_VolcanoEruption.new({
		flameTemplateBundle = loaded.volcanoFlameTemplateBundle,
		warningTemplateBundle = loaded.volcanoWarningTemplateBundle,
		arenaNormal = object.arenaCFrame.LookVector,
		flameFadeDuration = object.config.visual.volcanoFlameFadeDuration or 0.35,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		getBallMarkerHeight = function(p)
			return object:_getBallMarkerHeight(p)
		end
	})
	object._spiderWebVisual = TraitVisual_SpiderWeb.new({
		config = object.config,
		arenaScale = object.arenaScale,
		audio = audio,
		effectAssetRoot = loaded.effectAssetRoot,
		getTemplateBundle = function(_, _)
			return object.spiderWebTemplateBundle
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		getBallMarkerHeight = function(p)
			return object:_getBallMarkerHeight(p)
		end,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end
	})
	object._vampireWebVisual = TraitVisual_SpiderWeb.new({
		config = object.config,
		arenaScale = object.arenaScale,
		audio = audio,
		effectAssetRoot = loaded.effectAssetRoot,
		getTemplateBundle = function(_, _)
			return object.vampireWebTemplateBundle
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		getBallMarkerHeight = function(p)
			return object:_getBallMarkerHeight(p)
		end,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		websField = "vampireWebs",
		templateNameKey = "vampireWebTemplateName",
		instanceTag = "VampireWeb"
	})
	object._voltaicShockVisual = TraitVisual_VoltaicShock.new({
		config = object.config,
		effectAssetRoot = loaded.effectAssetRoot,
		rootFolder = object.rootFolder,
		audio = audio,
		effectArenaRotation = object.effectArenaRotation,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end
	})
	object._poisonSpikeVisual = TraitVisual_PoisonSpike.new({
		config = object.config,
		arenaScale = object.arenaScale,
		arenaCFrame = object.arenaCFrame,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		getTemplateBundle = function(_)
			return object.poisonSpikeTemplateBundle
		end
	})
	object._bigSpikeVisual = TraitVisual_BigSpike.new({
		config = object.config,
		arenaScale = object.arenaScale,
		arenaCFrame = object.arenaCFrame,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		getTemplateBundle = function(_)
			return object.bigSpikeTemplateBundle
		end
	})
	object._bladeVisual = TraitVisual_Blade.new({
		config = object.config,
		arenaCFrame = object.arenaCFrame,
		arenaScale = object.arenaScale,
		bladeTemplateBundle = loaded.bladeTemplateBundle,
		swordTemplateBundle = loaded.swordTemplateBundle,
		axeTemplateBundle = loaded.axeTemplateBundle,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		setTemplateModelVisibility = function(p, p2)
			object:_setTemplateModelVisibility(p, p2)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end,
		playOneShotModelEffect = function(self, p2, p3, p4)
			object._eventEffects:playOneShotModelEffect(self, p2, p3, p4)
		end,
		audio = audio
	})
	object._speedEffectVisual = TraitVisual_SpeedEffect.new({
		templateBundle = loaded.speedEffectTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end
	})
	object._freezeEffectVisual = TraitVisual_FreezeEffect.new({
		templateBundle = loaded.freezeEffectTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end
	})
	object._electromagneticParalysisVisual = TraitVisual_ElectromagneticParalysis.new({
		progress1TemplateBundle = loaded.electromagneticParalysisProgress1TemplateBundle,
		progress2TemplateBundle = loaded.electromagneticParalysisProgress2TemplateBundle,
		paralyzedTemplateBundle = loaded.electromagneticParalysisParalyzedTemplateBundle,
		getArenaBallCFrame = function(p)
			return object:_getArenaBallCFrame(p)
		end,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end
	})
	object._strongParalysisVisual = TraitVisual_StrongParalysis.new({
		templateBundle = loaded.strongParalysisTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end
	})
	object._slowOnHitVisual = TraitVisual_SlowOnHit.new({
		templateBundle = loaded.slowOnHitTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end
	})
	object._hasteVisual = TraitVisual_Haste.new({
		templateBundle = loaded.speedEffectTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end
	})
	object._shieldVisual = TraitVisual_Shield.new({
		templateBundle = loaded.shieldTemplateBundle,
		getArenaBallCFrame = function(p)
			return object:_getArenaBallCFrame(p)
		end,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end
	})
	object._expandingAuraVisual = TraitVisual_ExpandingAura.new({
		templateBundle = loaded.expandingAuraTemplateBundle,
		getArenaBallCFrame = function(p)
			return object:_getArenaBallCFrame(p)
		end,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end
	})
	object._frostTrailVisual = TraitVisual_FrostTrail.new({
		rootFolder = object.rootFolder,
		frostTrailTemplateBundle = loaded.frostTrailTemplateBundle,
		config = object.config,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		getArenaBallCFrame = function(p)
			return object:_getArenaBallCFrame(p)
		end
	})
	object._alchemistGasTrailVisual = TraitVisual_AlchemistGasTrail.new({
		rootFolder = object.rootFolder,
		alchemistGasTrailTemplateBundle = loaded.alchemistGasTrailTemplateBundle,
		config = object.config,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		getArenaBallCFrame = function(p)
			return object:_getArenaBallCFrame(p)
		end
	})
	object._poisonVisual = TraitVisual_Poison.new({
		templateBundle = loaded.poisonTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end
	})
	object._burnVisual = TraitVisual_Burn.new({
		templateBundle = loaded.volcanoBurnTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end
	})
	object._burstDriveVisual = TraitVisual_BurstDrive.new({
		templateBundle = loaded.burstDriveTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end
	})
	object._noCollisionChargeVisual = TraitVisual_NoCollisionCharge.new({
		templateBundle = loaded.noCollisionChargeTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end
	})
	object._gravityVisual = TraitVisual_Gravity.new({
		templateBundle = loaded.gravityTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end
	})
	object._buffAuraVisual = TraitVisual_BuffAura.new({
		attackTemplateBundle = loaded.attackBuffTemplateBundle,
		defenseTemplateBundle = loaded.defenseBuffTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end
	})
	object._chessPathVisual = TraitVisual_ChessPath.new({
		rootFolder = object.rootFolder,
		chessAssets = loaded.chessAssets,
		shieldTemplateBundle = loaded.vampireShieldTemplateBundle,
		config = object.config.traits.ChessPath,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		boardSize = function()
			return Vector2.new(object:_scaled(object.config.arena.size.X), object:_scaled(object.config.arena.size.Y))
		end,
		upVector = function()
			return object.arenaCFrame.UpVector
		end,
		pieceCFrame = function(p)
			return CFrame.fromMatrix(
				p,
				object.arenaCFrame.RightVector,
				object.arenaCFrame.UpVector,
				-object.arenaCFrame.LookVector
			)
		end,
		boardCFrame = function()
			return object.arenaCFrame * CFrame.new(0, 0, 0.08)
		end
	})
	object._wdcVisual = TraitVisual_WDC.new({
		wdcTemplateBundle = loaded.wdcTemplateBundle,
		config = object.config.traits.WDC,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		boardSize = function()
			return Vector2.new(object:_scaled(object.config.arena.size.X), object:_scaled(object.config.arena.size.Y))
		end,
		boardCFrame = function()
			return object.arenaCFrame * CFrame.new(0, 0, 0.4)
		end
	})
	object._thomasVisual = TraitVisual_ThomasUpgrade.new({
		rootFolder = object.rootFolder,
		templateBundle = loaded.thomasTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		getArenaBallCFrame = function(p)
			return object:_getArenaBallCFrame(p)
		end,
		setTemplateModelVisibility = function(p, p2)
			object:_setTemplateModelVisibility(p, p2)
		end
	})
	object._glassShardsVisual = TraitVisual_GlassShards.new({
		rootFolder = object.rootFolder,
		glassShardTemplateBundle = loaded.glassShardTemplateBundle,
		effectArenaRotation = object.effectArenaRotation,
		debugEnabled = object.config.debug and object.config.debug.glassShardRendering == true,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		setTemplateModelVisibility = function(p, p2)
			object:_setTemplateModelVisibility(p, p2)
		end
	})
	object._machineGunVisual = TraitVisual_MachineGun.new({
		rootFolder = object.rootFolder,
		machineGunBulletTemplateBundle = loaded.machineGunBulletTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		setTemplateModelVisibility = function(p, p2)
			object:_setTemplateModelVisibility(p, p2)
		end,
		worldFromArena = function(p)
			return object:_worldFromArena(p)
		end
	})
	object._appleVisual = TraitVisual_Apple.new({
		rootFolder = object.rootFolder,
		appleTemplateBundle = loaded.appleTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		getArenaBallCFrame = function(p)
			return object:_getArenaBallCFrame(p)
		end
	})
	object._acidSpitVisual = TraitVisual_AcidSpit.new({
		rootFolder = object.rootFolder,
		config = object.config.traits.AcidSpit or {},
		templateBundle = loaded.acidSpitTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		getArenaBallCFrame = function(p)
			return object:_getArenaBallCFrame(p)
		end
	})
	object._cannonTurretVisual = TraitVisual_CannonTurret.new({
		rootFolder = object.rootFolder,
		arenaCFrame = object.arenaCFrame,
		cannonTurretTemplateBundle = loaded.cannonTurretTemplateBundle,
		cannonBulletTemplateBundle = loaded.cannonBulletTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		setTemplateModelVisibility = function(p, p2)
			object:_setTemplateModelVisibility(p, p2)
		end,
		worldFromArena = function(p)
			return object:_worldFromArena(p)
		end
	})
	object._laserTurretV3Visual = TraitVisual_LaserTurretV3.new({
		rootFolder = object.rootFolder,
		config = object.config,
		arenaCFrame = object.arenaCFrame,
		laserTurretV3TemplateBundle = loaded.laserTurretV3TemplateBundle,
		laserTurretV3BeamTemplate = loaded.laserTurretV3BeamTemplate,
		effectArenaRotation = object.effectArenaRotation,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		setTemplateModelVisibility = function(p, p2)
			object:_setTemplateModelVisibility(p, p2)
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		getBallMarkerHeight = function(p)
			return object:_getBallMarkerHeight(p)
		end
	})
	object._chargedBowVisual = TraitVisual_ChargedBow.new({
		rootFolder = object.rootFolder,
		config = object.config,
		bowTemplateBundle = loaded.bowTemplateBundle,
		arrowTemplateBundle = loaded.arrowTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		setTemplateModelVisibility = function(p, p2)
			object:_setTemplateModelVisibility(p, p2)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end,
		worldFromArena = function(p)
			return object:_worldFromArena(p)
		end
	})
	object._harpoonVisual = TraitVisual_Harpoon.new({
		rootFolder = object.rootFolder,
		config = object.config,
		arenaCFrame = object.arenaCFrame,
		harpoonTemplateBundle = loaded.harpoonTemplateBundle,
		effectArenaRotation = object.effectArenaRotation,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		setTemplateModelVisibility = function(p, p2)
			object:_setTemplateModelVisibility(p, p2)
		end,
		worldFromArena = function(p)
			return object:_worldFromArena(p)
		end
	})
	object._hiveSwarmVisual = TraitVisual_HiveSwarm.new({
		rootFolder = object.rootFolder,
		config = object.config,
		arenaCFrame = object.arenaCFrame,
		hiveBeeTemplateBundle = loaded.hiveBeeTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		setTemplateModelVisibility = function(p, p2)
			object:_setTemplateModelVisibility(p, p2)
		end,
		worldFromArena = function(p)
			return object:_worldFromArena(p)
		end
	})
	object._shurikenVisual = TraitVisual_Shuriken.new({
		rootFolder = object.rootFolder,
		config = object.config,
		arenaCFrame = object.arenaCFrame,
		shurikenTemplateBundle = loaded.shurikenTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		setTemplateModelVisibility = function(p, p2)
			object:_setTemplateModelVisibility(p, p2)
		end,
		worldFromArena = function(p)
			return object:_worldFromArena(p)
		end
	})
	object._robuxVisual = TraitVisual_RobuxBarrage.new({
		rootFolder = object.rootFolder,
		config = object.config,
		arenaScale = object.arenaScale,
		arenaCFrame = object.arenaCFrame,
		robuxTemplateBundle = loaded.robuxTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		setTemplateModelVisibility = function(p, p2)
			object:_setTemplateModelVisibility(p, p2)
		end,
		worldFromArena = function(p)
			return object:_worldFromArena(p)
		end
	})
	object._medicBarrageVisual = TraitVisual_MedicBarrage.new({
		rootFolder = object.rootFolder,
		config = object.config,
		arenaCFrame = object.arenaCFrame,
		medicBulletTemplateBundle = loaded.medicBulletTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		setTemplateModelVisibility = function(p, p2)
			object:_setTemplateModelVisibility(p, p2)
		end,
		worldFromArena = function(p)
			return object:_worldFromArena(p)
		end
	})
	object._mathEquationVisual = TraitVisual_MathEquation.new({
		rootFolder = object.rootFolder,
		config = object.config,
		arenaCFrame = object.arenaCFrame,
		arenaScale = object.arenaScale,
		mathBulletTemplateBundle = loaded.mathBulletTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		setTemplateModelVisibility = function(p, p2)
			object:_setTemplateModelVisibility(p, p2)
		end,
		worldFromArena = function(p)
			return object:_worldFromArena(p)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end
	})
	object._iceConeTrailVisual = TraitVisual_IceConeTrail.new({
		rootFolder = object.rootFolder,
		config = object.config,
		iceConeTemplateBundle = loaded.iceConeTemplateBundle,
		effectArenaRotation = object.effectArenaRotation,
		bombTemplate = loaded.iceConeTemplateBundle.model:WaitForChild("装饰"):WaitForChild("定时炸弹本体"),
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		setTemplateModelVisibility = function(p, p2)
			object:_setTemplateModelVisibility(p, p2)
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end
	})
	object._potionThrowVisual = TraitVisual_PotionThrow.new({
		rootFolder = object.rootFolder,
		config = object.config,
		potionRedFlyTemplateBundle = loaded.potionRedFlyTemplateBundle,
		potionGreenFlyTemplateBundle = loaded.potionGreenFlyTemplateBundle,
		potionBlueFlyTemplateBundle = loaded.potionBlueFlyTemplateBundle,
		potionRedRegionTemplateBundle = loaded.potionRedRegionTemplateBundle,
		potionGreenRegionTemplateBundle = loaded.potionGreenRegionTemplateBundle,
		potionBlueRegionTemplateBundle = loaded.potionBlueRegionTemplateBundle,
		effectArenaRotation = object.effectArenaRotation,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		getArenaBallCFrame = function(p)
			return object:_getArenaBallCFrame(p)
		end,
		arenaCFrame = object.arenaCFrame,
		playOneShotModelEffect = function(self, p2, p3, p4)
			object._eventEffects:playOneShotModelEffect(self, p2, p3, p4)
		end
	})
	object._cactusThrowVisual = TraitVisual_CactusThrow.new({
		rootFolder = object.rootFolder,
		config = object.config,
		arenaCFrame = object.arenaCFrame,
		cactusTemplateBundle = loaded.cactusTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		playOneShotModelEffect = function(self, p2, p3, p4)
			object._eventEffects:playOneShotModelEffect(self, p2, p3, p4)
		end
	})
	object._trapReleaseVisual = TraitVisual_TrapRelease.new({
		rootFolder = object.rootFolder,
		config = object.config,
		arenaCFrame = object.arenaCFrame,
		arenaScale = object.arenaScale,
		trapTemplateBundle = loaded.trapTemplateBundle,
		playOneShotModelEffect = function(self, p2, p3, p4)
			object._eventEffects:playOneShotModelEffect(self, p2, p3, p4)
		end,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end
	})
	object._fibonacciVisual = TraitVisual_Fibonacci.new({
		config = object.config,
		playOneShotModelEffect = function(self, p2, p3, p4)
			object._eventEffects:playOneShotModelEffect(self, p2, p3, p4)
		end
	})
	object._spearThrustVisual = TraitVisual_SpearThrust.new({
		rootFolder = object.rootFolder,
		arenaCFrame = object.arenaCFrame,
		spearTemplateBundle = loaded.spearTemplateBundle,
		spearDashEffectTemplateBundle = loaded.spearDashEffectTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		getBallMarkerHeight = function(p)
			return object:_getBallMarkerHeight(p)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end
	})
	object._onePunchVisual = TraitVisual_OnePunch.new({
		rootFolder = object.rootFolder,
		config = object.config,
		arenaCFrame = object.arenaCFrame,
		effectAssetRoot = object.effectAssetRoot,
		onePunchTrailTemplateBundle = loaded.onePunchTrailTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end,
		getEffectArenaRotation = function()
			return object.effectArenaRotation
		end,
		playOneShotModelEffect = function(self, p2, p3, p4)
			object._eventEffects:playOneShotModelEffect(self, p2, p3, p4)
		end
	})
	object._timeBombVisual = TraitVisual_TimeBomb.new({
		rootFolder = object.rootFolder,
		config = object.config,
		arenaCFrame = object.arenaCFrame,
		bombTemplateBundle = loaded.bombTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		setTemplateModelVisibility = function(p, p2)
			object:_setTemplateModelVisibility(p, p2)
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end
	})
	object._diceBarrageVisual = TraitVisual_DiceBarrage.new({
		config = object.config,
		diceTemplateBundle = loaded.diceTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		worldFromArena = function(p, p2)
			return object:_worldFromArena(p, p2)
		end,
		getArenaBallCFrame = function(p)
			return object:_getArenaBallCFrame(p)
		end
	})
	object._thiefKnivesVisual = TraitVisual_ThiefKnives.new({
		rootFolder = object.rootFolder,
		arenaCFrame = object.arenaCFrame,
		thiefKnifeTemplateBundle = loaded.thiefKnifeTemplateBundle,
		thiefChargeTemplateBundle = loaded.thiefChargeTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		setTemplateModelVisibility = function(p, p2)
			object:_setTemplateModelVisibility(p, p2)
		end,
		worldFromArena = function(p)
			return object:_worldFromArena(p)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end
	})
	object._orbitSatelliteVisual = TraitVisual_OrbitSatellite.new({
		rootFolder = object.rootFolder,
		config = object.config,
		arenaCFrame = object.arenaCFrame,
		arenaScale = object.arenaScale,
		orbitSatelliteTemplateBundle = loaded.orbitSatelliteTemplateBundle,
		cloneTemplateModel = function(p, p2)
			return object:_cloneTemplateModel(p, p2)
		end,
		setTemplateModelVisibility = function(p, p2)
			object:_setTemplateModelVisibility(p, p2)
		end,
		worldFromArena = function(p)
			return object:_worldFromArena(p)
		end,
		getBallPart = function(p)
			return object.ballParts[p]
		end
	})
	local snakeTailVisual

	if loaded.snakeTailTemplateBundle then
		snakeTailVisual = TraitVisual_SnakeTail.new({
			rootFolder = object.rootFolder,
			snakeTailTemplateBundle = loaded.snakeTailTemplateBundle,
			cloneTemplateModel = function(p, p2)
				return object:_cloneTemplateModel(p, p2)
			end,
			setTemplateModelVisibility = function(p, p2)
				object:_setTemplateModelVisibility(p, p2)
			end,
			worldFromArena = function(p)
				return object:_worldFromArena(p)
			end
		}) or nil
	end

	object._snakeTailVisual = snakeTailVisual
	return object
end

function VisualRenderer:bind(audio, identity)
	self._audio = audio
	self._identity = identity
end

function VisualRenderer:setLocalParticipantSlot(localParticipantSlotId: string?)
	self.localParticipantSlotId = localParticipantSlotId
	self:_refreshSameMaterialEnemyHighlights()
end

function VisualRenderer:setForceHighlightAllEnemies(forceHighlightAllEnemies: boolean)
	self.forceHighlightAllEnemies = forceHighlightAllEnemies
	self:_refreshSameMaterialEnemyHighlights()
end

function VisualRenderer:_getOwningSlotId(p2: string)
	return RenderMath.getOwningSlotId(self.config, p2)
end

function VisualRenderer:_refreshSameMaterialEnemyHighlights()
	if not (self.rootFolder and self.sameMaterialEnemyHighlightTemplate) then
		return
	end

	for _, descendant in ipairs(self.rootFolder:GetDescendants()) do
		if not (descendant:IsA("Model") or descendant:IsA("BasePart")) then
			continue
		end

		local battleOwnerSlotId = descendant:GetAttribute("BattleOwnerSlotId")

		if typeof(battleOwnerSlotId) ~= "string" then
			continue
		end

		local v2 = self:_getOwningSlotId(battleOwnerSlotId) or battleOwnerSlotId
		local sameMaterialEnemyHighlight = descendant:FindFirstChild("SameMaterialEnemyHighlight")
		local shouldHighlightSameMaterialEnemy = RenderMath.shouldHighlightSameMaterialEnemy(
			self.config,
			self.currentRoleIds,
			self.localParticipantSlotId,
			v2,
			self.forceHighlightAllEnemies
		)

		if shouldHighlightSameMaterialEnemy and not sameMaterialEnemyHighlight then
			local clone = self.sameMaterialEnemyHighlightTemplate:Clone()
			clone.Name = "SameMaterialEnemyHighlight"
			clone.Adornee = descendant
			clone.Parent = descendant
		elseif not shouldHighlightSameMaterialEnemy and sameMaterialEnemyHighlight then
			sameMaterialEnemyHighlight:Destroy()
		end
	end
end

function VisualRenderer:_scaled(p2: number)
	return RenderMath.scaled(p2, self.arenaScale)
end

function VisualRenderer:_worldFromArena(point: Vector2, p2: number?)
	return RenderMath.worldFromArena(self.arenaCFrame, self.arenaScale, point, p2)
end

function VisualRenderer:_arenaFromWorld(vector2: Vector3)
	return RenderMath.arenaFromWorld(self.arenaCFrame, self.arenaScale, vector2)
end

function VisualRenderer:_getBallMarkerHeight(p: string)
	local ballPart = self.ballParts[p]
	local attachment = ballPart and ballPart:FindFirstChild("朝向标记")

	if attachment and attachment:IsA("Attachment") then
		return -self.arenaCFrame:PointToObjectSpace(attachment.WorldPosition).Z / self.arenaScale
	end

	return 0
end

function VisualRenderer:_getArenaBallCFrame(vector2: Vector3)
	return RenderMath.getArenaBallCFrame(self.arenaCFrame, vector2)
end

function VisualRenderer:_resolveBallCFrame(p, p2, vector2: Vector3)
	local ballTemplateBundles = self.ballTemplateBundles

	if p.traits and p.traits.VerityForms then
		ballTemplateBundles = {}
		ballTemplateBundles[p.roleId] = self._verityVisual:getBundle(p)
	end

	return RenderMath.resolveBallCFrame(self.arenaCFrame, self.arenaScale, ballTemplateBundles, p, p2, vector2)
end

function VisualRenderer:_buildBallHealthLabel(adornee, flag: boolean?)
	local billboardGui = ReplicatedStorage2:WaitForChild("美术素材"):WaitForChild("身份标识模板"):WaitForChild("标识球"):WaitForChild(flag and "敌方血量" or "小球血量")
	assert(billboardGui:IsA("BillboardGui"), "血量模板必须是 BillboardGui")
	local clone = billboardGui:Clone()
	clone.Name = "HealthBillboard"
	clone.Adornee = adornee
	clone.Enabled = false
	clone.Parent = self.rootFolder
	local label = clone:FindFirstChild("血量字")
	assert(label and label:IsA("TextLabel"), "小球血量模板缺少 TextLabel：血量字")
	return label, clone
end

function VisualRenderer:_cloneTemplateModel(p, name: string)
	local clone, v2 = TemplateLibrary.clone(p)
	local v3 = p == self.redStringTemplateBundle and clone:FindFirstChild("区域样式")

	if v3 then
		v3:Destroy()
	end

	clone.Name = name
	local _getOwningSlotId = self:_getOwningSlotId(name)

	if _getOwningSlotId then
		clone:SetAttribute("BattleOwnerSlotId", _getOwningSlotId)
	end

	clone.Parent = self.rootFolder
	return clone, v2
end

function VisualRenderer:_setTemplateModelVisibility(p, flag: boolean)
	TemplateLibrary.setVisible(p, flag)
end

function VisualRenderer:_ensureBallModel(data)
	local id = data.id
	local bundle, v2 = self._verityVisual:getBundle(data)

	if self.ballModelRoleIds[id] == data.roleId and self.ballModelStages[id] == v2 and self.ballModels[id] and self.ballParts[id] then
		return self.ballModels[id], self.ballParts[id]
	end

	assert(bundle ~= nil, string.format("No template bundle registered for role '%s'", data.roleId))
	local ballModel = self.ballModels[id]

	if ballModel then
		ballModel:Destroy()
	end

	local ballHealthBillboard = self.ballHealthBillboards[id]

	if ballHealthBillboard then
		ballHealthBillboard:Destroy()
	end

	self:_releaseBallHitHighlight(id)
	local _cloneTemplateModel, v3 = self:_cloneTemplateModel(bundle, id)
	self.ballModels[id] = _cloneTemplateModel
	self.ballModelRoleIds[id] = data.roleId
	self.ballModelStages[id] = v2
	self.ballParts[id] = v3
	local forceHighlightAllEnemies = self.forceHighlightAllEnemies

	if forceHighlightAllEnemies then
		if self.localParticipantSlotId == nil then
			forceHighlightAllEnemies = false
		else
			forceHighlightAllEnemies = data.team ~= self.localParticipantSlotId
		end
	end

	if self._ctx.hideBallHealth then
		self.ballHealthLabels[id] = nil
		self.ballHealthBillboards[id] = nil
	else
		local _buildBallHealthLabel, v4 = self:_buildBallHealthLabel(v3, forceHighlightAllEnemies)
		self.ballHealthLabels[id] = _buildBallHealthLabel
		self.ballHealthBillboards[id] = v4
	end

	self.ballHitHighlights[id] = self:_buildBallHitHighlight(_cloneTemplateModel)
	self._identity:rebuildMarker(id, v3)
	return _cloneTemplateModel, v3
end

function VisualRenderer:_buildBallHitHighlight(p)
	local highlight = Instance.new("Highlight")
	highlight.Name = "HitFlashHighlight"
	highlight.Adornee = p
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = Color3.new(1, 1, 1)
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.Parent = p
	return highlight
end

function VisualRenderer:_releaseBallHitHighlight(p2: string)
	local ballHitFlashTween = self.ballHitFlashTweens[p2]

	if ballHitFlashTween then
		ballHitFlashTween:Cancel()
		self.ballHitFlashTweens[p2] = nil
	end

	local ballHitHighlight = self.ballHitHighlights[p2]

	if ballHitHighlight then
		ballHitHighlight:Destroy()
		self.ballHitHighlights[p2] = nil
	end
end

function VisualRenderer:_flashHitHighlight(p: string)
	local ballHitHighlight = self.ballHitHighlights[p]

	if not ballHitHighlight then
		return
	end

	local ballHitFlashTween = self.ballHitFlashTweens[p]

	if ballHitFlashTween then
		ballHitFlashTween:Cancel()
	end

	ballHitHighlight.FillTransparency = 0
	local tween = TweenService:Create(
		ballHitHighlight,
		TweenInfo.new(self.config.visual.hitHighlightDuration, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out),
		{
			FillTransparency = 1
		}
	)
	self.ballHitFlashTweens[p] = tween
	tween:Play()
end

function VisualRenderer:_buildBoard()
	if self._ctx.skipBoard then
		return
	end

	local boardModel = TemplateLibrary.buildBoardModel(self.config, self.boardTemplate, self.arenaCFrame)

	if not boardModel then
		return
	end

	boardModel.Parent = self.rootFolder
	self.boardModel = boardModel
end

function VisualRenderer:_buildScene()
	local parent = Workspace:FindFirstChild("BattleClientEffects")

	if not parent then
		parent = Instance.new("Folder")
		parent.Name = "BattleClientEffects"
		parent.Parent = Workspace
	end

	self.rootFolder = Instance.new("Folder")
	self.rootFolder.Name = string.format("Battle_%s", self.instanceId)
	self.rootFolder.Parent = parent
	self._ctx.rootFolder = self.rootFolder
	DuelAudioController.bindRoot(self.rootFolder, self._ctx.soundGroup)
	self:_buildBoard()
end

function VisualRenderer:_updateBallVisual(data, p)
	local _ensureBallModel, v2 = self:_ensureBallModel(data)

	if not (_ensureBallModel and v2) then
		return
	end

	local _worldFromArena = self:_worldFromArena(data.position)
	local v3 = data.radius / math.max(0.001, data.baseRadius or data.radius)

	if data.traits and data.traits.VerityForms then
		v3 *= self._verityVisual:getBundle(data).model:GetScale()
	end

	_ensureBallModel:ScaleTo(v3)
	_ensureBallModel:PivotTo(self:_resolveBallCFrame(data, p, _worldFromArena))
	self:_setTemplateModelVisibility(_ensureBallModel, true)
	local ballHealthBillboard = self.ballHealthBillboards[data.id]

	if ballHealthBillboard then
		ballHealthBillboard.Enabled = true
	end

	local ballHealthLabel = self.ballHealthLabels[data.id]

	if ballHealthLabel then
		ballHealthLabel.Text = tostring((math.max(0, (math.ceil(data.hp)))))
	end

	self._bladeVisual:update(data)
	self._speedEffectVisual:update(data)
	self._freezeEffectVisual:update(data)
	self._electromagneticParalysisVisual:update(data)
	self._strongParalysisVisual:update(data)
	self._slowOnHitVisual:update(data)
	self._hasteVisual:update(data)
	self._shieldVisual:update(data)
	self._expandingAuraVisual:update(data)
	self._frostTrailVisual:update(data)
	self._alchemistGasTrailVisual:update(data)
	self._poisonVisual:update(data)
	self._burnVisual:update(data)
	self._burstDriveVisual:update(data)
	self._noCollisionChargeVisual:update(data)
	self._gravityVisual:update(data)
	self._buffAuraVisual:update(data)
	self._chessPathVisual:update(data)
	self._wdcVisual:update(data)
	self._thomasVisual:update(data)
end

function VisualRenderer:_updateLaunchArrow(p, value: number?)
	if not self._ctx.showLaunchArrows or self.launchArrowCleared[p.id] then
		return
	end

	local v2 = self.launchArrowSpawnedAt[p.id]

	if v2 and typeof(value) == "number" and value - v2 >= 1 then
		self:_clearLaunchArrow(p.id)
		return
	end

	local ballPart = self.ballParts[p.id]
	local attachment = ballPart and ballPart:FindFirstChild("朝向标记")

	if not (attachment and attachment:IsA("Attachment")) then
		return
	end

	local unit = self.launchArrowDirections[p.id]

	if not unit then
		if typeof(p.direction) ~= "Vector2" or p.direction.Magnitude < 1e-6 then
			return
		end

		unit = p.direction.Unit
		self.launchArrowDirections[p.id] = unit
	end

	local clone = self.launchArrowModels[p.id]

	if not clone then
		clone = v:Clone()
		clone.Parent = self.rootFolder
		self.launchArrowModels[p.id] = clone
		self.launchArrowSpawnedAt[p.id] = typeof(value) ~= "number" and 0 or value
	end

	local part = clone:FindFirstChild("绑定箱")
	local attachment2 = part and part:FindFirstChild("朝向标记")

	if not (part and part:IsA("BasePart") and attachment2 and attachment2:IsA("Attachment")) then
		return
	end

	local vectorToWorldSpace = self.arenaCFrame:VectorToWorldSpace(createVector(1, 0, 0))
	local vectorToWorldSpace2 = self.arenaCFrame:VectorToWorldSpace(createVector(0, 1, 0))
	local v3 = vectorToWorldSpace * unit.X + vectorToWorldSpace2 * unit.Y

	if v3.Magnitude < 1e-6 then
		return
	end

	local worldPosition = attachment.WorldPosition
	clone:PivotTo(CFrame.lookAt(worldPosition, worldPosition + v3.Unit, self.arenaCFrame.LookVector) * attachment2.CFrame:Inverse())
end

function VisualRenderer:_clearLaunchArrow(value: string)
	if typeof(value) ~= "string" or self.launchArrowCleared[value] then
		return
	end

	self.launchArrowCleared[value] = true
	local launchArrowModel = self.launchArrowModels[value]

	if launchArrowModel then
		launchArrowModel:Destroy()
		self.launchArrowModels[value] = nil
	end
end

function VisualRenderer:_maybeClearLaunchArrow(data)
	if not self._ctx.showLaunchArrows then
		return
	end

	local v2 = data.type == "wall_hit" or data.type == "ball_hit" or data.type == "ball_contact" or data.type == "cactus_hit" or data.type == "trap_bounce"
	local v3

	if typeof(data.damage) == "number" then
		v3 = data.damage > 0
	else
		v3 = false
	end

	if v2 or v3 then
		self:_clearLaunchArrow(data.targetBallId or data.ballId)
	end
end

local function easedNlerpDirection(point: Vector2, point2: Vector2, p: number)
	local lerped = point:Lerp(point2, 1 - (1 - p) ^ 3)

	if lerped.Magnitude > 1e-6 then
		return lerped.Unit
	end

	return point2
end

function VisualRenderer:renderBalls(p)
	self._latestBallStates = p.balls
	self._verityVisual:update(p.balls)
	local v2 = {}

	for k, ball in p.balls do
		v2[k] = true
		self.currentRoleIds[k] = ball.roleId
		self.ballTeams[k] = ball.team
		self.currentRoleIds[ball.team] = ball.roleId
		local dogCannon = ball.traits and ball.traits.DogCannon
		local v3

		if dogCannon or RenderMath.getFacingMode(ball.skill and ball.skill.trigger) == "Target" then
			v3 = RenderMath.findNearestEnemy(p.balls, ball)
		end

		if dogCannon then
			if self._dogCannonLastPhase[k] == "Beam" and dogCannon.phase ~= "Beam" and dogCannon.aimDirection then
				self._dogCannonFacingEase[k] = {
					fromDirection = dogCannon.aimDirection,
					startTime = os.clock()
				}
			end

			self._dogCannonLastPhase[k] = dogCannon.phase

			if dogCannon.phase == "Beam" and dogCannon.aimDirection then
				v3 = {
					position = ball.position + dogCannon.aimDirection
				}
				self._dogCannonFacingEase[k] = nil
			else
				local v4 = self._dogCannonFacingEase[k]

				if v4 then
					local v5 = math.clamp((os.clock() - v4.startTime) / 0.8, 0, 1)
					local unit = nil

					if v3 and v3.position then
						local v6 = v3.position - ball.position

						if v6.Magnitude > 1e-6 then
							unit = v6.Unit
						end
					end

					local unit2 = unit or v4.fromDirection
					local lerped = v4.fromDirection:Lerp(unit2, 1 - (1 - v5) ^ 3)

					if lerped.Magnitude > 1e-6 then
						unit2 = lerped.Unit
					end

					v3 = {
						position = ball.position + unit2
					}

					if v5 >= 1 then
						self._dogCannonFacingEase[k] = nil
					end
				end
			end
		end

		self:_updateBallVisual(ball, v3)
		self:_updateLaunchArrow(ball, p.elapsed)

		if ball.spiderWebs then
			self._spiderWebVisual:update(ball)
		end

		if ball.vampireWebs then
			self._vampireWebVisual:update(ball)
		end

		if ball.laserSegments then
			self._laserVisual:updatePreview(ball)
			self._laserVisual:updateVisuals(ball)
		end

		if ball.poisonSpikes then
			if ball.skill.trigger == "BigSpikeWall" then
				self._bigSpikeVisual:update(ball)
			else
				self._poisonSpikeVisual:update(ball)
			end
		end

		if ball.zoneRegions then
			self._zoneVisual:update(ball)
		end

		if ball.traits.GlassShards then
			self._glassShardsVisual:update(ball, p.elapsed)
		end

		if ball.traits.MachineGun then
			self._machineGunVisual:update(ball)
		end

		if ball.traits.AppleThrow then
			self._appleVisual:update(ball)
		end

		if ball.traits.AcidSpit then
			self._acidSpitVisual:update(ball)
		end

		if ball.traits.CannonTurret then
			self._cannonTurretVisual:update(ball)
		end

		if ball.traits.LaserTurretV3 then
			self._laserTurretV3Visual:update(ball)
		end

		if ball.traits.ElectroKingGrid then
			self._electroKingVisual:update(ball)
		end

		if ball.traits.TrainTrack then
			self._trainTrackVisual:update(ball)
		end

		if ball.traits.DogCannon then
			self._dogCannonVisual:update(ball)
		end

		if ball.traits.VolcanoEruption then
			self._volcanoEruptionVisual:update(ball)
		end

		if ball.traits.ChargedBow then
			self._chargedBowVisual:update(ball)
		end

		if ball.traits.Harpoon then
			self._harpoonVisual:update(ball)
		end

		if ball.traits.HiveSwarm then
			self._hiveSwarmVisual:update(ball)
		end

		if ball.traits.RobuxBarrage then
			self._robuxVisual:update(ball)
		end

		if ball.traits.Shuriken then
			self._shurikenVisual:update(ball)
		end

		if ball.traits.MedicBarrage then
			self._medicBarrageVisual:update(ball)
		end

		if ball.traits.MathEquation then
			self._mathEquationVisual:update(ball)
		end

		if ball.traits.IceConeTrail then
			self._iceConeTrailVisual:update(ball)
		end

		if ball.traits.TimeBomb then
			self._timeBombVisual:update(ball)
		end

		if ball.traits.PotionThrow then
			self._potionThrowVisual:update(ball)
		end

		if ball.traits.CactusThrow then
			self._cactusThrowVisual:update(ball)
		end

		if ball.traits.TrapRelease then
			self._trapReleaseVisual:update(ball)
		end

		if ball.traits.SpearThrust then
			self._spearThrustVisual:update(ball)
		end

		if ball.traits.OnePunch then
			self._onePunchVisual:update(ball)
		end

		if ball.traits.DiceBarrage then
			self._diceBarrageVisual:update(ball)
		end

		if ball.traits.ThiefKnives then
			self._thiefKnivesVisual:update(ball)
		end

		if ball.traits.OrbitSatellite then
			self._orbitSatelliteVisual:update(ball)
		end

		if ball.traits.SnakeTail and self._snakeTailVisual then
			self._snakeTailVisual:update(ball)
		end

		if ball.traits.HookGrapple then
			if not self._hookHandles[k] then
				self._hookHandles[k] = EffectPlayer.playModule("钩爪特效", {
					rootFolder = self.rootFolder,
					effectAssetRoot = self.effectAssetRoot,
					hookTemplateName = self.config.visual.hookTemplateName,
					arenaCFrame = self.arenaCFrame,
					arenaScale = self.arenaScale,
					ballId = k,
					ownerSlotId = self:_getOwningSlotId(string.format("%s_HookGrapple", k)),
					getBallState = function(p2)
						return self._latestBallStates[p2]
					end
				})
			end
		else
			self:_releaseHookEffect(k)
		end

		self._voltaicShockVisual:update(ball)
	end

	self:_refreshSameMaterialEnemyHighlights()

	for k in self.ballModels do
		if not v2[k] then
			self:_forgetBall(k, true)
		end
	end

	self._thomasVisual:cleanupInactive(v2)
end

function VisualRenderer:_forgetBall(p: string, flag: boolean)
	local ballModel = self.ballModels[p]

	if flag and ballModel then
		local ballTeam = self.ballTeams[p]

		if ballTeam then
			self.lastVanishedBallPositions[ballTeam] = ballModel:GetPivot().Position
		end

		ballModel:Destroy()
	end

	local ballModels = self.ballModels
	local ballParts = self.ballParts
	local ballModelRoleIds = self.ballModelRoleIds
	ballModels[p] = nil
	ballParts[p] = nil
	ballModelRoleIds[p] = nil
	self.ballTeams[p] = nil
	self.ballModelStages[p] = nil
	self.currentRoleIds[p] = nil
	local ballHealthBillboard = self.ballHealthBillboards[p]

	if ballHealthBillboard then
		ballHealthBillboard:Destroy()
	end

	local ballHealthLabels = self.ballHealthLabels
	local ballHealthBillboards = self.ballHealthBillboards
	ballHealthLabels[p] = nil
	ballHealthBillboards[p] = nil
	self:_releaseBallHitHighlight(p)
	self._speedEffectVisual:cleanupBall(p)
	self._freezeEffectVisual:cleanupBall(p)
	self._electromagneticParalysisVisual:cleanupBall(p)
	self._strongParalysisVisual:cleanupBall(p)
	self._slowOnHitVisual:cleanupBall(p)
	self._hasteVisual:cleanupBall(p)
	self._shieldVisual:cleanupBall(p)
	self._expandingAuraVisual:cleanupBall(p)
	self._frostTrailVisual:cleanupBall(p)
	self._alchemistGasTrailVisual:cleanupBall(p)
	self._poisonVisual:cleanupBall(p)
	self._burnVisual:cleanupBall(p)
	self._burstDriveVisual:cleanupBall(p)
	self._noCollisionChargeVisual:cleanupBall(p)
	self._gravityVisual:cleanupBall(p)
	self._buffAuraVisual:cleanupBall(p)
	self._chessPathVisual:cleanupBall(p)
	self._wdcVisual:cleanupBall(p)
	self._machineGunVisual:cleanupBall(p)
	self._appleVisual:cleanupBall(p)
	self._acidSpitVisual:cleanupBall(p)
	self._cannonTurretVisual:cleanupBall(p)
	self._laserTurretV3Visual:cleanupBall(p)
	self._electroKingVisual:cleanupBall(p)
	self._trainTrackVisual:cleanupBall(p)
	self._dogCannonVisual:cleanupBall(p)
	local _dogCannonLastPhase = self._dogCannonLastPhase
	local _dogCannonFacingEase = self._dogCannonFacingEase
	_dogCannonLastPhase[p] = nil
	_dogCannonFacingEase[p] = nil
	self._volcanoEruptionVisual:cleanupBall(p)
	self._chargedBowVisual:cleanupBall(p)
	self._harpoonVisual:cleanupBall(p)
	self._hiveSwarmVisual:cleanupBall(p)
	self._robuxVisual:cleanupBall(p)
	self._shurikenVisual:cleanupBall(p)
	self._medicBarrageVisual:cleanupBall(p)
	self._mathEquationVisual:cleanupBall(p)
	self._iceConeTrailVisual:cleanupBall(p)
	self._timeBombVisual:cleanupBall(p)
	self._potionThrowVisual:cleanupBall(p)
	self._cactusThrowVisual:cleanupBall(p)
	self._trapReleaseVisual:cleanupBall(p)
	self._spearThrustVisual:cleanupBall(p)
	self._onePunchVisual:cleanupBall(p)
	self._fibonacciVisual:cleanupBall(p)
	self._diceBarrageVisual:cleanupBall(p)
	self._thiefKnivesVisual:cleanupBall(p)
	self._orbitSatelliteVisual:cleanupBall(p)

	if self._snakeTailVisual then
		self._snakeTailVisual:cleanupBall(p)
	end

	self:_releaseHookEffect(p)
	self._voltaicShockVisual:cleanupBall(p)
	self._glassShardsVisual:cleanupBall(p)
	self._laserVisual:cleanupBall(p)
	self._bladeVisual:cleanupBall(p)
	self._poisonSpikeVisual:cleanupBall(p)
	self._bigSpikeVisual:cleanupBall(p)
	self._spiderWebVisual:cleanupBall(p)
	self._vampireWebVisual:cleanupBall(p)
	self._zoneVisual:cleanupBall(p)
	self._thomasVisual:cleanupBall(p)
	local launchArrowModel = self.launchArrowModels[p]

	if launchArrowModel then
		launchArrowModel:Destroy()
	end

	local launchArrowModels = self.launchArrowModels
	local launchArrowDirections = self.launchArrowDirections
	local launchArrowCleared = self.launchArrowCleared
	launchArrowModels[p] = nil
	launchArrowDirections[p] = nil
	launchArrowCleared[p] = nil
	self.launchArrowSpawnedAt[p] = nil
	return ballModel
end

function VisualRenderer:_releaseHookEffect(p2: string)
	local _hookHandle = self._hookHandles[p2]

	if _hookHandle then
		_hookHandle.destroy()
		self._hookHandles[p2] = nil
	end
end

function VisualRenderer:pluckFirstBallForTeam(p: string)
	for k, ballTeam in self.ballTeams do
		if ballTeam == p then
			return self:_forgetBall(k, false)
		end
	end

	return nil
end

function VisualRenderer:pluckAllBallsForOwner(p: string)
	local result = {}

	for k in table.clone(self.ballTeams) do
		if (self.ballOwnerIds[k] or k) ~= p then
			continue
		end

		local _forgetBall = self:_forgetBall(k, false)

		if _forgetBall then
			table.insert(result, _forgetBall)
		end
	end

	return result
end

function VisualRenderer:pluckBall(p: string)
	if self.ballTeams[p] == nil then
		return nil
	end

	return self:_forgetBall(p, false)
end

function VisualRenderer:pluckAllBallsForTeam(p: string)
	local result = {}

	for k, v2 in table.clone(self.ballTeams) do
		if v2 ~= p then
			continue
		end

		local _forgetBall = self:_forgetBall(k, false)

		if _forgetBall then
			table.insert(result, _forgetBall)
		end
	end

	return result
end

function VisualRenderer.getLastVanishedBallPosition(p, p2: string)
	return p.lastVanishedBallPositions[p2]
end

function VisualRenderer:destroyTeamBalls(p: string)
	for k, v2 in table.clone(self.ballTeams) do
		if v2 == p then
			self:_forgetBall(k, true)
		end
	end
end

function VisualRenderer:playEvents(items)
	for _, item in items do
		if item.type == "cell_split_child" and item.ballId and item.sourceBallId then
			self.ballOwnerIds[item.ballId] = self.ballOwnerIds[item.sourceBallId] or item.sourceBallId
		end
	end

	local v2 = false

	for _, item in items do
		self:_maybeClearLaunchArrow(item)

		if item.type == "verity_start" or item.type == "verity_transform" then
			self._verityVisual:playEvent(item)
		elseif item.type == "wall_hit" then
			local position = item.position

			if position then
				EffectPlayer.playModule("撞墙特效", {
					worldPosition = self:_worldFromArena(position, 1.2),
					effectAssetRoot = self.effectAssetRoot,
					rootFolder = self.rootFolder,
					arenaRotation = self.effectArenaRotation
				})
			end
		elseif item.type == "cactus_hit" then
			if (item.damage or 0) > 0 then
				self._eventEffects:spawnDamageNumber(item)
			end

			local position = item.position

			if position then
				EffectPlayer.playModule("撞墙特效", {
					worldPosition = self:_worldFromArena(position, 1.2),
					effectAssetRoot = self.effectAssetRoot,
					rootFolder = self.rootFolder,
					arenaRotation = self.effectArenaRotation
				})
			end
		elseif item.type == "trap_bounce" then
			if (item.damage or 0) > 0 then
				self._eventEffects:spawnDamageNumber(item)
			end

			local position = item.position

			if position then
				EffectPlayer.playModule("撞墙特效", {
					worldPosition = self:_worldFromArena(position, 1.2),
					effectAssetRoot = self.effectAssetRoot,
					rootFolder = self.rootFolder,
					arenaRotation = self.effectArenaRotation
				})
			end
		elseif item.type == "ball_hit" then
			self._eventEffects:spawnDamageNumber(item)

			if not v2 and item.startPosition and item.endPosition then
				local position = item.position or (item.startPosition + item.endPosition) * 0.5
				local v3 = math.max(1e-6, self.config.visual.cameraShake.referenceSpeed)
				local cameraShakeStrength

				if type(item.speedSum) == "number" then
					cameraShakeStrength = math.clamp(item.speedSum / v3, 0, 1)
				end

				EffectPlayer.playModule("碰撞打击特效", {
					worldPosition = self:_worldFromArena(position, 2.4),
					effectAssetRoot = self.effectAssetRoot,
					rootFolder = self.rootFolder,
					arenaRotation = self.effectArenaRotation,
					cameraShakeStrength = cameraShakeStrength,
					onCameraImpact = self.onCameraImpact
				})
				v2 = true
			end
		elseif item.type ~= "glass_shard_created" then
			if item.type == "glass_shard_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self._bladeVisual:playHit(item)
			elseif item.type == "machine_gun_fire" then
				self._audio:playCue(
					"bladeGrowth",
					self:_worldFromArena(item.position or Vector2.zero, self.config.visual.ballHeight)
				)
			elseif item.type == "machine_gun_bullet_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self._bladeVisual:playHit(item)
			elseif item.type == "apple_landed" then
				self._eventEffects:playOneShotModelEffect("苹果落地特效", item.position)
			elseif item.type == "acid_spit_release" then
				self._eventEffects:playOneShotModelEffect("酸液释放特效", item.position, nil, item.ballId)
			elseif item.type == "acid_droplet_landed" then
				self._eventEffects:playOneShotModelEffect("酸液落地特效", item.position)
			elseif item.type == "acid_poison_tick" then
				self._eventEffects:spawnDamageNumber(item)
				local model = self._poisonVisual:getModel(item.targetBallId or item.ballId)

				if model then
					EffectPlayer.playEmbeddedSounds(model)
				end
			elseif item.type == "apple_eaten" then
				if item.isDamage then
					self._eventEffects:spawnDamageNumber(item)
					self._eventEffects:playOneShotModelEffect("苹果扣血特效", item.position)
				else
					self._eventEffects:spawnHealNumber({
						heal = item.heal,
						sourceBallId = item.ballId
					})
					self._eventEffects:playOneShotModelEffect("苹果回血特效", item.position)
				end
			elseif item.type == "cannon_turret_fire" then
				self._audio:playCue(
					"bladeGrowth",
					self:_worldFromArena(item.position or Vector2.zero, self.config.visual.ballHeight)
				)
			elseif item.type == "cannon_bullet_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self._bladeVisual:playHit(item)
			elseif item.type == "bow_draw_started" then
				self._chargedBowVisual:playDrawStarted(item.ballId)
			elseif item.type == "bow_arrow_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self._bladeVisual:playHit(item)
			elseif item.type == "harpoon_launch" then
				self._eventEffects:playOneShotModelEffect("鱼叉发射", item.position, nil, item.ballId)
			elseif item.type == "harpoon_impact" then
				self._eventEffects:playOneShotModelEffect("鱼叉命中特效", item.position)
			elseif item.type == "harpoon_capture_tick" then
				self._eventEffects:spawnDamageNumber(item)
				self._eventEffects:playOneShotModelEffect("通用撞墙效果", item.position, nil, item.ballId)
			elseif item.type == "harpoon_expired" then
				self._harpoonVisual:playExpired(item.ballId)
			elseif item.type == "hive_bee_launch" then
				self._eventEffects:playOneShotModelEffect("蜂巢释放特效", item.position, nil, item.ballId)
			elseif item.type == "hive_bee_hit" then
				self._eventEffects:playOneShotModelEffect("蜂巢命中特效", item.position)
			elseif item.type == "hive_venom_tick" then
				self._eventEffects:spawnDamageNumber(item)
				self._eventEffects:playOneShotModelEffect("蜂巢中毒特效", item.position, nil, item.ballId)
			elseif item.type == "robux_launch" then
				self._eventEffects:playOneShotModelEffect(
					"Robux发射特效",
					item.position,
					nil,
					item.ballId,
					item.soundPlaybackSpeed
				)
			elseif item.type == "robux_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self._eventEffects:playOneShotModelEffect("Robux命中特效", item.position)
			elseif item.type == "robux_wall_hit" or item.type == "robux_expired" then
				self._eventEffects:playOneShotModelEffect("Robux撞墙特效", item.position)
			elseif item.type == "shuriken_launch" then
				self._eventEffects:playOneShotModelEffect("手里剑发射特效", item.position, nil, item.ballId)
			elseif item.type == "shuriken_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self._eventEffects:playOneShotModelEffect("手里剑命中特效", item.position)
			elseif item.type == "orbit_satellite_spawn" then
				self._eventEffects:playOneShotModelEffect("轨道卫星生成特效", item.position, nil, item.ballId)
			elseif item.type == "orbit_satellite_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self._eventEffects:playOneShotModelEffect("轨道卫星撞击特效", item.position)
			elseif item.type == "shuriken_wall_bounce" then
				self._eventEffects:playOneShotModelEffect("手里剑撞墙特效", item.position)
			elseif item.type == "shuriken_expired" then
				self._eventEffects:playOneShotModelEffect("手里剑撞墙特效", item.position)
			elseif item.type == "medic_launch" then
				self._eventEffects:playOneShotModelEffect("医疗弹幕发射特效", item.position, nil, item.ballId)
			elseif item.type == "medic_bullet_hit" then
				if item.isDamage then
					self._eventEffects:spawnDamageNumber(item)
					self._eventEffects:playOneShotModelEffect("医疗弹幕扣血特效", item.position)
				else
					self._eventEffects:spawnHealNumber({
						heal = item.heal,
						sourceBallId = item.ballId
					})
					self._eventEffects:playOneShotModelEffect("医疗弹幕回血特效", item.position)
				end
			elseif item.type == "medic_bullet_wall_bounce" or item.type == "medic_bullet_expired" then
				self._eventEffects:playOneShotModelEffect("医疗弹幕撞墙特效", item.position)
			elseif item.type == "math_bullet_launch" then
				self._eventEffects:playOneShotModelEffect("数学发射特效", item.position, nil, item.ballId)
			elseif item.type == "math_bullet_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self._eventEffects:playOneShotModelEffect("数学命中特效", item.position)
			elseif item.type == "math_bullet_wall" or item.type == "math_bullet_expired" then
				self._eventEffects:playOneShotModelEffect("数学撞墙特效", item.position)
			elseif item.type == "ice_cone_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self._bladeVisual:playHit(item)
			elseif item.type == "time_bomb_explode" then
				self._eventEffects:playOneShotModelEffect(self.config.visual.bombExplosionTemplateName, item.position)
			elseif item.type == "time_bomb_explode_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self._bladeVisual:playHit(item)
			elseif item.type == "dice_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self._bladeVisual:playHit(item)
			elseif item.type == "snake_tail_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self._bladeVisual:playHit(item)
			elseif item.type == "snake_tail_grown" then
				local _worldFromArena = self:_worldFromArena(
					item.position or Vector2.zero,
					self.config.visual.ballHeight
				)
				self._audio:playCue("snakeTailGrowth", _worldFromArena)
			elseif item.type == "thief_knife_charge_gain" then
				self._eventEffects:playOneShotModelEffect("盗贼蓄力特效", item.position, nil, item.ballId)
			elseif item.type == "thief_knife_charge_complete" then
				self._eventEffects:playOneShotModelEffect("盗贼蓄力完毕特效", item.position, nil, item.ballId)
			elseif item.type == "thief_knife_throw" then
				self._audio:playCue(
					"bladeGrowth",
					self:_worldFromArena(item.position or Vector2.zero, self.config.visual.ballHeight)
				)
			elseif item.type == "thief_knife_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self._bladeVisual:playHit(item)
			elseif item.type == "thomas_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self._bladeVisual:playHit(item)
			elseif item.type == "thomas_upgraded" then
				self._eventEffects:spawnThomasUpgradeFloat(item)
				self._eventEffects:playOneShotModelEffect("升级特效", item.position)
			elseif item.type == "blade_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self._bladeVisual:playHit(item)
			elseif item.type == "wdc_active_start" then
				self._eventEffects:playOneShotModelEffect("WDC释放特效", item.position, nil, item.ballId)
			elseif item.type == "wdc_cell_hit" then
				self._wdcVisual:playCellHit(item)
			elseif item.type == "spider_web_created" then
				self._spiderWebVisual:registerEvent(item)
			elseif item.type == "spider_web_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self._spiderWebVisual:playHit(item)
			elseif item.type == "vampire_web_created" then
				self._vampireWebVisual:registerEvent(item)
			elseif item.type == "vampire_web_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self._vampireWebVisual:playHit(item)
				self._eventEffects:playOneShotModelEffect("通用吸血特效", item.position, nil, item.targetBallId)

				if item.heal then
					self._eventEffects:spawnHealNumber({
						heal = item.heal,
						sourceBallId = item.sourceBallId
					})
					self._eventEffects:playOneShotModelEffect("通用回血特效", nil, nil, item.sourceBallId)
				end
			elseif item.type == "laser_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self._spiderWebVisual:playHit(item)
			elseif item.type == "electro_shock_start" then
				self._electroKingVisual:playShockStart(item.ballId)
			elseif item.type == "electro_shock_tick" then
				self._eventEffects:spawnDamageNumber(item)
			elseif item.type == "laser_turret_v3_fire" then
				self._laserTurretV3Visual:playFire(item.ballId, item.turretId)
			elseif item.type == "laser_turret_v3_hit" then
				self._eventEffects:spawnDamageNumber(item)
			elseif item.type == "dog_cannon_charge_pulse" then
				self._dogCannonVisual:playChargePulse(item.ballId)
			elseif item.type == "dog_cannon_beam_start" then
				self._dogCannonVisual:playBeamStart(item.ballId)
			elseif item.type == "dog_cannon_beam_tick" then
				self._eventEffects:spawnDamageNumber(item)
				self._eventEffects:playOneShotModelEffect("通用碰球效果", item.position)
			elseif item.type == "dog_cannon_beam_end" then
				self._dogCannonVisual:playBeamEnd(item.ballId)
			elseif item.type == "aura_tick" then
				self._eventEffects:spawnDamageNumber(item)
			elseif item.type == "frost_tick" then
				self._eventEffects:spawnDamageNumber(item)
			elseif item.type == "hook_wall_hit" then
				self._eventEffects:spawnDamageNumber(item)
				local targetBallId = item.targetBallId or item.ballId
				local v3 = targetBallId and self.ballParts[targetBallId]
				local v4 = v3 and self:_arenaFromWorld(v3.Position) or item.position

				if v4 then
					EffectPlayer.playModule("碰撞打击特效", {
						worldPosition = self:_worldFromArena(v4, self.config.visual.ballHeight),
						effectAssetRoot = self.effectAssetRoot,
						rootFolder = self.rootFolder,
						arenaRotation = self.effectArenaRotation,
						cameraShakeStrength = self.config.visual.cameraShake.hookWallHitStrength or 0,
						onCameraImpact = self.onCameraImpact
					})
				end
			elseif item.type == "poison_spike_created" then
				self._eventEffects:playPoisonSpikeCreated(item)
			elseif item.type == "poison_spike_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self._eventEffects:playPoisonSpikeHit(item)
			elseif item.type == "poison_tick" then
				self._eventEffects:spawnDamageNumber(item)
				local model = self._poisonVisual:getModel(item.targetBallId or item.ballId)

				if model then
					EffectPlayer.playEmbeddedSounds(model)
				end
			elseif item.type == "volcano_burn_tick" then
				self._eventEffects:spawnDamageNumber(item)
				local model = self._burnVisual:getModel(item.targetBallId or item.ballId)

				if model then
					EffectPlayer.playEmbeddedSounds(model)
				end
			elseif item.type == "zone_tick" then
				self._eventEffects:spawnDamageNumber(item)
				self._zoneVisual:playZoneTick(item)
			elseif item.type == "potion_red_tick" or item.type == "potion_blue_tick" then
				self._eventEffects:spawnDamageNumber(item)
				local v3 = item.type == "potion_red_tick" and "potionRedTick" or "potionBlueTick"
				local targetBallId = item.targetBallId or item.ballId
				local v4 = targetBallId and self.ballParts[targetBallId]
				local v5 = v4 and self:_arenaFromWorld(v4.Position) or item.position

				if v5 then
					self._audio:playCue(v3, self:_worldFromArena(v5, self.config.visual.ballHeight))
				end
			elseif item.type == "voltaic_charge_ready" then
				self._eventEffects:playOneShotModelEffect("十万伏特充能特效", item.position, nil, item.ballId)
			elseif item.type == "voltaic_shock_start" or item.type == "voltaic_shock_tick" then
				self._eventEffects:spawnDamageNumber(item)
				self._voltaicShockVisual:playShock(item)

				if item.type == "voltaic_shock_tick" then
					local highChargeModel = self._voltaicShockVisual:getHighChargeModel(item.targetBallId or item.ballId)

					if highChargeModel then
						EffectPlayer.playEmbeddedSounds(highChargeModel)
					end
				end
			elseif item.type == "self_repair_tick" then
				self._eventEffects:spawnHealNumber({
					heal = item.heal,
					sourceBallId = item.ballId
				})
			elseif item.type == "vampire_tick" then
				self._eventEffects:spawnDamageNumber(item)
				self._eventEffects:spawnHealNumber(item)
				local v3 = item.sourceBallId and self.ballParts[item.sourceBallId]
				local v4 = item.targetBallId and self.ballParts[item.targetBallId]
				local worldPosition = nil

				if v3 and v4 then
					worldPosition = (v3.Position + v4.Position) * 0.5
				elseif item.position then
					worldPosition = self:_worldFromArena(item.position, 2.2)
				end

				if worldPosition then
					EffectPlayer.playModule("吸血特效", {
						worldPosition = worldPosition,
						effectAssetRoot = self.effectAssetRoot,
						rootFolder = self.rootFolder,
						arenaRotation = self.effectArenaRotation
					})
				end
			elseif item.type == "train_spawn" then
				self._trainTrackVisual:playSpawnAudio(item.ballId)
			elseif item.type == "train_despawn" then
				self._trainTrackVisual:stopTrainAudio(item.ballId)
			elseif item.type == "train_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self.onHitFlash(item.targetBallId or item.ballId)
			elseif item.type == "chess_path_hit" then
				self._eventEffects:spawnDamageNumber(item)
				self._bladeVisual:playHit(item)
			elseif item.type == "spear_thrust_hit" then
				if (item.damage or 0) > 0 then
					self._eventEffects:spawnDamageNumber(item)
				end

				self.onHitFlash(item.targetBallId or item.ballId)
				self._eventEffects:playOneShotModelEffect(self.config.visual.spearHitEffectTemplateName, item.position)
			elseif item.type == "one_punch_hit" then
				local visual = self.config.visual
				local tier = item.tier or 1
				self._eventEffects:playOneShotModelEffect(visual.onePunchHitEffectTemplateNames[tier], item.position)

				if tier == 1 then
					self._eventEffects:spawnDamageNumberGravity(item.position, "MISS", visual.damageFloat)
				else
					if (item.damage or 0) > 0 then
						self._eventEffects:spawnDamageNumber(item)
					end

					self._eventEffects:playOneShotModelEffect(
						visual.onePunchVictimEffectTemplateName,
						item.position,
						nil,
						item.targetBallId
					)
					local onePunchTier3Shake

					if tier == 3 then
						onePunchTier3Shake = visual.onePunchTier3Shake
					else
						onePunchTier3Shake = visual.onePunchTier2Shake
					end

					self.onCameraImpact(onePunchTier3Shake.strength, {
						amplitudeScale = onePunchTier3Shake.amplitudeScale,
						duration = onePunchTier3Shake.duration
					})
				end
			elseif item.type ~= "one_punch_windup" and item.type ~= "one_punch_dash_start" and item.type ~= "one_punch_dash_end" then
				if item.type == "fibonacci_impact" then
					self._fibonacciVisual:playImpact(item)
				elseif item.type == "blade_growth" then
					self._bladeVisual:playGrowth(item)
				elseif item.type == "electromagnetic_paralysis_triggered" then
					local paralyzedModel = self._electromagneticParalysisVisual:getParalyzedModel(item.targetBallId or item.ballId)

					if paralyzedModel then
						EffectPlayer.playEmbeddedSounds(paralyzedModel)
					end
				elseif item.type == "strong_paralysis_triggered" then
					local model = self._strongParalysisVisual:getModel(item.targetBallId or item.ballId)

					if model then
						EffectPlayer.playEmbeddedSounds(model)
					end
				elseif item.type == "charge_gain" then
					local assetName = self.config.traits.NoCollisionCharge.assetName

					if assetName and assetName ~= "" then
						self._eventEffects:playOneShotModelEffect(assetName, item.position, nil, item.ballId)
					else
						self._eventEffects:playChargeGain(item)
					end
				elseif item.type == "charge_release" then
					self._eventEffects:playChargeRelease(item)
				elseif item.type == "battle_end" then
					self._audio:playCue("battleEnd")
				end
			end
		end
	end
end

function VisualRenderer:reset()
	self._verityVisual:reset()
	self.currentRoleIds = {}
	table.clear(self.lastVanishedBallPositions)
	table.clear(self.ballOwnerIds)

	for _, launchArrowModel in self.launchArrowModels do
		launchArrowModel:Destroy()
	end

	table.clear(self.launchArrowModels)
	table.clear(self.launchArrowDirections)
	table.clear(self.launchArrowCleared)
	table.clear(self.launchArrowSpawnedAt)
	self:_refreshSameMaterialEnemyHighlights()
	self._spiderWebVisual:reset()
	self._vampireWebVisual:reset()
	self._glassShardsVisual:reset()
	self._zoneVisual:reset()
	self._poisonSpikeVisual:reset()
	self._bigSpikeVisual:reset()

	for k, ballHitHighlight in self.ballHitHighlights do
		local ballHitFlashTween = self.ballHitFlashTweens[k]

		if ballHitFlashTween then
			ballHitFlashTween:Cancel()
			self.ballHitFlashTweens[k] = nil
		end

		ballHitHighlight.FillTransparency = 1
	end

	for k, ballPart in self.ballParts do
		ballPart.Transparency = 1
		local ballHealthBillboard = self.ballHealthBillboards[k]

		if ballHealthBillboard then
			ballHealthBillboard.Enabled = false
		end
	end

	self._bladeVisual:reset()
	self._speedEffectVisual:reset()
	self._freezeEffectVisual:reset()
	self._electromagneticParalysisVisual:reset()
	self._strongParalysisVisual:reset()
	self._slowOnHitVisual:reset()
	self._hasteVisual:reset()
	self._shieldVisual:reset()
	self._expandingAuraVisual:reset()
	self._frostTrailVisual:reset()
	self._alchemistGasTrailVisual:reset()
	self._poisonVisual:reset()
	self._burnVisual:reset()
	self._burstDriveVisual:reset()
	self._noCollisionChargeVisual:reset()
	self._gravityVisual:reset()
	self._buffAuraVisual:reset()
	self._chessPathVisual:reset()
	self._wdcVisual:reset()
	self._laserVisual:reset()

	for _, _hookHandle in self._hookHandles do
		_hookHandle.destroy()
	end

	table.clear(self._hookHandles)
	self._voltaicShockVisual:reset()
	self._iceConeTrailVisual:reset()
	self._timeBombVisual:reset()
	self._potionThrowVisual:reset()
	self._cactusThrowVisual:reset()
	self._trapReleaseVisual:reset()
	self._spearThrustVisual:reset()
	self._onePunchVisual:reset()
	self._fibonacciVisual:reset()
	self._diceBarrageVisual:reset()
	self._thiefKnivesVisual:reset()
	self._orbitSatelliteVisual:reset()

	if self._snakeTailVisual then
		self._snakeTailVisual:reset()
	end

	self._appleVisual:reset()
	self._acidSpitVisual:reset()
	self._cannonTurretVisual:reset()
	self._laserTurretV3Visual:reset()
	self._electroKingVisual:reset()
	self._trainTrackVisual:reset()
	self._dogCannonVisual:reset()
	self._dogCannonLastPhase = {}
	self._dogCannonFacingEase = {}
	self._volcanoEruptionVisual:reset()
	self._chargedBowVisual:reset()
	self._harpoonVisual:reset()
	self._hiveSwarmVisual:reset()
	self._robuxVisual:reset()
	self._shurikenVisual:reset()
	self._medicBarrageVisual:reset()
	self._mathEquationVisual:reset()
end

function VisualRenderer:destroy()
	self._robuxVisual:reset()
	self._verityVisual:reset()

	for _, _hookHandle in self._hookHandles do
		_hookHandle.destroy()
	end

	table.clear(self._hookHandles)

	if self.rootFolder then
		self.rootFolder:Destroy()
		self.rootFolder = nil
	end

	self._ctx.rootFolder = nil
	self._zoneVisual:destroy()
	self._chessPathVisual:destroy()
	self._wdcVisual:destroy()
	self._bladeVisual:destroy()
end

return VisualRenderer