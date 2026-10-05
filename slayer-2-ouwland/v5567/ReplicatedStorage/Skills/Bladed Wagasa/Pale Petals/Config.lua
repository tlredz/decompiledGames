local createVector = vector.create
local cframe = CFrame.fromMatrix(createVector(0, 0, 0), createVector(0, 0, 1), createVector(0, 1, 0))
local Config = {
	THROW_DURATION = 0.75,
	HOVER_DURATION = 3,
	PETAL_START_DELAY = 0.23333333333333334,
	PETAL_INTERVAL = 0.11666666666666667,
	THROW_WALK_SPEED = 8,
	LOCKED_SKILLS = "Floating Grace,Shade Breaker",
	HOVER_ORIENTATION = createVector(45, 90, 180),
	HOVER_POSITION = createVector(-0.138, 10.293, -0.59),
	UMBWEP2_F45 = CFrame.fromMatrix(createVector(-0.138, 2.207, -0.126), createVector(-1, 0, 0), createVector(0, 0, 1))
}
Config.UMBWEP2_F55 = CFrame.new(Config.HOVER_POSITION) * cframe:Inverse() * CFrame.Angles(
	0,
	math.rad(Config.HOVER_ORIENTATION.Y),
	0
) * CFrame.Angles(math.rad(Config.HOVER_ORIENTATION.X), 0, 0) * CFrame.Angles(
	0,
	0,
	(math.rad(Config.HOVER_ORIENTATION.Z))
) * CFrame.Angles(3.141592653589793, 0, 0)
Config.PETAL_SPEED = 90
Config.PETAL_LEAD = 1
Config.SCAN_OFFSET = CFrame.new(0, 0, -7)
Config.SCAN_SIZE = createVector(30, 25, 30)
Config.PETAL_LIFETIME = 1.2
Config.PETAL_SIZE = createVector(2, 2, 2)
Config.PETAL_DAMAGE = 3
Config.PETAL_BLOCK_BREAK = 0.175
return Config