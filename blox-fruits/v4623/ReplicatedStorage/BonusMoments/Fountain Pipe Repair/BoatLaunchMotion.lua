local createVector = vector.create
local Bezier = require(game.ReplicatedStorage.Util.Bezier)
local frozen = table.freeze({
	BOAT_READY_LURCH_DURATION = 0.4,
	BOAT_LAUNCH_SCALE_DURATION = 1,
	BOAT_STUCK_SCALE = 0.6,
	BOAT_ALMOST_READY_PROGRESS = 0.5,
	BOAT_ALMOST_READY_SCALE = 0.8,
	BOAT_READY_SCALE = 1,
	BOAT_LAUNCH_SCALE = 1,
	BOAT_SEAT_WATER_OFFSET = 34,
	LAUNCH_DISTANCE = 1000,
	LAUNCH_FIRST_FORWARD = 260,
	LAUNCH_SECOND_BACK = 220,
	LAUNCH_SECOND_HEIGHT = 450,
	LAUNCH_DURATION = 3.25,
	LANDING_FORWARD_DISTANCE = 180,
	LANDING_DURATION = 1.3,
	LANDING_OSCILLATION_AMPLITUDE = 37.76223776223776,
	LANDING_OSCILLATION_FREQUENCY = 11,
	LANDING_OSCILLATION_DAMPING = 2.5,
	LANDING_FINAL_FADE_ALPHA = 0.78,
	LANDING_IMPACT_PITCH = -0.24434609527920614,
	MAX_FLIGHT_PITCH = 0.4363323129985824,
	START_PIVOT_ATTRIBUTE = "FountainPipeRepairLaunchStartPivot",
	LANDING_PIVOT_ATTRIBUTE = "FountainPipeRepairLaunchLandingPivot",
	FLIGHT_STARTED_AT_ATTRIBUTE = "FountainPipeRepairFlightStartedAt",
	LAUNCH_HOLD_WELD_NAME = "FountainPipeRepairPassengerHold",
	LAUNCH_READY_EVENT_NAME = "FountainPipeRepairLaunchReady"
})
local v = {}
local v2 = {
	Config = frozen
}

function v.smoothStep(p: number)
	return p * p * (3 - p * 2)
end

function v.getFlightCurveAlpha(p: number)
	return p / (p * 0.6 + 0.4)
end

function v2.getLaunchScale(p: number)
	local v3 = math.clamp(p / frozen.BOAT_LAUNCH_SCALE_DURATION, 0, 1)
	local smoothStep2 = v.smoothStep(v3)
	return frozen.BOAT_READY_SCALE + (frozen.BOAT_LAUNCH_SCALE - frozen.BOAT_READY_SCALE) * smoothStep2
end

function v2.getPreviewScale(value: number)
	local v3 = math.clamp(value, 0, 1)

	if v3 <= frozen.BOAT_ALMOST_READY_PROGRESS then
		local v4 = v3 / frozen.BOAT_ALMOST_READY_PROGRESS
		return frozen.BOAT_STUCK_SCALE + (frozen.BOAT_ALMOST_READY_SCALE - frozen.BOAT_STUCK_SCALE) * v4
	end

	local v4 = (v3 - frozen.BOAT_ALMOST_READY_PROGRESS) / (1 - frozen.BOAT_ALMOST_READY_PROGRESS)
	return frozen.BOAT_ALMOST_READY_SCALE + (frozen.BOAT_READY_SCALE - frozen.BOAT_ALMOST_READY_SCALE) * v4
end

function v.getLandingForwardAlpha(p: number)
	local v3 = 3 * frozen.LAUNCH_SECOND_BACK * 0.4 / frozen.LAUNCH_DURATION * frozen.LANDING_DURATION / frozen.LANDING_FORWARD_DISTANCE
	local v4 = p * p
	local v5 = v4 * p
	return (math.clamp(v5 * -2 + v4 * 3 + (v5 - v4 * 2 + p) * v3, 0, 1))
end

function v2.createFlightPlan(cframe: CFrame, cframe2: CFrame)
	local lookVector = cframe2.LookVector
	local position = cframe2.Position
	local v3 = position - lookVector * frozen.LANDING_FORWARD_DISTANCE
	local v4 = frozen.LAUNCH_FIRST_FORWARD / math.max(cframe.LookVector:Dot(lookVector), 0.01)
	return {
		curve = Bezier.new({
			cframe.Position,
			cframe.Position + cframe.LookVector * v4,
			v3 - lookVector * frozen.LAUNCH_SECOND_BACK + createVector(0, 1, 0) * frozen.LAUNCH_SECOND_HEIGHT,
			v3
		}),
		impactPivot = CFrame.new(v3) * cframe2.Rotation,
		landingPivot = cframe2,
		splashCFrame = CFrame.new(v3.X, position.Y - frozen.BOAT_SEAT_WATER_OFFSET, v3.Z)
	}
end

function v2.getFlightCFrame(cframe: CFrame, p, value: number)
	local v3 = math.clamp(value, 0, 1)
	local flightCurveAlpha = v.getFlightCurveAlpha(v3)
	local deCasteljau = p.curve:DeCasteljau(flightCurveAlpha)
	local derivative = p.curve:GetDerivative(flightCurveAlpha)
	local magnitude = Vector3.new(derivative.X, 0, derivative.Z).Magnitude
	local v4 = math.clamp(math.atan2(derivative.Y, magnitude), -frozen.MAX_FLIGHT_PITCH, frozen.MAX_FLIGHT_PITCH)

	if flightCurveAlpha > 0.86 then
		local v5 = math.clamp((flightCurveAlpha - 0.86) / 0.14, 0, 1)
		local smoothStep2 = v.smoothStep(v5)
		v4 += (frozen.LANDING_IMPACT_PITCH - v4) * smoothStep2
	end

	local v5 = p.impactPivot.Rotation * CFrame.Angles(v4, 0, 0)
	local smoothStep2 = v.smoothStep((math.clamp(flightCurveAlpha / 0.12, 0, 1)))
	local lerped = cframe.Rotation:Lerp(v5, smoothStep2)
	return CFrame.new(deCasteljau) * lerped, derivative
end

function v2.getLandingCFrame(p, value: number)
	local v3 = math.clamp(value, 0, frozen.LANDING_DURATION)
	local v4 = v3 / frozen.LANDING_DURATION
	local v5 = math.clamp((v4 - frozen.LANDING_FINAL_FADE_ALPHA) / (1 - frozen.LANDING_FINAL_FADE_ALPHA), 0, 1)
	local v6 = math.exp(-frozen.LANDING_OSCILLATION_DAMPING * v3) * (1 - v.smoothStep(v5))
	local v7 = frozen.LANDING_OSCILLATION_FREQUENCY * v3
	local v8 = -frozen.LANDING_OSCILLATION_AMPLITUDE * v6 * math.sin(v7)
	local v9 = math.cos(v7) + frozen.LANDING_OSCILLATION_DAMPING / frozen.LANDING_OSCILLATION_FREQUENCY * math.sin(v7)
	local v10 = frozen.LANDING_IMPACT_PITCH * v6 * v9
	local v11 = frozen.LANDING_FORWARD_DISTANCE * v.getLandingForwardAlpha(v4)
	local v12 = p.impactPivot.Position + p.landingPivot.LookVector * v11 + createVector(0, 1, 0) * v8
	return CFrame.new(v12) * p.landingPivot.Rotation * CFrame.Angles(v10, 0, 0)
end

return table.freeze(v2)