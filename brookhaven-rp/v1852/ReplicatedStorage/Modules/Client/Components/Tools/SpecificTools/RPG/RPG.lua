local createVector = vector.create
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Component = require(ReplicatedStorage.Packages.Component)
local Input = require(ReplicatedStorage.Packages.Input)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local Remotes = require(ReplicatedStorage.Packages.Remotes)
local ExclusionConfig = require(ReplicatedStorage.Modules.Shared.DB.Exclusion.ExclusionConfig)
local ExclusionProjectile = require(ReplicatedStorage.Modules.Client.Components.Tools.Projectiles.ExclusionProjectile)
local ExclusionZoneController = require(ReplicatedStorage.Modules.Client.Exclusion.ExclusionZoneController)
local OnlyRunOnPlayerHotbar = require(ReplicatedStorage.Modules.Shared.Components.Tools.Extensions.OnlyRunOnPlayerHotbar)
local RPGConstants = require(ReplicatedStorage.Modules.Shared.Tools.RPGConstants)
local RPGProjectileUtil = require(ReplicatedStorage.Modules.Shared.Tools.RPGProjectileUtil)
local VisualEffectsUtil = require(ReplicatedStorage.Modules.Shared.Utils.VisualEffectsUtil)
local TelemetryController = require(ReplicatedStorage.Modules.Client.Telemetry.TelemetryController)
local v = Component.new({
	Tag = "RPG",
	Extensions = { OnlyRunOnPlayerHotbar }
})
local mouse = Input.Mouse
local localPlayer = Players.LocalPlayer

local function findAnimation(instance, p: string)
	for _, animation in instance:GetChildren() do
		if animation:IsA("Animation") and animation.Name == p then
			return animation
		end
	end

	error((`RPG is missing the {p} animation`))
end

local v2 = {}
local v3 = nil
local v4 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function stopBoostFlight()
	v4 = nil
	local v5 = v3

	if v5 == nil then
		return
	end

	v3 = nil
	v5:Destroy()
end

local function isBoostFlightFinished(object)
	if object.Health <= 0 or object.SeatPart ~= nil then
		return true
	end

	local state = object:GetState()

	if state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.RunningNoPhysics or state == Enum.HumanoidStateType.Seated or state == Enum.HumanoidStateType.Dead or state == Enum.HumanoidStateType.Climbing or state == Enum.HumanoidStateType.GettingUp or state == Enum.HumanoidStateType.Swimming then
		return true
	end

	return object.FloorMaterial ~= Enum.Material.Air
end

local function maintainBoostFlight(humanoid, humanoidRootPart)
	local assemblyLinearVelocity = humanoidRootPart.AssemblyLinearVelocity
	local vector2 = Vector2.new(assemblyLinearVelocity.X, assemblyLinearVelocity.Z)

	if vector2.Magnitude < RPGConstants.BOOST_FLIGHT_MIN_HORIZONTAL_SPEED then
		return
	end

	if v4 ~= nil then
		v4.PlaneVelocity = vector2
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.Name = "RPGBoostFlightAttachment"
	attachment.Parent = humanoidRootPart
	local linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Name = "RPGBoostFlight"
	linearVelocity.Attachment0 = attachment
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
	linearVelocity.PrimaryTangentAxis = createVector(1, 0, 0)
	linearVelocity.SecondaryTangentAxis = createVector(0, 0, 1)
	linearVelocity.PlaneVelocity = vector2
	linearVelocity.ForceLimitsEnabled = false
	linearVelocity.Parent = humanoidRootPart
	local maid = Janitor.new()
	v3 = maid
	v4 = linearVelocity
	maid:Add(attachment)
	maid:Add(linearVelocity)
	local lastTime = os.clock()
	maid:Add(humanoid.Died:Connect(stopBoostFlight))
	maid:Add(RunService.Heartbeat:Connect(function(dt: number)
		local v5 = os.clock() - lastTime

		if v5 < RPGConstants.BOOST_FLIGHT_GRACE then
			return
		end

		if RPGConstants.BOOST_FLIGHT_MAX_DURATION <= v5 or isBoostFlightFinished(humanoid) then
			stopBoostFlight() -- equivalent call inferred; original call site unknown
		else
			local planeVelocity = linearVelocity.PlaneVelocity * math.exp(-RPGConstants.BOOST_FLIGHT_DRAG * dt)

			if not (planeVelocity.Magnitude < RPGConstants.BOOST_FLIGHT_MIN_HORIZONTAL_SPEED) then
				linearVelocity.PlaneVelocity = planeVelocity
				return
			end

			stopBoostFlight() -- equivalent call inferred; original call site unknown
		end
	end))
end

localPlayer.CharacterRemoving:Connect(stopBoostFlight)

-- equivalent calls inferred from this helper; original call sites unknown
local function destroyRocket(p: number)
	local v5 = v2[p]

	if v5 == nil then
		return
	end

	v2[p] = nil
	v5:Destroy()
end

local function spawnExplosion(_explosionTemplate, position: Vector3, normal: Vector3)
	local clone = _explosionTemplate:Clone()
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	clone.CFrame = RPGProjectileUtil.lookAlong(position, normal)
	clone.Parent = workspace
	VisualEffectsUtil.ForParticles(clone, function(p)
		p.Enabled = true
	end)
	local sound = clone:FindFirstChild("Sound")
	sound:Play()
	task.delay(RPGConstants.EXPLOSION_LIFETIME, function()
		VisualEffectsUtil.ForParticles(clone, function(p)
			p.Enabled = false
		end)
	end)
	Debris:AddItem(
		clone,
		RPGConstants.EXPLOSION_LIFETIME + math.max(RPGConstants.EXPLOSION_CLEANUP_DELAY, sound.TimeLength)
	)
end

function v:Construct()
	self._Janitor = Janitor.new()
	self._equipJanitor = Janitor.new()
	self._isOnCooldown = false
	self._mouse = self._Janitor:Add(mouse.new())
	self._raycastParams = RaycastParams.new()
	self._raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	self._raycastParams.RespectCanCollide = true
	self._raycastParams.CollisionGroup = "Default"
end

function v:_SetWarheadVisible(flag: boolean)
	self._warhead.Transparency = flag and 0 or 1
end

function v:_PlayFireEffects()
	self._fireSound:Play()
	self:_SetWarheadVisible(false)
	local thread = task.delay(RPGConstants.FIRE_COOLDOWN, function()
		self:_SetWarheadVisible(true)
	end)
	self._equipJanitor:Add(thread, true, "warheadRestore")
end

function v:_PlayFireAnimation()
	self._fireTrack:Play(0.1, nil, RPGConstants.ANIMATION_SPEED)
	local thread = task.delay(RPGConstants.FIRE_ANIMATION_DURATION, function()
		self._fireTrack:Stop(0.1)
		self._reloadTrack:Play(0.1, nil, RPGConstants.ANIMATION_SPEED)
	end)
	self._equipJanitor:Add(thread, true, "reloadAnimation")
end

function v:_LoadAnimations(instance)
	local animator = instance:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator")
	self._fireTrack = self._equipJanitor:Add(animator:LoadAnimation(findAnimation(self.Instance, "Fire")))
	self._reloadTrack = self._equipJanitor:Add(animator:LoadAnimation(findAnimation(self.Instance, "Reload")))
	self._equipJanitor:Add(self._reloadTrack:GetMarkerReachedSignal("UnhideProj"):Connect(function()
		self:_SetWarheadVisible(true)
	end))
end

function v:_WatchReplicatedReload(instance)
	local animator = instance:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator")
	local animationId = findAnimation(self.Instance, "Reload").AnimationId
	self._equipJanitor:Add(animator.AnimationPlayed:Connect(function(object2)
		if object2.Animation == nil or object2.Animation.AnimationId ~= animationId then
			return
		end

		local connection = object2:GetMarkerReachedSignal("UnhideProj"):Connect(function()
			self:_SetWarheadVisible(true)
		end)
		self._equipJanitor:Add(connection, nil, "observerUnhide")
	end))
end

function v:_GetAimPosition()
	self._raycastParams.FilterDescendantsInstances = { localPlayer.Character, self.Instance }
	local raycastResult = self._mouse:Raycast(self._raycastParams, RPGConstants.ROCKET_MAX_TRAVEL)

	if raycastResult == nil then
		return self._mouse:Project(RPGConstants.ROCKET_MAX_TRAVEL)
	end

	return raycastResult.Position
end

local function closestPointOnHull(vector2: Vector3, vector3: Vector3, p: number, p2: number, p3: number)
	local v5 = vector3.X - p
	local v6 = vector3.X + p
	local v7 = vector3.Y - p2
	local v8 = vector3.Y + p3
	local v9 = vector3.Z - p
	local v10 = vector3.Z + p
	return (Vector3.new(math.clamp(vector2.X, v5, v6), math.clamp(vector2.Y, v7, v8), (math.clamp(vector2.Z, v9, v10))))
end

local function wouldSelfBoost(instance, object, position: Vector3)
	if object.Health <= 0 or object.SeatPart ~= nil then
		return false
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return false
	end

	local v5 = math.max(humanoidRootPart.Size.X, humanoidRootPart.Size.Z) / 2
	local v6 = object.HipHeight + humanoidRootPart.Size.Y / 2
	local v7 = humanoidRootPart.Size.Y / 2 + RPGConstants.BOOST_HULL_HEAD_OFFSET
	local state = object:GetState()
	local v8 = v6 + (object.FloorMaterial ~= Enum.Material.Air and state ~= Enum.HumanoidStateType.Jumping and state ~= Enum.HumanoidStateType.Freefall and 0 or RPGConstants.BOOST_AIRBORNE_HULL_DROP)
	local position2 = humanoidRootPart.Position
	local v9 = position2.X - v5
	local v10 = position2.X + v5
	local v11 = position2.Y - v8
	local v12 = position2.Y + v7
	local v13 = position2.Z - v5
	local v14 = position2.Z + v5
	return (Vector3.new(
		math.clamp(position.X, v9, v10),
		math.clamp(position.Y, v11, v12),
		(math.clamp(position.Z, v13, v14))
	) - position).Magnitude <= RPGConstants.BOOST_BLAST_RADIUS
end

function v:_ApplyBoost(vector2: Vector3)
	local character = localPlayer.Character

	if character == nil then
		return
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid == nil or humanoid.Health <= 0 or humanoid.SeatPart ~= nil then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local v5 = math.max(humanoidRootPart.Size.X, humanoidRootPart.Size.Z) / 2
	local v6 = humanoid.HipHeight + humanoidRootPart.Size.Y / 2
	local v7 = humanoidRootPart.Size.Y / 2 + RPGConstants.BOOST_HULL_HEAD_OFFSET
	local state = humanoid:GetState()
	local v8 = humanoid.FloorMaterial == Enum.Material.Air or state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall
	local v9 = v6 + (not v8 and 0 or RPGConstants.BOOST_AIRBORNE_HULL_DROP)
	local position = humanoidRootPart.Position
	local v10 = position.X - v5
	local v11 = position.X + v5
	local v12 = position.Y - v9
	local v13 = position.Y + v7
	local v14 = position.Z - v5
	local v15 = position.Z + v5
	local magnitude = (Vector3.new(
		math.clamp(vector2.X, v10, v11),
		math.clamp(vector2.Y, v12, v13),
		(math.clamp(vector2.Z, v14, v15))
	) - vector2).Magnitude

	if RPGConstants.BOOST_BLAST_RADIUS < magnitude then
		return
	end

	local v16 = humanoidRootPart.Position - vector2
	local unit = ((not (v16.Magnitude > 0.1) and createVector(0, 1, 0) or v16.Unit) + createVector(0, 1, 0) * RPGConstants.BOOST_UPWARD_BIAS).Unit
	local v17 = RPGConstants.BOOST_BLAST_RADIUS - RPGConstants.BOOST_FULL_STRENGTH_RADIUS
	local v18 = (magnitude <= RPGConstants.BOOST_FULL_STRENGTH_RADIUS or v17 <= 0) and 1 or math.sqrt(1 - (magnitude - RPGConstants.BOOST_FULL_STRENGTH_RADIUS) / v17)
	local v19 = v8 and 1 or RPGConstants.BOOST_GROUNDED_SCALE
	humanoid.Sit = false

	if v8 == false then
		humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	end

	humanoidRootPart.AssemblyLinearVelocity += unit * RPGConstants.BOOST_MAX_SPEED * v18 * v19
	maintainBoostFlight(humanoid, humanoidRootPart)
end

function v:_SpawnRocket(player, cFrame: CFrame, vector2: Vector3)
	local userId = player.UserId
	destroyRocket(userId) -- equivalent call inferred; original call site unknown
	local group = ExclusionConfig.GetGroupById(self.Instance.Name)
	local position = cFrame.Position
	local clone = self._rocketTemplate:Clone()
	clone.Anchored = true
	clone.CanCollide = false
	clone.CanTouch = false
	clone.CanQuery = false
	clone.CFrame = cFrame
	clone.Parent = workspace
	ExclusionProjectile.track(clone, self.Instance.Name, function()
		destroyRocket(userId) -- equivalent call inferred; original call site unknown
	end)
	VisualEffectsUtil.ForParticles(clone, function(p)
		p.Enabled = true
	end)
	clone:FindFirstChild("Sound"):Play()
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { clone, self.Instance, player.Character }
	raycastParams.RespectCanCollide = true
	raycastParams.CollisionGroup = "Default"
	local _explosionTemplate = self._explosionTemplate
	local v5 = player == localPlayer
	local v6 = RPGConstants.ROCKET_SPEED * RPGConstants.ROCKET_CAST_INTERVAL
	local total = 0
	local total2 = 0
	local v7 = nil
	local v8 = nil
	local maid = Janitor.new()
	maid:Add(clone)
	maid:Add(RunService.Heartbeat:Connect(function(dt: number)
		total += dt

		if total >= RPGConstants.MAX_ROCKET_LIFETIME then
			destroyRocket(userId) -- equivalent call inferred; original call site unknown
		else
			while v7 == nil and total2 < total do
				local v9 = position + vector2 * (RPGConstants.ROCKET_SPEED * total2)
				local raycastResult = workspace:Raycast(v9, vector2 * v6, raycastParams)

				if raycastResult == nil then
					total2 += RPGConstants.ROCKET_CAST_INTERVAL
				else
					v8 = raycastResult
					v7 = total2 + (raycastResult.Position - v9).Magnitude / RPGConstants.ROCKET_SPEED
				end
			end

			if v7 == nil or not (v7 <= total) then
				clone.CFrame = cFrame + vector2 * (RPGConstants.ROCKET_SPEED * total)
				return
			end

			destroyRocket(userId) -- equivalent call inferred; original call site unknown
			local v10 = v8

			if v10 ~= nil then
				local magnitude = (v10.Position - position).Magnitude
				local v11

				if group == nil then
					v11 = false
				else
					v11 = ExclusionZoneController.GetRestrictedEntryDistance(group, position, vector2, magnitude) ~= nil
				end

				if v11 == false then
					spawnExplosion(_explosionTemplate, v10.Position, v10.Normal)

					if v5 then
						self:_ApplyBoost(v10.Position)
					end
				end
			end
		end
	end))
	maid:Add(Players.PlayerRemoving:Connect(function(player2)
		if player2 == player then
			destroyRocket(userId) -- equivalent call inferred; original call site unknown
		end
	end))
	v2[userId] = maid
end

function v:_Fire()
	if self._isOnCooldown then
		return
	end

	local character = localPlayer.Character
	local humanoid = character:FindFirstChildOfClass("Humanoid")

	if humanoid.Health <= 0 then
		return
	end

	local v5 = self:_GetAimPosition() - self._projectileBone.Position

	if v5.Magnitude < RPGConstants.MIN_AIM_DISTANCE then
		return
	end

	local unit = v5.Unit
	local launchCFrame = RPGProjectileUtil.getLaunchCFrame(self._projectileBone, self._warhead, unit)

	if not (RPGProjectileUtil.isFiniteCFrame(launchCFrame) and RPGProjectileUtil.isFiniteVector3(unit)) then
		return
	end

	self._isOnCooldown = true
	task.delay(RPGConstants.FIRE_COOLDOWN, function()
		self._isOnCooldown = false
	end)
	self:_PlayFireEffects()
	self:_PlayFireAnimation()
	self:_SpawnRocket(localPlayer, launchCFrame, unit)
	Remotes.fireServerComponent(self.Instance, "Fire", launchCFrame, unit)
	self:_SendFireTelemetry(character, humanoid, launchCFrame.Position, unit)
end

function v:_SendFireTelemetry(instance, p2, vector2: Vector3, vector3: Vector3)
	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	self._raycastParams.FilterDescendantsInstances = { instance, self.Instance }
	local raycastResult = workspace:Raycast(vector2, vector3 * RPGConstants.ROCKET_MAX_TRAVEL, self._raycastParams)
	local ROCKET_MAX_TRAVEL

	if raycastResult == nil then
		ROCKET_MAX_TRAVEL = RPGConstants.ROCKET_MAX_TRAVEL
	else
		ROCKET_MAX_TRAVEL = (raycastResult.Position - vector2).Magnitude
	end

	local group = ExclusionConfig.GetGroupById(self.Instance.Name)
	local v5

	if group == nil then
		v5 = false
	else
		v5 = ExclusionZoneController.GetRestrictedEntryDistance(group, vector2, vector3, ROCKET_MAX_TRAVEL) ~= nil
	end

	local position = humanoidRootPart.Position
	TelemetryController.SendClientInteraction("fireRPG", {
		isSelfBoost = raycastResult ~= nil and not v5 and wouldSelfBoost(instance, p2, raycastResult.Position),
		location = {
			x = position.X,
			y = position.Y,
			z = position.Z
		}
	})
end

function v:Start()
	self._warhead = self.Instance:WaitForChild("Warhead", 5)
	self._projectileBone = self.Instance:WaitForChild("Proj Bone", 5)
	self._fireSound = self.Instance:WaitForChild("Handle", 5):WaitForChild("Fire", 5)
	local RPG = ReplicatedStorage.Assets:FindFirstChild("RPG")
	self._rocketTemplate = RPG:FindFirstChild("Rocket")
	self._explosionTemplate = RPG:FindFirstChild("Explosion")
	local instance = self.Instance
	self._Janitor:Add(Remotes.connectComponentRemote(
		self.Instance,
		"SpawnRocket",
		function(p, cframe: CFrame, vector2: Vector3)
			self:_SpawnRocket(p, cframe, vector2)
			self:_PlayFireEffects()
		end
	))

	local function onEquipped()
		self._equipJanitor:Cleanup()
		self:_SetWarheadVisible(true)
		local parent = instance.Parent
		local playerFromCharacter = Players:GetPlayerFromCharacter(parent)

		if playerFromCharacter == nil then
			return
		end

		if playerFromCharacter ~= localPlayer then
			self:_WatchReplicatedReload(parent)
			return
		end

		self:_LoadAnimations(parent)
		self._equipJanitor:Add(instance.Activated:Connect(function()
			self:_Fire()
		end))
	end

	self._Janitor:Add(instance.Equipped:Connect(onEquipped))
	self._Janitor:Add(instance.Unequipped:Connect(function()
		self:_SetWarheadVisible(true)
		self._equipJanitor:Cleanup()
	end))
	onEquipped()
end

function v:Stop()
	self:_SetWarheadVisible(true)
	self._equipJanitor:Destroy()
	self._Janitor:Destroy()
end

return v