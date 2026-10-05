local createVector = vector.create
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local SoundGroupManager = require(ReplicatedStorage.Modules.Audio.SoundGroupManager)
local CameraAuthority = require(ReplicatedStorage.SharedUtils.CameraAuthority)
local HudHide = require(ReplicatedStorage.SharedUtils.HudHide)
local SoulvesterGuardCameraCore = require(script.Parent.SoulvesterGuardCameraCore)
local SoulvesterGuardCinematic = {}
local v = nil

local function takeCamera()
	if v then
		return
	end

	local claim = CameraAuthority.claim

	if not claim then
		return
	end

	v = claim("SoulvesterGuardCinematic", {
		priority = 100
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function giveBackCamera()
	if v then
		v:release()
		v = nil
	end
end

local v2 = {
	Riser = {
		id = "rbxassetid://137100141753732",
		volume = 0.35,
		speed = 0.85
	},
	Stinger = {
		id = "Sounds.UI.Ping",
		volume = 0.5,
		speed = 0.8
	}
}
task.spawn(function()
	local ContentProvider = game:GetService("ContentProvider")
	local v3 = {}

	for _, v4 in pairs(v2) do
		if not (type(v4.id) == "string" and v4.id:find("rbxassetid")) then
			continue
		end

		local sound = Instance.new("Sound")
		sound.SoundId = v4.id
		table.insert(v3, sound)
	end

	for _, animationId in ipairs({
		"rbxassetid://110202168803261",
		"rbxassetid://92419655360284",
		"rbxassetid://80215716954867"
	}) do
		local animation = Instance.new("Animation")
		animation.AnimationId = animationId
		table.insert(v3, animation)
	end

	pcall(function()
		ContentProvider:PreloadAsync(v3)
	end)

	for _, v4 in ipairs(v3) do
		v4:Destroy()
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function playShotSound(p)
	local v3 = v2[p]

	if not v3 or v3.id == "" then
		return nil
	end

	local success, result = pcall(function()
		local v4 = Audio:Play(v3.id, {
			Volume = v3.volume,
			PlaybackSpeed = v3.speed
		})

		if v4 then
			SoundGroupManager.AssignSFXSound(v4)
		end

		return v4
	end)
	return success and result or nil
end

local function fadeSound(riser, duration)
	if not (riser and riser.Parent) then
		return
	end

	local tween = TweenService:Create(riser, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Volume = 0
	})
	tween.Completed:Connect(function()
		if riser.Parent then
			riser:Stop()
			riser:Destroy()
		end
	end)
	tween:Play()
end

local v3 = {
	TakeTime = 0.12,
	ReleaseTime = 0.22,
	BlendIn = 0.16,
	BlendOut = 0.14,
	Handheld = 0.1,
	Style = "Swoop",
	SwoopStartScale = 0.85,
	SwoopStartMax = 42,
	SwoopDegrees = 360,
	SwoopBank = 7,
	SweepDegrees = 55,
	ApexHang = 0.1,
	Fov = 65,
	FovApexScale = 0.82,
	FitMargin = 4,
	DistanceMin = 18,
	RelativeDistance = 0.55,
	RelativeHeight = 1,
	OcclusionLifts = {
		6,
		12,
		20,
		30
	},
	OcclusionPullFloor = 0.45,
	StoryVictimFraction = 0.32,
	StoryWideScale = 1.35,
	StoryHighScale = 1.4,
	DistanceApexScale = 0.92,
	HeightStart = 11,
	HeightApex = 6.5,
	FocusHeight = 1.8,
	FocusApexLift = 1.1,
	PoseRattle = 0.9,
	PoseRattleTime = 0.35,
	StandoffShoulderDegrees = 40,
	StandoffDistanceScale = 1,
	StandoffPush = 0.12,
	StandoffSettle = 1.5,
	FocusWeights = {
		caster = 0.5,
		ally = 0.25,
		attacker = 0.25
	},
	OcclusionMargin = 0.6,
	OcclusionFloor = 0.9,
	Saturation = 0.15,
	Brightness = 0.04,
	Contrast = 0.06,
	Tint = Color3.fromRGB(255, 248, 238),
	GradeStrength = 1,
	Exposure = 0.5,
	Spotlight = false,
	HitStop = 0.2,
	HitStopStillSpeed = 4,
	PortraitSettle = 0.56,
	PortraitTurns = {
		35,
		25,
		45,
		15,
		55
	},
	PortraitHeroAngles = {
		18,
		24,
		30,
		36,
		42
	},
	PortraitHeroPreferredAngle = 32,
	PortraitHeroAngleWeight = 0.004,
	PortraitHeroDistanceScales = {
		1.6,
		1.9,
		2.2,
		2.6
	},
	PortraitHeroMaxDistance = 26,
	PortraitTwistedTargetX = 0.67,
	PortraitTwistedBand = 0.12,
	PortraitTwistedMinX = 0.35,
	PortraitTwistedMaxX = 0.85,
	PortraitCasterHalfWidth = 1.2,
	PortraitDistance = 9,
	PortraitFovPreferred = 60,
	PortraitMinDistance = 1.5,
	PortraitTwistedClearance = 1.5,
	PortraitFrameSpan = 1.15,
	PortraitFocusShare = 0.55,
	PortraitLookUp = 0.4,
	PortraitHeroLookUp = 0.7,
	PortraitFovMin = 26,
	PortraitFovMax = 80,
	PortraitAllyBias = 0.15,
	PortraitAllyLeanMax = 1.2,
	PortraitCreep = 0.05,
	KeyBrightness = 3,
	KeyRange = 60,
	KeyAngle = 100,
	KeyColor = Color3.fromRGB(255, 240, 225),
	PortraitKeySideDegrees = 70,
	PortraitKeyLiftShare = 0.35,
	PortraitKeyDistance = 6,
	PortraitRimBrightness = 5,
	PortraitRimSideDegrees = 25,
	PortraitRimLiftShare = 0.45,
	PortraitRimColor = Color3.fromRGB(170, 200, 255),
	Bloom = {
		Intensity = 0.35,
		Size = 40,
		Threshold = 0.85
	},
	FilmLook = false,
	HideHud = true,
	DepthOfField = {
		InFocusRadius = 18,
		NearIntensity = 0.2,
		FarIntensity = 0.5
	},
	PortraitDepthOfField = {
		InFocusRadius = 6,
		NearIntensity = 0.1,
		FarIntensity = 0.55
	},
	Vignette = {
		thickness = 0.32,
		transparency = 0.35,
		color = Color3.fromRGB(5, 5, 12)
	},
	ToonLightDim = 0.35,
	Storybook = false,
	StorybookGrade = {
		Saturation = -0.65,
		Brightness = -0.03,
		Contrast = 0.22,
		Tint = Color3.fromRGB(255, 220, 168)
	},
	StorybookVignette = {
		thickness = 0.38,
		transparency = 0.08,
		color = Color3.fromRGB(40, 24, 10)
	},
	StorybookPaper = {
		color = Color3.fromRGB(236, 214, 176),
		transparency = 0.9
	},
	StorybookHatch = {
		enabled = false,
		spacing = 8,
		transparency = 0.78,
		color = Color3.fromRGB(58, 38, 20),
		angle = 38
	},
	StorybookFlicker = {
		rate = 12,
		paper = 0.025,
		hatch = 0.05
	},
	PoseLeanDegrees = 12,
	PoseRightArm = 2.792526803190927,
	PoseLeftArm = 0.6981317007977318,
	PoseSpeed = 0.35,
	LightHeight = 14,
	LightBrightness = 16,
	LightAngle = 50,
	LightRange = 48,
	LightColor = Color3.fromRGB(255, 244, 220),
	ShaftTopRadius = 2.2,
	ShaftTransparency = 0.82,
	FillColor = Color3.fromRGB(255, 110, 160),
	FillBrightness = 2.5,
	FillRange = 14,
	ParticleColor = ColorSequence.new(Color3.fromRGB(220, 60, 110), Color3.fromRGB(96, 140, 210)),
	ParticleBurst = 70,
	ParticleRate = 45
}
local v4 = v3

local function tuned(tuning)
	if type(tuning) ~= "table" then
		return v3
	end

	local object = setmetatable({}, {
		__index = v3
	})

	for k, v5 in pairs(tuning) do
		object[k] = v5
	end

	if tuning.ArmRaiseDegrees then
		object.PoseRightArm = math.rad(tuning.ArmRaiseDegrees)
		object.PoseLeftArm = math.rad(tuning.ArmRaiseDegrees * 0.25)
	end

	if tuning.BloomIntensity then
		object.Bloom = {
			Intensity = tuning.BloomIntensity,
			Size = v3.Bloom.Size,
			Threshold = v3.Bloom.Threshold
		}
	end

	return object
end

local v5 = nil
local count = 0
local v6 = nil
local v7 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function camera()
	return workspace.CurrentCamera
end

local function labPrint(...)
	local localPlayer = Players.LocalPlayer

	if localPlayer and (localPlayer:GetAttribute("SoulvesterLabArmed") == true or localPlayer:GetAttribute("AccessTier") == "Dev") then
		print("[SoulvesterLab/client]", ...)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function disconnectAll(conns)
	for _, connection in ipairs(conns) do
		connection:Disconnect()
	end
end

local function findJoints(folder)
	local humanoidRootPart = folder:FindFirstChild("HumanoidRootPart")
	local motor6Ds = {}
	local v8 = nil

	for _, motor6D in ipairs(folder:GetDescendants()) do
		if not motor6D:IsA("Motor6D") then
			continue
		end

		if humanoidRootPart and (motor6D.Part0 == humanoidRootPart or motor6D.Part1 == humanoidRootPart) then
			v8 = motor6D
		else
			local part1 = motor6D.Part1
			local name = (part1 and part1.Name or motor6D.Name):lower()

			if name:find("arm") or name:find("hand") or motor6D.Name:lower():find("shoulder") then
				table.insert(motor6Ds, motor6D)
			end
		end
	end

	return v8, motor6Ds
end

local function applyPose(p, instance)
	local joints, v8 = findJoints(instance)
	p.pose = {
		root = joints,
		rootC0 = joints and joints.C0,
		arms = {}
	}

	if joints then
		TweenService:Create(joints, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			C0 = joints.C0 * CFrame.Angles(math.rad(-v4.PoseLeanDegrees), 0, 0)
		}):Play()
	end

	for _, joint in ipairs(v8) do
		local v10 = (joint.Part1 and joint.Part1.Name or joint.Name):lower():find("right") ~= nil

		if joint:GetAttribute("GuardPoseBaseVelocity") == nil then
			joint:SetAttribute("GuardPoseBaseVelocity", joint.MaxVelocity)
			joint:SetAttribute("GuardPoseBaseAngle", joint.DesiredAngle)
		end

		table.insert(p.pose.arms, {
			joint = joint
		})
		joint.MaxVelocity = v4.PoseSpeed
		joint.DesiredAngle = v10 and v4.PoseRightArm or v4.PoseLeftArm
	end
end

local function jointIsPosed(p, p2)
	if not (p and p.pose) then
		return false
	end

	if p.pose.root == p2 then
		return true
	end

	for _, arm in ipairs(p.pose.arms) do
		if arm.joint == p2 then
			return true
		end
	end

	return false
end

local function applyHoldAnimation(p, instance, animation)
	if type(animation) ~= "string" or animation == "" then
		return
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

	if not animator then
		return
	end

	local success, result = pcall(function()
		local animation2 = Instance.new("Animation")
		animation2.AnimationId = animation
		local track = animator:LoadAnimation(animation2)
		animation2:Destroy()
		return track
	end)

	if not (success and result) then
		return
	end

	result.Looped = true
	result.Priority = Enum.AnimationPriority.Action2
	result:Play(0.1)
	p.holdTrack = result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseHoldAnimation(p)
	local holdTrack = p.holdTrack

	if not holdTrack then
		return
	end

	p.holdTrack = nil
	pcall(function()
		holdTrack:Stop(0.2)
		holdTrack:Destroy()
	end)
end

local function releasePose(p)
	local pose = p.pose

	if not pose then
		return
	end

	p.pose = nil

	if pose.root and pose.root.Parent and pose.rootC0 then
		TweenService:Create(pose.root, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			C0 = pose.rootC0
		}):Play()
	end

	for _, arm in ipairs(pose.arms) do
		local joint = arm.joint

		if not joint.Parent then
			continue
		end

		joint.DesiredAngle = joint:GetAttribute("GuardPoseBaseAngle") or 0
		local v8 = (joint:GetAttribute("GuardPoseToken") or 0) + 1
		joint:SetAttribute("GuardPoseToken", v8)
		local joint2 = joint
		task.delay(0.4, function()
			if joint2.Parent and joint2:GetAttribute("GuardPoseToken") == v8 then
				local v11 = v5
				local joint3 = joint2
				local v13

				if v11 and v11.pose then
					if v11.pose.root == joint3 then
						v13 = true
					else
						local flag = true

						for i, arm2 in ipairs(v11.pose.arms) do
							if arm2.joint ~= joint3 then
								continue
							end

							v13 = true
							flag = false
							break
						end

						if flag then
							v13 = false
						end
					end
				else
					v13 = false
				end

				if not v13 then
					local guardPoseBaseVelocity = joint2:GetAttribute("GuardPoseBaseVelocity")

					if guardPoseBaseVelocity ~= nil then
						joint2.MaxVelocity = guardPoseBaseVelocity
						joint2:SetAttribute("GuardPoseBaseVelocity", nil)
						joint2:SetAttribute("GuardPoseBaseAngle", nil)
					end
				end
			end
		end)
	end
end

local function applyExposure(p, exposure)
	local exposure2 = p.exposure

	if not exposure2 then
		if exposure <= 0 then
			return
		end

		exposure2 = {
			driver = Instance.new("NumberValue"),
			applied = 0
		}
		exposure2.conn = exposure2.driver.Changed:Connect(function(applied)
			Lighting.ExposureCompensation += applied - exposure2.applied
			exposure2.applied = applied
		end)
		p.exposure = exposure2
	end

	if exposure2.tween then
		exposure2.tween:Cancel()
	end

	exposure2.tween = TweenService:Create(
		exposure2.driver,
		TweenInfo.new(v4.TakeTime + 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Value = exposure
		}
	)
	exposure2.tween:Play()
end

local function releaseExposure(p, releaseTime)
	local exposure = p.exposure
	p.exposure = nil

	if not exposure then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function settle()
		if exposure.settled then
			return
		end

		exposure.settled = true
		exposure.conn:Disconnect()
		Lighting.ExposureCompensation -= exposure.applied
		exposure.applied = 0
		exposure.driver:Destroy()
	end

	if exposure.tween then
		exposure.tween:Cancel()
	end

	if releaseTime <= 0 then
		settle() -- equivalent call inferred; original call site unknown
	else
		exposure.tween = TweenService:Create(
			exposure.driver,
			TweenInfo.new(releaseTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Value = 0
			}
		)
		exposure.tween.Completed:Connect(settle)
		exposure.tween:Play()
	end
end

local function hitStop(list, duration)
	if duration <= 0 then
		return
	end

	local v8 = {}

	for _, v9 in ipairs(list) do
		local animator = v9 and v9.Parent and v9:FindFirstChildWhichIsA("Animator", true)

		if not animator then
			continue
		end

		local success, playingAnimationTracks = pcall(animator.GetPlayingAnimationTracks, animator)

		if not success then
			continue
		end

		for _, playingAnimationTrack in ipairs(playingAnimationTracks) do
			if playingAnimationTrack.Speed == 0 then
				continue
			end

			table.insert(v8, { playingAnimationTrack, playingAnimationTrack.Speed })
			playingAnimationTrack:AdjustSpeed(0)
		end
	end

	task.delay(duration, function()
		for _, v9 in ipairs(v8) do
			local v10 = v9[1]
			local v11 = v9[2]

			if v10.IsPlaying and v10.Speed == 0 then
				v10:AdjustSpeed(v11)
			end
		end
	end)
	labPrint(string.format("hit-stop: %d track(s) frozen for %.2fs", #v8, duration))
end

local function applySpotlight(p, humanoidRootPart)
	local part = Instance.new("Part")
	part.Name = "GuardSpotlight"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	part.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, v4.LightHeight, 0))
	local spotLight = Instance.new("SpotLight")
	spotLight.Face = Enum.NormalId.Bottom
	spotLight.Angle = v4.LightAngle
	spotLight.Range = v4.LightRange
	spotLight.Color = v4.LightColor
	spotLight.Shadows = true
	spotLight.Brightness = 0
	spotLight.Parent = part
	part.Parent = workspace
	TweenService:Create(spotLight, TweenInfo.new(v4.TakeTime + 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Brightness = v4.LightBrightness
	}):Play()
	local part2 = Instance.new("Part")
	part2.Name = "GuardLightShaft"
	part2.Shape = Enum.PartType.Cylinder
	part2.Material = Enum.Material.Neon
	part2.Color = v4.LightColor
	part2.Anchored = true
	part2.CanCollide = false
	part2.CanQuery = false
	part2.CanTouch = false
	part2.CastShadow = false
	part2.Transparency = 1
	local v8 = v4.ShaftTopRadius * 2
	part2.Size = Vector3.new(v4.LightHeight, v8, v8)
	part2.CFrame = CFrame.new(humanoidRootPart.Position + Vector3.new(0, v4.LightHeight / 2 - 2, 0)) * CFrame.Angles(
		0,
		0,
		1.5707963267948966
	)
	part2.Parent = workspace
	TweenService:Create(part2, TweenInfo.new(v4.TakeTime + 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = v4.ShaftTransparency
	}):Play()
	local pointLight = Instance.new("PointLight")
	pointLight.Name = "GuardFill"
	pointLight.Color = v4.FillColor
	pointLight.Range = v4.FillRange
	pointLight.Brightness = 0
	pointLight.Parent = humanoidRootPart
	TweenService:Create(pointLight, TweenInfo.new(v4.TakeTime + 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Brightness = v4.FillBrightness
	}):Play()
	p.spotlight = part
	p.shaft = part2
	p.fill = pointLight
end

local function applyCameraKey(p)
	if v4.KeyBrightness <= 0 then
		return
	end

	local part = Instance.new("Part")
	part.Name = "GuardCameraKey"
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Transparency = 1
	part.Size = createVector(1, 1, 1)
	local spotLight = Instance.new("SpotLight")
	spotLight.Face = Enum.NormalId.Front
	spotLight.Angle = v4.KeyAngle
	spotLight.Range = v4.KeyRange
	spotLight.Color = v4.KeyColor
	spotLight.Shadows = false
	spotLight.Brightness = 0
	spotLight.Parent = part
	part.Parent = workspace
	TweenService:Create(spotLight, TweenInfo.new(v4.TakeTime + 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Brightness = v4.KeyBrightness
	}):Play()
	p.key = part
end

local function placePortraitLights(state, data, p)
	local key = state.key
	local spotLight = key and key:FindFirstChildOfClass("SpotLight")

	if not spotLight then
		return
	end

	local vector2 = Vector3.new(data.eye.X - data.focus.X, 0, data.eye.Z - data.focus.Z)

	if vector2.Magnitude < 0.1 then
		return
	end

	local unit = vector2.Unit
	local vector3 = Vector3.new(-unit.Z, 0, unit.X)

	if p and Vector3.new(p.X - data.focus.X, 0, p.Z - data.focus.Z):Dot(vector3) > 0 then
		vector3 = -vector3
	end

	local height = data.height
	local v8 = math.max(v4.PortraitKeyDistance, height * 0.6)
	local angle = math.clamp(math.deg(math.atan((height * 0.5 + 1) / v8) * 2), 60, 120)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function reachFor(portraitKeyLiftShare)
		return math.sqrt(v8 * v8 + (height * 0.5 + height * portraitKeyLiftShare) ^ 2) + 1
	end

	local range = reachFor(v4.PortraitKeyLiftShare) -- equivalent call inferred; original call site unknown
	local portraitKeySideDegrees = math.rad(v4.PortraitKeySideDegrees)
	local v11 = data.focus + (unit * math.cos(portraitKeySideDegrees) + vector3 * math.sin(portraitKeySideDegrees)) * v8 + Vector3.new(
		0,
		height * v4.PortraitKeyLiftShare,
		0
	)
	key.CFrame = CFrame.lookAt(v11, data.focus)
	spotLight.Range = range
	spotLight.Angle = angle
	state.keyFixed = true

	if v4.PortraitRimBrightness > 0 then
		local portraitRimSideDegrees = math.rad(v4.PortraitRimSideDegrees)
		local v12 = data.focus + (-unit * math.cos(portraitRimSideDegrees) - vector3 * math.sin(portraitRimSideDegrees)) * v8 + Vector3.new(
			0,
			height * v4.PortraitRimLiftShare,
			0
		)
		local part = Instance.new("Part")
		part.Name = "GuardRimLight"
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.CastShadow = false
		part.Transparency = 1
		part.Size = createVector(1, 1, 1)
		part.CFrame = CFrame.lookAt(v12, data.focus)
		local spotLight2 = Instance.new("SpotLight")
		spotLight2.Face = Enum.NormalId.Front
		spotLight2.Angle = angle
		spotLight2.Range = reachFor(v4.PortraitRimLiftShare)
		spotLight2.Color = v4.PortraitRimColor
		spotLight2.Shadows = false
		spotLight2.Brightness = 0
		spotLight2.Parent = part
		part.Parent = workspace
		TweenService:Create(
			spotLight2,
			TweenInfo.new(v4.TakeTime + 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Brightness = v4.PortraitRimBrightness
			}
		):Play()
		state.rim = part
	end

	labPrint(string.format(
		"portrait lights: key %.1f studs off, cone %.0f, reach %.1f; rim %s",
		v8,
		angle,
		range,
		(tostring(state.rim ~= nil))
	))
end

local function dimToonLights(p, humanoidRootPart)
	local toonLightDim = v4.ToonLightDim

	if toonLightDim <= 0 or toonLightDim >= 1 then
		return
	end

	local lights = {}

	for _, light in ipairs(humanoidRootPart:GetChildren()) do
		if not (light.Name == "ToonLight" or light.Name == "ExtraLight") then
			continue
		end

		local v8 = light:IsA("Light") and { light } or light:GetChildren()

		for _, light2 in ipairs(v8) do
			if not light2:IsA("Light") then
				continue
			end

			labPrint(string.format(
				"toon light %s: colour %s, brightness %.2f, range %.1f (x%.2f for the shot)",
				light.Name,
				tostring(light2.Color),
				light2.Brightness,
				light2.Range,
				toonLightDim
			))
			light2.Brightness *= toonLightDim
			table.insert(lights, light2)
		end
	end

	p.toonLights = {
		lights = lights,
		factor = toonLightDim
	}
end

local function restoreToonLights(p)
	local toonLights = p.toonLights
	p.toonLights = nil

	if not toonLights then
		return
	end

	for _, light in ipairs(toonLights.lights) do
		if light.Parent then
			light.Brightness /= toonLights.factor
		end
	end
end

local function releaseSpotlight(state)
	local shaft = state.shaft
	local fill = state.fill
	state.shaft = nil
	state.fill = nil
	local rim = state.rim
	state.rim = nil

	if rim then
		local spotLight = rim:FindFirstChildOfClass("SpotLight")

		if spotLight then
			local tween = TweenService:Create(
				spotLight,
				TweenInfo.new(v4.ReleaseTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Brightness = 0
				}
			)
			tween.Completed:Connect(function()
				rim:Destroy()
			end)
			tween:Play()
		else
			rim:Destroy()
		end
	end

	local key = state.key
	state.key = nil

	if key then
		local spotLight = key:FindFirstChildOfClass("SpotLight")

		if spotLight then
			local tween = TweenService:Create(
				spotLight,
				TweenInfo.new(v4.ReleaseTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					Brightness = 0
				}
			)
			tween.Completed:Connect(function()
				key:Destroy()
			end)
			tween:Play()
		else
			key:Destroy()
		end
	end

	if shaft then
		local tween = TweenService:Create(
			shaft,
			TweenInfo.new(v4.ReleaseTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Transparency = 1
			}
		)
		tween.Completed:Connect(function()
			shaft:Destroy()
		end)
		tween:Play()
	end

	if fill then
		local tween = TweenService:Create(
			fill,
			TweenInfo.new(v4.ReleaseTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Brightness = 0
			}
		)
		tween.Completed:Connect(function()
			fill:Destroy()
		end)
		tween:Play()
	end

	local spotlight = state.spotlight

	if not spotlight then
		return
	end

	state.spotlight = nil
	local spotLight = spotlight:FindFirstChildOfClass("SpotLight")

	if not spotLight then
		spotlight:Destroy()
		return
	end

	local tween = TweenService:Create(
		spotLight,
		TweenInfo.new(v4.ReleaseTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Brightness = 0
		}
	)
	tween.Completed:Connect(function()
		spotlight:Destroy()
	end)
	tween:Play()
end

local function applyParticles(p, humanoidRootPart)
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "GuardHeroParticles"
	particleEmitter.Texture = "rbxassetid://241876428"
	particleEmitter.Color = v4.ParticleColor
	particleEmitter.LightEmission = 0.6
	particleEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.45), NumberSequenceKeypoint.new(1, 0) })
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 1)
	})
	particleEmitter.Lifetime = NumberRange.new(0.8, 1.4)
	particleEmitter.Speed = NumberRange.new(4, 7)
	particleEmitter.SpreadAngle = Vector2.new(40, 40)
	particleEmitter.Acceleration = createVector(0, 3, 0)
	particleEmitter.Rate = v4.ParticleRate
	particleEmitter.Parent = humanoidRootPart
	particleEmitter:Emit(v4.ParticleBurst)
	p.emitter = particleEmitter
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseParticles(p)
	local emitter = p.emitter

	if not emitter then
		return
	end

	p.emitter = nil
	emitter.Rate = 0
	task.delay(1.5, function()
		emitter:Destroy()
	end)
end

local function buildLetterbox()
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return nil
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SoulvesterHeroLetterbox"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 4

	local function bar(p, p2)
		local frame = Instance.new("Frame")
		frame.AnchorPoint = Vector2.new(0.5, p)
		frame.Position = UDim2.new(0.5, 0, p2, 0)
		frame.Size = UDim2.new(1, 0, 0, 0)
		frame.BackgroundColor3 = Color3.new(0, 0, 0)
		frame.BorderSizePixel = 0
		local frame2 = Instance.new("Frame")
		frame2.AnchorPoint = Vector2.new(0.5, p == 0 and 1 or 0)
		frame2.Position = UDim2.new(0.5, 0, p == 0 and 1 or 0, 0)
		frame2.Size = UDim2.new(1, 0, 0, 1)
		frame2.BackgroundColor3 = Color3.fromRGB(236, 208, 132)
		frame2.BackgroundTransparency = 0.45
		frame2.BorderSizePixel = 0
		frame2.Parent = frame
		frame.Parent = screenGui
		TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 0.085, 0)
		}):Play()
		return frame
	end

	local top = bar(0, 0)
	local bottom = bar(1, 1)
	screenGui.Parent = playerGui
	return {
		gui = screenGui,
		top = top,
		bottom = bottom
	}
end

local function releaseLetterbox(p, p2)
	local letterbox = p.letterbox

	if not letterbox then
		return
	end

	p.letterbox = nil

	if p2 or not letterbox.gui.Parent then
		letterbox.gui:Destroy()
		return
	end

	local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
	TweenService:Create(letterbox.top, tweenInfo, {
		Size = UDim2.new(1, 0, 0, 0)
	}):Play()
	local tween = TweenService:Create(letterbox.bottom, tweenInfo, {
		Size = UDim2.new(1, 0, 0, 0)
	})
	tween.Completed:Connect(function()
		letterbox.gui:Destroy()
	end)
	tween:Play()
end

local function buildVignette(data)
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return nil
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SoulvesterHeroVignette"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = -3
	local thickness = data.thickness

	local function edge(size, position, rotation)
		local frame = Instance.new("Frame")
		frame.BackgroundColor3 = data.color
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.Size = size
		frame.Position = position
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Rotation = rotation
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
		uIGradient.Parent = frame
		frame.Parent = screenGui
		TweenService:Create(frame, TweenInfo.new(v4.TakeTime + 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundTransparency = data.transparency
		}):Play()
	end

	edge(UDim2.new(1, 0, thickness, 0), UDim2.new(0, 0, 0, 0), 90)
	edge(UDim2.new(1, 0, thickness, 0), UDim2.new(0, 0, 1 - thickness, 0), -90)
	edge(UDim2.new(thickness, 0, 1, 0), UDim2.new(0, 0, 0, 0), 0)
	edge(UDim2.new(thickness, 0, 1, 0), UDim2.new(1 - thickness, 0, 0, 0), 180)
	screenGui.Parent = playerGui
	return screenGui
end

local v8 = nil

local function storybookHatch()
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")
	local currentCamera = camera() -- equivalent call inferred; original call site unknown

	if not (playerGui and currentCamera) then
		return nil
	end

	local viewportSize = currentCamera.ViewportSize

	if v8 and v8.gui.Parent == playerGui and v8.size == viewportSize then
		return v8
	end

	if v8 then
		v8.gui:Destroy()
	end

	local storybookHatch2 = v4.StorybookHatch
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SoulvesterHeroHatch"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 3
	screenGui.Enabled = false
	local canvasGroup = Instance.new("CanvasGroup")
	canvasGroup.Size = UDim2.fromScale(1, 1)
	canvasGroup.BackgroundTransparency = 1
	canvasGroup.GroupTransparency = 1
	canvasGroup.Parent = screenGui
	screenGui.Parent = playerGui
	local v10 = {
		gui = screenGui,
		group = canvasGroup,
		size = viewportSize,
		ready = false
	}
	v8 = v10
	local v11 = viewportSize.X + viewportSize.Y * 2
	local v12 = {}

	for _, rotation in ipairs({ storybookHatch2.angle, -storybookHatch2.angle }) do
		for i = -viewportSize.Y, viewportSize.X + viewportSize.Y, storybookHatch2.spacing do
			table.insert(v12, {
				x = i,
				rotation = rotation
			})
		end
	end

	task.spawn(function()
		for i, v13 in ipairs(v12) do
			if v8 ~= v10 then
				return
			end

			local frame = Instance.new("Frame")
			frame.AnchorPoint = Vector2.new(0.5, 0.5)
			frame.Position = UDim2.new(0, v13.x, 0.5, 0)
			frame.Size = UDim2.new(0, 1, 0, v11)
			frame.Rotation = v13.rotation
			frame.BackgroundColor3 = storybookHatch2.color
			frame.BorderSizePixel = 0
			frame.Parent = canvasGroup

			if i % 150 == 0 then
				task.wait()
			end
		end

		v10.ready = true
		labPrint(string.format("storybook hatch built: %d lines for %dx%d", #v12, viewportSize.X, viewportSize.Y))
	end)
	return v10
end

local function buildStorybook()
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")

	if not playerGui then
		return nil
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SoulvesterHeroPaper"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 2
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = v4.StorybookPaper.color
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Parent = screenGui
	screenGui.Parent = playerGui
	local tweenInfo = TweenInfo.new(v4.TakeTime + 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(frame, tweenInfo, {
		BackgroundTransparency = v4.StorybookPaper.transparency
	}):Play()
	local hatch

	if v4.StorybookHatch.enabled then
		hatch = storybookHatch()
	end

	if hatch then
		hatch.gui.Enabled = true
		TweenService:Create(hatch.group, tweenInfo, {
			GroupTransparency = v4.StorybookHatch.transparency
		}):Play()
	end

	return {
		paperGui = screenGui,
		paper = frame,
		hatch = hatch,
		nextFlick = 0
	}
end

local function flickerStorybook(storybook, now)
	if now < storybook.nextFlick then
		return
	end

	local storybookFlicker = v4.StorybookFlicker
	storybook.nextFlick = now + 1 / storybookFlicker.rate
	storybook.paper.BackgroundTransparency = v4.StorybookPaper.transparency + (math.random() * 2 - 1) * storybookFlicker.paper

	if storybook.hatch and storybook.hatch.gui.Enabled then
		storybook.hatch.group.GroupTransparency = v4.StorybookHatch.transparency + (math.random() * 2 - 1) * storybookFlicker.hatch
	end
end

local function releaseStorybook(p, p2)
	local storybook = p.storybook

	if not storybook then
		return
	end

	p.storybook = nil
	local hatch = storybook.hatch

	if p2 then
		storybook.paperGui:Destroy()

		if hatch and hatch.gui.Parent then
			hatch.group.GroupTransparency = 1
			hatch.gui.Enabled = false
		end
	else
		local tweenInfo = TweenInfo.new(v4.ReleaseTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = TweenService:Create(storybook.paper, tweenInfo, {
			BackgroundTransparency = 1
		})
		tween.Completed:Connect(function()
			storybook.paperGui:Destroy()
		end)
		tween:Play()

		if hatch and hatch.gui.Parent then
			local tween2 = TweenService:Create(hatch.group, tweenInfo, {
				GroupTransparency = 1
			})
			tween2.Completed:Connect(function(p3)
				if p3 == Enum.PlaybackState.Completed and not (v5 and v5.storybook) then
					hatch.gui.Enabled = false
				end
			end)
			tween2:Play()
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function smooth(value)
	local v9 = math.clamp(value, 0, 1)
	return v9 * v9 * (3 - 2 * v9)
end

local function orbitEye(ownEye, ownFocus, p, p2, p3)
	local lerped = ownFocus:Lerp(p2, p3)
	local v9 = ownEye - ownFocus
	local v10 = p - p2
	local magnitude = v9.Magnitude
	local magnitude2 = v10.Magnitude

	if magnitude < 0.05 or magnitude2 < 0.05 then
		return ownEye:Lerp(p, p3)
	end

	local unit = v9.Unit
	local unit2 = v10.Unit
	local cross = unit:Cross(unit2)

	if cross.Magnitude < 0.0001 then
		if not (unit:Dot(unit2) > 0) then
			local cross2 = unit:Cross(createVector(0, 1, 0))

			if cross2.Magnitude < 0.1 then
				cross2 = unit:Cross(createVector(1, 0, 0))
			end

			unit = CFrame.fromAxisAngle(cross2.Unit, 3.141592653589793 * p3):VectorToWorldSpace(unit)
		end
	else
		local v11 = math.acos((math.clamp(unit:Dot(unit2), -1, 1)))
		unit = CFrame.fromAxisAngle(cross.Unit, v11 * p3):VectorToWorldSpace(unit)
	end

	return lerped + unit * (magnitude + (magnitude2 - magnitude) * p3)
end

local function arcFrame(arcAnchor, value)
	local storyVictimFraction = v4.StoryVictimFraction
	local v9

	if storyVictimFraction > 0 then
		v9 = smooth(value / storyVictimFraction) or 1
	else
		v9 = 1
	end

	local v10 = not (storyVictimFraction < 1) and 0 or math.clamp(
		(value - storyVictimFraction) / (1 - storyVictimFraction),
		0,
		1
	) or 0
	local v11 = math.clamp(v10 + v4.ApexHang * math.sin(6.283185307179586 * v10), 0, 1)
	local v12 = math.sin(v11 * 3.141592653589793)
	local perpAngle = arcAnchor.perpAngle
	local v13 = nil
	local v14 = nil
	local v15 = 0
	local focusApexLift = 0
	local standoffFocus = nil
	local v16 = nil
	local fov

	if v4.Style == "Portrait" and arcAnchor.portrait then
		local portrait = arcAnchor.portrait
		local portraitTransit = SoulvesterGuardCameraCore.portraitTransit(value, v4.PortraitSettle)
		local v17 = smooth((value - v4.PortraitSettle) / math.max(1 - v4.PortraitSettle, 0.01)) -- equivalent call inferred; original call site unknown
		local v18 = portrait.focus + (portrait.eye - portrait.focus) * (1 - v4.PortraitCreep * v17)
		local ownEye = arcAnchor.ownEye or portrait.eye
		local ownFocus = arcAnchor.ownFocus or portrait.focus
		local ownFov = arcAnchor.ownFov or v4.Fov
		v16 = orbitEye(ownEye, ownFocus, v18, portrait.focus, portraitTransit)
		standoffFocus = ownFocus:Lerp(portrait.focus, portraitTransit)
		fov = ownFov + (portrait.fov - ownFov) * portraitTransit
		v9 = 1
	elseif v4.Style == "Swoop" then
		local swoopApex = arcAnchor.swoopApex
		local v17 = math.clamp(
			value - v4.ApexHang * (math.sin(6.283185307179586 * (value - swoopApex)) - math.sin(-6.283185307179586 * swoopApex)),
			0,
			1
		)
		local v18 = math.sin((v17 < swoopApex and v17 / swoopApex * 0.5 or 0.5 + (v17 - swoopApex) / (1 - swoopApex) * 0.5) * 3.141592653589793)
		perpAngle = arcAnchor.ownAngle + math.rad(v4.SwoopDegrees) * arcAnchor.swoopDirection * v17
		local v19 = math.max(
			math.min(arcAnchor.ownDistance * v4.SwoopStartScale, v4.SwoopStartMax),
			arcAnchor.swoopApexDistance
		)
		v13 = v19 + (arcAnchor.swoopApexDistance - v19) * v18
		v14 = v4.HeightStart + (v4.HeightApex - v4.HeightStart) * v18
		fov = v4.Fov * (1 + (v4.FovApexScale - 1) * v18)
		focusApexLift = v4.FocusApexLift * v18

		if v4.SwoopBank ~= 0 then
			local v20 = math.abs(1 - v4.ApexHang * 2 * 3.141592653589793 * math.cos(6.283185307179586 * (value - swoopApex))) / (1 + v4.ApexHang * 2 * 3.141592653589793)
			local v21 = math.clamp(math.min(value / 0.1, (1 - value) / 0.1), 0, 1)
			v15 = math.rad(v4.SwoopBank) * arcAnchor.swoopDirection * v20 * v21
		end
	elseif v4.Style == "Standoff" then
		perpAngle = arcAnchor.standoffAngle
		local v17 = smooth(value) -- equivalent call inferred; original call site unknown
		v13 = arcAnchor.swoopApexDistance * v4.StandoffDistanceScale * (1 - v4.StandoffPush * v17)
		v14 = v4.HeightApex + v4.StandoffSettle * (1 - smooth(math.min(value * 4, 1)))
		fov = v4.Fov * v4.FovApexScale
		focusApexLift = v4.FocusApexLift
		standoffFocus = arcAnchor.standoffFocus
		v9 = 1
	else
		if v4.Style == "Orbit" then
			perpAngle += 6.283185307179586 * arcAnchor.direction * v11
		else
			perpAngle += math.rad(v4.SweepDegrees) * arcAnchor.direction * v12
		end

		local v17 = arcAnchor.distance * (1 + (v4.DistanceApexScale - 1) * v12)
		local v18 = arcAnchor.heightStart + (arcAnchor.heightApex - arcAnchor.heightStart) * v12
		v13 = v17 * (v4.StoryWideScale + (1 - v4.StoryWideScale) * v9)
		v14 = v18 * (v4.StoryHighScale + (1 - v4.StoryHighScale) * v9)
		fov = v4.Fov
	end

	local v17 = (standoffFocus or arcAnchor.victimFocus:Lerp(arcAnchor.focus, v9)) + Vector3.new(0, focusApexLift, 0)
	local v18 = v16 or arcAnchor.center + Vector3.new(math.cos(perpAngle) * v13, v14, math.sin(perpAngle) * v13)
	return CFrame.lookAt(v18, v17), fov, v17, v15
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.IgnoreWater = true
raycastParams.RespectCanCollide = true

local function clearLine(p, p2)
	local v9 = p2 - p

	if v9.Magnitude < 0.1 then
		return true, nil
	end

	local raycastResult = workspace:Raycast(p, v9, raycastParams)
	return raycastResult == nil, raycastResult
end

local function occlude(position, p, filterDescendantsInstances, p2)
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local v9 = position - p
	local v10, raycastResult

	if v9.Magnitude < 0.1 then
		v10 = true
	else
		raycastResult = workspace:Raycast(p, v9, raycastParams)
		v10 = raycastResult == nil
	end

	if v10 then
		return position, false
	end

	for _, v11 in ipairs(p2 and {} or v4.OcclusionLifts) do
		local v12 = position + Vector3.new(0, v11, 0)
		local v13 = v12 - p

		if v13.Magnitude < 0.1 or workspace:Raycast(p, v13, raycastParams) == nil then
			return v12, true
		end
	end

	local v11 = position - p
	local magnitude = v11.Magnitude
	local v12 = math.max(
		(raycastResult.Position - p).Magnitude - v4.OcclusionMargin,
		p2 and 0 or magnitude * v4.OcclusionPullFloor,
		v4.OcclusionFloor
	)
	return p + v11.Unit * math.min(v12, magnitude), true
end

local function buildArcAnchor(position, casterPos, allyPos, attackerPos, p3)
	local DISTANCE_THRESHOLD = 0.5
	local focusWeights = v4.FocusWeights
	local magnitude = (Vector3.new(position.X, 0, position.Z) - Vector3.new(casterPos.X, 0, casterPos.Z)).Magnitude
	local v9 = position.Y - casterPos.Y
	local v10 = (casterPos * focusWeights.caster + allyPos * focusWeights.ally + (attackerPos or casterPos) * focusWeights.attacker) / (focusWeights.caster + focusWeights.ally + focusWeights.attacker)
	local vector2 = Vector3.new(v10.X, casterPos.Y, v10.Z)
	local focus = vector2 + Vector3.new(0, v4.FocusHeight, 0)
	local v12

	if attackerPos then
		v12 = (allyPos + attackerPos) * 0.5 or allyPos
	else
		v12 = allyPos
	end

	local victimFocus = Vector3.new(v12.X, casterPos.Y, v12.Z) + Vector3.new(0, v4.FocusHeight, 0)
	local v14 = allyPos - (attackerPos or casterPos)
	local vector3 = Vector3.new(v14.X, 0, v14.Z)
	local unit = (vector3.Magnitude < DISTANCE_THRESHOLD and createVector(1, 0, 0) or vector3).Unit
	local v15 = 0

	for _, v16 in ipairs({ casterPos, allyPos, attackerPos }) do
		if v16 then
			v15 = math.max(v15, Vector3.new(v16.X - vector2.X, 0, v16.Z - vector2.Z).Magnitude)
		end
	end

	local v16 = v15 + v4.FitMargin
	local currentCamera = camera() -- equivalent call inferred; original call site unknown
	local viewportSize = currentCamera and currentCamera.ViewportSize or Vector2.new(16, 9)
	local aspect = math.max(viewportSize.X / math.max(viewportSize.Y, 1), 0.5)
	local v19 = math.rad(v4.Fov) * 0.5
	local v20 = v16 / math.tan(math.atan(math.tan(v19) * aspect) * 0.85)
	local distance = math.max(v4.DistanceMin, v20, magnitude * v4.RelativeDistance)
	local v22 = v16 / math.tan(math.atan(math.tan(v19 * v4.FovApexScale) * aspect) * 0.85)
	local swoopApexDistance = math.max(v4.DistanceMin, v22)
	local heightStart = math.max(v4.HeightStart, v9 * v4.RelativeHeight)
	local heightApex = math.max(v4.HeightApex, v9 * v4.RelativeHeight * 0.6)
	local vector4 = Vector3.new(-unit.Z, 0, unit.X)
	local v26 = position - vector2
	local vector5 = Vector3.new(v26.X, 0, v26.Z)

	if vector5.Magnitude > DISTANCE_THRESHOLD and vector5.Unit:Dot(vector4) < 0 then
		vector4 = -vector4 or vector4
	end

	local perpAngle = math.atan2(vector4.Z, vector4.X)
	local direction

	if attackerPos then
		local vector6 = Vector3.new(attackerPos.X - vector2.X, 0, attackerPos.Z - vector2.Z)
		direction = Vector3.new(
			math.cos(perpAngle + math.rad(v4.SweepDegrees)),
			0,
			(math.sin(perpAngle + math.rad(v4.SweepDegrees)))
		):Dot(vector6) >= 0 and 1 or -1
	else
		direction = 1
	end

	local ownAngle = math.atan2(vector5.Z, vector5.X)
	local swoopDirection

	if attackerPos then
		local vector6 = Vector3.new(attackerPos.X - vector2.X, 0, attackerPos.Z - vector2.Z)
		swoopDirection = (math.atan2(vector6.Z, vector6.X) - ownAngle + 3.141592653589793) % 6.283185307179586 - 3.141592653589793 >= 0 and 1 or -1
	else
		swoopDirection = 1
	end

	local swoopApex = math.clamp(
		(perpAngle + 3.141592653589793 - ownAngle) * swoopDirection % 6.283185307179586 / 6.283185307179586,
		0.3,
		0.7
	)
	local standoffAngle, vector6

	if attackerPos then
		local vector7 = Vector3.new(attackerPos.X - vector2.X, 0, attackerPos.Z - vector2.Z)

		if vector7.Magnitude > DISTANCE_THRESHOLD then
			local v33 = math.atan2(vector7.Z, vector7.X) + 3.141592653589793
			local v34 = (ownAngle - v33 + 3.141592653589793) % 6.283185307179586 - 3.141592653589793 >= 0 and 1 or -1
			standoffAngle = v33 + math.rad(v4.StandoffShoulderDegrees) * v34
			local v35 = (casterPos + attackerPos) * 0.5
			vector6 = Vector3.new(v35.X, casterPos.Y + v4.FocusHeight, v35.Z)
		else
			vector6 = focus
			standoffAngle = perpAngle
		end
	else
		vector6 = focus
		standoffAngle = perpAngle
	end

	local vector7 = attackerPos and Vector3.new(attackerPos.X - casterPos.X, 0, attackerPos.Z - casterPos.Z) or p3 and Vector3.new(
		p3.X,
		0,
		p3.Z
	) or createVector(0, 0, 0)
	return {
		casterPos = casterPos,
		allyPos = allyPos,
		attackerPos = attackerPos,
		perp = vector4,
		aspect = aspect,
		portraitFront = vector7.Magnitude > DISTANCE_THRESHOLD and vector7.Unit or nil,
		standoffAngle = standoffAngle,
		standoffFocus = vector6,
		center = vector2,
		focus = focus,
		victimFocus = victimFocus,
		distance = distance,
		perpAngle = perpAngle,
		direction = direction,
		ownAngle = ownAngle,
		ownDistance = math.max(magnitude, v4.DistanceMin * 1.5),
		swoopDirection = swoopDirection,
		swoopApex = swoopApex,
		swoopApexDistance = swoopApexDistance,
		heightStart = heightStart,
		heightApex = heightApex,
		debug = string.format(
			"own camera %.0f studs / %.0f high; fit %.0f; chosen %.0f studs, heights %.1f->%.1f, fov %d, span %.0f",
			magnitude,
			v9,
			v20,
			distance,
			heightStart,
			heightApex,
			v4.Fov,
			v16 * 2
		)
	}
end

local function shotPositions(at, humanoidRootPart, humanoidRootPart2, humanoidRootPart3)
	local v9 = type(at) ~= "table" and {} or at
	local caster

	if typeof(v9.caster) == "CFrame" then
		caster = v9.caster
	else
		caster = humanoidRootPart.CFrame
	end

	local ally

	if typeof(v9.ally) == "Vector3" then
		ally = v9.ally
	else
		ally = humanoidRootPart2.Position
	end

	local v10

	if typeof(v9.attacker) == "Vector3" then
		v10 = v9.attacker
	else
		v10 = humanoidRootPart3 and humanoidRootPart3.Position
	end

	return caster.Position, ally, v10, caster.LookVector
end

local function bodyExtent(folder, humanoidRootPart)
	local humanoid = folder:FindFirstChildOfClass("Humanoid")
	local bottom = -(humanoidRootPart.Size.Y / 2 + (humanoid and humanoid.HipHeight or 2))
	local v10 = -1e999
	local v11 = 1e999

	for _, part in ipairs(folder:GetDescendants()) do
		if not (part:IsA("BasePart") and part.Transparency < 1 and part.Name ~= "HalloweenMask") then
			continue
		end

		if part:FindFirstAncestorOfClass("Accessory") or part:FindFirstAncestor("HalloweenMask") then
			continue
		end

		local cFrame = part.CFrame
		local size = part.Size
		local v12 = 0.5 * (math.abs(cFrame.RightVector.Y) * size.X + math.abs(cFrame.UpVector.Y) * size.Y + math.abs(cFrame.LookVector.Y) * size.Z)
		v10 = math.max(v10, cFrame.Y + v12)
		v11 = math.min(v11, cFrame.Y - v12)
	end

	if v10 < v11 then
		return {
			top = 2.2,
			bottom = bottom
		}
	end

	return {
		top = v10 - humanoidRootPart.Position.Y,
		bottom = math.min(v11 - humanoidRootPart.Position.Y, bottom)
	}
end

local function resolvePortrait(data, filterDescendantsInstances, p, p2)
	raycastParams.FilterDescendantsInstances = filterDescendantsInstances
	local casterPos = data.casterPos
	local height = math.clamp(p.top - p.bottom, 3, 16)
	local v10 = math.max(
		v4.PortraitDistance,
		height / (v4.PortraitFrameSpan * math.tan(math.rad(v4.PortraitFovPreferred) / 2))
	)
	local v11 = casterPos.Y + p.bottom + height * v4.PortraitFocusShare
	local v12 = Vector3.new(data.allyPos.X - casterPos.X, 0, data.allyPos.Z - casterPos.Z) * v4.PortraitAllyBias

	if v12.Magnitude > v4.PortraitAllyLeanMax then
		v12 = v12.Unit * v4.PortraitAllyLeanMax
	end

	local focus = Vector3.new(casterPos.X, v11, casterPos.Z) + v12
	local vector2 = Vector3.new(casterPos.X, v11 - v4.PortraitLookUp, casterPos.Z)
	local vector3 = Vector3.new(casterPos.X, v11 - v4.PortraitHeroLookUp, casterPos.Z)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function direction(p3, portraitTurn)
		if not data.portraitFront then
			return p3
		end

		local v14 = math.rad(portraitTurn)
		local v15 = p3 * math.cos(v14) + data.portraitFront * math.sin(v14)

		if v15.Magnitude > 0.1 then
			return v15.Unit
		end

		return p3
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function crowdsTwisted(p3)
		local attackerPos = data.attackerPos

		if attackerPos then
			return Vector3.new(p3.X - attackerPos.X, 0, p3.Z - attackerPos.Z).Magnitude < p2 + v4.PortraitTwistedClearance
		end

		return false
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function freeToward(p3)
		local v14 = p3 - focus
		local raycastResult = workspace:Raycast(focus, v14.Unit * (v14.Magnitude + v4.OcclusionMargin), raycastParams)

		if raycastResult then
			return (raycastResult.Position - focus).Magnitude - v4.OcclusionMargin
		end

		return 1e999
	end

	local function fovFor(p3)
		return (math.clamp(
			math.deg(math.atan(height / (v4.PortraitFrameSpan * (focus - p3).Magnitude)) * 2),
			v4.PortraitFovMin,
			v4.PortraitFovMax
		))
	end

	local function twistedFrameX(p3)
		local attackerPos = data.attackerPos
		local unit = (focus - p3).Unit
		local unit2 = unit:Cross(createVector(0, 1, 0)).Unit
		local v14 = math.tan((math.atan(math.tan(math.rad((math.clamp(
			math.deg(math.atan(height / (v4.PortraitFrameSpan * (focus - p3).Magnitude)) * 2),
			v4.PortraitFovMin,
			v4.PortraitFovMax
		))) / 2) * data.aspect)))
		local vector4 = attackerPos + createVector(0, 1, 0) - p3
		local vector5 = casterPos - p3
		local dot = vector4:Dot(unit)
		local dot2 = vector5:Dot(unit)

		if dot <= 0.5 or dot2 <= 0.5 then
			return nil
		end

		local v15 = vector4:Dot(unit2) / dot / v14
		local v16 = vector5:Dot(unit2) / dot2 / v14
		local v17 = (p2 / dot + v4.PortraitCasterHalfWidth / dot2) / v14

		if math.abs(v15) < v4.PortraitTwistedMinX or math.abs(v15) > v4.PortraitTwistedMaxX or math.abs(v15 - v16) <= v17 then
			return nil
		end

		return v15
	end

	local function pathBlocks(p3)
		if not (data.ownEye and data.ownFocus) then
			return 0
		end

		local count2 = 0

		for i = 1, 7 do
			local v14 = i / 8
			local lerped = data.ownFocus:Lerp(focus, v14)
			local v15 = orbitEye(data.ownEye, data.ownFocus, p3, focus, v14) - lerped

			if v15.Magnitude < 0.1 or workspace:Raycast(lerped, v15, raycastParams) == nil then
				continue
			end

			count2 += 1
		end

		return count2
	end

	local v14 = {
		crowd = 0,
		wall = 0,
		composition = 0
	}
	local v15 = nil
	local v16 = nil

	if data.attackerPos and data.portraitFront then
		local magnitude = Vector3.new(data.attackerPos.X - casterPos.X, 0, data.attackerPos.Z - casterPos.Z).Magnitude
		local portraitFront = data.portraitFront
		local vector4 = Vector3.new(-portraitFront.Z, 0, portraitFront.X)

		for _, side in ipairs({ data.perp, -data.perp }) do
			local v19

			if vector4:Dot(side) >= 0 then
				v19 = vector4
			else
				v19 = -vector4
			end

			local score = 1e999
			local v21 = nil

			for _, portraitHeroAngle in ipairs(v4.PortraitHeroAngles) do
				local v22 = math.rad(portraitHeroAngle)
				local v23 = portraitFront * math.cos(v22) + v19 * math.sin(v22)

				for _, portraitHeroDistanceScale in ipairs(v4.PortraitHeroDistanceScales) do
					local v24 = math.min(
						math.max(v10, magnitude * portraitHeroDistanceScale),
						v4.PortraitHeroMaxDistance
					)
					local eye = vector3 + v23 * v24
					local v26 = nil

					-- equivalent call inferred; original call site unknown
					if crowdsTwisted(eye) then
						v14.crowd += 1
					elseif freeToward(eye) < (eye - focus).Magnitude then
						v14.wall += 1
					else
						v26 = twistedFrameX(eye)

						if not v26 then
							v14.composition += 1
						end
					end

					if not v26 then
						continue
					end

					local v27 = math.max(
						math.abs(math.abs(v26) - v4.PortraitTwistedTargetX) - v4.PortraitTwistedBand,
						0
					)
					local heroAnglePenalty = SoulvesterGuardCameraCore.heroAnglePenalty(
						portraitHeroAngle,
						v4.PortraitHeroPreferredAngle,
						v4.PortraitHeroAngleWeight
					)
					local blocks = pathBlocks(eye)
					local v29 = v27 + heroAnglePenalty + v24 * 0.006 + blocks

					if not (v29 < score) then
						continue
					end

					v21 = {
						side = side,
						turn = 90 - portraitHeroAngle,
						eye = eye,
						hero = true,
						blocks = blocks
					}
					score = v29
				end
			end

			if v21 and (not v15 or score < v15.score) then
				v21.score = score
				v15 = v21
			end

			if v15 and v15.blocks == 0 then
				break
			end
		end
	end

	local v17 = nil

	if not v15 then
		for _, side in ipairs({ data.perp, -data.perp }) do
			for _, portraitTurn in ipairs(v4.PortraitTurns) do
				local dir = direction(side, portraitTurn) -- equivalent call inferred; original call site unknown
				local eye = vector2 + dir * v10

				-- equivalent call inferred; original call site unknown
				if crowdsTwisted(eye) then
					continue
				end

				local magnitude = (eye - focus).Magnitude
				local free = freeToward(eye) -- equivalent call inferred; original call site unknown

				if magnitude <= free then
					local blocks = pathBlocks(eye)

					if blocks == 0 then
						v15 = {
							side = side,
							turn = portraitTurn,
							eye = eye,
							blocks = 0
						}
						break
					else
						v17 = (not v17 or blocks < v17.blocks) and {
							side = side,
							turn = portraitTurn,
							eye = eye,
							blocks = blocks
						} or v17
					end
				end

				if not v16 or v16.free < free then
					v16 = {
						side = side,
						dir = dir,
						turn = portraitTurn,
						free = free,
						want = magnitude
					}
				end
			end

			if v15 then
				break
			end
		end
	end

	local v18 = v15 or v17 or v15
	local v19 = v18 ~= nil

	if v18 or not v16 then
		if not v18 then
			local perp = data.perp
			local portraitTurn = v4.PortraitTurns[1]

			if data.portraitFront then
				local v20 = math.rad(portraitTurn)
				local v21 = perp * math.cos(v20) + data.portraitFront * math.sin(v20)

				if v21.Magnitude > 0.1 then
					perp = v21.Unit
				end
			end

			v18 = {
				side = data.perp,
				turn = v4.PortraitTurns[1],
				eye = vector2 + perp * v10
			}
		end
	else
		local v20 = math.max(v10 * math.clamp(v16.free / v16.want, 0, 1), v4.PortraitMinDistance)
		v18 = {
			side = v16.side,
			turn = v16.turn,
			eye = vector2 + v16.dir * v20
		}
	end

	local fov = math.clamp(
		math.deg(math.atan(height / (v4.PortraitFrameSpan * (focus - v18.eye).Magnitude)) * 2),
		v4.PortraitFovMin,
		v4.PortraitFovMax
	)
	labPrint(string.format(
		"portrait: %s, %s side, %d deg off his facing, %.1f studs, fov %.0f, clear=%s, body %.1f studs, move blocked %s/%d; hero rejects crowd=%d wall=%d composition=%d",
		v18.hero and "HERO front view" or "side-on fallback",
		v18.side == data.perp and "near" or "far",
		90 - v18.turn,
		(v18.eye - focus).Magnitude,
		fov,
		tostring(v19),
		height,
		tostring(v18.blocks or "?"),
		7,
		v14.crowd,
		v14.wall,
		v14.composition
	))
	return {
		eye = v18.eye,
		focus = focus,
		fov = fov,
		height = height
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cutRelease()
	local v9 = v6

	if not v9 then
		return
	end

	v6 = nil
	v9.cut = true

	if v9.camTween then
		v9.camTween:Cancel()
	end

	if v9.effectTween then
		v9.effectTween:Cancel()
	end

	if v9.effect then
		v9.effect:Destroy()
	end
end

function SoulvesterGuardCinematic.release(p)
	local v9 = v5

	if v9 then
		v5 = nil
		disconnectAll(v9.conns) -- equivalent call inferred; original call site unknown
		cutRelease() -- equivalent call inferred; original call site unknown
		releasePose(v9)
		releaseHoldAnimation(v9) -- equivalent call inferred; original call site unknown
		releaseSpotlight(v9)
		restoreToonLights(v9)
		local exposure, hud

		if p and v9.cameraTaken then
			exposure = v9.exposure
			v9.exposure = nil
			hud = v9.hud
			v9.hud = nil
		end

		releaseExposure(v9, v4.ReleaseTime)

		if v9.hud then
			v9.hud:release()
			v9.hud = nil
		end

		releaseParticles(v9) -- equivalent call inferred; original call site unknown
		releaseLetterbox(v9, p == true)
		releaseStorybook(v9, p == true)
		fadeSound(v9.riser, p and 0.05 or v4.ReleaseTime)
		v9.riser = nil
		local currentCamera = camera() -- equivalent call inferred; original call site unknown

		if v9.cameraTaken then
			if p then
				if v9.effect then
					v9.effect:Destroy()
				end

				if v9.bloom then
					v9.bloom:Destroy()
				end

				if v9.dof then
					v9.dof:Destroy()
				end

				if v9.vignette then
					v9.vignette:Destroy()
				end

				return {
					savedFov = v9.savedFov,
					savedCFrame = v9.savedCFrame,
					savedRoot = v9.savedRoot,
					exposure = exposure,
					hud = hud
				}
			else
				local v11 = {
					effect = v9.effect,
					savedFov = v9.savedFov,
					savedCFrame = v9.savedCFrame,
					savedRoot = v9.savedRoot,
					cut = false,
					camTween = nil,
					effectTween = nil
				}
				v6 = v11

				if v9.bloom then
					local bloom = v9.bloom
					local tween = TweenService:Create(
						bloom,
						TweenInfo.new(v4.ReleaseTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Intensity = 0
						}
					)
					tween.Completed:Connect(function()
						bloom:Destroy()
					end)
					tween:Play()
				end

				if v9.dof then
					local dof = v9.dof
					local tween = TweenService:Create(
						dof,
						TweenInfo.new(v4.ReleaseTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							NearIntensity = 0,
							FarIntensity = 0
						}
					)
					tween.Completed:Connect(function()
						dof:Destroy()
					end)
					tween:Play()
				end

				if v9.vignette then
					local vignette = v9.vignette

					for _, child in ipairs(vignette:GetChildren()) do
						TweenService:Create(
							child,
							TweenInfo.new(v4.ReleaseTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								BackgroundTransparency = 1
							}
						):Play()
					end

					task.delay(v4.ReleaseTime + 0.05, function()
						vignette:Destroy()
					end)
				end

				if v9.effect then
					v11.effectTween = TweenService:Create(
						v9.effect,
						TweenInfo.new(v4.ReleaseTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							Saturation = 0,
							Brightness = 0,
							Contrast = 0,
							TintColor = Color3.fromRGB(255, 255, 255)
						}
					)
					v11.effectTween.Completed:Connect(function()
						if v6 == v11 then
							v6 = nil
						end

						v11.effect:Destroy()
					end)
					v11.effectTween:Play()
				end

				if currentCamera then
					v11.camTween = TweenService:Create(
						currentCamera,
						TweenInfo.new(v4.ReleaseTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
						{
							CFrame = v9.savedCFrame,
							FieldOfView = v9.savedFov
						}
					)
					v11.camTween.Completed:Connect(function(p2)
						if p2 == Enum.PlaybackState.Completed and not (v5 and v5.cameraTaken) then
							currentCamera.FieldOfView = v9.savedFov
							giveBackCamera() -- equivalent call inferred; original call site unknown
						end
					end)
					v11.camTween:Play()
					task.delay(v4.ReleaseTime + 1, function()
						if v11.cut then
							return
						end

						if not (v5 and v5.cameraTaken) and v then
							v:release()
							v = nil
						end
					end)
				else
					giveBackCamera() -- equivalent call inferred; original call site unknown
				end

				return nil
			end
		else
			if v9.effect then
				v9.effect:Destroy()
			end

			if v9.bloom then
				v9.bloom:Destroy()
			end

			if v9.dof then
				v9.dof:Destroy()
			end

			if v9.vignette then
				v9.vignette:Destroy()
			end

			return nil
		end
	else
		local v10 = v6

		if p and v10 and v10.savedCFrame then
			return {
				savedFov = v10.savedFov,
				savedCFrame = v10.savedCFrame,
				savedRoot = v10.savedRoot
			}
		end

		return nil
	end
end

function SoulvesterGuardCinematic.isActive()
	local v9 = v7

	if not v9 then
		if v5 == nil then
			return false
		else
			return v5.cameraTaken == true
		end
	end

	return v9
end

function SoulvesterGuardCinematic.claim()
	v7 = true
end

function SoulvesterGuardCinematic.unclaim()
	v7 = false
end

function SoulvesterGuardCinematic.play(instance, instance2, instance3, value, options)
	v7 = false
	local v9 = options or {}
	v4 = tuned(v9.tuning)
	local currentCamera = camera() -- equivalent call inferred; original call site unknown
	local humanoidRootPart = instance2 and instance2:FindFirstChild("HumanoidRootPart")
	local humanoidRootPart2 = instance and instance:FindFirstChild("HumanoidRootPart")

	if not (currentCamera and humanoidRootPart and humanoidRootPart2) then
		labPrint("hero shot skipped: missing camera / caster root / ally root")
		return
	end

	local v11 = instance2 == Players.LocalPlayer.Character
	local v12 = math.max(math.max(value or 1, 0.4) - v4.TakeTime - v4.ReleaseTime, 0.2)
	local v13 = v11 and v9.camera ~= false
	local v14 = SoulvesterGuardCinematic.release(v13)
	local v15 = v13 and v6

	if v15 then
		v6 = nil
		v15.cut = true

		if v15.camTween then
			v15.camTween:Cancel()
		end

		if v15.effectTween then
			v15.effectTween:Cancel()
		end

		if v15.effect then
			v15.effect:Destroy()
		end
	end

	count += 1
	local v16 = {
		token = count,
		conns = {},
		cameraTaken = false,
		lastEye = nil,
		lastEyeAt = nil,
		key = nil
	}
	v5 = v16

	if v14 and v14.exposure then
		v16.exposure = v14.exposure
	end

	if v14 and v14.hud then
		v16.hud = v14.hud
	end

	local localPlayer = Players.LocalPlayer

	if localPlayer then
		table.insert(v16.conns, localPlayer.CharacterRemoving:Connect(function()
			SoulvesterGuardCinematic.release()
		end))
	end

	local humanoid = instance2:FindFirstChildOfClass("Humanoid")

	if humanoid then
		table.insert(v16.conns, humanoid.Died:Connect(function()
			SoulvesterGuardCinematic.release()
		end))
	end

	table.insert(v16.conns, instance2.AncestryChanged:Connect(function()
		if not instance2:IsDescendantOf(workspace) then
			SoulvesterGuardCinematic.release()
		end
	end))
	local info = workspace:FindFirstChild("Info")
	local floorActive = info and info:FindFirstChild("FloorActive")

	if floorActive then
		table.insert(v16.conns, floorActive.Changed:Connect(function()
			SoulvesterGuardCinematic.release()
		end))
	end

	applyHoldAnimation(v16, instance2, v9.animation)
	local revealDelay = tonumber(v9.revealDelay) or 0
	task.delay(revealDelay, function()
		if v5 ~= v16 or not (instance2.Parent and humanoidRootPart.Parent) then
			return
		end

		local head = (v9.particles ~= false and instance ~= instance2 and instance.Parent and true or false) and (instance:FindFirstChild("Head") or instance:FindFirstChild("HumanoidRootPart"))

		if head then
			local particleEmitter = Instance.new("ParticleEmitter")
			particleEmitter.Texture = "rbxassetid://241876428"
			particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
			particleEmitter.LightEmission = 0.4
			particleEmitter.Size = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.35),
				NumberSequenceKeypoint.new(1, 0)
			})
			particleEmitter.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.3),
				NumberSequenceKeypoint.new(1, 1)
			})
			particleEmitter.Lifetime = NumberRange.new(0.6, 0.9)
			particleEmitter.Speed = NumberRange.new(2, 3.5)
			particleEmitter.SpreadAngle = Vector2.new(25, 25)
			particleEmitter.Acceleration = createVector(0, 2, 0)
			particleEmitter.Rate = 0
			particleEmitter.Parent = head
			particleEmitter:Emit(8)
			task.delay(1.2, function()
				particleEmitter:Destroy()
			end)
		end

		if v9.pose ~= false then
			applyPose(v16, instance2)
		end

		if v9.lighting ~= false and v4.Spotlight then
			applySpotlight(v16, humanoidRootPart)
		end

		if v9.particles ~= false then
			applyParticles(v16, humanoidRootPart)
		end
	end)
	labPrint(string.format(
		"hero shot: caster=%s camera=%s pose=%s lighting=%s particles=%s hold=%.2fs",
		tostring(v11),
		tostring(v9.camera ~= false),
		tostring(v9.pose ~= false),
		tostring(v9.lighting ~= false),
		tostring(v9.particles ~= false),
		v12
	))

	if not v11 or v9.camera == false then
		task.delay(v4.TakeTime + v12, function()
			if v5 == v16 then
				SoulvesterGuardCinematic.release()
			end
		end)
		return
	end

	v16.cameraTaken = true
	local fieldOfView = currentCamera.FieldOfView
	local cFrame = currentCamera.CFrame
	local position = humanoidRootPart.Position
	v16.savedFov = fieldOfView
	v16.savedCFrame = cFrame
	v16.savedRoot = position

	if v14 then
		local savedFov = v14.savedFov
		local savedCFrame = v14.savedCFrame
		v16.savedFov = savedFov
		v16.savedCFrame = savedCFrame
		v16.savedRoot = v14.savedRoot or v16.savedRoot
	end

	if v9.lighting == false then
		releaseExposure(v16, v4.ReleaseTime)
	else
		local colorCorrectionEffect = Instance.new("ColorCorrectionEffect")
		colorCorrectionEffect.Name = "SoulvesterHeroShot"
		colorCorrectionEffect.Parent = Lighting
		v16.effect = colorCorrectionEffect
		local v17 = math.clamp(v4.GradeStrength, 0, 1)
		local storybookGrade

		if v4.Storybook then
			storybookGrade = v4.StorybookGrade
		else
			storybookGrade = v4
		end

		TweenService:Create(
			colorCorrectionEffect,
			TweenInfo.new(v4.TakeTime + 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Saturation = storybookGrade.Saturation * v17,
				Brightness = storybookGrade.Brightness * v17,
				Contrast = storybookGrade.Contrast * v17,
				TintColor = Color3.fromRGB(255, 255, 255):Lerp(storybookGrade.Tint, v17)
			}
		):Play()
		applyCameraKey(v16)
		dimToonLights(v16, humanoidRootPart)
		applyExposure(v16, v4.Exposure)
		local bloomEffect = Instance.new("BloomEffect")
		bloomEffect.Name = "SoulvesterHeroShotBloom"
		bloomEffect.Intensity = 0
		bloomEffect.Size = v4.Bloom.Size
		bloomEffect.Threshold = v4.Bloom.Threshold
		bloomEffect.Parent = Lighting
		TweenService:Create(
			bloomEffect,
			TweenInfo.new(v4.TakeTime + 0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{
				Intensity = v4.Bloom.Intensity
			}
		):Play()
		v16.bloom = bloomEffect
		local depthOfField

		if v4.FilmLook then
			depthOfField = v4.DepthOfField
		elseif v4.Style == "Portrait" then
			depthOfField = v4.PortraitDepthOfField
		end

		if depthOfField then
			local depthOfFieldEffect = Instance.new("DepthOfFieldEffect")
			depthOfFieldEffect.Name = "SoulvesterHeroShotFocus"
			depthOfFieldEffect.FocusDistance = (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude
			depthOfFieldEffect.InFocusRadius = depthOfField.InFocusRadius
			depthOfFieldEffect.NearIntensity = 0
			depthOfFieldEffect.FarIntensity = 0
			depthOfFieldEffect.Parent = Lighting
			TweenService:Create(
				depthOfFieldEffect,
				TweenInfo.new(v4.TakeTime + 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
				{
					NearIntensity = depthOfField.NearIntensity,
					FarIntensity = depthOfField.FarIntensity
				}
			):Play()
			v16.dof = depthOfFieldEffect

			if v4.FilmLook and not v4.Storybook then
				v16.vignette = buildVignette(v4.Vignette)
			end
		end

		if v4.Storybook then
			v16.vignette = buildVignette(v4.StorybookVignette)
			v16.storybook = buildStorybook()
		end

		labPrint(string.format(
			"grade: %s, strength %.2f, exposure +%.2f stops",
			v4.Storybook and "storybook" or "base",
			v17,
			v4.Exposure
		))
	end

	v16.letterbox = buildLetterbox()

	if v4.HideHud then
		v16.hud = v16.hud or HudHide.hide("SoulvesterGuardCinematic", {
			keep = { "SoulvesterHero" }
		})
	elseif v16.hud then
		v16.hud:release()
		v16.hud = nil
	end

	local riser = playShotSound("Riser") -- equivalent call inferred; original call site unknown
	v16.riser = riser
	task.delay(tonumber(v9.revealDelay) or 0, function()
		local stinger = v5 == v16 and v2.Stinger

		if stinger then
			if stinger.id == "" then
				return
			else
				local _, _ = pcall(function()
					local v18 = Audio:Play(stinger.id, {
						Volume = stinger.volume,
						PlaybackSpeed = stinger.speed
					})

					if v18 then
						SoundGroupManager.AssignSFXSound(v18)
					end

					return v18
				end)
			end
		end
	end)
	local humanoidRootPart3 = instance3 and (instance3:FindFirstChild("HumanoidRootPart") or instance3.PrimaryPart)
	local savedRoot, allyPos, attackerPos, v21 = shotPositions(
		v9.at,
		humanoidRootPart,
		humanoidRootPart2,
		humanoidRootPart3
	)
	labPrint(string.format(
		"positions: server-sent=%s, his root %.1f studs behind, Twisted %.1f studs behind",
		tostring(type(v9.at) == "table"),
		(humanoidRootPart.Position - savedRoot).Magnitude,
		not (humanoidRootPart3 and attackerPos) and 0 or (humanoidRootPart3.Position - attackerPos).Magnitude or 0
	))
	v16.savedCFrame += savedRoot - v16.savedRoot
	v16.savedRoot = savedRoot
	local v22 = currentCamera.CFrame + (savedRoot - humanoidRootPart.Position)
	local fieldOfView2 = currentCamera.FieldOfView
	local arcAnchor = buildArcAnchor(v16.savedCFrame.Position, savedRoot, allyPos, attackerPos, v21)
	local v23 = math.max((savedRoot - v22.Position).Magnitude, 8)
	arcAnchor.ownEye = v22.Position
	arcAnchor.ownFocus = v22.Position + v22.LookVector * v23
	arcAnchor.ownFov = fieldOfView2
	local lastTime = os.clock()
	labPrint("shot rig: " .. arcAnchor.debug)
	local v24 = false
	local filterDescendantsInstances = { instance2, instance }

	if instance3 then
		table.insert(filterDescendantsInstances, instance3)
	end

	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if inGamePlayers then
		table.insert(filterDescendantsInstances, inGamePlayers)
	end

	if v4.Style == "Portrait" then
		local v26 = 2

		if instance3 then
			local success, _, v27 = pcall(instance3.GetBoundingBox, instance3)

			if success and v27 then
				v26 = math.max(v27.X, v27.Z) * 0.5
			end
		end

		local success, result = pcall(
			resolvePortrait,
			arcAnchor,
			filterDescendantsInstances,
			bodyExtent(instance2, humanoidRootPart),
			v26
		)

		if success then
			arcAnchor.portrait = result

			if v9.lighting ~= false then
				local success2, result2 = pcall(placePortraitLights, v16, result, attackerPos)

				if not success2 then
					warn("[SoulvesterGuardCinematic] portrait lights failed: " .. tostring(result2))
				end
			end
		else
			warn("[SoulvesterGuardCinematic] portrait pick failed, side-on fallback: " .. tostring(result))
		end
	end

	local claim = not v and CameraAuthority.claim

	if claim then
		v = claim("SoulvesterGuardCinematic", {
			priority = 100
		})
	end

	local v26 = v4.TakeTime + v12
	local v27 = math.max(v4.BlendIn, 0.01)
	local v28 = math.max(v4.BlendOut, 0.01)
	table.insert(v16.conns, RunService.RenderStepped:Connect(function()
		if v5 ~= v16 or v and not v:isActive() then
			return
		end

		local v29 = os.clock() - lastTime
		local v30 = math.clamp(v29 / v26, 0, 1)

		if v16.storybook and v4.TakeTime + 0.15 < v29 then
			flickerStorybook(v16.storybook, os.clock())
		end

		local v31, v32, v33, v34 = arcFrame(arcAnchor, v30)
		local v35

		if v4.Style == "Portrait" then
			v35 = arcAnchor.portrait ~= nil
		else
			v35 = false
		end

		local v36

		if v35 then
			v36 = 1
		else
			v36 = smooth(v30 / v27)
		end

		local v37 = v36 * smooth((1 - v30) / v28)
		local savedCFrame = v22
		local savedFov = fieldOfView2

		if v30 >= 0.5 then
			savedCFrame = v16.savedCFrame
			savedFov = v16.savedFov
		end

		local position2 = v31.Position
		local lastEye, v38 = occlude(position2, v33, filterDescendantsInstances, v35)

		if v35 and v38 and v16.lastEye then
			lastEye = v16.lastEye
		elseif v16.lastEye and not v35 then
			local v39 = math.min(os.clock() - (v16.lastEyeAt or os.clock()), 0.1)
			lastEye = v16.lastEye:Lerp(lastEye, (math.min(v39 * 16, 1)))
		elseif v35 and v16.lastEye and (position2 - v16.lastEye).Magnitude > 1.5 then
			local v39 = math.min(os.clock() - (v16.lastEyeAt or os.clock()), 0.05)
			lastEye = v16.lastEye:Lerp(position2, (math.min(v39 * 8, 1)))
		end

		if v35 then
			if v38 then
				v16.heldFrames = (v16.heldFrames or 0) + 1
			end

			v16.maxLag = math.max(v16.maxLag or 0, (position2 - lastEye).Magnitude)
		end

		local v39 = v16
		local v40 = v16
		local now = os.clock()
		v39.lastEye = lastEye
		v40.lastEyeAt = now

		if v4.Handheld > 0 then
			lastEye += Vector3.new(
				math.sin(v29 * 1.7) + math.sin(v29 * 4.1) * 0.5,
				math.sin(v29 * 2.3 + 1) + math.sin(v29 * 3.7) * 0.5,
				(math.sin(v29 * 1.3 + 2))
			) * (v4.Handheld * v37)
		end

		local cframe = CFrame.lookAt(lastEye, v33)

		if v34 and v34 ~= 0 then
			cframe *= CFrame.Angles(0, 0, v34)
		end

		if v4.PoseRattle > 0 then
			local v41 = v29 - revealDelay

			if v41 >= 0 and v41 < v4.PoseRattleTime then
				local v42 = 1 - v41 / v4.PoseRattleTime
				local v43 = math.rad(v4.PoseRattle) * v42 * v42 * v37
				cframe *= CFrame.Angles(
					math.sin(v41 * 93) * v43,
					math.sin(v41 * 71 + 1.3) * v43 * 0.6,
					math.sin(v41 * 83 + 2.1) * v43 * 0.8
				)
			end
		end

		currentCamera.CFrame = savedCFrame:Lerp(cframe, v37)
		currentCamera.FieldOfView = savedFov + (v32 - savedFov) * v37

		if v16.key and not v16.keyFixed then
			v16.key.CFrame = CFrame.lookAt(currentCamera.CFrame.Position, v33)
		end

		if not v24 and v30 >= 0.5 then
			v24 = true
			local magnitude = (currentCamera.CFrame.Position - arcAnchor.center).Magnitude
			labPrint(string.format(
				"shot apex: camera %.1f studs from centre (ideal %.1f, height %.1f), type=%s, fov=%.0f, wall-adjusted=%s, blend=%.2f",
				magnitude,
				(v31.Position - arcAnchor.center).Magnitude,
				lastEye.Y - arcAnchor.center.Y,
				tostring(currentCamera.CameraType),
				currentCamera.FieldOfView,
				tostring(v38),
				v37
			))
		end

		if v16.dof and humanoidRootPart.Parent then
			v16.dof.FocusDistance = (humanoidRootPart.Position - currentCamera.CFrame.Position).Magnitude
		end
	end))
	task.delay(v4.TakeTime + v12, function()
		if v5 == v16 then
			labPrint(string.format(
				"shot end: %d frame(s) held behind a wall, max lag behind the rig %.1f studs",
				v16.heldFrames or 0,
				v16.maxLag or 0
			))
			SoulvesterGuardCinematic.release()
		end
	end)
	local instances = {}

	if instance3 then
		table.insert(instances, instance3)
	end

	local assemblyLinearVelocity = humanoidRootPart2.AssemblyLinearVelocity

	if instance ~= instance2 and Vector3.new(assemblyLinearVelocity.X, 0, assemblyLinearVelocity.Z).Magnitude < v4.HitStopStillSpeed then
		table.insert(instances, instance)
	end

	local success, result = pcall(hitStop, instances, v4.HitStop)

	if not success then
		warn("[SoulvesterGuardCinematic] hit-stop failed: " .. tostring(result))
	end
end

return SoulvesterGuardCinematic