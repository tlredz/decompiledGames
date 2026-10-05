local _7Page = {}
local libraryNew = require(script.Parent.libraryNew)
local _ = libraryNew.PlayAttachment
local _ = libraryNew.Maid
local _ = libraryNew.PlayTween
local _ = libraryNew.CamShake
local _ = libraryNew.PlayFlipBook
local _ = libraryNew.dtwait
local _ = libraryNew.EFP
local _ = libraryNew.PlayMesh
local _ = libraryNew.Impact
local _ = libraryNew.GlassLight
local _ = libraryNew.RaiseZIndex
local _ = libraryNew.Able
local _ = libraryNew.LifeScale
local _ = libraryNew.QuickFX
local _ = libraryNew.QuickWeld
local _ = libraryNew.Yield
local _ = libraryNew.ProcessPart
local _ = libraryNew.WeldObject
local _ = libraryNew.Bezier
local class = {}
class.__index = class
Random.new()
game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
game:GetService("PhysicsService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local _ = game.Workspace.CurrentCamera
local MeshControl = require(script.Parent.MeshControl)
local thrown = workspace:FindFirstChild("Thrown") or workspace:FindFirstChild("Effects") or workspace
local vfx = script.vfx
local v = {}
local connections = {}
local v2 = {}
local threads = {}
local tweens = {}
local v3 = {}

local function delaytask(value, callback)
	local thread = nil
	thread = task.delay(value or 0, function()
		local index = table.find(threads, thread)

		if index then
			table.remove(threads, index)
		end

		callback()
	end)
	table.insert(threads, thread)
	return thread
end

-- equivalent calls inferred from this helper; original call sites unknown
local function spawntask(callback)
	local thread = nil
	thread = task.spawn(function()
		local index = table.find(threads, thread)

		if index then
			table.remove(threads, index)
		end

		callback()
	end)
	table.insert(threads, thread)
	return thread
end

local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {
	CameraBeam1 = {
		{
			LightEmission = 0
		},
		{
			LightEmission = 1
		}
	},
	CameraBeam2 = {
		{
			LightEmission = 0.25
		},
		{
			LightEmission = 1
		}
	},
	ShadowBeam1 = {
		{
			LightEmission = 1
		},
		{
			LightEmission = 0
		},
		{
			LightEmission = 0
		},
		{
			LightEmission = 0.786
		},
		{
			LightEmission = 1
		}
	},
	ShadowBeam2 = {
		{
			LightEmission = 1
		},
		{
			LightEmission = 0
		},
		{
			LightEmission = 0
		},
		{
			LightEmission = 0.786
		},
		{
			LightEmission = 1
		}
	},
	ShadowBeam3 = {
		{
			LightEmission = 1
		},
		{
			LightEmission = 0
		},
		{
			LightEmission = 0
		},
		{
			LightEmission = 0.786
		},
		{
			LightEmission = 1
		}
	},
	ColorCorrelation = {
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = 0,
			Contrast = 0,
			Saturation = 0
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = -0.5,
			Contrast = 0.2,
			Saturation = 0.25
		},
		{
			Brightness = 0.2
		},
		{
			Brightness = 0
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Contrast = 0.2,
			Saturation = 0.25
		},
		{
			Contrast = 555,
			Saturation = -1
		},
		{
			TintColor = Color3.fromRGB(11, 255, 0),
			Contrast = -21555
		},
		{
			Contrast = 25
		},
		{
			Contrast = -5
		},
		{
			TintColor = Color3.fromRGB(11, 255, 0),
			Contrast = 0.25,
			Saturation = -1
		},
		{
			Contrast = 0.2,
			Saturation = 0.25
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255)
		},
		{
			Brightness = 0
		},
		{
			Brightness = 0.2
		},
		{
			Brightness = 0.15
		},
		{
			Brightness = 0
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = 0,
			Contrast = 0.2,
			Saturation = 0.25
		},
		{
			TintColor = Color3.fromRGB(255, 213, 135),
			Brightness = 0.15,
			Contrast = 0.45,
			Saturation = 0.5
		},
		{
			TintColor = Color3.fromRGB(255, 213, 135)
		},
		{
			Contrast = 0,
			Saturation = 0.2
		},
		{
			Brightness = 0,
			Contrast = 0.2,
			Saturation = 0.5
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255)
		},
		{
			Brightness = -0.25
		},
		{
			Contrast = 0.8
		},
		{
			Brightness = -0.05
		},
		{
			Contrast = 0.8,
			Saturation = 0.5
		},
		{
			Brightness = 0
		},
		{
			Contrast = 0.2,
			Saturation = 0.5
		},
		{
			TintColor = Color3.fromRGB(255, 213, 135),
			Brightness = 0,
			Contrast = 0.2,
			Saturation = 0.5
		},
		{
			Contrast = 0.5,
			Saturation = 0.4
		},
		{
			Contrast = 0.5
		},
		{
			Contrast = 1,
			Saturation = 0.4
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = 0
		},
		{
			Contrast = 0.15,
			Saturation = 0.9
		},
		{
			Brightness = 0.5
		},
		{
			TintColor = Color3.fromRGB(255, 222, 157)
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255)
		},
		{
			Brightness = 0
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = 0,
			Contrast = 0.15,
			Saturation = 0.9
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = -0.005,
			Contrast = 0.7,
			Saturation = -0.7
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = -0.005,
			Contrast = 0.7,
			Saturation = -0.7
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = 0.35,
			Contrast = 0.15,
			Saturation = 0.4
		},
		{
			Contrast = 0.8
		},
		{
			Brightness = 0.35
		},
		{
			Brightness = -0.005
		},
		{
			Contrast = 0.25
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = -0.005,
			Contrast = 0.25,
			Saturation = 0.4
		},
		{
			TintColor = Color3.fromRGB(255, 255, 255),
			Brightness = 0,
			Contrast = 0,
			Saturation = 0
		}
	},
	WindBeam = {
		{
			TextureSpeed = 3
		},
		{
			TextureSpeed = 3
		},
		{
			TextureSpeed = 0
		}
	},
	WindBeam1 = {
		{
			TextureSpeed = 3
		},
		{
			TextureSpeed = 3
		},
		{
			TextureSpeed = 0
		}
	},
	WindBeam2 = {
		{
			TextureSpeed = 3
		},
		{
			TextureSpeed = 3
		},
		{
			TextureSpeed = 0
		}
	},
	WindBeam3 = {
		{
			TextureSpeed = 3
		},
		{
			TextureSpeed = 3
		},
		{
			TextureSpeed = 0
		}
	},
	WindBeam4 = {
		{
			TextureSpeed = 5
		},
		{
			TextureSpeed = 5
		},
		{
			TextureSpeed = 0
		}
	},
	WindBeam5 = {
		{
			TextureSpeed = 2.656
		},
		{
			TextureSpeed = 2.656
		},
		{
			TextureSpeed = 0
		}
	},
	WindBeam6 = {
		{
			TextureSpeed = 2.656
		},
		{
			TextureSpeed = 2.656
		},
		{
			TextureSpeed = 0
		}
	},
	WindBeam7 = {
		{
			TextureSpeed = 5
		},
		{
			TextureSpeed = 5
		},
		{
			TextureSpeed = 0
		}
	}
}
local v8 = {
	CameraBeam1 = { TweenInfo.new(3.966, Enum.EasingStyle.Linear), TweenInfo.new(4.783, Enum.EasingStyle.Linear) },
	CameraBeam2 = { TweenInfo.new(3.966, Enum.EasingStyle.Linear), TweenInfo.new(4.783, Enum.EasingStyle.Linear) },
	ShadowBeam1 = {
		TweenInfo.new(2.316, Enum.EasingStyle.Linear),
		TweenInfo.new(2.866, Enum.EasingStyle.Linear),
		TweenInfo.new(4.516, Enum.EasingStyle.Linear),
		TweenInfo.new(5, Enum.EasingStyle.Linear),
		TweenInfo.new(5.3, Enum.EasingStyle.Linear)
	},
	ShadowBeam2 = {
		TweenInfo.new(2.316, Enum.EasingStyle.Linear),
		TweenInfo.new(2.866, Enum.EasingStyle.Linear),
		TweenInfo.new(4.516, Enum.EasingStyle.Linear),
		TweenInfo.new(5, Enum.EasingStyle.Linear),
		TweenInfo.new(5.3, Enum.EasingStyle.Linear)
	},
	ShadowBeam3 = {
		TweenInfo.new(2.316, Enum.EasingStyle.Linear),
		TweenInfo.new(2.866, Enum.EasingStyle.Linear),
		TweenInfo.new(4.516, Enum.EasingStyle.Linear),
		TweenInfo.new(5, Enum.EasingStyle.Linear),
		TweenInfo.new(5.3, Enum.EasingStyle.Linear)
	},
	ColorCorrelation = {
		TweenInfo.new(0.583333, Enum.EasingStyle.Linear),
		TweenInfo.new(0.65, Enum.EasingStyle.Linear),
		TweenInfo.new(0.9, Enum.EasingStyle.Linear),
		TweenInfo.new(1.233, Enum.EasingStyle.Linear),
		TweenInfo.new(1.316, Enum.EasingStyle.Linear),
		TweenInfo.new(1.333, Enum.EasingStyle.Linear),
		TweenInfo.new(1.366, Enum.EasingStyle.Linear),
		TweenInfo.new(1.383, Enum.EasingStyle.Linear),
		TweenInfo.new(1.4, Enum.EasingStyle.Linear),
		TweenInfo.new(1.416, Enum.EasingStyle.Linear),
		TweenInfo.new(1.5, Enum.EasingStyle.Linear),
		TweenInfo.new(1.8166, Enum.EasingStyle.Linear),
		TweenInfo.new(1.866, Enum.EasingStyle.Linear),
		TweenInfo.new(2.383, Enum.EasingStyle.Linear),
		TweenInfo.new(2.65, Enum.EasingStyle.Linear),
		TweenInfo.new(3.45, Enum.EasingStyle.Linear),
		TweenInfo.new(3.55, Enum.EasingStyle.Linear),
		TweenInfo.new(3.766, Enum.EasingStyle.Linear),
		TweenInfo.new(4.0166, Enum.EasingStyle.Linear),
		TweenInfo.new(4.366, Enum.EasingStyle.Linear),
		TweenInfo.new(4.466, Enum.EasingStyle.Linear),
		TweenInfo.new(4.4833, Enum.EasingStyle.Linear),
		TweenInfo.new(4.516, Enum.EasingStyle.Linear),
		TweenInfo.new(4.5833, Enum.EasingStyle.Linear),
		TweenInfo.new(4.733, Enum.EasingStyle.Linear),
		TweenInfo.new(4.783, Enum.EasingStyle.Linear),
		TweenInfo.new(5, Enum.EasingStyle.Linear),
		TweenInfo.new(5.416, Enum.EasingStyle.Linear),
		TweenInfo.new(5.7, Enum.EasingStyle.Linear),
		TweenInfo.new(11.58, Enum.EasingStyle.Linear),
		TweenInfo.new(12.983, Enum.EasingStyle.Linear),
		TweenInfo.new(13.01, Enum.EasingStyle.Linear),
		TweenInfo.new(13.033, Enum.EasingStyle.Linear),
		TweenInfo.new(13.05, Enum.EasingStyle.Linear),
		TweenInfo.new(13.066, Enum.EasingStyle.Linear),
		TweenInfo.new(13.383, Enum.EasingStyle.Linear),
		TweenInfo.new(13.4166, Enum.EasingStyle.Linear),
		TweenInfo.new(14.6833, Enum.EasingStyle.Linear),
		TweenInfo.new(14.93, Enum.EasingStyle.Linear),
		TweenInfo.new(15.883, Enum.EasingStyle.Linear),
		TweenInfo.new(15.95, Enum.EasingStyle.Linear),
		TweenInfo.new(16.016, Enum.EasingStyle.Linear),
		TweenInfo.new(16.03, Enum.EasingStyle.Linear),
		TweenInfo.new(16.183, Enum.EasingStyle.Linear),
		TweenInfo.new(16.4, Enum.EasingStyle.Linear),
		TweenInfo.new(16.983, Enum.EasingStyle.Linear),
		TweenInfo.new(17.016, Enum.EasingStyle.Linear)
	},
	WindBeam = {
		TweenInfo.new(6.333, Enum.EasingStyle.Linear),
		TweenInfo.new(11.916, Enum.EasingStyle.Linear),
		TweenInfo.new(13.966, Enum.EasingStyle.Linear)
	},
	WindBeam1 = {
		TweenInfo.new(6.333, Enum.EasingStyle.Linear),
		TweenInfo.new(11.916, Enum.EasingStyle.Linear),
		TweenInfo.new(13.966, Enum.EasingStyle.Linear)
	},
	WindBeam2 = {
		TweenInfo.new(6.333, Enum.EasingStyle.Linear),
		TweenInfo.new(11.916, Enum.EasingStyle.Linear),
		TweenInfo.new(13.966, Enum.EasingStyle.Linear)
	},
	WindBeam3 = {
		TweenInfo.new(6.333, Enum.EasingStyle.Linear),
		TweenInfo.new(11.916, Enum.EasingStyle.Linear),
		TweenInfo.new(13.966, Enum.EasingStyle.Linear)
	},
	WindBeam4 = {
		TweenInfo.new(6.333, Enum.EasingStyle.Linear),
		TweenInfo.new(11.916, Enum.EasingStyle.Linear),
		TweenInfo.new(13.966, Enum.EasingStyle.Linear)
	},
	WindBeam5 = {
		TweenInfo.new(6.333, Enum.EasingStyle.Linear),
		TweenInfo.new(11.916, Enum.EasingStyle.Linear),
		TweenInfo.new(13.966, Enum.EasingStyle.Linear)
	},
	WindBeam6 = {
		TweenInfo.new(6.333, Enum.EasingStyle.Linear),
		TweenInfo.new(11.916, Enum.EasingStyle.Linear),
		TweenInfo.new(13.966, Enum.EasingStyle.Linear)
	},
	WindBeam7 = {
		TweenInfo.new(6.333, Enum.EasingStyle.Linear),
		TweenInfo.new(11.916, Enum.EasingStyle.Linear),
		TweenInfo.new(13.966, Enum.EasingStyle.Linear)
	}
}

function CreateWeld(part, p)
	local motor6D = Instance.new("Motor6D")
	motor6D.Part0 = part
	motor6D.Part1 = p
	motor6D.Parent = p
	return motor6D
end

local CreateTweenLoop

CreateTweenLoop = function(p, p2, value)
	if not v4[p2] then
		v4[p2] = 1
	end

	local v9 = value or 0
	local v10 = v4[p2]
	local v11 = v7[p2] and v7[p2][v10]
	local v12 = v8[p2] and v8[p2][v10]

	if v12 and v11 then
		if v[p2] then
			v[p2]:Disconnect()
		end

		local time = v12.Time
		local v13 = math.max(0, time - v9)
		local tween = TweenService:Create(
			p,
			TweenInfo.new(v13, v12.EasingStyle, v12.EasingDirection or Enum.EasingDirection.In),
			v11
		)
		table.insert(tweens, tween)
		tween:Play()
		v[p2] = tween.Completed:Connect(function()
			v[p2]:Disconnect()
			v[p2] = nil
			local index = table.find(tweens, tween)

			if index then
				table.remove(tweens, index)
			end

			tween:Destroy()
			v4[p2] = v10 + 1

			if v4[p2] > #v7[p2] then
				v4[p2] = 1
				v5[p2] = false
			end

			if v5[p2] then
				CreateTweenLoop(p, p2, time)
			end
		end)
	else
		v4[p2] = 1
		v5[p2] = false

		if v[p2] then
			v[p2]:Disconnect()
			v[p2] = nil
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StartTweenLoop(p, p2)
	if v[p2] then
		v[p2]:Disconnect()
		v[p2] = nil
	end

	v5[p2] = true
	v4[p2] = 1
	CreateTweenLoop(p, p2, 0)
end

local function CleanUp(instance, _)
	if not instance then
		return
	end

	local playerFromCharacter = Players:GetPlayerFromCharacter(instance)
	local v9 = playerFromCharacter == Players.LocalPlayer
	local currentCamera = workspace.CurrentCamera
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local playerGui = playerFromCharacter and playerFromCharacter:FindFirstChildOfClass("PlayerGui")

	for _, v10 in v do
		local connection = v10
		pcall(function()
			connection:Disconnect()
		end)
	end

	table.clear(v)

	for _, v10 in tweens do
		local v11 = v10
		pcall(function()
			v11:Cancel()
			v11:Destroy()
		end)
	end

	table.clear(tweens)
	local thread = coroutine.running()

	for _, v10 in threads do
		if not (v10 and v10 ~= thread) then
			continue
		end

		local v11 = v10
		pcall(function()
			task.cancel(v11)
		end)
	end

	table.clear(threads)

	for _, connection in connections do
		local connection2 = connection
		pcall(function()
			connection2:Disconnect()
		end)
	end

	table.clear(connections)

	for _, v10 in v3 do
		local v11 = v10
		pcall(function()
			v11:Stop(0)
			v11:Destroy()
		end)
	end

	table.clear(v3)
	table.clear(v4)
	table.clear(v5)
	table.clear(v6)

	if v9 and playerGui then
		if script:GetAttribute("PreviousClocktime") then
			Lighting.ClockTime = script:GetAttribute("PreviousClocktime")
			script:SetAttribute("PreviousClocktime", nil)
		end

		if script:GetAttribute("PreviousGeographicLatitude") then
			Lighting.GeographicLatitude = script:GetAttribute("PreviousGeographicLatitude")
			script:SetAttribute("PreviousGeographicLatitude", nil)
		end

		if script:GetAttribute("PreviousExposureCompensation") then
			Lighting.ExposureCompensation = script:GetAttribute("PreviousExposureCompensation")
			script:SetAttribute("PreviousExposureCompensation", nil)
		end

		if script:GetAttribute("OriginalFOV") then
			currentCamera.FieldOfView = script:GetAttribute("OriginalFOV")
			script:SetAttribute("OriginalFOV", nil)
		end
	end

	if humanoidRootPart then
		humanoidRootPart.Anchored = false
	end

	if humanoid then
		humanoid.WalkSpeed = 16
		humanoid.JumpHeight = 7.2
		humanoid.AutoRotate = true
	end

	for _, v10 in v2 do
		if not (v10 and v10.Parent) then
			continue
		end

		local v11 = v10
		pcall(function()
			v11:Destroy()
		end)
	end

	table.clear(v2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function LerpColor3(data, data2, p)
	return Color3.new(data.R + (data2.R - data.R) * p, data.G + (data2.G - data.G) * p, data.B + (data2.B - data.B) * p)
end

local function TweenScale(p: number, p2: number, data, instance)
	local v9 = 0
	local v10 = 0

	local function onStep(p3: number)
		v9 = math.min(v9 + p3, data.Time)
		v10 = p + TweenService:GetValue(v9 / data.Time, data.EasingStyle, data.EasingDirection) * (p2 - p)

		if v10 <= 0 then
			v10 = 0.00001
		end

		instance:ScaleTo(v10)
		local tweenScaleConnection = v9 == data.Time and connections.TweenScaleConnection

		if tweenScaleConnection then
			tweenScaleConnection:Disconnect()
			connections.TweenScaleConnection = nil
		end
	end

	connections.TweenScaleConnection = RunService.Heartbeat:Connect(onStep)
end

local function TweenBeamColor(p, p2, p3, p4, p5)
	local v9 = p4 / p5

	local function fn()
		for i = 1, p5 do
			local lerpColor3 = LerpColor3(p2, p3, i / p5) -- equivalent call inferred; original call site unknown
			p.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, lerpColor3),
				ColorSequenceKeypoint.new(1, lerpColor3)
			})
			task.wait(v9)
		end
	end

	spawntask(fn) -- equivalent call inferred; original call site unknown
end

local function TweenBeamColors(folder, color, color2)
	for _, beam in folder:GetDescendants() do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, color), ColorSequenceKeypoint.new(1, color) })
		local v11 = 2
		local v12 = beam
		local v13 = 0.5

		local function fn()
			for i = 1, v11 do
				local lerpColor3 = LerpColor3(color, color2, i / v11) -- equivalent call inferred; original call site unknown
				v12.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, lerpColor3),
					ColorSequenceKeypoint.new(1, lerpColor3)
				})
				task.wait(v13)
			end
		end

		local thread = nil
		thread = task.spawn(function()
			local index = table.find(threads, thread)

			if index then
				table.remove(threads, index)
			end

			fn()
		end)
		table.insert(threads, thread)
	end
end

local function ToggleVisiblity(folder, p, p2)
	local v9 = p2 == nil and {} or p2
	local transparency = p == false and 1 or 0

	for _, part in folder:GetDescendants() do
		if table.find(v9, part.Name) or not (part:IsA("MeshPart") or part:IsA("BasePart")) then
			continue
		end

		part.Transparency = transparency
	end
end

local function ApplySkinColor(folder, color)
	for _, part in folder:GetDescendants() do
		if not ((part:IsA("MeshPart") or part:IsA("BasePart")) and part:GetAttribute("SkinColor")) then
			continue
		end

		part.Color = color
	end
end

local function ApplyMeshEffects(folder)
	for _, model in folder:GetDescendants() do
		if model:IsA("Model") then
			MeshControl(model)
		end
	end
end

local function EmitEffects(folder)
	for _, emitter in folder:GetDescendants() do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		local emitDelay = emitter:GetAttribute("EmitDelay")
		local v9 = emitter

		local function fn()
			v9:Emit(v9:GetAttribute("EmitCount"))
		end

		local thread = nil
		thread = task.delay(emitDelay or 0, function()
			local index = table.find(threads, thread)

			if index then
				table.remove(threads, index)
			end

			fn()
		end)
		table.insert(threads, thread)
	end
end

local function ToggleEffects(folder, enabled)
	for _, descendant in folder:GetDescendants() do
		if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("Light") or descendant:IsA("Trail")) then
			continue
		end

		descendant.Enabled = enabled
	end
end

function _7Page.FirstEvent(data)
	local char = data.Char
	local targChar = data.targChar
	local playerFromCharacter = Players:GetPlayerFromCharacter(char)
	local playerFromCharacter2 = targChar and Players:GetPlayerFromCharacter(targChar)
	local localPlayer = Players.LocalPlayer
	CleanUp(char, true)
	CleanUp(targChar, true)
	script:SetAttribute("PreviousClocktime", Lighting.ClockTime)
	script:SetAttribute("PreviousGeographicLatitude", Lighting.GeographicLatitude)
	script:SetAttribute("PreviousExposureCompensation", Lighting.ExposureCompensation)
	local cleanupTable = data.CleanupTable
	local _ = data.RealAnim

	local function trackObject(instance)
		if not instance then
			return instance
		end

		table.insert(v2, instance)

		if cleanupTable then
			table.insert(cleanupTable, instance)
		end

		local function fn()
			if instance and instance.Parent then
				instance:Destroy()
			end
		end

		local thread = nil
		thread = task.delay(29, function()
			local index = table.find(threads, thread)

			if index then
				table.remove(threads, index)
			end

			fn()
		end)
		table.insert(threads, thread)
		return instance
	end

	local function trackAnimation(p)
		if p then
			table.insert(v3, p)
		end

		return p
	end

	local bind = data.Bind
	local v9 = false
	local colorCorrectionEffect = nil
	local flag = false

	local function fn()
		if flag then
			return
		end

		flag = true

		if colorCorrectionEffect then
			local TweenService2 = game:GetService("TweenService")
			TweenService2:Create(colorCorrectionEffect, TweenInfo.new(0.5), {
				Contrast = 0,
				Saturation = 0,
				Brightness = 0,
				TintColor = Color3.fromRGB(255, 255, 255)
			}):Play()
			game.Debris:AddItem(colorCorrectionEffect, 0.6)
		end
	end

	local cameraRig25 = nil
	connections.cleanup = bind:GetPropertyChangedSignal("Parent"):Connect(function()
		if not (bind and bind.Parent) then
			v9 = true

			if cameraRig25 then
				cameraRig25:Destroy()
			end

			if colorCorrectionEffect then
				fn()
			end

			CleanUp(char)
			CleanUp(targChar)
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function fn2()
		fn()
		CleanUp(char)
		CleanUp(targChar)
	end

	local thread = nil
	thread = task.delay(29, function()
		local index = table.find(threads, thread)

		if index then
			table.remove(threads, index)
		end

		fn2()
	end)
	table.insert(threads, thread)
	local v10 = playerFromCharacter == localPlayer
	local v11 = localPlayer == playerFromCharacter2
	local _ = workspace.CurrentCamera

	if playerFromCharacter then
		playerFromCharacter:FindFirstChildOfClass("PlayerGui")
	end

	localPlayer:FindFirstChildOfClass("PlayerGui")

	local function firstEvent()
		local DELAY_DURATION = 29

		if v10 or v11 then
			cameraRig25 = char:WaitForChild("CameraRig25", 2)
		end

		local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")
		char:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator")
		char:FindFirstChild("Left Arm")
		char:FindFirstChild("Right Arm")
		char:FindFirstChild("Left Leg")
		char:FindFirstChild("Right Leg")
		local head = char:FindFirstChild("Head")
		char:FindFirstChild("Torso")
		targChar:FindFirstChild("HumanoidRootPart")
		targChar:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator")

		if v10 or v11 then
			colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
			colorCorrectionEffect.Parent = Lighting
			v5.ColorCorrelation = true
			StartTweenLoop(colorCorrectionEffect, "ColorCorrelation") -- equivalent call inferred; original call site unknown
		end

		connections.ChildAdded = char.ChildAdded:Connect(function(child)
			if child.Name == "Freeze" then
				fn2() -- equivalent call inferred; original call site unknown
			end
		end)
		local clone = vfx.Fx:Clone()
		clone:PivotTo(humanoidRootPart.CFrame * (CFrame.new(0, 15.55, -7.3) * CFrame.Angles(0, 1.2271060904921733, 0)))
		clone.Parent = thrown

		-- equivalent calls inferred from this helper; original call sites unknown
		local function fn3()
			if clone and clone.Parent then
				clone:Destroy()
			end
		end

		local thread2 = nil
		thread2 = task.delay(DELAY_DURATION, function()
			local index = table.find(threads, thread2)

			if index then
				table.remove(threads, index)
			end

			fn3()
		end)
		table.insert(threads, thread2)

		if clone then
			table.insert(v2, clone)

			if cleanupTable then
				table.insert(cleanupTable, clone)
			end

			local function fn4()
				fn3() -- equivalent call inferred; original call site unknown
			end

			local thread3 = nil
			thread3 = task.delay(DELAY_DURATION, function()
				local index = table.find(threads, thread3)

				if index then
					table.remove(threads, index)
				end

				fn4()
			end)
			table.insert(threads, thread3)
		end

		for _, child in vfx.HeadEffects:GetChildren() do
			local clone2 = child:Clone()
			clone2.Parent = head

			if not clone2 then
				continue
			end

			table.insert(v2, clone2)

			if cleanupTable then
				table.insert(cleanupTable, clone2)
			end

			local v12 = clone2

			local function fn4()
				if v12 and v12.Parent then
					v12:Destroy()
				end
			end

			local thread3 = nil
			thread3 = task.delay(DELAY_DURATION, function()
				local index = table.find(threads, thread3)

				if index then
					table.remove(threads, index)
				end

				fn4()
			end)
			table.insert(threads, thread3)
		end

		local v12 = threads

		local function fn4()
			local v13

			if not v10 then
				v13 = false
			end

			if not (v13 and cameraRig25) then
				return
			end

			EmitEffects(cameraRig25.CamPart.Fx.Emit1)
		end

		local thread3 = nil
		thread3 = task.delay(1.8, function()
			local index = table.find(threads, thread3)

			if index then
				table.remove(threads, index)
			end

			fn4()
		end)
		table.insert(threads, thread3)
		v12.CameraEmit1 = thread3
		local v13 = threads

		local function fn5()
			local v14

			if not v10 then
				v14 = false
			end

			if not (v14 and cameraRig25) then
				return
			end

			ToggleEffects(cameraRig25.CamPart.LinesScreen, true)
		end

		local thread4 = nil
		thread4 = task.delay(3.233, function()
			local index = table.find(threads, thread4)

			if index then
				table.remove(threads, index)
			end

			fn5()
		end)
		table.insert(threads, thread4)
		v13.CameraEmit2 = thread4
		local v14 = threads

		local function fn6()
			ApplyMeshEffects(clone.Mesh.Punch)
			local v15

			if not v10 then
				v15 = false
			end

			if not (v15 and cameraRig25) then
				return
			end

			ToggleEffects(cameraRig25.CamPart.LinesScreen, false)
		end

		local thread5 = nil
		thread5 = task.delay(3.566, function()
			local index = table.find(threads, thread5)

			if index then
				table.remove(threads, index)
			end

			fn6()
		end)
		table.insert(threads, thread5)
		v14.CameraEmit3 = thread5
		local v15 = threads

		local function fn7()
			local v16

			if not v10 then
				v16 = false
			end

			if not (v16 and cameraRig25) then
				return
			end

			ToggleEffects(cameraRig25.CamPart.LinesScreen, true)
		end

		local thread6 = nil
		thread6 = task.delay(4.1166, function()
			local index = table.find(threads, thread6)

			if index then
				table.remove(threads, index)
			end

			fn7()
		end)
		table.insert(threads, thread6)
		v15.CameraEmit4 = thread6
		local v16 = threads

		local function fn8()
			local v17

			if not v10 then
				v17 = false
			end

			if not (v17 and cameraRig25) then
				return
			end

			ToggleEffects(cameraRig25.CamPart.TextBeam.M1, true)
		end

		local thread7 = nil
		thread7 = task.delay(4.45, function()
			local index = table.find(threads, thread7)

			if index then
				table.remove(threads, index)
			end

			fn8()
		end)
		table.insert(threads, thread7)
		v16.CameraEmit5 = thread7
		local v17 = threads

		local function fn9()
			EmitEffects(clone.TextFx)

			if cameraRig25 then
			end
		end

		local thread8 = nil
		thread8 = task.delay(4.55, function()
			local index = table.find(threads, thread8)

			if index then
				table.remove(threads, index)
			end

			fn9()
		end)
		table.insert(threads, thread8)
		v17.CameraEmit6 = thread8
		local v18 = threads

		local function fn10()
			if not cameraRig25 then
				return
			end

			ToggleEffects(cameraRig25.CamPart.LinesScreen, false)
		end

		local thread9 = nil
		thread9 = task.delay(4.683, function()
			local index = table.find(threads, thread9)

			if index then
				table.remove(threads, index)
			end

			fn10()
		end)
		table.insert(threads, thread9)
		v18.CameraEmit7 = thread9
		local v19 = threads

		local function fn11()
			if not cameraRig25 then
				return
			end

			ToggleEffects(cameraRig25.CamPart.TextBeam.M1, false)
			ToggleEffects(cameraRig25.CamPart.Beams.M1, false)
		end

		local thread10 = nil
		thread10 = task.delay(5.1, function()
			local index = table.find(threads, thread10)

			if index then
				table.remove(threads, index)
			end

			fn11()
		end)
		table.insert(threads, thread10)
		v19.CameraEmit8 = thread10
		local v20 = threads

		local function fn12()
			if not cameraRig25 then
				return
			end

			ToggleEffects(cameraRig25.CamPart.Fx.Enable1, true)
			ToggleEffects(cameraRig25.CamPart.TextScreen, true)
		end

		local thread11 = nil
		thread11 = task.delay(6.033, function()
			local index = table.find(threads, thread11)

			if index then
				table.remove(threads, index)
			end

			fn12()
		end)
		table.insert(threads, thread11)
		v20.CameraEmit9 = thread11
		local v21 = threads

		local function fn13()
			if not cameraRig25 then
				return
			end

			ToggleEffects(cameraRig25.CamPart.LinesScreen1, true)
		end

		local thread12 = nil
		thread12 = task.delay(8.8, function()
			local index = table.find(threads, thread12)

			if index then
				table.remove(threads, index)
			end

			fn13()
		end)
		table.insert(threads, thread12)
		v21.CameraEmit10 = thread12
		local v22 = threads

		local function fn14()
			if not cameraRig25 then
				return
			end

			ToggleEffects(cameraRig25.CamPart.LinesScreen1, false)
		end

		local thread13 = nil
		thread13 = task.delay(8.933, function()
			local index = table.find(threads, thread13)

			if index then
				table.remove(threads, index)
			end

			fn14()
		end)
		table.insert(threads, thread13)
		v22.CameraEmit11 = thread13
		local v23 = threads

		local function fn15()
			if not cameraRig25 then
				return
			end

			ToggleEffects(cameraRig25.CamPart.LinesScreen1, true)
		end

		local thread14 = nil
		thread14 = task.delay(9.85, function()
			local index = table.find(threads, thread14)

			if index then
				table.remove(threads, index)
			end

			fn15()
		end)
		table.insert(threads, thread14)
		v23.CameraEmit12 = thread14
		local v24 = threads

		local function fn16()
			if not cameraRig25 then
				return
			end

			ToggleEffects(cameraRig25.CamPart.LinesScreen1, false)
		end

		local thread15 = nil
		thread15 = task.delay(10.0166, function()
			local index = table.find(threads, thread15)

			if index then
				table.remove(threads, index)
			end

			fn16()
		end)
		table.insert(threads, thread15)
		v24.CameraEmit13 = thread15
		local v25 = threads

		local function fn17()
			ToggleEffects(clone.HandFx, true)

			if not cameraRig25 then
				return
			end

			ToggleEffects(cameraRig25.CamPart.LinesScreen1, true)
		end

		local thread16 = nil
		thread16 = task.delay(11.33, function()
			local index = table.find(threads, thread16)

			if index then
				table.remove(threads, index)
			end

			fn17()
		end)
		table.insert(threads, thread16)
		v25.CameraEmit14 = thread16
		local v26 = threads

		local function fn18()
			if not cameraRig25 then
				return
			end

			ToggleEffects(cameraRig25.CamPart.LinesScreen1, false)
		end

		local thread17 = nil
		thread17 = task.delay(11.5, function()
			local index = table.find(threads, thread17)

			if index then
				table.remove(threads, index)
			end

			fn18()
		end)
		table.insert(threads, thread17)
		v26.CameraEmit15 = thread17
		local v27 = threads

		local function fn19()
			if not cameraRig25 then
				return
			end

			ToggleEffects(cameraRig25.CamPart.TextScreen, false)
		end

		local thread18 = nil
		thread18 = task.delay(12.73, function()
			local index = table.find(threads, thread18)

			if index then
				table.remove(threads, index)
			end

			fn19()
		end)
		table.insert(threads, thread18)
		v27.CameraEmit16 = thread18
		local v28 = threads

		local function fn20()
			ToggleEffects(clone.HandFx, false)

			if not cameraRig25 then
				return
			end

			ToggleEffects(cameraRig25.CamPart.LinesScreen1, true)
		end

		local thread19 = nil
		thread19 = task.delay(13, function()
			local index = table.find(threads, thread19)

			if index then
				table.remove(threads, index)
			end

			fn20()
		end)
		table.insert(threads, thread19)
		v28.CameraEmit17 = thread19
		local v29 = threads

		local function fn21()
			if not cameraRig25 then
				return
			end

			ToggleEffects(cameraRig25.CamPart.LinesScreen1, false)
			ToggleEffects(cameraRig25.CamPart.Fx.Enable1, false)
			ToggleEffects(cameraRig25.CamPart.Beams.M3, false)
			ToggleEffects(cameraRig25.CamPart.Beams.M2, false)
			ToggleEffects(cameraRig25.CamPart.LinesScreen, true)
		end

		local thread20 = nil
		thread20 = task.delay(13.166, function()
			local index = table.find(threads, thread20)

			if index then
				table.remove(threads, index)
			end

			fn21()
		end)
		table.insert(threads, thread20)
		v29.CameraEmit18 = thread20
		local v30 = threads

		local function fn22()
			if not cameraRig25 then
				return
			end

			EmitEffects(cameraRig25.CamPart.Fx.Emit11)
		end

		local thread21 = nil
		thread21 = task.delay(13.4833, function()
			local index = table.find(threads, thread21)

			if index then
				table.remove(threads, index)
			end

			fn22()
		end)
		table.insert(threads, thread21)
		v30.CameraEmit19 = thread21
		local v31 = threads

		local function fn23()
			if cameraRig25 then
			end
		end

		local thread22 = nil
		thread22 = task.delay(13.716, function()
			local index = table.find(threads, thread22)

			if index then
				table.remove(threads, index)
			end

			fn23()
		end)
		table.insert(threads, thread22)
		v31.CameraEmit20 = thread22
		local v32 = threads

		local function fn24()
			if not cameraRig25 then
				return
			end

			EmitEffects(cameraRig25.CamPart.Fx.Emit6)
		end

		local thread23 = nil
		thread23 = task.delay(14.283, function()
			local index = table.find(threads, thread23)

			if index then
				table.remove(threads, index)
			end

			fn24()
		end)
		table.insert(threads, thread23)
		v32.CameraEmit21 = thread23
		local v33 = threads

		local function fn25()
			if not cameraRig25 then
				return
			end

			EmitEffects(cameraRig25.CamPart.Fx.Emit6)
		end

		local thread24 = nil
		thread24 = task.delay(14.283, function()
			local index = table.find(threads, thread24)

			if index then
				table.remove(threads, index)
			end

			fn25()
		end)
		table.insert(threads, thread24)
		v33.CameraEmit22 = thread24
		local v34 = threads

		local function fn26()
			if not cameraRig25 then
				return
			end

			EmitEffects(cameraRig25.CamPart.Fx.Emit0)
		end

		local thread25 = nil
		thread25 = task.delay(14.45, function()
			local index = table.find(threads, thread25)

			if index then
				table.remove(threads, index)
			end

			fn26()
		end)
		table.insert(threads, thread25)
		v34.CameraEmit23 = thread25
		local v35 = threads

		local function fn27()
			if not cameraRig25 then
				return
			end

			ToggleEffects(cameraRig25.CamPart.Beams.M4, false)
		end

		local thread26 = nil
		thread26 = task.delay(14.9, function()
			local index = table.find(threads, thread26)

			if index then
				table.remove(threads, index)
			end

			fn27()
		end)
		table.insert(threads, thread26)
		v35.CameraEmit24 = thread26
		local v36 = threads

		local function fn28()
			if cameraRig25 then
			end
		end

		local thread27 = nil
		thread27 = task.delay(15.65, function()
			local index = table.find(threads, thread27)

			if index then
				table.remove(threads, index)
			end

			fn28()
		end)
		table.insert(threads, thread27)
		v36.CameraEmit25 = thread27
		local v37 = threads

		local function fn29()
			if cameraRig25 then
			end
		end

		local thread28 = nil
		thread28 = task.delay(15.95, function()
			local index = table.find(threads, thread28)

			if index then
				table.remove(threads, index)
			end

			fn29()
		end)
		table.insert(threads, thread28)
		v37.CameraEmit26 = thread28
		local v38 = threads

		local function fn30()
			if not cameraRig25 then
				return
			end

			ToggleEffects(cameraRig25.CamPart.LinesScreen, false)
			ToggleEffects(cameraRig25.CamPart.Beams.M4, false)
			ToggleEffects(cameraRig25.CamPart.Beams.M6, false)
		end

		local thread29 = nil
		thread29 = task.delay(15.95, function()
			local index = table.find(threads, thread29)

			if index then
				table.remove(threads, index)
			end

			fn30()
		end)
		table.insert(threads, thread29)
		v38.CameraEmit27 = thread29
		local v39 = threads

		local function fn31()
			EmitEffects(clone.SummonFx)
			ApplyMeshEffects(clone.Mesh.Summon)
		end

		local thread30 = nil
		thread30 = task.delay(0.55, function()
			local index = table.find(threads, thread30)

			if index then
				table.remove(threads, index)
			end

			fn31()
		end)
		table.insert(threads, thread30)
		v39.EffectEmit1 = thread30
		local v40 = threads

		local function fn32()
			EmitEffects(clone.SlamFx)
			ApplyMeshEffects(clone.Mesh.Tree)
		end

		local thread31 = nil
		thread31 = task.delay(1.166, function()
			local index = table.find(threads, thread31)

			if index then
				table.remove(threads, index)
			end

			fn32()
		end)
		table.insert(threads, thread31)
		v40.EffectEmit2 = thread31
		local v41 = threads

		local function fn33()
			if cameraRig25 then
			end
		end

		local thread32 = nil
		thread32 = task.delay(1.3333, function()
			local index = table.find(threads, thread32)

			if index then
				table.remove(threads, index)
			end

			fn33()
		end)
		table.insert(threads, thread32)
		v41.EffectEmit3 = thread32
		local v42 = threads

		local function fn34()
			if not cameraRig25 then
				return
			end

			EmitEffects(cameraRig25.CamPart.Fx.Emit4)
		end

		local thread33 = nil
		thread33 = task.delay(3.4333, function()
			local index = table.find(threads, thread33)

			if index then
				table.remove(threads, index)
			end

			fn34()
		end)
		table.insert(threads, thread33)
		v42.EffectEmit4 = thread33
		local v43 = threads

		local function fn35()
			if cameraRig25 then
			end
		end

		local thread34 = nil
		thread34 = task.delay(3.5166, function()
			local index = table.find(threads, thread34)

			if index then
				table.remove(threads, index)
			end

			fn35()
		end)
		table.insert(threads, thread34)
		v43.EffectEmit5 = thread34
		local v44 = threads

		local function fn36()
			EmitEffects(clone.Muda1Fx)

			if not cameraRig25 then
				return
			end

			ToggleEffects(cameraRig25.CamPart.Beams.M5, false)
		end

		local thread35 = nil
		thread35 = task.delay(3.56666, function()
			local index = table.find(threads, thread35)

			if index then
				table.remove(threads, index)
			end

			fn36()
		end)
		table.insert(threads, thread35)
		v44.EffectEmit6 = thread35
		local v45 = threads

		local function fn37()
			for i, beam in clone.Hit.BeamsSlash:GetDescendants() do
				if not beam:IsA("Beam") then
					continue
				end

				beam.Enabled = true
				beam.Width0 = 15
				beam.Width1 = 6
				local tween = TweenService:Create(
					beam,
					TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Width0 = 0,
						Width1 = 0
					}
				)
				table.insert(tweens, tween)
				tween:Play()
				local v46 = threads
				local v47 = "BeamDelay" .. tostring(i)

				local function fn38()
					tween:Destroy()
				end

				local thread36 = nil
				thread36 = task.delay(0.2, function()
					local index = table.find(threads, thread36)

					if index then
						table.remove(threads, index)
					end

					fn38()
				end)
				table.insert(threads, thread36)
				v46[v47] = thread36
			end
		end

		local thread36 = nil
		thread36 = task.delay(3.6166, function()
			local index = table.find(threads, thread36)

			if index then
				table.remove(threads, index)
			end

			fn37()
		end)
		table.insert(threads, thread36)
		v45.EffectEmit7 = thread36
		local v46 = threads

		local function fn38()
			if not cameraRig25 then
				return
			end

			ToggleEffects(cameraRig25.CamPart.Beams.M0, false)
		end

		local thread37 = nil
		thread37 = task.delay(4.9, function()
			local index = table.find(threads, thread37)

			if index then
				table.remove(threads, index)
			end

			fn38()
		end)
		table.insert(threads, thread37)
		v46.EffectEmit8 = thread37
		local v47 = threads

		local function fn39()
			EmitEffects(clone.SymbolFx)
		end

		local thread38 = nil
		thread38 = task.delay(5.15, function()
			local index = table.find(threads, thread38)

			if index then
				table.remove(threads, index)
			end

			fn39()
		end)
		table.insert(threads, thread38)
		v47.EffectEmit9 = thread38
		local v48 = threads

		local function fn40()
			EmitEffects(clone.Muda2Fx)
		end

		local thread39 = nil
		thread39 = task.delay(5.5833, function()
			local index = table.find(threads, thread39)

			if index then
				table.remove(threads, index)
			end

			fn40()
		end)
		table.insert(threads, thread39)
		v48.EffectEmit10 = thread39
		local v49 = threads

		local function fn41()
			ToggleEffects(clone.BarrageFx, true)
		end

		local thread40 = nil
		thread40 = task.delay(6.0166, function()
			local index = table.find(threads, thread40)

			if index then
				table.remove(threads, index)
			end

			fn41()
		end)
		table.insert(threads, thread40)
		v49.EffectEmit11 = thread40
		local v50 = threads

		local function fn42()
			ToggleEffects(clone.BarrageFx, false)
		end

		local thread41 = nil
		thread41 = task.delay(13.033, function()
			local index = table.find(threads, thread41)

			if index then
				table.remove(threads, index)
			end

			fn42()
		end)
		table.insert(threads, thread41)
		v50.EffectEmit12 = thread41
		local v51 = threads

		local function fn43()
			EmitEffects(clone.TextFx)
		end

		local thread42 = nil
		thread42 = task.delay(14.4, function()
			local index = table.find(threads, thread42)

			if index then
				table.remove(threads, index)
			end

			fn43()
		end)
		table.insert(threads, thread42)
		v51.EffectEmit13 = thread42
		local v52 = threads

		local function fn44()
			warn("ye")
			EmitEffects(clone.LastSceneFx.Fly)
		end

		local thread43 = nil
		thread43 = task.delay(14.833, function()
			local index = table.find(threads, thread43)

			if index then
				table.remove(threads, index)
			end

			fn44()
		end)
		table.insert(threads, thread43)
		v52.EffectEmit14 = thread43
		local v53 = threads

		local function fn45()
			for i, emitter in clone.LastSceneFx.Hit:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
				emitter.TimeScale = 1
				local tween = TweenService:Create(
					emitter,
					TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						TimeScale = 0.03
					}
				)
				table.insert(tweens, tween)
				tween:Play()
				local v54 = threads
				local v55 = "ParticleDelay" .. tostring(i)

				local function fn46()
					tween:Destroy()
				end

				local thread44 = nil
				thread44 = task.delay(0.4, function()
					local index = table.find(threads, thread44)

					if index then
						table.remove(threads, index)
					end

					fn46()
				end)
				table.insert(threads, thread44)
				v54[v55] = thread44
			end
		end

		local thread44 = nil
		thread44 = task.delay(15.933, function()
			local index = table.find(threads, thread44)

			if index then
				table.remove(threads, index)
			end

			fn45()
		end)
		table.insert(threads, thread44)
		v53.EffectEmit15 = thread44
		local v54 = threads

		local function fn46()
			local function fn47()
				local folder = char:FindFirstChild("StandClone" .. tostring(playerFromCharacter.UserId))

				if folder then
					local count = 0
					local parts = {}

					for _, part in ipairs(folder:GetDescendants()) do
						if not part:IsA("BasePart") or part.Name == "HumanoidRootPart" or not (part.Transparency < 1) or part.Name:find("Hitbox") then
							continue
						end

						count += 1
						parts[count] = part
					end

					local function fn48()
						for i = 1, 6 do
							task.wait(0.03916666666666666)

							if not (folder and folder.Parent) then
								break
							end

							local localTransparencyModifier = i * 0.16666666666666666

							for i2 = 1, count do
								if parts[i2] and parts[i2].Parent then
									parts[i2].LocalTransparencyModifier = localTransparencyModifier
								end
							end
						end
					end

					local thread45 = nil
					thread45 = task.spawn(function()
						local index = table.find(threads, thread45)

						if index then
							table.remove(threads, index)
						end

						fn48()
					end)
					table.insert(threads, thread45)
				end
			end

			local thread45 = nil
			thread45 = task.delay(0.6, function()
				local index = table.find(threads, thread45)

				if index then
					table.remove(threads, index)
				end

				fn47()
			end)
			table.insert(threads, thread45)
			task.wait(0.5)

			for i, emitter in clone.LastSceneFx.Hit:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
				emitter.TimeScale = 1
				local tween = TweenService:Create(
					emitter,
					TweenInfo.new(0.001, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
					{
						TimeScale = 1
					}
				)
				table.insert(tweens, tween)
				tween:Play()
				local v55 = threads
				local v56 = "ParticleDelay|A" .. tostring(i)

				local function fn48()
					tween:Destroy()
				end

				local thread46 = nil
				thread46 = task.delay(0.001, function()
					local index = table.find(threads, thread46)

					if index then
						table.remove(threads, index)
					end

					fn48()
				end)
				table.insert(threads, thread46)
				v55[v56] = thread46
			end

			local clone2 = vfx.last:Clone()
			game.Debris:AddItem(clone2, 5)
			clone2:PivotTo(char:GetPivot() * clone2:GetAttribute("Offset"):Inverse())
			clone2.Parent = game.Workspace.Thrown
			shared.vfx.emit(clone2)
		end

		local thread45 = nil
		thread45 = task.delay(16.55, function()
			local index = table.find(threads, thread45)

			if index then
				table.remove(threads, index)
			end

			fn46()
		end)
		table.insert(threads, thread45)
		v54.EffectEmit16 = thread45
		local v55 = threads

		local function fn47()
			if cameraRig25 then
				for _, beam in cameraRig25.CamPart:GetChildren() do
					if beam:IsA("Beam") then
						TweenBeamColors(beam, Color3.fromRGB(0, 0, 0), Color3.fromRGB(90, 90, 90), 0.25, 10)
					end
				end
			end

			task.wait(1.8)

			if cameraRig25 then
				for _, beam in cameraRig25.CamPart:GetChildren() do
					if beam:IsA("Beam") then
						TweenBeamColors(beam, Color3.fromRGB(90, 90, 90), Color3.fromRGB(0, 0, 0), 0.1833, 10)
					end
				end
			end

			task.wait(0.4)

			if cameraRig25 then
				for _, beam in cameraRig25.CamPart:GetChildren() do
					if beam:IsA("Beam") then
						TweenBeamColors(beam, Color3.fromRGB(0, 0, 0), Color3.fromRGB(255, 255, 255), 0.0833, 10)
					end
				end
			end

			task.wait(0.85)

			if cameraRig25 then
				for _, beam in cameraRig25.CamPart:GetChildren() do
					if beam:IsA("Beam") then
						TweenBeamColors(beam, Color3.fromRGB(255, 255, 255), Color3.fromRGB(0, 0, 0), 0.1, 10)
					end
				end
			end
		end

		local thread46 = nil
		thread46 = task.delay(13.266, function()
			local index = table.find(threads, thread46)

			if index then
				table.remove(threads, index)
			end

			fn47()
		end)
		table.insert(threads, thread46)
		v55.BeamColors = thread46

		if v10 and v11 and cameraRig25 then
			for i, beam in cameraRig25.CamPart:GetDescendants() do
				if not beam:IsA("Beam") then
					continue
				end

				beam.Enabled = false
				local v56 = beam
				connections["BeamChanged" .. tostring(i)] = beam:GetPropertyChangedSignal("Enabled"):Connect(function()
					if v56.Enabled == true then
						v56.Enabled = false
					end
				end)
			end
		end

		local v56 = threads

		local function fn48()
			if cameraRig25 then
				cameraRig25.CamPart.Specs.Enabled = true
				cameraRig25.CamPart.Specs1.Enabled = true
				cameraRig25.CamPart.Specs2.Enabled = true
			end

			task.wait(11.85)

			if cameraRig25 then
				cameraRig25.CamPart.Specs.Enabled = false
				cameraRig25.CamPart.Specs1.Enabled = false
				cameraRig25.CamPart.Specs2.Enabled = false
			end
		end

		local thread47 = nil
		thread47 = task.delay(1.033, function()
			local index = table.find(threads, thread47)

			if index then
				table.remove(threads, index)
			end

			fn48()
		end)
		table.insert(threads, thread47)
		v56.DesignatedEnable = thread47
		local v57 = threads

		local function fn49()
			for _, beam in clone.BarrageFx.WindBeams:GetChildren() do
				if beam:IsA("Beam") then
					TweenBeamColors(beam, Color3.fromRGB(0, 0, 0), Color3.fromRGB(124, 124, 124), 0.2833, 10)
				end
			end

			task.wait(5.3)

			for _, beam in clone.BarrageFx.WindBeams:GetChildren() do
				if beam:IsA("Beam") then
					TweenBeamColors(beam, Color3.fromRGB(124, 124, 124), Color3.fromRGB(0, 0, 0), 1.9666, 10)
				end
			end
		end

		local thread48 = nil
		thread48 = task.delay(6.333, function()
			local index = table.find(threads, thread48)

			if index then
				table.remove(threads, index)
			end

			fn49()
		end)
		table.insert(threads, thread48)
		v57.WindBeamColors = thread48
		local v58 = threads

		local function fn50()
			if cameraRig25 then
				TweenBeamColors(
					cameraRig25.CamPart.Beams.M0.Beam3,
					Color3.fromRGB(22, 25, 31),
					Color3.fromRGB(0, 0, 0),
					0.81666,
					10
				)
				TweenBeamColors(
					cameraRig25.CamPart.Beams.M0.Beam2,
					Color3.fromRGB(255, 192, 103),
					Color3.fromRGB(0, 0, 0),
					0.81666,
					10
				)
				TweenBeamColors(
					cameraRig25.CamPart.Beams.M0.Beam1,
					Color3.fromRGB(255, 189, 76),
					Color3.fromRGB(0, 0, 0),
					0.81666,
					10
				)
			end
		end

		local thread49 = nil
		thread49 = task.delay(3.966, function()
			local index = table.find(threads, thread49)

			if index then
				table.remove(threads, index)
			end

			fn50()
		end)
		table.insert(threads, thread49)
		v58.CameraBeamColors = thread49

		if cameraRig25 then
			v5.CameraBeam1 = true
			StartTweenLoop(cameraRig25.CamPart.Beams.M0.Beam3, "CameraBeam1") -- equivalent call inferred; original call site unknown
			v5.CameraBeam2 = true
			StartTweenLoop(cameraRig25.CamPart.Beams.M0.Beam0, "CameraBeam2") -- equivalent call inferred; original call site unknown
			v5.ShadowBeam1 = true
			StartTweenLoop(head.ShadowBeams.B.Beam, "ShadowBeam1") -- equivalent call inferred; original call site unknown
			v5.ShadowBeam2 = true
			StartTweenLoop(head.ShadowBeams.A.Beam, "ShadowBeam2") -- equivalent call inferred; original call site unknown
			v5.ShadowBeam3 = true
			StartTweenLoop(head.ShadowBeams.A.Beam1, "ShadowBeam3") -- equivalent call inferred; original call site unknown
			v5.WindBeam = true
			StartTweenLoop(clone.BarrageFx.WindBeams.Wind, "WindBeam") -- equivalent call inferred; original call site unknown
			v5.WindBeam1 = true
			StartTweenLoop(clone.BarrageFx.WindBeams.Wind1, "WindBeam1") -- equivalent call inferred; original call site unknown
			v5.WindBeam2 = true
			StartTweenLoop(clone.BarrageFx.WindBeams.Wind2, "WindBeam2") -- equivalent call inferred; original call site unknown
			v5.WindBeam3 = true
			StartTweenLoop(clone.BarrageFx.WindBeams.Wind3, "WindBeam3") -- equivalent call inferred; original call site unknown
			v5.WindBeam4 = true
			StartTweenLoop(clone.BarrageFx.WindBeams.Wind4, "WindBeam4") -- equivalent call inferred; original call site unknown
			v5.WindBeam5 = true
			StartTweenLoop(clone.BarrageFx.WindBeams.Wind5, "WindBeam5") -- equivalent call inferred; original call site unknown
			v5.WindBeam6 = true
			StartTweenLoop(clone.BarrageFx.WindBeams.Wind6, "WindBeam6") -- equivalent call inferred; original call site unknown
			v5.WindBeam7 = true
			StartTweenLoop(clone.BarrageFx.WindBeams.Wind7, "WindBeam7") -- equivalent call inferred; original call site unknown
		end
	end

	spawntask(firstEvent) -- equivalent call inferred; original call site unknown
end

return _7Page