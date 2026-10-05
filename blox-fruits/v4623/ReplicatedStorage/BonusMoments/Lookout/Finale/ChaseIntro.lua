local createVector = vector.create
local RunService = game:GetService("RunService")
local BoatPresentation = require(script.Parent.Parent.BoatPresentation)
local CharacterPresentation = require(script.Parent.Parent.CharacterPresentation)
local Ship = require(script.Parent.Parent.Observation.Ship)
local CutsceneDialogue = require(script.Parent.CutsceneDialogue)
local FailureTemplates = require(script.Parent.FailureTemplates)
local Timing = require(script.Parent.Timing)
require(script.Parent.Types)
local frozen = table.freeze({
	CameraDistance = 260,
	CameraHeight = 45,
	CameraTargetHeight = 12,
	FailureCameraTargetHeight = 8,
	FailureFieldOfView = 21,
	TravelDistance = 1400,
	PirateStartOffsets = { 600, 520, 600 },
	PirateDepthOffsets = { -65, 0, 65 },
	MarineStartOffset = 950,
	MarineDepthOffset = 0,
	PirateTemplate = "PirateBrigade",
	MarineTemplate = "MarineGrandBrigade",
	MarineSailColor = "White",
	PirateVerticalOffset = 0,
	MarineVerticalOffset = -15,
	DriverRootHeight = 2,
	DoghouseChaseDrop = 1.5,
	SmugglerFaceId = "255535022429711"
})

local function unitCFrame(data, value: number, vector2: Vector3)
	local v2 = data.StartPosition + (data.EndPosition - data.StartPosition) * value
	local v3 = math.sin(math.clamp(value, 0, 1) * 3.141592653589793)
	local v4 = math.sin(value * 3.141592653589793 * 5 + data.Phase) * 0.04363323129985824 * v3
	local v5 = math.sin(value * 3.141592653589793 * 4 + data.Phase) * 0.08726646259971647 * v3
	local v6 = math.sin(value * 3.141592653589793 * 7 + data.Phase) * 0.8
	local v7 = v2 + createVector(0, 1, 0) * v6
	return CFrame.lookAt(v7, v7 + vector2) * CFrame.Angles(v4, 0, v5)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateUnit(data, p: number, vector2: Vector3)
	local v2 = unitCFrame(data, p, vector2)
	data.Boat:PivotTo(v2)

	if data.Pilot and data.DriverSeatOffset and data.PilotTransform then
		data.Pilot:PivotTo(v2 * data.DriverSeatOffset * data.PilotTransform)
	end
end

local function spawnUnit(parent, p, p2: string, p3: string, startPosition: Vector3, endPosition: Vector3, phase: number, chaseDuration: number, p4: number, vector2: Vector3, p5, p6: string?)
	local namedFromCache, v2 = BoatPresentation.cloneNamedFromCache(p, p2, p3, "Observation")

	if not namedFromCache then
		return nil, v2
	end

	local driverSeatOffset = BoatPresentation.getDriverSeatOffset(namedFromCache)
	local clone

	if p6 then
		if not driverSeatOffset then
			namedFromCache:Destroy()
			return nil, (`{p2} has no driver-seat transform`)
		end

		clone = CharacterPresentation.clone(p6, p5)

		if p6 == "Pirate" then
			CharacterPresentation.setFace(clone, frozen.SmugglerFaceId)
		end
	end

	local pilotTransform

	if p6 == "Doghouse" then
		pilotTransform = CFrame.new(0, frozen.DriverRootHeight - frozen.DoghouseChaseDrop, 0) * CFrame.Angles(
			0,
			3.141592653589793,
			0
		)
	else
		pilotTransform = CFrame.new(0, frozen.DriverRootHeight, 0)
	end

	local v3 = {
		Boat = namedFromCache,
		Pilot = clone,
		DriverSeatOffset = driverSeatOffset,
		PilotTransform = pilotTransform,
		StartPosition = startPosition,
		EndPosition = endPosition,
		Phase = phase,
		Duration = chaseDuration
	}
	updateUnit(v3, 0, vector2) -- equivalent call inferred; original call site unknown
	namedFromCache.Parent = parent

	if clone then
		clone.Parent = parent

		if not CharacterPresentation.playDriverIdle(clone) then
			warn("[Lookout] A chase pilot could not play the steering idle")
		end
	end

	local _, v5 = Ship.createWake(namedFromCache, p4)

	if not v5 then
		return v3, nil
	end

	namedFromCache:Destroy()

	if clone then
		clone:Destroy()
	end

	return nil, v5
end

local function advanceUnits(data, items, total: number, p: number, vector2: Vector3)
	local currentDialogueBeat = data.currentDialogueBeat()

	while total < p and data.canContinue(currentDialogueBeat) do
		total += RunService.Heartbeat:Wait()

		for _, item in items do
			updateUnit(item, total / item.Duration, vector2) -- equivalent call inferred; original call site unknown
		end
	end

	if not data.isLive() then
		return total, false
	end

	for _, item in items do
		updateUnit(item, p / item.Duration, vector2) -- equivalent call inferred; original call site unknown
	end

	return p, true
end

return table.freeze({
	run = function(data, instance, p, object, vector2: Vector3, vector3: Vector3, vector4: Vector3, p2: string, p3, p4, p5)
		local v2 = vector2 - vector3 * frozen.CameraDistance + createVector(0, 1, 0) * frozen.CameraHeight
		local v3 = vector2 + createVector(0, 1, 0) * frozen.CameraTargetHeight
		object:TeleportTo(CFrame.lookAt(v2, v3))
		CutsceneDialogue.hide()

		if not data.wait(Timing.Shared.PreChaseSeaHoldTime) then
			return false, nil
		end

		local v4 = {}
		local v5 = -vector4
		local v6

		if p3 == "Failure" then
			v6 = FailureTemplates.get(assert(p4))
		end

		local v7 = not v6 and "Pirate" or v6.ActorRole
		local v8 = nil

		for _, v9 in p3 == "Failure" and { 2 } or { 1, 2, 3 } do
			local pirateStartOffset = frozen.PirateStartOffsets[v9]
			local pirateDepthOffset = frozen.PirateDepthOffsets[v9]
			local startPosition = vector2 + vector4 * pirateStartOffset + vector3 * pirateDepthOffset + createVector(
				0,
				1,
				0
			) * frozen.PirateVerticalOffset
			local endPosition = startPosition + v5 * frozen.TravelDistance
			local v12, v13 = spawnUnit(
				instance,
				p,
				frozen.PirateTemplate,
				p2,
				startPosition,
				endPosition,
				v9 * 1.7,
				Timing.Shared.ChaseDuration,
				frozen.PirateVerticalOffset,
				v5,
				p5,
				v7
			)

			if not v12 then
				return false, v13
			end

			table.insert(v4, v12)

			if p3 == "Failure" then
				v8 = v12
			end
		end

		local startPosition2 = vector2 + vector4 * frozen.MarineStartOffset + vector3 * frozen.MarineDepthOffset + createVector(
			0,
			1,
			0
		) * frozen.MarineVerticalOffset
		local endPosition2 = startPosition2 + v5 * frozen.TravelDistance
		local v11, v12 = spawnUnit(
			instance,
			p,
			frozen.MarineTemplate,
			frozen.MarineSailColor,
			startPosition2,
			endPosition2,
			0.4,
			Timing.Shared.ChaseDuration,
			frozen.MarineVerticalOffset,
			v5,
			p5,
			nil
		)

		if not v11 then
			return false, v12
		end

		table.insert(v4, v11)
		local fieldOfView = workspace.CurrentCamera.FieldOfView
		CutsceneDialogue.showChaseShout(data)
		local v13 = 0
		local v14 = nil

		if p3 == "Failure" then
			local v15, v16 = advanceUnits(data, v4, v13, Timing.Failure.ChaseReplyDelay, v5)

			if not v16 then
				return false, nil
			end

			CutsceneDialogue.showFailureChaseReply(data, assert(p4))

			if v8 then
				v14 = object:SetCameraTarget(function()
					return v8.Boat:GetPivot().Position + createVector(0, 1, 0) * frozen.FailureCameraTargetHeight
				end)
				v14:SetPositionLocked(true)
				v14:SetTrackingSpring(1, Timing.Failure.ChaseCameraTrackingFrequency)
				object.Animations:AnimateFieldOfView(
					frozen.FailureFieldOfView,
					1,
					Timing.Failure.ChaseFieldOfViewInFrequency
				)
			end

			local v17
			v13, v17 = advanceUnits(
				data,
				v4,
				v15,
				Timing.Failure.ChaseReplyDelay + Timing.Failure.LookoutConcernDelay,
				v5
			)

			if not v17 then
				return false, nil
			end

			CutsceneDialogue.showLookoutConcern(data)
		end

		local v15, v16 = advanceUnits(data, v4, v13, Timing.Shared.ChaseDuration, v5)
		local v17 = v15

		if not v16 then
			return false, nil
		end

		local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			if not (data.isLive() and instance:IsDescendantOf(workspace)) then
				return
			end

			v17 += dt

			for _, v18 in v4 do
				updateUnit(v18, v17 / v18.Duration, v5) -- equivalent call inferred; original call site unknown
			end
		end)
		data.giveConnection(renderSteppedConnection)

		if v14 then
			object:ClearCameraTarget()
			object.Animations:AnimateFieldOfView(fieldOfView, 1, Timing.Failure.ChaseFieldOfViewOutFrequency)
		end

		CutsceneDialogue.hide()
		return data.isLive(), nil
	end
})