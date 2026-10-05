local createVector = vector.create
game:GetService("RunService")
local Server = require(game.ReplicatedStorage.Modules.Server)
local isTestServer = Server:IsTestServer()

local function minutes(p: number)
	return p * 60
end

return {
	GET_RANDOM_CANDY_AMOUNT = function()
		return math.random(3, 8)
	end,
	SANTA_ENABLED = true,
	POSITION = 0,
	SANTA_SPEED = 60,
	REINDEER_SPACING = 10,
	POINT_CENTER = createVector(800, 200, 800),
	POINT_SPREAD = 50,
	POINT_SPREAD_VECTOR = createVector(1, 1, 1),
	POINT_RADIUS = 500,
	POINT_AMOUNT = 15,
	MINIMUM_QUEUED_TIME_FOR_SANTA = isTestServer and 10 or 300,
	DIVE_POINT_AMOUNT = 3,
	DIVE_POINT_SPREAD = createVector(1.5, 0.25, 1.5),
	DIVE_WAIT_TIME = isTestServer and { 0, 6 } or { 1080, 1800 },
	DIVE_SPEED = 60,
	PRESENT_DESTROY_TIME = 2,
	PRESENT_DESPAWN_TIME = 45,
	PRESENT_DROP_TIME_PERIOD = 120,
	PRESENT_DROPS_WAIT_TIME = isTestServer and { 0, 6 } or { 540, 960 },
	PRESENT_SPAWN_CHANCE = isTestServer and 120 / (60 * 120) or 15 / (60 * 120),
	PRESENT_MOVEMENT_STEP = 150,
	PRESENT_MOVEMENT_TOP_Y = 100
}