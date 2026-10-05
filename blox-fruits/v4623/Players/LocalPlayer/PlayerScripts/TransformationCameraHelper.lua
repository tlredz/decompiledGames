local createVector = vector.create
local GuiService = game:GetService("GuiService")
local gamepadEnabled = GuiService:IsTenFootInterface()

if not gamepadEnabled then
	local UserInputService = game:GetService("UserInputService")
	gamepadEnabled = UserInputService.GamepadEnabled
end

local v = nil
local v2 = nil
local localPlayer = game.Players.LocalPlayer
local character = localPlayer.Character
local currentCamera = workspace.CurrentCamera
local humanoid = character and character:FindFirstChild("Humanoid")

if character and not humanoid then
	task.spawn(function()
		humanoid = character:WaitForChild("Humanoid")
		humanoid:SetAttribute("CameraOff", humanoid.CameraOffset)
	end)
end

local tweenZoom
local v3 = false
localPlayer.CharacterAdded:Connect(function(character2)
	character = character2
	humanoid = character:WaitForChild("Humanoid")
	humanoid:SetAttribute("CameraOff", humanoid.CameraOffset)
end)
local v4 = {
	GasRig = {
		Time = 0.25,
		MinZoom = 50,
		TargetZoom = 80,
		MaxZoom = 220,
		CameraOffset = createVector(0, 10, 0)
	},
	LeopardRig = {
		Time = 0.15,
		MinZoom = 10,
		TargetZoom = 30,
		MaxZoom = 220,
		CameraOffset = createVector(0, 4, 0)
	},
	YetiRig = {
		Time = 0.15,
		MinZoom = 20,
		TargetZoom = 40,
		MaxZoom = 220,
		CameraOffset = createVector(0, 4, 0)
	},
	TRex = {
		Time = 0.2,
		MinZoom = 20,
		TargetZoom = 40,
		MaxZoom = 220,
		CameraOffset = createVector(0, 8, 0)
	},
	Kitsune = {
		Time = 0.15,
		MinZoom = 20,
		TargetZoom = 40,
		MaxZoom = 220,
		CameraOffset = createVector(0, 3, 0)
	},
	Mammoth = {
		Time = 0.2,
		MinZoom = 30,
		TargetZoom = 80,
		MaxZoom = 220,
		CameraOffset = createVector(0, 0, 0)
	},
	Buddha = {
		Time = 0.2,
		MinZoom = 30,
		TargetZoom = 50,
		MaxZoom = 220,
		CameraOffset = createVector(0, 5, 0)
	},
	Buddha2 = {
		Time = 0.3,
		MinZoom = 60,
		TargetZoom = 80,
		MaxZoom = 220,
		CameraOffset = createVector(0, 8, 0)
	},
	Phoenix2 = {
		Time = 0.3,
		MinZoom = 30,
		TargetZoom = 40,
		MaxZoom = 220,
		CameraOffset = createVector(0, 4, 0)
	}
}

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local v5 = {
	CameraOffset = createVector(0, 0, 0),
	MinZoom = localPlayer.CameraMinZoomDistance,
	MaxZoom = localPlayer.CameraMaxZoomDistance,
	OriginalZoom = 0
}

-- equivalent calls inferred from this helper; original call sites unknown
local function returnToNormal()
	local v6 = v4[v3]

	if not v6 then
		return
	end

	if gamepadEnabled then
		task.spawn(tweenZoom, v5.MinZoom, v5.MaxZoom, v6.Time, v5.OriginalZoom)
	end

	task.spawn(adjustCameraOffset, humanoid:GetAttribute("CameraOff"), v6.Time)
end

local function transformed(p)
	local v6 = v4[p]

	if not v6 then
		return
	end

	if not (v or v2) then
		v5.OriginalZoom = (currentCamera.CFrame.Position - currentCamera.Focus.Position).Magnitude
	end

	if v3 then
		local Global = require(game.ReplicatedStorage.Global)
		Global.TestGameWarn("bug from /g or what.")
	end

	if gamepadEnabled then
		task.spawn(tweenZoom, v6.MinZoom, v6.MaxZoom, v6.Time, v6.TargetZoom or nil)
	end

	task.spawn(adjustCameraOffset, v6.CameraOffset, v6.Time)
	return p
end

function adjustCameraOffset(cameraOffset, p)
	local now = tick()
	v2 = now
	local cameraOffset2 = humanoid.CameraOffset
	local total = 0

	while total < p do
		total += task.wait()
		local _ = total / p

		if v2 ~= now then
			return
		end

		humanoid.CameraOffset = cameraOffset2:Lerp(cameraOffset, total / p)
	end

	humanoid.CameraOffset = cameraOffset
	v2 = nil
end

tweenZoom = function(cameraMinZoomDistance, cameraMaxZoomDistance, p, p2)
	local now = tick()
	v = now
	local magnitude = (currentCamera.CFrame.Position - currentCamera.Focus.Position).Magnitude
	local total = 0

	while total < p do
		total += task.wait()

		if v ~= now then
			return
		end

		local localPlayer2 = localPlayer
		local v7

		if p2 then
			v7 = p2 - 0.01 or cameraMinZoomDistance
		else
			v7 = cameraMinZoomDistance
		end

		local v8 = math.clamp(total / p, 0, 1)
		localPlayer2.CameraMinZoomDistance = magnitude + (v7 - magnitude) * v8
		local localPlayer3 = localPlayer
		local v10

		if p2 then
			v10 = p2 + 0.01 or cameraMaxZoomDistance
		else
			v10 = cameraMaxZoomDistance
		end

		local v11 = math.clamp(total / p, 0, 1)
		localPlayer3.CameraMaxZoomDistance = magnitude + (v10 - magnitude) * v11
	end

	task.wait()

	if p2 then
		local v6 = (currentCamera.CFrame.Position - currentCamera.Focus.Position).unit * p2
		currentCamera.CFrame = CFrame.lookAt(currentCamera.Focus.Position + v6, currentCamera.Focus.Position)
	end

	localPlayer.CameraMinZoomDistance = cameraMinZoomDistance
	localPlayer.CameraMaxZoomDistance = cameraMaxZoomDistance
	v = nil
end

local SharedSignals = require(game.ReplicatedStorage.SharedSignals)
SharedSignals.TransformationChanged():Connect(function(p)
	if p and not v3 then
		v3 = transformed(p)
	elseif not p and v3 then
		returnToNormal() -- equivalent call inferred; original call site unknown
		v3 = false
	end
end)