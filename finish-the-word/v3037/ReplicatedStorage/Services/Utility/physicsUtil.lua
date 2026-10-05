local createVector = vector.create
_G.import("configuration")
game:GetService("RunService")
local PhysicsUtil = {
	velocityForward = function(parent, p)
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = parent.CFrame.LookVector * p
		bodyVelocity.MaxForce = createVector(1e999, 1e999, 1e999)
		bodyVelocity.Parent = parent
	end,
	velocityStop = function(folder)
		for _, bodyVelocity in pairs(folder:GetDescendants()) do
			if bodyVelocity:IsA("BodyVelocity") then
				bodyVelocity:Destroy()
			end
		end
	end,
	timeUntilGrounded = function(p, p2, p3)
		local Y = p2.Y
		local Y2 = p3.Y
		return (-Y2 - math.sqrt(Y2 ^ 2 - 4 * p / 2 * Y)) / (2 * p / 2)
	end
}

function PhysicsUtil.findGroundedPos(p, p2, p3)
	return (p2 + p3 * PhysicsUtil.timeUntilGrounded(p, p2, p3)) * createVector(1, 0, 1)
end

function PhysicsUtil:simulate(p, p2, p3, p4, p5, p6)
	local v = p
	local v2 = p6 or function() end
	local v3 = true
	task.spawn(function()
		while true do
			local v4 = task.wait(0)
			v += v4

			if not v3 then
				break
			end

			local cFrame = self.CFrame
			self.CFrame = PhysicsUtil.motion(p2, p3, p4, v) * PhysicsUtil.rot(p5, v) * self.PivotOffset:Inverse()

			if v2(v, v4, cFrame) then
				break
			end
		end
	end)
	return {
		Disconnect = function()
			v3 = false
		end,
		Pause = function(self)
			self:Disconnect()
			return self:GetInfo()
		end,
		GetInfo = function()
			return {
				C0 = PhysicsUtil.motion(p2, p3, p4, v),
				V0 = PhysicsUtil.vel(p3, p4, v)
			}
		end
	}
end

function PhysicsUtil.jumpHeight(p, p2, p3)
	local v = math.sqrt(-2 * p2 / p)
	local v2 = (p2 - p / 2 * v ^ 2) / v
	return PhysicsUtil.motion(0, v2, p, p3)
end

function PhysicsUtil.airTime(p, p2)
	return (math.sqrt(-2 * p2 / p))
end

function PhysicsUtil.motion(p, p2, p3, p4)
	return p + p2 * p4 + p3 / 2 * p4 ^ 2
end

function PhysicsUtil.vel(p, p2, p3)
	return p + p2 * p3
end

function PhysicsUtil.rot(data, p)
	return CFrame.Angles(data.X * p, data.Y * p, data.Z * p)
end

function PhysicsUtil.quadraticFormula(p, p2, p3)
	local v = p2 * p2 - 4 * p * p3

	if v < 0 then
		return
	end

	local v2 = math.sqrt(v)
	return (-p2 + v2) / (2 * p), (-p2 - v2) / (2 * p)
end

function PhysicsUtil.distantFrom(p, vector2, p2, p3)
	local vector3 = p - p2
	local dot = vector2:Dot(vector2)
	local v = 2 * vector3:Dot(vector2)
	local v2 = vector3:Dot(vector3) - p3 * p3
	local v3 = v * v - 4 * dot * v2

	if v3 < 0 then
		return nil
	end

	local v4 = math.sqrt(v3)
	local v5 = (-v + v4) / (2 * dot)
	local v6 = (-v - v4) / (2 * dot)
	return p + vector2 * v5, p + vector2 * v6, v5, v6
end

function PhysicsUtil.bounce(p, vector2, p2, p3, p4, p5, p6, p7, p8)
	local v = 0.4 * p8 * p5 ^ 2
	local vector3 = p2 - p3
	local vector4 = p + vector2:Cross(vector3)
	local unit = p4.unit
	local dot = vector4:Dot(unit)

	if dot >= 0 then
		return p, vector2
	end

	local v2 = vector4 - unit * dot
	local unit2 = v2.magnitude > 1e-6 and v2.unit or createVector(0, 0, 0)
	local v3 = 1 / p8 + vector3:Cross(unit).magnitude ^ 2 / v
	local v4 = -(1 + p6) * dot / v3
	local v5 = 1 / p8 + vector3:Cross(unit2).magnitude ^ 2 / v
	local v6 = -vector4:Dot(unit2) / v5
	local v7 = p7 * v4
	local v8 = math.clamp(v6, -v7, v7)
	local v9 = unit * v4 + unit2 * v8
	local v10 = p + v9 / p8
	local vector5 = vector2 + vector3:Cross(v9) / v

	if (v10 + vector5:Cross(vector3)).magnitude < 0.1 then
		vector5 = vector3:Cross(v10) / p5 ^ 2
	end

	return v10 * 0.99, vector5 * 0.99
end

return PhysicsUtil