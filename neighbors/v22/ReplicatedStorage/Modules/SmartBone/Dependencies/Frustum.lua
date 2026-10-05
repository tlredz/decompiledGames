local parent = script.Parent
local Config = require(parent:WaitForChild("Config"))
local Utilities = require(parent:WaitForChild("Utilities"))
local Frustum = {
	GetCFrames = function(data, p)
		local cFrame = data.CFrame
		local position = cFrame.Position
		local rightVector = cFrame.RightVector
		local upVector = cFrame.UpVector
		local v = p * 0.5
		local v2 = math.tan((data.FieldOfView + 5) * 0.5 * 0.017453) * p
		local v3 = v2 * (data.ViewportSize.X / data.ViewportSize.Y)
		local v4 = cFrame * CFrame.new(0, 0, -p)
		local v5 = v4 * Vector3.new(v3, v2, 0)
		local v6 = v4 * Vector3.new(-v3, -v2, 0)
		local v7 = v4 * Vector3.new(v3, -v2, 0)
		return
			(cFrame * CFrame.new(0, 0, -v)):Inverse(),
			v3,
			v2,
			v,
			upVector:Cross(v7 - position).Unit,
			upVector:Cross(v6 - position).Unit,
			rightVector:Cross(position - v5).Unit,
			rightVector:Cross(position - v7).Unit,
			cFrame
	end,
	InViewFrustum = function(p, p2, p3, p4, p5, vector, vector2, vector3, vector4, p6)
		local position = p6.Position
		local v = p2 * p

		if p3 < v.X or v.X < -p3 or p4 < v.Y or v.Y < -p4 or p5 < v.Z or v.Z < -p5 then
			return false
		end

		local v2 = p - position
		return not (vector:Dot(v2) < 0 or vector2:Dot(v2) > 0 or vector3:Dot(v2) < 0 or vector4:Dot(v2) > 0)
	end
}

function Frustum.ObjectInFrustum(instance, p, p2, p3, p4, p5, p6, p7, p8, p9)
	local cFrame = instance.CFrame
	local size = instance.Size
	local v = Config.FAR_PLANE * 0.5
	local v2 = p9.Position + p9.LookVector * v
	local closestPointOnLine = Utilities.ClosestPointOnLine(v2, p9.LookVector, v, cFrame.Position)
	local closestPointInBox, v3 = Utilities.ClosestPointInBox(cFrame, size, closestPointOnLine)

	if closestPointInBox or Frustum.InViewFrustum(v3, p, p2, p3, p4, p5, p6, p7, p8, p9) then
		return true
	end

	return false
end

return Frustum