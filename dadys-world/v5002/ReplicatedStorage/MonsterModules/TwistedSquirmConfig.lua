local createVector = vector.create
local TwistedSquirmConfig = {
	STATS = {
		Name = "Squirm",
		Rarity = "Rare",
		Icon = "rbxassetid://108443751963686",
		Render = "rbxassetid://133102229631608",
		VisionRadius = 0,
		InstantRadius = 0,
		WalkSpeed = 0,
		RunSpeed = 0,
		HearingRadius = 0,
		Damage = 1,
		KillRadius = 4,
		ResearchRadius = 30
	},
	ROPE = {
		LENGTH_MIN = 1,
		LENGTH_MAX = 40,
		LENGTH_DEFAULT = 3,
		LENGTH_RECOIL = 8,
		SLACK_BUFFER = 0.5,
		RESTITUTION = 0.05,
		THICKNESS = 1,
		VISIBLE = true,
		ATTACHMENT_OFFSET = createVector(-0.5, -0.5, 0),
		COLOR = Color3.fromRGB(0, 0, 0)
	},
	MOVEMENT = {
		DESCEND_SPEED_INITIAL = 3,
		DESCEND_SPEED_MAX = 12,
		DESCEND_ACCEL_TIME = 2,
		STRIKE_SPEED = 45,
		RETRACT_SPEED_NORMAL = 15,
		RETRACT_SPEED_RELOCATE = 20,
		SWAY_AMPLITUDE = createVector(0.3, 0.1, 0.2),
		SWAY_FREQUENCY = createVector(0.3, 0.5, 0.25)
	},
	CEILING_ZONE_TAG = "SquirmCeilingZone",
	CEILING_ZONE_TAGS = {
		CENTER = "CeilingZone_Center",
		STANDARD = "CeilingZone",
		WALL = "CeilingZone_Wall"
	},
	ZONE_PRIORITY = {
		CENTER = 100,
		WALL = 50,
		STANDARD = 10
	},
	WALL_TAG = "Wall",
	LOS_BLOCKING_TAGS = { "Wall", "Obstacle" },
	WALL_COLLISION = {
		ENABLED = true,
		SAFE_DISTANCE = 1.5
	},
	ZONE = {
		SIZE = createVector(50, 30, 50),
		OFFSET_Y = -15,
		QUERY_INTERVAL = 0.1
	},
	DISTANCES = {
		ALERT = 25,
		ALERT_EXIT = 35,
		DESCEND = 25,
		DESCEND_EXIT = 30,
		STRIKE = 12,
		GRAB = 7,
		ESCAPE = 10,
		RELOCATE = 50,
		PLAYER_WATCH = 40,
		PLAYER_FACE = 40,
		BOOKSHELF_SEARCH = 35
	},
	BOOKSHELF = {
		IDLE_DELAY = 60,
		USE_MUNCH_LEAVE_ANIM = true,
		MUNCH_LEAVE_DURATION = 1.5
	},
	TIMING = {
		ALERT_DELAY = 1.5,
		ALERT_TIMEOUT = 8,
		STRIKE_DURATION = 0.6,
		STRIKE_DURATION_MAX = 1.5,
		RECOIL_DURATION = 2.5,
		LEAVE_ANIM_DURATION = 2,
		CEILING_PUDDLE_FADE = 0.6,
		EMERGE_DELAY = 1,
		RELOCATE_COOLDOWN = 3,
		IDLE_RELOCATE_MIN = 45,
		IDLE_RELOCATE_MAX = 90,
		MIN_IDLE = 1,
		MIN_ALERT = 2,
		MIN_DESCENDING = 0.5,
		MIN_STRIKE = 0.3,
		MIN_HOLDING = 1,
		MIN_RECOIL = 1.5
	},
	WHIFF = {
		MAX_RETRIES = 2,
		RETRY_COOLDOWN = 1.5,
		FULL_COOLDOWN = 5,
		FRUSTRATION_SPEEDUP = 1.2
	},
	GRAB = {
		GRAB_SPEED_MULTIPLIER = 0.15,
		TIMEOUT_DAMAGE = 1,
		MAX_DURATION = 4,
		GRAB_COOLDOWN = 8,
		ALERT_TWISTEDS_ON_GRAB = false,
		ALERT_TWISTEDS_ON_ESCAPE = false,
		ATTACHMENT_OFFSET = createVector(0, 4, 2),
		SQUIRM_OFFSET = createVector(0, 0, 0),
		CHARACTER_OFFSETS = {
			Pebble = createVector(0, 1.5, 4)
		},
		ATTACHMENT_ROTATION = createVector(0, 0, 0)
	},
	STRUGGLE = {
		STRUGGLES_TO_ESCAPE = 20,
		PROGRESS_PER_STRUGGLE = 5,
		MIN_INPUT_INTERVAL = 0.05,
		MAX_INPUT_INTERVAL = 1.5,
		DECAY_RATE = 3,
		DECAY_DELAY = 0.8,
		WRONG_INPUT_PENALTY = 2,
		WRONG_INPUT_COOLDOWN = 0.15,
		MOVEMENT_BONUS_ENABLED = true,
		MOVEMENT_BONUS_MULTIPLIER = 0.5,
		TOUCH_ZONE_WIDTH = 0.4,
		STICK_THRESHOLD = 0.5,
		FLASH_ON_STRUGGLE = true,
		SHAKE_ON_STRUGGLE = true,
		SHAKE_INTENSITY = 3
	},
	RELOCATION = {
		ENABLED = true,
		MIN_DISTANCE_TO_RELOCATE = 30,
		PREFER_CLOSER_ANCHOR = false,
		HIDE_DURING_TELEPORT = true,
		SCURRY_TRAVEL_SPEED = 40,
		SCURRY_VOLUME = 1,
		SCURRY_ROLLOFF = 200
	},
	ANIMATIONS = {
		IDLE_HANGING = "rbxassetid://98557050106397",
		ALERT = "rbxassetid://123118786348855",
		ALERT_B = "rbxassetid://120205604474409",
		IDLE_TO_READY = "rbxassetid://130069185652222",
		DESCEND = "rbxassetid://81784629508125",
		STRIKE = "rbxassetid://112701703239803",
		HOLDING = "rbxassetid://105829442651312",
		RETRACT = "rbxassetid://99097557271640",
		LEAVE = "rbxassetid://119466598283627",
		EMERGE = "rbxassetid://130764964149887",
		LOST_INTEREST = "rbxassetid://113275431719629",
		ALERT_TO_IDLE_A = "rbxassetid://114369085815140",
		ALERT_TO_IDLE_B = "rbxassetid://98982935244309",
		ATTACK_START = "rbxassetid://129335553885155",
		ATTACK_LOOP = "rbxassetid://125065604973503",
		QUIRK = "rbxassetid://134359604905978",
		ALERT_C = "rbxassetid://135048813582670",
		EATING_BOOKS = "rbxassetid://104488316492019",
		MUNCH_LEAVE_A = "rbxassetid://100966559208531",
		MUNCH_LEAVE_B = "rbxassetid://76566251560158"
	},
	SOUNDS = {
		IDLE_DRIP = "rbxassetid://132099523680905",
		ALERT_HISS = "rbxassetid://93949511004321",
		DESCEND_CREAK = "rbxassetid://86811156044116",
		SCURRY_TRAVEL = "rbxassetid://75013658034784",
		STRIKE_LUNGE = "rbxassetid://130197518206108",
		GRAB_CHOMP = "rbxassetid://121593641826701",
		HOLDING_STRUGGLE = "rbxassetid://75780516089827",
		RETRACT_WOOSH = "rbxassetid://135993917130910",
		TELEPORT = "rbxassetid://137100141753732",
		EMERGE = "rbxassetid://109633461841936",
		LEAVE = "rbxassetid://131173396953101",
		BOOK_MUNCH = "rbxassetid://109154321614942",
		PLAYER_ESCAPE = "rbxassetid://106768382386122",
		PLAYER_GASP = "rbxassetid://118698401673131"
	},
	IDLE_SOUND_VARIANTS = { "rbxassetid://132099523680905", "rbxassetid://81425351248870" },
	SCREAM_VARIANTS = { "rbxassetid://93949511004321" },
	MUNCH_VARIANTS = { "rbxassetid://109154321614942" },
	GRAB_EFFECTS = {
		SHAKE_ENABLED = true,
		SHAKE_DURATION = 0.3,
		SHAKE_INTENSITY = 20,
		BLUR_ENABLED = true,
		BLUR_DURATION = 0.4,
		BLUR_SIZE = 18,
		SOUND_ENABLED = true,
		SOUND_VOLUME = 0.8,
		ARM_WIGGLE_ENABLED = true,
		ARM_WIGGLE_DURATION = 0.18,
		ARM_WIGGLE_INTENSITY = 3.5,
		ARM_WIGGLE_FLAIL = true
	},
	SQUIRM_ALERT_EFFECTS = {
		SHAKE_ENABLED = true,
		SHAKE_DURATION = 0.2,
		SHAKE_INTENSITY = 8,
		SOUND_ENABLED = true,
		SOUND_VOLUME = 0.6,
		SOUND_ROLLOFF = 60
	},
	ESCAPE_EFFECTS = {
		SCREAM_ENABLED = false,
		SCREAM_VOLUME = 1.5,
		SCREAM_ROLLOFF = 100,
		SHAKE_ENABLED = true,
		SHAKE_DURATION = 0.5,
		SHAKE_INTENSITY = 15,
		BLUR_ENABLED = true,
		BLUR_DURATION = 0.3,
		BLUR_SIZE = 24,
		ALERT_RADIUS = 150
	},
	TILT = {
		IDLE = 0,
		ALERT = 0,
		DESCENDING = 0,
		STRIKE = 0,
		HOLDING = 0,
		RECOIL = 0,
		EATING_BOOKS = 0,
		LERP_SPEED = 0.8
	},
	SPRING = {
		IDLE_STIFFNESS = 2,
		IDLE_DAMPING = 5,
		ALERT_STIFFNESS = 2,
		ALERT_DAMPING = 6,
		DESCEND_STIFFNESS_BASE = 15,
		DESCEND_STIFFNESS_ACCEL = 10,
		DESCEND_DAMPING = 5,
		STRIKE_STIFFNESS = 45,
		STRIKE_DAMPING = 6,
		HOLDING_STIFFNESS = 50,
		HOLDING_DAMPING = 12,
		RECOIL_STIFFNESS = 4,
		RECOIL_DAMPING = 6,
		MAX_VELOCITY = 40,
		YAW_LERP_SPEED = 2
	},
	ANIMATION = {
		BLEND_TIME = 0.5
	},
	IK = {
		ENABLED = false,
		WEIGHT = 0.75,
		SMOOTH_TIME = 0.15,
		LOOK_AT_TYPE = 0
	},
	HAND_IK = {
		ENABLED = true,
		WEIGHT = 1,
		FADE_IN_TIME = 0,
		FADE_OUT_TIME = 0.15,
		LEFT_HAND_OFFSET = createVector(-2.5, 1.5, -0.5),
		RIGHT_HAND_OFFSET = createVector(2.5, 1.5, -0.5),
		LEFT_POLE_OFFSET = createVector(-3, 2, 0.5),
		RIGHT_POLE_OFFSET = createVector(3, 2, 0.5),
		CHARACTER_OVERRIDES = {
			Pebble = {
				disabled = true
			}
		}
	},
	CEILING_DUST = {
		ENABLED = true,
		TEXTURE = "rbxasset://textures/particles/smoke_main.dds",
		COLOR = ColorSequence.new(Color3.fromRGB(180, 170, 155), Color3.fromRGB(140, 130, 115)),
		SIZE = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.8),
			NumberSequenceKeypoint.new(0.5, 2),
			NumberSequenceKeypoint.new(1, 3)
		}),
		TRANSPARENCY = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.1),
			NumberSequenceKeypoint.new(0.5, 0.4),
			NumberSequenceKeypoint.new(1, 1)
		}),
		LIFETIME = NumberRange.new(2, 4),
		RATE = 30,
		SPEED = NumberRange.new(2, 6),
		SPREAD_ANGLE = Vector2.new(30, 30),
		ROTATION = NumberRange.new(0, 360),
		ROT_SPEED = NumberRange.new(-20, 20),
		ACCELERATION = createVector(0, -4, 0),
		LIGHT_INFLUENCE = 1
	},
	ICHOR_DRIP = {
		ENABLED = true,
		FOLDER_NAME = "IchorPuddlesCeiling",
		MODEL_PATTERN = "Ichor_Puddle_"
	},
	GLOWING_EYES = {
		ENABLED = true,
		BLACKOUT_ONLY = true,
		BRIGHTNESS = 2,
		RANGE = 15,
		COLOR = Color3.fromRGB(255, 100, 100),
		DISTANCE_TWEEN_ENABLED = true,
		DISTANCE_MAX = 40,
		DISTANCE_MIN = 10,
		TWEEN_TIME = 0.5,
		MIN_BRIGHTNESS = 0.3,
		MIN_EMISSIVE = 0,
		MAX_EMISSIVE = 30
	},
	DEBUG = {
		ENABLED = false,
		SHOW_ZONE = false,
		SHOW_ROPE = true,
		SHOW_STATE = false,
		LOG_STATE_CHANGES = false,
		LOG_GRAB_PROGRESS = false,
		LOG_IK = false,
		LOG_WALL_DETECTION = true,
		VISUALIZE_IK_TARGETS = false,
		CONSTANT_GRAB = false,
		CONSTANT_GRAB_TARGET = nil
	},
	PARTS = {
		ROOT = "RootPart",
		COCOON = "Cocoon",
		HEAD = "Head",
		ANTENNAS = "Antennas",
		TORSO = "Torso",
		BASE = "Base",
		LEFT_UPPER_ARM = "LeftUpperArm",
		LEFT_LOWER_ARM = "LeftLowerArm",
		RIGHT_UPPER_ARM = "RIghtUpperArm",
		RIGHT_LOWER_ARM = "RightLowerArm",
		DRIP = "Drip",
		GLOWING_EYES = "GlowingEyes"
	},
	STATES = {
		IDLE = "IDLE",
		ALERT = "ALERT",
		DESCENDING = "DESCENDING",
		STRIKE = "STRIKE",
		HOLDING = "HOLDING",
		RECOIL = "RECOIL",
		RELOCATING = "RELOCATING"
	}
}

function TwistedSquirmConfig.Validate()
	local v = {}

	for k, v2 in pairs(TwistedSquirmConfig.ANIMATIONS) do
		if v2 == "rbxassetid://0" then
			table.insert(v, "Animation '" .. k .. "' not configured (rbxassetid://0)")
		end
	end

	for k, v2 in pairs(TwistedSquirmConfig.SOUNDS) do
		if v2 == "rbxassetid://0" then
			table.insert(v, "Sound '" .. k .. "' not configured (rbxassetid://0)")
		end
	end

	if #v > 0 then
		warn("[TwistedSquirmConfig] Configuration warnings:")

		for _, v2 in ipairs(v) do
			warn("  - " .. v2)
		end
	end

	return #v == 0
end

function TwistedSquirmConfig.SetConfig(items)
	if type(items) ~= "table" then
		return
	end

	local v = {
		SpeedMultiplier = { "GRAB", "GRAB_SPEED_MULTIPLIER" },
		TimeoutDamage = { "GRAB", "TIMEOUT_DAMAGE" },
		MaxDuration = { "GRAB", "MAX_DURATION" },
		GrabCooldown = { "GRAB", "GRAB_COOLDOWN" },
		StrugglesToEscape = { "STRUGGLE", "STRUGGLES_TO_ESCAPE" },
		StruggleDecayRate = { "STRUGGLE", "DECAY_RATE" },
		DescendSpeed = { "MOVEMENT", "DESCEND_SPEED_MAX" },
		StrikeSpeed = { "MOVEMENT", "STRIKE_SPEED" },
		AlertDist = { "DISTANCES", "ALERT" },
		StrikeDist = { "DISTANCES", "STRIKE" },
		GrabDist = { "DISTANCES", "GRAB" },
		EscapeDist = { "DISTANCES", "ESCAPE" },
		RopeLength = { "ROPE", "LENGTH_MAX" },
		AlertDelay = { "TIMING", "ALERT_DELAY" },
		AlertTimeout = { "TIMING", "ALERT_TIMEOUT" },
		StrikeDuration = { "TIMING", "STRIKE_DURATION" },
		StrikeDurationMax = { "TIMING", "STRIKE_DURATION_MAX" },
		RecoilDuration = { "TIMING", "RECOIL_DURATION" },
		MinAlert = { "TIMING", "MIN_ALERT" },
		MinRecoil = { "TIMING", "MIN_RECOIL" },
		EmergeDelay = { "TIMING", "EMERGE_DELAY" },
		ScurryVolume = { "RELOCATION", "SCURRY_VOLUME" },
		ScurrySpeed = { "RELOCATION", "SCURRY_TRAVEL_SPEED" },
		DustRate = { "CEILING_DUST", "RATE" },
		DustEnabled = { "CEILING_DUST", "ENABLED" },
		HeadIKEnabled = { "IK", "ENABLED" },
		HeadIKWeight = { "IK", "WEIGHT" },
		HeadIKLookAtType = { "IK", "LOOK_AT_TYPE" },
		HandIKEnabled = { "HAND_IK", "ENABLED" },
		LeftHandOffset = { "HAND_IK", "LEFT_HAND_OFFSET" },
		RightHandOffset = { "HAND_IK", "RIGHT_HAND_OFFSET" },
		LeftPoleOffset = { "HAND_IK", "LEFT_POLE_OFFSET" },
		RightPoleOffset = { "HAND_IK", "RIGHT_POLE_OFFSET" },
		HandIKWeight = { "HAND_IK", "WEIGHT" },
		UseMunchLeaveAnim = { "BOOKSHELF", "USE_MUNCH_LEAVE_ANIM" },
		MunchLeaveDuration = { "BOOKSHELF", "MUNCH_LEAVE_DURATION" },
		WallCollisionEnabled = { "WALL_COLLISION", "ENABLED" },
		WallSafeDistance = { "WALL_COLLISION", "SAFE_DISTANCE" },
		DebugEnabled = { "DEBUG", "ENABLED" },
		ShowState = { "DEBUG", "SHOW_STATE" },
		ShowIKTargets = { "DEBUG", "VISUALIZE_IK_TARGETS" },
		LogWallDetection = { "DEBUG", "LOG_WALL_DETECTION" },
		ConstantGrab = { "DEBUG", "CONSTANT_GRAB" },
		ConstantGrabTarget = { "DEBUG", "CONSTANT_GRAB_TARGET" },
		EyesEnabled = { "GLOWING_EYES", "ENABLED" },
		EyesBlackoutOnly = { "GLOWING_EYES", "BLACKOUT_ONLY" },
		EyesBrightness = { "GLOWING_EYES", "BRIGHTNESS" },
		EyesRange = { "GLOWING_EYES", "RANGE" },
		EyesDistanceTween = { "GLOWING_EYES", "DISTANCE_TWEEN_ENABLED" },
		EyesDistanceMin = { "GLOWING_EYES", "DISTANCE_MIN" },
		EyesDistanceMax = { "GLOWING_EYES", "DISTANCE_MAX" },
		ArmWiggleEnabled = { "GRAB_EFFECTS", "ARM_WIGGLE_ENABLED" },
		ArmWiggleDuration = { "GRAB_EFFECTS", "ARM_WIGGLE_DURATION" },
		ArmWiggleIntensity = { "GRAB_EFFECTS", "ARM_WIGGLE_INTENSITY" },
		ArmWiggleFlail = { "GRAB_EFFECTS", "ARM_WIGGLE_FLAIL" }
	}

	for k, item in pairs(items) do
		local v2 = v[k]

		if not v2 then
			continue
		end

		local v3 = TwistedSquirmConfig[v2[1]]

		if v3 then
			v3[v2[2]] = item
		end
	end
end

function TwistedSquirmConfig.GetConfig()
	return {
		SpeedMultiplier = TwistedSquirmConfig.GRAB.GRAB_SPEED_MULTIPLIER,
		TimeoutDamage = TwistedSquirmConfig.GRAB.TIMEOUT_DAMAGE,
		MaxDuration = TwistedSquirmConfig.GRAB.MAX_DURATION,
		GrabCooldown = TwistedSquirmConfig.GRAB.GRAB_COOLDOWN,
		StrugglesToEscape = TwistedSquirmConfig.STRUGGLE.STRUGGLES_TO_ESCAPE,
		StruggleDecayRate = TwistedSquirmConfig.STRUGGLE.DECAY_RATE,
		DescendSpeed = TwistedSquirmConfig.MOVEMENT.DESCEND_SPEED_MAX,
		StrikeSpeed = TwistedSquirmConfig.MOVEMENT.STRIKE_SPEED,
		AlertDist = TwistedSquirmConfig.DISTANCES.ALERT,
		StrikeDist = TwistedSquirmConfig.DISTANCES.STRIKE,
		GrabDist = TwistedSquirmConfig.DISTANCES.GRAB,
		EscapeDist = TwistedSquirmConfig.DISTANCES.ESCAPE,
		RopeLength = TwistedSquirmConfig.ROPE.LENGTH_MAX,
		AlertDelay = TwistedSquirmConfig.TIMING.ALERT_DELAY,
		AlertTimeout = TwistedSquirmConfig.TIMING.ALERT_TIMEOUT,
		StrikeDuration = TwistedSquirmConfig.TIMING.STRIKE_DURATION,
		StrikeDurationMax = TwistedSquirmConfig.TIMING.STRIKE_DURATION_MAX,
		RecoilDuration = TwistedSquirmConfig.TIMING.RECOIL_DURATION,
		MinAlert = TwistedSquirmConfig.TIMING.MIN_ALERT,
		MinRecoil = TwistedSquirmConfig.TIMING.MIN_RECOIL,
		EmergeDelay = TwistedSquirmConfig.TIMING.EMERGE_DELAY,
		ScurryVolume = TwistedSquirmConfig.RELOCATION.SCURRY_VOLUME,
		ScurrySpeed = TwistedSquirmConfig.RELOCATION.SCURRY_TRAVEL_SPEED,
		DustRate = TwistedSquirmConfig.CEILING_DUST.RATE,
		DustEnabled = TwistedSquirmConfig.CEILING_DUST.ENABLED,
		HeadIKEnabled = TwistedSquirmConfig.IK.ENABLED,
		HeadIKWeight = TwistedSquirmConfig.IK.WEIGHT,
		HeadIKLookAtType = TwistedSquirmConfig.IK.LOOK_AT_TYPE,
		HandIKEnabled = TwistedSquirmConfig.HAND_IK.ENABLED,
		LeftHandOffset = TwistedSquirmConfig.HAND_IK.LEFT_HAND_OFFSET,
		RightHandOffset = TwistedSquirmConfig.HAND_IK.RIGHT_HAND_OFFSET,
		LeftPoleOffset = TwistedSquirmConfig.HAND_IK.LEFT_POLE_OFFSET,
		RightPoleOffset = TwistedSquirmConfig.HAND_IK.RIGHT_POLE_OFFSET,
		HandIKWeight = TwistedSquirmConfig.HAND_IK.WEIGHT,
		WallCollisionEnabled = TwistedSquirmConfig.WALL_COLLISION.ENABLED,
		WallSafeDistance = TwistedSquirmConfig.WALL_COLLISION.SAFE_DISTANCE,
		DebugEnabled = TwistedSquirmConfig.DEBUG.ENABLED,
		ShowState = TwistedSquirmConfig.DEBUG.SHOW_STATE,
		ShowIKTargets = TwistedSquirmConfig.DEBUG.VISUALIZE_IK_TARGETS,
		LogWallDetection = TwistedSquirmConfig.DEBUG.LOG_WALL_DETECTION,
		ConstantGrab = TwistedSquirmConfig.DEBUG.CONSTANT_GRAB,
		ConstantGrabTarget = TwistedSquirmConfig.DEBUG.CONSTANT_GRAB_TARGET,
		EyesEnabled = TwistedSquirmConfig.GLOWING_EYES and TwistedSquirmConfig.GLOWING_EYES.ENABLED or false,
		EyesBlackoutOnly = TwistedSquirmConfig.GLOWING_EYES and TwistedSquirmConfig.GLOWING_EYES.BLACKOUT_ONLY or false,
		EyesBrightness = TwistedSquirmConfig.GLOWING_EYES and TwistedSquirmConfig.GLOWING_EYES.BRIGHTNESS or 2,
		EyesRange = TwistedSquirmConfig.GLOWING_EYES and TwistedSquirmConfig.GLOWING_EYES.RANGE or 15,
		EyesDistanceTween = TwistedSquirmConfig.GLOWING_EYES and TwistedSquirmConfig.GLOWING_EYES.DISTANCE_TWEEN_ENABLED or false,
		EyesDistanceMin = TwistedSquirmConfig.GLOWING_EYES and TwistedSquirmConfig.GLOWING_EYES.DISTANCE_MIN or 10,
		EyesDistanceMax = TwistedSquirmConfig.GLOWING_EYES and TwistedSquirmConfig.GLOWING_EYES.DISTANCE_MAX or 40,
		ArmWiggleEnabled = TwistedSquirmConfig.GRAB_EFFECTS.ARM_WIGGLE_ENABLED,
		ArmWiggleDuration = TwistedSquirmConfig.GRAB_EFFECTS.ARM_WIGGLE_DURATION,
		ArmWiggleIntensity = TwistedSquirmConfig.GRAB_EFFECTS.ARM_WIGGLE_INTENSITY,
		ArmWiggleFlail = TwistedSquirmConfig.GRAB_EFFECTS.ARM_WIGGLE_FLAIL
	}
end

function TwistedSquirmConfig.EnableConstantGrab(CONSTANT_GRAB, CONSTANT_GRAB_TARGET)
	TwistedSquirmConfig.DEBUG.CONSTANT_GRAB = CONSTANT_GRAB
	TwistedSquirmConfig.DEBUG.CONSTANT_GRAB_TARGET = CONSTANT_GRAB_TARGET

	if CONSTANT_GRAB and CONSTANT_GRAB_TARGET then
	end
end

return TwistedSquirmConfig