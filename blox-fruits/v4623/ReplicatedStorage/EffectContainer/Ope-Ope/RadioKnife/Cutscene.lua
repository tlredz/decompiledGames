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
require(game.ReplicatedStorage.Util.Tween)
return function(list)
	local v, v2, v3, v4 = unpack(list)
	currentCamera.CameraType = "Scriptable"
	local _ = currentCamera.CFrame
	local v5 = v * CFrame.Angles(0.2617993877991494, 0, 0) * CFrame.new(0, 0, -3 * v3)
	local lastTime = tick()
	local v6 = lastTime - 0.016666666666666666

	while tick() - lastTime < v4 do
		local now = tick()
		local v7 = now - v6
		local cframe = CFrame.new(v5.p, v2.Position)
		currentCamera.CFrame = currentCamera.CFrame:Lerp(cframe, v7 * 3)
		RunService.RenderStepped:Wait()
		v6 = now
	end
end