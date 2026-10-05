local vector = Vector2.new(10, 20)
local vector2 = Vector2.new(60, 130)

local function r_vec(vector3)
	return math.random(vector3.X, vector3.Y)
end

wait(r_vec(vector))
local v = {
	"The community server has channels for both suggestions and bug reports!",
	"If you're enjoying the game so far, don't forget to leave a like!",
	"Thank you for playing Neighbors :)",
	"When was the last time somebody asked how you were truly feeling?",
	"Met anyone new so far? I hope so!",
	"We highly recommend you join the community server!",
	"How are you liking Neighbors so far?",
	"Thank you so much for playing, we seriously appreciate it.",
	"We're open to all kinds of feedback! Let us know what you think in the community server.",
	"Please note that the game is still in heavy development. Thank you!"
}

while true do
	_G.DisplayText(v[math.random(1, #v)], 10)
	wait(r_vec(vector2))
end