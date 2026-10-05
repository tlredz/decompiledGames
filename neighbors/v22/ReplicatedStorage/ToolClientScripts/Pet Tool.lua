local createVector = vector.create
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
require(ReplicatedStorage.Modules.Tool)
local v = {
	FollowOffset = CFrame.new(4, 0, 2),
	FollowSmoothing = 8,
	RotationSmoothing = 6,
	TeleportThreshold = 40,
	WalkThreshold = 1.5,
	WalkSpeed = 9,
	StillThreshold = 7.5,
	SleepThreshold = 15,
	StepSoundInterval = 0.45,
	PathRecomputeInterval = 0.35,
	PathRecomputeDistance = 4,
	WaypointReachedDistance = 2.5
}
local v2 = {
	Idle = {
		onEnter = function(object)
			object:StopAllAnimations()
			object:PlayAnimation("Idle")
		end
	},
	Sit = {
		onEnter = function(object)
			object:StopAllAnimations()
			object:PlayAnimation("IdleToSit")
			object:ReplicateSound("Sitting", "Play")
			task.delay(object.AnimationTracks.IdleToSit.Length - 0.2, function()
				if object.CurrentState == "Sit" then
					object:TransitionTo("Sitting")
				end
			end)
		end,
		onExit = function(object)
			object:StopAllAnimations()
		end
	},
	Sitting = {
		onEnter = function(object)
			object:StopAllAnimations()
			object:PlayAnimation("Sit")
		end,
		onExit = function(object)
			object:StopAllAnimations()
		end
	},
	Pet = {
		onEnter = function(object)
			task.delay(1.25, function()
				if object.CurrentState ~= "Pet" then
					return
				end

				object:StopAllAnimations()
				object:ReplicateSound("Petting", "Play")
				object:PlayAnimation("Petting", 1)
			end)
		end,
		onExit = function(object)
			object:ReplicateSound("Petting", "Stop")
		end
	},
	Sleep = {
		onEnter = function(object)
			task.delay(1, function()
				if object.CurrentState == "Sleep" then
					object:ReplicateSound("Sleeping", "Play")
				end
			end)
			object:PlayAnimation("Sleep", 1)
		end,
		onExit = function(object)
			object:ReplicateSound("Sleeping", "Stop")
		end
	},
	WakingUp = {
		onEnter = function(object)
			object:StopAllAnimations()
			object:ReplicateSound("WakingUp", "Play")
			object:PlayAnimation("WakingUp")
			object.StillTimer = 0
			task.delay(object.AnimationTracks.WakingUp.Length - 0.2, function()
				if object.CurrentState == "WakingUp" then
					object:TransitionTo("Idle")
				end
			end)
		end,
		onExit = function(object)
			object:StopAllAnimations()
		end
	}
}

local function calculateSmooth(p: number, p2: number)
	return 1 - 0.5 ^ (p * p2)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function flattenPosition(vector2: Vector3)
	return (Vector3.new(vector2.X, 0, vector2.Z))
end

local PetTool = {}

function PetTool:GetGroundPosition(vector2: Vector3, p2: number)
	local raycastResult = workspace:Raycast(
		Vector3.new(vector2.X, vector2.Y + 3, vector2.Z),
		createVector(0, -100, 0),
		self.RaycastParameters
	)
	local v3

	if raycastResult then
		v3 = raycastResult.Position.Y
	else
		v3 = vector2.Y
	end

	return (Vector3.new(vector2.X, v3 + p2, vector2.Z))
end

function PetTool:ClearPath()
	if self.PathBlockedConnection then
		self.PathBlockedConnection:Disconnect()
		self.PathBlockedConnection = nil
	end

	self.CurrentPath = nil
	self.CurrentWaypoints = {}
	self.CurrentWaypointIndex = 1
	self.PathNeedsRefresh = true
end

function PetTool:ConstructPathfindingModifiers()
	self.Modifiers = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function createPathfindingModifier(parent)
		local pathfindingModifier = Instance.new("PathfindingModifier")
		pathfindingModifier.PassThrough = true
		pathfindingModifier.Parent = parent
		table.insert(self.Modifiers, pathfindingModifier)
	end

	for _, v3 in CollectionService:GetTagged("PhysicsDoor") do
		for _, v4 in v3:QueryDescendants("BasePart") do
			createPathfindingModifier(v4) -- equivalent call inferred; original call site unknown
		end
	end
end

function PetTool:ComputePath(vector2: Vector3, lastPathTarget: Vector3)
	local primaryPart = self.Model and self.Model.PrimaryPart

	if not primaryPart then
		return false
	end

	local path = PathfindingService:CreatePath({
		AgentRadius = math.max(primaryPart.Size.X, primaryPart.Size.Z) / 2,
		AgentHeight = 0,
		AgentCanJump = false
	})
	local groundPosition = self:GetGroundPosition(vector2, primaryPart.Size.Y / 2)
	local groundPosition2 = self:GetGroundPosition(lastPathTarget, primaryPart.Size.Y / 2)
	local v3 = pcall(function()
		path:ComputeAsync(groundPosition, groundPosition2)
	end)
	self.LastPathCompute = os.clock()
	self.LastPathTarget = lastPathTarget

	if not v3 or path.Status ~= Enum.PathStatus.Success then
		self:ClearPath()
		return false
	end

	local waypoints = path:GetWaypoints()
	self:ClearPath()
	self.CurrentPath = path
	self.CurrentWaypoints = waypoints
	self.CurrentWaypointIndex = 1
	self.PathNeedsRefresh = false

	while self.CurrentWaypointIndex <= #self.CurrentWaypoints do
		local position = self.CurrentWaypoints[self.CurrentWaypointIndex].Position

		if (Vector3.new(position.X, 0, position.Z) - Vector3.new(groundPosition.X, 0, groundPosition.Z)).Magnitude > v.WaypointReachedDistance then
			break
		else
			self.CurrentWaypointIndex += 1
		end
	end

	self.PathBlockedConnection = path.Blocked:Connect(function(p: number)
		if self.CurrentWaypointIndex <= p then
			self.PathNeedsRefresh = true
		end
	end)
	return self.CurrentWaypointIndex <= #self.CurrentWaypoints
end

function PetTool:GetNavigationTarget(vector2: Vector3, vector3: Vector3)
	local v3 = flattenPosition(vector3) -- equivalent call inferred; original call site unknown
	local v4 = os.clock() - self.LastPathCompute
	local v5 = false

	if self.LastPathTarget == nil then
		v5 = true
	elseif v.PathRecomputeInterval <= v4 then
		local lastPathTarget = self.LastPathTarget
		local magnitude = (Vector3.new(lastPathTarget.X, 0, lastPathTarget.Z) - v3).Magnitude
		v5 = (self.PathNeedsRefresh or self.CurrentWaypointIndex > #self.CurrentWaypoints or v.PathRecomputeDistance <= magnitude) and true or false
	end

	if v5 and not self:ComputePath(vector2, vector3) then
		return vector3
	end

	while self.CurrentWaypointIndex <= #self.CurrentWaypoints do
		local currentWaypoint = self.CurrentWaypoints[self.CurrentWaypointIndex]
		local position = currentWaypoint.Position

		if (Vector3.new(position.X, 0, position.Z) - Vector3.new(vector2.X, 0, vector2.Z)).Magnitude > v.WaypointReachedDistance then
			return currentWaypoint.Position
		else
			self.CurrentWaypointIndex += 1
		end
	end

	return vector3
end

function PetTool:StopAllAnimations()
	for _, v3 in self.AnimationTracks or {} do
		if v3.IsPlaying then
			v3:Stop(0.5)
		end
	end

	self:FireEvent("StopAnimations")
end

function PetTool:ReplicateSound(p: string, p2: string)
	self:FireEvent("Replicate", p, p2)
end

function PetTool:PlayAnimation(p: string, p2: number)
	self.AnimationTracks[p]:Play(p2)
	self:FireEvent("PlayAnimation", p, p2)
end

function PetTool:StopAnimation(p: string, p2: number)
	self.AnimationTracks[p]:Stop(p2)
	self:FireEvent("StopAnimation", p, p2)
end

function PetTool:TransitionTo(currentState: string)
	if self.CurrentState == currentState then
		return
	end

	local v3 = v2[self.CurrentState]

	if v3 and v3.onExit then
		v3.onExit(self)
	end

	self.CurrentState = currentState
	self:FireEvent("Replicate", currentState, "State")

	if self.Model then
		self.Model:SetAttribute("State", currentState)
	end

	local v4 = v2[currentState]

	if v4 and v4.onEnter then
		v4.onEnter(self)
	end
end

function PetTool:UpdateStateMachine(p2)
	local v3 = v2[self.CurrentState]

	if not v3 then
		return
	end

	if v3.onUpdate then
		v3.onUpdate(self, p2)
	end
end

function PetTool:ResetStateMachine()
	self:StopAllAnimations()
	self.CurrentState = ""
	self:TransitionTo("Idle")
end

function PetTool:Initialize()
	self.AnimationTracks = {}
	self.CurrentState = ""
	self.SmoothedLookDirection = createVector(0, 0, 1)
	self.SmoothedPosition = createVector(0, 0, 0)
	self.CurrentAlignPosition = createVector(0, 0, 0)
	self.TargetAlignPosition = createVector(0, 0, 0)
	self.StillTimer = 0
	self.StepSoundTimer = 0
	self.HeartbeatConnection = nil
	self.EventConnection = nil
	self.CurrentPath = nil
	self.CurrentWaypoints = {}
	self.CurrentWaypointIndex = 1
	self.LastPathCompute = 0
	self.LastPathTarget = nil
	self.PathBlockedConnection = nil
	self.PathNeedsRefresh = false
	self.RaycastParameters = RaycastParams.new()
	self.RaycastParameters.FilterType = Enum.RaycastFilterType.Include
	self.RaycastParameters.FilterDescendantsInstances = {
		workspace:WaitForChild("Places"),
		workspace:WaitForChild("Prefabs")
	}
	self:ConstructPathfindingModifiers()
	self.Tool:GetAttributeChangedSignal("Petting"):Connect(function()
		if self.Tool:GetAttribute("Petting") then
			local petting = self.AnimationTracks.Petting
			self:TransitionTo("Pet")
			task.wait(6.75)
			petting:Stop(1)
			self:TransitionTo("Idle")
		end
	end)
	self.Tool:GetAttributeChangedSignal("Toggled"):Connect(function()
		if self.Tool:GetAttribute("Toggled") then
			self.Model = workspace.Terrain:WaitForChild((`{self.Player.UserId}'s Pet`))

			if not next(self.AnimationTracks) then
				local animator = self.Model:WaitForChild("AnimationController"):WaitForChild("Animator")

				for _, animation in ReplicatedStorage.Assets.Animations.Pets[self.Model:GetAttribute("PetName")]:GetChildren() do
					self.AnimationTracks[animation.Name] = animator:LoadAnimation(animation)
				end
			end

			local v3 = self.HumanoidRootPart.CFrame * v.FollowOffset
			self.SmoothedPosition = v3.Position
			self.CurrentAlignPosition = v3.Position
			self.TargetAlignPosition = v3.Position
			self.SmoothedLookDirection = self.HumanoidRootPart.CFrame.LookVector
			self.StillTimer = 0
			self:ClearPath()

			if self.EventConnection then
				self.EventConnection:Disconnect()
				self.EventConnection = nil
			end

			self.EventConnection = self.Model.States.Event:Connect(function(p: string?)
				if p then
					self:TransitionTo(p)
					return
				end

				if self.CurrentState == "Sleep" or self.CurrentState == "WakingUp" then
					return self:TransitionTo("WakingUp")
				end

				return self:TransitionTo("Idle")
			end)
			self:ResetStateMachine()
			self.HeartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
				local primaryPart = self.Model and self.Model.PrimaryPart

				if not primaryPart then
					return
				end

				if self.CurrentState == "Pet" then
					self.StillTimer = 0
				end

				if self.CurrentState ~= "WakingUp" and self.CurrentState ~= "Pet" and self.CurrentState ~= "Sleep" and self.CurrentState ~= "Sit" and self.CurrentState ~= "Sitting" then
					if self.Player:DistanceFromCharacter(primaryPart.Position) >= 10 then
						local position = (self.HumanoidRootPart.CFrame * v.FollowOffset).Position
						local v4 = flattenPosition(position) -- equivalent call inferred; original call site unknown
						local magnitude = (self.SmoothedPosition - position).Magnitude
						local v5 = 1 - 0.5 ^ (dt * v.FollowSmoothing)

						if v.TeleportThreshold < magnitude then
							self.SmoothedPosition = position
							self.TargetAlignPosition = position
							self:ClearPath()
						else
							self.SmoothedPosition = self.SmoothedPosition:Lerp(v4, v5)
							local v6 = flattenPosition(self:GetNavigationTarget(primaryPart.Position, position)) -- equivalent call inferred; original call site unknown
							local v7 = flattenPosition(self.TargetAlignPosition) -- equivalent call inferred; original call site unknown
							local v8 = v6 - v7
							local magnitude2 = v8.Magnitude

							if magnitude2 > 0 then
								local v9 = v.WalkSpeed * dt

								if magnitude2 <= v9 then
									self.TargetAlignPosition = Vector3.new(v6.X, self.TargetAlignPosition.Y, v6.Z)
								else
									local v10 = v7 + v8.Unit * v9
									self.TargetAlignPosition = Vector3.new(v10.X, self.TargetAlignPosition.Y, v10.Z)
								end
							end
						end
					end

					local raycastResult = workspace:Raycast(
						Vector3.new(
							self.TargetAlignPosition.X,
							self.HumanoidRootPart.Position.Y + 3,
							self.TargetAlignPosition.Z
						),
						createVector(0, -500, 0),
						self.RaycastParameters
					)
					local v4

					if raycastResult then
						v4 = raycastResult.Position.Y
					else
						v4 = self.HumanoidRootPart.Position.Y
					end

					self.TargetAlignPosition = Vector3.new(
						self.TargetAlignPosition.X,
						v4 + primaryPart.Size.Y / 2,
						self.TargetAlignPosition.Z
					)
					local v5 = flattenPosition(primaryPart.AssemblyLinearVelocity) -- equivalent call inferred; original call site unknown
					local v6 = 1 - 0.5 ^ (dt * v.FollowSmoothing)
					self.CurrentAlignPosition = self.CurrentAlignPosition:Lerp(self.TargetAlignPosition, v6)
					self.Model.AlignPosition.Position = self.CurrentAlignPosition

					if v5.Magnitude > 0.1 then
						local v7 = 1 - 0.5 ^ (dt * v.RotationSmoothing)
						self.SmoothedLookDirection = self.SmoothedLookDirection:Lerp(v5.Unit, v7)
					end

					self.Model.AlignOrientation.CFrame = CFrame.lookAt(
						primaryPart.Position,
						primaryPart.Position + self.SmoothedLookDirection
					)
				end

				local magnitude = (primaryPart.AssemblyLinearVelocity * createVector(1, 0, 1)).Magnitude

				if magnitude <= 0.1 then
					local walk = self.AnimationTracks.Walk

					if walk and walk.IsPlaying then
						self:StopAnimation("Walk", 0.1)
					end

					self.StillTimer += dt
				elseif magnitude >= 0.5 then
					local walk = self.AnimationTracks.Walk

					if walk and not walk.IsPlaying then
						self:PlayAnimation("Walk")
					end

					self.AnimationTracks.Walk:AdjustSpeed((math.clamp(magnitude / 7.5, 0.75, 3)))
					self.StepSoundTimer += dt

					if self.StepSoundTimer >= v.StepSoundInterval then
						self:ReplicateSound("Step", "Play")
						self.StepSoundTimer = 0
					end

					self.StillTimer = 0
				end

				self:UpdateStateMachine({
					stillTimer = self.StillTimer,
					deltaTime = dt,
					AnimationTracks = self.AnimationTracks
				})
			end)
		else
			local v3 = v2[self.CurrentState]

			if v3 and v3.onExit then
				v3.onExit(self)
			end

			self.CurrentState = ""
			self.SmoothedPosition = createVector(0, 0, 0)
			self:ClearPath()

			for _, animationTrack in self.AnimationTracks do
				animationTrack:Stop()
			end

			if self.EventConnection then
				self.EventConnection:Disconnect()
				self.EventConnection = nil
			end

			if self.HeartbeatConnection then
				self.HeartbeatConnection:Disconnect()
				self.HeartbeatConnection = nil
			end
		end
	end)
end

function PetTool.Equipped(_)
	localPlayer.PlayerGui.RenamePet.Enabled = true
end

function PetTool.Unequipped(_)
	localPlayer.PlayerGui.RenamePet.Enabled = false
end

function PetTool:Destroyed()
	self:ClearPath()

	for _, animationTrack in self.AnimationTracks do
		animationTrack:Stop()
		animationTrack:Destroy()
	end

	for _, modifier in self.Modifiers do
		modifier:Destroy()
	end

	if self.EventConnection then
		self.EventConnection:Disconnect()
		self.EventConnection = nil
	end

	if self.HeartbeatConnection then
		self.HeartbeatConnection:Disconnect()
		self.HeartbeatConnection = nil
	end
end

return PetTool