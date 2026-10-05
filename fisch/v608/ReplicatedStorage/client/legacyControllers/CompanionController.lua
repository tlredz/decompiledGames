local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Net = require(ReplicatedStorage.packages.Net)
local Trove = require(ReplicatedStorage.packages.Trove)
local companions = require(ReplicatedStorage.shared.modules.library.companions)
local skins = require(ReplicatedStorage.shared.modules.library.companions.skins)
local assets = require(ReplicatedStorage.shared.utils.assets)
local module = require("./DataController")
local playerDataReplicator = module.PlayerDataReplicator
local GeneralUtils = require(ReplicatedStorage.shared.utils.GeneralUtils)
local observeCharacter = require(ReplicatedStorage.packages.Observers.observeCharacter)
local module2 = require("./InventoryController")
local Signal = require(ReplicatedStorage.packages.Signal)
local moods = script.Moods
local localPlayer = Players.LocalPlayer
local remoteEvent = Net:RemoteEvent("Companion/Updated")
local remoteEvent2 = Net:RemoteEvent("Companion/RequestMood")
local remoteEvent3 = Net:RemoteEvent("Companion/RequestMoodStop")
local remoteEvent4 = Net:RemoteEvent("Companion/MoodStarted")
local remoteEvent5 = Net:RemoteEvent("Companion/MoodStopped")
local remoteEvent6 = Net:RemoteEvent("Companion/MoodPhase")
local remoteEvent7 = Net:RemoteEvent("Companion/RequestInteract")
local remoteEvent8 = Net:RemoteEvent("Companion/InteractionPlayed")
local remoteEvent9 = Net:RemoteEvent("Companion/StateData")
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = {}
raycastParams.RespectCanCollide = true
raycastParams.IgnoreWater = false
raycastParams.CollisionGroup = "Players"
local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local track = nil
local track2 = nil
local CompanionController = {
	CompanionSpawned = Signal.new()
}

local function getCompanionModel(p: string, p2: string)
	local companion = companions.Companions[p]

	if not companion then
		return nil
	end

	local formatted = `{companion.Model}/{p2}`
	local async = assets.getAsync("companion", formatted)

	if not async and p2 ~= companion.Skins[1] then
		async = assets.getAsync("companion", (`{companion.Model}/{companion.Skins[1]}`))
	end

	if async then
		return async:Clone()
	end

	warn((`[CompanionController] Failed to stream companion "{formatted}"`))
	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getOwnerHRP(player)
	local character = player.Character

	if character then
		return (character:FindFirstChild("HumanoidRootPart"))
	end

	return nil
end

local function loadAnimations(humanoid, companionModel)
	local tracksByName = {}
	local velocityScalesByTrack = {}
	local animations = companionModel:FindFirstChild("Animations")

	if not animations then
		local companionRig = ReplicatedStorage.resources.animations:FindFirstChild("companionRig")

		if not companionRig then
			return tracksByName, velocityScalesByTrack
		end

		animations = companionRig:Clone()
		animations.Parent = companionModel
	end

	local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

	for _, animation in ipairs(animations:GetChildren()) do
		if not animation:IsA("Animation") then
			continue
		end

		local track3 = animator:LoadAnimation(animation)
		local allowLoop = animation:GetAttribute("AllowLoop")

		if not allowLoop then
			if animation.Name == "Jump" then
				allowLoop = false
			else
				allowLoop = animation.Name ~= "Dive"
			end
		end

		track3.Looped = allowLoop
		tracksByName[animation.Name] = track3

		if animation:GetAttribute("VelocityScale") then
			velocityScalesByTrack[track3] = animation:GetAttribute("VelocityScale")
		end
	end

	return tracksByName, velocityScalesByTrack
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playAnimation(state, p: string)
	if state.CurrentAnimation then
		state.CurrentAnimation:Stop()
	end

	local animation = state.Animations[p]

	if animation then
		animation:Play()
		state.CurrentAnimation = animation
	end
end

local function getAnimationForState(data)
	local state = data.State
	local companion = companions.Companions[data.CompanionType]

	if companion and companion.StateAnimations and companion.StateAnimations[state] then
		local stateAnimation = companion.StateAnimations[state]

		if data.Animations[stateAnimation] then
			return stateAnimation
		end
	end

	if state == "Sleeping" then
		if data.Animations.SleepIdle then
			return "SleepIdle"
		end

		return "SitIdle"
	elseif state == "Idle" then
		if data.Animations.SitIdle then
			return "SitIdle"
		end

		return "Idle"
	elseif state == "Walking" then
		if companion and companion.RareWalkChance and data.Animations.RareWalk and math.random() * 100 < companion.RareWalkChance then
			return "RareWalk"
		end

		if data.MoodHandler and data.MoodHandler.GetWalkAnimation then
			return data.MoodHandler:GetWalkAnimation()
		end

		if data.Animations.Run then
			return "Run"
		end

		return "Walk"
	else
		if state == "Jumping" then
			return "Jump"
		end

		if state ~= "Swimming" then
			return "SitIdle"
		end

		if data.Animations.Swim then
			return "Swim"
		end

		return "Run"
	end
end

local function setState(state, state2: string)
	if state.State == state2 then
		return
	end

	local state3 = state.State
	state.State = state2
	playAnimation(state, getAnimationForState(state)) -- equivalent call inferred; original call site unknown

	if state2 == "Jumping" then
		local jump = state.RootPart:FindFirstChild("Jump")

		if jump and jump:IsA("Sound") then
			jump.PlaybackSpeed = math.random(8, 12) / 10
			jump:Play()
		end

		local jumpFX = state.RootPart:FindFirstChild("JumpFX")

		if jumpFX then
			local particle = jumpFX:FindFirstChild("Particle")

			if particle and particle:IsA("ParticleEmitter") then
				particle:Emit(5)
			end
		end
	end

	if state3 == "Jumping" and state2 ~= "Jumping" then
		local land = state.RootPart:FindFirstChild("Land")

		if land and land:IsA("Sound") then
			land:Play()
		end
	end
end

local function getGroundY(vector2: Vector3, characters, groundOffset: number, flag: boolean?)
	raycastParams.FilterDescendantsInstances = characters
	local v6 = vector2 + createVector(0, 10, 0)
	local raycastResult = workspace:Raycast(v6, createVector(0, -50, 0), raycastParams)

	if not raycastResult then
		return nil, false, false, nil
	end

	if raycastResult.Instance:HasTag("VolcanicLava") or raycastResult.Instance:HasTag("KillPart") or raycastResult.Instance:HasTag("FreezingWater") or raycastResult.Instance:HasTag("ToxicWater") then
		return nil, false, false, nil
	end

	if raycastResult.Material == Enum.Material.Water and not flag then
		return nil, false, true, raycastResult.Position.Y
	end

	return raycastResult.Position.Y + groundOffset, true, raycastResult.Material == Enum.Material.Water, nil
end

local function setupInteraction(data)
	local companion = companions.Companions[data.CompanionType]

	if not companion or not companion.InteractionAnimations or #companion.InteractionAnimations == 0 then
		return
	end

	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.ActionText = "Interact"
	proximityPrompt.ObjectText = data.DisplayName or `{data.Owner.DisplayName}'s {data.CompanionType}`
	proximityPrompt.MaxActivationDistance = 5
	proximityPrompt.HoldDuration = 0
	proximityPrompt.RequiresLineOfSight = false
	proximityPrompt.Style = Enum.ProximityPromptStyle.Custom
	proximityPrompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
	proximityPrompt.Name = "InteractionPrompt"
	proximityPrompt:AddTag("CompanionInteractionPrompt")
	proximityPrompt.Parent = data.RootPart
	data.Trove:Add(proximityPrompt)
	data.Trove:Add(proximityPrompt.Triggered:Connect(function(_)
		local character = Players.LocalPlayer.Character

		if not character or track and track.IsPlaying or track2 and track2.IsPlaying then
			return
		end

		if track and track2 and not companion.Flight then
			local pivot = character:GetPivot()
			character:PivotTo(CFrame.lookAt(
				pivot.Position,
				(Vector3.new(data.RootPart.Position.X, pivot.Y, data.RootPart.Position.Z))
			))

			if companion.InteractPlayerAnimation == "petCompanionLarge" then
				track2:Play(nil, nil, 1.5)
			else
				track:Play(nil, nil, 1.5)
			end

			task.wait(0.75)
		end

		remoteEvent7:FireServer(data.Owner)
	end))
end

local function onInteractionPlayed(p, p2: string)
	local v6 = v[p]

	if not v6 or v6.MoodHandler and v6.MoodHandler.activeMood then
		return
	end

	local animation = v6.Animations[p2]

	if not animation then
		return
	end

	animation.Looped = false
	playAnimation(v6, p2) -- equivalent call inferred; original call site unknown
	animation.Stopped:Once(function()
		if v6.CurrentAnimation == animation then
			playAnimation(v6, getAnimationForState(v6)) -- equivalent call inferred; original call site unknown
		end
	end)
end

local function initMoodHandler(p)
	local companion = companions.Companions[p.CompanionType]

	if not (companion and companion.MoodHandler) then
		return
	end

	local child = moods:FindFirstChild(companion.MoodHandler)

	if not child then
		warn((`[CompanionController] Mood handler "{companion.MoodHandler}" not found`))
		return
	end

	local module3 = require(child)

	if type(module3) == "table" and type(module3.new) == "function" then
		p.MoodHandler = module3.new(p)
	else
		warn((`[CompanionController] Mood handler "{companion.MoodHandler}" is invalid (missing .new)`))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyMoodHandler(p)
	if not p.MoodHandler then
		return
	end

	p.MoodHandler:Destroy()
	p.MoodHandler = nil
	p.MoodPositionOverride = nil
	p.MoodSmoothTime = nil
	p.MoodFaceOwner = false
end

local function disableRigCollision(folder)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Massless = true
	end
end

local function prepareRig(companionModel)
	local humanoid = companionModel:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return companionModel:FindFirstChild("RootPart"), (companionModel:FindFirstChild("AnimationController"))
	end

	humanoid.EvaluateStateMachine = false
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
	humanoid.BreakJointsOnDeath = false
	humanoid.RequiresNeck = false
	disableRigCollision(companionModel)
	return companionModel:FindFirstChild("HumanoidRootPart"), humanoid
end

local function spawnCompanion(player, companionType: string, skinName: string)
	if v[player] then
		destroyMoodHandler(v[player]) -- equivalent call inferred; original call site unknown
		v[player].Trove:Destroy()
		v[player] = nil
	end

	local companion = companions.Companions[companionType]

	if not companion then
		return
	end

	local skinName2 = skinName

	if skinName2 and skinName2 ~= "" then
		local skin = skins.Skins[skinName2]

		if skin and skin.ConfigOverrides then
			companion = GeneralUtils.applyTable(companion, skin.ConfigOverrides)
		end
	else
		skinName2 = companion.Skins[1]
	end

	local formatted = `{companionType}/{skinName2}`
	v2[player] = formatted
	local companionModel = getCompanionModel(companionType, skinName2)

	if v2[player] == formatted then
		v2[player] = nil

		if not companionModel then
			return
		end

		local ownerHRP = getOwnerHRP(player) -- equivalent call inferred; original call site unknown

		if ownerHRP then
			local rootPart, humanoid = prepareRig(companionModel)

			if rootPart and humanoid then
				local parent = workspace:FindFirstChild("Pets")

				if not parent then
					parent = Instance.new("Folder")
					parent.Name = "Pets"
					parent.Parent = workspace
				end

				local followOffset = companion.FollowOffset or createVector(-4, 0, 0)
				rootPart.Anchored = true
				rootPart.CanCollide = false
				rootPart.CFrame = CFrame.new(ownerHRP.CFrame:PointToWorldSpace(followOffset))
				companionModel.Name = `{player.Name}_{companionType}`
				companionModel.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
				companionModel.Parent = parent

				if humanoid:IsA("Humanoid") then
					disableRigCollision(companionModel)
				end

				local maid = Trove.new()
				maid:Add(companionModel)
				local animations, moveAnims = loadAnimations(humanoid, companionModel)
				local characters = { companionModel }

				if player.Character then
					table.insert(characters, player.Character)
				end

				local isOwner = player == localPlayer
				local v12 = {
					Owner = player,
					CompanionType = companionType,
					SkinName = skinName,
					Model = companionModel,
					RootPart = rootPart,
					Animator = humanoid,
					Animations = animations,
					CurrentAnimation = nil,
					State = "Idle",
					StateData = v5[player] or {},
					Trove = maid,
					MoveAnims = moveAnims,
					DisplayName = v4[player] and v4[player][companionType],
					PositionVelocity = createVector(0, 0, 0),
					RotationVelocity = CFrame.identity,
					LastPosition = nil,
					IsMoving = false,
					OwnerLastPosition = nil,
					OwnerVelocity = createVector(0, 0, 0),
					TrailBlend = 0,
					BobPhase = 0,
					TargetRotation = rootPart.CFrame - rootPart.CFrame.Position,
					AirBlend = 0,
					IsSwimming = false,
					SwimPitch = 0,
					SwimSurfaceY = nil,
					LazyOwnerRotation = ownerHRP.CFrame - ownerHRP.CFrame.Position,
					LazyRotationVelocity = CFrame.identity,
					IsFollowing = false,
					AnchorPosition = nil,
					FollowStartTime = 0,
					IdleSettleTime = 0,
					MoodPositionOverride = nil,
					MoodSmoothTime = nil,
					MoodModelOffset = nil,
					MoodFaceOwner = false,
					MoodHandler = nil,
					MoodStopRequested = false,
					MoodIgnoreGroundClamp = false,
					AllowWater = false,
					MoodUninterruptible = false,
					IsOwner = isOwner,
					CachedHumanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid"),
					FarAccumulator = 0
				}
				v5[player] = nil
				v[player] = v12
				setupInteraction(v12)
				playAnimation(v12, getAnimationForState(v12)) -- equivalent call inferred; original call site unknown
				initMoodHandler(v12)
				CompanionController.CompanionSpawned:Fire(player, companionType)
				local followSmoothing = companion.FollowSmoothing or 0.2
				local followOffset2 = companion.FollowOffset or createVector(-4, 0, 0)
				local modelOffset = companion.ModelOffset or createVector(0, 0, 0)
				local groundOffset = companion.GroundOffset or rootPart.Size.Y / 2
				local total = 0
				local flight = companion.Flight == true
				local cframe = CFrame.Angles(0, companion.ModelRotation or 0, 0)
				local swimOffset = companion.SwimOffset or 0.5
				local swimPitch = companion.SwimPitch or 0
				local noWalkBob = companion.NoWalkBob == true
				maid:Connect(RunService.RenderStepped, function(farAccumulator: number)
					local DISTANCE_THRESHOLD = 0.5

					if not (rootPart.Parent and rootPart:IsDescendantOf(workspace)) then
						return
					end

					local character = localPlayer.Character
					local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

					if humanoidRootPart then
						if (humanoidRootPart.Position - rootPart.Position).Magnitude > 300 then
							v12.FarAccumulator += farAccumulator

							if v12.FarAccumulator < 0.25 then
								return
							end

							farAccumulator = v12.FarAccumulator
							v12.FarAccumulator = 0
						else
							v12.FarAccumulator = 0
						end
					end

					local ownerHRP2 = getOwnerHRP(v12.Owner) -- equivalent call inferred; original call site unknown

					if ownerHRP2 then
						if v12.OwnerUnavailableSince then
							v12.OwnerUnavailableSince = nil
							local pointToWorldSpace = ownerHRP2.CFrame:PointToWorldSpace(followOffset2)
							rootPart.CFrame = CFrame.new(pointToWorldSpace) * cframe
							v12.PositionVelocity = createVector(0, 0, 0)
							v12.LastPosition = pointToWorldSpace
							v12.IsFollowing = false
							v12.AnchorPosition = nil
							v12.IdleSettleTime = tick()
							v12.TrailBlend = 0
							v12.AirBlend = 0
							v12.OwnerVelocity = createVector(0, 0, 0)
							v12.OwnerLastPosition = nil
							v12.LazyOwnerRotation = ownerHRP2.CFrame - ownerHRP2.CFrame.Position
							v12.LazyRotationVelocity = CFrame.identity
							v12.TargetRotation = ownerHRP2.CFrame - ownerHRP2.CFrame.Position
						else
							local position = ownerHRP2.Position
							local ownerLastPosition = v12.OwnerLastPosition

							if v12.OwnerLastPosition then
								v12.OwnerVelocity = (position - v12.OwnerLastPosition) / math.max(farAccumulator, 0.001)
							end

							v12.OwnerLastPosition = position

							if ownerLastPosition and (position - ownerLastPosition).Magnitude > 50 then
								local pointToWorldSpace = ownerHRP2.CFrame:PointToWorldSpace(followOffset2)
								rootPart.CFrame = CFrame.new(pointToWorldSpace) * cframe
								v12.PositionVelocity = createVector(0, 0, 0)
								v12.LastPosition = pointToWorldSpace
								v12.IsFollowing = false
								v12.AnchorPosition = nil
								v12.IdleSettleTime = tick()
								v12.TrailBlend = 0
								v12.AirBlend = 0
								v12.OwnerVelocity = createVector(0, 0, 0)
								v12.LazyOwnerRotation = ownerHRP2.CFrame - ownerHRP2.CFrame.Position
								v12.LazyRotationVelocity = CFrame.identity
								v12.TargetRotation = ownerHRP2.CFrame - ownerHRP2.CFrame.Position

								if v12.MoodHandler and v12.MoodHandler.activeMood then
									v12.MoodHandler:RequestInterrupt()

									if v12.IsOwner then
										remoteEvent3:FireServer()
										v12.MoodStopRequested = true
									end
								end
							else
								local v13 = (v12.OwnerVelocity * createVector(1, 0, 1)).Magnitude > 1
								v12.TrailBlend += ((v13 and 1 or 0) - v12.TrailBlend) * math.min(farAccumulator * 3, 1)
								local v15 = followOffset2 + Vector3.new(0, 0, v12.TrailBlend * 3)
								local v16 = ownerHRP2.CFrame - ownerHRP2.CFrame.Position
								local v17 = v12
								local smoothDamp, lazyRotationVelocity = TweenService:SmoothDamp(
									v12.LazyOwnerRotation,
									v16,
									v12.LazyRotationVelocity,
									0.4,
									1e999,
									farAccumulator
								)
								v17.LazyRotationVelocity = lazyRotationVelocity
								v12.LazyOwnerRotation = smoothDamp
								local cframe2 = CFrame.new(position) * smoothDamp
								local cachedHumanoid = v12.CachedHumanoid
								local v19, v20

								if cachedHumanoid and cachedHumanoid.Parent then
									local state = cachedHumanoid:GetState()
									v19 = state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall

									if state == Enum.HumanoidStateType.Swimming then
										v20 = true
									else
										v20 = false
									end
								else
									v19 = false
									v20 = false
								end

								local moodPositionOverride = cframe2:PointToWorldSpace(v15)

								if v12.SuppressPositionUpdates then
									moodPositionOverride = nil
								elseif v12.MoodPositionOverride then
									moodPositionOverride = v12.MoodPositionOverride
									v12.IsFollowing = false
									v12.AnchorPosition = nil
								else
									local position2 = rootPart.Position
									local magnitude = ((position - position2) * createVector(1, 0, 1)).Magnitude
									local magnitude2 = ((moodPositionOverride - position2) * createVector(1, 0, 1)).Magnitude

									if v12.IsFollowing then
										local magnitude3 = v12.PositionVelocity.Magnitude

										if magnitude2 < 6 and not v13 and magnitude3 < 2 then
											v12.IsFollowing = false
											v12.IdleSettleTime = tick()
											v12.AnchorPosition = nil
										end
									elseif v12.AnchorPosition then
										if magnitude > 16 or v19 then
											v12.IsFollowing = true
											v12.FollowStartTime = tick()
											v12.AnchorPosition = nil
										end
									elseif v13 then
										v12.IsFollowing = true
										v12.FollowStartTime = tick()
									elseif tick() - v12.IdleSettleTime >= 1 then
										v12.AnchorPosition = position2
									end

									if not v12.IsFollowing then
										if v12.AnchorPosition then
											local anchorPosition = v12.AnchorPosition
											moodPositionOverride = Vector3.new(
												anchorPosition.X,
												moodPositionOverride.Y,
												anchorPosition.Z
											)
										elseif not v13 then
											local position3 = rootPart.Position
											moodPositionOverride = Vector3.new(
												position3.X,
												moodPositionOverride.Y,
												position3.Z
											)
										end
									end
								end

								local flag = false

								if flight then
									if not v12.SuppressPositionUpdates then
										moodPositionOverride += Vector3.new(0, math.sin(tick() * 2) * 0.2, 0)
									end
								elseif not v12.MoodIgnoreGroundClamp then
									local groundY, v21, _, v22 = getGroundY(
										moodPositionOverride,
										characters,
										groundOffset,
										v12.AllowWater
									)
									local v23 = not v21 and v22 ~= nil

									if (v20 or v23) and not v12.MoodPositionOverride then
										local swimSurfaceY = v22 or position.Y
										v12.SwimSurfaceY = swimSurfaceY
										moodPositionOverride = Vector3.new(
											moodPositionOverride.X,
											swimSurfaceY + swimOffset,
											moodPositionOverride.Z
										)
										v12.AirBlend = 0
										v12.BobPhase = 0
										flag = true
									else
										v12.SwimSurfaceY = nil
										v12.AirBlend += ((v19 and 1 or 0) - v12.AirBlend) * math.min(
											farAccumulator * 5,
											1
										)
										local v25 = groundY or moodPositionOverride.Y
										local v26 = position.Y + (followOffset2.Y - 2)
										moodPositionOverride = Vector3.new(
											moodPositionOverride.X,
											v25 + (v26 - v25) * v12.AirBlend,
											moodPositionOverride.Z
										)
										local magnitude = v12.PositionVelocity.Magnitude

										if noWalkBob or not (v12.IsMoving and magnitude > 3) then
											v12.BobPhase = 0
										else
											local v27 = math.clamp((magnitude - 3) / 10, 0, 1)
											v12.BobPhase += farAccumulator * 8
											moodPositionOverride += Vector3.new(
												0,
												math.abs((math.sin(v12.BobPhase))) * 0.3 * v27,
												0
											)
										end
									end
								end

								v12.IsSwimming = flag
								local v21 = rootPart.Position - modelOffset
								local moodSmoothTime

								if v12.MoodPositionOverride and v12.MoodSmoothTime then
									moodSmoothTime = v12.MoodSmoothTime
								elseif v12.IsFollowing then
									local v22 = math.clamp((tick() - v12.FollowStartTime) / 1.5, 0, 1)
									moodSmoothTime = 0.6 + (followSmoothing - 0.6) * v22
								else
									moodSmoothTime = followSmoothing
								end

								local vector2

								if v12.SuppressPositionUpdates then
									vector2 = createVector(0, 0, 0)
								else
									local v22 = v12
									local positionVelocity
									vector2, positionVelocity = TweenService:SmoothDamp(
										v21,
										moodPositionOverride,
										v12.PositionVelocity,
										moodSmoothTime,
										1e999,
										farAccumulator
									)
									v22.PositionVelocity = positionVelocity
								end

								for k, moveAnim in pairs(v12.MoveAnims) do
									k:AdjustSpeed(v12.PositionVelocity.Magnitude / moveAnim)
								end

								if not (flight or v12.MoodIgnoreGroundClamp or flag) then
									local groundY, v22 = getGroundY(vector2, characters, groundOffset)

									if v22 and groundY and vector2.Y < groundY then
										vector2 = Vector3.new(vector2.X, groundY, vector2.Z)
										v12.PositionVelocity = Vector3.new(
											v12.PositionVelocity.X,
											math.max(v12.PositionVelocity.Y, 0),
											v12.PositionVelocity.Z
										)
									end
								end

								local isMoving

								if v12.LastPosition then
									local magnitude = ((vector2 - v12.LastPosition) * createVector(1, 0, 1)).Magnitude
									isMoving = farAccumulator * 0.15 < magnitude
								else
									isMoving = false
								end

								v12.LastPosition = vector2
								v12.IsMoving = isMoving

								if not (v12.MoodHandler and v12.MoodHandler.activeMood) then
									if flag then
										if v12.State ~= "Swimming" then
											local v23 = v12

											if v23.State ~= "Swimming" then
												local state = v23.State
												v23.State = "Swimming"
												playAnimation(v23, getAnimationForState(v23)) -- equivalent call inferred; original call site unknown

												if state == "Jumping" then
													local land = v23.RootPart:FindFirstChild("Land")

													if land and land:IsA("Sound") then
														land:Play()
													end
												end
											end
										end
									elseif flight then
										if v12.State == "Swimming" then
											local v23 = v12

											if v23.State ~= "Idle" then
												local state = v23.State
												v23.State = "Idle"
												playAnimation(v23, getAnimationForState(v23)) -- equivalent call inferred; original call site unknown

												if state == "Jumping" then
													local land = v23.RootPart:FindFirstChild("Land")

													if land and land:IsA("Sound") then
														land:Play()
													end
												end
											end
										end
									elseif v19 and v12.State ~= "Jumping" then
										setState(v12, "Jumping")
									elseif v19 or not (v12.AirBlend < 0.2) or v12.State ~= "Jumping" then
										if v12.State == "Swimming" then
											setState(v12, isMoving and "Walking" or "Idle")
										end
									else
										setState(v12, isMoving and "Walking" or "Idle")
									end

									if v12.State ~= "Jumping" and v12.State ~= "Swimming" then
										if isMoving and v12.State ~= "Walking" then
											if not v12.AnchorPosition or v12.MoodPositionOverride then
												local v23 = v12

												if v23.State ~= "Walking" then
													local state = v23.State
													v23.State = "Walking"
													playAnimation(v23, getAnimationForState(v23)) -- equivalent call inferred; original call site unknown

													if state == "Jumping" then
														local land = v23.RootPart:FindFirstChild("Land")

														if land and land:IsA("Sound") then
															land:Play()
														end
													end
												end
											end
										elseif not isMoving and v12.State == "Walking" then
											local v23 = v12

											if v23.State ~= "Idle" then
												local state = v23.State
												v23.State = "Idle"
												playAnimation(v23, getAnimationForState(v23)) -- equivalent call inferred; original call site unknown

												if state == "Jumping" then
													local land = v23.RootPart:FindFirstChild("Land")

													if land and land:IsA("Sound") then
														land:Play()
													end
												end
											end
										end
									end
								end

								local targetRotation

								if v12.State == "MoodAction" and v12.MoodFaceOwner then
									local v23 = (position - vector2) * createVector(1, 0, 1)

									if v23.Magnitude > DISTANCE_THRESHOLD then
										targetRotation = CFrame.lookAt(createVector(0, 0, 0), v23) - createVector(
											0,
											0,
											0
										)
									else
										targetRotation = v12.TargetRotation
									end
								elseif v12.State == "Walking" or v12.State == "Jumping" or v12.State == "Swimming" then
									local v23 = v12.PositionVelocity * createVector(1, 0, 1)

									if v23.Magnitude > DISTANCE_THRESHOLD then
										targetRotation = CFrame.lookAt(createVector(0, 0, 0), v23) - createVector(
											0,
											0,
											0
										)
									else
										targetRotation = v12.TargetRotation
									end
								elseif v12.State == "MoodAction" and v12.MoodPositionOverride then
									local v23 = v12.PositionVelocity * createVector(1, 0, 1)

									if v23.Magnitude > DISTANCE_THRESHOLD then
										targetRotation = CFrame.lookAt(createVector(0, 0, 0), v23) - createVector(
											0,
											0,
											0
										)
									else
										targetRotation = v12.TargetRotation
									end
								elseif v12.State == "Idle" then
									local v23 = (position - vector2) * createVector(1, 0, 1)

									if v23.Magnitude > DISTANCE_THRESHOLD then
										targetRotation = CFrame.lookAt(createVector(0, 0, 0), v23) - createVector(
											0,
											0,
											0
										)
									else
										targetRotation = v12.TargetRotation
									end
								else
									targetRotation = v12.TargetRotation
								end

								local v23 = v12
								local smoothDamp2, rotationVelocity = TweenService:SmoothDamp(
									v12.TargetRotation,
									targetRotation,
									v12.RotationVelocity,
									0.15,
									1e999,
									farAccumulator
								)
								v23.RotationVelocity = rotationVelocity
								v12.TargetRotation = smoothDamp2

								if not v12.SuppressPositionUpdates then
									local moodModelOffset = v12.MoodModelOffset or createVector(0, 0, 0)
									local identity = CFrame.identity

									if swimPitch ~= 0 then
										local v25 = not v12.IsSwimming and 0 or swimPitch
										v12.SwimPitch += (v25 - v12.SwimPitch) * math.min(farAccumulator * 6, 1)
										identity = CFrame.Angles(v12.SwimPitch, 0, 0)
									end

									rootPart.CFrame = CFrame.new(vector2 + modelOffset + moodModelOffset) * smoothDamp2 * cframe * identity
								end

								if v12.IsOwner and v12.MoodHandler and v12.MoodHandler.activeMood and (v13 or v19) and not (v12.MoodStopRequested or v12.MoodUninterruptible) then
									v12.MoodHandler:RequestInterrupt()
									remoteEvent3:FireServer()
									v12.MoodStopRequested = true
								end

								if v12.MoodHandler and v12.MoodHandler.activeMood then
									local v25 = v12.MoodHandler:UpdateMood(farAccumulator)

									if v12.IsOwner and v25 and not v12.MoodStopRequested then
										v12.MoodHandler:RequestInterrupt()
										remoteEvent3:FireServer()
										v12.MoodStopRequested = true
									end
								end

								if v12.IsOwner then
									if v12.AnchorPosition and not v12.IsFollowing or v12.AlwaysTickUpdate then
										total += farAccumulator

										if total >= 1 then
											local v25 = v12.MoodHandler and not v12.MoodHandler.activeMood and v12.MoodHandler:Update(total)

											if v25 then
												remoteEvent2:FireServer(v25)
											end

											total = 0
										end
									else
										total = 0
									end
								end
							end
						end
					elseif not v12.OwnerUnavailableSince then
						v12.OwnerUnavailableSince = tick()
					elseif tick() - v12.OwnerUnavailableSince > 1.5 and v12.Owner ~= localPlayer then
						v3[v12.Owner] = {
							companionType = v12.CompanionType,
							skinName = skinName2
						}
						despawnCompanion(v12.Owner)
					end
				end)
				maid:Connect(player.CharacterAdded, function(instance)
					characters = { companionModel, instance }
					v12.CachedHumanoid = instance:FindFirstChildOfClass("Humanoid")

					if not v12.CachedHumanoid then
						task.defer(function()
							v12.CachedHumanoid = instance:WaitForChild("Humanoid", 10) or v12.CachedHumanoid
						end)
					end
				end)
				maid:Add(player.CharacterRemoving:Connect(function()
					if v[player] then
						destroyMoodHandler(v[player]) -- equivalent call inferred; original call site unknown
						v[player].Trove:Destroy()
						v[player] = nil
					end
				end))
			else
				warn((`[CompanionController] Model for "{companionType}" missing RootPart or AnimationController`))
				companionModel:Destroy()
			end
		else
			companionModel:Destroy()
			v3[player] = {
				companionType = companionType,
				skinName = skinName2
			}
		end
	elseif companionModel then
		companionModel:Destroy()
	end
end

function despawnCompanion(p)
	v2[p] = nil
	local v6 = v[p]

	if not v6 then
		return
	end

	destroyMoodHandler(v6) -- equivalent call inferred; original call site unknown
	v6.Trove:Destroy()
	v[p] = nil
end

local function updateCompanionName(p, p2: string, displayName: string?)
	if not v4[p] then
		v4[p] = {}
	end

	v4[p][p2] = displayName
	local v6 = v[p]

	if not v6 or v6.CompanionType ~= p2 then
		return
	end

	v6.DisplayName = displayName

	if v6.RootPart then
		local interactionPrompt = v6.RootPart:FindFirstChild("InteractionPrompt")

		if interactionPrompt and interactionPrompt:IsA("ProximityPrompt") then
			interactionPrompt.ObjectText = displayName or interactionPrompt.ObjectText
		end
	end
end

local function onCompanionUpdated(owner, companionType: string, p3: string, p4: string?)
	if p3 == "equip" then
		v3[owner] = nil
		spawnCompanion(owner, companionType, p4)
	elseif p3 == "unequip" then
		v3[owner] = nil
		despawnCompanion(owner)
	elseif p3 == "skin" then
		v3[owner] = nil
		spawnCompanion(owner, companionType, p4)
	elseif p3 == "rename" then
		updateCompanionName(owner, companionType, p4)
	end
end

local function onMoodStarted(p, lastMoodStarted: string, lastMoodData)
	local v6 = v[p]

	if v6 and v6.MoodHandler then
		v6.MoodStopRequested = false
		v6.LastMoodStarted = lastMoodStarted
		v6.LastMoodData = lastMoodData
		v6.MoodHandler:StartMood(lastMoodStarted, lastMoodData or {})
	end
end

local function onMoodStopped(p)
	local v6 = v[p]

	if not (v6 and v6.MoodHandler) then
		return
	end

	v6.MoodStopRequested = false

	if v6.MoodHandler.activeMood then
		v6.MoodHandler:StopMood()
		v6.MoodPositionOverride = nil
		v6.MoodSmoothTime = nil
		v6.MoodFaceOwner = false

		if v6.State == "Idle" then
			return
		end

		local state = v6.State
		v6.State = "Idle"
		playAnimation(v6, getAnimationForState(v6)) -- equivalent call inferred; original call site unknown

		if state == "Jumping" then
			local land = v6.RootPart:FindFirstChild("Land")

			if land and land:IsA("Sound") then
				land:Play()
			end
		end
	end
end

local function onMoodPhase(p, p2: string, options)
	local v6 = v[p]

	if v6 and v6.MoodHandler and v6.MoodHandler.activeMood then
		v6.MoodHandler:OnPhase(p2, options or {})
	end
end

local function onStateDataUpdate(p, stateData)
	local v6 = v[p]

	if not v6 then
		v5[p] = stateData
		return
	end

	v6.StateData = stateData

	if v6.MoodHandler then
		v6.MoodHandler:SetStateData(stateData)
	else
		v5[p] = stateData
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCompanionData()
	playerDataReplicator:WaitForLoaded()
	return playerDataReplicator:Index({ "Companions" })
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getOwnedEntry(p: string)
	local companionData = getCompanionData() -- equivalent call inferred; original call site unknown

	if not companionData then
		return nil
	end

	local v6 = companionData.Owned[p]
	return v6 or nil
end

local recursePatches

recursePatches = function(value, value2, p: number)
	if typeof(value) == "table" and typeof(value2) == "table" then
		for k, item in value do
			value[k] = recursePatches(item, value2[k], p)
		end

		return value
	elseif typeof(value) == "number" and typeof(value2) == "number" then
		return math.map(p, 0, 1, value, value2)
	else
		return value
	end
end

function CompanionController.GetLevel(p: string)
	local ownedEntry = getOwnedEntry(p) -- equivalent call inferred; original call site unknown

	if ownedEntry then
		return ownedEntry.Level or 1
	end

	return 1
end

function CompanionController.GetLevelMultiplier(p: string)
	return 1 + (CompanionController.GetLevel(p) - 1) / 9
end

function CompanionController.GetScaledConfig(p)
	if not p.CompanionScaling then
		return p
	end

	local companionScaling = p.CompanionScaling
	local level = CompanionController.GetLevel(companionScaling.Companion)
	local value = TweenService:GetValue(
		math.map(level, 1, 10, 0, 1),
		companionScaling.ScalingStyle or Enum.EasingStyle.Linear,
		Enum.EasingDirection.In
	)
	local v6 = recursePatches(GeneralUtils.copy(p, true), companionScaling.MaxLevelConfig, value)
	return (GeneralUtils.applyTable(p, v6, false))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateCompanionPrompt(p)
	p.Enabled = not module2.EquippedTool
end

function CompanionController.Start()
	remoteEvent.OnClientEvent:Connect(onCompanionUpdated)
	remoteEvent4.OnClientEvent:Connect(onMoodStarted)
	remoteEvent5.OnClientEvent:Connect(onMoodStopped)
	remoteEvent6.OnClientEvent:Connect(onMoodPhase)
	remoteEvent8.OnClientEvent:Connect(onInteractionPlayed)
	remoteEvent9.OnClientEvent:Connect(onStateDataUpdate)
	CollectionService:GetInstanceAddedSignal("CompanionInteractionPrompt"):Connect(updateCompanionPrompt)
	module2.EquippedToolChanged:Connect(function()
		for _, v6 in CollectionService:GetTagged("CompanionInteractionPrompt") do
			updateCompanionPrompt(v6) -- equivalent call inferred; original call site unknown
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		v3[player] = nil
		v4[player] = nil
		v5[player] = nil
		despawnCompanion(player)
	end)
	local heartbeatConnection = nil
	observeCharacter(Players.LocalPlayer, function(_, instance)
		local animator = instance:WaitForChild("Humanoid"):WaitForChild("Animator")

		if track then
			track:Destroy()
			track = nil
		end

		if track2 then
			track2:Destroy()
			track2 = nil
		end

		if heartbeatConnection then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		end

		track = animator:LoadAnimation(ReplicatedStorage.resources.animations.player.petCompanion)
		track2 = animator:LoadAnimation(ReplicatedStorage.resources.animations.player.petCompanionLarge)
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if humanoidRootPart.AssemblyLinearVelocity.Magnitude > 4 then
				if track and track.IsPlaying then
					track:Stop()
				end

				if track2 and track2.IsPlaying then
					track2:Stop()
				end
			end
		end)
	end)
	RunService.Heartbeat:Connect(function()
		for k, v6 in pairs(v3) do
			if k.Parent then
				local character = k.Character

				if character and character:FindFirstChild("HumanoidRootPart") then
					v3[k] = nil
					spawnCompanion(k, v6.companionType, v6.skinName)
				end
			else
				v3[k] = nil
			end
		end
	end)
end

function CompanionController.GetActiveCompanion(p)
	return v[p]
end

return CompanionController