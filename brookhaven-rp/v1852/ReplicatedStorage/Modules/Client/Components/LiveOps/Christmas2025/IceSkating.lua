local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ContextActionService = game:GetService("ContextActionService")
local ContentProvider = game:GetService("ContentProvider")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local OscillatingSpring = require(ReplicatedStorage.Modules.Client.Util.OscillatingSpring)
local DebugVisualization = require(ReplicatedStorage.Modules.Client.Util.DebugVisualization)
local context = DebugVisualization.NewContext("InStudio")
local NumberUtil = require(ReplicatedStorage.Modules.Shared.Utils.NumberUtil)
local v = Component.new({
	Tag = "IceSkating"
})
local phi = NumberUtil.phi
local v2 = NumberUtil.phi * 2
local v3 = 0.5
local v4 = 2
local v5 = 1.2
local v6 = 1.5
local v7 = 32
local v8 = 10
local v9 = 3.141592653589793
local v10 = 7.5
local quarterCircle = NumberUtil.quarterCircle
local v11 = 3.141592653589793
local v12 = 0.5235987755982988
local v13 = 0.8726646259971648
local v14 = 2.356194490192345
local v15 = 1
local unit = createVector(0, 1, 0)
local v17 = -unit * 9.81 * 2 * 3.141592653589793
local v18 = v17.Magnitude * 10
local v19 = false
local v20 = 0
local v21 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function FlattenVector(vector2: Vector3)
	if vector2.Magnitude > 0 then
		return vector2 - vector2:Dot(unit.Unit) * unit.Unit
	end

	return createVector(0, 0, 0)
end

local function CastVectorToLocalFlatPlanarSurface(vector2: Vector3, vector3: Vector3)
	if vector3.Magnitude < NumberUtil.basicallyZero then
		return CFrame.identity
	end

	local unit2 = (vector2.Unit - vector2.Unit:Dot(vector3.Unit) * vector3.Unit).Unit
	local unit3 = unit2:Cross(vector3.Unit).Unit
	return CFrame.fromMatrix(createVector(0, 0, 0), unit3, vector3.Unit, -unit2)
end

local function LerpVectorWithUp(vector2: Vector3, vector3: Vector3, vector4: Vector3, p: number)
	if vector2 ~= vector2 or vector2.Magnitude <= 0 then
		return vector3 * p
	end

	if vector3 ~= vector3 or vector3.Magnitude <= 0 then
		return vector2 * (1 - p)
	end

	local v22 = CastVectorToLocalFlatPlanarSurface(vector2, vector4).LookVector:Angle(
		CastVectorToLocalFlatPlanarSurface(vector3, vector4).LookVector,
		vector4
	) * p
	return (CFrame.lookAlong(createVector(0, 0, 0), vector2, vector4) * CFrame.Angles(0, v22, 0)).LookVector * math.lerp(
		vector2.Magnitude,
		vector3.Magnitude,
		p
	)
end

local function ReflectCFrameAlongPlane(cframe: CFrame, vector2: Vector3, vector3: Vector3)
	return CFrame.fromMatrix(
		cframe.Position - 2 * (vector2.Unit * (cframe.Position - vector3):Dot(vector2.Unit)),
		cframe.RightVector - 2 * vector2.Unit * cframe.RightVector:Dot(vector2.Unit),
		cframe.UpVector - 2 * vector2.Unit * cframe.UpVector:Dot(vector2.Unit)
	)
end

function v:Construct()
	self._Janitor = Janitor.new()
end

function v:GetSurfaceCast(vector2: Vector3?, value: number?, vector3: Vector3?)
	local raycastResult = nil

	for _ = 1, 3 do
		raycastResult = workspace:Raycast(
			vector3 or self.hrp.Position,
			-(vector2 or unit) * (value or 250),
			self.skatableSurfaceParams
		)

		if not (raycastResult and raycastResult.Instance and raycastResult.Instance:IsA("BasePart")) then
			break
		end

		if raycastResult.Instance.Transparency >= 0.95 then
			self.skatableSurfaceParams:AddToFilter(raycastResult.Instance)
		else
			if v19 then
				break
			end

			if raycastResult.Instance:HasTag("SkatableSurface") then
				return raycastResult
			end
		end
	end

	return raycastResult
end

function v:LoadSkateAnimations()
	local humanoid = self.Instance:FindFirstChild("Humanoid")
	local animator = humanoid and humanoid:FindFirstChild("Animator")

	if not animator then
		error("IceSkating::LoadSkateAnimations() - missing Animator")
		return
	end

	local skateAnimations = self.Instance:WaitForChild("SkateAnimations", 1)

	if not skateAnimations then
		error("IceSkating::LoadSkateAnimations() - missing SkateAnimations folder; this should've been replicated from the server before the IceSkating component was applied to the character!")
		return
	end

	local children = {}
	self.animations = {}
	local LoadAnimFolder

	LoadAnimFolder = function(instance, p)
		for _, child in instance:GetChildren() do
			if child:IsA("Folder") then
				p[child.Name] = {}
				LoadAnimFolder(child, p[child.Name])
			else
				if not child:IsA("Animation") then
					error("IceSkating::LoadSkateAnimations() - found non-animation/folder descendant in SkateAnimations folder?")
				end

				p[child.Name] = animator:LoadAnimation(child)
				table.insert(children, child)
			end
		end
	end

	LoadAnimFolder(skateAnimations, self.animations)
	task.spawn(ContentProvider.PreloadAsync, ContentProvider, children)
end

local count = 0
local unit2 = unit
local now = 0

function v:ChangeUp(vector2: Vector3, p2: number?)
	if unit2:FuzzyEq(vector2.Unit, 0.01) then
		return
	end

	now = tick()

	if p2 ~= 0 then
		p2 = 1 / (p2 or NumberUtil.phi / 10)
	end

	unit2 = vector2.Unit
	count += 1
	local v22 = count
	local v23 = unit
	local v24 = p2 ~= 0 and 0 or 1 - NumberUtil.basicallyZero
	local orient = self._Janitor:Get("Orient")
	local velocity = self._Janitor:Get("Velocity")

	if self._Janitor and self._Janitor.Get then
		orient = self._Janitor:Get("Orient")
		velocity = self._Janitor:Get("Velocity")
	end

	task.spawn(function()
		while v24 < 1 do
			v24 = math.clamp(v24 + RunService.PostSimulation:Wait() * p2, 0, 1)

			if v22 ~= count then
				break
			end

			local v25 = unit
			unit = v23:Lerp(vector2.Unit, v24).Unit
			local cframe = CFrame.fromRotationBetweenVectors(v25, unit)

			if orient then
				orient.CFrame *= cframe
			end

			if velocity and velocity.VectorVelocity.Magnitude > 0 then
				velocity.VectorVelocity = (CFrame.lookAlong(createVector(0, 0, 0), velocity.VectorVelocity.Unit, v25) * cframe).LookVector * velocity.VectorVelocity.Magnitude
			end
		end
	end)
end

function v:UpdateConfigs(p: number, flag: boolean, flag2: boolean, vector2: Vector3, p2: number, vector3: Vector3)
	self:ChangeUp(vector2, 0)

	if p >= 2 then
		now = tick()
	end

	v17 = vector3
	local v22 = p2 / v7
	v7 = p2
	v8 *= v22
	v10 *= v22
	v6 *= v22
	v5 *= v22
	v21 = flag2
	v20 = p
	v19 = flag

	if Players.LocalPlayer.Character then
		local _, _ = Players.LocalPlayer.Character:GetBoundingBox()

		for _, part in Players.LocalPlayer.Character:GetDescendants() do
			if not (part:IsA("BasePart") and part.Transparency < 1) then
				continue
			end

			local instance = Instance.fromExisting(part)
			local v23 = {
				"SpecialMesh",
				"BlockMesh",
				"Decal",
				"Texture"
			}

			for _, child in part:GetChildren() do
				for _, className in v23 do
					if not child:IsA(className) then
						continue
					end

					local clone = child:Clone()
					clone.Parent = instance
				end
			end

			instance.CanCollide = false
			instance.CastShadow = false
			instance.CanQuery = false
			instance.CanTouch = false
			instance.Archivable = false
			instance.Parent = workspace.Terrain
			instance.Color = Color3.new(1, 1, 1)
			instance.Material = Enum.Material.Neon
			instance.Anchored = true
			Debris:AddItem(instance, 1)
			TweenService:Create(instance, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Transparency = 1,
				Color = Color3.new(1, 0.843, 0),
				Size = instance.Size * (1 + NumberUtil.phi / 2)
			}):Play()
		end
	end
end

function v:Start()
	local instance = self.Instance

	if instance ~= (Players.LocalPlayer and Players.LocalPlayer.Character) then
		return
	end

	self:ChangeUp(createVector(0, 1, 0), 0)
	self.isLocalPlayer = true
	local name = Players.LocalPlayer.Name
	local humanoidRootPart = instance and instance:FindFirstChild("HumanoidRootPart")
	local humanoid = instance and instance:FindFirstChild("Humanoid")
	local rootAttachment = humanoidRootPart and humanoidRootPart:FindFirstChild("RootAttachment")
	local leftFoot = instance and instance:FindFirstChild("LeftFoot")
	local rightFoot = instance and instance:FindFirstChild("RightFoot")

	if humanoid and humanoidRootPart and leftFoot and rightFoot then
		if rootAttachment then
			self.hrp = humanoidRootPart
			self:LoadSkateAnimations()
			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			raycastParams.IgnoreWater = false
			raycastParams.FilterDescendantsInstances = {}
			local running = humanoidRootPart:FindFirstChild("Running")

			local function HookupPlayerToSkateParamExclusion(player)
				if not self._Janitor then
					return
				end

				self._Janitor:Add(player.CharacterAdded:Connect(function(character)
					raycastParams:AddToFilter(character)
				end))

				if player.Character then
					raycastParams:AddToFilter(player.Character)
				end
			end

			self._Janitor:Add(Players.PlayerAdded:Connect(function(player)
				HookupPlayerToSkateParamExclusion(player)
			end))
			local v22 = nil

			for _, v23 in Players:GetPlayers() do
				HookupPlayerToSkateParamExclusion(v23)
			end

			self.skatableSurfaceParams = raycastParams
			self.isSkating = true
			local v23 = self._Janitor:Add(Instance.new("AlignOrientation"), nil, "Orient")
			v23.Mode = Enum.OrientationAlignmentMode.OneAttachment
			v23.Attachment0 = rootAttachment
			v23.Responsiveness = 200
			v23.MaxTorque = 5000
			v23.MaxAngularVelocity = 3000
			v23.RigidityEnabled = true
			v23.CFrame = humanoidRootPart.CFrame
			v23.Parent = self.hrp
			local v24 = self._Janitor:Add(Instance.new("LinearVelocity"), nil, "Velocity")
			v24.ForceLimitsEnabled = false
			v24.Attachment0 = rootAttachment
			v24.VectorVelocity = FlattenVector(humanoidRootPart.AssemblyLinearVelocity)
			v24.Parent = self.hrp
			local sprintDust = instance:FindFirstChild("LowerTorso") and instance.LowerTorso:FindFirstChild("SprintDust")
			local skateGlideLoop = humanoidRootPart:WaitForChild("SkateGlideLoop")
			skateGlideLoop.Volume = 0
			Debris:AddItem(humanoidRootPart:FindFirstChild("ServerSkateGlideLoop"), 0)
			local skateHockeyStop = humanoidRootPart:WaitForChild("SkateHockeyStop")
			local networkPing = Players.LocalPlayer:GetNetworkPing()
			local leftSkateVFX = instance:WaitForChild("LeftSkateVFX", networkPing * 2 + 1)
			local rightSkateVFX = instance:WaitForChild("RightSkateVFX", networkPing * 2 + 1)
			local trail

			if leftSkateVFX then
				trail = leftSkateVFX:FindFirstChild("FL1") and leftSkateVFX.FL1:FindFirstChild("Trail")
			else
				trail = nil
			end

			local trail2

			if rightSkateVFX then
				trail2 = rightSkateVFX:FindFirstChild("FL1") and rightSkateVFX.FL1:FindFirstChild("Trail")
			else
				trail2 = nil
			end

			local v25 = leftSkateVFX and rightSkateVFX and trail and trail2
			context.DoIfDebuggingEnabled(function()
				leftSkateVFX.Transparency = 0.5
				rightSkateVFX.Transparency = 0.5
				humanoidRootPart.Transparency = 0.75

				for _, v26 in {
					"FRICTION",
					"AIR_DRAG",
					"JUMP_HEIGHT",
					"BASE_ACCELERATION",
					"BASE_TURN_SPEED",
					"SKATE_SPEED_GOAL",
					"SKATE_SPEED_PER_PUSH",
					"ROLL_ADDITION_PER_PUSH",
					"ORIENTATION_ALIGNMENT_SPEED",
					"STRAFE_ANGULAR_ACCELERATION_MULTIPLIER",
					"ANGULAR_MOMENTUM_CHARACTER_ROLL_SCALE",
					"MAXIMUM_CHARACTER_ROLL_ANGLE",
					"STRAFE_THRESHOLD",
					"HOCKEY_STOP_THRESHOLD",
					"HOCKEY_STOP_DECELERATION_MULTIPLIER",
					"TERMINAL_VELOCITY"
				} do
					local v27 = v26

					local function UpdateConstant()
						local attribute = instance:GetAttribute(v27)

						if attribute ~= nil then
							if v27 == "FRICTION" then
								phi = attribute
							elseif v27 == "AIR_DRAG" then
								v3 = attribute
							elseif v27 == "JUMP_HEIGHT" then
								v4 = attribute
							elseif v27 == "BASE_ACCELERATION" then
								v5 = attribute
							elseif v27 == "BASE_TURN_SPEED" then
								v6 = attribute
							elseif v27 == "SKATE_SPEED_GOAL" then
								v7 = attribute
							elseif v27 == "SKATE_SPEED_PER_PUSH" then
								v8 = attribute
							elseif v27 == "ROLL_ADDITION_PER_PUSH" then
								v9 = attribute
							elseif v27 == "ORIENTATION_ALIGNMENT_SPEED" then
								v10 = attribute
							elseif v27 == "STRAFE_ANGULAR_ACCELERATION_MULTIPLIER" then
								quarterCircle = attribute
							elseif v27 == "ANGULAR_MOMENTUM_CHARACTER_ROLL_SCALE" then
								v11 = attribute
							elseif v27 == "MAXIMUM_CHARACTER_ROLL_ANGLE" then
								v12 = attribute
							elseif v27 == "STRAFE_THRESHOLD" then
								v13 = attribute
							elseif v27 == "HOCKEY_STOP_THRESHOLD" then
								v14 = attribute
							elseif v27 == "HOCKEY_STOP_DECELERATION_MULTIPLIER" then
								v15 = attribute
							elseif v27 == "TERMINAL_VELOCITY" then
								v18 = attribute
							end

							instance:SetAttribute(v27, nil)
						end
					end

					local UpdateConstant2 = UpdateConstant
					instance:GetAttributeChangedSignal(v26):Connect(function()
						UpdateConstant2()
					end)
					UpdateConstant()
				end
			end)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function MultiplyByVerticalCharacterScale(p: number)
				return p * humanoid:GetAppliedDescription().HeightScale
			end

			-- equivalent calls inferred from this helper; original call sites unknown
			local function MultiplyByHorizontalCharacterScale(p: number)
				return p * humanoid:GetAppliedDescription().WidthScale
			end

			local v26 = OscillatingSpring.new(0, 1.5, 0.2)
			local v27 = humanoidRootPart.Size.Y / 2 + humanoid.HipHeight + 0.27
			local v28 = {
				DistanceToGroundAdjustments = {
					[self.animations.Run] = MultiplyByVerticalCharacterScale(0),
					[self.animations.StrafeL] = MultiplyByVerticalCharacterScale(0),
					[self.animations.StrafeR] = MultiplyByVerticalCharacterScale(0)
				},
				TrailVFXRelativeOffsets = {
					[self.animations.StrafeL] = {
						CFrame.new(MultiplyByHorizontalCharacterScale(0), 0, 0),
						CFrame.identity
					},
					[self.animations.StrafeR] = {
						CFrame.identity,
						CFrame.new(MultiplyByHorizontalCharacterScale(0), 0, 0)
					}
				}
			}

			-- equivalent calls inferred from this helper; original call sites unknown
			local function GetAdjustedDistanceToGround()
				if v28.DistanceToGroundAdjustments[v22] then
					return v27 - v28.DistanceToGroundAdjustments[v22]
				end

				return v27
			end

			humanoid.PlatformStand = true
			humanoid.AutoRotate = false
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, false)
			local count2 = 0

			local function TransitionToAnimation(object2, duration: number, p: number, value: number?, value2: number?)
				if v22 == object2 then
					if v22.Speed ~= value2 then
						v22:AdjustSpeed(value2 or 1)
					end
				else
					if v22 then
						local v31 = v22
						v31:AdjustWeight(0, duration)
						task.delay(duration, function()
							if v31.IsPlaying and v31.WeightCurrent <= NumberUtil.basicallyZero and v22 ~= v31 then
								v31:Stop(0)
							end
						end)
					end

					count2 += 1
					v22 = object2

					if object2.IsPlaying then
						object2:AdjustWeight(value or 1, p)
					else
						object2:Play(p, value or 1, value2 or 1)
					end
				end
			end

			local v31 = createVector(0, 0, 0)
			local v32 = false
			local v33 = false
			local enabled = false
			local flag = false
			local v34 = false
			local v35 = v7
			local now2 = 0
			local v36 = false
			local now3 = nil
			local v37 = nil
			local lastTime = nil
			local vectorVelocity3 = nil
			local vectorVelocity = nil
			local lookVector = nil

			local function AddSkatePushForwardVelocity(p: number)
				if v22 == self.animations.Run and not v32 then
					v26:Snap(0)
					v26:Impulse(v9 * p)
					local v39 = (FlattenVector(humanoidRootPart.CFrame.LookVector.Unit)).Unit * v8
					local magnitude = v24.VectorVelocity.Magnitude

					if v35 < magnitude then
						v39 = v39.Unit * math.clamp(
							v39.Magnitude,
							0,
							(math.max(0.01, v35 - v24.VectorVelocity.Magnitude))
						)
					end

					if v31.Magnitude > 0 then
						v24.VectorVelocity += v39

						if skateGlideLoop.Playing and skateGlideLoop.Volume > 0 then
							skateGlideLoop.Volume = math.clamp(skateGlideLoop.Volume + 0.22499999999999998, 0, 1.875)
							skateGlideLoop.PlaybackSpeed = math.clamp(skateGlideLoop.PlaybackSpeed + 0.05, 1, 1.5)
						end
					end
				end
			end

			local function DownwardRaycastFromHRPPlane(vector2: Vector3, value: number?)
				local workspace2 = workspace
				local flattenVector = FlattenVector(vector2) -- equivalent call inferred; original call site unknown
				return workspace2:Raycast(
					flattenVector + (humanoidRootPart.CFrame.Position - FlattenVector(humanoidRootPart.CFrame.Position)),
					-unit * (value or 20),
					raycastParams
				)
			end

			self._Janitor:Add(self.animations.Run:GetMarkerReachedSignal("PushR"):Connect(function()
				AddSkatePushForwardVelocity(-1)
			end))
			self._Janitor:Add(self.animations.Run:GetMarkerReachedSignal("PushL"):Connect(function()
				AddSkatePushForwardVelocity(1)
			end))

			if sprintDust then
				self._Janitor:Add(sprintDust:GetPropertyChangedSignal("Enabled"):Connect(function()
					enabled = sprintDust.Enabled
				end))
			end

			local moves = {}
			local v39 = {}
			local v40 = {}

			for _, move in self.animations.Moves do
				table.insert(moves, move)
				v39[move] = {}

				for _, attributeName in {
					"CoyoteTime",
					"MoveDuration",
					"VelImpulseMult",
					"PostLandingQuickTurnDuration"
				} do
					v39[move][attributeName] = move.Animation:GetAttribute(attributeName)
				end
			end

			for k, move in self.animations.Moves do
				v40[move] = k
			end

			local function TryLeap()
				local DISTANCE_THRESHOLD = 0
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				v32 = true
				local v41 = tick() - now3
				now3 = nil
				RunService.PreAnimation:Wait()
				lastTime = tick()
				local v42

				if vectorVelocity and vectorVelocity.Magnitude > v24.VectorVelocity.Magnitude then
					v42 = vectorVelocity
				else
					v42 = v24.VectorVelocity
				end

				vectorVelocity3 = v42
				lookVector = v23.CFrame.LookVector
				local v43 = math.min(0.15, self.animations.JumpBuffer.Length - self.animations.JumpBuffer.TimePosition)
				local _ = moves[math.random(1, #moves)]
				local backflip

				if flag then
					backflip = self.animations.Moves.Backflip
				else
					repeat
						backflip = moves[math.random(1, #moves)]
					until backflip ~= self.animations.Moves.Backflip
				end

				v37 = backflip
				TransitionToAnimation(backflip, v43, v43, 1, math.random(90, 110) / 100)
				local iceSkateJump = humanoidRootPart:FindFirstChild("IceSkateJump")

				if iceSkateJump then
					iceSkateJump.TimePosition = 0.075
					iceSkateJump.PlaybackSpeed = math.random(90, 110) / 100
					iceSkateJump:Play()
				end

				local vector2 = vectorVelocity or v24.VectorVelocity
				vectorVelocity = nil
				local v44 = v24
				local cFrame = v23.CFrame
				local vectorToObjectSpace = v23.CFrame:VectorToObjectSpace(not (vector2.Magnitude > DISTANCE_THRESHOLD) and createVector(
					0,
					0,
					0
				) or vector2 - vector2:Dot(unit.Unit) * unit.Unit)
				local velImpulseMult = v39[backflip].VelImpulseMult
				local vectorToWorldSpace = cFrame:VectorToWorldSpace(vectorToObjectSpace * (not (velImpulseMult.Magnitude > DISTANCE_THRESHOLD) and createVector(
					0,
					0,
					0
				) or velImpulseMult - velImpulseMult:Dot(unit.Unit) * unit.Unit))
				local unit3 = unit.Unit
				local v45 = unit.Unit * (v27 * 2 * v4)
				local velImpulseMult2 = v39[backflip].VelImpulseMult
				local velImpulseMult3 = v39[backflip].VelImpulseMult
				v44.VectorVelocity = vectorToWorldSpace + unit3 * ((v45 * (velImpulseMult2 - (not (velImpulseMult3.Magnitude > DISTANCE_THRESHOLD) and createVector(
					0,
					0,
					0
				) or velImpulseMult3 - velImpulseMult3:Dot(unit.Unit) * unit.Unit)).Magnitude).Magnitude + math.clamp(
					v41 / 2 + 1,
					1,
					1.5
				) * 7.5)
			end

			ContextActionService:BindActionAtPriority("IceSkating::Jump", function(_: string, p, _)
				if p == Enum.UserInputState.Begin then
					v36 = true
				elseif p == Enum.UserInputState.End then
					v36 = false
				end

				if p == Enum.UserInputState.Begin and (not v32 or v21) then
					now3 = tick()
					vectorVelocity = v24.VectorVelocity
				elseif p == Enum.UserInputState.End and now3 then
					TryLeap()
				end

				return Enum.ContextActionResult.Sink
			end, false, 2001, Enum.PlayerActions.CharacterJump)
			local jumpRequestConnection = nil
			jumpRequestConnection = UserInputService.JumpRequest:Connect(function()
				if (v32 or v33) and not v21 then
					return
				end

				if self.isSkating then
					now3 = tick() - 0.5
					vectorVelocity = v24.VectorVelocity
					TryLeap()
				elseif jumpRequestConnection then
					jumpRequestConnection:Disconnect()
				end
			end)
			self._Janitor:Add(jumpRequestConnection)
			self._Janitor:Add(function()
				if not self.isSkating then
					return
				end

				self.isSkating = false

				if humanoid then
					humanoid.AutoRotate = true
					humanoid.PlatformStand = false
					humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
					humanoid:SetStateEnabled(Enum.HumanoidStateType.Running, true)
				end

				ContextActionService:UnbindAction("IceSkating::Jump")
				local StopAllAnims

				StopAllAnims = function(items)
					for _, item in items do
						if typeof(item) == "table" then
							StopAllAnims(item)
						else
							item:Stop(0)
						end
					end
				end

				if self.animations then
					StopAllAnims(self.animations)
				end

				if humanoidRootPart then
					humanoidRootPart.Transparency = 1
				end

				if self._Janitor then
					self._Janitor:Cleanup()
				end

				Debris:AddItem(v23, 0)
				Debris:AddItem(v24, 0)
				Remotes.fireServer("ClientStoppedSkating")
			end)

			while true do
				local v41 = RunService.PreRender:Wait()

				if not self.isSkating then
					break
				end

				local surfaceCast = self:GetSurfaceCast()

				if instance:GetAttribute("PreventSkate") then
					Remotes.fireServer("ClientStoppedSkating")
					break
				end

				if v20 ~= 0 then
					local value = TweenService:GetValue(
						math.clamp((tick() - now - 0.5) / 5, 0, 1),
						Enum.EasingStyle.Exponential,
						Enum.EasingDirection.In
					)

					if value < 1 then
						local v42 = tick() - now
						local visualizeVector = context.VisualizeVector
						local v43 = unit * (not (v42 - 4.5 < 0.5) and 0.5 or not (v42 > 0.5 and v42 < 1) and 1 or NumberUtil.phi)
						local v44

						if v42 - 4.5 < 0.5 then
							local v45 = unit
							local v46

							if v42 < 0.5 then
								v46 = NumberUtil.phi
							else
								v46 = v42 < 1 and 1 or 0.5
							end

							v44 = v45 * v46
						else
							v44 = unit * 3.141592653589793
						end

						local v46

						if v42 - 4.5 < 0.5 then
							if v42 < 0.5 then
								v46 = v42 * 2
							elseif v42 < 1 then
								v46 = (v42 - 0.5) * 2
							else
								v46 = math.clamp(v42 - 4.5, 0, 0.5) * 2
							end
						else
							v46 = math.clamp(v42 - 5, 0, 0.5) * 2
						end

						local lerped = v43:Lerp(
							v44,
							TweenService:GetValue(v46, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
						)
						local color

						if v42 - 4.5 < 0.5 then
							color = Color3.new(1, 0.5, 1)
						else
							color = Color3.new(1, 0.25, 1)
						end

						local v47

						if v42 - 4.5 < 0.5 then
							v47 = Color3.new(1, 0.25, 1)
						else
							v47 = Color3.new(0.25, 0.125, 0.25)
						end

						local lerped2 = color:Lerp(v47, value)
						local v48 = v41 * 1.25
						local v49 = humanoidRootPart.Position + (createVector(0, 0, 0)):Lerp(
							unit.Unit * math.lerp(
								5 + math.sin(v42 / 2 * NumberUtil.phi * 3.141592653589793) / 3.141592653589793 * (v42 / 5 + 1),
								5 + NumberUtil.phi,
								value
							),
							TweenService:GetValue(
								math.clamp(v42 * NumberUtil.phi * NumberUtil.goldenFraction, 0, 1),
								Enum.EasingStyle.Back,
								Enum.EasingDirection.Out
							)
						)
						local v50 = math.lerp(0.1, 0, value)
						local arrowHeadsAngle

						if v42 < NumberUtil.goldenFraction + 0.25 then
							arrowHeadsAngle = math.lerp(
								0.017453292519943295,
								2.356194490192345,
								TweenService:GetValue(
									math.clamp(v42 - 0.25, 0, 1) * NumberUtil.phi,
									Enum.EasingStyle.Sine,
									Enum.EasingDirection.InOut
								)
							)
						elseif value < NumberUtil.goldenFraction then
							arrowHeadsAngle = math.lerp(
								2.356194490192345,
								1.8325957145940461,
								TweenService:GetValue(
									math.clamp(value / NumberUtil.goldenFraction, 0, 1),
									Enum.EasingStyle.Sine,
									Enum.EasingDirection.In
								)
							)
						else
							arrowHeadsAngle = math.lerp(
								1.8325957145940461,
								3.12413936106985,
								TweenService:GetValue(
									math.clamp(
										(value - NumberUtil.goldenFraction) / (1 - NumberUtil.goldenFraction),
										0,
										1
									),
									Enum.EasingStyle.Exponential,
									Enum.EasingDirection.Out
								)
							)
						end

						local arrowHeadsLength

						if v42 < NumberUtil.goldenFraction + 0.25 then
							arrowHeadsLength = math.lerp(
								0,
								0.6283185307179586,
								TweenService:GetValue(
									math.clamp(v42 - 0.25, 0, 1) * NumberUtil.phi,
									Enum.EasingStyle.Sine,
									Enum.EasingDirection.InOut
								)
							)
						else
							arrowHeadsLength = math.lerp(
								0.6283185307179586,
								(unit + Vector3.new(
									math.cos((tick() - now) * NumberUtil.phi) * 0.225,
									0,
									math.sin((tick() - now) * NumberUtil.phi) * 0.225
								)):Lerp(
									createVector(0, 0, 0),
									value
								).Magnitude,
								value
							)
						end

						local specificRoll

						if v42 < 4 then
							specificRoll = v42 * NumberUtil.quarterCircle
						elseif v42 > 4 and v42 < 4.5 then
							specificRoll = math.lerp(
								4 * NumberUtil.quarterCircle,
								4.375 * NumberUtil.quarterCircle,
								TweenService:GetValue(
									math.clamp((v42 - 4) / 0.5, 0, 1),
									Enum.EasingStyle.Sine,
									Enum.EasingDirection.Out
								)
							)
						elseif v42 > 4.5 and v42 < 5 then
							specificRoll = math.lerp(
								4.375 * NumberUtil.quarterCircle,
								3 * NumberUtil.quarterCircle,
								TweenService:GetValue(
									math.clamp((v42 - 4.5) / 0.5, 0, 1),
									Enum.EasingStyle.Sine,
									Enum.EasingDirection.InOut
								)
							)
						else
							specificRoll = 3 * NumberUtil.quarterCircle + (v42 - 5) * NumberUtil.fullCircle * 2
						end

						local properties = {
							Material = Enum.Material.SmoothPlastic,
							Transparency = 0,
							skipHighlight = true
						}
						local transparency

						if v42 > 5 then
							transparency = math.clamp((v42 - 5) * 2, 0, 1)
						else
							transparency = 1 - math.clamp(v42 * NumberUtil.phi, 0, 1)
						end

						properties.Transparency = transparency
						local v59 = v42
						visualizeVector(lerped, lerped2, v48, v49, v50, "up", {
							arrowHeads = true,
							arrowHeadsAngle = arrowHeadsAngle,
							arrowHeadsLength = arrowHeadsLength,
							specificRoll = specificRoll,
							properties = properties,
							hooks = {
								queryDescendants = {
									{
										queryString = "#BottomCap,#TopCap",
										forEach = function(p)
											local color2 = Color3.new(
												p.Color.R * 0.85,
												p.Color.G * 0.85,
												p.Color.B * 0.85
											)

											if not (v42 < 0.5) then
												if v42 > 4.5 then
													color2 = p.Color:Lerp(
														color2,
														TweenService:GetValue(
															math.clamp((v42 - 4.5) / 0.5, 0, 1),
															Enum.EasingStyle.Sine,
															Enum.EasingDirection.Out
														)
													)
												else
													color2 = color2:Lerp(
														p.Color,
														TweenService:GetValue(
															math.clamp((v42 - 0.5) / NumberUtil.goldenFraction, 0, 1),
															Enum.EasingStyle.Sine,
															Enum.EasingDirection.InOut
														)
													)
												end
											end

											p.Color = color2
										end
									},
									{
										queryString = "#ArrowLimb>#BottomCap,#ArrowLimb>#BottomCap#TopCap",
										forEach = function(p)
											local size = p.Size
											local v60

											if v59 < 0.5 then
												v60 = math.lerp(
													1,
													1.5,
													TweenService:GetValue(
														math.clamp(v59 / 0.5, 0, 1),
														Enum.EasingStyle.Sine,
														Enum.EasingDirection.Out
													)
												)
											else
												v60 = not (v59 < 1) and 1 or math.lerp(
													1.5,
													1,
													TweenService:GetValue(
														math.clamp((v59 - 0.5) / 0.5, 0, 1),
														Enum.EasingStyle.Back,
														Enum.EasingDirection.Out
													)
												)
											end

											p.Size = size * v60
										end
									}
								}
							}
						})
					end

					if v32 and v36 then
						local closestPointOnSurface = self.hrp:GetClosestPointOnSurface(self.hrp.Position + v24.VectorVelocity.Unit * v27)
						context.VisualizeVector(
							v24.VectorVelocity.Unit * (v24.VectorVelocity.Magnitude * v41 + 0.5),
							Color3.new(0.75, 0.75, 0),
							0.1,
							closestPointOnSurface,
							0.05,
							"VelCastForwardForGeckoStick",
							{
								arrowHeads = 5,
								arrowHeadsAngle = math.rad(90 - math.abs((math.sin(tick() * NumberUtil.fullCircle))) * 45),
								bottomArrowHeads = 3,
								bottomArrowHeadsAngle = 1.5707963267948966,
								specificRoll = tick() * NumberUtil.fullCircle
							}
						)
						local surfaceCast2 = self:GetSurfaceCast(
							-v24.VectorVelocity.Unit,
							v24.VectorVelocity.Magnitude * v41 + 0.5,
							closestPointOnSurface
						)

						if surfaceCast2 then
							context.VisualizeVector(
								surfaceCast2.Position - closestPointOnSurface,
								Color3.new(0.2, 0.75, 0),
								NumberUtil.phi,
								closestPointOnSurface,
								0.05,
								"StuckOntoSurface",
								{
									arrowHeads = 5,
									arrowHeadsAngle = 0.7853981633974483,
									bottomArrowHeads = 3,
									bottomArrowHeadsAngle = 1.5707963267948966,
									specificRoll = tick() * NumberUtil.fullCircle
								}
							)
							self:ChangeUp(
								surfaceCast2.Normal,
								not (surfaceCast2.Normal:Dot(unit) > 0) and 0 or NumberUtil.phi / 10
							)

							if v20 == 2 then
								v17 = -surfaceCast2.Normal * v17.Magnitude
							end

							surfaceCast = surfaceCast2
						end
					end

					if surfaceCast and surfaceCast.Normal then
						context.VisualizeVector(
							surfaceCast.Normal,
							Color3.new(1, 0.5, 1),
							0.1,
							surfaceCast.Position,
							0.05,
							"currentSurfaceCast.Normal from Hit-Pos",
							{
								arrowHeads = true,
								arrowHeadsAngle = 1.8325957145940461,
								bottomArrowHeads = true,
								bottomArrowHeadsAngle = 1.5707963267948966,
								specificRoll = tick() * NumberUtil.quarterCircle * 0.5
							}
						)

						if not v32 or surfaceCast.Distance < v27 * 4 then
							self:ChangeUp(surfaceCast.Normal, NumberUtil.phi / 10)

							if v20 == 2 then
								v17 = -surfaceCast.Normal * v17.Magnitude
							end
						end
					else
						surfaceCast = self:GetSurfaceCast(nil, 2000)

						if not surfaceCast and v19 then
							self:ChangeUp(createVector(0, 1, 0), 5)
							v17 = createVector(0, -1, 0) * v17.Magnitude
						end
					end

					if v20 == 2 then
						if not v32 and surfaceCast and surfaceCast.Normal then
							local v42 = "Y"
							local v43 = math.abs(surfaceCast.Normal.X) > math.abs(surfaceCast.Normal[v42]) and "X" or v42
							local v44 = math.abs(surfaceCast.Normal.Z) > math.abs(surfaceCast.Normal[v43]) and "Z" or v43
							v17 = Vector3.new(v44 == "X" and 1 or 0, v44 == "Y" and 1 or 0, v44 == "Z" and 1 or 0) * math.sign(surfaceCast.Normal[v44]) * -v17.Magnitude
						end

						local visualizeVector = context.VisualizeVector
						local v42 = v17
						local color = Color3.new(0.5, 0, 0.5)
						local v44

						if surfaceCast then
							v44 = surfaceCast.Position
						else
							v44 = self.hrp.Position
						end

						visualizeVector(v42, color, 0.1, v44, 0.1, "gravity_vis_spidermode=2", true)
					end
				end

				if not (surfaceCast and surfaceCast.Instance:HasTag("SkatableSurface") or v32 and surfaceCast or v19) then
					break
				end

				if not v32 then
					self:ChangeUp(surfaceCast.Normal, 0)
				end

				if humanoid.SeatPart or humanoid.Sit or humanoid.Health <= 0 or humanoidRootPart:IsGrounded() or humanoid:GetState() == Enum.HumanoidStateType.Seated or instance:FindFirstChild("NoMotorVehicleModel") or instance:FindFirstChild(name .. "Horse") then
					break
				end

				v33 = v32
				local v42

				if humanoid:GetState() == Enum.HumanoidStateType.Jumping then
					v42 = true
				else
					v42 = not surfaceCast

					if not v42 then
						local distance = surfaceCast.Distance
						v42 = v27 + 0.5 < distance
					end
				end

				v32 = v42

				if humanoid.MoveDirection.Magnitude > 0 then
					v31 = (FlattenVector(CastVectorToLocalFlatPlanarSurface(
						humanoid.MoveDirection,
						workspace.CurrentCamera.CFrame.UpVector
					).LookVector)).Unit * humanoid.MoveDirection.Magnitude
				else
					v31 = createVector(0, 0, 0)
				end

				if not v32 then
					lastTime = nil

					if v33 then
						now2 = tick()
						local v43 = v24.VectorVelocity:Dot(-unit) / v17.Magnitude

						if v43 >= 0 then
							local skateJumpLand = humanoidRootPart:FindFirstChild("SkateJumpLand")

							if skateJumpLand then
								skateJumpLand.PlaybackSpeed = math.random(85, 100) / 100
								skateJumpLand.Volume = math.clamp(v43, 0.5, 2.5)
								skateJumpLand:Play()
							end
						end
					end

					if vectorVelocity3 then
						v24.VectorVelocity = vectorVelocity3
						vectorVelocity3 = nil
					end

					if lookVector then
						v23.CFrame = CFrame.lookAlong(v23.CFrame.Position, lookVector, v23.CFrame.UpVector)
						lookVector = nil
					end
				end

				if v24.VectorVelocity.Magnitude == 0 then
					local vectorVelocity4

					if v31.Magnitude > 0 then
						vectorVelocity4 = v31.Unit * 0.01
					else
						vectorVelocity4 = humanoidRootPart.CFrame.LookVector.Unit * 0.01
					end

					v24.VectorVelocity = vectorVelocity4
				end

				local v43 = enabled and 1.5 or 1

				if enabled then
					v35 = v7 * 1.5
				else
					v35 = v7
				end

				local v44 = v31 * v35 * v5 * v41
				local v45

				if v31.Magnitude > 0.1 then
					v45 = v31.Unit:Angle(FlattenVector(v24.VectorVelocity.Unit), unit)
				else
					v45 = 0
				end

				local v46 = v37 and v39[v37] and tick() - now2 < v39[v37].PostLandingQuickTurnDuration
				local v47 = v13 - (not v46 and 0 or math.lerp(
					0.4363323129985824,
					0,
					TweenService:GetValue(
						(tick() - now2) / v39[v37].PostLandingQuickTurnDuration,
						Enum.EasingStyle.Circular,
						Enum.EasingDirection.In
					)
				))
				local v48 = v14 - (not v46 and 0 or v47 - v13)
				local v49 = v47 <= math.abs(v45)

				if v48 <= math.abs(v45) then
					flag = true
				else
					flag = false
				end

				local vectorVelocity2 = v24.VectorVelocity
				local lookVector2 = v23.CFrame.LookVector
				local cframe = CFrame.new(createVector(0, 0, 0), FlattenVector(lookVector2))

				if v32 then
					local v50 = v17 * v41
					local v51 = FlattenVector(v24.VectorVelocity) * (v3 * v41)

					if v24.VectorVelocity:Dot(v17.Unit) < v18 then
						local dot = v24.VectorVelocity:Dot(unit)

						if v22 and v22.IsPlaying and v40[v22] and v22.TimePosition < v39[v22].CoyoteTime and dot > 0 then
							v50 = -unit * math.min(dot, v17.Magnitude) * v41
							v51 *= 3.141592653589793
						end

						v24.VectorVelocity += v50
					end

					v24.VectorVelocity -= v51
				else
					if v31.Magnitude > 0 then
						local angle = v24.VectorVelocity.Unit:Angle(v31.Unit, unit)
						local lerped = v24.VectorVelocity.Unit:Lerp(
							(CFrame.lookAlong(createVector(0, 0, 0), v24.VectorVelocity.Unit, unit) * CFrame.Angles(
								0,
								angle,
								0
							)).LookVector,
							v41 * v6 * v43
						)
						v24.VectorVelocity = lerped * (v24.VectorVelocity.Magnitude + math.sign((v44.Unit:Dot(lerped.Unit))) * v44.Magnitude)
					end

					humanoid.PlatformStand = true

					if running and running.Playing then
						running.Playing = false
					end

					if now3 then
						v24.VectorVelocity *= 1 - v2 * v41
					else
						v24.VectorVelocity *= 1 - phi * v41
					end

					v24.VectorVelocity = FlattenVector(v24.VectorVelocity)
					local magnitude = (humanoidRootPart.Position - surfaceCast.Position).Magnitude
					local adjustedDistanceToGround = GetAdjustedDistanceToGround() -- equivalent call inferred; original call site unknown

					if math.abs(magnitude - adjustedDistanceToGround) > 0.025 then
						local adjustedDistanceToGround2 = GetAdjustedDistanceToGround() -- equivalent call inferred; original call site unknown
						local v52 = magnitude - adjustedDistanceToGround2
						local cFrame = humanoidRootPart.CFrame
						local unit3 = (surfaceCast.Position - humanoidRootPart.Position).Unit

						if not (math.abs(v52) - v41 * 2 < 0.025) then
							v52 = math.min(v41 * 2, (math.abs(v52))) * math.sign(v52)
						end

						humanoidRootPart.CFrame = cFrame + unit3 * v52
					end
				end

				local v50, vector2, v51, v52, v53, v54, v55, position, position2, workspace2, v56, position3, position4, raycastResult, alignPosition, workspace3, v57, position5, position6, raycastResult2, alignPosition2, position7, position8, v58, v59, v60, v61, v62, v63, visualizeVector, v64, color

				if v32 then
					if lastTime and tick() - lastTime > 4 and v20 == 0 then
						break
					end
				elseif v24.VectorVelocity.Magnitude > 1 then
					local cframe2 = CFrame.lookAlong(self.hrp.Position, v24.VectorVelocity, unit)
					local vector3 = FlattenVector(self.hrp.CFrame.LookVector) -- equivalent call inferred; original call site unknown
					local angle = vector3:Angle(FlattenVector(cframe2.LookVector), unit)
					local visualizeAngle = context.VisualizeAngle
					local cframe3 = CFrame.lookAlong(surfaceCast.Position, self.hrp.CFrame.LookVector, unit)
					local v65 = -angle
					local color2 = Color3.new(0, 0.5, 1)
					visualizeAngle(cframe3, createVector(1, 0, 0), 1.5, v65, color2, 0.1, nil, "dRot", {
						protractorMode = { true, false }
					})
					local visualizeAngle2 = context.VisualizeAngle
					local v66 = CFrame.lookAlong(surfaceCast.Position, self.hrp.CFrame.LookVector, unit) * CFrame.Angles(
						NumberUtil.quarterCircle,
						0,
						0
					)
					local v68 = humanoidRootPart.Position.Y - surfaceCast.Position.Y + humanoidRootPart.Size.Y / 2
					local v69 = math.clamp(-angle * v11, -v12, v12)
					local v70 = math.abs(angle)
					local v71

					if v12 < v70 then
						v71 = Color3.new(1, 0.5, 0)
					else
						v71 = Color3.new(0, 0.5, 1)
					end

					visualizeAngle2(v66, createVector(1, 0, 0), v68, v69, v71, 0.1, nil, "dRot2", {
						hideThetaLabel = true,
						protractorMode = { true, math.abs(angle) <= v12 }
					})
					local position9 = v26:GetPosition()
					local visualizeAngle3 = context.VisualizeAngle
					local v72 = CFrame.lookAlong(surfaceCast.Position, self.hrp.CFrame.LookVector, unit) * CFrame.Angles(
						NumberUtil.quarterCircle,
						0,
						0
					)
					local v74 = humanoidRootPart.Position.Y - surfaceCast.Position.Y + humanoidRootPart.Size.Y / 2 + 0.5
					local v75 = math.abs(angle) + math.abs(position9)
					local v76

					if v12 < v75 then
						v76 = Color3.new(1, 0, 0)
					else
						v76 = Color3.new(0.5, 0.5, 0.5)
					end

					visualizeAngle3(v72, createVector(1, 0, 0), v74, position9, v76, 0.1, nil, "dRot2_extraPushRoll")
					local v77 = cframe2 * CFrame.Angles(0, 0, (math.clamp(angle * v11 - position9, -v12, v12)))
					v23.CFrame = v23.CFrame:Lerp(v77, v41 * v10)
				else
					v23.CFrame = v23.CFrame:Lerp(
						CFrame.lookAlong(self.hrp.Position, self.hrp.CFrame.LookVector, unit),
						v41 * (v10 / 2)
					)
				end

				if v32 then
					skateGlideLoop.Volume = math.lerp(skateGlideLoop.Volume, 0, v41 * 10)
					v34 = false
				else
					if v33 and v22 and v40[v22] then
						v22:Stop(0)
					end

					if now3 then
						if tick() - now3 >= self.animations.JumpBuffer.Length then
							now3 = nil
						else
							TransitionToAnimation(self.animations.JumpBuffer, 0.25, 0.25, 1, 1)
						end
					elseif v24.VectorVelocity.Magnitude > 1 or v31.Magnitude > 0.1 then
						if v31.Magnitude > 0.1 then
							if flag then
								if not v34 then
									skateHockeyStop:Play()
									skateHockeyStop.Volume = math.clamp(
										humanoidRootPart.AssemblyLinearVelocity.Magnitude / v7,
										0,
										1.5
									)
									skateHockeyStop.PlaybackSpeed = math.clamp(
										humanoidRootPart.AssemblyLinearVelocity.Magnitude / (v7 / 2),
										0.75,
										1.25
									)
								end

								skateHockeyStop.Volume = math.lerp(
									skateHockeyStop.Volume,
									humanoidRootPart.AssemblyLinearVelocity.Magnitude / v7,
									v41 * 2
								)
								skateHockeyStop.PlaybackSpeed = math.lerp(skateHockeyStop.PlaybackSpeed, 1, v41 * 2)
								TransitionToAnimation(self.animations.HockeyStop, 0.125, 0.125, nil, 1)
								v50 = v24.VectorVelocity - vectorVelocity2
								vector2 = v24.VectorVelocity + v50.Unit * (v50.Magnitude * v15)

								if v27 < vector2.Magnitude and vector2:Dot(v24.VectorVelocity) > 0 then
									v24.VectorVelocity = vector2
								else
									v24.VectorVelocity = -v24.VectorVelocity.Unit * 30
									v23.CFrame *= CFrame.Angles(0, 3.141592653589793, 0)
								end

								v34 = true
							elseif v49 then
								v51 = quarterCircle

								if v46 then
									v51 = quarterCircle * math.lerp(
										2,
										1,
										TweenService:GetValue(
											(tick() - now2) / v39[v37].PostLandingQuickTurnDuration,
											Enum.EasingStyle.Circular,
											Enum.EasingDirection.In
										)
									)
								end

								v52 = v45 > 0 and "R" or "L"
								TransitionToAnimation(self.animations[`Strafe{v52}`], 0.5, 0.5, nil, 1)

								if vectorVelocity2.Magnitude > NumberUtil.basicallyZero and v24.VectorVelocity.Magnitude > NumberUtil.basicallyZero then
									v24.VectorVelocity = v24.VectorVelocity.Unit * vectorVelocity2.Magnitude
									v53 = v24.VectorVelocity.Unit:Angle(vectorVelocity2.Unit, unit)
									v24.VectorVelocity = v24.VectorVelocity.Unit:Lerp(
										(CFrame.lookAlong(createVector(0, 0, 0), v24.VectorVelocity.Unit, unit) * CFrame.Angles(
											0,
											-v53,
											0
										)).LookVector,
										v51
									) * v24.VectorVelocity.Magnitude
								end
							else
								TransitionToAnimation(self.animations.Run, 0.25, 0.25, nil, (enabled and 0.2 or 0) + 1)
							end
						else
							TransitionToAnimation(self.animations.Idle, 0.75, 0.75, nil, 1)
						end
					else
						TransitionToAnimation(self.animations.Idle, 0.25, 0.25, nil, 1)
					end

					skateGlideLoop.Playing = true
					skateGlideLoop.Volume = math.lerp(
						skateGlideLoop.Volume,
						math.clamp(humanoidRootPart.AssemblyLinearVelocity.Magnitude / v7 * 1.5, 0, 1.5),
						v41 * 2
					)
					skateGlideLoop.PlaybackSpeed = math.lerp(skateGlideLoop.PlaybackSpeed, 1, v41 * 2)
				end

				if v25 and not v32 then
					v54 = leftFoot.Size.Z / 2
					v55 = rightFoot.Size.Z / 2
					position = (leftFoot.CFrame * CFrame.new(0, -(0.27 + leftFoot.Size.Y / 2), -v54)).Position
					position2 = (rightFoot.CFrame * CFrame.new(0, -(0.27 + rightFoot.Size.Y / 2), -v55)).Position
					workspace2 = workspace
					v56 = FlattenVector(position)
					position3 = humanoidRootPart.CFrame.Position
					position4 = humanoidRootPart.CFrame.Position
					raycastResult = workspace2:Raycast(
						v56 + (position3 - FlattenVector(position4)),
						-unit * 20,
						raycastParams
					)

					if raycastResult then
						leftSkateVFX.AlignPosition.Position = raycastResult.Position + cframe.LookVector * v54 * 0.75

						if v28.TrailVFXRelativeOffsets[v22] then
							alignPosition = leftSkateVFX.AlignPosition
							alignPosition.Position += (cframe * v28.TrailVFXRelativeOffsets[v22][1]).Position
						end

						leftSkateVFX.AlignOrientation.CFrame = CFrame.lookAlong(
							createVector(0, 0, 0),
							raycastResult.Normal
						) * CFrame.Angles(-NumberUtil.quarterCircle, 0, 0)
					end

					workspace3 = workspace
					v57 = FlattenVector(position2)
					position5 = humanoidRootPart.CFrame.Position
					position6 = humanoidRootPart.CFrame.Position
					raycastResult2 = workspace3:Raycast(
						v57 + (position5 - FlattenVector(position6)),
						-unit * 20,
						raycastParams
					)

					if raycastResult2 then
						rightSkateVFX.AlignPosition.Position = raycastResult2.Position + cframe.LookVector * v55 * 0.75

						if v28.TrailVFXRelativeOffsets[v22] then
							alignPosition2 = rightSkateVFX.AlignPosition
							alignPosition2.Position += (cframe * v28.TrailVFXRelativeOffsets[v22][2]).Position
						end

						rightSkateVFX.AlignOrientation.CFrame = CFrame.lookAlong(
							createVector(0, 0, 0),
							raycastResult2.Normal
						) * CFrame.Angles(-NumberUtil.quarterCircle, 0, 0)
					end

					if surfaceCast then
						if v22 == self.animations.StrafeL then
							trail.Enabled = true
							trail2.Enabled = false
						elseif v22 == self.animations.StrafeR then
							trail2.Enabled = true
							trail.Enabled = false
						else
							position7 = surfaceCast.Position
							position8 = surfaceCast.Position
							v58 = position7 - FlattenVector(position8)
							v59 = position - FlattenVector(position)
							v60 = position2 - FlattenVector(position2)
							v61 = (v59 - v58):Dot(unit)
							v62 = (v60 - v58):Dot(unit)
							trail.Enabled = v61 < 0.135
							trail2.Enabled = v62 < 0.135
						end
					end
				end

				context.Retain(
					function(p, lastTime2: number?, value: number, value2: number, value3: number, value4: number)
						if p ~= v22 or not lastTime2 then
							lastTime2 = tick()
							p = v22
						end

						local v67 = value or 0
						local v68 = value2 or 0
						local v69 = value3 or 0
						local v70 = value4 or 0
						local v71 = math.clamp((tick() - lastTime2) / 2, 0, 1)
						local v72 = math.clamp(tick() - lastTime2, 0, 1)
						local v73 = math.lerp(
							0,
							0.25,
							TweenService:GetValue(v71, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out)
						)
						local v74

						if v22 == self.animations.Run then
							v74 = v73
						elseif v22 == self.animations.StrafeR or v22 == self.animations.StrafeL then
							v74 = math.lerp(v67, v73 / 2, v72)
						else
							v74 = math.lerp(v67, 0, v72)
						end

						local v75

						if v22 == self.animations.StrafeR then
							v75 = v73
						elseif v22 == self.animations.Run or v22 == self.animations.HockeyStop then
							v75 = math.lerp(v68, v73 / 2, v72)
						else
							v75 = math.lerp(v68, 0, tick() - lastTime2)
						end

						local v76

						if v22 == self.animations.StrafeL then
							v76 = v73
						elseif v22 == self.animations.Run or v22 == self.animations.HockeyStop then
							v76 = math.lerp(v69, v73 / 2, v72)
						else
							v76 = math.lerp(v69, 0, v72)
						end

						if v22 ~= self.animations.HockeyStop then
							if v22 == self.animations.StrafeR or v22 == self.animations.StrafeL then
								v73 = math.lerp(v70, v73 / 2, v72)
							else
								v73 = math.lerp(v70, 0, v72)
							end
						end

						local visualizeAngle = context.VisualizeAngle
						local v77 = CFrame.lookAlong(
							self.hrp.Position - unit * (v27 - v74),
							v24.VectorVelocity.Unit,
							unit
						) * CFrame.Angles(0, v47, 0)
						local v80 = v47 * 2
						local color2

						if v22 == self.animations.Run then
							color2 = Color3.new(0, 1, 0)
						else
							color2 = Color3.new(0.019608, 0.694118, 0.615686)
						end

						local material

						if v22 == self.animations.Run then
							material = Enum.Material.Neon
						else
							material = Enum.Material.SmoothPlastic
						end

						visualizeAngle(
							v77,
							createVector(1, 0, 0),
							5,
							v80,
							color2,
							0.1,
							nil,
							"visualizedNormalSkateForwardsRegion",
							{
								hideThetaLabel = true,
								protractorMode = true,
								properties = {
									Material = material
								}
							}
						)
						local visualizeAngle2 = context.VisualizeAngle
						local v87 = CFrame.lookAlong(
							self.hrp.Position - unit * (v27 - v75),
							v24.VectorVelocity.Unit,
							unit
						) * CFrame.Angles(0, -v47, 0)
						local v90 = 3.141592653589793 - v47 - (3.141592653589793 - v48)
						local color3

						if v22 == self.animations.StrafeR then
							color3 = Color3.new(1, 0.5, 0)
						else
							color3 = Color3.new(0.639216, 0.427451, 0.054902)
						end

						local material2

						if v22 == self.animations.StrafeR then
							material2 = Enum.Material.Neon
						else
							material2 = Enum.Material.SmoothPlastic
						end

						visualizeAngle2(
							v87,
							createVector(1, 0, 0),
							5,
							v90,
							color3,
							0.1,
							nil,
							"visualizedStrafeInputRegionR",
							{
								hideThetaLabel = true,
								protractorMode = true,
								properties = {
									Material = material2
								}
							}
						)
						local visualizeAngle3 = context.VisualizeAngle
						local v97 = CFrame.lookAlong(
							self.hrp.Position - unit * (v27 - v76),
							v24.VectorVelocity.Unit,
							unit
						) * CFrame.Angles(0, v47, 0)
						local v100 = 3.141592653589793 - v47 - (3.141592653589793 - v48)
						local color4

						if v22 == self.animations.StrafeL then
							color4 = Color3.new(1, 0.5, 0)
						else
							color4 = Color3.new(0.639216, 0.427451, 0.054902)
						end

						local material3

						if v22 == self.animations.StrafeL then
							material3 = Enum.Material.Neon
						else
							material3 = Enum.Material.SmoothPlastic
						end

						visualizeAngle3(
							v97,
							createVector(-1, -0, -0),
							5,
							v100,
							color4,
							0.1,
							nil,
							"visualizedStrafeInputRegionL",
							{
								hideThetaLabel = true,
								protractorMode = true,
								properties = {
									Material = material3
								}
							}
						)
						local visualizeAngle4 = context.VisualizeAngle
						local v107 = CFrame.lookAlong(
							self.hrp.Position - unit * (v27 - v73),
							v24.VectorVelocity.Unit,
							unit
						) * CFrame.Angles(0, v48, 0)
						local v110 = (3.141592653589793 - v48) * 2
						local color5

						if v22 == self.animations.HockeyStop then
							color5 = Color3.new(1, 0, 0)
						else
							color5 = Color3.new(0.52549, 0.125, 0.125)
						end

						local material4

						if v22 == self.animations.HockeyStop then
							material4 = Enum.Material.Neon
						else
							material4 = Enum.Material.SmoothPlastic
						end

						visualizeAngle4(
							v107,
							createVector(-1, -0, -0),
							5,
							v110,
							color5,
							0.1,
							nil,
							"visualizedHockeyStopInputRegion",
							{
								hideThetaLabel = true,
								protractorMode = true,
								properties = {
									Material = material4
								}
							}
						)
						return p, lastTime2, v74, v75, v76, v73
					end,
					1
				)
				context.VisualizeVector(
					v24.VectorVelocity / 2,
					Color3.new(1, 1, 0),
					0.1,
					self.hrp.Position,
					0.1,
					"velocity",
					true
				)
				v63 = v24.VectorVelocity.Magnitude - vectorVelocity2.Magnitude

				if math.abs(v63) > NumberUtil.basicallyZero then
					visualizeVector = context.VisualizeVector
					v64 = v24.VectorVelocity.Unit * (v63 / v41 + v24.VectorVelocity.Magnitude * (math.abs(v63) <= NumberUtil.basicallyZero / v41 and 0 or 1))

					if math.sign(v63) >= 0 then
						color = Color3.new(0, 1, 0)
					else
						color = Color3.new(1, 0, 0)
					end

					visualizeVector(v64, color, 0.1, self.hrp.Position, 0.1, "acceleration", true)
				end

				context.VisualizeVector(
					v31 * 5,
					Color3.new(0, 1, 1),
					0.1,
					self.hrp.Position - unit * v27,
					nil,
					"input",
					true
				)
				context.DoIfDebuggingEnabled(function()
					if trail.Enabled then
						leftSkateVFX.Material = Enum.Material.Neon
						leftSkateVFX.Color = Color3.new(0, 1, 0)
					else
						leftSkateVFX.Material = Enum.Material.SmoothPlastic
						leftSkateVFX.Color = Color3.new(1, 1, 1)
					end

					if trail2.Enabled then
						rightSkateVFX.Material = Enum.Material.Neon
						rightSkateVFX.Color = Color3.new(0, 1, 0)
					else
						rightSkateVFX.Material = Enum.Material.SmoothPlastic
						rightSkateVFX.Color = Color3.new(1, 1, 1)
					end
				end)
				v26:Update(v41)
			end

			if self._Janitor then
				task.defer(function()
					self._Janitor:Cleanup()
				end)
			end
		else
			warn("IceSkating missing RootAttachment; unable to begin skating")
			Remotes.fireServer("ClientStoppedSkating")
		end
	else
		warn("IceSkating missing critical character instances; unable to begin skating")
		Remotes.fireServer("ClientStoppedSkating")
	end
end

function v:Stop()
	if self.isLocalPlayer then
		ContextActionService:UnbindAction("IceSkating::Jump")
		Remotes.fireServer("ClientStoppedSkating")
		self.isSkating = false
	end

	self._Janitor:Destroy()
end

return v