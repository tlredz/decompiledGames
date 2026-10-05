local createVector = vector.create
local lightingPresets = game.ReplicatedStorage.ReplicatedAssets.LightingPresets
local import = _G.import("aura")
_G.import("event")
_G.import("iterator")
_G.import("cframeUtil")
local import2 = _G.import("vectorUtil")
_G.import("modelUtil")
_G.import("dictUtil")
_G.import("clientUtil")
local import3 = _G.import("cameraShake")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local localPlayer = game.Players.LocalPlayer or {
	GetMouse = function()
		return {
			Hit = CFrame.new(0, 0, 0)
		}
	end
}
local mouse = localPlayer:GetMouse()
local currentCamera = workspace.CurrentCamera
local v = import3.new(Enum.RenderPriority.Camera.Value, function(p)
	currentCamera.CFrame *= p
end)
local CameraUtil = {
	ray = function(p, p2, filterType, filterDescendantsInstances)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = filterType
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		raycastParams.IgnoreWater = true
		local raycastResult = workspace:Raycast(p, p2, raycastParams)

		if not raycastResult then
			return CFrame.new(p + p2, p + p2 + p2.unit)
		end

		local position = raycastResult.Position
		return CFrame.new(position, position + p2), raycastResult.Instance, raycastResult.Normal
	end,
	mouseHit = function()
		return mouse.hit
	end
}

function CameraUtil.hitAboveGround(p)
	local hit = mouse.hit
	local rayGround = CameraUtil.rayGround(hit.p + createVector(0, 0.01, 0), p)
	return hit - hit.p + rayGround.p + Vector3.new(0, p, 0)
end

function CameraUtil.rayGround(p, value)
	return CameraUtil.rayWhiteGround(p, (Vector3.new(0, -(value or 999), 0)))
end

function CameraUtil.rayWhiteGround(p, p2)
	return CameraUtil.rayWhite(p, p2, CollectionService:GetTagged("Ground"), CFrame.new(p + p2))
end

function CameraUtil.rayWhite(p, p2, p3, p4)
	return CameraUtil.ray(p, p2, Enum.RaycastFilterType.Include, p3, p4)
end

function CameraUtil.rayBlack(p, p2, p3, p4)
	return CameraUtil.ray(p, p2, Enum.RaycastFilterType.Exclude, p3, p4)
end

function CameraUtil.hitWhite(options)
	local vector2 = Vector2.new(mouse.X, mouse.Y)
	local screenPointToRay = currentCamera:ScreenPointToRay(vector2.X, vector2.Y, 0)
	return CameraUtil.rayWhite(screenPointToRay.Origin, screenPointToRay.Direction * 999, options or {}, mouse.Hit)
end

function CameraUtil.hitGround()
	return CameraUtil.hitWhite(CollectionService:GetTagged("Ground"))
end

function CameraUtil.shake(callback, ...)
	v:Start()
	callback(v, ...)
end

function CameraUtil.shakeWithin(p, p2, p3)
	local v2 = p2 * 6
	local magnitude = (localPlayer.Character.HumanoidRootPart.Position - p).magnitude

	if magnitude > 300 then
		return
	end

	CameraUtil.shake(p3, 0.5 + 0.5 * (1 - magnitude / v2))
end

function CameraUtil.explosion(p, p2, p3)
	CameraUtil.shakeWithin(p, p3, function(object, p4)
		object:ShakeOnce(
			p2 * 1 / 20 * p4,
			p2 * 1 / 4 * p4,
			0,
			math.max(0.2, p2 * 1 / 40),
			createVector(0.25, 0.25, 0.25) * p4,
			createVector(4, 1, 1) * p4
		)
	end)
end

CameraUtil.CameraShake = import3
local v2 = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function applyKeyframe(p, p2, p3, now, p4, p5)
	local v3 = p3 + p4.Time
	local v4 = p3 + p5.Time
	local v5 = (now - v3) / (v4 - v3)
	p.CFrame = p2 * p4.RootPart.CFrame:Lerp(p5.RootPart.CFrame, v5)
end

function CameraUtil.makeCameraAnimation(p, p2)
	local clone = CAMERA_ANIMATIONS[p2]:Clone()
	local now = os.clock()
	local v3 = -1e999

	for _, child in pairs(clone:GetChildren()) do
		v3 = child.Time < v3 and v3 or child.time
	end

	return {
		p,
		now,
		clone,
		v3,
		import.applyAura(game.Players.LocalPlayer, "CamScriptable")
	}
end

function CameraUtil.startCameraAnimation(p, p2)
	local GUID = HttpService:GenerateGUID()
	local cameraAnimation = CameraUtil.makeCameraAnimation(p, p2)
	v2[GUID] = cameraAnimation
	return GUID, cameraAnimation
end

function CameraUtil.stopCameraAnimation(p)
	import.removeAuraInstance(game.Players.LocalPlayer, v2[p][5])
	v2[p] = nil
end

function CameraUtil.stepCameraAnimation(p, list)
	local v3, v4, v5, v6 = unpack(list)
	local v7 = v4 + v6
	local now = os.clock()
	local v8 = now - v4

	if v7 <= now then
		return false
	end

	local v9 = nil
	local v10 = nil

	for _, child in pairs(v5:GetChildren()) do
		if child.Time < v8 then
			if v9 and v9.Time > child.Time and v9 then
				child = v9
			end

			v9 = child
		else
			if v10 and v10.Time < child.Time and v10 then
				child = v10
			end

			v10 = child
		end
	end

	applyKeyframe(p, v3, v4, now, v9, v10) -- equivalent call inferred; original call site unknown
	return true
end

local v3 = {
	W = createVector(0, 0, 1),
	A = createVector(-1, 0, 0),
	S = createVector(0, 0, -1),
	D = createVector(1, 0, 0)
}

function CameraUtil.getInputDir()
	local v4 = createVector(0, 0, 0)

	for k, v5 in pairs(v3) do
		if UserInputService:IsKeyDown(Enum.KeyCode[k]) then
			v4 += v5
		end
	end

	return import2.zeroUnit(v4)
end

function CameraUtil.getMovementDir()
	local vector2 = createVector(0, 1, 0)
	local v4 = currentCamera.CFrame.LookVector * createVector(1, 0, 1)
	local v5 = -vector2:Cross(v4)
	local inputDir = CameraUtil.getInputDir()
	return import2.zeroUnit(v5 * inputDir.X + vector2 * inputDir.Y + v4 * inputDir.Z)
end

function CameraUtil.getMovementDirChar(data)
	local inputDir = CameraUtil.getInputDir()
	return import2.zeroUnit(data.rightVector * inputDir.X + data.upVector * inputDir.Y + data.lookVector * inputDir.Z)
end

function CameraUtil.setLightingObject(instance)
	game.Lighting:ClearAllChildren()

	for _, depthOfFieldEffect in pairs(instance:GetChildren()) do
		if depthOfFieldEffect:IsA("DepthOfFieldEffect") then
			print(
				"[DOF TRACE] cameraUtil.setLightingObject cloning DepthOfFieldEffect from preset",
				instance.Name,
				depthOfFieldEffect.Name
			)
		end
	end

	for k, v4 in pairs(instance:GetAttributes()) do
		if k ~= "Technology" then
			game.Lighting[k] = v4
		end
	end

	for _, child in pairs(instance:GetChildren()) do
		local clone = child:Clone()
		clone.Parent = game.Lighting
	end
end

function CameraUtil.setLighting(p)
	local lightingPreset = lightingPresets[p]
	CameraUtil.setLightingObject(lightingPreset)
end

task.spawn(function()
	while true do
		for k, v4 in pairs(v2) do
			if not CameraUtil.stepCameraAnimation(currentCamera, v4) then
				CameraUtil.stopCameraAnimation(k)
			end
		end

		task.wait(0)
	end
end)
return CameraUtil