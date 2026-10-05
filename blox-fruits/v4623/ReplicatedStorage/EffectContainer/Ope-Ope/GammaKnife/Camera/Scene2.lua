local createVector = vector.create

local function MapRay(p, p2)
	return workspace:FindPartOnRayWithWhitelist(Ray.new(p, p2), { workspace.Map })
end

local function lerpNumber(p, p2, p3)
	return p + (p2 - p) * p3
end

-- equivalent calls inferred from this helper; original call sites unknown
local function xzAim(p, p2)
	return CFrame.new(p, (Vector3.new(p2.X, p.Y, p2.Z)))
end

local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local Tween = require(game.ReplicatedStorage.Util.Tween)
require(game.ReplicatedStorage.Effect)
return function(list)
	local _, v, v2, v3 = unpack(list)
	local cFrame = currentCamera.CFrame
	local _, _, _ = cFrame:ToEulerAnglesXYZ()
	local v5 = xzAim(cFrame.p, cFrame * createVector(0, 0, -1)) -- equivalent call inferred; original call site unknown
	local cFrame2 = CFrame.new(v.p, v.p + v5.LookVector) * CFrame.Angles(-0.4363323129985824, 0, 0) * CFrame.new(
		0,
		2.75 * v3,
		10 * v3
	)
	wait(v2 * 0.1)
	local lastTime = tick()

	while tick() - lastTime < v2 do
		local v7 = tick() - lastTime
		local back = Tween.ease.out.back(v7, 0, 1, v2)
		local v8 = math.sin(3.141592653589793 * v7 / v2)
		currentCamera.FieldOfView = 70 + 20 * v8
		currentCamera.CFrame = cFrame:Lerp(cFrame2, back) * CFrame.new(Vector3.new(
			math.random() - 0.5,
			math.random() - 0.5,
			math.random() - 0.5
		) * 0.5 * v8) * CFrame.Angles(0, 0, 0.17453292519943295 * (math.random() - 0.5) * v8)
		RunService.RenderStepped:Wait()
	end

	currentCamera.CFrame = cFrame2
end