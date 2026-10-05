local KnifeDisplayRig = {}
local parent = script.Parent.Parent
local AnimationConfig = require(parent.Animation.AnimationConfig)
local ScythePose = require(script.Parent.ScythePose)

-- equivalent calls inferred from this helper; original call sites unknown
local function scaled(p, p2)
	return CFrame.new(p.Position * p2) * p.Rotation
end

function KnifeDisplayRig.create(instance, instance2, instance3)
	local clone = instance:Clone()
	clone.Name = instance2.Name .. "_Preview"

	for _, descendant in clone:GetDescendants() do
		if not (descendant:IsA("LuaSourceContainer") or descendant:IsA("BillboardGui") or descendant:IsA("SurfaceGui") or descendant:IsA("Tool")) then
			continue
		end

		descendant:Destroy()
	end

	for k in clone:GetAttributes() do
		clone:SetAttribute(k, nil)
	end

	local humanoid = clone:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = clone:FindFirstChild("HumanoidRootPart")
	local rightArm = clone:FindFirstChild("Right Arm")
	assert(humanoid and humanoidRootPart and rightArm, "Display requires R6 body")

	for _, animator in humanoid:GetChildren() do
		if animator:IsA("Animator") then
			animator:Destroy()
		end
	end

	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.AutoRotate = false
	humanoid.BreakJointsOnDeath = false
	humanoid.Health = humanoid.MaxHealth
	humanoid.WalkSpeed = 0
	humanoid.JumpPower = 0
	clone.PrimaryPart = humanoidRootPart
	clone:ScaleTo(1)
	local blade, stowedBlade, motor6D, idleGrip

	if instance3 then
		local clone2 = instance3:Clone()
		clone2.Name = "DisplayKnife"
		local handle = clone2.Handle
		blade = clone2.Blade
		stowedBlade = clone2.StowedBlade
		handle.Transparency = 1
		blade.Transparency = 0
		motor6D = Instance.new("Motor6D")
		motor6D.Name = "Handle"
		motor6D.Part0 = rightArm
		motor6D.Part1 = handle
		local DaggerGrip = require(script.Parent.DaggerGrip)
		motor6D.C0 = DaggerGrip.c0(clone2)
		motor6D.C1 = clone2:GetAttribute("GripC1")
		handle.CFrame = rightArm.CFrame * motor6D.C0 * motor6D.C1:Inverse()
		blade.CFrame = handle.CFrame * handle.BladeWeld.C0 * handle.BladeWeld.C1:Inverse()
		local torso = clone.Torso
		stowedBlade.CFrame = torso.CFrame * clone2:GetAttribute("StowedOffset")
		local weld = Instance.new("Weld")
		weld.Name = "DisplaySheath"
		weld.Part0 = torso
		weld.Part1 = stowedBlade
		weld.C0 = clone2:GetAttribute("StowedOffset")
		weld.Parent = stowedBlade
		local WeaponEffects = require(script.Parent.WeaponEffects)
		WeaponEffects.position(clone2)
		clone2.Parent = clone
		motor6D.Parent = rightArm
		idleGrip = clone2:GetAttribute("IdleGrip")
	end

	for _, part in clone:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = part == humanoidRootPart
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.Massless = part ~= humanoidRootPart
		part.LocalTransparencyModifier = 0
	end

	local displayScale = instance2:GetAttribute("DisplayScale") or instance2:GetScale()
	clone:ScaleTo(displayScale)
	clone:PivotTo(instance2:GetPivot())
	local leftLeg = instance2:FindFirstChild("Left Leg")
	local leftLeg2 = clone:FindFirstChild("Left Leg")

	if leftLeg and leftLeg2 then
		local v = leftLeg.Position.Y - leftLeg.Size.Y * 0.5
		local v2 = leftLeg2.Position.Y - leftLeg2.Size.Y * 0.5
		clone:PivotTo(clone:GetPivot() + Vector3.new(0, v - v2, 0))
	end

	clone:SetAttribute("LobbyKnifeDisplay", true)
	clone:SetAttribute("LocalAvatarUserId", game.Players.LocalPlayer and game.Players.LocalPlayer.UserId or 0)
	local animator = Instance.new("Animator")
	animator.Parent = humanoid
	local v = {
		model = clone,
		root = humanoidRootPart,
		humanoid = humanoid,
		animator = animator,
		motor = motor6D,
		idle = idleGrip and scaled(idleGrip, displayScale),
		blade = blade,
		stowed = stowedBlade,
		scythe = 0,
		scale = 0,
		basePivot = 0,
		tracks = 0,
		assets = 0,
		rates = 0,
		cueFired = 0
	}
	local scythe

	if instance3 then
		scythe = ScythePose.new(clone.DisplayKnife) or nil
	end

	v.scythe = scythe
	v.scale = displayScale
	v.basePivot = clone:GetPivot()
	v.tracks = {}
	v.assets = {}
	v.rates = {}
	v.cueFired = {}
	return v
end

KnifeDisplayRig.Sequence = {
	{
		label = "IDLE",
		clip = "Idle",
		duration = 1.6
	},
	{
		label = "DRAW",
		clip = "DaggerEquip",
		duration = 0.94,
		held = true,
		draw = true,
		cues = {
			{ 0.08, "Equip" }
		}
	},
	{
		label = "READY",
		clip = "Idle",
		duration = 1.5,
		held = true
	},
	{
		label = "WALK",
		clip = "Walk",
		duration = 2,
		held = true,
		steps = 0.52
	},
	{
		label = "RUN",
		clip = "Run",
		duration = 2.2,
		held = true,
		steps = 0.3
	},
	{
		label = "STOP",
		clip = "Stop",
		duration = 1.65,
		held = true,
		cues = {
			{ 0.1, "RunStop" }
		}
	},
	{
		label = "WIND-UP",
		clip = "DaggerWindup",
		duration = 0.65,
		held = true,
		windup = true,
		cues = {
			{ 0.04, "Windup" }
		}
	},
	{
		label = "STAB",
		clip = "DaggerStab",
		duration = 0.84,
		held = true,
		cues = {
			{ 0.04, "Swing" },
			{ 0.26, "Hit" }
		}
	},
	{
		label = "RECOVER",
		clip = "Idle",
		duration = 1,
		held = true
	},
	{
		label = "DIVE",
		clip = "DaggerDive",
		duration = 0.72,
		held = true,
		cues = {
			{ 0.02, "Dive" },
			{ 0.32, "Hit" }
		}
	},
	{
		label = "RECOVER",
		clip = "Idle",
		duration = 1.3,
		held = true
	},
	{
		label = "WIND-UP",
		clip = "DaggerWindup",
		duration = 0.48,
		held = true,
		windup = true,
		cues = {
			{ 0.04, "Windup" }
		}
	},
	{
		label = "CANCEL",
		clip = "Idle",
		duration = 0.65,
		held = true,
		cues = {
			{ 0.04, "Cancel" }
		}
	},
	{
		label = "SHEATHE",
		clip = "DaggerEquip",
		duration = 0.94,
		held = true,
		reverse = true,
		cues = {
			{ 0.7, "Sheath" }
		}
	},
	{
		label = "RUNNER WALK",
		clip = "Walk",
		duration = 1.5,
		steps = 0.52
	},
	{
		label = "RUNNER RUN",
		clip = "Run",
		duration = 1.8,
		steps = 0.3
	},
	{
		label = "MOVE LEFT",
		clip = "Left",
		duration = 1,
		steps = 0.5
	},
	{
		label = "MOVE RIGHT",
		clip = "Right",
		duration = 1,
		steps = 0.5
	},
	{
		label = "MOVE BACK",
		clip = "Back",
		duration = 1,
		steps = 0.5
	},
	{
		label = "DASH LEFT",
		clip = "DashLeft",
		duration = 0.62,
		cues = {
			{ 0.02, "BoostStart" }
		}
	},
	{
		label = "DASH RIGHT",
		clip = "DashRight",
		duration = 0.62,
		cues = {
			{ 0.02, "BoostStart" }
		}
	},
	{
		label = "DASH BACK",
		clip = "DashBack",
		duration = 0.71,
		cues = {
			{ 0.02, "BoostStart" }
		}
	},
	{
		label = "FALL",
		clip = "Fall",
		duration = 0.85,
		lift = 0.55
	},
	{
		label = "LAND",
		clip = "Land",
		duration = 0.36,
		cues = {
			{ 0.04, "LandSoft" }
		}
	},
	{
		label = "CAUGHT",
		clip = "CaughtIdle",
		duration = 1.67
	}
}
local v = {
	Idle = true,
	Walk = true,
	Run = true,
	Left = true,
	Right = true,
	Back = true,
	CaughtIdle = true,
	DaggerHold = true
}
local v2 = {
	DaggerEquip = true,
	DaggerWindup = true,
	DaggerStab = true,
	DaggerDive = true,
	DashLeft = true,
	DashRight = true,
	DashBack = true,
	Fall = true,
	Land = true,
	Stop = true
}
local v3 = {
	DaggerEquip = true,
	DaggerWindup = true,
	DaggerStab = true,
	DaggerDive = true
}

local function loadTrack(data, p)
	if data.tracks[p] then
		return data.tracks[p]
	end

	local publishedId = AnimationConfig.PublishedIds[p]

	if not publishedId then
		return
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = publishedId
	table.insert(data.assets, animation)
	local success, result = pcall(function()
		return data.animator:LoadAnimation(animation)
	end)

	if not success then
		return
	end

	result.Name = "Display_" .. p
	result.Looped = v[p] == true

	if p == "DaggerHold" then
		result.Priority = Enum.AnimationPriority.Action
	elseif v2[p] then
		result.Priority = Enum.AnimationPriority.Action2
	elseif p == "Idle" or p == "CaughtIdle" then
		result.Priority = Enum.AnimationPriority.Idle
	else
		result.Priority = Enum.AnimationPriority.Movement
	end

	data.tracks[p] = result
	return result
end

-- equivalent calls inferred from this helper; original call sites unknown
local function play(state, clip, reverse)
	local track = state.tracks[clip]

	if not track then
		return
	end

	local v4 = reverse and -1 or 1
	state.rates[clip] = v4
	track:Play(0.12, 1, v4)

	if reverse and track.Length > 0 then
		track.TimePosition = math.max(0, track.Length - 0.01)
	end
end

local function enter(state, stageIndex)
	state.stageIndex = stageIndex
	state.stage = KnifeDisplayRig.Sequence[stageIndex]
	state.elapsed = 0
	state.nextStep = 0
	table.clear(state.cueFired)
	local stage = state.stage

	for k, track in state.tracks do
		if k ~= stage.clip and (k ~= "DaggerHold" or not stage.held) and track.IsPlaying then
			track:Stop(0.12)
		end
	end

	if stage.held and state.motor then
		local daggerHold = state.tracks.DaggerHold
		local daggerHold2 = daggerHold and not daggerHold.IsPlaying and state.tracks.DaggerHold

		if daggerHold2 then
			state.rates.DaggerHold = 1
			daggerHold2:Play(0.12, 1, 1)
		end
	end

	play(state, stage.clip, stage.reverse) -- equivalent call inferred; original call site unknown
	state.model:SetAttribute("PreviewAction", stage.label)
	state.model:PivotTo(state.basePivot + Vector3.new(0, (stage.lift or 0) * state.scale, 0))
end

function KnifeDisplayRig.animate(p, value)
	for _, v4 in KnifeDisplayRig.Sequence do
		loadTrack(p, v4.clip)
	end

	if p.motor then
		loadTrack(p, "DaggerHold")
	end

	enter(p, value or 1)
end

function KnifeDisplayRig.preAnimation(p)
	if p.motor and p.baseGrip then
		p.motor.Transform = p.baseGrip
	end
end

function KnifeDisplayRig:step(near, value, p, callback)
	if not self.stage then
		return
	end

	if self.near ~= near then
		self.near = near

		for k, track in self.tracks do
			track:AdjustSpeed(not near and 0 or self.rates[k] or 1)
		end
	end

	if near then
		self.elapsed += math.min(value or 0, 0.1)

		if self.elapsed >= self.stage.duration then
			enter(self, self.stageIndex % #KnifeDisplayRig.Sequence + 1)
		end
	end

	local stage = self.stage

	if self.blade then
		local held = stage.held == true

		if stage.draw then
			held = self.elapsed >= 0.17
		elseif stage.reverse then
			held = self.elapsed < 0.77
		end

		self.blade.Transparency = held and 0 or 1
		self.stowed.Transparency = held and 1 or 0
	end

	local track = self.tracks[stage.clip]

	if stage.reverse and track and track.Length > 0 and self.elapsed < 0.15 and track.TimePosition == 0 then
		track.TimePosition = track.Length - 0.01
	end

	if stage.windup and track and track.Length > 0 and track.TimePosition >= track.Length - 0.04 then
		track:AdjustSpeed(0)
		self.rates[stage.clip] = 0
	end

	if self.motor then
		local total = 0

		for k, track2 in self.tracks do
			if v3[k] and track2.IsPlaying then
				total += track2.WeightCurrent
			end
		end

		self.baseGrip = self.motor.Transform
		self.motor.Transform = self.baseGrip:Lerp(self.idle, 1 - math.clamp(total, 0, 1))
		local daggerDive = self.tracks.DaggerDive
		local v4 = daggerDive and daggerDive.IsPlaying and daggerDive.Length > 0
		ScythePose.apply(
			self.scythe,
			not v4 and 0 or daggerDive.TimePosition / daggerDive.Length or 0,
			v4 and daggerDive.WeightCurrent or 0
		)
	end

	if near then
		for k, v4 in stage.cues or {} do
			if not (self.elapsed >= v4[1]) or self.cueFired[k] then
				continue
			end

			self.cueFired[k] = true

			if p and callback then
				callback(v4[2])
			end
		end

		if stage.steps and self.elapsed >= self.nextStep then
			self.nextStep = self.elapsed + stage.steps

			if p and callback then
				callback("FootstepGrass")
			end
		end
	end
end

function KnifeDisplayRig.destroy(data)
	for _, track in data.tracks do
		track:Stop(0)
		track:Destroy()
	end

	for _, asset in data.assets do
		asset:Destroy()
	end

	data.model:Destroy()
end

return KnifeDisplayRig