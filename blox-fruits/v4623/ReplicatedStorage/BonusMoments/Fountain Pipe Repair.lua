local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CameraController = require(game.ReplicatedStorage.Controllers.CameraController)
local BonusMomentInteraction = require(game.ReplicatedStorage.Util.BonusMomentInteraction)
local Util = require(game.ReplicatedStorage.Util)
local sound = Util.Sound
local WaitForExpectedDescendants = require(game.ReplicatedStorage.Util.WaitForExpectedDescendants)
require(game.ReplicatedStorage.Controllers.BonusMomentsController.Types)
local BoatLaunchMotion = require(script.BoatLaunchMotion)
local PipeRipple = require(script.PipeRipple)
require(script.Types)
local frozen = table.freeze({
	adjustLaunchCamera = function(cframe: CFrame)
		local v = cframe.Position * 1.15 + createVector(0, -8, -15)
		return CFrame.new(v) * cframe.Rotation
	end
})
local frozen2 = table.freeze({
	NODES_NAME = "FountainPipeNodes",
	PIPE_ID_ATTRIBUTE = "FountainPipeRepairId",
	FOUNTAIN_NAME = "Fountain",
	FOUNTAIN_MIDDLE_NAME = "FountainMiddleBuilding",
	WATER_NAME = "Meshes/Fountain_House12_Cylinder.004",
	RESOLVE_INTERVAL = 0.25,
	DEPENDENCY_TIMEOUT = 5,
	LAUNCH_PREPARE_TIMEOUT = 12,
	LAUNCH_RECOVERY_TIMEOUT = 50,
	BOAT_HANDOFF_SETTLE_DURATION = 0.12,
	EXPECTED_DESCENDANTS_ATTRIBUTE = "ExpectedDescendants",
	BOAT_TEMPLATE = "PirateGrandBrigade",
	BOAT_NAME = "Grand Brigade",
	BOAT_SAIL_COLOR = "White",
	BOAT_START_CFRAME = CFrame.new(5616.191, 369.127, 4477.017) * CFrame.fromOrientation(
		0.31744048435272865,
		-3.0505737330982887,
		-0.05134758659367318
	),
	BOAT_READY_CFRAME = CFrame.new(5635.122, 397.013, 4558.625) * CFrame.fromOrientation(
		0.31744048435272865,
		-3.0505737330982887,
		-0.05134758659367318
	),
	WATER_FULL_CFRAME = CFrame.new(5611.74, 409.972, 4409.1, 0.756225, 0, 0.654312, 0, 1, 0, -0.654312, 0, 0.756225),
	WATER_FULL_SIZE = createVector(330.068, 0.001, 330.068),
	FAKE_SEAT_NAME = "FakeVehicleSeat",
	FAKE_SEAT_SIZE = createVector(2.857143, 1, 2.857143),
	BOAT_TRACKER_ID = "FountainPipeRepairSteeringWheel",
	STEERING_WHEEL_SPINDLE_NAME = "SteeringWheelSpindle",
	STEERING_WHEEL_RIG_NAME = "SteeringWheelRig",
	BOAT_SHAKE_POSITION = 0.8,
	BOAT_SHAKE_ROTATION = 0.04363323129985824,
	BOAT_READY_SHAKE_MULTIPLIER = 2.25,
	LAUNCH_MOTION = BoatLaunchMotion.Config,
	LAUNCH_PHASE_ATTRIBUTE = "FountainPipeRepairLaunchPhase",
	LAUNCH_OWNER_ATTRIBUTE = "FountainPipeRepairOwnerUserId",
	LAUNCH_TOKEN_ATTRIBUTE = "FountainPipeRepairLaunchToken",
	LAUNCH_CAMERA_TIMEOUT = 15,
	LAUNCH_CAMERA_FADE_DURATION = 0.75,
	LAUNCH_RENDER_PRIORITY = Enum.RenderPriority.Camera.Value,
	LAUNCH_ANGLE_ONE_FLIGHT_DELAY = 0.35,
	LAUNCH_ANGLE_TWO_DELAY = 1,
	LAUNCH_ANGLE_TWO_MINIMUM_HOLD = 1.25,
	LAUNCH_FINAL_CAMERA_LEFT_DISTANCE = 57.5,
	LAUNCH_FINAL_CAMERA_FORWARD_DISTANCE = 38,
	LAUNCH_FINAL_CAMERA_UP_DISTANCE = 15,
	LAUNCH_CAMERA_ANGLE_ONE = frozen.adjustLaunchCamera(CFrame.new(
		-92.4108887,
		23.1202698,
		-99.395507812,
		0.0249872301,
		0.197216377,
		-0.980041444,
		-0.00167694909,
		0.980354488,
		0.197236627,
		0.99968636,
		-0.00328491209,
		0.0248270221
	)),
	LAUNCH_CAMERA_ANGLE_TWO = frozen.adjustLaunchCamera(CFrame.new(
		-54.3786621,
		-0.997009277,
		-295.120605,
		-0.966344476,
		0.0560878143,
		-0.2510629,
		0.0661417246,
		0.997304022,
		-0.0317812338,
		0.248603404,
		-0.0473173521,
		-0.96744889
	)),
	LAUNCH_CAMERA_ANGLE_THREE = frozen.adjustLaunchCamera(CFrame.new(
		-31.0339355,
		12.9916992,
		-26.9746094,
		-0.678418458,
		0.179562643,
		-0.712394357,
		0.0464530326,
		0.978215814,
		0.202326685,
		0.733205736,
		0.104169287,
		-0.671980798
	)),
	HIT_SOUND = "Subclass.RepairImpact",
	SPOUT_SOUND = "Dough.DoughWaterLoop",
	OMNIDIRECTIONAL_PIPE_NAME = "Omnidirectional",
	SPOUT_ATTACHMENT_NAME = "FountainPipeWaterSpout",
	SPOUT_EMITTER_NAME = "Water",
	SPOUT_TEXTURE = "rbxassetid://13386858482",
	SPOUT_SOUND_FADE = 0.2,
	SPOUT_SOUND_OPTIONS = {
		group = "LowPriority",
		radius = 3,
		volume = 0.18,
		fadeIn = 0.15
	},
	SPOUT_COLOR = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(175, 225, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 145, 255))
	}),
	SPOUT_SIZE = NumberSequence.new({ NumberSequenceKeypoint.new(0, 8), NumberSequenceKeypoint.new(1, 8) }),
	SPOUT_SQUASH = NumberSequence.new({ NumberSequenceKeypoint.new(0, -2), NumberSequenceKeypoint.new(1, -2) }),
	SPOUT_TRANSPARENCY = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.05),
		NumberSequenceKeypoint.new(0.75, 0.2),
		NumberSequenceKeypoint.new(1, 1)
	}),
	FEEDBACK_NAME = "FountainPipeHitFeedback",
	REPAIRED_COLOR = Color3.fromRGB(70, 255, 100),
	IN_PROGRESS_COLOR = Color3.fromRGB(255, 70, 70),
	PIPE_TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	WATER_TWEEN_INFO = TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	FEEDBACK_TWEEN_INFO = TweenInfo.new(0.45, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
})
local v = {}
local count = 0
local fn
local fn2
local v2 = nil
local v3 = false
local descendantAddedConnection = nil
local v4 = {}

function v.findPipeNodes()
	local _WorldOrigin = workspace:FindFirstChild("_WorldOrigin")
	local model

	if _WorldOrigin then
		model = _WorldOrigin:FindFirstChild(frozen2.NODES_NAME)
	end

	if model and model:IsA("Model") then
		return model
	end

	return nil
end

function v:hidePipePart()
	if v4[self] == nil then
		v4[self] = {
			transparency = self.LocalTransparencyModifier,
			destroyingConnection = self.Destroying:Once(function()
				v4[self] = nil
			end)
		}
	end

	self.LocalTransparencyModifier = 1
end

function v:restorePipePart()
	local v5 = v4[self]

	if v5 == nil then
		return
	end

	v5.destroyingConnection:Disconnect()
	self.LocalTransparencyModifier = v5.transparency
	v4[self] = nil
end

function v.refreshPipeVisibility()
	local pipeNodes = v.findPipeNodes()

	if not pipeNodes then
		return
	end

	for _, part in pipeNodes:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		if v3 then
			v.hidePipePart(part)
		else
			v.restorePipePart(part)
		end
	end
end

function v.setPipesHidden(flag: boolean)
	v3 = flag

	if not descendantAddedConnection then
		descendantAddedConnection = workspace.DescendantAdded:Connect(function(part)
			local pipeNodes = v.findPipeNodes()

			if not pipeNodes then
				return
			end

			if part == pipeNodes or pipeNodes:IsDescendantOf(part) then
				v.refreshPipeVisibility()
			elseif part:IsA("BasePart") and part:IsDescendantOf(pipeNodes) then
				if v3 then
					v.hidePipePart(part)
				else
					v.restorePipePart(part)
				end
			end
		end)
	end

	v.refreshPipeVisibility()

	if flag then
		return
	end

	local v5 = v4
	v4 = {}

	for k, v6 in v5 do
		v6.destroyingConnection:Disconnect()
		k.LocalTransparencyModifier = v6.transparency
	end
end

function v:releaseSpouts()
	for _, staticSpout in self.staticSpouts do
		if staticSpout.sound then
			sound:Kill(staticSpout.sound)
		end

		for _, emitter in staticSpout.emitters do
			local parent = emitter.Parent

			if parent then
				parent:Destroy()
			else
				emitter:Destroy()
			end
		end
	end

	table.clear(self.staticSpouts)
	self.spoutNodes = nil
	self.spoutStaticPartCount = 0
end

function v.updateSpouts(p)
	for _, staticSpout in p.staticSpouts do
		local v5 = false

		for k, emitter in staticSpout.emitters do
			local pipe = p.pipes[k]
			local enabled

			if pipe == nil or pipe.currentSteps == 0 then
				enabled = false
			else
				enabled = emitter.Parent ~= nil
			end

			if emitter.Parent then
				emitter.Enabled = enabled
			end

			v5 = v5 or enabled
		end

		if staticSpout.sound and not staticSpout.sound.Parent then
			staticSpout.sound = nil
		end

		if v5 and not staticSpout.sound then
			staticSpout.sound = sound:Play(frozen2.SPOUT_SOUND, staticSpout.part, frozen2.SPOUT_SOUND_OPTIONS)
		elseif not v5 and staticSpout.sound then
			sound:FadeOut(staticSpout.sound, frozen2.SPOUT_SOUND_FADE)
			staticSpout.sound = nil
		end
	end
end

function v.createSpoutEmitter(parent, vector2: Vector3)
	local pointToObjectSpace = parent.CFrame:PointToObjectSpace(vector2)
	local v5 = parent.Size * 0.5
	local vector3 = nil
	local vector4

	if parent.Name == frozen2.OMNIDIRECTIONAL_PIPE_NAME then
		if math.abs(pointToObjectSpace.X / v5.X) >= math.abs(pointToObjectSpace.Y / v5.Y) then
			vector3 = Vector3.new(math.sign(pointToObjectSpace.X), 0, 0)
			vector4 = Vector3.new(vector3.X * v5.X, 0, 0)
		else
			vector3 = Vector3.new(0, math.sign(pointToObjectSpace.Y), 0)
			vector4 = Vector3.new(0, vector3.Y * v5.Y, 0)
		end
	else
		vector4 = Vector3.new(
			math.clamp(pointToObjectSpace.X, -v5.X, v5.X),
			math.clamp(pointToObjectSpace.Y, -v5.Y, v5.Y),
			(math.clamp(pointToObjectSpace.Z, -v5.Z, v5.Z))
		)
	end

	local pointToWorldSpace = parent.CFrame:PointToWorldSpace(vector4)

	if vector3 then
		vector2 = pointToWorldSpace + parent.CFrame:VectorToWorldSpace(vector3)
	end

	local v6 = vector2 - pointToWorldSpace

	if v6.Magnitude < 0.01 then
		return nil
	end

	local v7 = math.abs((v6.Unit:Dot(createVector(0, 1, 0)))) > 0.95 and createVector(1, 0, 0) or createVector(0, 1, 0)
	local attachment = Instance.new("Attachment")
	attachment.Name = frozen2.SPOUT_ATTACHMENT_NAME
	attachment.CFrame = parent.CFrame:ToObjectSpace(CFrame.lookAt(pointToWorldSpace, vector2, v7))
	attachment.Parent = parent
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = frozen2.SPOUT_EMITTER_NAME
	particleEmitter.Texture = frozen2.SPOUT_TEXTURE
	particleEmitter.Color = frozen2.SPOUT_COLOR
	particleEmitter.Size = frozen2.SPOUT_SIZE
	particleEmitter.Squash = frozen2.SPOUT_SQUASH
	particleEmitter.Transparency = frozen2.SPOUT_TRANSPARENCY
	particleEmitter.EmissionDirection = Enum.NormalId.Front
	particleEmitter.Lifetime = NumberRange.new(0.45, 0.65)
	particleEmitter.Rate = 45
	particleEmitter.Orientation = Enum.ParticleOrientation.VelocityParallel
	particleEmitter.Speed = NumberRange.new(28, 34)
	particleEmitter.SpreadAngle = Vector2.new(20, 20)
	particleEmitter.Acceleration = createVector(0, -35, 0)
	particleEmitter.Drag = 1
	particleEmitter.LightEmission = 0.45
	particleEmitter.Enabled = false
	particleEmitter.Parent = attachment
	return particleEmitter
end

function v.spoutsAreValid(data, instance)
	if data.spoutNodes ~= instance then
		return false
	end

	local count2 = 0

	for _, part in instance:GetChildren() do
		if not (part:IsA("BasePart") and part:GetAttribute(frozen2.PIPE_ID_ATTRIBUTE) == nil) then
			continue
		end

		count2 += 1
	end

	if count2 ~= data.spoutStaticPartCount then
		return false
	end

	for k, staticSpout in data.staticSpouts do
		if k.Parent ~= instance then
			return false
		end

		for k2, emitter in staticSpout.emitters do
			local pipe = data.pipes[k2]

			if not pipe or not pipe.part or pipe.part.Parent ~= instance or not emitter.Parent then
				return false
			end
		end
	end

	return next(data.staticSpouts) ~= nil
end

function v:resolveSpouts(spoutNodes)
	if v.spoutsAreValid(self, spoutNodes) then
		return
	end

	v.releaseSpouts(self)
	local parts = {}

	for _, part in spoutNodes:GetChildren() do
		if not (part:IsA("BasePart") and part:GetAttribute(frozen2.PIPE_ID_ATTRIBUTE) == nil) then
			continue
		end

		table.insert(parts, part)
	end

	for _, pipe in self.pipes do
		if not pipe.part or pipe.part.Parent ~= spoutNodes then
			return
		end
	end

	local staticSpouts = {}

	for k, pipe in self.pipes do
		local part = pipe.part
		local v6 = pipe.originalPivot * part.PivotOffset:Inverse()
		local position = v6.Position

		for _, part2 in parts do
			if PipeRipple.getSurfaceGap(part.Size, v6, part2.Size, part2.CFrame) > PipeRipple.MAX_SURFACE_GAP then
				continue
			end

			local v8 = staticSpouts[part2]

			if not v8 then
				v8 = {
					part = part2,
					emitters = {},
					sound = nil
				}
				staticSpouts[part2] = v8
			end

			local spoutEmitter = v.createSpoutEmitter(part2, position)

			if spoutEmitter then
				v8.emitters[k] = spoutEmitter
			end
		end
	end

	self.staticSpouts = staticSpouts
	self.spoutNodes = spoutNodes
	self.spoutStaticPartCount = #parts
	v.updateSpouts(self)
end

function v:releasePipeTween()
	if self.pivotConnection then
		self.pivotConnection:Disconnect()
		self.pivotConnection = nil
	end

	if self.completedConnection then
		self.completedConnection:Disconnect()
		self.completedConnection = nil
	end

	if self.tween then
		self.tween:Destroy()
		self.tween = nil
	end

	if self.pivotValue then
		self.pivotValue:Destroy()
		self.pivotValue = nil
	end
end

function v:stopPipeTween()
	if self.completedConnection then
		self.completedConnection:Disconnect()
		self.completedConnection = nil
	end

	if self.tween then
		self.tween:Cancel()
	end

	v.releasePipeTween(self)
end

function v.updatePipeCollision(data)
	local part = data.part

	if part and part.Parent then
		part.CanCollide = data.currentSteps == 0 and data.tween == nil
	end
end

function v:releasePipeFeedback()
	if self.feedbackConnection then
		self.feedbackConnection:Disconnect()
		self.feedbackConnection = nil
	end

	if self.feedbackTween then
		self.feedbackTween:Cancel()
		self.feedbackTween:Destroy()
		self.feedbackTween = nil
	end

	if self.feedbackHighlight then
		self.feedbackHighlight:Destroy()
		self.feedbackHighlight = nil
	end
end

function v:flashPipe(flag: boolean)
	v.releasePipeFeedback(self)
	local part = self.part

	if not (part and part.Parent) then
		return
	end

	local REPAIRED_COLOR

	if flag then
		REPAIRED_COLOR = frozen2.REPAIRED_COLOR
	else
		REPAIRED_COLOR = frozen2.IN_PROGRESS_COLOR
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = frozen2.FEEDBACK_NAME
	highlight.Adornee = part
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.FillColor = REPAIRED_COLOR
	highlight.OutlineColor = REPAIRED_COLOR
	highlight.FillTransparency = 0.2
	highlight.OutlineTransparency = 0
	highlight.Parent = part
	local tween = TweenService:Create(highlight, frozen2.FEEDBACK_TWEEN_INFO, {
		FillTransparency = 1,
		OutlineTransparency = 1
	})
	local completedConnection = tween.Completed:Connect(function()
		if self.feedbackTween == tween then
			v.releasePipeFeedback(self)
		end
	end)
	self.feedbackHighlight = highlight
	self.feedbackTween = tween
	self.feedbackConnection = completedConnection
	tween:Play()
end

function v.restorePipes(p)
	PipeRipple.clear(p.ripple)

	for _, pipe in p.pipes do
		v.stopPipeTween(pipe)
		v.releasePipeFeedback(pipe)
		local part = pipe.part

		if not (part and part.Parent) then
			continue
		end

		part:PivotTo(pipe.originalPivot)
		part.CanCollide = false
	end

	table.clear(p.pipes)
end

function v:stopWaterTween()
	if self.tween then
		self.tween:Cancel()
		self.tween:Destroy()
		self.tween = nil
	end
end

function v:restoreWater()
	local water = self.water

	if not water then
		return
	end

	v.stopWaterTween(water)

	if water.part.Parent then
		water.part.Size = water.originalSize
		water.part.CFrame = water.originalCFrame
	end

	self.water = nil
end

function v:stopBoatShake()
	if self.boatShakeConnection then
		self.boatShakeConnection:Disconnect()
		self.boatShakeConnection = nil
	end
end

function v:stopBoatTracker()
	if self.boatTrackerSeatConnection then
		self.boatTrackerSeatConnection:Disconnect()
		self.boatTrackerSeatConnection = nil
	end

	if self.boatTrackerCharacterConnection then
		self.boatTrackerCharacterConnection:Disconnect()
		self.boatTrackerCharacterConnection = nil
	end

	if not self.boatTrackerActive then
		return
	end

	self.boatTrackerActive = false
	local CompassTracker = require(game.ReplicatedStorage.GuideModule.CompassTracker)
	CompassTracker.removeTracker(frozen2.BOAT_TRACKER_ID)
end

function v.isLaunchSeat(p, vehicleSeat)
	if not (vehicleSeat and vehicleSeat:IsA("VehicleSeat")) then
		return false
	end

	local model = vehicleSeat:FindFirstAncestorWhichIsA("Model")
	return model ~= nil and model:GetAttribute(frozen2.LAUNCH_OWNER_ATTRIBUTE) == p.Player.UserId
end

function v.bindBoatTrackerToCharacter(p, p2, instance)
	if p2.boatTrackerSeatConnection then
		p2.boatTrackerSeatConnection:Disconnect()
		p2.boatTrackerSeatConnection = nil
	end

	local humanoid = instance:FindFirstChildOfClass("Humanoid")

	if not humanoid then
		return
	end

	if v.isLaunchSeat(p, humanoid.SeatPart) then
		v.stopBoatTracker(p2)
	else
		p2.boatTrackerSeatConnection = humanoid.Seated:Connect(function(flag: boolean, p3)
			if flag and v.isLaunchSeat(p, p3) then
				v.stopBoatTracker(p2)
			end
		end)
	end
end

function v.getSteeringTrackerTarget(instance, p)
	local part = instance:FindFirstChild(frozen2.STEERING_WHEEL_SPINDLE_NAME, true)

	if part and part:IsA("BasePart") then
		return part
	end

	local instance2 = instance:FindFirstChild(frozen2.STEERING_WHEEL_RIG_NAME, true)

	if instance2 and instance2:IsA("BasePart") or instance2 and instance2:IsA("Model") then
		return instance2
	end

	return p
end

function v.startBoatTracker(p, p2, p3, p4)
	if p2.boatTrackerActive then
		return
	end

	p2.boatTrackerActive = true
	local CompassTracker = require(game.ReplicatedStorage.GuideModule.CompassTracker)
	CompassTracker.createTracker(frozen2.BOAT_TRACKER_ID, {
		Target = v.getSteeringTrackerTarget(p3, p4),
		AlertIconSettings = {
			MaxDistance = 1000
		},
		IconSettings = {
			ShowIsland = false
		},
		ShowOffScreenAlert = true
	})
	p2.boatTrackerCharacterConnection = p.Player.CharacterAdded:Connect(function(character)
		v.bindBoatTrackerToCharacter(p, p2, character)
	end)
	local character = p.Player.Character

	if character then
		v.bindBoatTrackerToCharacter(p, p2, character)
	end
end

function v:suppressBoatForHandoff()
	v.stopBoatShake(self)

	if self.boatPartStates then
		return
	end

	local boatPartStates = {}

	if self.boat then
		for _, part in self.boat:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			boatPartStates[part] = {
				canCollide = part.CanCollide,
				canQuery = part.CanQuery,
				canTouch = part.CanTouch
			}
			part.CanQuery = false
			part.CanTouch = false
		end
	end

	self.boatPartStates = boatPartStates
end

function v.restoreBoatAfterRejectedHandoff(p, state)
	local boatPartStates = state.boatPartStates
	state.boatPartStates = nil

	if boatPartStates then
		for k, boatPartState in boatPartStates do
			if not k.Parent then
				continue
			end

			k.CanCollide = boatPartState.canCollide
			k.CanQuery = boatPartState.canQuery
			k.CanTouch = boatPartState.canTouch
		end
	end

	if not state.cleaned and state.boat and state.boat.Parent then
		fn(p, state, state.boat)
	end
end

function v:releaseBoat()
	v.stopBoatShake(self)
	v.stopBoatTracker(self)
	self.boatPartStates = nil

	if self.boat then
		self.boat:Destroy()
		self.boat = nil
	end
end

function v.getState(maid)
	local _fountainPipeRepairState = maid.MiscData._fountainPipeRepairState

	if _fountainPipeRepairState then
		return _fountainPipeRepairState
	end

	local fountainPipeRepairState = {
		pipes = {},
		staticSpouts = {},
		spoutNodes = nil,
		spoutStaticPartCount = 0,
		ripple = PipeRipple.create(),
		water = nil,
		boat = nil,
		boatShakeConnection = nil,
		boatPartStates = nil,
		boatTrackerActive = false,
		boatTrackerSeatConnection = nil,
		boatTrackerCharacterConnection = nil,
		spawningBoat = false,
		turnInRequested = false,
		cleaned = false,
		repairedCount = 0,
		totalPipes = 0,
		fullyRepaired = false,
		boatReadyAlpha = 0,
		setupGeneration = 0
	}
	maid.MiscData._fountainPipeRepairState = fountainPipeRepairState
	maid:GiveTask(function()
		fountainPipeRepairState.cleaned = true
		v.releaseSpouts(fountainPipeRepairState)
		v.restorePipes(fountainPipeRepairState)
		v.restoreWater(fountainPipeRepairState)

		if fountainPipeRepairState.turnInRequested then
			v.suppressBoatForHandoff(fountainPipeRepairState)
		else
			v.releaseBoat(fountainPipeRepairState)
		end

		maid.MiscData._fountainPipeRepairState = nil
	end)
	return fountainPipeRepairState
end

function v.getBoatPresentation()
	local bonusMoments = game.ReplicatedStorage:FindFirstChild("BonusMoments") or game.ReplicatedStorage:WaitForChild(
		"BonusMoments",
		frozen2.DEPENDENCY_TIMEOUT
	)
	local lookout

	if bonusMoments then
		lookout = bonusMoments:FindFirstChild("Lookout") or bonusMoments:WaitForChild(
			"Lookout",
			frozen2.DEPENDENCY_TIMEOUT
		)
	end

	local boatPresentation

	if lookout then
		boatPresentation = lookout:FindFirstChild("BoatPresentation") or lookout:WaitForChild(
			"BoatPresentation",
			frozen2.DEPENDENCY_TIMEOUT
		)
	end

	if not (boatPresentation and boatPresentation:IsA("ModuleScript")) then
		return nil, "Lookout.BoatPresentation is unavailable"
	end

	local success, result = pcall(require, boatPresentation)

	if success then
		return result, nil
	end

	return nil, (tostring(result))
end

function v:resolveLaunchPlan(instance)
	if self.flightPlan then
		return
	end

	local attribute = instance:GetAttribute(frozen2.LAUNCH_MOTION.START_PIVOT_ATTRIBUTE)
	local attribute2 = instance:GetAttribute(frozen2.LAUNCH_MOTION.LANDING_PIVOT_ATTRIBUTE)

	if typeof(attribute) ~= "CFrame" or typeof(attribute2) ~= "CFrame" then
		return
	end

	self.startPivot = attribute
	self.flightPlan = BoatLaunchMotion.createFlightPlan(attribute, attribute2)
	self.finalCameraPosition = (attribute2 * self.seatPivotOffset * CFrame.new(
		-frozen2.LAUNCH_FINAL_CAMERA_LEFT_DISTANCE,
		0,
		-frozen2.LAUNCH_FINAL_CAMERA_FORWARD_DISTANCE
	)).Position + createVector(0, 1, 0) * frozen2.LAUNCH_FINAL_CAMERA_UP_DISTANCE
end

function v:updateLocalLaunchMotion(instance, p)
	v.resolveLaunchPlan(self, instance)
	local startPivot = self.startPivot
	local flightPlan = self.flightPlan

	if not (startPivot and flightPlan) then
		return
	end

	local landingPivot = nil

	if p == "Flight" or p == "Descent" or p == "Landing" then
		local attribute = instance:GetAttribute(frozen2.LAUNCH_MOTION.FLIGHT_STARTED_AT_ATTRIBUTE)

		if typeof(attribute) == "number" then
			local v5 = workspace:GetServerTimeNow() - attribute

			if not self.launchScaleCompleted then
				instance:ScaleTo(BoatLaunchMotion.getLaunchScale(v5))
				self.launchScaleCompleted = frozen2.LAUNCH_MOTION.BOAT_LAUNCH_SCALE_DURATION <= v5
			end

			if v5 < frozen2.LAUNCH_MOTION.LAUNCH_DURATION then
				landingPivot = BoatLaunchMotion.getFlightCFrame(
					startPivot,
					flightPlan,
					v5 / frozen2.LAUNCH_MOTION.LAUNCH_DURATION
				)
			else
				landingPivot = BoatLaunchMotion.getLandingCFrame(flightPlan, v5 - frozen2.LAUNCH_MOTION.LAUNCH_DURATION)
			end
		end
	elseif p == "Landed" then
		landingPivot = flightPlan.landingPivot
	end

	if landingPivot then
		instance:PivotTo(landingPivot)
	end
end

function v:updateLaunchCamera(instance, object, p)
	local now = os.clock()
	local v5 = p == "Flight" or p == "Descent" or p == "Landing"

	if not self.flightStartedAt and v5 then
		self.flightStartedAt = now
	end

	if self.angleOneAt or not (self.flightStartedAt and now - self.flightStartedAt >= frozen2.LAUNCH_ANGLE_ONE_FLIGHT_DELAY) then
		if not self.angleTwoAt and self.angleOneAt and now - self.angleOneAt >= frozen2.LAUNCH_ANGLE_TWO_DELAY then
			object:SetCFrame(instance:GetPivot() * frozen2.LAUNCH_CAMERA_ANGLE_TWO)
			self.angleTwoAt = now
		end
	else
		object:SetCFrame(instance:GetPivot() * frozen2.LAUNCH_CAMERA_ANGLE_ONE)
		self.angleOneAt = now
	end

	local v6 = p == "Descent" or p == "Landing"

	if not self.trackingFinalCamera and self.angleTwoAt and v6 and self.finalCameraPosition and now - self.angleTwoAt >= frozen2.LAUNCH_ANGLE_TWO_MINIMUM_HOLD then
		self.trackingFinalCamera = true
	end

	local finalCameraPosition = self.finalCameraPosition

	if self.trackingFinalCamera and finalCameraPosition then
		object:SetCFrame(CFrame.lookAt(finalCameraPosition, instance:GetPivot().Position, createVector(0, 1, 0)))
	end
end

function v:renderLaunchFrame(instance, p, p2, p3)
	if self.finished then
		return true
	end

	if self.serial ~= count or not instance.Parent or not p.Parent or workspace.CurrentCamera ~= p2 then
		self.finished = true
		return true
	end

	local attribute = instance:GetAttribute(frozen2.LAUNCH_PHASE_ATTRIBUTE)
	v.updateLocalLaunchMotion(self, instance, attribute)

	if attribute == "Landed" or attribute == "Released" or attribute == "Recovering" then
		self.finished = true
		return true
	end

	v.updateLaunchCamera(self, p, p3, attribute)
	return true
end

function v.playLaunchCutscene(instance)
	count += 1
	local currentCamera = workspace.CurrentCamera
	local vehicleSeat = instance:FindFirstChild("VehicleSeat")

	if not (currentCamera and vehicleSeat and vehicleSeat:IsA("VehicleSeat")) then
		return
	end

	local objectSpace = instance:GetPivot():ToObjectSpace(vehicleSeat:GetPivot())
	local v5 = frozen2.LAUNCH_MOTION.BOAT_LAUNCH_SCALE / instance:GetScale()
	local seatPivotOffset = CFrame.new(objectSpace.Position * v5) * objectSpace.Rotation
	local v7 = {
		serial = count,
		startedAt = os.clock(),
		flightStartedAt = nil,
		angleOneAt = nil,
		angleTwoAt = nil,
		trackingFinalCamera = false,
		launchScaleCompleted = false,
		seatPivotOffset = seatPivotOffset,
		finalCameraPosition = nil,
		finished = false,
		renderError = nil,
		startPivot = nil,
		flightPlan = nil
	}
	local formatted = `FountainPipeRepairLaunch_{v7.serial}`
	local v8 = CameraController.new(currentCamera)
	local v9, v10 = xpcall(function()
		v8:SetCFrame(vehicleSeat:GetPivot() * frozen2.LAUNCH_CAMERA_ANGLE_THREE)
		RunService:BindToRenderStep(formatted, frozen2.LAUNCH_RENDER_PRIORITY, function()
			local success, result = pcall(v.renderLaunchFrame, v7, instance, vehicleSeat, currentCamera, v8)

			if not success then
				v7.renderError = tostring(result)
				v7.finished = true
			end
		end)

		while not v7.finished and v7.serial == count and os.clock() - v7.startedAt < frozen2.LAUNCH_CAMERA_TIMEOUT do
			task.wait()
		end
	end, debug.traceback)
	RunService:UnbindFromRenderStep(formatted)
	local renderError

	if v9 then
		renderError = v7.renderError
	else
		renderError = tostring(v10)
	end

	if renderError or not v7.trackingFinalCamera or workspace.CurrentCamera ~= currentCamera then
		v8:Destroy()
	else
		v8:FadeOut(frozen2.LAUNCH_CAMERA_FADE_DURATION)
	end

	if renderError then
		warn((`[Fountain Pipe Repair] Grand Brigade camera failed: {renderError}`))
	end
end

function v.getLaunchReadyEvent(instance, p: number)
	local vehicleSeat = instance:FindFirstChild("VehicleSeat")
	local seatWeld

	if vehicleSeat then
		seatWeld = vehicleSeat:FindFirstChild("SeatWeld")
	end

	local weldConstraint = instance:FindFirstChild(frozen2.LAUNCH_MOTION.LAUNCH_HOLD_WELD_NAME)
	local remoteEvent = instance:FindFirstChild(frozen2.LAUNCH_MOTION.LAUNCH_READY_EVENT_NAME)
	local character = game.Players.LocalPlayer.Character
	local humanoidRootPart

	if character then
		humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	end

	local humanoid

	if character then
		humanoid = character:FindFirstChildOfClass("Humanoid")
	end

	if instance:IsDescendantOf(workspace) and instance.PrimaryPart ~= nil and vehicleSeat ~= nil and vehicleSeat:IsA("VehicleSeat") and humanoid ~= nil and humanoid.SeatPart == vehicleSeat and seatWeld ~= nil and seatWeld:IsA("Weld") and seatWeld.Part0 == vehicleSeat and seatWeld.Part1 ~= nil and character ~= nil and seatWeld.Part1:IsDescendantOf(character) and weldConstraint ~= nil and weldConstraint:IsA("WeldConstraint") and weldConstraint.Part0 == vehicleSeat and weldConstraint.Part1 == humanoidRootPart and instance:GetAttribute(frozen2.LAUNCH_OWNER_ATTRIBUTE) == p and remoteEvent ~= nil and remoteEvent:IsA("RemoteEvent") then
		return remoteEvent
	end

	return nil
end

function v.hideLaunchBoatPart(p, p2)
	if p.partTransparency[p2] == nil then
		p.partTransparency[p2] = p2.LocalTransparencyModifier
	end

	p2.LocalTransparencyModifier = 1
end

function v:clearHiddenLaunchBoat()
	if self.descendantConnection then
		self.descendantConnection:Disconnect()
		self.descendantConnection = nil
	end

	for k, localTransparencyModifier in self.partTransparency do
		if k.Parent then
			k.LocalTransparencyModifier = localTransparencyModifier
		end
	end

	table.clear(self.partTransparency)
	self.boat = nil
end

function v:hideLaunchBoat(folder)
	if self.boat == folder then
		return
	end

	if self.boat then
		v.clearHiddenLaunchBoat(self)
	end

	self.boat = folder

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			v.hideLaunchBoatPart(self, part)
		end
	end

	self.descendantConnection = folder.DescendantAdded:Connect(function(part)
		if part:IsA("BasePart") then
			v.hideLaunchBoatPart(self, part)
		end
	end)
end

function v.isLaunchBoatForUser(instance, p: number, p2)
	return instance:GetAttribute(frozen2.LAUNCH_OWNER_ATTRIBUTE) == p and instance:GetAttribute(frozen2.LAUNCH_PHASE_ATTRIBUTE) == "Shake" and instance:GetAttribute(frozen2.LAUNCH_TOKEN_ATTRIBUTE) == p2
end

function v.createLaunchBoatHider(p: number, p2)
	local v5 = {
		boat = nil,
		partTransparency = {},
		workspaceConnection = nil,
		descendantConnection = nil
	}
	v5.workspaceConnection = workspace.ChildAdded:Connect(function(model)
		if model:IsA("Model") and v.isLaunchBoatForUser(model, p, p2) then
			v.hideLaunchBoat(v5, model)
		end
	end)

	for _, model in workspace:GetChildren() do
		if not (model:IsA("Model") and v.isLaunchBoatForUser(model, p, p2)) then
			continue
		end

		v.hideLaunchBoat(v5, model)
		return v5
	end

	return v5
end

function v:releaseLaunchBoatHider()
	if self.workspaceConnection then
		self.workspaceConnection:Disconnect()
		self.workspaceConnection = nil
	end

	v.clearHiddenLaunchBoat(self)
end

function v.waitForHiddenLaunchBoat(p, p2: number)
	while os.clock() < p2 do
		if p.boat and p.boat:IsDescendantOf(game) then
			return p.boat
		else
			task.wait()
		end
	end

	return nil
end

function v.waitForLaunchBoat(instance, p: number, p2: number)
	local v5 = false

	while instance:IsDescendantOf(game) and os.clock() < p2 do
		if not v5 and typeof(instance:GetAttribute(frozen2.EXPECTED_DESCENDANTS_ATTRIBUTE)) == "number" then
			pcall(
				WaitForExpectedDescendants,
				instance,
				math.min(frozen2.DEPENDENCY_TIMEOUT, (math.max(p2 - os.clock(), 0))),
				false
			)
			v5 = true
		end

		local launchReadyEvent = v.getLaunchReadyEvent(instance, p)

		if launchReadyEvent then
			return launchReadyEvent
		else
			task.wait()
		end
	end

	return nil
end

function v.waitForLaunchRecovery(instance)
	local v5 = os.clock() + frozen2.LAUNCH_RECOVERY_TIMEOUT

	while instance:IsDescendantOf(game) and os.clock() < v5 do
		if instance:GetAttribute(frozen2.LAUNCH_PHASE_ATTRIBUTE) == "Released" then
			break
		else
			task.wait()
		end
	end
end

function v.cancelLaunchHandoff(p, p2, instance)
	local remoteEvent = instance:FindFirstChild(frozen2.LAUNCH_MOTION.LAUNCH_READY_EVENT_NAME)

	if remoteEvent and remoteEvent:IsA("RemoteEvent") then
		pcall(remoteEvent.FireServer, remoteEvent, "Cancel")
	end

	v.waitForLaunchRecovery(instance)
	v.releaseLaunchBoatHider(p2)

	if p then
		v.releaseBoat(p)
	end
end

function v.signalLaunchReady(instance, p, p2: number)
	if v.getLaunchReadyEvent(instance, p2) == p and instance:GetAttribute(frozen2.LAUNCH_PHASE_ATTRIBUTE) == "Shake" then
		return (pcall(p.FireServer, p, "Ready"))
	end

	return false
end

function v.releaseHandoffPreview(p, instance)
	if p and instance == p.boat then
		v.releaseBoat(p)
	elseif instance and instance.Parent then
		instance:Destroy()
	end
end

function v.releaseDebugLaunchHandoff(data)
	v.releaseHandoffPreview(data.state, data.previewBoat)
	v.releaseLaunchBoatHider(data.hider)
end

function v.cancelDebugLaunchPreparation(data)
	v.releaseLaunchBoatHider(data.hider)
	data.moment.MiscData._debugLaunchPending = nil
	local state = data.state

	if not state or state.cleaned then
		v.releaseHandoffPreview(state, data.previewBoat)
		return
	end

	local previewBoat = data.previewBoat

	if previewBoat and previewBoat.Parent then
		if data.previewScale then
			previewBoat:ScaleTo(data.previewScale)
		end

		if data.previewPivot then
			previewBoat:PivotTo(data.previewPivot)
		end
	end

	state.turnInRequested = false
	v.restoreBoatAfterRejectedHandoff(data.moment, state)
end

function v.expireDebugLaunchHandoff(data)
	data.moment.MiscData._debugLaunchPending = nil
	local boat = data.hider.boat

	if boat and boat:IsDescendantOf(game) then
		v.cancelLaunchHandoff(data.state, data.hider, boat)
	else
		v.cancelDebugLaunchPreparation(data)
	end
end

function v.requestTurnIn(object, state)
	local boat = state.boat
	local launchBoatHider = v.createLaunchBoatHider(object.Player.UserId, false)
	v.suppressBoatForHandoff(state)
	fn2(boat)
	local success, result, model, v5 = pcall(function()
		return object:InvokeServer("TurnIn")
	end)

	if success and BonusMomentInteraction.isTransformedReason(v5) then
		BonusMomentInteraction.notifyTransformed()
	end

	local v6 = os.clock() + frozen2.LAUNCH_PREPARE_TIMEOUT

	if not success or result ~= true or typeof(model) ~= "Instance" or not model:IsA("Model") then
		model = nil
	end

	if model then
		v.hideLaunchBoat(launchBoatHider, model)
	elseif not success or result == true then
		model = v.waitForHiddenLaunchBoat(launchBoatHider, v6)
	end

	if model then
		local v7 = v.waitForLaunchBoat(model, object.Player.UserId, v6)

		if v7 then
			fn2(boat)

			if not v.signalLaunchReady(model, v7, object.Player.UserId) then
				v.cancelLaunchHandoff(state, launchBoatHider, model)
				return
			end

			v.releaseHandoffPreview(state, boat)
			v.releaseLaunchBoatHider(launchBoatHider)
			v.playLaunchCutscene(model)
		else
			warn("[Fountain Pipe Repair] Grand Brigade did not fully replicate before launch")
			v.cancelLaunchHandoff(state, launchBoatHider, model)
		end
	else
		v.releaseLaunchBoatHider(launchBoatHider)

		if state.cleaned then
			v.releaseBoat(state)
			return
		end

		state.turnInRequested = false
		v.restoreBoatAfterRejectedHandoff(object, state)
	end
end

function v.tryRequestTurnIn(p, state, instance)
	if state.cleaned or state.turnInRequested or not state.fullyRepaired or state.boatReadyAlpha < 1 then
		return false
	end

	local character = p.Player.Character

	if not (character and instance:IsDescendantOf(character)) then
		return false
	end

	if BonusMomentInteraction.isTransformed(character) then
		BonusMomentInteraction.notifyTransformed()
		return false
	end

	state.turnInRequested = true
	task.spawn(v.requestTurnIn, p, state)
	return true
end

function v.tryRequestSeatContacts(p, p2, object)
	if not object.Parent then
		return
	end

	for _, v5 in object:GetTouchingParts() do
		if v.tryRequestTurnIn(p, p2, v5) then
			break
		end
	end
end

function v.createFakeSeat(p, p2, parent, p3, instance)
	local primaryPart = parent.PrimaryPart
	local driverSeatOffset = p3.getDriverSeatOffset(parent)

	if not (primaryPart and driverSeatOffset) then
		return false, "Grand Brigade preview has no saved driver-seat offset"
	end

	local part = Instance.new("Part")
	part.Name = frozen2.FAKE_SEAT_NAME
	part.Size = frozen2.FAKE_SEAT_SIZE
	local child = instance:FindFirstChild(frozen2.BOAT_TEMPLATE)
	local vehicleSeat

	if child then
		vehicleSeat = child:FindFirstChild("VehicleSeat", true)
	end

	if vehicleSeat and vehicleSeat:IsA("BasePart") then
		part.Size = vehicleSeat.Size
		part.Color = vehicleSeat.Color
		part.Material = vehicleSeat.Material
		part.MaterialVariant = vehicleSeat.MaterialVariant
		part.Reflectance = vehicleSeat.Reflectance
	end

	part.Anchored = false
	part.CanCollide = true
	part.CanQuery = false
	part.CanTouch = true
	part.CastShadow = true
	part.Massless = true
	part.Transparency = 0
	part.CFrame = primaryPart.CFrame * driverSeatOffset
	part.Parent = parent
	local weldConstraint = Instance.new("WeldConstraint")
	weldConstraint.Name = "FakeVehicleSeatWeld"
	weldConstraint.Part0 = primaryPart
	weldConstraint.Part1 = part
	weldConstraint.Parent = part
	part.Touched:Connect(function(otherPart)
		v.tryRequestTurnIn(p, p2, otherPart)
	end)
	return true, nil
end

function v.getBoatTargetCFrame(value: number)
	return frozen2.BOAT_START_CFRAME:Lerp(frozen2.BOAT_READY_CFRAME, (math.clamp(value, 0, 1)))
end

fn2 = function(instance)
	if not (instance and instance.Parent) then
		return
	end

	local pivot = instance:GetPivot()
	local scale = instance:GetScale()
	local boatTargetCFrame = v.getBoatTargetCFrame(1)
	local lastTime = os.clock()

	while instance.Parent do
		local v5 = math.min((os.clock() - lastTime) / frozen2.BOAT_HANDOFF_SETTLE_DURATION, 1)
		local value = TweenService:GetValue(v5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		instance:ScaleTo(scale + (frozen2.LAUNCH_MOTION.BOAT_READY_SCALE - scale) * value)
		instance:PivotTo(pivot:Lerp(boatTargetCFrame, value))

		if v5 >= 1 then
			break
		else
			RunService.RenderStepped:Wait()
		end
	end
end

function v.getRepairProgress(data)
	if data.fullyRepaired then
		return 1
	end

	if data.totalPipes <= 0 then
		return 0
	end

	return (math.clamp(data.repairedCount / data.totalPipes, 0, 1))
end

function v.getBoatProgressTarget(data)
	if data.fullyRepaired then
		return 1
	end

	if data.totalPipes <= 1 then
		return 0
	end

	return frozen2.LAUNCH_MOTION.BOAT_ALMOST_READY_PROGRESS * math.clamp(
		data.repairedCount / (data.totalPipes - 1),
		0,
		1
	)
end

fn = function(p, state, instance)
	if state.boatShakeConnection then
		state.boatShakeConnection:Disconnect()
	end

	local total = 0
	local v5 = 0
	local boatReadyAlpha = state.boatReadyAlpha
	local boatReadyAlpha2 = state.boatReadyAlpha
	state.boatShakeConnection = RunService.RenderStepped:Connect(function(dt)
		if state.cleaned or state.boat ~= instance or not instance.Parent then
			return
		end

		total += dt
		local boatProgressTarget = v.getBoatProgressTarget(state)

		if boatProgressTarget ~= boatReadyAlpha2 then
			v5 = total
			boatReadyAlpha = state.boatReadyAlpha
			boatReadyAlpha2 = boatProgressTarget
		end

		local boatReadyAlpha3 = state.boatReadyAlpha
		local value = TweenService:GetValue(
			math.clamp((total - v5) / frozen2.LAUNCH_MOTION.BOAT_READY_LURCH_DURATION, 0, 1),
			Enum.EasingStyle.Quint,
			Enum.EasingDirection.Out
		)
		state.boatReadyAlpha = boatReadyAlpha + (boatReadyAlpha2 - boatReadyAlpha) * value
		local v7

		if boatReadyAlpha3 < 1 then
			v7 = state.boatReadyAlpha >= 1
		else
			v7 = false
		end

		if state.boatReadyAlpha ~= boatReadyAlpha3 then
			instance:ScaleTo(BoatLaunchMotion.getPreviewScale(state.boatReadyAlpha))
		end

		local v8 = not (state.fullyRepaired and state.boatReadyAlpha >= 1) and 0 or frozen2.BOAT_READY_SHAKE_MULTIPLIER
		local v9 = Vector3.new(
			math.noise(total * 11, 0, 0),
			math.noise(0, total * 11 * 1.15, 0) * 0.55,
			math.noise(0, 0, total * 11 * 0.9)
		) * frozen2.BOAT_SHAKE_POSITION * v8
		local cframe = CFrame.Angles(
			math.noise(total * 11 * 1.2, 4, 0) * frozen2.BOAT_SHAKE_ROTATION * v8,
			math.noise(0, total * 11, 8) * frozen2.BOAT_SHAKE_ROTATION * 0.65 * v8,
			math.noise(12, 0, total * 11 * 1.1) * frozen2.BOAT_SHAKE_ROTATION * v8
		)
		instance:PivotTo(v.getBoatTargetCFrame(state.boatReadyAlpha) * CFrame.new(v9) * cframe)

		if v7 then
			local part = instance:FindFirstChild(frozen2.FAKE_SEAT_NAME)

			if part and part:IsA("BasePart") then
				v.startBoatTracker(p, state, instance, part)
				task.spawn(function()
					RunService.Heartbeat:Wait()
					v.tryRequestSeatContacts(p, state, part)
				end)
			end
		end
	end)
end

function v.spawnStuckBoat(p)
	local state = v.getState(p)

	if state.boat or state.spawningBoat or state.cleaned then
		return
	end

	state.spawningBoat = true
	local boatPresentation, v5 = v.getBoatPresentation()

	if boatPresentation then
		local cache, v6 = boatPresentation.resolveCache()

		if cache then
			local namedFromCache, v7 = boatPresentation.cloneNamedFromCache(
				cache,
				frozen2.BOAT_TEMPLATE,
				frozen2.BOAT_SAIL_COLOR,
				"Observation"
			)
			state.spawningBoat = false

			if not namedFromCache then
				warn((`[Fountain Pipe Repair] {tostring(v7)}`))
				return
			end

			if state.cleaned then
				namedFromCache:Destroy()
				return
			end

			namedFromCache.Name = frozen2.BOAT_NAME
			boatPresentation.enableCollisions(namedFromCache)
			local fakeSeat, v8 = v.createFakeSeat(p, state, namedFromCache, boatPresentation, cache)

			if fakeSeat then
				namedFromCache:ScaleTo(frozen2.LAUNCH_MOTION.BOAT_STUCK_SCALE)
				namedFromCache:PivotTo(v.getBoatTargetCFrame(state.boatReadyAlpha))
				namedFromCache.Parent = workspace
				state.boat = namedFromCache
				fn(p, state, namedFromCache)
			else
				namedFromCache:Destroy()
				warn((`[Fountain Pipe Repair] {tostring(v8)}`))
			end
		else
			state.spawningBoat = false
			warn((`[Fountain Pipe Repair] {tostring(v6)}`))
		end
	else
		state.spawningBoat = false
		warn((`[Fountain Pipe Repair] {tostring(v5)}`))
	end
end

function v.isValidSetup(data)
	if typeof(data) == "table" and typeof(data.id) == "string" and data.id ~= "" and typeof(data.originalPivot) == "CFrame" and typeof(data.rotationAxis) == "Vector3" and (data.rotationAxis == createVector(
		1,
		0,
		0
	) or data.rotationAxis == createVector(0, 1, 0)) and typeof(data.radiansPerStep) == "number" and data.radiansPerStep > 0 and data.radiansPerStep < 3.141592653589793 and typeof(data.maxSteps) == "number" and data.maxSteps >= 1 and data.maxSteps % 1 == 0 and typeof(data.currentSteps) == "number" and math.abs(data.currentSteps) <= data.maxSteps and data.currentSteps % 1 == 0 and typeof(data.revision) == "number" and data.revision >= 0 then
		return data.revision % 1 == 0
	else
		return false
	end
end

function v.getPipePivot(data)
	local cframe = CFrame.fromAxisAngle(data.rotationAxis, data.radiansPerStep * data.currentSteps)
	return data.originalPivot * cframe
end

function v:applyPipeProgress(value: number, revision: number)
	self.currentSteps = math.clamp(value, -self.maxSteps, self.maxSteps)
	self.revision = revision
	local part = self.part

	if not (part and part.Parent) then
		return
	end

	v.stopPipeTween(self)
	part.CanCollide = false
	local pipePivot = v.getPipePivot(self)
	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = part:GetPivot()
	local changedConnection = cFrameValue.Changed:Connect(function(cframe: CFrame)
		if part.Parent then
			part:PivotTo(cframe)
		end
	end)
	local tween = TweenService:Create(cFrameValue, frozen2.PIPE_TWEEN_INFO, {
		Value = pipePivot
	})
	local completedConnection = tween.Completed:Connect(function(p)
		if self.tween ~= tween then
			return
		end

		local v5 = p == Enum.PlaybackState.Completed

		if v5 and part.Parent then
			part:PivotTo(pipePivot)
		end

		v.releasePipeTween(self)

		if v5 then
			v.updatePipeCollision(self)
		end
	end)
	self.pivotValue = cFrameValue
	self.pivotConnection = changedConnection
	self.completedConnection = completedConnection
	self.tween = tween
	tween:Play()
end

function v.findBasinWater()
	local map = workspace:FindFirstChild("Map")
	local child

	if map then
		child = map:FindFirstChild(frozen2.FOUNTAIN_NAME)
	end

	local child2

	if child then
		child2 = child:FindFirstChild(frozen2.FOUNTAIN_MIDDLE_NAME)
	end

	local part

	if child2 then
		part = child2:FindFirstChild(frozen2.WATER_NAME)
	end

	if part and part:IsA("BasePart") then
		return part
	end

	return nil
end

function v.applyWaterProgress(p, flag: boolean)
	local water = p.water

	if not (water and water.part.Parent and p.totalPipes > 0) then
		return
	end

	local repairProgress = v.getRepairProgress(p)
	local lerped = water.originalSize:Lerp(frozen2.WATER_FULL_SIZE, repairProgress)
	local lerped2 = water.originalCFrame:Lerp(frozen2.WATER_FULL_CFRAME, repairProgress)
	v.stopWaterTween(water)

	if flag then
		local tween = TweenService:Create(water.part, frozen2.WATER_TWEEN_INFO, {
			Size = lerped,
			CFrame = lerped2
		})
		water.tween = tween
		tween:Play()
	else
		water.part.Size = lerped
		water.part.CFrame = lerped2
	end
end

function v:resolveWater()
	local basinWater = v.findBasinWater()

	if not basinWater then
		return
	end

	local water = self.water

	if water and water.part == basinWater and basinWater.Parent then
		return
	end

	if water then
		v.stopWaterTween(water)

		if water.part.Parent then
			water.part.Size = water.originalSize
			water.part.CFrame = water.originalCFrame
		end
	end

	self.water = {
		part = basinWater,
		originalSize = basinWater.Size,
		originalCFrame = basinWater.CFrame,
		tween = nil
	}
	v.applyWaterProgress(self, false)
end

function v.resolveRipple(p, p2)
	local v5 = {}

	for _, pipe in p.pipes do
		local part = pipe.part

		if part and part.Parent == p2 then
			v5[part] = pipe.originalPivot * part.PivotOffset:Inverse()
		else
			PipeRipple.clear(p.ripple)
			return
		end
	end

	PipeRipple.resolve(p.ripple, p2, v5)
end

function v.playRepairRipple(p, p2)
	local part = p2.part

	if not (part and part.Parent) then
		return
	end

	local v5 = {}

	for _, pipe in p.pipes do
		local part2 = pipe.part

		if pipe.currentSteps ~= 0 and part2 and part2.Parent then
			v5[part2] = true
		end
	end

	PipeRipple.play(p.ripple, part, v5)
end

function v.resolvePresentation(data, p: number)
	while not data.cleaned and data.setupGeneration == p do
		local _WorldOrigin = workspace:FindFirstChild("_WorldOrigin")
		local model

		if _WorldOrigin then
			model = _WorldOrigin:FindFirstChild(frozen2.NODES_NAME)
		end

		if model and model:IsA("Model") then
			for _, part in model:GetChildren() do
				if not part:IsA("BasePart") then
					continue
				end

				local attribute = part:GetAttribute(frozen2.PIPE_ID_ATTRIBUTE)
				local v5

				if typeof(attribute) == "string" then
					v5 = data.pipes[attribute]
				end

				if not v5 or v5.part and v5.part.Parent then
					continue
				end

				v.releaseSpouts(data)
				PipeRipple.clear(data.ripple)
				v.stopPipeTween(v5)
				v.releasePipeFeedback(v5)
				v5.part = part
				part:PivotTo(v.getPipePivot(v5))
			end

			for _, pipe in data.pipes do
				v.updatePipeCollision(pipe)
			end

			v.resolveRipple(data, model)
			v.resolveSpouts(data, model)
		end

		v.resolveWater(data)
		task.wait(frozen2.RESOLVE_INTERVAL)
	end
end

function v:setupPipes(items)
	if typeof(items) ~= "table" then
		return
	end

	local state = v.getState(self)

	if state.fullyRepaired then
		return
	end

	v.releaseSpouts(state)
	v.restorePipes(state)
	v.restoreWater(state)
	state.repairedCount = 0
	state.totalPipes = 0
	state.fullyRepaired = false
	state.boatReadyAlpha = 0
	state.turnInRequested = false
	state.setupGeneration += 1
	self.Progress = 0

	for _, item in items do
		if not v.isValidSetup(item) or state.pipes[item.id] then
			continue
		end

		local v5 = {
			part = nil,
			originalPivot = item.originalPivot,
			rotationAxis = item.rotationAxis,
			radiansPerStep = item.radiansPerStep,
			currentSteps = item.currentSteps,
			maxSteps = item.maxSteps,
			revision = item.revision,
			tween = nil,
			pivotValue = nil,
			pivotConnection = nil,
			completedConnection = nil,
			feedbackHighlight = nil,
			feedbackTween = nil,
			feedbackConnection = nil
		}
		state.pipes[item.id] = v5
		state.totalPipes += 1
	end

	if state.totalPipes > 0 then
		task.spawn(v.resolvePresentation, state, state.setupGeneration)
		task.spawn(v.spawnStuckBoat, self)
	end
end

local FountainPipeRepair = {}
FountainPipeRepair.DataName = script.Name
FountainPipeRepair.Repeatable = false
FountainPipeRepair.LoadWhenCompleted = true

function FountainPipeRepair.OnLoad(p)
	v.setPipesHidden(p.Completed)

	if p.Completed or p.MiscData._debugLaunchPending then
		return
	end

	v.getState(p)
end

function FountainPipeRepair.OnComplete(p)
	v.setPipesHidden(p.Completed)
end

FountainPipeRepair.RemoteEvents = {
	PrepareDebugLaunch = function(moment, token)
		if typeof(token) ~= "number" then
			return
		end

		local v5 = v2

		if v5 then
			v2 = nil
			local boat = v5.hider.boat

			if boat and boat:IsDescendantOf(game) then
				task.spawn(v.expireDebugLaunchHandoff, v5)
				pcall(function()
					return moment:InvokeServer("DebugLaunchPrepared", token, false)
				end)
				return
			else
				v.cancelDebugLaunchPreparation(v5)
			end
		end

		moment.MiscData._debugLaunchPending = true
		local _fountainPipeRepairState = moment.MiscData._fountainPipeRepairState

		if _fountainPipeRepairState then
			_fountainPipeRepairState.turnInRequested = true
			v.suppressBoatForHandoff(_fountainPipeRepairState)
		end

		local boat

		if _fountainPipeRepairState then
			boat = _fountainPipeRepairState.boat
		end

		local v6 = {
			moment = moment,
			token = token,
			state = _fountainPipeRepairState,
			previewBoat = boat,
			previewPivot = 0,
			previewScale = 0,
			hider = 0
		}
		local previewPivot

		if boat then
			previewPivot = boat:GetPivot()
		end

		v6.previewPivot = previewPivot
		local previewScale

		if boat then
			previewScale = boat:GetScale()
		end

		v6.previewScale = previewScale
		v6.hider = v.createLaunchBoatHider(game.Players.LocalPlayer.UserId, token)
		v2 = v6
		task.delay(frozen2.DEPENDENCY_TIMEOUT + frozen2.LAUNCH_RECOVERY_TIMEOUT, function()
			if v2 ~= v6 then
				return
			end

			v2 = nil
			v.expireDebugLaunchHandoff(v6)
		end)
		fn2(v6.previewBoat)
		local success, result = pcall(function()
			return moment:InvokeServer("DebugLaunchPrepared", token, true)
		end)

		if (not success or result ~= true) and v2 == v6 then
			v2 = nil
			v.cancelDebugLaunchPreparation(v6)
		end
	end,
	DebugLaunch = function(_, value, p, model)
		if typeof(value) ~= "number" or typeof(p) ~= "boolean" then
			return
		end

		local v5 = v2

		if not v5 or v5.token ~= value then
			return
		end

		v2 = nil
		local hider = v5.hider
		task.spawn(function()
			local v6 = os.clock() + frozen2.LAUNCH_PREPARE_TIMEOUT

			if not p then
				v.releaseDebugLaunchHandoff(v5)
				return
			end

			local v7

			if typeof(model) == "Instance" and model:IsA("Model") then
				v7 = model
			end

			if v7 then
				v.hideLaunchBoat(hider, v7)
			else
				v7 = v.waitForHiddenLaunchBoat(hider, v6)
			end

			if not v7 then
				v.releaseDebugLaunchHandoff(v5)
				return
			end

			local v8 = v.waitForLaunchBoat(v7, game.Players.LocalPlayer.UserId, v6)

			if v8 then
				fn2(v5.previewBoat)

				if not v.signalLaunchReady(v7, v8, game.Players.LocalPlayer.UserId) then
					v.cancelLaunchHandoff(v5.state, hider, v7)
					return
				end

				v.releaseHandoffPreview(v5.state, v5.previewBoat)
				v.releaseLaunchBoatHider(hider)
				v.playLaunchCutscene(v7)
			else
				warn("[Fountain Pipe Repair] Debug Grand Brigade did not fully replicate before launch")
				v.cancelLaunchHandoff(v5.state, hider, v7)
			end
		end)
	end,
	Setup = function(p, p2)
		v.setupPipes(p, p2)
	end,
	PipeHit = function(p, value: string, value2: number, value3: number, value4: number, totalPipes: number)
		local state = v.getState(p)
		local v5

		if typeof(value) == "string" then
			v5 = state.pipes[value]
		end

		if not v5 or typeof(value2) ~= "number" or value2 % 1 ~= 0 or math.abs(value2) > v5.maxSteps or typeof(value3) ~= "number" or value3 % 1 ~= 0 or value3 <= v5.revision or typeof(value4) ~= "number" or value4 % 1 ~= 0 or value4 < 0 or typeof(totalPipes) ~= "number" or totalPipes % 1 ~= 0 or totalPipes ~= state.totalPipes or totalPipes < value4 or state.fullyRepaired then
			return
		end

		local repairedCount = state.repairedCount
		local v6 = v5.currentSteps == 0
		state.repairedCount = value4
		state.totalPipes = totalPipes
		state.fullyRepaired = value4 == totalPipes
		p.Progress = value4
		v.applyPipeProgress(v5, value2, value3)
		v.updateSpouts(state)
		local v7 = not v6 and value2 == 0
		local part = v5.part

		if part and part.Parent then
			sound:Play(frozen2.HIT_SOUND, part)
		end

		v.flashPipe(v5, v7)

		if v7 then
			v.playRepairRipple(state, v5)
		end

		if value4 ~= repairedCount then
			v.applyWaterProgress(state, true)
		end
	end
}
return FountainPipeRepair