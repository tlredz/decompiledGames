local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Component = require(ReplicatedStorage.Packages.Component)
local Janitor = require(ReplicatedStorage.Packages.Janitor)
local v = Component.new({
	Tag = "SledVehicle2",
	Extensions = {
		{
			ShouldConstruct = function(p)
				return p.Instance:WaitForChild("PlayerObject").Value == Players.LocalPlayer
			end
		}
	}
})
local _ = workspace.Gravity * 0.5

function v:Construct()
	self._Janitor = Janitor.new()
	self.sledDisableUntil = 0
	self._airWalkLocked = false
	self._jumpRequested = false
end

function v:GetFloorSurfaceAngle(object)
	local vectorToObjectSpace = self.collider.CFrame:VectorToObjectSpace(self.hrp.AssemblyLinearVelocity)
	local halfBoundSize = self.boundSize / 2
	local position = (self.collider.CFrame * CFrame.new(
		math.clamp(vectorToObjectSpace.X, -halfBoundSize.X, halfBoundSize.X),
		0,
		(math.clamp(vectorToObjectSpace.Z, -halfBoundSize.Z, halfBoundSize.Z))
	)).Position
	local raycastResult = workspace:Raycast(position, -self.middle.CFrame.UpVector * 10, self.rcParams)

	if not raycastResult then
		return nil
	end

	if object then
		return
			math.deg(((self.hrp.Position - object:GetClosestPointOnSurface(self.hrp.Position)).Unit:Angle(createVector(
				0,
				1,
				0
			)))),
			raycastResult
	end

	return math.deg((raycastResult.Normal:Angle(createVector(0, 1, 0)))), raycastResult
end

function v:BeginSleddingOnSlope(slopePart)
	if self.sledDisableUntil and os.clock() < self.sledDisableUntil then
		return
	end

	self.slopePart = slopePart
	local attachment = self._Janitor:Add(Instance.new("Attachment"), nil, "SledAttachment")
	attachment.Name = "SledAttachment"
	attachment.CFrame = CFrame.Angles(0, -0.29670597283903605, 0)
	attachment.Parent = self.hrp
	local v3 = self._Janitor:Add(Instance.new("AlignOrientation"), nil, "Orient")
	v3.Mode = Enum.OrientationAlignmentMode.OneAttachment
	v3.Attachment0 = attachment
	v3.Responsiveness = 200
	v3.MaxTorque = 1000
	v3.MaxAngularVelocity = 1000
	v3.Parent = self.hrp
	local v4 = self._Janitor:Add(Instance.new("LinearVelocity"), nil, "Velocity")
	v4.ForceLimitsEnabled = false
	v4.Attachment0 = attachment
	v4.Parent = self.hrp
	local vector2 = Vector3.new(0, -workspace.Gravity / 2.5, 0)
	local vector3 = Vector3.new(0, -workspace.Gravity / 3, 0)
	local v5 = math.max(self.boundSize.Magnitude * 0.5, 6)
	local v6 = math.max(self.boundSize.X * 0.6, 5)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function safeUnit(vector4: Vector3?, vector5: Vector3?)
		if vector4 and vector4.Magnitude >= 0.0001 then
			return vector4.Unit
		end

		if vector5 and vector5.Magnitude >= 0.0001 then
			return vector5.Unit
		end

		return createVector(0, 0, -1)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function projectOntoPlane(vector4: Vector3, lastNormal: Vector3)
		if lastNormal.Magnitude < 0.0001 then
			return vector4
		end

		local unit = lastNormal.Unit
		return vector4 - unit * vector4:Dot(unit)
	end

	local function reflect(vector4: Vector3, vector5: Vector3)
		if vector5.Magnitude < 0.0001 then
			return vector4
		end

		local unit = vector5.Unit
		return vector4 - unit * (2 * vector4:Dot(unit))
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function applyDrag(vector4: Vector3, p: number, p2: number)
		return vector4 - vector4 * math.min(p * p2, 0.95)
	end

	local function computeSteerAlpha(p: number, p2: number, p3: number, max: number)
		return (math.clamp(1 - math.exp(-(p * math.clamp(p2 / 1326, 0.05, 1)) * p3), 0, max))
	end

	local function buildOrientationCFrame(position: Vector3, forwardVector: Vector3, vector4: Vector3)
		local DISTANCE_EPSILON = 0.0001
		local vector5 = safeUnit(forwardVector, self.middle.CFrame.LookVector) -- equivalent call inferred; original call site unknown
		local unit

		if vector4 and vector4.Magnitude >= DISTANCE_EPSILON then
			unit = vector4.Unit
		else
			unit = not ((createVector(0, 1, 0)).Magnitude >= DISTANCE_EPSILON) and createVector(0, 0, -1) or (createVector(
				0,
				1,
				0
			)).Unit
		end

		if math.abs((vector5:Dot(unit))) > 0.98 then
			if not (vector5.Magnitude < DISTANCE_EPSILON) then
				local unit2 = vector5.Unit
				unit -= unit2 * unit:Dot(unit2)
			end

			if unit and unit.Magnitude >= DISTANCE_EPSILON then
				unit = unit.Unit
			else
				unit = not ((createVector(0, 1, 0)).Magnitude >= DISTANCE_EPSILON) and createVector(0, 0, -1) or (createVector(
					0,
					1,
					0
				)).Unit
			end
		end

		return CFrame.lookAt(position, position + vector5, unit)
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function smoothVector(vector4: Vector3, vector5: Vector3, p: number, p2: number)
		if p <= 0 then
			return vector5
		end

		return vector4:Lerp(vector5, (math.clamp(p * p2, 0, 1)))
	end

	local v7 = {
		Vector3.new(self.boundSize.X * 0.1, 0, 0),
		Vector3.new(-self.boundSize.X * 0.1, 0, 0),
		Vector3.new(0, 0, self.boundSize.Z * 0.1),
		Vector3.new(0, self.boundSize.Y * 0.1, 0),
		(Vector3.new(0, -self.boundSize.Y * 0.1, 0))
	}
	local raycastResults = {}

	local function multiRaycastWall(vector4: Vector3, p: number)
		table.clear(raycastResults)
		local v8 = 1e999
		local v9 = nil

		for _, v10 in ipairs(v7) do
			local v11 = self.middle.Position + self.middle.CFrame:VectorToWorldSpace(v10)
			local raycastResult = workspace:Raycast(v11, vector4 * p, self.rcParams)

			if not raycastResult then
				continue
			end

			table.insert(raycastResults, raycastResult)
			local magnitude = (raycastResult.Position - v11).Magnitude

			if not (magnitude < v8) then
				continue
			end

			v9 = raycastResult
			v8 = magnitude
		end

		return v9, raycastResults
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function averageNormal(list)
		if not list or #list == 0 then
			return nil
		end

		local v8 = createVector(0, 0, 0)

		for _, v9 in ipairs(list) do
			v8 += v9.Normal
		end

		if v8.Magnitude < 0.001 then
			return nil
		end

		return v8.Unit
	end

	local assemblyLinearVelocity = self.hrp.AssemblyLinearVelocity

	if assemblyLinearVelocity.Magnitude < 0.5 and self.humanoid then
		assemblyLinearVelocity = self.humanoid.MoveDirection * self.humanoid.WalkSpeed
	end

	local lookVector = self.middle.CFrame.LookVector
	local forwardVector2

	if lookVector and lookVector.Magnitude >= 0.0001 then
		forwardVector2 = lookVector.Unit
	else
		forwardVector2 = not ((createVector(0, 0, -1)).Magnitude >= 0.0001) and createVector(0, 0, -1) or (createVector(
			0,
			0,
			-1
		)).Unit
	end

	local v8 = {
		velocity = assemblyLinearVelocity,
		onGround = false,
		lastNormal = createVector(0, 1, 0),
		forwardVector = forwardVector2,
		upVector = createVector(0, 1, 0),
		forwardLockTimer = 0,
		lastSlopeAngle = 0,
		slopeBlendTime = 0,
		rampSnapTimer = 0,
		wallContactTimer = 0,
		jumpCooldown = 0,
		groundSuppressTimer = 0,
		jumpGravityTimer = 0,
		stuckTimer = 0,
		stuckStartPos = self.hrp.Position
	}
	self.humanoid.PlatformStand = true
	self.humanoid.AutoRotate = false

	if self.humanoid then
		self._cachedWalkSpeed = self.humanoid.WalkSpeed
		self.humanoid.WalkSpeed = 0
	end

	local v10 = self.boundSize.Y * 0.25
	local v11 = self.boundSize.Z * 0.15
	local v12 = self.boundSize.Z * 0.3
	local v13 = {
		Vector3.new(0, v10, 0),
		Vector3.new(0, v10, v11),
		Vector3.new(0, v10, -v11),
		Vector3.new(0, v10, v12),
		(Vector3.new(0, v10, -v12))
	}
	local raycastResults2 = {}

	while true do
		local v14 = math.min(RunService.PreRender:Wait(), 0.05)

		if self.slopePart ~= slopePart or self.playerObject.Value ~= Players.LocalPlayer or not self.Instance:IsDescendantOf(workspace) then
			break
		end

		v8.stuckTimer = (v8.stuckTimer or 0) + v14

		if (v8.stuckTimer or 0) >= 2 then
			local stuckStartPos = v8.stuckStartPos or self.hrp.Position

			if (self.hrp.Position - stuckStartPos).Magnitude < 1.25 then
				self.sledDisableUntil = os.clock() + 0.75
				break
			else
				v8.stuckTimer = 0
				v8.stuckStartPos = self.hrp.Position
			end
		end

		local onGround = v8.onGround
		local magnitude = Vector3.new(v8.velocity.X, 0, v8.velocity.Z).Magnitude
		v8.rampSnapTimer = math.max(0, (v8.rampSnapTimer or 0) - v14)
		v8.jumpCooldown = math.max(0, (v8.jumpCooldown or 0) - v14)
		v8.groundSuppressTimer = math.max(0, (v8.groundSuppressTimer or 0) - v14)
		v8.jumpGravityTimer = math.max(0, (v8.jumpGravityTimer or 0) - v14)

		if v8.forwardLockTimer and v8.forwardLockTimer > 0 then
			v8.forwardLockTimer = math.max(0, v8.forwardLockTimer - v14)
		end

		table.clear(raycastResults2)
		local v15 = self.boundSize.Y + 2
		local v16 = -self.middle.CFrame.UpVector * v15
		local v17 = nil
		local v18 = false

		for _, v19 in ipairs(v13) do
			local pointToWorldSpace = self.middle.CFrame:PointToWorldSpace(v19)
			local raycastResult = workspace:Raycast(pointToWorldSpace, v16, self.rcParams)
			v18 = raycastResult and v19.Z < 0 and true or v18

			if not raycastResult then
				continue
			end

			table.insert(raycastResults2, raycastResult)
			v17 = v17 or raycastResult
		end

		if not v18 then
			table.clear(raycastResults2)
			v17 = nil
		end

		if not v17 then
			v8.rampSnapTimer = 0
		end

		local v19 = averageNormal(raycastResults2) -- equivalent call inferred; original call site unknown

		if (v8.groundSuppressTimer or 0) > 0 then
			v17 = nil
			v19 = nil
			raycastResults2 = {}
		end

		local lastNormal = v8.lastNormal
		local lastSlopeAngle = 0
		local lookVector2 = projectOntoPlane(vector2, lastNormal) -- equivalent call inferred; original call site unknown
		v8.onGround = false

		if v17 and v19 then
			if v19 and v19.Magnitude >= 0.0001 then
				lastNormal = v19.Unit
			else
				lastNormal = not (lastNormal and lastNormal.Magnitude >= 0.0001) and createVector(0, 0, -1) or lastNormal.Unit
			end

			local lastSlopeAngle2 = math.deg((lastNormal:Angle(createVector(0, 1, 0))))
			lastSlopeAngle = v8.lastSlopeAngle or lastSlopeAngle2
			local v21 = lastSlopeAngle2 - lastSlopeAngle
			local v22 = math.deg((math.acos((math.clamp(v8.lastNormal:Dot(lastNormal), -1, 1)))))
			local v23 = v17.Position.Y - self.groundPart.Position.Y
			local lookVector3 = projectOntoPlane(vector2, lastNormal) -- equivalent call inferred; original call site unknown

			if lookVector3.Magnitude < 0.001 then
				lookVector3 = self.middle.CFrame.LookVector

				if not (lastNormal.Magnitude < 0.0001) then
					local unit = lastNormal.Unit
					lookVector3 -= unit * lookVector3:Dot(unit)
				end
			end

			local velocity = v8.velocity

			if not ((createVector(0, 1, 0)).Magnitude < 0.0001) then
				local unit = (createVector(0, 1, 0)).Unit
				velocity -= unit * velocity:Dot(unit)
			end

			local v24 = safeUnit(velocity, self.middle.CFrame.LookVector) -- equivalent call inferred; original call site unknown

			if not ((createVector(0, 1, 0)).Magnitude < 0.0001) then
				local unit = (createVector(0, 1, 0)).Unit
				lookVector3 -= unit * lookVector3:Dot(unit)
			end

			local vector4 = safeUnit(lookVector3, v24) -- equivalent call inferred; original call site unknown
			local v25 = vector4:Dot(v24) < 0

			if onGround then
				if v21 >= 7 or v22 >= 7 or v25 then
					v25 = v23 < -(self.boundSize.Y * 0.15)
				end
			else
				v25 = onGround
			end

			if v25 then
				lastNormal = v8.lastNormal
				v8.onGround = false
				v17 = nil
			else
				if (v17.Position - self.middle.Position).Magnitude <= self.boundSize.Y + 6 then
					v8.onGround = true
					v8.lastNormal = lastNormal
					v8.lastSlopeAngle = lastSlopeAngle2

					if not onGround then
						v8.slopeBlendTime = 0

						if magnitude >= 200 then
							local vector5 = safeUnit(v17.Position - self.middle.Position, lastNormal) -- equivalent call inferred; original call site unknown

							if vector5:Dot(lastNormal) < -0.25 then
								v8.rampSnapTimer = 0.15
							end
						end
					end

					if lastNormal.Magnitude < 0.0001 then
						lookVector2 = vector2
					else
						local unit = lastNormal.Unit
						lookVector2 = vector2 - unit * vector2:Dot(unit)
					end

					if lookVector2.Magnitude < 0.001 then
						lookVector2 = self.middle.CFrame.LookVector

						if not (lastNormal.Magnitude < 0.0001) then
							local unit = lastNormal.Unit
							lookVector2 -= unit * lookVector2:Dot(unit)
						end
					end

					local dot = v8.velocity:Dot(lastNormal)

					if dot < 0 then
						v8.velocity -= lastNormal * dot
					end

					local v26 = safeUnit(lookVector2, self.middle.CFrame.LookVector) -- equivalent call inferred; original call site unknown
					local v27 = vector2.Magnitude * math.sin((math.rad((math.clamp(lastSlopeAngle2, 0, 90)))))
					v8.velocity += v26 * v27 * v14
					v8.velocity = applyDrag(v8.velocity, v14, 0.45)
				end

				lastSlopeAngle = lastSlopeAngle2
			end
		end

		if self._jumpRequested then
			self._jumpRequested = false

			if v8.onGround and (v8.jumpCooldown or 0) <= 0 then
				local v20

				if lastNormal and lastNormal.Magnitude >= 0.0001 then
					v20 = lastNormal.Unit
				else
					v20 = not ((createVector(0, 1, 0)).Magnitude >= 0.0001) and createVector(0, 0, -1) or (createVector(
						0,
						1,
						0
					)).Unit
				end

				v8.velocity += v20 * 70

				if v8.velocity.Y < 35 then
					v8.velocity = Vector3.new(v8.velocity.X, 35, v8.velocity.Z)
				end

				v8.onGround = false
				v8.groundSuppressTimer = 0.12
				v8.jumpCooldown = 0.6
				v8.jumpGravityTimer = 1.2
				v8.rampSnapTimer = 0
			end
		end

		if self.humanoid then
			if v8.onGround then
				if self._airWalkLocked and self._cachedWalkSpeed then
					self.humanoid.WalkSpeed = self._cachedWalkSpeed
				end

				self._airWalkLocked = false
			else
				if self.humanoid.WalkSpeed ~= 0 then
					if not self._cachedWalkSpeed then
						self._cachedWalkSpeed = self.humanoid.WalkSpeed
					end

					self.humanoid.WalkSpeed = 0
				end

				self._airWalkLocked = true
			end
		end

		if v8.onGround then
			v8.jumpGravityTimer = 0
			local v20

			if magnitude > 7 then
				v20 = v14
			else
				v20 = v14 * 0.35
			end

			v8.slopeBlendTime = math.min(0.4, (v8.slopeBlendTime or 0) + v20)
		elseif not (v8.onGround or onGround) then
			v8.slopeBlendTime = 0
		end

		if not v8.onGround then
			local v20

			if (v8.jumpGravityTimer or 0) > 0 then
				v20 = vector3 * 2
			else
				v20 = vector3
			end

			v8.velocity += v20 * v14
			v8.velocity = applyDrag(v8.velocity, v14, 0.005)
		end

		local moveDirection = self.humanoid.MoveDirection

		if v8.onGround and moveDirection.Magnitude > 0.05 then
			if not (lastNormal.Magnitude < 0.0001) then
				local unit = lastNormal.Unit
				moveDirection -= unit * moveDirection:Dot(unit)
			end

			if moveDirection.Magnitude > 0.001 then
				local v20 = safeUnit(lookVector2, self.middle.CFrame.LookVector) -- equivalent call inferred; original call site unknown
				local vector4 = safeUnit(moveDirection, v20) -- equivalent call inferred; original call site unknown
				local v21 = math.max(v8.velocity.Magnitude, 0)
				local velocity = v8.velocity

				if not (lastNormal.Magnitude < 0.0001) then
					local unit = lastNormal.Unit
					velocity -= unit * velocity:Dot(unit)
				end

				local v22 = safeUnit(velocity, vector4) -- equivalent call inferred; original call site unknown
				local v23 = math.clamp(
					1 - math.exp(-(math.clamp(velocity.Magnitude / 1326, 0.05, 1) * 35) * v14),
					0,
					0.8
				)
				local v25 = safeUnit(v22 * (1 - v23) + vector4 * v23, vector4) -- equivalent call inferred; original call site unknown
				v8.velocity = v25 * v21
				local v26 = safeUnit(lookVector2, vector4) -- equivalent call inferred; original call site unknown
				local dot = vector4:Dot(v26)

				if dot > 0 then
					v8.velocity += v26 * (dot * 20 * v14)
				end
			end
		elseif not v8.onGround and moveDirection.Magnitude > 0.05 then
			local velocity = v8.velocity
			local vector4 = Vector3.new(velocity.X, 0, velocity.Z)
			local magnitude2 = vector4.Magnitude

			if magnitude2 > 0.001 then
				local vector5 = Vector3.new(moveDirection.X, 0, moveDirection.Z)

				if vector5.Magnitude > 0.001 then
					local v20 = math.clamp(
						1 - math.exp(-(math.clamp(math.max(magnitude2, 0) / 1326, 0.05, 1) * 17) * v14),
						0,
						0.6
					)
					local v21 = safeUnit(vector4, vector5) -- equivalent call inferred; original call site unknown
					local unit = vector5.Unit
					local v23 = safeUnit(v21 * (1 - v20) + unit * v20, unit) -- equivalent call inferred; original call site unknown
					v8.velocity = Vector3.new(0, velocity.Y, 0) + v23 * magnitude2
				end
			end
		end

		local v20 = v8.onGround and 1560 or 1950

		if v20 < v8.velocity.Magnitude then
			v8.velocity = v8.velocity.Unit * v20
		end

		local v21 = false

		if magnitude > 2 then
			local velocity = v8.velocity
			local unit

			if velocity and velocity.Magnitude >= 0.0001 then
				unit = velocity.Unit
			else
				unit = not ((createVector(0, 0, -1)).Magnitude >= 0.0001) and createVector(0, 0, -1) or (createVector(
					0,
					0,
					-1
				)).Unit
			end

			local v22, v23 = multiRaycastWall(unit, math.max(v8.velocity.Magnitude * v14, v5))
			local vector4 = averageNormal(v23) -- equivalent call inferred; original call site unknown

			if v22 and v22.Instance and vector4 and math.abs((vector4:Dot(createVector(0, 1, 0)))) < 0.8 then
				local vector5 = safeUnit(v8.velocity, unit) -- equivalent call inferred; original call site unknown
				local dot = vector5:Dot(vector4)

				if v8.onGround and lastSlopeAngle > 5 and math.abs(dot) <= 0.25 then
					local v24 = (1 - math.abs(dot) / 0.25) * 120 * v14
					local magnitude2 = v8.velocity.Magnitude

					if magnitude2 > 0.01 then
						v8.velocity -= vector5 * math.min(v24, magnitude2)
						v21 = true
					end
				end

				if dot < 0 then
					v21 = true

					if dot <= -0.85 then
						local lookVector3 = self.middle.CFrame.LookVector

						if not ((createVector(0, 1, 0)).Magnitude < 0.0001) then
							local unit2 = (createVector(0, 1, 0)).Unit
							lookVector3 -= unit2 * lookVector3:Dot(unit2)
						end

						local unit2

						if lookVector3 and lookVector3.Magnitude >= 0.0001 then
							unit2 = lookVector3.Unit
						else
							unit2 = not ((createVector(0, 0, -1)).Magnitude >= 0.0001) and createVector(0, 0, -1) or (createVector(
								0,
								0,
								-1
							)).Unit
						end

						local v24 = -vector5 * v8.velocity.Magnitude * 0.92
						v8.velocity = v8.velocity:Lerp(v24, (math.clamp(v14 * 18, 0, 1)))
						v8.forwardVector = unit2
						v8.forwardLockTimer = 0.4
					else
						local velocity3 = v8.velocity

						if not (vector4.Magnitude < 0.0001) then
							local unit2 = vector4.Unit
							velocity3 -= unit2 * (2 * velocity3:Dot(unit2))
						end

						local v24 = velocity3 * 0.8
						v8.velocity = v8.velocity:Lerp(v24, (math.clamp(v14 * 18, 0, 1)))

						if v8.forwardLockTimer <= 0 then
							local velocity4 = v8.velocity

							if not (lastNormal.Magnitude < 0.0001) then
								local unit2 = lastNormal.Unit
								velocity4 -= unit2 * velocity4:Dot(unit2)
							end

							local velocity5 = v8.velocity
							local v25

							if velocity5 and velocity5.Magnitude >= 0.0001 then
								v25 = velocity5.Unit
							else
								v25 = not ((createVector(0, 0, -1)).Magnitude >= 0.0001) and createVector(0, 0, -1) or (createVector(
									0,
									0,
									-1
								)).Unit
							end

							local forwardVector3 = safeUnit(velocity4, v25) -- equivalent call inferred; original call site unknown
							v8.forwardVector = forwardVector3
						end
					end
				end
			end

			local rightVector = self.middle.CFrame.RightVector

			if not ((createVector(0, 1, 0)).Magnitude < 0.0001) then
				local unit2 = (createVector(0, 1, 0)).Unit
				rightVector -= unit2 * rightVector:Dot(unit2)
			end

			local v24 = safeUnit(rightVector, self.middle.CFrame.RightVector) -- equivalent call inferred; original call site unknown
			local v25, v26 = multiRaycastWall(v24, v6)
			local vector5 = averageNormal(v26) -- equivalent call inferred; original call site unknown

			if v25 and vector5 and math.abs((vector5:Dot(createVector(0, 1, 0)))) < 0.8 then
				local vector6 = safeUnit(v8.velocity, v24) -- equivalent call inferred; original call site unknown
				local dot = vector6:Dot(vector5)

				if v8.onGround and lastSlopeAngle > 5 and math.abs(dot) <= 0.25 then
					local v27 = (1 - math.abs(dot) / 0.25) * 120 * v14
					local magnitude2 = v8.velocity.Magnitude

					if magnitude2 > 0.01 then
						v8.velocity -= vector6 * math.min(v27, magnitude2)
					end

					v21 = true
				end

				if dot < 0 then
					local velocity3 = v8.velocity

					if not (vector5.Magnitude < 0.0001) then
						local unit2 = vector5.Unit
						velocity3 -= unit2 * (2 * velocity3:Dot(unit2))
					end

					local v27 = velocity3 * 0.8
					v8.velocity = v8.velocity:Lerp(v27, (math.clamp(v14 * 18, 0, 1)))
					v21 = true

					if v8.forwardLockTimer <= 0 then
						local velocity4 = v8.velocity

						if not (lastNormal.Magnitude < 0.0001) then
							local unit2 = lastNormal.Unit
							velocity4 -= unit2 * velocity4:Dot(unit2)
						end

						local velocity5 = v8.velocity
						local v28

						if velocity5 and velocity5.Magnitude >= 0.0001 then
							v28 = velocity5.Unit
						else
							v28 = not ((createVector(0, 0, -1)).Magnitude >= 0.0001) and createVector(0, 0, -1) or (createVector(
								0,
								0,
								-1
							)).Unit
						end

						local forwardVector3 = safeUnit(velocity4, v28) -- equivalent call inferred; original call site unknown
						v8.forwardVector = forwardVector3
					end
				end
			end

			local v27 = -v24
			local v28, v29 = multiRaycastWall(v27, v6)
			local vector6 = averageNormal(v29) -- equivalent call inferred; original call site unknown

			if v28 and vector6 and math.abs((vector6:Dot(createVector(0, 1, 0)))) < 0.8 then
				local vector7 = safeUnit(v8.velocity, v27) -- equivalent call inferred; original call site unknown
				local dot = vector7:Dot(vector6)

				if v8.onGround and lastSlopeAngle > 5 and math.abs(dot) <= 0.25 then
					local v30 = (1 - math.abs(dot) / 0.25) * 120 * v14
					local magnitude2 = v8.velocity.Magnitude

					if magnitude2 > 0.01 then
						v8.velocity -= vector7 * math.min(v30, magnitude2)
					end

					v21 = true
				end

				if dot < 0 then
					local velocity3 = v8.velocity

					if not (vector6.Magnitude < 0.0001) then
						local unit2 = vector6.Unit
						velocity3 -= unit2 * (2 * velocity3:Dot(unit2))
					end

					local v30 = velocity3 * 0.8
					v8.velocity = v8.velocity:Lerp(v30, (math.clamp(v14 * 18, 0, 1)))
					v21 = true

					if v8.forwardLockTimer <= 0 then
						local velocity4 = v8.velocity

						if not (lastNormal.Magnitude < 0.0001) then
							local unit2 = lastNormal.Unit
							velocity4 -= unit2 * velocity4:Dot(unit2)
						end

						local velocity5 = v8.velocity
						local v31

						if velocity5 and velocity5.Magnitude >= 0.0001 then
							v31 = velocity5.Unit
						else
							v31 = not ((createVector(0, 0, -1)).Magnitude >= 0.0001) and createVector(0, 0, -1) or (createVector(
								0,
								0,
								-1
							)).Unit
						end

						local forwardVector3 = safeUnit(velocity4, v31) -- equivalent call inferred; original call site unknown
						v8.forwardVector = forwardVector3
					end
				end
			end
		end

		if v21 and v8.onGround and lastSlopeAngle > 5 then
			v8.wallContactTimer = math.min(2.5, (v8.wallContactTimer or 0) + v14)
		else
			v8.wallContactTimer = math.max(0, (v8.wallContactTimer or 0) - v14 * 0.5)
		end

		if (v8.wallContactTimer or 0) >= 2 then
			self.sledDisableUntil = os.clock() + 1.5
			break
		end

		if v8.onGround and lastSlopeAngle <= 5 and magnitude <= 10 or not v8.onGround and v8.velocity.Magnitude < 0.5 and self.humanoid.MoveDirection.Magnitude < 0.1 then
			break
		end

		local position = self.hrp.Position

		if v8.onGround and v17 then
			local v22 = self.groundPart.Position - self.hrp.Position
			local v23 = v17.Position - v22
			local v24 = (v8.rampSnapTimer or 0) > 0 and onGround and 1 or math.clamp(
				(onGround and 20 or 55) * v14,
				0,
				1
			)
			position = self.hrp.Position:Lerp(v23, v24)
		end

		local forwardVector

		if v8.forwardLockTimer > 0 then
			forwardVector = v8.forwardVector

			if v8.onGround and not (lastNormal.Magnitude < 0.0001) then
				local unit = lastNormal.Unit
				forwardVector -= unit * forwardVector:Dot(unit)
			end
		else
			forwardVector = v8.velocity

			if v8.onGround then
				if not (lastNormal.Magnitude < 0.0001) then
					local unit = lastNormal.Unit
					forwardVector -= unit * forwardVector:Dot(unit)
				end

				if forwardVector.Magnitude < 0.001 then
					forwardVector = lookVector2
				end
			else
				local v22 = safeUnit(forwardVector, v8.forwardVector) -- equivalent call inferred; original call site unknown
				local vector4 = Vector3.new(v22.X, 0, v22.Z)
				local unit

				if vector4 and vector4.Magnitude >= 0.0001 then
					unit = vector4.Unit
				else
					unit = not ((createVector(0, 0, -1)).Magnitude >= 0.0001) and createVector(0, 0, -1) or (createVector(
						0,
						0,
						-1
					)).Unit
				end

				local v23 = unit + Vector3.new(0, math.clamp(v22.Y, -0.20791169081775934, 0.10452846326765347), 0)

				if v23 and v23.Magnitude >= 0.0001 then
					forwardVector = v23.Unit
				else
					forwardVector = not (unit and unit.Magnitude >= 0.0001) and createVector(0, 0, -1) or unit.Unit
				end
			end

			v8.forwardVector = forwardVector
		end

		local v22 = not v8.onGround and 0 or math.clamp((v8.slopeBlendTime or 0) / 0.4, 0, 1)
		local v23 = not v8.onGround and createVector(0, 1, 0) or (createVector(0, 1, 0)):Lerp(lastNormal, v22)
		local v24 = v8.onGround and (onGround and 60 or 50) or 45
		local upVector = smoothVector(v8.upVector, v23, v24, v14) -- equivalent call inferred; original call site unknown
		v8.upVector = upVector
		local v26 = safeUnit(v8.upVector, v23) -- equivalent call inferred; original call site unknown

		if v8.forwardLockTimer > 0 then
			forwardVector = v8.forwardVector
		elseif v8.onGround and not (v26.Magnitude < 0.0001) then
			local unit = v26.Unit
			forwardVector -= unit * forwardVector:Dot(unit)
		end

		local v28 = smoothVector(v8.forwardVector, forwardVector, onGround and 15 or 22, v14) -- equivalent call inferred; original call site unknown

		if v28.Magnitude < 0.0001 then
			v28 = forwardVector
		end

		local forwardVector4 = safeUnit(v28, forwardVector) -- equivalent call inferred; original call site unknown
		v8.forwardVector = forwardVector4
		local orientationCFrame = buildOrientationCFrame(position, v8.forwardVector, v26)
		v3.CFrame = orientationCFrame

		if v8.onGround and v17 then
			self.hrp.CFrame = orientationCFrame
		elseif not v8.onGround then
			self.hrp.CFrame = CFrame.lookAlong(self.hrp.Position, v8.forwardVector, createVector(0, 1, 0))
		end

		v4.VectorVelocity = v8.velocity
	end

	if self._Janitor and self._Janitor.Remove then
		self._Janitor:Remove("Orient")
		self._Janitor:Remove("Velocity")
	end

	self.slopePart = nil
	self:_restoreCharacterMovement()
end

function v:Start()
	self.middle = self.Instance:WaitForChild("Middle")
	self.collider = self.middle:WaitForChild("Collider")
	self.groundPart = self.middle:WaitForChild("GroundPart")
	self.vehicleSeat = self.middle:WaitForChild("Seat")
	self.playerObject = self.Instance:WaitForChild("PlayerObject")
	self.boundSize = ({ self.Instance:GetBoundingBox() })[2]
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { self.Instance, Players.LocalPlayer.Character }
	raycastParams.RespectCanCollide = true
	self.rcParams = raycastParams
	local character = Players.LocalPlayer.Character

	if not (character and self.playerObject.Value == Players.LocalPlayer) then
		return
	end

	self.humanoid = character:WaitForChild("Humanoid")
	self.humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
	self.humanoid.Sit = false
	self._Janitor:Add(self.humanoid:GetPropertyChangedSignal("Sit"):Connect(function()
		if self.humanoid and self.humanoid.Sit then
			self.humanoid.Sit = false
		end
	end))
	self.hrp = character:WaitForChild("HumanoidRootPart")
	local seatAnimation = self.vehicleSeat:WaitForChild("SeatAnimation")
	self.seatAnimationTrack = self.humanoid:LoadAnimation(seatAnimation)
	self.seatAnimationTrack:Play()
	self._Janitor:Add(self.vehicleSeat:GetPropertyChangedSignal("Occupant"):Connect(function()
		local occupant = self.vehicleSeat.Occupant

		if not occupant then
			return
		end

		task.defer(function()
			task.wait()
			task.wait()
			task.wait(0.1)

			for _, part in occupant.Parent:GetDescendants() do
				if not part:IsA("BasePart") then
					continue
				end

				part.CanCollide = false
				part.Massless = true
			end
		end)
	end))
	self.slopePart = nil
	self._Janitor:Add(UserInputService.JumpRequest:Connect(function()
		if self.slopePart ~= nil then
			self._jumpRequested = true
		end
	end))

	local function isDescendingIntoNormal(normal: Vector3?, _: Vector3?)
		local assemblyLinearVelocity = self.hrp and self.hrp.AssemblyLinearVelocity or createVector(0, 0, 0)

		if assemblyLinearVelocity.Magnitude < 0.5 and self.humanoid then
			assemblyLinearVelocity = self.humanoid.MoveDirection * self.humanoid.WalkSpeed
		end

		if assemblyLinearVelocity.Magnitude < 0.5 then
			return false
		end

		if not (normal and normal.Magnitude >= 0.001) then
			return assemblyLinearVelocity.Y < -2
		end

		local unit = normal.Unit
		local v2 = createVector(0, -1, 0) - unit * (createVector(0, -1, 0)):Dot(unit)

		if v2.Magnitude < 0.001 then
			return false
		end

		local unit2 = v2.Unit
		local dot = assemblyLinearVelocity.Unit:Dot(unit2)
		local dot2 = assemblyLinearVelocity.Unit:Dot(unit)
		return not (dot <= 0.1) and not (dot2 > 0.25)
	end

	self._Janitor:Add(self.collider.Touched:Connect(function(otherPart, part)
		if self.slopePart or self.sledDisableUntil and os.clock() < self.sledDisableUntil then
			return
		end

		local floorSurfaceAngle, v2 = self:GetFloorSurfaceAngle()

		if not floorSurfaceAngle then
			return
		end

		local normal = nil

		if v2 then
			normal = v2.Normal
		elseif part and part:IsA("BasePart") then
			normal = (self.hrp.Position - part.Position).Unit
		end

		local position

		if v2 then
			position = v2.Position
		elseif otherPart and otherPart.Position then
			position = otherPart.Position
		end

		if math.abs(floorSurfaceAngle) >= 10 and isDescendingIntoNormal(normal, position) then
			self:BeginSleddingOnSlope(otherPart)
		end
	end))

	while task.wait(0.1) and self.playerObject.Value == Players.LocalPlayer and self.Instance:IsDescendantOf(workspace) do
		if self.slopePart or self.sledDisableUntil and os.clock() < self.sledDisableUntil then
			continue
		end

		local floorSurfaceAngle, v2 = self:GetFloorSurfaceAngle()

		if not (floorSurfaceAngle and math.abs(floorSurfaceAngle) >= 10 and v2 and isDescendingIntoNormal(
			v2.Normal,
			v2.Position
		)) then
			continue
		end

		self:BeginSleddingOnSlope(v2.Instance)
	end
end

function v:_restoreCharacterMovement()
	local humanoid = self.humanoid

	if not humanoid then
		return
	end

	self._airWalkLocked = false
	humanoid.PlatformStand = false
	humanoid.AutoRotate = true

	if self._cachedWalkSpeed then
		humanoid.WalkSpeed = self._cachedWalkSpeed
	end
end

function v:Stop()
	if self.humanoid then
		self.humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
		self.humanoid.Sit = false
		task.defer(function()
			self.humanoid.WalkSpeed = 16
		end)
	end

	if self.seatAnimationTrack then
		self.seatAnimationTrack:Stop()
	end

	self.slopePart = nil
	self._jumpRequested = false
	self:_restoreCharacterMovement()
	self._Janitor:Destroy()
end

return v