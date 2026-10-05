local createVector = vector.create
return {
	SLOW_SPEED = 13,
	STARTUP = 0.3333333333333333,
	STRIKE_VFX_GAP = 0.1,
	SLASH_WIDTH = 12,
	SLASH_HEIGHT = 11,
	SLASH_LENGTH_PADDING = 8,
	SLASH_EXTRA_SIZE = createVector(4, 4, 10),
	SLASH_OFFSET = CFrame.new(0, 2.5, -5),
	SLASH_LEAD = 8,
	SLASHES = {
		{
			dash = "Dash1",
			strike = "Finisher1",
			windup = 0.15,
			lunge = 0.24,
			gap = 0.5,
			speed = 65,
			damage = 8,
			stun = 1,
			knockFwd = 27,
			knockUp = 1,
			knockDur = 1
		},
		{
			dash = "Dash2",
			strike = "Finisher2",
			windup = 0.15,
			lunge = 0.24,
			gap = 0.5,
			speed = 88,
			damage = 14,
			stun = 1,
			knockFwd = 27,
			knockUp = 2,
			knockDur = 1
		}
	},
	FINISHER = {
		dash = "Dash3",
		strikeB = "Finisher3b",
		windup = 0.19,
		lunge = 0.24,
		speed = 115,
		aoeGap = 0.4,
		outer = {
			size = createVector(50, 35, 50),
			offset = CFrame.new(0, 14.5, -3),
			damage = 22,
			ragdoll = 2,
			knockFwd = 45,
			knockUp = 18,
			knockDur = 0.5
		}
	}
}