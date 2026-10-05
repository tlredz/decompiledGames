local createVector = vector.create
local MovementModel = {}

local function angle(vector2, p)
	return (math.deg((math.atan2(vector2:Cross(p).Magnitude, (vector2:Dot(p))))))
end

local function disarm(p)
	p.armed = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearTravel(state)
	table.clear(state.travelHistory)
	state.travelClock = 0
	state.requestUntil = nil
end

local function rememberTravel(state, unit, p, p2, p3, data, p4)
	state.travelClock += p3
	local touchTurnInputGrace = p4 and data.Dash.TouchTurnInputGrace or data.Dash.TurnInputGrace
	local v = state.travelClock - (touchTurnInputGrace or 0.2)

	while #state.travelHistory > 0 and state.travelHistory[1].at < v do
		table.remove(state.travelHistory, 1)
	end

	local v2 = p or state.outputDirection * p2
	local vector2 = Vector3.new(v2.X, 0, v2.Z)

	if unit.Magnitude > data.InputDeadzone and data.StopThreshold < p2 and vector2.Magnitude > data.StopThreshold then
		table.insert(state.travelHistory, {
			at = state.travelClock,
			direction = unit,
			speed = math.min(p2, vector2.Magnitude, data.MaxSpeed)
		})
	end
end

local function redirectsTravel(state, unit, data, p)
	local v = math.cos((math.rad(p and data.Dash.TouchMinIntentAngle or data.Dash.MinIntentAngle or data.Dash.MinTurnAngle or 90)))

	for i = #state.travelHistory, 1, -1 do
		local v2 = state.travelHistory[i]
		local dot = v2.direction:Dot(unit)

		if not (dot <= v + 0.00001) then
			continue
		end

		local v3 = unit - v2.direction * math.max(0, dot)

		if v3.Magnitude > 0.01 then
			return true, v2.direction, v2.speed, v3.Unit
		end
	end

	return false
end

function MovementModel.new()
	return {
		speed = 0,
		direction = createVector(0, 0, 0),
		stalled = 0,
		mode = "Idle",
		turnAngle = 0,
		cooldown = 0,
		recoveryRemaining = 0,
		boostStart = 0,
		boostExit = 0,
		boostLift = 0,
		dashRemaining = 0,
		dashElapsed = 0,
		dashPeak = 0,
		dashExit = 0,
		dashDirection = createVector(0, 0, 0),
		dashFromDirection = createVector(0, 0, 0),
		dashCount = 0,
		lastDashDistance = 0,
		lastDashEntrySpeed = 0,
		outputSpeed = 0,
		outputDirection = createVector(0, 0, 0),
		armed = false,
		entrySpeed = 0,
		travelHistory = {},
		travelClock = 0
	}
end

function MovementModel:suspend(p)
	self.cooldown = math.max(0, self.cooldown - p)
	self.recoveryRemaining = math.max(0, self.recoveryRemaining - p)
	self.speed = 0
	self.direction = createVector(0, 0, 0)
	self.dashRemaining = 0
	self.outputSpeed = 0
	self.outputDirection = createVector(0, 0, 0)
	self.mode = "Idle"
	clearTravel(self) -- equivalent call inferred; original call site unknown
	self.armed = false
end

local function burst(state, p, dash)
	local dashElapsed = state.dashElapsed
	local v = math.min(p, dash.Duration - dashElapsed)
	local dashElapsed2 = dashElapsed + v

	-- equivalent calls inferred from this helper; original call sites unknown
	local function distance(p2)
		return state.dashPeak * p2 + (state.dashExit - state.dashPeak) * p2 * p2 / (2 * dash.Duration)
	end

	local v3 = distance(dashElapsed2) - distance(dashElapsed)
	state.outputSpeed = p > 0 and (v3 + state.speed * (p - v)) / p or state.dashPeak
	state.outputDirection = state.dashDirection
	state.direction = state.dashDirection
	state.dashElapsed = dashElapsed2
	state.dashRemaining = math.max(0, dash.Duration - dashElapsed2)
	state.mode = "Dashing"
end

local function boost(state, p, dash)
	local v = math.min(p, dash.Duration - state.dashElapsed)
	local dashElapsed = state.dashElapsed
	local dashElapsed2 = dashElapsed + v

	-- equivalent calls inferred from this helper; original call sites unknown
	local function distance(p2)
		local v3 = p2 / dash.Duration
		return dash.Duration * (state.boostStart * v3 + (state.boostExit - state.boostStart) * v3 * v3 / 2 + state.boostLift * (3 * v3 * v3 - 2 * v3 * v3 * v3))
	end

	local v3 = distance(dashElapsed2) -- equivalent call inferred; original call site unknown
	local v4 = v3 - distance(dashElapsed)
	state.outputSpeed = p > 0 and (v4 + state.boostExit * (p - v)) / p or state.boostStart
	state.outputDirection = state.dashDirection
	state.direction = state.dashDirection
	state.dashElapsed = dashElapsed2
	state.dashRemaining = math.max(0, dash.Duration - dashElapsed2)
	state.mode = "Boosting"

	if state.dashRemaining <= 1e-6 then
		state.dashRemaining = 0
		state.speed = state.boostExit
		state.recoveryRemaining = math.max(0, dash.RecoveryDuration - (p - v))
	end
end

function MovementModel.canBoost(data, p, p2)
	local enabled = p.Dash.Enabled

	if enabled then
		if p2 == false or not (data.cooldown <= 0.00001 and data.recoveryRemaining <= 0.00001) then
			enabled = false
		else
			enabled = data.dashRemaining <= 0.00001
		end
	end

	return enabled
end

function MovementModel:step(p, p2, value, data, p3, _, value2, p4, p5, p6)
	local v = math.max(value, 0)
	local v2 = math.clamp(value, 0, 0.1)
	local v3 = p3 ~= false
	self.cooldown = math.max(0, self.cooldown - v2)
	self.recoveryRemaining = math.max(0, self.recoveryRemaining - v2)
	local dash = data.Dash
	local vector2 = Vector3.new(p.X, 0, p.Z)
	local v4 = vector2.Magnitude > data.InputDeadzone
	local unit = v4 and vector2.Unit or createVector(0, 0, 0)

	if not dash.Enabled then
		self.dashRemaining = 0
		self.recoveryRemaining = 0
		self.armed = false
	end

	if not v3 then
		self.dashRemaining = 0
		self.armed = false
	end

	if dash.Enabled and v3 and self.dashRemaining <= 0 then
		rememberTravel(self, unit, p5, p2, v, data, p6)
	else
		clearTravel(self) -- equivalent call inferred; original call site unknown
	end

	if self.dashRemaining > 0 then
		if dash.Mode == "RunBoost" then
			boost(self, v2, dash)
			return self
		end

		burst(self, v2, dash)
		return self
	else
		local v5 = false
		local dashFromDirection = nil
		local v7 = nil
		local dashDirection = nil
		local canBoost = MovementModel.canBoost(self, data, v3)

		if p4 == true and canBoost then
			local touchInputBuffer = p6 and dash.TouchInputBuffer or dash.InputBuffer
			self.requestUntil = self.travelClock + (touchInputBuffer or 0)
		end

		if self.requestUntil and (self.travelClock > self.requestUntil or not canBoost) then
			self.requestUntil = nil
		end

		if self.requestUntil and v4 and data.StopThreshold < p2 and canBoost then
			v5, dashFromDirection, v7, dashDirection = redirectsTravel(self, unit, data, p6)
		end

		local entrySpeed = math.clamp(math.min(self.speed, p2), 0, data.MaxSpeed)

		if v5 then
			if dash.ScaleDistanceWithSpeed then
				entrySpeed = v7 or entrySpeed
			end

			self.entrySpeed = entrySpeed
		end

		self.turnAngle = 0

		if v4 and data.TurnRate and self.direction.Magnitude > 0.01 and self.speed > data.StopThreshold then
			local v10 = math.clamp(self.speed / data.MaxSpeed, 0, 1)
			local v11 = (data.SlowTurnRate or data.TurnRate) + (data.TurnRate - (data.SlowTurnRate or data.TurnRate)) * v10
			local v12 = math.atan2(self.direction:Cross(unit).Y, (self.direction:Dot(unit)))
			local v13 = math.rad(v11) * v2
			unit = CFrame.Angles(0, math.clamp(v12, -v13, v13), 0):VectorToWorldSpace(self.direction)
		end

		if v4 then
			if self.direction.Magnitude > 0 and self.speed > data.StopThreshold then
				local direction = self.direction
				self.turnAngle = math.deg((math.atan2(direction:Cross(unit).Magnitude, (direction:Dot(unit)))))
				self.speed *= data.TurnRetention90 ^ (self.turnAngle / 90)
			end

			self.direction = unit
			local v10 = data.MaxSpeed * math.clamp(value2 or 1, 0.1, 1)

			if self.recoveryRemaining > 0 then
				v10 *= dash.RecoverySpeedRatio
			end

			if v10 < self.speed then
				self.speed = math.max(v10, self.speed - data.Deceleration * v2)
			else
				self.speed = math.min(v10, self.speed + data.Acceleration * v2)
			end

			if p2 < data.StallSpeed then
				self.stalled += v2

				if self.stalled >= data.StallGrace then
					self.speed = math.min(self.speed, data.StallSpeedCap)
					self.armed = false
				end
			else
				self.stalled = 0
			end

			self.mode = self.recoveryRemaining > 0 and "Recovering" or self.turnAngle >= 20 and "Turning" or self.speed >= data.MaxSpeed * 0.9 and "Running" or "Accelerating"
		else
			self.stalled = 0
			self.speed = math.max(0, self.speed - data.Deceleration * v2)
			self.mode = "Braking"
		end

		if self.speed <= data.StopThreshold then
			self.speed = 0

			if not v4 then
				self.direction = createVector(0, 0, 0)
				self.mode = "Idle"
				self.armed = false
			end
		end

		self.outputSpeed = self.speed
		self.outputDirection = self.direction

		if v5 then
			local v10 = not dash.ScaleDistanceWithSpeed and 1 or math.clamp(self.entrySpeed / data.MaxSpeed, 0, 1) or 1
			local lastDashDistance = dash.Distance * v10
			self.lastDashEntrySpeed = self.entrySpeed
			self.lastDashDistance = lastDashDistance
			self.dashExit = math.min(self.speed, lastDashDistance / dash.Duration)
			self.speed = self.dashExit
			self.dashPeak = 2 * lastDashDistance / dash.Duration - self.dashExit
			self.dashDirection = dashDirection
			self.dashFromDirection = dashFromDirection
			self.dashElapsed = 0
			self.dashRemaining = dash.Duration
			self.cooldown = dash.Cooldown
			self.dashCount += 1
			clearTravel(self) -- equivalent call inferred; original call site unknown
			self.armed = false

			if dash.Mode == "RunBoost" then
				self.boostStart = math.min(self.entrySpeed, data.MaxSpeed)
				self.boostExit = data.MaxSpeed * v10 * math.clamp(value2 or 1, 0.1, 1) * dash.BoostExitSpeedRatio
				self.boostLift = lastDashDistance / dash.Duration - (self.boostStart + self.boostExit) / 2
				boost(self, v2, dash)
			else
				burst(self, v2, dash)
			end
		end

		self.armed = MovementModel.canBoost(self, data, v3)
		return self
	end
end

return MovementModel