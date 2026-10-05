local createVector = vector.create
local BoidHelper = require(script.BoidHelper)
local directions = BoidHelper.GetDirections(10)

local function clamp_magnitude(vector2: Vector3, p: number, p2: number)
	local magnitude = vector2.Magnitude

	if p2 < magnitude then
		return vector2.Unit * p2
	end

	if magnitude < p then
		return vector2.Unit * p
	end

	return vector2
end

local function isnan(p: number)
	return p ~= p
end

local function isnan_vec3(vector2: Vector3)
	local X = vector2.X
	local v = X ~= X

	if v then
		return v
	end

	local Y = vector2.Y
	v = Y ~= Y

	if not v then
		local Z = vector2.Z
		return Z ~= Z
	end

	return v
end

local v = {
	__index = {
		_SteerTowards = function(self, p2, vector2: Vector3)
			local v2 = vector2.Unit * self.MAX_SPEED - p2._Velocity
			local MAX_STEER_FORCE = self.MAX_STEER_FORCE
			local magnitude = v2.Magnitude

			if MAX_STEER_FORCE < magnitude then
				return v2.Unit * MAX_STEER_FORCE
			end

			if magnitude < 0 then
				return v2.Unit * 0
			end

			return v2
		end,
		AddBoid = function(p, p2)
			p._Boids[p2._Instance] = p2
		end,
		RemoveBoid = function(p, p2)
			p._Boids[p2._Instance] = nil
		end,
		GetBoids = function(p)
			local _Boids = {}

			for _, _Boid in pairs(p._Boids) do
				_Boids[#_Boids + 1] = _Boid
			end

			return _Boids
		end,
		Step = function(self, p: number)
			local raycastParams = self.RaycastParams
			local targetPosition = self.TargetPosition
			local neighborOcclusionChecking = self.NeighborOcclusionChecking
			local vector2 = Vector3.new()
			local count = 0

			for k, _Boid in pairs(self._Boids) do
				count += 1
				local v2 = createVector(0, 0, 0)
				local v3 = createVector(0, 0, 0)
				local v4 = createVector(0, 0, 0)
				local count2 = 0

				for k2, _Boid2 in pairs(self._Boids) do
					if k == k2 then
						continue
					end

					local v5 = _Boid2._Position - _Boid._Position
					local magnitude = v5.Magnitude

					if self.NEIGHBOR_DIST < magnitude then
						continue
					end

					local v6

					if neighborOcclusionChecking then
						v6 = workspace:Raycast(_Boid._Position, v5, raycastParams)
					end

					if v6 then
						continue
					end

					if magnitude <= self.CROWDING_DIST then
						v2 -= v5 / magnitude
					end

					v3 += _Boid2._Position
					v4 += _Boid2._Velocity
					count2 += 1
				end

				if targetPosition then
					local v5 = targetPosition - _Boid._Position
					local _ = v5.Magnitude
					local v6 = self:_SteerTowards(_Boid, v5.Unit) / (count2 + 1) * self.TARGET_WEIGHT
					local X = v6.X
					local v7 = X ~= X

					if not v7 then
						local Y = v6.Y
						v7 = Y ~= Y

						if not v7 then
							local Z = v6.Z
							v7 = Z ~= Z
						end
					end

					if not v7 then
						_Boid._Acceleration += v6
					end
				end

				local pivot = _Boid._Instance:GetPivot()

				if workspace:Raycast(_Boid._Position, pivot.LookVector * self.RAY_LENGTH, raycastParams) then
					local v5 = nil

					for i = 1, #directions do
						local vectorToWorldSpace = pivot:VectorToWorldSpace(directions[i])
						local v6 = vectorToWorldSpace * self.RAY_LENGTH
						local raycastResult = workspace:Raycast(_Boid._Position, v6, raycastParams)

						if raycastResult and raycastResult.Instance then
							continue
						end

						v5 = vectorToWorldSpace
						break
					end

					if v5 then
						local v6 = self:_SteerTowards(_Boid, v5) * self.AVOIDANCE_WEIGHT
						_Boid._Acceleration += v6
					end
				end

				if count2 > 0 then
					local v5 = v3 / count2
					local v6 = v4 / count2
					local v7 = v5 - _Boid._Position
					local v8 = self:_SteerTowards(_Boid, v6) * self.ALIGN_WEIGHT
					local v9 = self:_SteerTowards(_Boid, v7) * self.COHESION_WEIGHT
					local v10 = self:_SteerTowards(_Boid, v2) * self.SEPARATE_WEIGHT
					local X = v8.X
					local v11 = X ~= X

					if not v11 then
						local Y = v8.Y
						v11 = Y ~= Y

						if not v11 then
							local Z = v8.Z
							v11 = Z ~= Z
						end
					end

					if not v11 then
						_Boid._Acceleration += v8
					end

					local X2 = v9.X
					local v12 = X2 ~= X2

					if not v12 then
						local Y = v9.Y
						v12 = Y ~= Y

						if not v12 then
							local Z = v9.Z
							v12 = Z ~= Z
						end
					end

					if not v12 then
						_Boid._Acceleration += v9
					end

					local X3 = v10.X
					local v13 = X3 ~= X3

					if not v13 then
						local Y = v10.Y
						v13 = Y ~= Y

						if not v13 then
							local Z = v10.Z
							v13 = Z ~= Z
						end
					end

					if not v13 and v2.Magnitude > 0.01 then
						_Boid._Acceleration += v10
					end
				end

				_Boid._Velocity += _Boid._Acceleration * p
				local _Velocity = _Boid._Velocity
				local MIN_SPEED = self.MIN_SPEED
				local MAX_SPEED = self.MAX_SPEED
				local magnitude = _Velocity.Magnitude

				if MAX_SPEED < magnitude then
					_Velocity = _Velocity.Unit * MAX_SPEED
				elseif magnitude < MIN_SPEED then
					_Velocity = _Velocity.Unit * MIN_SPEED
				end

				_Boid._Velocity = _Velocity
				_Boid._Position += _Boid._Velocity * p
				local cframe = CFrame.lookAt(_Boid._Position, _Boid._Position + _Boid._Velocity)
				_Boid._Instance:PivotTo(cframe)
				vector2 += cframe.Position
			end

			self._AveragePosition = vector2 / count
		end
	}
}
local Boid = {}

function Boid.new()
	return (setmetatable({
		_Boids = {},
		_AveragePosition = nil,
		NeighborOcclusionChecking = false,
		TargetPosition = nil,
		RaycastParams = nil,
		MAX_SPEED = 20,
		MIN_SPEED = 1,
		RAY_LENGTH = 5,
		NEIGHBOR_DIST = 10,
		CROWDING_DIST = 4,
		MAX_STEER_FORCE = 10,
		ALIGN_WEIGHT = 1,
		COHESION_WEIGHT = 0.1,
		TARGET_WEIGHT = 0.2,
		SEPARATE_WEIGHT = 1,
		AVOIDANCE_WEIGHT = 100
	}, v))
end

function Boid.CreateBoid(instance)
	return {
		_Instance = instance,
		_Position = instance:GetPivot().Position,
		_Velocity = createVector(0, 0, 1),
		_Acceleration = createVector(0, 0, 0)
	}
end

return Boid