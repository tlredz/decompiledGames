local createVector = vector.create
local Effect = require(game.ReplicatedStorage.Effect)
local shakeCam = Effect.new("ShakeCam")
local currentCamera = workspace.CurrentCamera
return function(list)
	local v, v2 = unpack(list)
	local v3 = math.clamp(1 - (v.p - currentCamera.CFrame.p).Magnitude / (4 * v2), 0, 1)
	shakeCam:replicate({
		v3 * 2,
		v3 * 3,
		0,
		0.9,
		createVector(1, 1, 0),
		createVector(0, 0, 1)
	})
end