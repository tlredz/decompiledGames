local createVector = vector.create
local PhysicsUtil = {}
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Shared.Utils.VisualEffectsUtil)

function PhysicsUtil:NewSimulation(position: Vector3, vector2: Vector3, max: number, _: number, p, callback, value: number?)
	self:PivotTo(CFrame.new(position))
	local v = math.clamp((vector2 - position).Magnitude, 0, max)
	local v2 = v / max
	local v3 = (vector2 - position).Unit * v
	local gravity = workspace.Gravity
	local vector3 = Vector3.new(v3.X / v2, (v3.Y + 0.5 * gravity * v2 ^ 2) / v2, v3.Z / v2)
	self.Velocity = vector3
	local v4 = position + vector3 * 0 + Vector3.new(0, 0.5 * gravity * 0, 0)
	self:PivotTo(CFrame.new(v4))

	local function PlayImpact(raycastResult, velocity)
		if self and self.Parent then
			self:PivotTo(CFrame.new(raycastResult.Position))
			self.Anchored = true
			self.Transparency = 1
			self.CanCollide = false
			self.CanTouch = false
			self.CanQuery = false

			if callback then
				callback(raycastResult, velocity.Unit)
			end

			task.wait(value or 4)
			self:Destroy()
		end
	end

	local steppedConnection = nil
	local thread = nil
	steppedConnection = RunService.Stepped:Connect(function()
		local velocity = self.Velocity
		local raycastResult = workspace:Raycast(self.CFrame.Position - velocity.Unit * 1.25, velocity.Unit * 4, p)

		if raycastResult then
			if thread then
				task.cancel(thread)
			end

			steppedConnection:Disconnect()
			PlayImpact(raycastResult, velocity)
		end
	end)
	thread = task.delay(v2 - 0, function()
		steppedConnection:Disconnect()
		local velocity = self.Velocity
		PlayImpact(workspace:Raycast(vector2 - velocity.Unit * 1.25, velocity.Unit * 4, p), velocity)
	end)
end

function PhysicsUtil.LobProjectileToLocation(object, vector2: Vector3, vector3: Vector3, p: number, p2: number?)
	local vector4 = Vector3.new(vector2.X, 0, vector2.Z)
	local vector5 = Vector3.new(vector3.X, 0, vector3.Z)
	local v = vector3.Y - vector2.Y
	local v2 = p2 or workspace.Gravity
	local unit = (vector5 - vector4).Unit
	local magnitude = (vector4 - vector5).Magnitude
	local v3 = p ^ 4 - v2 * (v2 * magnitude ^ 2 + v * 2 * p ^ 2)

	if v3 < 0 then
		return false
	end

	local v4 = math.atan((p ^ 2 - math.sqrt(v3)) / (v2 * magnitude))
	object:ApplyImpulse(CFrame.fromAxisAngle(unit:Cross(createVector(0, 1, 0)), v4):VectorToWorldSpace(unit) * object.AssemblyMass * p)
end

function PhysicsUtil.AutoProjectileToLocation(object, vector2: Vector3, vector3: Vector3, p: number?)
	local v = p or workspace.Gravity
	local assemblyMass = object.AssemblyMass
	local v2 = vector3 - vector2
	local vector4 = Vector3.new(v2.X, 0, v2.Z)
	local magnitude = vector4.Magnitude
	local Y = v2.Y

	if magnitude < 0.1 then
		local v3 = math.sqrt(2 * v * math.abs(Y))
		object:ApplyImpulse(Vector3.new(0, Y >= 0 and v3 or -v3, 0) * assemblyMass)
		return true
	else
		local unit = vector4.Unit
		local v3 = nil
		local v4 = nil

		for i = 0.017453292519943295, 1.5533430342749532, 0.017453292519943295 do
			local v5 = math.cos(i)
			math.sin(i)
			local v6 = v5 ^ 2 * 2 * (magnitude * math.tan(i) - Y)

			if v6 <= 0 then
				continue
			end

			local v7 = v * magnitude ^ 2 / v6

			if v7 <= 0 then
				continue
			end

			local speed2 = math.sqrt(v7)
			local v9 = math.abs(i - math.atan2(Y, magnitude))
			local v10 = {
				speed = speed2,
				angle = i,
				deltaFromIdeal = math.abs(v9 - 0.17453292519943295)
			}

			if v3 then
				if speed2 < v3.speed then
					v3 = v10
				end
			else
				v3 = v10
			end

			if v9 >= 0.17453292519943295 and v9 <= 0.3490658503988659 and (not v4 or v10.deltaFromIdeal < v4.deltaFromIdeal) then
				v4 = v10
			end
		end

		local v5 = v4 or v3
		local angle = v5.angle
		local speed = v5.speed
		object:ApplyImpulse(CFrame.fromAxisAngle(unit:Cross(createVector(0, 1, 0)), angle):VectorToWorldSpace(unit) * speed * assemblyMass)
		return true
	end
end

return PhysicsUtil