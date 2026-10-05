return {
	CoilsFolder = "TeslaPuzzle",
	PointPath = { "relic", "Point" },
	AutoAim = true,
	RequireMutual = false,
	ShowOnlyRequired = true,
	WinMode = "ExactSet",
	RequiredLinks = {
		{ "Coil1", "Coil2" },
		{ "Coil2", "Coil3" },
		{ "Coil3", "Coil4" },
		{ "Coil4", "Coil5" },
		{ "Coil5", "Coil6" },
		{ "Coil6", "Coil1" }
	},
	MaxClickDistance = 32,
	RotateTime = 1.5,
	RotateEasing = Enum.EasingStyle.Back,
	RotateDirection = Enum.EasingDirection.Out,
	LockDuringRotate = true,
	Beam = {
		EdgeColor = Color3.fromRGB(35, 120, 255),
		CoreColor = Color3.fromRGB(190, 235, 255),
		Width = 0.9,
		Transparency = 0.05,
		LightEmission = 1,
		LightInfluence = 0,
		Segments = 24,
		CurveSize = 0,
		FaceCamera = true,
		Texture = "rbxassetid://5889875399",
		TextureMode = Enum.TextureMode.Wrap,
		TextureLength = 5,
		TextureSpeed = 3,
		ZOffset = 0
	},
	SolvedBeam = {
		EdgeColor = Color3.fromRGB(120, 205, 255),
		CoreColor = Color3.fromRGB(255, 255, 255),
		Width = 1.6,
		Transparency = 0,
		TextureSpeed = 7,
		TweenTime = 0.8
	},
	Light = {
		Enabled = true,
		Color = Color3.fromRGB(110, 190, 255),
		Range = 12,
		PerLink = 0.5,
		SolvedBonus = 0.8,
		Max = 2
	},
	Particle = {
		Enabled = true,
		Texture = "rbxasset://textures/particles/sparkles_main.dds",
		Color = Color3.fromRGB(205, 238, 255),
		Size = 0.9,
		Transparency = 0.1,
		Rate = 12,
		LifetimeMin = 0.5,
		LifetimeMax = 1.1,
		SpinSpeed = 60,
		LightEmission = 1,
		LightInfluence = 0,
		ZOffset = 0
	},
	Flicker = {
		Enabled = true,
		WidthAmount = 0.18,
		AlphaAmount = 0.12,
		CurveAmount = 0,
		Speed = 6
	},
	Origin = CFrame.new(-7389.549, 5598.91, 338.985) * CFrame.Angles(0, -0.6095562412590195, 0),
	Radius = 34,
	CoilScale = 1.8,
	RotateSound = "UpperSkySFX.BF_UpperSky_Spin_Gold_Pylon",
	RotateSoundVariants = 3,
	RotateSoundVolume = 0.6,
	ConnectSound = "UpperSkySFX.BF_UpperSky_Spin_Gold_Pylon_Activation",
	ConnectSoundVariants = 3,
	ConnectSoundVolume = 0.55,
	CoilGroundUp = 6,
	CoilGroundDown = 400,
	Relic = {
		Enabled = true,
		Model = "TeslaCoil",
		Part = "relic",
		Height = 1.1,
		Period = 5,
		Spin = 0
	},
	RelicFinale = {
		Enabled = true,
		ShakeTime = 1.8,
		ShakeAmplitude = 0.3,
		ShakeFrequency = 22,
		RiseTime = 1,
		RiseHeight = 18,
		OrbitTime = 7,
		Revolutions = 3,
		OrbitRadius = 0,
		OrbitEdge = 0.25,
		WaveHeight = 4,
		WaveCycles = 3,
		SpinDegrees = 900,
		BankAngle = 25,
		BurstTime = 1.6,
		BurstDelay = 0.55,
		ApproachTime = 1.6,
		ApproachArc = 9,
		HoverHeight = 12,
		HoverTime = 1,
		AlignTime = 1.2,
		AlignRise = 7,
		DropTime = 1,
		LandInHand = true,
		CatchKeyTime = 1.33,
		HandOffset = 0.5,
		BounceHeight = 0.5,
		BounceTime = 0.45,
		CleanupTime = 0.35
	},
	Camera = {
		Enabled = true,
		LockCharacter = true,
		Smoothing = 4.5,
		OrbitSmoothing = 14,
		VelocitySmoothing = 8,
		CloseDistance = 7,
		CloseHeight = 2.5,
		FollowOut = 4,
		FollowUp = 2.5,
		FollowBack = 5,
		FollowMinRadius = 3,
		BurstDistance = 22,
		BurstHeight = 8,
		ChaseBack = 14,
		ChaseUp = 5,
		ChaseMinSpeed = 6,
		OverheadDistance = 12,
		OverheadSide = 3,
		OverheadHeight = 6,
		OverheadBias = 0.62,
		SnapLead = 0.5,
		SnapDistance = 9,
		SnapSide = -4,
		SnapHeight = 4,
		SnapLookHeight = 2.5,
		SnapRelicBias = 0.45,
		HoldTime = 1.2,
		RestoreTime = 0.8
	},
	CoilSpin = {
		Enabled = true,
		PartName = "teslaCoil",
		MaxSpeed = 260,
		IdleFactor = 0.15,
		StopTime = 0.5
	},
	CoilAlign = {
		Enabled = true,
		PartName = "relic"
	},
	Shockwave = {
		Enabled = true,
		Texture = "rbxasset://textures/particles/sparkles_main.dds",
		Color = Color3.fromRGB(190, 235, 255),
		Count = 90,
		Speed = 55,
		Drag = 4,
		Lifetime = 0.8,
		Size = 3,
		LightEmission = 1
	},
	Shutdown = {
		Enabled = true,
		ExtraDelay = 0.25
	},
	Coils = {
		Coil1 = {
			Model = "Coil1",
			Start = 2,
			States = { "Coil2", "Coil4", "Coil6" }
		},
		Coil2 = {
			Model = "Coil2",
			Start = 1,
			States = { "Coil3", "Coil5", "Coil1" }
		},
		Coil3 = {
			Model = "Coil3",
			Start = 2,
			States = { "Coil4", "Coil6", "Coil2" }
		},
		Coil4 = {
			Model = "Coil4",
			Start = 3,
			States = { "Coil5", "Coil1", "Coil3" }
		},
		Coil5 = {
			Model = "Coil5",
			Start = 2,
			States = { "Coil6", "Coil2", "Coil4" }
		},
		Coil6 = {
			Model = "Coil6",
			Start = 1,
			States = { "Coil1", "Coil3", "Coil5" }
		}
	}
}