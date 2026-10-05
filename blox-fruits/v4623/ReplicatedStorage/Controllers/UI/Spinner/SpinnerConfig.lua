local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local RunService = game:GetService("RunService")
RunService:IsStudio()
local SpinnerConfig = {
	SKIP_ALL = true,
	DEBUG_SKIP = false,
	DEBUG_FAST_SPIN = false,
	PREVIEW_MODEL = true,
	NUM_PADDED_FRAMES = 2,
	MIN_SNAP_VELOCITY = 8,
	TWEEN_MIDDLE_TIME = 0.2,
	DAMPENING = 2,
	FREQUENCY = 0.5,
	FAST_SPIN_MIN_SNAP_VELOCITY = 16,
	FAST_SPIN_TWEEN_MIDDLE_TIME = 0.1,
	FAST_SPIN_DAMPENING = 0.9,
	FAST_SPIN_FREQUENCY = 3,
	SKIPPED_SPIN_DAMPENING = 0.9,
	SKIPPED_SPIN_FREQUENCY = 8,
	NUM_DATA = 100,
	TICK_SOUND_MAP = { "Blox_WheelTick_01", "Blox_WheelTick_02", "Blox_WheelTick_03" }
}
TableUtil.deepFreeze(SpinnerConfig)
return SpinnerConfig