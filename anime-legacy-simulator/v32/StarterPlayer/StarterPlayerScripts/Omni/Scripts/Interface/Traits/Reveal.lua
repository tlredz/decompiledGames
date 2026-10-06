local createVector = vector.create
local module = require("@game/ReplicatedStorage/Omni")
local fusion = module.Libs.Fusion
local shake = module.Libs.Shake
local playerGui = module.Instance:WaitForChild("PlayerGui")
local reward = module.Assets.Interface.Templates.GachaRoll.Reward
local stopTraits = module.Interface.HUD.StopButtons.StopTraits
local main = playerGui:WaitForChild("GachaRoll"):WaitForChild("Main")
local vector2 = Vector2.new(0.5, 0.52)
local color = Color3.new(1, 0, 0)
local v = {
	Vector2.new(0.08, 0.08),
	Vector2.new(0.92, 0.92),
	Vector2.new(0.92, 0.08),
	Vector2.new(0.08, 0.92),
	Vector2.new(0.5, 0.04),
	Vector2.new(0.5, 0.96),
	Vector2.new(0.04, 0.5),
	Vector2.new(0.96, 0.5)
}
local v2 = {
	Mythical = {
		Reveal = 1.15,
		Fade = 2.35
	},
	Secret = {
		Reveal = 1.7,
		Fade = 3.05
	}
}
local v3 = {
	Color3.fromRGB(157, 0, 255),
	Color3.fromRGB(255, 0, 144),
	Color3.fromRGB(0, 195, 255),
	Color3.fromRGB(255, 179, 0)
}
local v4 = {
	Vector2.new(0.23, 0.22),
	Vector2.new(0.48, 0.14),
	Vector2.new(0.72, 0.26),
	Vector2.new(0.86, 0.49),
	Vector2.new(0.68, 0.75),
	Vector2.new(0.44, 0.87),
	Vector2.new(0.17, 0.67),
	Vector2.new(0.13, 0.41)
}
local v5 = {
	{ 1, 2 },
	{ 2, 3 },
	{ 3, 4 },
	{ 4, 5 },
	{ 5, 6 },
	{ 6, 7 },
	{ 7, 8 },
	{ 8, 1 },
	{ 1, 5 },
	{ 3, 7 },
	{ 2, 6 }
}
local v6 = nil
local Reveal = {}

local function Create(className: string, parent, items)
	local instance = Instance.new(className)

	for k, item in items do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

local function Frame(parent, name: string, udim: UDim2, udim2: UDim2?, value: string?)
	local v7 = {
		Name = name,
		Size = udim,
		Position = udim2 or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	}
	local instance = Instance.new(value or "Frame")

	for k, v8 in v7 do
		instance[k] = v8
	end

	instance.Parent = parent
	return instance
end

local function Circle(p, p2: string, p3: number, backgroundColor: Color3)
	local parent = Frame(p, p2, UDim2.fromScale(p3, p3))
	parent.BackgroundColor3 = backgroundColor
	parent.BackgroundTransparency = 0
	local v8 = {
		CornerRadius = UDim.new(1, 0)
	}
	local uICorner = Instance.new("UICorner")

	for k, v9 in v8 do
		uICorner[k] = v9
	end

	uICorner.Parent = parent
	return parent
end

local function Glow(parent, color2: Color3, p: number)
	local v7 = {
		Name = "Glow",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(p, p),
		BackgroundTransparency = 1,
		Image = "rbxassetid://84343393827379",
		ImageColor3 = color2,
		ImageTransparency = 0.4,
		ZIndex = 0
	}
	local imageLabel = Instance.new("ImageLabel")

	for k, v8 in v7 do
		imageLabel[k] = v8
	end

	imageLabel.Parent = parent
	return imageLabel
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Progress(p: number, p2: number, duration: number)
	return (math.clamp((p - p2) / duration, 0, 1))
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function EaseOut(p: number)
	return 1 - (1 - p) ^ 3
end

local function SpringScale(state, parent)
	local value = state.Scope:Value(0)
	local uIScale = Instance.new("UIScale")

	for k, v7 in {
		Scale = 0
	} do
		uIScale[k] = v7
	end

	uIScale.Parent = parent
	state.Scope:Hydrate(uIScale)({
		Scale = state.Scope:Spring(value, 10, 1)
	})
	return value
end

local function PlaySound(state, p: string)
	local v7 = module.Sound:PlayEffect("Gacha." .. p, {
		MaxVoices = 1
	})
	state.Sounds[v7] = true
	v7:finally(function()
		state.Sounds[v7] = nil
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function RestoreCamera(state)
	local shakeCamera = state.ShakeCamera

	if shakeCamera and shakeCamera.Parent then
		shakeCamera.CFrame -= state.CameraOffset
	end

	state.ShakeCamera = nil
end

local function StopSuspense(state)
	if state.FOVApplied then
		state.FOVApplied = false
		module.Signal:FireSelf("Player", "FOV", "Remove", "TraitReveal")
	end

	if state.Shake then
		state.Shake:Destroy()
		state.Shake = nil
	end

	if state.RestoreConnection then
		state.RestoreConnection:Disconnect()
		state.RestoreConnection = nil
	end

	RestoreCamera(state) -- equivalent call inferred; original call site unknown

	if state.RoulettePosition then
		main.Position = state.RoulettePosition
		state.RoulettePosition = nil
	end
end

local function StartSuspense(state)
	state.SuspenseStarted = true
	state.FOVApplied = true
	module.Signal:FireSelf("Player", "FOV", "Add", "TraitReveal", -15)

	if module.Data.Settings["Low Mode"] or module.Data.Settings["Camera Shake"] == false then
		return
	end

	state.RoulettePosition = main.Position
	state.Shake = shake.new()
	state.Shake.Amplitude = 0.2
	state.Shake.Frequency = 0.08
	state.Shake.FadeInTime = 0.25
	state.Shake.SustainTime = 0.25
	state.Shake.FadeOutTime = 0.3
	state.Shake.PositionInfluence = createVector(1, 1, 0)
	state.Shake.RotationInfluence = createVector(0, 0, 0)
	state.Shake:Start()
	state.RestoreConnection = module.Services.RunService.Heartbeat:Connect(function()
		RestoreCamera(state) -- equivalent call inferred; original call site unknown
	end)
	state.Shake:BindToRenderStep(shake.NextRenderName(), Enum.RenderPriority.Last.Value, function(p, _, p2)
		RestoreCamera(state) -- equivalent call inferred; original call site unknown

		if state.Cleaned then
			return
		end

		if p2 or module.Data.Settings["Low Mode"] or module.Data.Settings["Camera Shake"] == false then
			main.Position = state.RoulettePosition
			return
		end

		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			state.CameraOffset = currentCamera.CFrame:VectorToWorldSpace(p)
			currentCamera.CFrame += state.CameraOffset
			state.ShakeCamera = currentCamera
		end

		main.Position = state.RoulettePosition + UDim2.fromOffset(p.X * 30, p.Y * 30)
	end)
end

local function Clean(state)
	if state.Cleaned then
		return
	end

	state.Cleaned = true

	if v6 == state then
		v6 = nil
	end

	StopSuspense(state)

	for _, connection in state.Connections do
		connection:Disconnect()
	end

	table.clear(state.Connections)

	for k in state.Sounds do
		if not state.Completed then
			k:cancel()
		end
	end

	table.clear(state.Sounds)
	state.Scope:doCleanup()

	if state.Gui then
		state.Gui:Destroy()
	end

	if state.HidingFrames then
		module.Frame:RemoveFramesHider("TraitReveal")
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function Finish(p)
	if p.Cleaned then
		return
	end

	local onComplete = p.Options.OnComplete
	Clean(p)

	if onComplete then
		onComplete()
	end
end

local function BuildRings(state, p: number, color2: Color3)
	state.Rings = {}

	for i = 1, p do
		local v7 = Circle(state.Stage, `Ring{i}`, 0, color2)
		v7.BackgroundTransparency = 1
		v7.Position = UDim2.fromScale(vector2.X, vector2.Y)
		local uIStroke = Instance.new("UIStroke")

		for k, v8 in {
			Thickness = 2,
			Color = color2,
			Transparency = 1
		} do
			uIStroke[k] = v8
		end

		uIStroke.Parent = v7
		table.insert(state.Rings, {
			Instance = v7,
			Stroke = uIStroke
		})
	end
end

local function BuildEnergy(state)
	local frame = Frame(state.Stage, "Energy", UDim2.fromScale(1, 1))
	local random = Random.new()
	state.Particles = {}

	for i = 1, 24 do
		local v8 = v3[(i - 1) % #v3 + 1]
		local size = i % 5 * 0.002 + 0.008
		local instance = Circle(frame, `Particle{i}`, size, v8)
		local glow = Glow(instance, v8, 5)
		instance.Visible = false
		local v12 = v[(i - 1) % #v + 1] + Vector2.new(
			random:NextNumber(-0.025, 0.025),
			random:NextNumber(-0.025, 0.025)
		) - vector2
		table.insert(state.Particles, {
			Instance = instance,
			Glow = glow,
			Size = size,
			Angle = math.atan2(v12.Y, v12.X),
			Radius = v12.Magnitude,
			Start = math.floor((i - 1) / #v) * 0.1 + 0.05 + random:NextNumber(0, 0.025),
			Duration = random:NextNumber(0.55, 0.72)
		})
	end

	state.Core = Circle(state.Stage, "Core", 0, Color3.new(1, 1, 1))
	state.Core.Position = UDim2.fromScale(vector2.X, vector2.Y)
	state.CoreGlow = Glow(state.Core, v3[1], 3)
	BuildRings(state, 2, v3[1])
end

local function BuildConstellation(state)
	state.Constellation = Frame(state.Stage, "Constellation", UDim2.fromScale(1, 1))
	local frame = Frame(state.Constellation, "Lines", UDim2.fromScale(1, 1))
	state.Stars = {}
	state.Edges = {}

	for k, position in v4 do
		local v9 = 0.04 + k % 3 * 0.01
		local instance = Frame(
			state.Constellation,
			`Star{k}`,
			UDim2.fromScale(v9, v9),
			UDim2.fromScale(position.X, position.Y)
		)
		local glow = Glow(instance, Color3.new(1, 0, 0), 3)
		local parts = { (Circle(instance, "Core", 0.22, Color3.new(1, 1, 1))) }

		for i = 1, 2 do
			local frame2 = Frame(instance, `Ray{i}`, UDim2.fromScale(1, 0.08))
			frame2.BackgroundColor3 = Color3.new(1, 1, 1)
			frame2.BackgroundTransparency = 0
			frame2.Rotation = (i - 1) * 90
			table.insert(parts, frame2)
		end

		table.insert(state.Stars, {
			Instance = instance,
			Glow = glow,
			Parts = parts,
			Goal = SpringScale(state, instance),
			Position = position,
			Started = false
		})
	end

	for k, v8 in v5 do
		local instance = Frame(frame, `Line{k}`, UDim2.fromOffset(0, 2))
		instance.BackgroundColor3 = Color3.new(1, 0, 0)
		table.insert(state.Edges, {
			Instance = instance,
			From = v8[1],
			To = v8[2]
		})
	end

	state.Core = Circle(state.Stage, "Core", 0, Color3.new(1, 1, 1))
	state.Core.Position = UDim2.fromScale(vector2.X, vector2.Y)
	state.CoreGlow = Glow(state.Core, Color3.new(1, 0, 0), 3)
	BuildRings(state, 1, Color3.new(1, 0, 0))
end

local function BuildResult(state, data)
	state.RewardSlot = Frame(
		state.Stage,
		"RewardSlot",
		UDim2.fromScale(0.46, 0.46),
		UDim2.fromScale(vector2.X, vector2.Y),
		"CanvasGroup"
	)
	state.RewardSlot.GroupTransparency = 1
	state.RewardSlot.ZIndex = 3
	state.RewardGoal = SpringScale(state, state.RewardSlot)
	state.Reward = reward:Clone()
	state.Reward.Name = "Reward"
	state.Reward.Size = UDim2.fromScale(1, 1)
	state.Reward.Position = UDim2.fromScale(0.5, 0.5)
	state.Reward.AnchorPoint = Vector2.new(0.5, 0.5)
	state.Reward.Visible = false
	state.Reward.Main.Title.Text = data.Name
	state.Reward.Main.Icon.Image = data.Icon or ""
	state.Reward.Main.Icon.Visible = true
	state.Reward.Main.Viewport.Visible = false
	local v7 = data.Rarity == "Secret"
	local uIGradient = state.Reward.Main.UIGradient

	if v7 then
		uIGradient:RemoveTag("GradientWaves")
		uIGradient:SetAttribute("Rarity", nil)
		uIGradient.Color = ColorSequence.new(color)
		uIGradient.Offset = Vector2.zero
		uIGradient.Rotation = 0
		state.Reward.Main.ImageColor3 = Color3.new(1, 1, 1)
		state.Reward.Main.Fade.BackgroundColor3 = color
	else
		uIGradient.Color = module.Utils.Colors:GetColorSequenceFromRarity(data.Rarity)
		uIGradient:SetAttribute("Rarity", data.Rarity)
	end

	state.Reward.Parent = state.RewardSlot
	state.Rarity = reward.Main.Title:Clone()
	state.Rarity.Name = "Rarity"
	state.Rarity.AnchorPoint = Vector2.new(0.5, 0.5)
	state.Rarity.Position = UDim2.fromScale(0.5, 0.21)
	state.Rarity.Size = UDim2.fromScale(0.9, 0.08)
	state.Rarity.BackgroundTransparency = 1
	state.Rarity.Text = string.upper(data.Rarity) .. " TRAIT"
	state.Rarity.TextScaled = true
	state.Rarity.TextTransparency = 1
	state.Rarity.Visible = false
	state.Rarity.ZIndex = 3

	if v7 then
		state.Rarity.TextColor3 = color
	end

	local uIStroke = state.Rarity:FindFirstChildWhichIsA("UIStroke")

	if uIStroke and data.Rarity == "Secret" then
		uIStroke.Color = Color3.fromRGB(180, 30, 30)
	end

	local rarity = state.Rarity
	local v8 = {
		Color = v7 and ColorSequence.new(color) or module.Utils.Colors:GetColorSequenceFromRarity(data.Rarity),
		Rotation = 0
	}
	local uIGradient2 = Instance.new("UIGradient")

	for k, v9 in v8 do
		uIGradient2[k] = v9
	end

	uIGradient2.Parent = rarity
	state.Rarity.Parent = state.Stage
end

local function BuildStopAuto(state)
	if not (state.Options.IsAutoRolling and state.Options.IsAutoRolling()) then
		return
	end

	state.StopAuto = stopTraits:Clone()
	state.StopAuto.Name = "StopAuto"
	state.StopAuto.AnchorPoint = Vector2.new(0.5, 0.5)
	state.StopAuto.Position = UDim2.fromScale(0.5, 0.94)
	state.StopAuto.Size = UDim2.fromScale(0.22, 0.065)
	state.StopAuto.Visible = true
	state.StopAuto.ZIndex = 3
	state.StopAuto.Main.Text.Text = "STOP AUTO"
	local stopAuto = state.StopAuto
	local v7 = {
		MinSize = Vector2.new(120, 32),
		MaxSize = Vector2.new(280, 56)
	}
	local uISizeConstraint = Instance.new("UISizeConstraint")

	for k, v8 in v7 do
		uISizeConstraint[k] = v8
	end

	uISizeConstraint.Parent = stopAuto
	state.StopAuto.Parent = state.Root
	state.StopGoal = SpringScale(state, state.StopAuto)
	module.Button:Create(state.StopAuto.Main, "Default"):BindFunction("Click", function()
		if v6 ~= state then
			return
		end

		if state.Options.OnStopAuto then
			state.Options.OnStopAuto()
		end

		state.StopAuto.Visible = false
	end)
	state.StopGoal:set(1)
end

local function Build(state, p)
	local v7 = {
		Name = "TraitReveal",
		Enabled = true,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ScreenInsets = Enum.ScreenInsets.None,
		ClipToDeviceSafeArea = false,
		DisplayOrder = 100,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}
	local screenGui = Instance.new("ScreenGui")

	for k, v8 in v7 do
		screenGui[k] = v8
	end

	screenGui.Parent = nil
	state.Gui = screenGui
	state.Root = Frame(state.Gui, "Root", UDim2.fromScale(1, 1), UDim2.fromScale(0.5, 0.5), "CanvasGroup")
	state.Backdrop = Frame(state.Root, "Backdrop", UDim2.fromScale(1, 1))
	state.Backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
	state.Backdrop.Active = true
	state.Stage = Frame(state.Root, "Stage", UDim2.fromScale(0.72, 0.72))
	state.Stage.ZIndex = 2
	state.Stage.Visible = false
	local stage = state.Stage
	local v8 = {
		AspectRatio = 1,
		AspectType = Enum.AspectType.FitWithinMaxSize
	}
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")

	for k, v9 in v8 do
		uIAspectRatioConstraint[k] = v9
	end

	uIAspectRatioConstraint.Parent = stage

	if state.RarityName == "Secret" then
		BuildConstellation(state)
	else
		BuildEnergy(state)
	end

	BuildResult(state, p)
	BuildStopAuto(state)
end

local function UpdateEnergy(data, p: number)
	for _, particle in data.Particles do
		local progress = Progress(p, particle.Start, particle.Duration) -- equivalent call inferred; original call site unknown
		local v8 = progress ^ 2
		local v9 = particle.Angle + v8 * 3.141592653589793 * 1.5
		local v10 = particle.Radius * (1 - v8)
		local v11 = particle.Size * (1 - v8)
		local instance = particle.Instance
		instance.Visible = particle.Start <= p and progress < 1
		particle.Instance.Position = UDim2.fromScale(vector2.X + math.cos(v9) * v10, vector2.Y + math.sin(v9) * v10)
		particle.Instance.Size = UDim2.fromScale(v11, v11)
		particle.Instance.BackgroundTransparency = math.max(
			1 - progress * 8,
			(math.clamp((progress - 0.8) / 0.2, 0, 1))
		)
		particle.Glow.ImageTransparency = 0.2 + particle.Instance.BackgroundTransparency * 0.8
	end

	local v7

	if p < 0.8 then
		v7 = (1 - (1 - math.clamp((p - 0.1) / 0.7, 0, 1)) ^ 3) * 0.14
	elseif p < 0.975 then
		v7 = math.clamp((p - 0.8) / 0.175, 0, 1) * 0.04 + 0.14
	else
		v7 = 0.18 - math.clamp((p - 0.975) / 0.175, 0, 1) * 0.1
	end

	data.Core.Size = UDim2.fromScale(v7, v7)
	data.Core.BackgroundTransparency = math.clamp((p - 1.15) / 0.15, 0, 1)
	data.CoreGlow.ImageTransparency = 0.25 + data.Core.BackgroundTransparency * 0.75
end

local function UpdateConstellation(data, p: number)
	local v7 = math.clamp((p - 1.35) / 0.35, 0, 1) ^ 2
	data.Constellation.Rotation = math.clamp((p - 0.15) / 1.2, 0, 1) * 12

	for k, star in data.Stars do
		local v8 = 0.15 + (k - 1) * 0.08

		if v8 <= p and not star.Started then
			star.Started = true
			star.Goal:set(1)
		end

		local lerped = star.Position:Lerp(vector2, v7)
		star.Instance.Position = UDim2.fromScale(lerped.X, lerped.Y)
		local backgroundTransparency = math.max(1 - math.clamp((p - v8) / 0.15, 0, 1), v7)

		for _, part in star.Parts do
			part.BackgroundTransparency = backgroundTransparency
		end

		local v10 = math.sin(p * 5 + k) * 0.2 + 0.4
		star.Glow.ImageTransparency = v10 + (1 - v10) * backgroundTransparency
	end

	local absoluteSize = data.Constellation.AbsoluteSize

	for k, edge in data.Edges do
		local lerped = v4[edge.From]:Lerp(vector2, v7)
		local lerped2 = v4[edge.To]:Lerp(vector2, v7)
		local v8 = (lerped2 - lerped) * absoluteSize
		local progress = Progress(p, 0.35 + (k - 1) * 0.09, 0.12) -- equivalent call inferred; original call site unknown
		local lerped3 = lerped:Lerp(lerped2, progress / 2)
		edge.Instance.Position = UDim2.fromScale(lerped3.X, lerped3.Y)
		edge.Instance.Rotation = math.deg((math.atan2(v8.Y, v8.X)))
		edge.Instance.Size = UDim2.fromOffset(v8.Magnitude * progress, 2)
		edge.Instance.BackgroundTransparency = v7 * 0.85 + 0.15
	end

	local imageTransparency = Progress(p, 1.35, 0.3) -- equivalent call inferred; original call site unknown
	local v9 = EaseOut(imageTransparency) * 0.35 + 0.1
	local core = data.Core
	core.Visible = p >= 1.35 and imageTransparency < 1
	data.Core.Size = UDim2.fromScale(v9, v9)
	data.Core.BackgroundTransparency = imageTransparency * 0.5 + 0.5
	data.CoreGlow.ImageTransparency = imageTransparency
end

local function Update(state, p: number)
	if state.Cleaned then
		return
	end

	local v7 = v2[state.RarityName]

	if v7.Fade + 0.35 <= p then
		state.Completed = true
		Finish(state) -- equivalent call inferred; original call site unknown
	else
		state.Backdrop.BackgroundTransparency = 0
		state.Root.GroupTransparency = math.clamp((p - v7.Fade) / 0.35, 0, 1)

		if state.RarityName == "Secret" then
			UpdateConstellation(state, p)
		else
			UpdateEnergy(state, p)
		end

		for k, ring in state.Rings do
			local v8 = v7.Reveal + (k - 1) * 0.06
			local v9 = state.RarityName == "Secret"
			local v10 = math.clamp((p - v8) / (v9 and 0.5 or 0.45), 0, 1)
			local v11 = 0.08 + ((v9 and 0.85 or 1) - 0.08) * EaseOut(v10)
			local instance = ring.Instance
			instance.Visible = v8 <= p and v10 < 1
			ring.Instance.Size = UDim2.fromScale(v11, v11)
			ring.Stroke.Transparency = v10 * 0.9 + 0.1
		end

		if v7.Reveal <= p and not state.Revealed then
			state.Revealed = true
			state.Reward.Visible = true
			state.Rarity.Visible = true
			state.RewardGoal:set(1)
			PlaySound(state, "End")
		end

		local progress = Progress(p, v7.Reveal, 0.2) -- equivalent call inferred; original call site unknown
		state.RewardSlot.GroupTransparency = 1 - progress
		state.Rarity.TextTransparency = 1 - progress
		local uIStroke = state.Rarity:FindFirstChildWhichIsA("UIStroke")

		if uIStroke then
			uIStroke.Transparency = 1 - progress
		end

		if state.StopAuto then
			state.StopAuto.Visible = state.Options.IsAutoRolling()
		end
	end
end

function Reveal.IsSupported(p: string)
	return v2[p] ~= nil
end

function Reveal.IsPlaying()
	return v6 ~= nil
end

function Reveal.Cancel()
	if v6 then
		Clean(v6)
	end
end

function Reveal.Play(p, options)
	if not (p and Reveal.IsSupported(p.Rarity)) then
		return false
	end

	Reveal.Cancel()
	local v7 = {
		Scope = fusion.scoped(fusion),
		Options = options or {},
		RarityName = p.Rarity,
		Connections = {},
		Sounds = {},
		Revealed = false,
		Cleaned = false
	}
	v6 = v7
	task.spawn(function()
		local v8, v9 = xpcall(function()
			module.Gacha.Animation(4.5, { p }, {
				Info = module.Shared.Traits.List,
				Chances = module.Shared.Traits.List
			}, v7.Options.Luck, {
				RollTime = 4.5,
				HideResult = true,
				IsCancelled = function()
					return not v7.Completed and (v7.Cleaned or v6 ~= v7)
				end,
				OnStart = function()
					Build(v7, p)
					v7.HidingFrames = true
					module.Frame:AddFramesHider("TraitReveal")
					v7.Gui.Parent = playerGui
					table.insert(v7.Connections, v7.Gui.Destroying:Connect(function()
						Finish(v7) -- equivalent call inferred; original call site unknown
					end))
				end,
				OnStep = function(p2)
					if v7.Cleaned then
						return
					end

					local progress = Progress(p2, 3.7, 0.8) -- equivalent call inferred; original call site unknown
					v7.Backdrop.BackgroundTransparency = 1 - EaseOut(progress)

					if progress > 0 and not v7.SuspenseStarted then
						StartSuspense(v7)
					end

					if v7.StopAuto then
						v7.StopAuto.Visible = v7.Options.IsAutoRolling()
					end
				end,
				OnTransition = function()
					if v7.Cleaned then
						return
					end

					StopSuspense(v7)
					v7.Stage.Visible = true
					Update(v7, 0)
					local lastTime = os.clock()
					table.insert(v7.Connections, module.Services.RunService.RenderStepped:Connect(function()
						if v7.Cleaned then
							return
						end

						local v10, v11 = xpcall(Update, debug.traceback, v7, os.clock() - lastTime)

						if not v10 then
							warn((`[TraitReveal] {v11}`))
							Finish(v7) -- equivalent call inferred; original call site unknown
						end
					end))

					while not v7.Cleaned do
						module.Services.RunService.Heartbeat:Wait()
					end
				end,
				OnFinish = function()
					Finish(v7) -- equivalent call inferred; original call site unknown
				end
			})
		end, debug.traceback)

		if not v8 then
			warn((`[TraitReveal] {v9}`))
			Finish(v7) -- equivalent call inferred; original call site unknown
		end
	end)
	return true
end

script.Destroying:Connect(Reveal.Cancel)
return Reveal