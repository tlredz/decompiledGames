local createVector = vector.create

local function MapRay(p, p2)
	return workspace:FindPartOnRayWithWhitelist(Ray.new(p, p2), { workspace.Map })
end

local function lerpNumber(p, p2, p3)
	return p + (p2 - p) * p3
end

local function xzAim(p, p2)
	return CFrame.new(p, p2 * createVector(1, 0, 1) + Vector3.new(0, p.Y))
end

local RunService = game:GetService("RunService")
local currentCamera = workspace.CurrentCamera
local Tween = require(game.ReplicatedStorage.Util.Tween)
require(game.ReplicatedStorage.Effect)
return function(list)
	local _, v, v2, v3 = unpack(list)
	local cFrame = currentCamera.CFrame
	local _, _, _ = cFrame:ToEulerAnglesXYZ()
	local lastTime = tick()

	while tick() - lastTime < v2 do
		local v4 = tick() - lastTime
		local circ = Tween.ease.inout.circ(v4, 0, 1, v2)
		local back = Tween.ease["in"].back(v4, 0, 1, v2)
		local quad = Tween.ease["in"].quad(v4, 0, 1, v2)
		currentCamera.FieldOfView = 70 + 30 * math.sin(3.141592653589793 * quad)
		local cFrame2 = cFrame:Lerp(
			CFrame.new(v.p, v.p + cFrame.LookVector) * CFrame.Angles(-0.6108652381980153, 0, 0),
			circ
		) * CFrame.new(0, v3 * 0.2 * back, 3 * v3 * back)
		local v7 = cFrame2.p + cFrame2.LookVector
		local v8 = -2 * cFrame2.LookVector
		local part, v9, v10 = workspace:FindPartOnRayWithWhitelist(Ray.new(v7, v8), { workspace.Map })

		if part then
			currentCamera.CFrame = CFrame.new(v9) * (cFrame2 - cFrame2.p) + v10
		else
			currentCamera.CFrame = cFrame2
		end

		RunService.RenderStepped:Wait()
	end

	currentCamera.FieldOfView = 70
end