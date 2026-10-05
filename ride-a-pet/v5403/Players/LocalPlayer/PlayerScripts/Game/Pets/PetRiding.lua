local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local SoundService = game:GetService("SoundService")
local CameraShaker = require(ReplicatedStorage2:WaitForChild("Services"):WaitForChild("CameraShaker"))
local PetRideModes = require(ReplicatedStorage2.GameServices:WaitForChild("PetRideModes"))
local PetRideSurface = require(ReplicatedStorage2.GameServices:WaitForChild("PetRideSurface"))
local petRideMode = ReplicatedStorage2.Remotes.Game:WaitForChild("PetRideMode")
local localPlayer = Players.LocalPlayer
local petDismount = ReplicatedStorage2:WaitForChild("Remotes"):WaitForChild("Game"):WaitForChild("PetDismount")
local animals = SoundService:WaitForChild("Animals")

local function GetAnimalSounds(childName, childName2)
	local folder = animals:FindFirstChild(childName)
	local child = folder and folder:IsA("Folder") and folder:FindFirstChild(childName2)

	if not child then
		return nil
	end

	local sounds = {}

	for _, sound in child:GetChildren() do
		if sound:IsA("Sound") then
			table.insert(sounds, sound)
		end
	end

	if #sounds > 0 then
		return sounds
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetFootstepSounds(petName)
	return (GetAnimalSounds(petName, "Footsteps"))
end

local function EnsureRideSounds(parent, items, p, value)
	local v = math.max(value or 1, 1)
	local clones = {}

	for k, item in items do
		for i = 1, v do
			local name

			if v > 1 then
				name = string.format("%s%d_%d_%s", p, k, i, item.Name)
			else
				name = string.format("%s%d_%s", p, k, item.Name)
			end

			local clone = parent:FindFirstChild(name)

			if not clone then
				clone = item:Clone()
				clone.Name = name
				clone.Parent = parent
			end

			table.insert(clones, clone)
		end
	end

	return clones
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PlayRandomClip(list)
	if not list or #list == 0 then
		return
	end

	local v = list[math.random(#list)]

	if v.Parent then
		v.TimePosition = 0
		v:Play()
	end
end

local function BaseVolumeOf(instance)
	local baseVolume = instance:GetAttribute("BaseVolume")

	if not baseVolume then
		baseVolume = instance.Volume
		instance:SetAttribute("BaseVolume", baseVolume)
	end

	return baseVolume
end

local function PlayFootstepClip(instance, playbackSpeed)
	instance:SetAttribute("FadeToken", (instance:GetAttribute("FadeToken") or 0) + 1)
	instance:SetAttribute("Fading", false)
	local baseVolume = instance:GetAttribute("BaseVolume")

	if not baseVolume then
		baseVolume = instance.Volume
		instance:SetAttribute("BaseVolume", baseVolume)
	end

	instance.Volume = baseVolume
	instance.PlaybackSpeed = playbackSpeed
	instance:Play()
end

local function StopFootstepClips(items)
	if not items then
		return
	end

	for _, item in items do
		if not item.Playing or item:GetAttribute("Fading") then
			continue
		end

		local baseVolume = item:GetAttribute("BaseVolume")

		if not baseVolume then
			baseVolume = item.Volume
			item:SetAttribute("BaseVolume", baseVolume)
		end

		local v = (item:GetAttribute("FadeToken") or 0) + 1
		item:SetAttribute("FadeToken", v)
		item:SetAttribute("Fading", true)
		local v2 = item
		task.spawn(function()
			local total = 0

			while total < 0.08 do
				total += task.wait()

				if v2:GetAttribute("FadeToken") ~= v then
					return
				end

				v2.Volume = baseVolume * math.max(1 - total / 0.08, 0)
			end

			v2:Stop()
			v2.Volume = baseVolume
		end)
	end
end

local function LegacyFootstepPitch(p)
	return (math.clamp((math.max(p, 1) / 70) ^ 0.3333333333333333 * 3, 1, 8))
end

local function EnsureLegacyClip(parent, name, soundId, volume)
	local v = parent:FindFirstChild(name)

	if not v then
		v = Instance.new("Sound")
		v.Name = name
		v.SoundId = soundId
		v.RollOffMode = Enum.RollOffMode.Inverse
		v.RollOffMinDistance = 5
		v.RollOffMaxDistance = 150
		v.Parent = parent
	end

	v.Volume = volume
	v:SetAttribute("BaseVolume", volume)
	return { v }
end

local animations = script:WaitForChild("Animations")
local tracksByName = {}

local function LoadAnimations(character)
	local animator = character:WaitForChild("Humanoid"):WaitForChild("Animator")

	for _, animation in animations:GetChildren() do
		tracksByName[animation.Name] = animator:LoadAnimation(animation)
	end
end

if localPlayer.Character then
	LoadAnimations(localPlayer.Character)
end

localPlayer.CharacterAdded:Connect(LoadAnimations)
local v = CameraShaker.new(Enum.RenderPriority.Camera.Value + 3, function(p)
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera.CFrame *= p
	end
end)
v._renderName = "CameraShakerRiding"
local v2 = {}
local v3 = { Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Ragdoll }

local function StopSync(instance)
	local v4 = v2[instance]

	if not v4 then
		return
	end

	v2[instance] = nil

	for _, connection in v4.Connections do
		connection:Disconnect()
	end

	for _, track in v4.Tracks do
		track:Stop(0.2)
		local v5 = track
		task.delay(0.2, function()
			v5:Destroy()
		end)
	end

	if v4.OffsetTarget and v4.OffsetTarget.Parent then
		v4.OffsetTarget[v4.OffsetProp] = v4.RootJointC0
	end

	if v4.FootstepSound then
		v4.FootstepSound:Stop()
	end

	StopFootstepClips(v4.GallopClips)
	StopFootstepClips(v4.FlyClips)

	if v4.DefaultRunSound then
		v4.DefaultRunSound.Volume = v4.DefaultRunVolume

		if v4.DefaultRunPlaybackSpeed then
			v4.DefaultRunSound.PlaybackSpeed = v4.DefaultRunPlaybackSpeed
		end
	end

	if v4.MutedCharSounds then
		for _, mutedCharSound in v4.MutedCharSounds do
			if mutedCharSound.Sound.Parent then
				mutedCharSound.Sound.Volume = mutedCharSound.Volume
			end
		end
	end

	if v4.WindSound then
		local windSound = v4.WindSound
		v4.WindSound = nil
		task.spawn(function()
			local volume = windSound.Volume
			local total = 0

			while total < 0.35 and windSound.Parent do
				total += task.wait()
				windSound.Volume = volume * math.max(1 - total / 0.35, 0)
			end

			windSound:Destroy()
		end)
	end

	if v4.Pet and v4.Pet.Parent then
		v4.Pet:SetAttribute("PredictedRideMode", nil)
	end

	if v4.AutoJumpEnabled ~= nil and v4.Humanoid then
		v4.Humanoid.AutoJumpEnabled = v4.AutoJumpEnabled
	end

	if v4.FlyParts then
		for _, flyPart in v4.FlyParts do
			flyPart:Destroy()
		end

		local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart then
			humanoidRootPart.CanCollide = true

			if v4.Pet then
				local v5 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)

				if v5.Magnitude > 0.001 then
					humanoidRootPart.CFrame = CFrame.lookAlong(humanoidRootPart.Position, v5.Unit)
				end

				humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
			end
		end

		if v4.Humanoid then
			v4.Humanoid.AutoRotate = true
		end
	end

	if v4.CameraShaking then
		v:Stop()
	end

	if v4.SavedStates and v4.Humanoid then
		for k, savedState in v4.SavedStates do
			v4.Humanoid:SetStateEnabled(k, savedState)
		end
	end

	if v4.IsLocal and v4.Humanoid then
		v4.Humanoid.CameraOffset = createVector(0, 0, 0)
		local currentCamera = workspace.CurrentCamera

		if currentCamera then
			TweenService:Create(currentCamera, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				FieldOfView = 70
			}):Play()
		end
	end
end

local v4 = {}
local StartSync

StartSync = function(instance)
	StopSync(instance)
	local v5 = (v4[instance] or 0) + 1
	v4[instance] = v5
	local humanoid = instance:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
	local petMountJoint = humanoidRootPart and humanoidRootPart:FindFirstChild("PetMountJoint")

	if not (humanoid and humanoidRootPart and petMountJoint) then
		return
	end

	local v6 = os.clock() + 5
	local parent

	while true do
		parent = petMountJoint.Part1 and petMountJoint.Part1.Parent

		if parent then
			break
		end

		task.wait()

		if v6 < os.clock() then
			break
		end
	end

	if not parent or v4[instance] ~= v5 or not petMountJoint.Parent then
		return
	end

	local v7 = os.clock() + 5
	local animator, animations2

	while true do
		local animationController = parent:FindFirstChildOfClass("AnimationController")
		animator = animationController and animationController:FindFirstChildOfClass("Animator")
		animations2 = parent:FindFirstChild("Animations")

		if animator and animations2 then
			break
		end

		task.wait()

		if v7 < os.clock() then
			break
		end
	end

	if not (v4[instance] == v5 and (petMountJoint.Parent and parent.Parent and instance.Parent)) then
		return
	end

	if animator and animations2 then
		local isLocal = instance == localPlayer.Character
		local rootPart = parent:FindFirstChild("RootPart")
		local footstep = rootPart and rootPart:FindFirstChild("Footstep")
		local petName = parent:GetAttribute("PetName") or parent.Name
		local footstepSounds = GetFootstepSounds(petName) -- equivalent call inferred; original call site unknown
		local parent3 = rootPart or parent:FindFirstChildWhichIsA("BasePart")
		local gallopClips

		if footstepSounds and parent3 then
			gallopClips = EnsureRideSounds(parent3, footstepSounds, "RideFootstep_", 4) or nil
		else
			gallopClips = nil
		end

		local animalSounds = GetAnimalSounds(petName, "Fly")
		local flyClips

		if animalSounds and parent3 then
			flyClips = EnsureRideSounds(parent3, animalSounds, "RideFly_", 4) or nil
		else
			flyClips = nil
		end

		local v14 = 0
		local data = parent:FindFirstChild("Data")
		local isFlying = data and data:FindFirstChild("IsFlying")
		local speeds, v15 = PetRideModes.Speeds(parent)
		local v16

		if speeds == nil then
			v16 = false
		else
			v16 = v15 ~= nil
		end

		local enabled

		if v16 then
			enabled = parent:GetAttribute("RideMode") == "Fly"
		elseif isFlying == nil then
			enabled = false
		else
			enabled = isFlying.Value == true
		end

		local v18

		if enabled then
			v18 = flyClips or not v16 and gallopClips
		else
			v18 = gallopClips
		end

		local v19 = v16 and enabled
		local fn
		local lastTime = os.clock()
		local lastTime2 = os.clock()
		local v20 = false
		local now = -1e999
		local v21 = false
		local rideModeSequence = tonumber(parent:GetAttribute("RideModeSequence")) or 0
		local v22 = nil
		local v23 = 0
		local rideToken = parent:GetAttribute("RideToken")
		local animalSounds2 = GetAnimalSounds(petName, "Jumps")
		local animalSounds3 = GetAnimalSounds(petName, "Land")
		local v26

		if animalSounds2 and parent3 then
			v26 = EnsureRideSounds(parent3, animalSounds2, "RideJump_") or nil
		else
			v26 = nil
		end

		local v27

		if animalSounds3 and parent3 then
			v27 = EnsureRideSounds(parent3, animalSounds3, "RideLand_") or nil
		else
			v27 = nil
		end

		local jumping = humanoidRootPart:FindFirstChild("Jumping")
		local landing = humanoidRootPart:FindFirstChild("Landing")

		local function SoundIdOf(sound, p)
			if sound and sound:IsA("Sound") and sound.SoundId ~= "" then
				return sound.SoundId
			end

			return p
		end

		if not v26 and parent3 and not enabled then
			v26 = EnsureLegacyClip(
				parent3,
				"RideJumpLegacy",
				(not jumping or not jumping:IsA("Sound") or jumping.SoundId == "") and "rbxasset://sounds/action_jump.mp3" or jumping.SoundId,
				4
			)
		end

		if not v27 and parent3 and not enabled then
			v27 = EnsureLegacyClip(
				parent3,
				"RideLandLegacy",
				(not landing or not landing:IsA("Sound") or landing.SoundId == "") and "rbxasset://sounds/action_jump_land.mp3" or landing.SoundId,
				4
			)
		end

		local sounds = {}

		for _, sound in { jumping, landing } do
			if sound and sound:IsA("Sound") then
				table.insert(sounds, sound)
			end
		end

		local noFreezeJump = data and data:FindFirstChild("NoFreezeJump")
		local v28

		if noFreezeJump == nil then
			v28 = false
		else
			v28 = noFreezeJump.Value == true
		end

		local footstepSoundOverlap = data and data:FindFirstChild("FootstepSoundOverlap")

		local function ShouldOverlapSteps()
			return footstepSoundOverlap ~= nil and footstepSoundOverlap.Value == true
		end

		local smallShakeOnStep = data and data:FindFirstChild("SmallShakeOnStep")

		local function ShouldShakeOnStep()
			local isLocal2 = isLocal

			if isLocal2 then
				if smallShakeOnStep == nil then
					return false
				else
					return smallShakeOnStep.Value == true
				end
			end

			return isLocal2
		end

		local function GetMovementSoundSpeed()
			local v29 = enabled and "FlySoundSpeed" or "FootstepSpeed"
			local footstepSpeed = data and data:FindFirstChild(v29)

			if not footstepSpeed and enabled and not v16 then
				footstepSpeed = data and data:FindFirstChild("FootstepSpeed")
			end

			local value = footstepSpeed and footstepSpeed:IsA("ValueBase") and tonumber(footstepSpeed.Value)

			if value and value == value and not (value <= 0) and value ~= 1e999 then
				return value
			end

			return 1
		end

		local v29 = {
			Connections = {},
			Tracks = {},
			Humanoid = humanoid,
			IsLocal = isLocal,
			FootstepSound = footstep,
			GallopClips = gallopClips,
			FlyClips = flyClips
		}
		v2[instance] = v29
		local tracks = v29.Tracks

		if isLocal then
			v29.SavedStates = {}

			for _, v30 in v3 do
				v29.SavedStates[v30] = humanoid:GetStateEnabled(v30)
				humanoid:SetStateEnabled(v30, false)
			end
		end

		if isLocal then
			v:Start()
			v29.CameraShaking = true
		end

		local legacyFootstepSpeed = data and data:FindFirstChild("LegacyFootstepSpeed")

		local function GetLegacyFootstepPitch()
			local value = legacyFootstepSpeed and tonumber(legacyFootstepSpeed.Value)

			if value and value > 0 then
				return value
			end

			return (math.clamp((math.max(humanoid.WalkSpeed, 1) / 70) ^ 0.3333333333333333 * 3, 1, 8))
		end

		v29.MutedCharSounds = {}

		for _, sound in sounds do
			table.insert(v29.MutedCharSounds, {
				Sound = sound,
				Volume = sound.Volume
			})
			sound.Volume = 0
		end

		local v30 = not (gallopClips and #gallopClips > 0) and footstep == nil and (v16 or not enabled)
		local v31 = nil
		local running = humanoidRootPart:FindFirstChild("Running")

		if running and running:IsA("Sound") then
			v29.DefaultRunSound = running
			v29.DefaultRunVolume = running.Volume
			v29.DefaultRunPlaybackSpeed = running.PlaybackSpeed

			if v30 then
				v31 = running

				if enabled then
					running.Volume = 0
				end
			else
				running.Volume = 0
			end
		end

		local freeFalling = humanoidRootPart:FindFirstChild("FreeFalling")

		if enabled and freeFalling and freeFalling:IsA("Sound") and freeFalling.SoundId ~= "" then
			local sound = Instance.new("Sound")
			sound.Name = "RideWind"
			sound.SoundId = freeFalling.SoundId
			sound.SoundGroup = freeFalling.SoundGroup
			sound.RollOffMode = freeFalling.RollOffMode
			sound.RollOffMinDistance = freeFalling.RollOffMinDistance
			sound.RollOffMaxDistance = freeFalling.RollOffMaxDistance
			sound.Looped = true
			sound.Volume = 0
			sound.Parent = humanoidRootPart
			sound:Play()
			v29.WindSound = sound
			task.spawn(function()
				local total = 0

				while total < 0.35 and v29.WindSound == sound do
					total += task.wait()
					sound.Volume = math.min(total / 0.35, 1) * 1.6
				end
			end)
		end

		local fn2

		if isLocal then
			local v32 = false

			if v16 then
				v29.AutoJumpEnabled = humanoid.AutoJumpEnabled
				humanoid.AutoJumpEnabled = false

				-- equivalent calls inferred from this helper; original call sites unknown
				local function WatchJumpButton(guiObject)
					if guiObject.Name == "JumpButton" and guiObject:IsA("GuiObject") then
						table.insert(v29.Connections, guiObject.InputEnded:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.Touch then
								v32 = false
							end
						end))
					end
				end

				local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")

				if playerGui then
					for _, descendant in playerGui:GetDescendants() do
						WatchJumpButton(descendant) -- equivalent call inferred; original call site unknown
					end

					table.insert(v29.Connections, playerGui.DescendantAdded:Connect(WatchJumpButton))
				end

				table.insert(v29.Connections, UserInputService.InputEnded:Connect(function(input)
					if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA then
						v32 = false
					end
				end))
				table.insert(v29.Connections, UserInputService.WindowFocusReleased:Connect(function()
					v32 = false
				end))
			end

			table.insert(v29.Connections, UserInputService.JumpRequest:Connect(function()
				if v16 then
					if UserInputService:GetFocusedTextBox() or v32 then
						return
					end

					v32 = true

					if fn and not enabled then
						fn("Fly")
					end
				elseif humanoid.FloorMaterial ~= Enum.Material.Air and fn2 then
					fn2()
				end
			end))
		end

		local idle = nil
		local fly = nil
		local v32 = {
			Idle = Enum.AnimationPriority.Idle,
			Run = Enum.AnimationPriority.Action2,
			Walk = Enum.AnimationPriority.Action2,
			Fly = Enum.AnimationPriority.Action2,
			Jump = Enum.AnimationPriority.Action3,
			Land = Enum.AnimationPriority.Action
		}

		local function LoadPetTrack(animation)
			if not animation:IsA("Animation") or tracks[animation.Name] then
				return
			end

			local success, result = pcall(animator.LoadAnimation, animator, animation)

			if not success then
				warn("PetRiding animation " .. animation.Name .. ": " .. tostring(result))
				return
			end

			result.Priority = v32[animation.Name] or result.Priority

			if v16 and animation.Name == "Land" then
				result.Priority = Enum.AnimationPriority.Action3
				result.Looped = false
			end

			tracks[animation.Name] = result

			if animation.Name == "Idle" then
				idle = result
				result.Looped = true
				result:Play(0.3)
			end

			local fly2 = enabled and tracks.Fly or tracks.Walk or tracks.Run

			if fly2 ~= fly then
				if fly then
					fly:Stop(0.2)
				end

				fly = fly2

				if fly then
					fly.Looped = true
				end
			end
		end

		for _, child in animations2:GetChildren() do
			LoadPetTrack(child)
		end

		table.insert(v29.Connections, animations2.ChildAdded:Connect(LoadPetTrack))
		idle = tracks.Idle

		if idle then
			idle.Looped = true
			idle:Play(0.3)
		end

		fly = enabled and tracks.Fly or tracks.Walk or tracks.Run

		if fly then
			fly.Looped = true
		end

		local v33 = nil

		for _, bone in parent:GetDescendants() do
			if not ((bone.Name == "MiddleTorso" or bone:HasTag("SeatBone")) and bone:IsA("Bone")) then
				continue
			end

			v33 = bone
			break
		end

		local lowerTorso = instance:FindFirstChild("LowerTorso")
		local lowerTorsoRoot = lowerTorso and lowerTorso:FindFirstChild("Root") or humanoidRootPart:FindFirstChild("RootJoint")
		local attachment0 = nil
		local offsetProp = nil

		if lowerTorsoRoot then
			if lowerTorsoRoot:IsA("AnimationConstraint") then
				attachment0 = lowerTorsoRoot.Attachment0
				offsetProp = "CFrame"
			elseif lowerTorsoRoot:IsA("JointInstance") then
				attachment0 = lowerTorsoRoot
				offsetProp = "C0"
			end
		end

		local rootJointC = attachment0 and attachment0[offsetProp]

		if attachment0 then
			v29.OffsetTarget = attachment0
			v29.OffsetProp = offsetProp
			v29.RootJointC0 = rootJointC
		end

		if not (v33 and attachment0) then
			warn("PetRiding: bone-follow disabled - couldn't find the saddle Bone or the character's root joint")
		end

		local noFollowSeatOrientation = data and data:FindFirstChild("NoFollowSeatOrientation")

		local function FollowsSeatOrientation()
			return noFollowSeatOrientation == nil or noFollowSeatOrientation.Value ~= true
		end

		local orientationAdjust = data and (data:FindFirstChild("OrientationAdjust") or data:FindFirstChild("OrientaionAdjust"))

		local function GetLeanRot()
			if orientationAdjust then
				local value = orientationAdjust.Value

				if value.Magnitude > 0 then
					return CFrame.Angles(math.rad(value.X), math.rad(value.Y), (math.rad(value.Z)))
				end
			end

			return CFrame.identity
		end

		if attachment0 then
			local cframe

			if orientationAdjust then
				local value = orientationAdjust.Value

				if value.Magnitude > 0 then
					cframe = CFrame.Angles(math.rad(value.X), math.rad(value.Y), (math.rad(value.Z)))
				else
					cframe = CFrame.identity
				end
			else
				cframe = CFrame.identity
			end

			attachment0[offsetProp] = cframe * rootJointC
		end

		local v37 = nil
		local v38 = nil

		if v33 then
			local cFrame = v33.CFrame
			local parent2 = v33.Parent

			while parent2 and parent2:IsA("Bone") do
				cFrame = parent2.CFrame * cFrame
				parent2 = parent2.Parent
			end

			if parent2 and parent2:IsA("BasePart") then
				v38 = cFrame
				v37 = parent2
			end
		end

		local motor6D = petMountJoint.Part1 and petMountJoint.Part1:FindFirstChildOfClass("Motor6D")
		local v39 = math.max(humanoid.WalkSpeed, 1)
		local total = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function GetSizeAnimSpeed()
			local weight = tonumber(parent:GetAttribute("Weight"))

			if not weight or weight <= 0 then
				return 1
			end

			local v40 = weight / 10

			if v40 <= 1 then
				return 1
			end

			return v40 ^ 0.25
		end

		local function GetMoveAnimSpeed()
			local function Read(childName)
				local valueBase = data and data:FindFirstChild(childName)
				local value = valueBase and valueBase:IsA("ValueBase") and tonumber(valueBase.Value)

				if not value or value ~= value or not (value > 0 and value < 1e999 and value) then
					value = nil
				end

				return value
			end

			local v40 = enabled and "FlyAnimationSpeed" or "RunAnimationSpeed"
			local valueBase = data and data:FindFirstChild(v40)
			local value = valueBase and valueBase:IsA("ValueBase") and tonumber(valueBase.Value)

			if not value or value ~= value or not (value > 0 and value < 1e999 and value) then
				value = nil
			end

			if not value then
				local movementAnimationSpeed = data and data:FindFirstChild("MovementAnimationSpeed")
				local value2 = movementAnimationSpeed and movementAnimationSpeed:IsA("ValueBase") and tonumber(movementAnimationSpeed.Value)

				if not value2 or value2 ~= value2 or not (value2 > 0 and value2 < 1e999 and value2) then
					value2 = nil
				end

				value = value2 or 1
			end

			local sizeAnimSpeed = GetSizeAnimSpeed() -- equivalent call inferred; original call site unknown
			return value * sizeAnimSpeed
		end

		v29.LandPlayed = false
		v29.LandSoundPlayed = false
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.FilterDescendantsInstances = { instance, parent }
		raycastParams.RespectCanCollide = true
		raycastParams.IgnoreWater = true
		raycastParams.CollisionGroup = humanoidRootPart.CollisionGroup
		local v40 = humanoid.HipHeight + humanoidRootPart.Size.Y / 2
		local total2 = 0
		local total3 = 0
		local vector2 = nil
		local linearVelocity, alignOrientation, raycastParams2, v41

		if (enabled or v16) and isLocal then
			local attachment = Instance.new("Attachment")
			attachment.Name = "FlyAttachment"
			attachment.Parent = humanoidRootPart
			linearVelocity = Instance.new("LinearVelocity")
			linearVelocity.Attachment0 = attachment
			linearVelocity.MaxForce = 100000
			linearVelocity.VectorVelocity = createVector(0, 0, 0)
			linearVelocity.Parent = humanoidRootPart
			alignOrientation = Instance.new("AlignOrientation")
			alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
			alignOrientation.Attachment0 = attachment
			alignOrientation.MaxTorque = 1e999
			alignOrientation.Responsiveness = 40
			alignOrientation.CFrame = humanoidRootPart.CFrame.Rotation
			alignOrientation.Parent = humanoidRootPart
			v29.FlyParts = { attachment, linearVelocity, alignOrientation }
			linearVelocity.Enabled = enabled
			alignOrientation.Enabled = enabled
			humanoid.AutoRotate = not enabled
			raycastParams2 = RaycastParams.new()
			raycastParams2.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams2.FilterDescendantsInstances = { instance, parent }
			raycastParams2.RespectCanCollide = true
			raycastParams2.IgnoreWater = true
			raycastParams2.CollisionGroup = humanoidRootPart.CollisionGroup
			local v42 = nil

			for _, bone in parent:GetDescendants() do
				if not bone:IsA("Bone") then
					continue
				end

				local Y = bone.TransformedWorldCFrame.Position.Y

				if not v42 or Y < v42 then
					v42 = Y
				end
			end

			if v16 then
				v41 = v40 + 10
			else
				v41 = humanoidRootPart.Position.Y - (v42 or humanoidRootPart.Position.Y) + 10
			end
		else
			linearVelocity = nil
			alignOrientation = nil
			v41 = 0
			raycastParams2 = nil
		end

		local function ApplyRideMode(p)
			local enabled2 = p == "Fly"

			if enabled2 == enabled then
				return
			end

			enabled = enabled2
			StopFootstepClips(gallopClips)
			StopFootstepClips(flyClips)

			if footstep then
				footstep:Stop()
			end

			local v43

			if enabled2 then
				v43 = flyClips
			else
				v43 = gallopClips
			end

			v18 = v43
			v14 = 0

			if v31 then
				v31.Volume = enabled2 and 0 or 4
			end

			v19 = false

			if enabled2 then
				lastTime = os.clock()
			else
				lastTime2 = os.clock()
				v20 = false
			end

			v21 = false
			now = -1e999

			if fly then
				fly:Stop(0.18)
			end

			if tracks.Jump then
				tracks.Jump:Stop(0.1)
			end

			if tracks.Land then
				tracks.Land:Stop(0.1)
			end

			fly = enabled2 and tracks.Fly or tracks.Walk or tracks.Run

			if fly then
				fly.Looped = true
			end

			if enabled2 and fly then
				fly:Play(0.18)
			end

			if not enabled2 and tracks.Land then
				tracks.Land:Play(0.12)
			end

			total2 = 0
			total3 = 0
			vector2 = nil

			if isLocal then
				if linearVelocity then
					linearVelocity.Enabled = enabled2
				end

				if alignOrientation then
					alignOrientation.CFrame = humanoidRootPart.CFrame.Rotation
					alignOrientation.Enabled = true
					v29.SettlingUntil = os.clock() + 0.18
				end

				humanoid.AutoRotate = not enabled2
				local attribute = parent:GetAttribute(enabled2 and "RideFlySpeed" or "RideWalkSpeed")

				if type(attribute) == "number" then
					humanoid.WalkSpeed = attribute
				end

				if enabled2 then
					humanoid.Jump = false
					humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
				else
					local v44 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)

					if v44.Magnitude > 0.001 and alignOrientation then
						alignOrientation.CFrame = CFrame.lookAlong(createVector(0, 0, 0), v44.Unit)
					end

					local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
					humanoidRootPart.AssemblyLinearVelocity = Vector3.new(
						assemblyLinearVelocity.X,
						math.max(assemblyLinearVelocity.Y, -12),
						assemblyLinearVelocity.Z
					)
					humanoidRootPart.AssemblyAngularVelocity = createVector(0, 0, 0)
					humanoid:ChangeState(Enum.HumanoidStateType.Running)
				end
			end
		end

		if v16 then
			v29.Pet = parent
			table.insert(v29.Connections, parent:GetAttributeChangedSignal("RideMode"):Connect(function()
				if not (isLocal and v22) then
					ApplyRideMode(parent:GetAttribute("RideMode"))
				end
			end))

			if isLocal then
				table.insert(v29.Connections, petRideMode.OnClientEvent:Connect(function(p, p2, p3, p4)
					if p ~= parent or p2 ~= rideToken or p3 < rideModeSequence then
						return
					end

					rideModeSequence = p3
					v22 = nil
					parent:SetAttribute("PredictedRideMode", nil)
					ApplyRideMode(p4)
				end))
			end

			fn = function(predictedRideMode)
				if not isLocal or not petMountJoint.Parent or humanoid.Health <= 0 or predictedRideMode == "Fly" == enabled then
					return
				end

				if predictedRideMode == "Fly" and (os.clock() - lastTime2 < PetRideModes.LandingCooldown or not PetRideSurface.Headroom(
					workspace,
					humanoidRootPart,
					raycastParams
				)) then
					return
				end

				rideModeSequence += 1
				v22 = predictedRideMode
				parent:SetAttribute("PredictedRideMode", predictedRideMode)
				ApplyRideMode(predictedRideMode)
				v23 = 0
			end
		end

		table.insert(v29.Connections, RunService.Stepped:Connect(function(_, dt)
			local DISTANCE_EPSILON = 0.001
			local DISTANCE_THRESHOLD = 0.05

			if motor6D then
				motor6D.Transform = CFrame.identity
			end

			if v33 and attachment0 and v37 then
				local cframe = v37.CFrame * v38
				local v42 = v33.TransformedWorldCFrame * cframe:Inverse()
				local cFrame = humanoidRootPart.CFrame
				local cframe2 = cFrame:Inverse() * v42 * cFrame
				local v43

				if noFollowSeatOrientation == nil then
					v43 = false
				else
					v43 = noFollowSeatOrientation.Value == true
				end

				if v43 then
					cframe2 = CFrame.new(0, cframe2.Y, 0)
				end

				local v44 = attachment0
				local cframe3

				if orientationAdjust then
					local value = orientationAdjust.Value

					if value.Magnitude > 0 then
						cframe3 = CFrame.Angles(math.rad(value.X), math.rad(value.Y), (math.rad(value.Z)))
					else
						cframe3 = CFrame.identity
					end
				else
					cframe3 = CFrame.identity
				end

				v44[offsetProp] = cframe2 * cframe3 * rootJointC

				if isLocal then
					humanoid.CameraOffset = Vector3.new(0, cframe2.Y, 0)
				end
			end

			if v16 then
				v40 = humanoid.HipHeight + humanoidRootPart.Size.Y / 2
				v41 = v40 + 10
				v39 = math.max(humanoid.WalkSpeed, 1)

				if isLocal and fn then
					local rideToken2 = parent:GetAttribute("RideToken")

					if rideToken2 and rideToken2 ~= rideToken then
						rideToken = rideToken2
						rideModeSequence = (tonumber(parent:GetAttribute("RideModeSequence")) or 0) + 1
						v22 = enabled and "Fly" or "Walk"
						v23 = 0
					end

					if v22 and rideToken then
						local now2 = os.clock()

						if v23 <= now2 then
							v23 = os.clock() + 1
							petRideMode:FireServer(parent, rideToken, rideModeSequence, v22)
						end
					end

					if v29.SettlingUntil and os.clock() >= v29.SettlingUntil then
						v29.SettlingUntil = nil

						if not enabled and alignOrientation then
							alignOrientation.Enabled = false
						end
					end

					local currentCamera = workspace.CurrentCamera
					local lookVector = currentCamera and currentCamera.CFrame.LookVector or createVector(0, 0, 0)
					local v42 = lookVector * createVector(1, 0, 1)
					local v43 = v42.Magnitude > DISTANCE_EPSILON and humanoid.MoveDirection:Dot(v42.Unit) or 0

					if lookVector.Y < PetRideModes.TakeoffLookY - 0.1 or v43 < 0.05 then
						v20 = true
					end

					if enabled or not (v20 and PetRideModes.ShouldTakeoff(lookVector.Y, v43, os.clock(), lastTime2)) then
						if enabled then
							local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
							local v44 = humanoid.MoveDirection.Magnitude > DISTANCE_THRESHOLD
							local Y

							if v43 < -0.1736481776669303 * humanoid.MoveDirection.Magnitude then
								Y = -lookVector.Y
							else
								Y = lookVector.Y
							end

							local v45

							if assemblyLinearVelocity.Y < -0.5 then
								v45 = true
							elseif Y < -0.1 then
								v45 = v44
							else
								v45 = false
							end

							if v45 then
								now = os.clock()
							end

							if Y > 0.1 and v44 then
								now = -1e999
							end

							local v46, v47

							if os.clock() - now < 0.8 then
								v46, v47 = PetRideSurface.Ground(
									workspace,
									humanoidRootPart,
									v40,
									assemblyLinearVelocity,
									dt,
									raycastParams
								)
							end

							v21 = v46 ~= nil and v47 < 12

							if v46 and PetRideModes.ShouldLand(true, v47, v46.Normal.Y, os.clock(), lastTime) then
								fn("Walk")
							end
						end
					else
						fn("Fly")
					end
				end
			end

			local v42 = humanoid.FloorMaterial ~= Enum.Material.Air
			local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
			local magnitude

			if enabled then
				magnitude = assemblyLinearVelocity.Magnitude
			else
				magnitude = (assemblyLinearVelocity * createVector(1, 0, 1)).Magnitude
			end

			local v43 = fly

			if v43 then
				local jump = tracks.Jump

				if enabled then
					if v43.IsPlaying then
						local v44 = math.clamp(magnitude / v39, 0.5, 2)

						local function Read(childName)
							local valueBase = data and data:FindFirstChild(childName)
							local value = valueBase and valueBase:IsA("ValueBase") and tonumber(valueBase.Value)

							if not value or value ~= value or not (value > 0 and value < 1e999 and value) then
								value = nil
							end

							return value
						end

						local v45 = enabled and "FlyAnimationSpeed" or "RunAnimationSpeed"
						local valueBase = data and data:FindFirstChild(v45)
						local value = valueBase and valueBase:IsA("ValueBase") and tonumber(valueBase.Value)

						if not value or value ~= value or not (value > 0 and value < 1e999 and value) then
							value = nil
						end

						if not value then
							local movementAnimationSpeed = data and data:FindFirstChild("MovementAnimationSpeed")
							local value2 = movementAnimationSpeed and movementAnimationSpeed:IsA("ValueBase") and tonumber(movementAnimationSpeed.Value)

							if not value2 or value2 ~= value2 or not (value2 > 0 and value2 < 1e999 and value2) then
								value2 = nil
							end

							value = value2 or 1
						end

						local sizeAnimSpeed = GetSizeAnimSpeed() -- equivalent call inferred; original call site unknown
						v43:AdjustSpeed(v44 * (value * sizeAnimSpeed))

						if magnitude < 2 and not v16 then
							total += dt

							if total > 0.4 then
								v43:Stop(0.4)
							end
						else
							total = 0
						end
					elseif magnitude > 4 or v16 then
						total = 0
						v43:Play(0.25)
					end
				elseif v42 and magnitude > 1 and not (jump and jump.IsPlaying) then
					if not v43.IsPlaying then
						v43:Play(0.15)
					end

					local v44 = magnitude / v39

					local function Read(childName)
						local valueBase = data and data:FindFirstChild(childName)
						local value = valueBase and valueBase:IsA("ValueBase") and tonumber(valueBase.Value)

						if not value or value ~= value or not (value > 0 and value < 1e999 and value) then
							value = nil
						end

						return value
					end

					local v45 = enabled and "FlyAnimationSpeed" or "RunAnimationSpeed"
					local valueBase = data and data:FindFirstChild(v45)
					local value = valueBase and valueBase:IsA("ValueBase") and tonumber(valueBase.Value)

					if not value or value ~= value or not (value > 0 and value < 1e999 and value) then
						value = nil
					end

					if not value then
						local movementAnimationSpeed = data and data:FindFirstChild("MovementAnimationSpeed")
						local value2 = movementAnimationSpeed and movementAnimationSpeed:IsA("ValueBase") and tonumber(movementAnimationSpeed.Value)

						if not value2 or value2 ~= value2 or not (value2 > 0 and value2 < 1e999 and value2) then
							value2 = nil
						end

						value = value2 or 1
					end

					local sizeAnimSpeed = GetSizeAnimSpeed() -- equivalent call inferred; original call site unknown
					v43:AdjustSpeed(v44 * (value * sizeAnimSpeed))
				elseif v43.IsPlaying and (magnitude <= 1 or not v42) then
					v43:Stop(0.25)
				end
			end

			if v18 and #v18 > 0 then
				local isPlaying

				if enabled then
					isPlaying = flyClips ~= nil or not v16

					if isPlaying then
						if fly then
							isPlaying = fly.IsPlaying
						else
							isPlaying = magnitude > 1
						end
					end
				else
					isPlaying = v42 and magnitude > 1
				end

				if isPlaying then
					local now2 = os.clock()

					if v14 <= now2 then
						local v44 = v18[math.random(#v18)]
						local v45 = math.max(humanoid.WalkSpeed, 1)
						local playbackSpeed = math.clamp(
							math.max(magnitude, humanoid.MoveDirection.Magnitude * v45) / v45,
							0.7,
							2
						)
						PlayFootstepClip(v44, playbackSpeed)

						if not enabled then
							local v47 = isLocal

							if v47 then
								if smallShakeOnStep == nil then
									v47 = false
								else
									v47 = smallShakeOnStep.Value == true
								end
							end

							if v47 then
								v:ShakeOnce(
									playbackSpeed * 2.8,
									15,
									0,
									0.2,
									createVector(0, 0.35, 0),
									createVector(1, 0, 0.6)
								)
							end
						end

						local v47

						if footstepSoundOverlap == nil then
							v47 = false
						else
							v47 = footstepSoundOverlap.Value == true
						end

						local v48

						if v47 then
							v48 = 0.3 / playbackSpeed / GetMovementSoundSpeed()
						else
							v48 = v44.TimeLength / playbackSpeed * 0.85 / GetMovementSoundSpeed()
						end

						v14 = now2 + math.clamp(v48, 0.05, 3)
					end
				else
					StopFootstepClips(v18)
					v14 = 0
				end
			elseif footstep then
				local v44

				if enabled then
					v44 = not v16 and magnitude > 1
				else
					v44 = v42 and magnitude > 1
				end

				if v44 and not footstep.Playing then
					footstep:Play()
				elseif not v44 and footstep.Playing then
					footstep:Stop()
				end

				if footstep.Playing then
					footstep.PlaybackSpeed = magnitude / v39
				end
			elseif v31 then
				v31.Volume = v16 and enabled and 0 or 4
				local v44 = v31
				local playbackSpeed = legacyFootstepSpeed and tonumber(legacyFootstepSpeed.Value)

				if not (playbackSpeed and playbackSpeed > 0) then
					playbackSpeed = math.clamp((math.max(humanoid.WalkSpeed, 1) / 70) ^ 0.3333333333333333 * 3, 1, 8)
				end

				v44.PlaybackSpeed = playbackSpeed
			end

			if not enabled then
				if not v28 then
					local jump = tracks.Jump

					if jump and jump.IsPlaying and jump.Speed > 0 and jump.Length > 0 then
						local v44 = math.max(dt * jump.Speed * 2, 0.03)

						if jump.TimePosition >= jump.Length - v44 then
							jump.TimePosition = math.max(jump.Length - 0.001, 0)
							jump:AdjustSpeed(0)
						end
					end
				end

				if v42 then
					v29.LandPlayed = false
					v29.LandSoundPlayed = false
				elseif assemblyLinearVelocity.Y < -1 then
					local land = tracks.Land

					if not (v29.LandPlayed and v29.LandSoundPlayed) then
						local v44 = -assemblyLinearVelocity.Y * 0.2 + v40

						if workspace:Raycast(humanoidRootPart.Position, Vector3.new(0, -v44, 0), raycastParams) then
							if not v29.LandSoundPlayed then
								v29.LandSoundPlayed = true
								PlayRandomClip(v27) -- equivalent call inferred; original call site unknown
							end

							if land and not (v29.LandPlayed or land.IsPlaying) then
								v29.LandPlayed = true
								local jump = tracks.Jump

								if jump and jump.IsPlaying then
									jump:Stop(0.1)
								end

								land:Play(0.05)
							end
						end
					end
				end
			end

			if enabled and linearVelocity and linearVelocity.Parent then
				local currentCamera = workspace.CurrentCamera
				local lookVector = currentCamera and currentCamera.CFrame.LookVector or createVector(0, 0, 1)
				local vector3 = Vector3.new(lookVector.X, 0, lookVector.Z)
				local unit

				if vector3.Magnitude > DISTANCE_EPSILON then
					unit = vector3.Unit
				else
					unit = humanoidRootPart.CFrame.LookVector
				end

				local cross = unit:Cross(createVector(0, 1, 0))
				local moveDirection = humanoid.MoveDirection
				local dot = moveDirection:Dot(unit)
				local dot2 = moveDirection:Dot(cross)

				if not vector2 then
					local v44 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)
					local v45

					if v44.Magnitude > DISTANCE_EPSILON then
						v45 = v44.Unit
					else
						v45 = unit
					end

					vector2 = v45
				end

				local v44 = 0
				local v45 = 0
				local v46 = vector2 or unit

				if moveDirection.Magnitude > DISTANCE_THRESHOLD then
					v44 = math.asin((math.clamp(lookVector.Y, -1, 1)))
					local v47 = math.atan2(dot2, dot)
					local v48 = math.abs(v47) > 1.7453292519943295

					if v48 then
						unit = -unit
					end

					if v48 then
						v47 -= math.sign(v47) * 3.141592653589793
					end

					local v49 = math.clamp(v47, -1.3962634015954636, 1.3962634015954636)
					local v50 = CFrame.fromAxisAngle(createVector(0, 1, 0), -v49) * unit

					if v48 then
						v44 = -v44
					end

					local vector4 = (v50 * math.cos(v44) + createVector(0, 1, 0) * math.sin(v44)) * (moveDirection.Magnitude * humanoid.WalkSpeed)

					if vector4.Y < 0 then
						local raycastResult = workspace:Raycast(
							humanoidRootPart.Position,
							createVector(0, -500, 0),
							raycastParams2
						)

						if raycastResult then
							local v51 = raycastResult.Position.Y + (v41 - 10)
							local v52 = math.max(humanoidRootPart.Position.Y - v51, 0) / math.max(dt, 0.001)

							if v52 < -vector4.Y then
								vector4 = Vector3.new(vector4.X, -v52, vector4.Z)
							end
						end
					end

					if vector4.Y > 0 and humanoid.FloorMaterial ~= Enum.Material.Air then
						humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
					end

					linearVelocity.VectorVelocity = vector4
					local v51 = math.atan2(v46.X, v46.Z)
					local v52 = v51 + ((math.atan2(v50.X, v50.Z) - v51 + 3.141592653589793) % 6.283185307179586 - 3.141592653589793) * math.min(
						dt * 8,
						1
					)
					vector2 = Vector3.new(math.sin(v52), 0, (math.cos(v52)))
					v46 = vector2
					v45 = -math.clamp(v49 * 0.45, -0.6981317007977318, 0.6981317007977318)
				else
					local raycastResult = workspace:Raycast(
						humanoidRootPart.Position,
						createVector(0, -100, 0),
						raycastParams2
					)

					if raycastResult then
						local v47 = raycastResult.Position.Y + v41 - humanoidRootPart.Position.Y
						linearVelocity.VectorVelocity = Vector3.new(0, math.clamp(math.max(v47, 0) * 4, 0, 30), 0)
					else
						linearVelocity.VectorVelocity = createVector(0, 0, 0)
					end
				end

				if v16 and not v19 and os.clock() - lastTime < PetRideModes.TakeoffLiftSeconds then
					local vectorVelocity = linearVelocity.VectorVelocity
					linearVelocity.VectorVelocity = Vector3.new(
						vectorVelocity.X,
						math.max(vectorVelocity.Y, PetRideModes.TakeoffLiftSpeed),
						vectorVelocity.Z
					)
					humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
				end

				if v16 then
					if v21 and moveDirection.Magnitude <= DISTANCE_THRESHOLD then
						linearVelocity.VectorVelocity = createVector(0, -12, 0)
					end

					linearVelocity.VectorVelocity = PetRideSurface.Slide(
						workspace,
						humanoidRootPart,
						linearVelocity.VectorVelocity,
						dt,
						raycastParams2
					)
				end

				total2 += (v44 - total2) * math.min(dt * 6, 1)
				total3 += (v45 - total3) * math.min(dt * 6, 1)
				alignOrientation.CFrame = CFrame.lookAlong(createVector(0, 0, 0), v46) * CFrame.Angles(
					total2,
					0,
					total3
				)
			end

			local currentCamera = isLocal and (localPlayer:GetAttribute("FocusFrameDepth") or 0) == 0 and workspace.CurrentCamera

			if currentCamera then
				local v44 = math.clamp(magnitude / 150, 0, 1) * 30 + 70
				currentCamera.FieldOfView += (v44 - currentCamera.FieldOfView) * math.min(dt * 8, 1)
			end
		end))
		local jumpWindup = data and data:FindFirstChild("JumpWindup")
		local timePosition = jumpWindup and jumpWindup.Value or 0.25

		if isLocal then
			local RideCollisionGuard = require(game.ReplicatedStorage.GameServices:WaitForChild("RideCollisionGuard"))
			table.insert(
				v29.Connections,
				RideCollisionGuard.Attach(instance, parent, humanoidRootPart, humanoid, linearVelocity)
			)
		end

		local jumpAnimationSpeed = data and data:FindFirstChild("JumpAnimationSpeed")

		fn2 = function()
			if v16 or os.clock() - (v29.JumpCueClock or 0) < 0.35 then
				return
			end

			v29.JumpCueClock = os.clock()
			PlayRandomClip(v26) -- equivalent call inferred; original call site unknown

			if fly then
				fly:Stop(0.1)
			end

			local jump = tracks.Jump

			if jump then
				if not jump.IsPlaying then
					jump:Play(0.05)
				end

				jump.TimePosition = timePosition
				local value2 = tonumber(jumpAnimationSpeed and jumpAnimationSpeed.Value) or 1
				jump:AdjustSpeed(value2 <= 0 and 1 or value2)
			end
		end

		table.insert(v29.Connections, humanoid.StateChanged:Connect(function(_, p)
			local jump = tracks.Jump
			local land = tracks.Land

			if v16 and p == Enum.HumanoidStateType.Jumping or v16 and enabled then
				return
			end

			if p == Enum.HumanoidStateType.Jumping then
				v29.LandPlayed = false
				v29.LandSoundPlayed = false
				fn2()
			elseif p == Enum.HumanoidStateType.Landed then
				if jump then
					jump:Stop(0.1)
				end

				if not v29.LandSoundPlayed then
					v29.LandSoundPlayed = true
					PlayRandomClip(v27) -- equivalent call inferred; original call site unknown
				end

				if land and not land.IsPlaying then
					land:Play(0.1)
				end
			end
		end))
	else
		warn(string.format(
			"PetRiding: %s never replicated an Animator and animation clips within %ds",
			parent:GetAttribute("PetName") or parent.Name,
			5
		))
		task.delay(1, function()
			if v4[instance] == v5 and petMountJoint.Parent and instance.Parent then
				StartSync(instance)
			end
		end)
	end
end

local function HandleDismountAction(_, p)
	if GamepadUI.GameplayBlocked() then
		return Enum.ContextActionResult.Pass
	end

	if p == Enum.UserInputState.Begin then
		petDismount:FireServer()
	end

	return Enum.ContextActionResult.Sink
end

local v5 = nil
local v6 = false

local function RefreshRidePose()
	local v7 = localPlayer:GetAttribute("IsRiding") == true or localPlayer:GetAttribute("IsPassenger") == true

	if v7 == v6 then
		return
	end

	v6 = v7
	local character = localPlayer.Character

	if v7 then
		local animate = character and character:FindFirstChild("Animate")

		if animate and animate:IsA("BaseScript") then
			animate.Disabled = true
			v5 = animate
		end

		local ride = tracksByName.Ride
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")

		if animator then
			for _, v8 in animator:GetPlayingAnimationTracks() do
				if v8 ~= ride then
					v8:Stop(0.2)
				end
			end
		end

		if ride then
			ride.Priority = Enum.AnimationPriority.Action
			ride:Play(0.2)
		end

		ContextActionService:BindAction(
			"PetDismount",
			HandleDismountAction,
			false,
			Enum.KeyCode.X,
			Enum.KeyCode.ButtonB
		)
	else
		if v5 and v5.Parent then
			v5.Disabled = false
		end

		v5 = nil
		local ride = tracksByName.Ride

		if ride then
			ride:Stop(0.2)
		end

		ContextActionService:UnbindAction("PetDismount")
	end
end

localPlayer:GetAttributeChangedSignal("IsRiding"):Connect(RefreshRidePose)
localPlayer:GetAttributeChangedSignal("IsPassenger"):Connect(RefreshRidePose)
local v7 = {}

local function StartHeldIdle(_) end

-- equivalent calls inferred from this helper; original call sites unknown
local function StopHeldIdle(tool)
	local v8 = v7[tool]
	v7[tool] = nil

	if typeof(v8) == "Instance" then
		v8:Stop(0.2)
	end
end

local function WatchCharacter(character)
	local volcanoScaleFactor = character:GetAttribute("VolcanoScaleFactor") or 1
	local flag = false

	local function QueueGeometryRefresh()
		if flag then
			return
		end

		flag = true
		task.defer(function()
			flag = false

			if not character.Parent then
				return
			end

			local volcanoScaleFactor2 = character:GetAttribute("VolcanoScaleFactor") or 1
			local v8 = volcanoScaleFactor2 / volcanoScaleFactor
			volcanoScaleFactor = volcanoScaleFactor2
			local v9 = v2[character]

			if v9 and v9.RootJointC0 then
				local rootJointC0 = v9.RootJointC0
				v9.RootJointC0 = CFrame.new(rootJointC0.Position * v8) * rootJointC0.Rotation
			end

			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

			if humanoidRootPart and humanoidRootPart:FindFirstChild("PetMountJoint") then
				StartSync(character)
			end
		end)
	end

	local volcanoScaleFactorChangedConnection = character:GetAttributeChangedSignal("VolcanoScaleFactor"):Connect(QueueGeometryRefresh)
	local rideGeometryRevisionChangedConnection = character:GetAttributeChangedSignal("RideGeometryRevision"):Connect(QueueGeometryRefresh)
	local childAddedConnection = character.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") then
			tool:HasTag("Pet")
		end
	end)
	local childRemovedConnection = character.ChildRemoved:Connect(function(tool)
		if tool:IsA("Tool") then
			StopHeldIdle(tool) -- equivalent call inferred; original call site unknown
		end
	end)
	local tool = character:FindFirstChildOfClass("Tool")

	if tool then
		tool:HasTag("Pet")
	end

	local descendantAddedConnection = character.DescendantAdded:Connect(function(motor6D)
		if motor6D.Name == "PetMountJoint" and motor6D:IsA("Motor6D") then
			task.defer(StartSync, character)
		end
	end)
	local descendantRemovingConnection = character.DescendantRemoving:Connect(function(descendant)
		if descendant.Name == "PetMountJoint" then
			StopSync(character)
		end
	end)
	character.AncestryChanged:Connect(function()
		if not character.Parent then
			descendantAddedConnection:Disconnect()
			volcanoScaleFactorChangedConnection:Disconnect()
			rideGeometryRevisionChangedConnection:Disconnect()
			descendantRemovingConnection:Disconnect()
			childAddedConnection:Disconnect()
			childRemovedConnection:Disconnect()
			local tool2 = character:FindFirstChildOfClass("Tool")

			if tool2 then
				StopHeldIdle(tool2) -- equivalent call inferred; original call site unknown
			end

			StopSync(character)
		end
	end)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart and humanoidRootPart:FindFirstChild("PetMountJoint") then
		StartSync(character)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function WatchPlayer(player)
	player.CharacterAdded:Connect(WatchCharacter)

	if player.Character then
		WatchCharacter(player.Character)
	end
end

Players.PlayerAdded:Connect(WatchPlayer)

for _, v8 in Players:GetPlayers() do
	WatchPlayer(v8) -- equivalent call inferred; original call site unknown
end