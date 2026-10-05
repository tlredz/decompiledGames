local createVector = vector.create
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ScrambleBossHazards = require(ReplicatedStorage.Shared.Util.ScrambleBossHazards)
local Kit = require(script.Parent.Kit)
local Vfx = require(script.Parent.Vfx)
local rad = math.rad
local color = Color3.fromRGB(30, 40, 30)
local numberRange = NumberRange.new(0.35, 0.75)
local color2 = Color3.fromRGB(120, 220, 255)
local color3 = Color3.fromRGB(235, 250, 255)
local numberRange2 = NumberRange.new(0.35, 0.8)
local color4 = Color3.fromRGB(80, 255, 60)
local color5 = Color3.fromRGB(255, 45, 45)
local v = {
	Idle = 120484795823977,
	Walk = 107270328959157,
	Spawn = 105745907093338,
	Summon = 95582559814590,
	SpikesAttack = 79479910863027,
	SpikesStrike = 79479910863027,
	SpikeSlam = 115149678962464,
	GrabThrow = 112978654814407,
	SlamDown = 140381763957066,
	Leap = 136703401677693,
	Overheat = 116934559155212,
	Eject = 108503440344107,
	Death = 73457528876079
}
local v2 = {
	Idle = {},
	Recover = {
		Fade = 0.8
	},
	Walk = {
		Clip = "Walk",
		Loop = true,
		Walk = true
	},
	Rush = {
		Clip = "Walk",
		Loop = true,
		Walk = true,
		Speed = 1.8
	},
	SpawnDrop = {
		Clip = "Spawn",
		Speed = 2.3,
		HoldAt = 2.9
	},
	SpawnLand = {
		Clip = "Spawn",
		From = 2.9,
		Speed = 1.3,
		Hold = true
	},
	Drop = {
		Clip = "Leap",
		From = 0.7,
		Speed = 2,
		HoldAt = 2.85
	},
	Land = {
		Clip = "Leap",
		From = 2.85
	},
	SlamCharge = {
		Clip = "SlamDown",
		Speed = 0.6666666666666666,
		HoldAt = 1.43
	},
	Slam = {
		Clip = "SlamDown",
		From = 1.43
	},
	Pound = {
		Clip = "SpikeSlam"
	},
	Swipe = {
		Clip = "SpikesAttack",
		Speed = 0.5,
		HoldAt = 0.45
	},
	SwipeStrike = {
		Clip = "SpikesStrike",
		From = 0.73,
		Speed = 0.7,
		HoldAt = 1.6
	},
	Barrage = {
		Clip = "SpikesAttack",
		Loop = true
	},
	Grab = {
		Clip = "GrabThrow",
		Speed = 0.68,
		HoldAt = 1
	},
	Hold = {
		Clip = "GrabThrow",
		From = 1,
		Speed = 0.4,
		HoldAt = 1.75
	},
	Throw = {
		Clip = "GrabThrow",
		From = 1.75,
		Speed = 1.6
	},
	Summon = {
		Clip = "Summon",
		Hold = true
	},
	Laser = {
		Clip = "GrabThrow",
		Speed = 0.68,
		HoldAt = 1
	},
	Call = {
		Clip = "Summon",
		Hold = true
	},
	Laugh = {
		Clip = "Summon",
		Hold = true
	},
	Roar = {
		Clip = "Spawn",
		Speed = 2.2
	},
	Overheat = {
		Clip = "Overheat",
		Hold = true
	},
	Eject = {
		Clip = "Eject",
		Hold = true
	},
	Fall = {
		Clip = "Death",
		Hold = true
	},
	Dead = {
		Clip = "Death",
		From = 1e999,
		Hold = true
	}
}

local function a(p: number, value: number?, value2: number?)
	return CFrame.Angles(rad(p), rad(value or 0), (rad(value2 or 0)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clipAnimation(p: number)
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. p
	return animation
end

local function preloadClips()
	local clone = table.clone(v)

	for i = 1, 3 do
		local v3 = {}

		for _, v4 in clone do
			table.insert(v3, clipAnimation(v4))
		end

		local v4 = {}
		pcall(function()
			ContentProvider:PreloadAsync(v3, function(value: string, p)
				local v7 = tonumber(string.match(value, "(%d+)%D*$"))

				if v7 and p == Enum.AssetFetchStatus.Success then
					v4[v7] = true
				end
			end)
		end)

		for _, v7 in v3 do
			v7:Destroy()
		end

		for k, v7 in clone do
			if v4[v7] then
				clone[k] = nil
			end
		end

		if next(clone) == nil then
			return
		else
			task.wait(i * 2)
		end
	end

	for k, v3 in clone do
		warn(string.format("[ScrambleBoss] mech clip %s (%d) failed to preload", k, v3))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function holdPoint(p, p2)
	if p.HoldAt then
		return (math.min(p.HoldAt, p2.Length - 0.04))
	end

	if p.Hold then
		return (math.max(p2.Length - 0.04, 0))
	end

	return nil
end

local Rigs = {
	Mech = function(maid, folder)
		local v3 = os.clock() + 5

		while folder:GetAttribute("AnimAt") == nil and os.clock() < v3 do
			task.wait()
		end

		if folder.Parent == nil then
			return nil
		end

		local primaryPart = folder.PrimaryPart or folder:WaitForChild("RootPart")
		local bonesByName = {}

		for _, bone in primaryPart:GetDescendants() do
			if bone:IsA("Bone") then
				bonesByName[bone.Name] = bone
			end
		end

		local upperTorso1 = bonesByName.UpperTorso1
		maid:Connect(folder:GetAttributeChangedSignal("Anim"), function()
			if folder:GetAttribute("Anim") == "Laugh" then
				Kit.Sound("DrScrambleLaughing", primaryPart, 1)
			end
		end)
		local parent3 = folder:FindFirstChildWhichIsA("AnimationController") or folder:WaitForChild(
			"AnimationController",
			5
		)

		if parent3 == nil then
			parent3 = Instance.new("AnimationController")
			parent3.Parent = folder
			maid:Add(parent3)
		end

		maid:Connect(folder.ChildAdded, function(animationController)
			if animationController ~= parent3 and animationController:IsA("AnimationController") then
				task.defer(function()
					if animationController.Parent == folder then
						animationController.Parent = nil
					end
				end)
			end
		end)
		local v5 = parent3:FindFirstChildWhichIsA("Animator")

		if v5 == nil then
			v5 = Instance.new("Animator")
			v5.Parent = parent3
			maid:Add(v5)
		end

		local tracks = {}
		local nows = {}
		local v6 = {}

		local function load(p: string)
			local animation = clipAnimation(v[p]) -- equivalent call inferred; original call site unknown
			local track = v5:LoadAnimation(animation)
			animation:Destroy()
			tracks[p] = track
			nows[p] = os.clock()
			v6[p] = (v6[p] or 0) + 1
			return track
		end

		local v7 = {}

		for k in v do
			local animation = clipAnimation(v[k]) -- equivalent call inferred; original call site unknown
			local track = v5:LoadAnimation(animation)
			animation:Destroy()
			tracks[k] = track
			nows[k] = os.clock()
			v6[k] = (v6[k] or 0) + 1
		end

		tracks.Idle.Looped = true
		tracks.Idle:Play(0)
		maid:Add(function()
			for _, v8 in tracks do
				v8:Stop(0)
				v8:Destroy()
			end
		end)
		local v8 = {}
		local v9 = nil

		for _, descendant in folder:GetDescendants() do
			local followBone = descendant:GetAttribute("FollowBone")
			local bone = followBone and bonesByName[followBone]

			if bone == nil then
				continue
			end

			if descendant:IsA("BasePart") then
				local follow = descendant:FindFirstChild("Follow")

				if follow then
					local v11 = {
						Motor = follow,
						Bone = bone,
						Offset = bone.WorldCFrame:ToObjectSpace(descendant.CFrame)
					}
					table.insert(v8, v11)

					if descendant.Name == "ClawR" then
						v9 = v11
					end
				end
			elseif descendant:IsA("Attachment") then
				table.insert(v8, {
					Attachment = descendant,
					Bone = bone,
					Offset = bone.WorldCFrame:ToObjectSpace(descendant.WorldCFrame)
				})
			end
		end

		local pilot = folder:WaitForChild("Pilot", 5)

		if pilot then
			local parts = pilot:GetAttribute("Parts") or 0
			local v10 = os.clock() + 5

			while os.clock() < v10 do
				local count = 0

				for _, part in pilot:GetDescendants() do
					if part:IsA("BasePart") then
						count += 1
					end
				end

				if parts <= count then
					break
				else
					task.wait(0.1)
				end
			end
		end

		local v10 = nil
		local identity = CFrame.identity

		if pilot and upperTorso1 then
			local clone = pilot:Clone()
			local primaryPart2 = clone.PrimaryPart

			for _, descendant in clone:GetDescendants() do
				if descendant:IsA("BasePart") then
					descendant.Anchored = descendant == primaryPart2
					descendant.CanCollide = false
					descendant.CanQuery = false
					descendant.CanTouch = false
					descendant.Massless = true
				elseif descendant:IsA("WeldConstraint") then
					if descendant.Part0 and not descendant.Part0:IsDescendantOf(clone) or descendant.Part1 and not descendant.Part1:IsDescendantOf(clone) then
						descendant:Destroy()
					end
				elseif descendant:IsA("BallSocketConstraint") then
					descendant.Enabled = false
				elseif descendant:IsA("Humanoid") then
					descendant.EvaluateStateMachine = false
					descendant.PlatformStand = true
				end
			end

			for _, animationConstraint in clone:GetDescendants() do
				if not animationConstraint:IsA("AnimationConstraint") then
					continue
				end

				local attachment0 = animationConstraint.Attachment0
				local attachment1 = animationConstraint.Attachment1
				local parent = attachment0 and attachment0.Parent
				local parent2 = attachment1 and attachment1.Parent

				if attachment0 and attachment1 and parent and parent2 and parent:IsA("BasePart") and parent2:IsA("BasePart") then
					local motor6D = Instance.new("Motor6D")
					motor6D.Name = animationConstraint.Name
					motor6D.Part0 = parent
					motor6D.Part1 = parent2
					motor6D.C0 = attachment0.CFrame
					motor6D.C1 = attachment1.CFrame
					motor6D.Parent = parent2
				end

				animationConstraint:Destroy()
			end

			local drive = pilot:FindFirstChild("Animations") and pilot.Animations:FindFirstChild("Drive")
			local humanoid = clone:FindFirstChildWhichIsA("Humanoid") or clone:FindFirstChildWhichIsA("AnimationController")

			for _, part in pilot:GetDescendants() do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = 1
				end
			end

			identity = upperTorso1.WorldCFrame:ToObjectSpace(pilot:GetPivot())
			clone.Name = "PilotView"
			clone.Parent = folder
			maid:Add(clone)

			if drive and drive:IsA("Animation") and drive.AnimationId ~= "" and humanoid then
				local animator = humanoid:FindFirstChildWhichIsA("Animator") or Instance.new("Animator")
				animator.Parent = humanoid
				local track = animator:LoadAnimation(drive)
				track.Looped = true
				track:Play(0)
			end

			maid:Connect(pilot.AncestryChanged, function()
				if not pilot:IsDescendantOf(folder) then
					clone:Destroy()
					v10 = nil
				end
			end)
			v10 = clone
		end

		local colorsByDescendant = {}
		local descendants = {}

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("BasePart") and descendant:GetAttribute("Eye") then
				colorsByDescendant[descendant] = descendant.Color
			elseif descendant:IsA("Attachment") and descendant:GetAttribute("OverheatFx") then
				for _, descendant2 in descendant:GetDescendants() do
					if not (descendant2:IsA("ParticleEmitter") or descendant2:IsA("Light")) then
						continue
					end

					descendant2.Enabled = false
					table.insert(descendants, descendant2)
				end
			end
		end

		local v11 = {
			Jiggle = 0,
			Key = "",
			Spec = v2.Idle,
			Clip = nil,
			Track = nil,
			StartedAt = 0,
			Pending = false,
			Overheated = false,
			WalkRate = 1,
			LastPosition = primaryPart.Position,
			GrabFree = 0,
			GrabShake = 0,
			HitFlash = 0
		}
		local highlight = Instance.new("Highlight")
		highlight.Name = "HitFlash"
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.FillColor = color5
		highlight.OutlineColor = color5
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 1
		highlight.Enabled = false
		highlight.Adornee = folder
		highlight.Parent = folder
		maid:Add(highlight)

		local function enter(anim: string, animAt: number)
			local spec = v2[anim] or v2.Idle
			local track2

			if spec.Clip then
				track2 = tracks[spec.Clip]
			end

			local track = v11.Track

			if track and track ~= track2 then
				track:Stop(spec.Fade or 0.25)
			end

			v11.Spec = spec
			v11.Clip = spec.Clip
			v11.Track = track2
			v11.StartedAt = animAt
			v11.Pending = track2 ~= nil

			if track2 then
				track2.Looped = spec.Loop == true
			end
		end

		local function start(track, spec)
			local speed = spec.Speed or 1
			local v12 = math.max(Workspace:GetServerTimeNow() - v11.StartedAt, 0)
			local v13 = (spec.From or 0) + v12 * speed

			if spec.Loop then
				v13 %= track.Length
			end

			local v14 = holdPoint(spec, track) -- equivalent call inferred; original call site unknown
			local v15 = math.min(v13, v14 or track.Length - 0.04)
			track.Looped = spec.Loop == true

			if not track.IsPlaying then
				track:Play(0.25)
			end

			track.TimePosition = math.max(v15, 0)
			track:AdjustSpeed(v14 and v14 <= v15 and 0 or speed)
		end

		local function retryMissing()
			local now = os.clock()

			for k, v12 in tracks do
				if v12.Length > 0 or v7[k] or now - nows[k] < 4 then
					continue
				end

				if v6[k] >= 5 then
					v7[k] = true
					warn(string.format("[ScrambleBoss] mech clip %s (%d) never loaded", k, v[k]))
				else
					v12:Destroy()
					local animation = clipAnimation(v[k]) -- equivalent call inferred; original call site unknown
					local track = v5:LoadAnimation(animation)
					animation:Destroy()
					tracks[k] = track
					nows[k] = os.clock()
					v6[k] = (v6[k] or 0) + 1

					if v11.Clip == k then
						v11.Track = track
						v11.Pending = true
					end
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function keepIdle()
			local idle = tracks.Idle

			if idle.Length <= 0 then
				return
			end

			if not idle.Looped then
				idle.Looped = true
			end

			if not idle.IsPlaying then
				idle:Play(0.25)
			end
		end

		local function drive(p: number)
			local anim = folder:GetAttribute("Anim") or "Idle"
			local animAt = folder:GetAttribute("AnimAt") or 0
			local v12 = anim .. "@" .. animAt

			if v12 ~= v11.Key then
				v11.Key = v12
				enter(anim, animAt)
			end

			retryMissing()
			keepIdle() -- equivalent call inferred; original call site unknown
			local position = primaryPart.Position
			local vector2 = Vector3.new(position.X - v11.LastPosition.X, 0, position.Z - v11.LastPosition.Z)
			v11.LastPosition = position

			if p > 0 then
				local v13 = math.clamp(vector2.Magnitude / p / 20, 0.4, 1.6)
				v11.WalkRate += (v13 - v11.WalkRate) * (1 - math.exp(-p * 2))
			end

			local track = v11.Track
			local spec = v11.Spec

			if track == nil or track.Length <= 0 then
				return
			end

			if v11.Pending then
				v11.Pending = false
				start(track, spec)
			else
				if spec.Loop and not track.IsPlaying then
					start(track, spec)
					return
				end

				if spec.Walk then
					track:AdjustSpeed((spec.Speed or 1) * v11.WalkRate)
					return
				end

				local timePosition = holdPoint(spec, track) -- equivalent call inferred; original call site unknown

				if timePosition == nil then
					return
				end

				if track.IsPlaying then
					if track.Speed ~= 0 and timePosition <= track.TimePosition then
						track.TimePosition = timePosition
						track:AdjustSpeed(0)
					end
				else
					track:Play(0)
					track.TimePosition = timePosition
					track:AdjustSpeed(0)
				end
			end
		end

		maid:Connect(RunService.PreAnimation, function(p: number)
			if folder.Parent ~= nil then
				drive(p)
			end
		end)
		maid:Connect(RunService.PreSimulation, function(p: number)
			if folder.Parent == nil then
				return
			end

			v11.Jiggle = math.max(0, v11.Jiggle - p * 5)
			v11.HitFlash = math.max(0, v11.HitFlash - p / 0.18)
			local hitFlash = v11.HitFlash
			highlight.Enabled = hitFlash > 0
			highlight.FillTransparency = 1 - 0.6 * hitFlash
			highlight.OutlineTransparency = 1 - hitFlash
			local jiggle = v11.Jiggle

			if jiggle > 0 and upperTorso1 then
				local upperTorso = upperTorso1
				local transform = upperTorso.Transform
				local v13 = math.sin(os.clock() * 70) * 3.5 * jiggle
				local v14 = math.cos(os.clock() * 53) * 3 * jiggle
				local v15 = math.sin(os.clock() * 61) * 2.5 * jiggle
				upperTorso.Transform = transform * CFrame.Angles(rad(v13), rad(v14 or 0), (rad(v15 or 0)))
			end

			local cFrame = primaryPart.CFrame
			local v12 = nil

			for _, v13 in v8 do
				local worldCFrame = v13.Bone.TransformedWorldCFrame * v13.Offset

				if v13 == v9 then
					v12 = worldCFrame
				end

				if v13.Motor then
					local motor = v13.Motor
					motor.Transform = motor.C0:Inverse() * cFrame:ToObjectSpace(worldCFrame) * motor.C1
				else
					v13.Attachment.WorldCFrame = worldCFrame
				end
			end

			if v10 and upperTorso1 then
				v10:PivotTo(upperTorso1.TransformedWorldCFrame * identity)
			end

			local grabFree = folder.Parent and folder.Parent:GetAttribute("GrabFree") or 0

			if v11.GrabFree < grabFree then
				v11.GrabShake = 1
			end

			v11.GrabFree = grabFree
			v11.GrabShake = math.max(0, v11.GrabShake - p * 4)
			local scrambleGrab = primaryPart:FindFirstChild("ScrambleGrab")

			if v12 and scrambleGrab and scrambleGrab:IsA("Weld") then
				local v13 = v11.GrabShake * 0.3
				scrambleGrab.C0 = ScrambleBossHazards.GripCFrame(cFrame:PointToObjectSpace(v12.Position)) * CFrame.Angles(
					math.sin(os.clock() * 38) * v13,
					0,
					math.cos(os.clock() * 31) * v13
				)
			end

			local overheated = folder:GetAttribute("Overheated") == true

			if overheated ~= v11.Overheated then
				v11.Overheated = overheated

				for _, v13 in descendants do
					v13.Enabled = overheated
				end
			end

			local anim = folder:GetAttribute("Anim") or "Idle"
			local midpoint = (math.sin(os.clock() * 14) + 1) / 2
			local v14 = anim == "Fall" or anim == "Dead" or anim == "Eject"

			for k, color6 in colorsByDescendant do
				if v14 then
					color6 = color:Lerp(Kit.Red, anim ~= "Eject" and 0 or midpoint)
				end

				k.Color = color6
			end
		end)
		return {
			Hit = function(flag: boolean)
				v11.Jiggle = flag and 1 or 0.6
				v11.HitFlash = 1
			end
		}
	end,
	Ball = function(maid, folder, _)
		local animations = folder:FindFirstChild("Animations")
		local humanoid = folder:FindFirstChildWhichIsA("Humanoid", true)
		local drScrambleBall = folder:FindFirstChild("DrScrambleBall", true)
		local animationController = drScrambleBall and drScrambleBall:FindFirstChildWhichIsA(
			"AnimationController",
			true
		)
		local tracks = {}

		if animations and humanoid then
			local animator = humanoid:FindFirstChildWhichIsA("Animator") or Instance.new("Animator")
			animator.Parent = humanoid
			local pilotDrive = animations:FindFirstChild("PilotDrive")

			if pilotDrive and pilotDrive:IsA("Animation") and pilotDrive.AnimationId ~= "" then
				table.insert(tracks, animator:LoadAnimation(pilotDrive))
			end
		end

		if animations and animationController then
			local animator = animationController:FindFirstChildWhichIsA("Animator") or Instance.new("Animator")
			animator.Parent = animationController
			local ballDrive = animations:FindFirstChild("BallDrive")

			if ballDrive and ballDrive:IsA("Animation") and ballDrive.AnimationId ~= "" then
				table.insert(tracks, animator:LoadAnimation(ballDrive))
			end
		end

		for _, v3 in tracks do
			v3.Looped = true
			v3:Play(0)
		end

		maid:Add(function()
			for _, v3 in tracks do
				v3:Stop(0)
				v3:Destroy()
			end
		end)
		local primaryPart = folder.PrimaryPart
		local v3, v4

		if primaryPart then
			v3, v4 = Kit.Loop("BallDriving", primaryPart)

			if v3 then
				maid:Add(v3)
			end
		else
			v3 = nil
			v4 = 0
		end

		local position = not primaryPart and createVector(0, 0, 0) or primaryPart.Position
		local stunned = folder:GetAttribute("Stunned") == true
		local colorsByDescendant = {}
		local descendants = {}

		for _, descendant in folder:GetDescendants() do
			if descendant:IsA("BasePart") and descendant:GetAttribute("DamageGlow") then
				colorsByDescendant[descendant] = descendant.Color
			elseif descendant:IsA("ParticleEmitter") and descendant.Name == "DamageSmoke" then
				descendant.Enabled = false
				table.insert(descendants, descendant)
			end
		end

		local visor = folder:FindFirstChild("Visor")
		local glass = visor and visor:FindFirstChild("Glass")
		local visorFollow = glass and glass:FindFirstChild("VisorFollow")
		local child

		if glass and drScrambleBall then
			child = drScrambleBall:FindFirstChild(glass:GetAttribute("FollowBone") or "", true)
		else
			child = nil
		end

		local followOffset = glass and glass:GetAttribute("FollowOffset")
		local parts = {}
		local v5 = -1

		if visor then
			for _, part in visor:GetDescendants() do
				if part:IsA("BasePart") and part:GetAttribute("CrackAt") then
					table.insert(parts, part)
				end
			end
		end

		local primaryPart2 = folder.PrimaryPart
		local _, v6 = folder:GetBoundingBox()

		for _, v7 in Vfx.Trail(primaryPart2, v6.X) do
			maid:Add(v7)
		end

		local highlight = Instance.new("Highlight")
		highlight.Name = "CoreHighlight"
		highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		highlight.FillColor = color2
		highlight.OutlineColor = color4
		highlight.FillTransparency = 1
		highlight.OutlineTransparency = 0.3
		highlight.Adornee = folder
		highlight.Parent = folder
		maid:Add(highlight)
		local total = 0
		local v7 = 0
		local v8 = 0
		maid:Connect(RunService.RenderStepped, function(p: number)
			local v9 = math.clamp(folder:GetAttribute("DamageRatio") or 0, 0, 1)
			local stunned2 = folder:GetAttribute("Stunned") == true
			local v10 = (math.sin(os.clock() * (v9 * 28 + 12)) + 1) * 0.5
			local v11 = math.noise(os.clock() * (v9 * 18 + 8), 0, 0) * 0.5 + 0.5
			local v12 = math.clamp(v9 * (v10 * 0.35 + 0.35 + v11 * 0.3), 0, 0.9)

			if stunned2 then
				v12 = math.max(v12, v10 * 0.8)
			end

			for k, v13 in colorsByDescendant do
				k.Color = v13:Lerp(Color3.fromRGB(8, 35, 12), v12)
			end

			if visorFollow and child and typeof(followOffset) == "CFrame" then
				local v13 = child.TransformedWorldCFrame * followOffset
				local cFrame = visorFollow.Part0.CFrame
				visorFollow.Transform = visorFollow.C0:Inverse() * cFrame:ToObjectSpace(v13) * visorFollow.C1
			end

			if v9 ~= v5 then
				v5 = v9

				for _, v13 in parts do
					v13.Transparency = (v13:GetAttribute("CrackAt") or 2) <= v9 and 0.1 or 1
				end
			end

			for _, v13 in descendants do
				v13.Enabled = v9 >= 0.28
				v13.Rate = v9 * 5 + 1
			end

			if stunned2 and not stunned then
				Kit.Sound("DrivingStunned", primaryPart or folder, 1)
			end

			stunned = stunned2

			if v3 and primaryPart then
				local v13 = (primaryPart.Position - position).Magnitude / math.max(p, 0.004166666666666667)
				position = primaryPart.Position
				local v14 = stunned2 and 0 or math.clamp(v13 / 45, 0.25, 1)
				local v15 = math.min(1, p * 5)
				v3.Volume += (v14 * v4 - v3.Volume) * v15
			end

			total += ((stunned2 and 1 or 0) - total) * math.min(1, p * 6)
			local now = os.clock()

			if v8 <= now then
				v8 = os.clock() + 0.05
				v7 = math.random()
			end

			highlight.FillTransparency = 1 - (1 - (numberRange2.Min + (numberRange2.Max - numberRange2.Min) * v7)) * total
			highlight.OutlineColor = color4:Lerp(color3, total)
			highlight.OutlineTransparency = (v7 * 0.6 - 0.3) * total + 0.3
		end)
	end
}

local function waitForDroneParts(instance)
	local hitbox = instance:WaitForChild("Hitbox", 10)
	local lastTime = os.clock()

	while instance.PrimaryPart == nil and instance.Parent ~= nil and os.clock() - lastTime < 10 do
		task.wait()
	end

	return hitbox, instance.PrimaryPart
end

local function attachDroneBar(object, instance, instance2)
	local v3, v4 = waitForDroneParts(instance)

	if v3 == nil or v4 == nil or not instance:IsDescendantOf(Workspace) then
		return
	end

	local visualSize = instance:GetAttribute("VisualSize")
	local Y

	if typeof(visualSize) == "Vector3" then
		Y = visualSize.Y
	else
		Y = select(2, instance:GetBoundingBox()).Y
	end

	local clone = instance2:Clone()
	clone.Adornee = v4
	clone.StudsOffsetWorldSpace = Vector3.new(0, Y / 2 + 2, 0)
	clone.Enabled = true
	clone.Parent = v4
	object:Add(clone)
	local healthProgress = clone:FindFirstChild("HealthProgress")
	local fill = healthProgress and healthProgress:FindFirstChild("Fill")
	local textLabel = healthProgress and healthProgress:FindFirstChild("TextLabel")

	local function refresh()
		local health = v3:GetAttribute("Health") or 0
		local v5 = math.max(v3:GetAttribute("MaxHealth") or 1, 1)
		local v6 = math.clamp(health / v5, 0, 1)

		if textLabel then
			textLabel.Text = string.format("%d / %d HP", math.max(0, (math.ceil(health))), v5)
		end

		if fill then
			fill.Visible = v6 > 0
			TweenService:Create(fill, TweenInfo.new(0.15), {
				Size = UDim2.fromScale(v6, 1)
			}):Play()
		end
	end

	object:Connect(v3:GetAttributeChangedSignal("Health"), refresh)
	object:Connect(v3:GetAttributeChangedSignal("MaxHealth"), refresh)
	refresh()
end

function Rigs.Drone(maid, instance)
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Kit.Red
	highlight.OutlineColor = Kit.Red
	highlight.FillTransparency = 0.9
	highlight.OutlineTransparency = numberRange.Min
	highlight.Adornee = instance
	highlight.Parent = instance
	maid:Add(highlight)
	local scrambleBoss = ReplicatedStorage.Assets.UI:FindFirstChild("ScrambleBoss")
	local droneHealth = scrambleBoss and scrambleBoss:FindFirstChild("DroneHealth")

	if droneHealth then
		maid:Add(task.spawn(attachDroneBar, maid, instance, droneHealth))
	end

	local lastTime = nil
	maid:Connect(RunService.RenderStepped, function()
		if instance.Parent == nil then
			return
		end

		if instance:GetAttribute("Armed") then
			if lastTime == nil then
				lastTime = os.clock()
				Kit.Sound("DroneFuse", instance.PrimaryPart, 1)
			end

			local v3 = os.clock() - lastTime
			highlight.FillTransparency = math.floor(v3 * (v3 < 1.86 and 2 or 11)) % 2 == 0 and 0.3 or 0.85
			highlight.OutlineTransparency = 0
		else
			if lastTime then
				lastTime = nil
				local droneFuse = instance.PrimaryPart and instance.PrimaryPart:FindFirstChild("DroneFuse")

				if droneFuse then
					droneFuse:Destroy()
				end
			end

			local midpoint = (math.sin(os.clock() * 3) + 1) / 2
			highlight.FillTransparency = 0.9
			highlight.OutlineTransparency = numberRange.Min + (numberRange.Max - numberRange.Min) * midpoint
		end
	end)
end

task.spawn(preloadClips)
return Rigs