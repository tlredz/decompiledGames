local createVector = vector.create
local Football1 = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
game:GetService("Players")
game:GetService("Debris")
local localPlayer = game.Players.LocalPlayer
local _ = workspace.Thrown

function CreateWeld(part, p)
	local motor6D = Instance.new("Motor6D")
	motor6D.Part0 = part
	motor6D.Part1 = p
	motor6D.Parent = p
	return motor6D
end

local v = {
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
local v2 = {
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

local function ApplyMeshEffects(folder)
	local MeshControl = require(ReplicatedStorage.Emotes.VFX.VfxMods.MeshControl)

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

		local v3 = emitter
		task.delay(emitter:GetAttribute("EmitDelay"), function()
			v3:Emit(v3:GetAttribute("EmitCount"))
		end)
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

-- equivalent calls inferred from this helper; original call sites unknown
local function LerpColor3(data, data2, p)
	return Color3.new(data.R + (data2.R - data.R) * p, data.G + (data2.G - data.G) * p, data.B + (data2.B - data.B) * p)
end

local function TweenBeamColor(p, p2, p3, p4, p5)
	local v3 = p4 / p5
	task.spawn(function()
		for i = 1, p5 do
			local lerpColor3 = LerpColor3(p2, p3, i / p5) -- equivalent call inferred; original call site unknown
			p.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, lerpColor3),
				ColorSequenceKeypoint.new(1, lerpColor3)
			})
			task.wait(v3)
		end
	end)
end

local function TweenBeamColors(folder, p, p2)
	for _, beam in folder:GetDescendants() do
		if not beam:IsA("Beam") then
			continue
		end

		beam.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, p), ColorSequenceKeypoint.new(1, p) })
		local v5 = 2
		local v6 = beam
		local v7 = 0.5
		task.spawn(function()
			for i = 1, v5 do
				local lerpColor3 = LerpColor3(p, p2, i / v5) -- equivalent call inferred; original call site unknown
				v6.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, lerpColor3),
					ColorSequenceKeypoint.new(1, lerpColor3)
				})
				task.wait(v7)
			end
		end)
	end
end

local function ToggleVisiblity(folder, p, p2)
	local v3 = p2 == nil and {} or p2
	local transparency = p == false and 1 or 0

	for _, part in folder:GetDescendants() do
		if table.find(v3, part.Name) or not (part:IsA("MeshPart") or part:IsA("BasePart")) then
			continue
		end

		part.Transparency = transparency
	end
end

local v3 = {}

function Football1.FirstEvent(data)
	local char = data.Char
	local _ = data.CleanupTable
	local realAnim = data.RealAnim
	local bind = data.Bind or data.EmoteBind

	if not (char and char.Parent) then
		return
	end

	local v4 = false
	pcall(function()
		shared.NerfVfx({
			Script = script,
			Char = char
		})
	end)
	local v5 = {}
	local v6 = {}
	local v7 = {}
	local v8 = {}
	local v9 = {}
	local v10 = {}
	local CreateTweenLoop

	CreateTweenLoop = function(p, p2, value)
		if not v9[p2] then
			v9[p2] = 1
		end

		local v11 = value or 0
		local v12 = v9[p2]
		local v13 = v[p2] and v[p2][v12]
		local v14 = v2[p2] and v2[p2][v12]

		if v14 and v13 then
			if v3[p2] then
				v3[p2]:Disconnect()
			end

			local time = v14.Time
			local v15 = math.max(0, time - v11)
			local tween = TweenService:Create(
				p,
				TweenInfo.new(v15, v14.EasingStyle, v14.EasingDirection or Enum.EasingDirection.In),
				v13
			)
			tween:Play()
			v3[p2] = tween.Completed:Connect(function()
				v3[p2]:Disconnect()
				v3[p2] = nil
				v9[p2] = v12 + 1

				if v9[p2] > #v[p2] then
					v9[p2] = 1
					v10[p2] = false
				end

				if v10[p2] then
					CreateTweenLoop(p, p2, time)
				end
			end)
		else
			v9[p2] = 1
			v10[p2] = false

			if v3[p2] then
				v3[p2]:Disconnect()
				v3[p2] = nil
			end
		end
	end

	local function TweenScale(p: number, p2: number, data2, instance)
		local v11 = 0
		local v12 = 0

		local function onStep(p3: number)
			v11 = math.min(v11 + p3, data2.Time)
			v12 = p + TweenService:GetValue(v11 / data2.Time, data2.EasingStyle, data2.EasingDirection) * (p2 - p)

			if v12 <= 0 then
				v12 = 0.00001
			end

			instance:ScaleTo(v12)

			if v11 == data2.Time then
				v5.TweenScaleConnection:Disconnect()
			else
				local v13

				if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
					v4 = true
					v13 = false
				else
					v13 = true
				end

				if not v13 then
					v5.TweenScaleConnection:Disconnect()
				end
			end
		end

		if v5.TweenScaleConnection then
			v5.TweenScaleConnection:Disconnect()
		end

		v5.TweenScaleConnection = RunService.Heartbeat:Connect(onStep)
	end

	local function StartTweenLoop(p, p2)
		if v3[p2] then
			v3[p2]:Disconnect()
			v3[p2] = nil
		end

		v10[p2] = true
		v9[p2] = 1
		CreateTweenLoop(p, p2, 0)
	end

	local clockTime = Lighting.ClockTime
	local flag = false

	local function CleanUp()
		if flag then
			return
		end

		flag = true
		TweenService:Create(Lighting, TweenInfo.new(0.5), {
			ClockTime = clockTime
		}):Play()

		for _, connection in v3 do
			connection:Disconnect()
		end

		for _, v11 in v8 do
			v11:Cancel()
			v11:Destroy()
		end

		for _, v11 in v7 do
			task.cancel(v11)
		end

		for _, connection in v5 do
			connection:Disconnect()
		end

		for _, v11 in v6 do
			if v11 and v11.Parent then
				v11:Destroy()
			end
		end
	end

	local v11 = nil
	local fn
	local v12 = char == game.Players.LocalPlayer.Character
	local parentChangedConnection

	if bind then
		parentChangedConnection = bind:GetPropertyChangedSignal("Parent"):Connect(function()
			if not bind.Parent then
				CleanUp(char)
			end
		end)
		table.insert(v5, parentChangedConnection)
		table.insert(v5, char:GetPropertyChangedSignal("Parent"):Connect(function()
			if not char.Parent then
				CleanUp()
			end
		end))
	else
		parentChangedConnection = nil
	end

	for _, v13 in pairs(v5) do
		local connection = v13
		task.delay(30, function()
			if connection then
				connection:Disconnect()
			end
		end)
	end

	local v13 = {}
	local shidouEffects = script:WaitForChild("ShidouEffects")

	if localPlayer.Character == char then
		v7.ClockTimeDelay = task.delay(0.33, function()
			v8.ClockTween = TweenService:Create(Lighting, TweenInfo.new(2.31, Enum.EasingStyle.Linear), {
				ClockTime = 0.248
			})
			v8.ClockTween:Play()
		end)
		local depthOfFieldEffect = Instance.new("DepthOfFieldEffect")
		table.insert(v13, depthOfFieldEffect)
		depthOfFieldEffect.Parent = Lighting
		table.insert(v6, depthOfFieldEffect)
		v10.DepthOfField = true
		CreateTweenLoop(depthOfFieldEffect, "DepthOfField")
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		table.insert(v13, colorCorrectionEffect)
		colorCorrectionEffect.Parent = Lighting
		table.insert(v6, colorCorrectionEffect)
		v10.ColorCorrelation = true
		CreateTweenLoop(colorCorrectionEffect, "ColorCorrelation")
	end

	v5.ChildAdded = char.ChildAdded:Connect(function(child)
		if child.Name == "Freeze" or child.Name == "Ragdoll" then
			CleanUp(char)
		end
	end)
	local shidouEffects2 = script.ShidouEffects
	local v14

	if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
		v4 = true
		v14 = false
	else
		v14 = true
	end

	if not v14 then
		return
	end

	local clone = shidouEffects.Effects:Clone()
	clone:PivotTo(char.HumanoidRootPart.CFrame * CFrame.new(1.259, 14.246, 2.844))
	clone.Parent = workspace.Thrown
	table.insert(v6, clone)

	for _, child in shidouEffects2.TorsoEffects:GetChildren() do
		local v15

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v15 = false
		else
			v15 = true
		end

		if not v15 then
			return
		end

		local clone2 = child:Clone()
		clone2.Parent = char.Torso
		table.insert(v6, clone2)
	end

	local clones = {}

	for _, child in shidouEffects2.HeadEffects:GetChildren() do
		local v15

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v15 = false
		else
			v15 = true
		end

		if not v15 then
			return
		end

		local clone2 = child:Clone()
		clone2.Parent = char.Head
		table.insert(clones, clone2)
		table.insert(v6, clone2)
	end

	for _, child in shidouEffects2.LeftLegEffects:GetChildren() do
		local v15

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v15 = false
		else
			v15 = true
		end

		if not v15 then
			return
		end

		local clone2 = child:Clone()
		clone2.Parent = char["Left Leg"]
		table.insert(v6, clone2)
	end

	local v15

	if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
		v4 = true
		v15 = false
	else
		v15 = true
	end

	if not v15 then
		return
	end

	local clone2 = shidouEffects2.Wings:Clone()
	clone2.Parent = char
	table.insert(v6, clone2)
	local motor6D = Instance.new("Motor6D")
	motor6D.Part0 = char.Torso
	motor6D.Part1 = clone2.L
	motor6D.Parent = char.Torso
	motor6D.C0 = CFrame.new(
		-2.31159401,
		0.348124504,
		0.971909463,
		0.946494401,
		0.180227295,
		0.267706007,
		-0.173423946,
		0.983624995,
		-0.0490511507,
		-0.272162676,
		0,
		0.962251365
	)
	motor6D.C1 = CFrame.new(
		1.93431091,
		0.935721874,
		-0.662989497,
		0.789164424,
		0.452726483,
		-0.415040106,
		-0.447337538,
		0.886723578,
		0.116664246,
		0.420842767,
		0.0935957432,
		0.902292192
	)
	table.insert(v6, motor6D)
	local motor6D2 = Instance.new("Motor6D")
	motor6D2.Part0 = char.Torso
	motor6D2.Part1 = clone2.R
	motor6D2.Parent = char.Torso
	motor6D2.C0 = CFrame.new(
		2.17743158,
		0.393496037,
		1.04702556,
		-0.946845829,
		-0.152823448,
		0.283068925,
		-0.17342405,
		0.983625054,
		-0.0490512438,
		-0.270937473,
		-0.0955349207,
		-0.957844496
	)
	motor6D2.C1 = CFrame.new(
		2.2411201,
		1.73267913,
		0.428651273,
		0.890649498,
		0.291072428,
		0.349313825,
		-0.34179467,
		0.935245872,
		0.0921684653,
		-0.299866408,
		-0.201483399,
		0.932463586
	)
	table.insert(v6, motor6D2)
	local clone3 = shidouEffects2.MeshPartball:Clone()
	clone3.Parent = char
	table.insert(v6, clone3)
	local motor6D3 = Instance.new("Motor6D")
	motor6D3.Part0 = char.HumanoidRootPart
	motor6D3.Part1 = clone3
	motor6D3.Parent = clone3
	motor6D3.C1 = CFrame.new(-0.154, 2.316, 1.973)
	local cameraRigFootbal = char:WaitForChild("CameraRigFootbal")
	v7.EffectEmit1 = task.delay(1.116, function()
		local v16

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v16 = false
		else
			v16 = true
		end

		if not v16 then
			return
		end

		ApplyMeshEffects(clone.Mesh.M0)
		EmitEffects(clone.WindFx)
		ToggleEffects(clone3.Attachment, true)
	end)
	v7.EffectEmit2 = task.delay(2.166, function()
		local v16

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v16 = false
		else
			v16 = true
		end

		if not v16 then
			return
		end

		EmitEffects(cameraRigFootbal.CamPart.Emit)
	end)
	v7.EffectEmit3 = task.delay(2.25, function()
		local v16

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v16 = false
		else
			v16 = true
		end

		if not v16 then
			return
		end

		ToggleEffects(clone3.Attachment2, true)
		ToggleEffects(clone.StarFx, true)
	end)
	v7.EffectEmit4 = task.delay(2.716, function()
		local v16

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v16 = false
		else
			v16 = true
		end

		if not v16 then
			return
		end

		ApplyMeshEffects(clone.Mesh.M1)
		ToggleEffects(char.Torso.Enable, true)
		EmitEffects(clone.JumpFx)
	end)
	v7.EffectEmit5 = task.delay(2.916, function()
		local v16

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v16 = false
		else
			v16 = true
		end

		if not v16 then
			return
		end

		EmitEffects(char.Torso.Emit)
	end)
	v7.EffectEmit6 = task.delay(3.183, function()
		local v16

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v16 = false
		else
			v16 = true
		end

		if not v16 then
			return
		end

		ToggleEffects(clone2, true)
		EmitEffects(clone2)
		ToggleEffects(char.Torso.Enable, false)
	end)
	v7.EffectEmit7 = task.delay(4.4333, function()
		local v16

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v16 = false
		else
			v16 = true
		end

		if not v16 then
			return
		end

		ToggleEffects(clone3.Attachment2, false)
		ToggleEffects(clone3.Attachment, false)
		ToggleEffects(clone2, false)
		ToggleEffects(clone.StarFx, false)
		ToggleEffects(clone.SPFx, true)

		for _, v17 in pairs(clones) do
			ToggleEffects(v17, true)
		end
	end)
	v7.EffectEmit8 = task.delay(6.25, function()
		local v16

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v16 = false
		else
			v16 = true
		end

		if not v16 then
			return
		end

		ToggleEffects(clone.Star1Fx, true)
	end)
	v7.EffectEmit9 = task.delay(6.5166, function()
		local v16

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v16 = false
		else
			v16 = true
		end

		if not v16 then
			return
		end

		ToggleEffects(clone.SPFx, false)

		for _, v17 in pairs(clones) do
			ToggleEffects(v17, false)
		end
	end)
	v7.EffectEmit10 = task.delay(7.066, function()
		local v16

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v16 = false
		else
			v16 = true
		end

		if not v16 then
			return
		end

		EmitEffects(char["Left Leg"])
	end)
	v7.EffectEmit11 = task.delay(7.266, function()
		local v16

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v16 = false
		else
			v16 = true
		end

		if not v16 then
			return
		end

		ToggleEffects(clone.InkFx, true)
		ToggleEffects(clone.WindBeams, true)
		ToggleEffects(cameraRigFootbal.CamPart.Ink1Fx, true)
		EmitEffects(clone.BGFx)
	end)
	v7.EffectEmit12 = task.delay(7.4, function()
		local v16

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v16 = false
		else
			v16 = true
		end

		if not v16 then
			return
		end

		ToggleEffects(clone3.Attachment3, true)
	end)
	v7.EffectEmit13 = task.delay(7.685, function()
		local v16

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v16 = false
		else
			v16 = true
		end

		if not v16 then
			return
		end

		ToggleEffects(clone.Star1Fx, false)
		ToggleEffects(clone.InkFx, false)
		ToggleEffects(clone.WindBeams, false)
		ToggleEffects(cameraRigFootbal.CamPart.Ink1Fx, false)
		ToggleEffects(clone3.Attachment3, false)
	end)
	v7.EffectEmit14 = task.delay(8.083, function()
		local v16

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v16 = false
		else
			v16 = true
		end

		if not v16 then
			return
		end

		EmitEffects(clone.KickFx)

		for _, connection in v3 do
			connection:Disconnect()
		end

		if v12 then
			for _, depthOfFieldEffect in pairs(v13) do
				if depthOfFieldEffect:IsA("DepthOfFieldEffect") then
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(depthOfFieldEffect, TweenInfo.new(0.5), {
						FarIntensity = 0,
						FocusDistance = 0,
						NearIntensity = 0,
						InFocusRadius = 0
					}):Play()
				else
					local TweenService2 = game:GetService("TweenService")
					TweenService2:Create(depthOfFieldEffect, TweenInfo.new(0.5), {
						Contrast = 0,
						Saturation = 0,
						Brightness = 0,
						TintColor = Color3.fromRGB(255, 255, 255)
					}):Play()
				end

				game.Debris:AddItem(depthOfFieldEffect, 0.5)
			end

			TweenService:Create(Lighting, TweenInfo.new(0.5), {
				ClockTime = clockTime
			}):Play()
			local folder = Instance.new("Folder")
			folder.Name = "NoSmoothTransition"
			folder.Parent = char
			game.Debris:AddItem(folder, 1)
			cameraRigFootbal:Destroy()
		end

		table.remove(v6, table.find(v6, clone3))
		v11 = true

		if parentChangedConnection then
			parentChangedConnection:Disconnect()
		end

		table.insert(v5, char.ChildAdded:Connect(function(child)
			if child.Name == "BlockTry" or child.Name == "M1ing" or child.Name == "CancelEmote" or child.Name == "CancelEmote2" or child.Name == "Freeze" or child.Name == "Ragdoll" then
				fn()
				CleanUp(char)
			end
		end))
		tick()
		local currentCamera = workspace.CurrentCamera
		local primaryPart = char.PrimaryPart
		local cFrame = clone3.CFrame

		if motor6D3 then
			motor6D3:Destroy()
		end

		clone3.Parent = workspace.Thrown
		clone3.CFrame = cFrame
		local numberValue = Instance.new("NumberValue")
		numberValue.Value = 1
		local model = Instance.new("Model")
		task.delay(30, function()
			if model and model.Parent then
				model:Destroy()
			end
		end)
		model.Parent = workspace.Thrown
		clone3.Parent = model
		model:PivotTo(cFrame)
		clone3.Anchored = false
		clone3.CanCollide = true
		clone3.CollisionGroup = "nocol"
		numberValue.Changed:Connect(function()
			if numberValue.Value <= 0 then
				return numberValue:Destroy()
			end

			model:ScaleTo(numberValue.Value)
		end)
		game.Debris:AddItem(numberValue, 30)
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(numberValue, TweenInfo.new(1.5), {
			Value = math.random(5, 10)
		}):Play()
		local highlight = Instance.new("Highlight")
		highlight.OutlineTransparency = 0.75
		highlight.OutlineColor = Color3.fromRGB()
		highlight.FillTransparency = 1
		highlight.Parent = clone3
		spawn(function()
			if v12 then
				shared.repfire({
					Effect = "Camshake",
					Intensity = 6,
					Last = 2
				})
			end
		end)
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(400000, 400000, 400000)
		bodyVelocity.Velocity = -primaryPart.CFrame.lookVector * 45 + createVector(0, 35, 0)
		bodyVelocity.Parent = clone3
		local v17 = -primaryPart.CFrame.lookVector
		spawn(function()
			local lastTime = tick()
			local v18

			if math.random(1, 2) == 1 then
				v18 = -15
			else
				v18 = 10
			end

			while bodyVelocity and bodyVelocity.Parent do
				local v19 = tick() - lastTime

				if v19 > 1.75 or not (bodyVelocity and bodyVelocity.Parent) then
					break
				end

				local v20 = math.max(35 - v19 * 75, v18)
				bodyVelocity.Velocity = v17 * (45 + v19 * 150) + Vector3.new(0, v20, 0)
				local RunService2 = game:GetService("RunService")
				RunService2.Heartbeat:Wait()
			end
		end)
		game.Debris:AddItem(bodyVelocity, 1.75)
		local cFrame2 = nil
		local lastTime = tick()
		local lastTime2 = tick()
		local cFrame3 = currentCamera.CFrame
		local position = clone3.Position
		local flag2 = false
		local renderSteppedConnection = nil
		local now = 0
		local v18 = 1
		local position2 = cFrame3.Position
		local position3 = clone3.Position

		if v12 then
			local RunService2 = game:GetService("RunService")
			renderSteppedConnection = RunService2.RenderStepped:Connect(function()
				if not (clone3 and clone3.Parent) then
					renderSteppedConnection:Disconnect()
					return
				end

				currentCamera.CameraType = Enum.CameraType.Scriptable
				local v19 = tick() - lastTime
				local value = TweenService:GetValue(
					math.min(v19 / 0.5, 1),
					Enum.EasingStyle.Sine,
					Enum.EasingDirection.InOut
				)
				local magnitude = (clone3.Position - position).Magnitude
				position = clone3.Position
				position3 = position3:Lerp(position, 0.35)
				local v21 = position3
				local value2 = numberValue.Value
				local v22, vector2

				if flag2 then
					local v23 = tick() - now

					if v23 < 2 then
						local v24 = math.min(v23 * 3, 1)
						local v25 = math.sin(v24 * 3.141592653589793 * 0.5)
						v22 = position + Vector3.new(v25 * 30 - (1 - v25) * 8, v24 * 8 + 20, -35 - v24 * 10)
						v21 = position + createVector(0, -3, -10)
						local v26 = math.exp(-v23 * 8) * 12 * v18
						vector2 = Vector3.new(
							math.random(-100, 100) / 100 * v26,
							math.random(-100, 100) / 100 * v26,
							math.random(-100, 100) / 100 * v26
						)
					else
						CleanUp(char)
						renderSteppedConnection:Disconnect()
						shared.smoothout(cFrame2)
						return
					end
				else
					local v23 = math.min((tick() - lastTime2) * 0.6, 1)
					local v24 = math.min(value2 / 3, 2)
					local v25 = (-15 - magnitude * 0.15 - v23 * 8) * v24
					local v26 = (v23 * 3 + 8) * v24
					local v27 = (-6 - v23 * 2) * v24
					v22 = position + Vector3.new(v27, v26, v25)
					vector2 = Vector3.new(
						math.sin(v19 * 25) * 0.45,
						math.cos(v19 * 30) * 0.35,
						math.sin(v19 * 35) * 0.3
					) * (1 - value * 0.3)

					if v19 < 0.45 then
						local v28 = math.exp(-v19 * 3) * 8
						vector2 += Vector3.new(
							math.random(-100, 100) / 100 * v28,
							math.random(-100, 100) / 100 * v28,
							math.random(-100, 100) / 100 * v28
						)
					end
				end

				local v23 = value * 0.15 + 0.12
				position2 = position2:Lerp(v22, v23)
				currentCamera.CFrame = CFrame.lookAt(position2 + vector2, v21)
				cFrame2 = currentCamera.CFrame
			end)
		end

		local v19 = false

		fn = function()
			if not v12 then
				return
			end

			v19 = true

			if renderSteppedConnection then
				renderSteppedConnection:Disconnect()
			end

			shared.smoothout(cFrame2)
		end

		spawn(function()
			if not v12 then
				return
			end

			local lastTime3 = tick()
			local overlapParams = OverlapParams.new()
			overlapParams.FilterDescendantsInstances = { workspace.Built, workspace.Map, workspace.Terrain }
			overlapParams.FilterType = Enum.RaycastFilterType.Include
			local _ = clone3.Position

			while task.wait(0.015) and not (tick() - lastTime3 >= 5) and clone3 and clone3.Parent do
				local value = numberValue.Value
				local partBoundsInRadius = workspace:GetPartBoundsInRadius(
					clone3.Position,
					math.min(6 * value, 13),
					overlapParams
				)

				if not (partBoundsInRadius and #partBoundsInRadius > 0) then
					continue
				end

				local position4 = clone3.Position

				if bodyVelocity then
					bodyVelocity:Destroy()
				end

				local v20 = tick() - lastTime2
				local v21 = math.min(1 + v20 * 1.2, 4)
				v18 = v21
				clone3.Velocity = createVector(0, 0, 0)
				local number = Random.new():NextNumber(3.5, 7.25)
				task.delay(number, function()
					game.Debris:AddItem(clone3.Parent, 1.15)
					local TweenService3 = game:GetService("TweenService")
					TweenService3:Create(clone3, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
						Transparency = 1
					}):Play()
				end)
				local v22 = partBoundsInRadius[1]
				local v23 = (position4 - v22.Position).Unit + Vector3.new(
					math.random(-30, 30) / 100,
					0.5,
					math.random(-30, 30) / 100
				)
				local bodyVelocity2 = Instance.new("BodyVelocity")
				bodyVelocity2.MaxForce = createVector(400000, 400000, 400000)
				bodyVelocity2.Velocity = v23 * (v21 * 25)
				bodyVelocity2.Parent = clone3
				game.Debris:AddItem(bodyVelocity2, 0.2)
				flag2 = true
				now = tick()

				if shared.OnScreen(clone3.Position) then
					shared.repfire({
						Effect = "Camshake",
						Intensity = 7
					})
					task.spawn(function()
						local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
						game.Debris:AddItem(colorCorrectionEffect, 0.8)
						colorCorrectionEffect.TintColor = Color3.fromRGB(252, 153, 255)
						colorCorrectionEffect.Parent = game.Lighting
						local TweenService3 = game:GetService("TweenService")
						TweenService3:Create(colorCorrectionEffect, TweenInfo.new(0.75), {
							TintColor = Color3.fromRGB(255, 255, 255)
						}):Play()
						local clone4 = script.Game:Clone()
						clone4.Parent = game.Players.LocalPlayer.PlayerGui
						local imageLabel = clone4.ImageLabel
						imageLabel.Size = UDim2.new(0, 0, 4, 0)
						imageLabel.Visible = true
						local TweenService4 = game:GetService("TweenService")
						TweenService4:Create(
							imageLabel,
							TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{
								Size = UDim2.new(1.5, 0, 0, 0)
							}
						):Play()
						local glow = clone4.Glow
						glow.Size = UDim2.new(2, 0, 2, 0)
						glow.ImageTransparency = 0
						glow.Visible = true
						local TweenService5 = game:GetService("TweenService")
						TweenService5:Create(
							glow,
							TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								ImageTransparency = 1,
								Size = UDim2.new(3, 0, 3, 0)
							}
						):Play()
						local fade = clone4.Fade
						fade.Size = UDim2.new(1.5, 0, 2.5, 0)
						fade.ImageTransparency = 1
						fade.Visible = true
						local TweenService6 = game:GetService("TweenService")
						TweenService6:Create(
							fade,
							TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								ImageTransparency = 0.4,
								Size = UDim2.new(1.8, 0, 1, 0)
							}
						):Play()
						local textLabels = {}
						spawn(function()
							local textLabel = clone4.TextLabel
							table.insert(textLabels, textLabel)
							textLabel.ZIndex = 1
							local size = textLabel.Size
							textLabel.Size = UDim2.new(0, 0, 0, 0)
							textLabel.ImageTransparency = 0
							textLabel.Visible = true
							TweenService:Create(
								textLabel,
								TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									Size = size
								}
							):Play()
						end)
						task.wait(1)
						task.delay(1, function()
							for _, v24 in pairs(textLabels) do
								TweenService:Create(
									v24,
									TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
									{
										ImageTransparency = 1
									}
								):Play()
							end

							local TweenService7 = game:GetService("TweenService")
							TweenService7:Create(
								fade,
								TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
								{
									ImageTransparency = 1
								}
							):Play()
							task.wait(1)
							clone4:Destroy()
						end)
					end)
				end

				for _ = 1, math.floor(v21 * 2 + 5) do
					local part = Instance.new("Part")
					game.Debris:AddItem(part, 3)
					part.Material = v22.Material == Enum.Material.Grass and Enum.Material.Slate or v22.Material
					part.Color = v22.Color
					part.Size = createVector(1, 1, 1) * Random.new():NextNumber(0.8, 1.5) * math.min(value * 0.4, 1.8)
					part.CFrame = CFrame.new(position4) * CFrame.Angles(
						math.rad((math.random(-360, 360))),
						math.rad((math.random(-360, 360))),
						(math.rad((math.random(-360, 360))))
					)
					part.CanCollide = true
					part.CollisionGroup = "nocol"
					part.Parent = workspace.Thrown
					local bodyVelocity3 = Instance.new("BodyVelocity")
					bodyVelocity3.MaxForce = createVector(100000, 100000, 100000)
					bodyVelocity3.Velocity = Vector3.new(
						math.random(-100, 100) / 100,
						Random.new():NextNumber(0.3, 0.8),
						math.random(-100, 100) / 100
					).Unit * Random.new():NextNumber(20, 40) * v21 + createVector(0, 10, 0)
					bodyVelocity3.Parent = part
					game.Debris:AddItem(bodyVelocity3, 0.2)
					task.delay(2, function()
						local TweenService3 = game:GetService("TweenService")
						TweenService3:Create(part, TweenInfo.new(1), {
							Transparency = 1,
							Size = part.Size * 0.5
						}):Play()
					end)
				end

				local clone4 = script.Part:Clone()
				clone4.Anchored = true
				clone4.CanCollide = false
				clone4.CanQuery = false
				clone4.CanTouch = false
				local model2 = Instance.new("Model")
				model2.Parent = workspace.Thrown
				clone4.Parent = model2
				local v24 = math.min(1 + v20 * 0.4, 2)
				local v25 = ((v24 - 1) * 0.3 + 0.8) * math.min(value * 0.35, 1.5)
				model2:PivotTo(CFrame.new(position4))
				clone4.Position = position4
				model2:ScaleTo(v25)
				game.Debris:AddItem(model2, 5)

				for _, emitter in pairs(clone4:GetDescendants()) do
					if emitter:IsA("ParticleEmitter") then
						emitter:Emit((math.floor(emitter:GetAttribute("EmitCount") * v24 * math.min(value * 0.25, 1.3))))
					end
				end

				break
			end

			if renderSteppedConnection and renderSteppedConnection.Connected and not flag2 then
				renderSteppedConnection:Disconnect()

				if cFrame2 then
					shared.smoothout(cFrame2)
				end
			end
		end)
	end)
	local v16

	if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
		v4 = true
		v16 = false
	else
		v16 = true
	end

	if not v16 then
		return
	end

	v10.Box = true
	CreateTweenLoop(clone.Box, "Box")
	v10.Box1 = true
	CreateTweenLoop(clone.Box1, "Box1")
	v10.SPLight1 = true
	CreateTweenLoop(clone.SPFx.P.SurfaceLight, "SPLight1")
	v10.SPLight2 = true
	CreateTweenLoop(clone.SPFx.P0.PointLight, "SPLight2")
	v10.SPLight3 = true
	CreateTweenLoop(clone.SPFx.P1.SurfaceLight, "SPLight3")
	v10.InkLight1 = true
	CreateTweenLoop(clone.InkFx.P.SurfaceLight, "InkLight1")
	v10.InkLight2 = true
	CreateTweenLoop(clone.InkFx.P1.SurfaceLight, "InkLight2")
	v10.InkEffect1 = true
	CreateTweenLoop(clone.BGFx.Ink1, "InkEffect1")
	v10.InkEffect2 = true
	CreateTweenLoop(clone.BGFx.Ink2, "InkEffect2")
	v10.WindPointLight = true
	CreateTweenLoop(clone.WindFx.P.PointLight, "WindPointLight")
	v10.WindSurfaceLight = true
	CreateTweenLoop(clone.WindFx.P1.SurfaceLight, "WindSurfaceLight")
	v10.WindSurfaceLight1 = true
	CreateTweenLoop(clone.WindFx.P2.SurfaceLight, "WindSurfaceLight1")
	v10.BallPointLight = true
	CreateTweenLoop(clone3.P.PointLight, "BallPointLight")
	v10.BallSurfaceLight = true
	CreateTweenLoop(clone3.P1.SurfaceLight, "BallSurfaceLight")

	for _, child in char.Torso.A:GetChildren() do
		local v17

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v17 = false
		else
			v17 = true
		end

		if not v17 then
			return
		end

		child.Attachment0 = char.Torso.A
		child.Attachment1 = char.Torso.B
		v10["A" .. child.Name] = true
		CreateTweenLoop(child, "A" .. child.Name)
	end

	for _, child in char.Torso.A1:GetChildren() do
		local v17

		if v4 or not (realAnim and realAnim.IsPlaying and bind and bind.Parent) then
			v4 = true
			v17 = false
		else
			v17 = true
		end

		if not v17 then
			break
		end

		child.Attachment0 = char.Torso.A1
		child.Attachment1 = char.Torso.B1
		v10["A1" .. child.Name] = true
		CreateTweenLoop(child, "A1" .. child.Name)
	end
end

return Football1