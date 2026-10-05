local createVector = vector.create
return {
	MOUSE_RANGE = 500,
	HOLD_FREEZE_AT = 0.2,
	RELEASE_CANCEL_WINDOW = 1.5,
	RELEASE_PAUSE_DUR = 1.14,
	TILE1_AT = 0.25,
	TILE_INTERVAL = 0.3,
	TILE_BLOCK_BREAK = 2,
	TILE_STUN = 1.5,
	TILE_RAGDOLL = 1.5,
	TILE_DAMAGES = { 6.25, 10, 11.25 },
	TILE_KNOCKBACKS = {
		{ 30, createVector(0, 10, 0) },
		{ 40, createVector(0, 15, 0) },
		{ 65, createVector(0, 45, 0) }
	},
	TILE_HITBOX_SIZES = { createVector(10, 10, 20), createVector(15, 15, 25), createVector(20, 30, 35) },
	TILE_HITBOX_OFFSETS = {
		CFrame.new(0.3939208984375, 0, -6.660888671875),
		CFrame.new(0.022705078125, 0, -17.94342041015625),
		CFrame.new(0.35882568359375, 0, -35.28997802734375)
	}
}