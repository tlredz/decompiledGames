local createVector = vector.create
local Players = game:GetService("Players")
local v = nil
local v2 = createVector(0, 1, 0)
local v3 = false
local v4 = nil
local v5 = false

local function resolveCameraUtils()
	if v ~= nil then
		return v
	end

	local localPlayer = Players.LocalPlayer
	local playerScripts

	if localPlayer ~= nil then
		playerScripts = localPlayer:FindFirstChild("PlayerScripts")
	end

	local playerModule

	if playerScripts ~= nil then
		playerModule = playerScripts:FindFirstChild("PlayerModule")
	end

	local cameraModule

	if playerModule ~= nil then
		cameraModule = playerModule:FindFirstChild("CameraModule")
	end

	local cameraUtils

	if cameraModule ~= nil then
		cameraUtils = cameraModule:FindFirstChild("CameraUtils")
	end

	if not (cameraUtils ~= nil and cameraUtils:IsA("ModuleScript")) then
		return v
	end

	local success, result = pcall(require, cameraUtils)

	if not success then
		result = nil
	end

	if result ~= nil and typeof(result.setGravityResolver) == "function" then
		v = result
	end

	return v
end

local Camera = {}

function Camera.setTarget(vector2: Vector3)
	v2 = vector2
	local cameraUtils = resolveCameraUtils()

	if cameraUtils ~= nil then
		if v4 ~= nil then
			cameraUtils.setGravityTau(v4)
			v4 = nil
		end

		cameraUtils.setGravityBodyOwned(v5)

		if not v3 then
			v3 = true
			cameraUtils.setGravityResolver(function()
				return v2
			end)
		end
	end
end

function Camera.setTau(p: number)
	local cameraUtils = resolveCameraUtils()

	if cameraUtils == nil then
		v4 = p
	else
		cameraUtils.setGravityTau(p)
	end
end

function Camera.setBodyOwned(flag: boolean)
	v5 = flag
end

function Camera.reset()
	v2 = createVector(0, 1, 0)
	v3 = false
	v5 = false
	local cameraUtils = resolveCameraUtils()

	if cameraUtils ~= nil then
		cameraUtils.resetGravity()
	end
end

function Camera.isLinked()
	return resolveCameraUtils() ~= nil
end

return Camera