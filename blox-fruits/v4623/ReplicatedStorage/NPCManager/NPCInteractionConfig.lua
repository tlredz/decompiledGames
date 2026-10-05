local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local v = 0
local v2 = -1e999

local function getCharacterPivotHeight(instance)
	local humanoid = instance:FindFirstChildWhichIsA("Humanoid")

	if not humanoid then
		return 0
	end

	local rootPart = humanoid.RootPart

	if rootPart then
		return humanoid.HipHeight + rootPart.Size.Y / 2
	end

	return 0
end

return {
	DIALOGUE_CAMERA_ANGLE = 30,
	DIALOGUE_CAMERA_SWING_SPEED = 30,
	DIALOGUE_CAMERA_SIDE_RESET = 15,
	DIALOGUE_CAMERA_BASE_DISTANCE = 6,
	DIALOGUE_CAMERA_PULLBACK = 1.35,
	DIALOGUE_CAMERA_PLAYER_GAP = 8,
	DIALOGUE_CAMERA_HEIGHT = 2.5,
	DIALOGUE_CAMERA_FREQUENCY = 2.5,
	DIALOGUE_STAGED_CAMERA_FORWARD = 1.75,
	DIALOGUE_STAGED_CAMERA_HEIGHT = 1.5,
	DIALOGUE_STAGED_WALKAWAY_MARGIN = 6,
	DIALOGUE_WALKAWAY_DISTANCE = 13,
	DIALOGUE_START_LOCKOUT = 0.5,
	DIALOGUE_PLAYER_GAP = 9,
	DIALOGUE_PLAYER_POSITION_RADIUS = 3,
	DIALOGUE_PLAYER_LOOK_TWEEN_TIME = 0.2,
	DIALOGUE_PLAYER_MOVE_TIMEOUT = 0.75,
	DIALOGUE_PLAYER_REACHED_DISTANCE = 0.3,
	DIALOGUE_PLAYER_REFACE_TIMEOUT = 0.55,
	DIALOGUE_PLAYER_REFACE_DOT = 0.995,
	DIALOGUE_PLAYER_REFACE_MOVE_SCALE = 0.15,
	DIALOGUE_PLAYER_FLOOR_RAY_HEIGHT = 12,
	DIALOGUE_PLAYER_FLOOR_RAY_DEPTH = 80,
	DIALOGUE_PLAYER_FLOOR_CLEARANCE = 0.15,
	DIALOGUE_PLAYER_MIN_FLOOR_NORMAL_Y = 0.7,
	DIALOGUE_PLAYER_MAX_STEP_UP = 2,
	DIALOGUE_PLAYER_MAX_DROP = 6,
	DIALOGUE_PLAYER_MIN_GAP = 4,
	DIALOGUE_PLAYER_GAP_STEP = 2,
	DIALOGUE_PLAYER_PATH_FLOOR_SAMPLE_DISTANCE = 2,
	DIALOGUE_PLAYER_SIDE_OFFSETS = { 0, -2, 2 },
	DIALOGUE_PLAYER_PATH_RAY_HEIGHTS = { 0.25, 2.5 },
	getLocalCharacterReach = function()
		local now = os.clock()

		if now - v2 < 0.1 then
			return v
		end

		v2 = now
		local character

		if localPlayer then
			character = localPlayer.Character
		end

		local v3

		if character then
			local humanoid = character:FindFirstChildWhichIsA("Humanoid")

			if humanoid then
				local rootPart = humanoid.RootPart
				v3 = not rootPart and 0 or humanoid.HipHeight + rootPart.Size.Y / 2
			else
				v3 = 0
			end
		else
			v3 = 0
		end

		v = math.max(v3 - 4, 0) * 1.5
		return v
	end
}