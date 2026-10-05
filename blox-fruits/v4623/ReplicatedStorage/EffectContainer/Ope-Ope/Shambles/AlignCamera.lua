local createVector = vector.create

local function xzAim(p, p2)
	return CFrame.new(p, p2 * createVector(1, 0, 1) + Vector3.new(0, p.Y))
end

local currentCamera = workspace.CurrentCamera
return function(list)
	local v, v2 = unpack(list)
	local _ = currentCamera.CFrame
	currentCamera.CFrame = CFrame.new(v2, v * createVector(1, 0, 1) + Vector3.new(0, v2.Y)) * CFrame.Angles(
		-0.5235987755982988,
		0,
		0
	)
end