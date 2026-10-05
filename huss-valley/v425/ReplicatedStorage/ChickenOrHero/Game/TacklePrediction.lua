local createVector = vector.create
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local gameAction = chickenOrHero.Game.GameAction
local GameConfig = require(chickenOrHero.Game.GameConfig)
local tackle = GameConfig.Tackle
local TacklePredictionConfig = require(chickenOrHero.Game.TacklePredictionConfig)
local TackleProfile = require(chickenOrHero.Game.TackleProfile)
local TackleMotion = require(chickenOrHero.Game.TackleMotion)
local TackleCollision = require(chickenOrHero.Game:WaitForChild("TackleCollision"))
local MovementProfiles = require(chickenOrHero.Movement.MovementProfiles)
local TackleAnimation = require(chickenOrHero.Animation.TackleAnimation)
local ControlGate = require(chickenOrHero.Movement.ControlGate)
local CombatPrediction = require(chickenOrHero.Game:WaitForChild("CombatPrediction"))
local HitReplayMath = require(chickenOrHero.Game.HitReplayMath)
CombatPrediction.start()
local TacklePrediction = {}
local v = nil
local readyAt = 0

local function finish(p)
	local v2 = v

	if not v2 then
		return
	end

	v = nil
	CombatPrediction.cancel(v2.id)

	for _, v3 in { v2.orientation, v2.velocity, v2.attachment } do
		if v3 then
			v3:Destroy()
		end
	end

	if v2.character.Parent then
		v2.character:SetAttribute("TackleActive", false)
		v2.character:SetAttribute("TacklePredictionId", nil)
	end

	if not p then
		TackleAnimation.stop(v2.character)
	end

	if v2.h.Parent then
		v2.h.AutoRotate = v2.autoRotate
	end
end

function TacklePrediction.remaining()
	return (math.max(
		0,
		readyAt - workspace:GetServerTimeNow(),
		(localPlayer:GetAttribute("TackleReadyAt") or 0) - workspace:GetServerTimeNow()
	))
end

local function startMotion(state)
	local character = state.character
	local h = state.h
	local root = state.root
	local cfg = state.cfg
	local direction = state.direction
	local started = state.started
	local id = state.id
	state.attachment = Instance.new("Attachment")
	state.attachment.Name = "LocalTackleMotion"
	state.attachment.Parent = root
	state.velocity = Instance.new("LinearVelocity")
	state.velocity.Name = "LocalTackleVelocity"
	state.velocity.Attachment0 = state.attachment
	state.velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	state.velocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
	state.velocity.PrimaryTangentAxis = createVector(1, 0, 0)
	state.velocity.SecondaryTangentAxis = createVector(0, 0, 1)
	state.collision = TackleCollision.new(character)
	state.velocity.PlaneVelocity = Vector2.new(direction.X, direction.Z) * TackleCollision.limit(
		state.collision,
		root,
		direction,
		TackleMotion.speed(cfg, 0, 0.016666666666666666),
		0.016666666666666666
	)
	state.velocity.ForceLimitsEnabled = true
	state.velocity.ForceLimitMode = Enum.ForceLimitMode.Magnitude
	state.velocity.MaxForce = math.max(1, root.AssemblyMass) * 4000
	state.velocity.Parent = root
	state.orientation = Instance.new("AlignOrientation")
	state.orientation.Name = "LocalTackleFacing"
	state.orientation.Attachment0 = state.attachment
	state.orientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	state.orientation.CFrame = CFrame.lookAt(createVector(0, 0, 0), direction)
	state.orientation.MaxTorque = 1000000
	state.orientation.MaxAngularVelocity = 25
	state.orientation.Responsiveness = 35
	state.orientation.Parent = root
	character:SetAttribute("TacklePredictionId", id)
	character:SetAttribute("TackleActive", true)
	character:SetAttribute("TackleVariant", cfg.Name)
	character:SetAttribute("TackleStartedAt", started)
	character:SetAttribute("TackleDirection", direction)
	character:SetAttribute("TackleDuration", cfg.Duration)
	character:SetAttribute("TackleRecovery", cfg.Recovery)
	h.AutoRotate = false
	h.WalkSpeed = 0
	h:Move(createVector(0, 0, 0), false)
	TackleAnimation.play(character, cfg.Animation, cfg.Duration + cfg.Recovery)
end

function TacklePrediction.request()
	local character = localPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

	if v or TacklePrediction.remaining() > 0.02 or not humanoidRootPart or not humanoid or humanoid.Health <= 0 or humanoidRootPart.Anchored or humanoid.Sit or humanoid.PlatformStand or humanoid.FloorMaterial == Enum.Material.Air or character:GetAttribute("MovementLocked") or character:GetAttribute("TackleActive") or character:GetAttribute("DaggerEquipped") and character:GetAttribute("DaggerState") ~= "Held" or localPlayer:GetAttribute("GameRole") ~= "Catcher" or localPlayer:GetAttribute("RunState") ~= "Active" or ControlGate.reason(localPlayer) then
		return false
	end

	local v2 = humanoidRootPart.CFrame.LookVector * createVector(1, 0, 1)

	if v2.Magnitude < 0.01 then
		return false
	end

	local unit = v2.Unit
	local magnitude = (humanoidRootPart.AssemblyLinearVelocity * createVector(1, 0, 1)).Magnitude
	local cfg = TackleProfile.select(tackle, magnitude, MovementProfiles.get("Catcher", localPlayer).MaxSpeed)
	local serverTimeNow = workspace:GetServerTimeNow()
	local GUID = game.HttpService:GenerateGUID(false)
	local v4 = {
		character = character,
		h = humanoid,
		root = humanoidRootPart,
		cfg = cfg,
		direction = unit,
		started = serverTimeNow,
		requestedAt = serverTimeNow,
		elapsed = 0,
		id = GUID,
		version = character:GetAttribute("MovementReset"),
		autoRotate = humanoid.AutoRotate,
		confirmed = false
	}
	v = v4
	readyAt = serverTimeNow + cfg.Cooldown
	gameAction:FireServer("Tackle", {
		id = GUID,
		at = serverTimeNow,
		speed = magnitude,
		direction = unit,
		position = humanoidRootPart.Position
	})
	startMotion(v4)
	CombatPrediction.begin({
		id = GUID,
		kind = "Tackle",
		character = character,
		predicted = true,
		startedAt = serverTimeNow,
		starts = serverTimeNow,
		ends = serverTimeNow + cfg.Duration,
		direction = unit,
		box = HitReplayMath.bounds("Tackle", cfg)
	})
	return true
end

function TacklePrediction.isActive(p)
	return v ~= nil and v.character == p
end

gameAction.OnClientEvent:Connect(function(p, p2, p3, data)
	local v2 = v

	if not v2 or v2.id ~= p2 then
		return
	end

	if p == "TackleResult" then
		if p3 then
			v2.confirmed = true

			if type(data) == "table" then
				readyAt = data.readyAt or readyAt

				if type(data.speed) == "number" then
					v2.cfg = TackleProfile.select(
						tackle,
						data.speed,
						MovementProfiles.get("Catcher", localPlayer).MaxSpeed
					)
				end

				v2.started = type(data.startedAt) == "number" and data.startedAt or workspace:GetServerTimeNow()
			else
				v2.started = workspace:GetServerTimeNow()
			end

			CombatPrediction.reconcile(p2, true, {
				startedAt = v2.started,
				starts = v2.started,
				ends = v2.started + v2.cfg.Duration,
				direction = v2.direction,
				box = HitReplayMath.bounds("Tackle", v2.cfg)
			})
		else
			readyAt = type(data) == "table" and data.readyAt or 0
			finish(false)
		end
	elseif p == "TackleEnded" then
		finish(p3 == true)
	end
end)
RunService.PreSimulation:Connect(function(dt)
	local v2 = v

	if not v2 then
		return
	end

	local character = v2.character
	local h = v2.h
	local root = v2.root

	if localPlayer.Character ~= character or not character.Parent or not root.Parent or h.Health <= 0 or root.Anchored or h.Sit or h.PlatformStand or character:GetAttribute("MovementLocked") or character:GetAttribute("MovementReset") ~= v2.version or localPlayer:GetAttribute("GameRole") ~= "Catcher" or localPlayer:GetAttribute("RunState") ~= "Active" then
		finish(false)
		return
	end

	local serverTimeNow = workspace:GetServerTimeNow()

	if v2.confirmed or not (serverTimeNow - v2.requestedAt > TacklePredictionConfig.ConfirmTimeout) then
		if serverTimeNow - v2.started >= v2.cfg.Duration + v2.cfg.Recovery then
			finish(true)
			return
		end

		character:SetAttribute("TackleActive", true)
		local limit = TackleCollision.limit(
			v2.collision,
			root,
			v2.direction,
			TackleMotion.speed(v2.cfg, v2.elapsed, dt),
			dt
		)
		v2.elapsed += dt

		if v2.collision.stopped and not v2.wallStopped then
			v2.wallStopped = true
			TackleAnimation.stop(character)
		end

		v2.velocity.PlaneVelocity = Vector2.new(v2.direction.X, v2.direction.Z) * limit
		h.WalkSpeed = 0
		h:Move(createVector(0, 0, 0), false)
	else
		readyAt = 0
		finish(false)
	end
end)

local function prepare(instance)
	local humanoid = instance:WaitForChild("Humanoid", 10)

	if not humanoid then
		return
	end

	if humanoid:WaitForChild("Animator", 10) and instance.Parent then
		TackleAnimation.prepare(instance)
	end
end

localPlayer.CharacterAdded:Connect(function(character)
	if v then
		finish(false)
	end

	task.spawn(prepare, character)
end)
localPlayer.CharacterRemoving:Connect(function(character)
	if v and v.character == character then
		finish(false)
	end
end)

if localPlayer.Character then
	task.spawn(prepare, localPlayer.Character)
end

return TacklePrediction