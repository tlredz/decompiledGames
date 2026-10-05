local createVector = vector.create
local wedgePart = Instance.new("WedgePart")
wedgePart.Anchored = true
wedgePart.CanCollide = false
wedgePart.CanTouch = false
wedgePart.CanQuery = false
wedgePart.TopSurface = Enum.SurfaceType.Smooth
wedgePart.BottomSurface = Enum.SurfaceType.Smooth
wedgePart.CastShadow = false
local cframe = CFrame.Angles(0, 3.141592653589793, 0)

function DrawTriangle(vector2: Vector3, vector3: Vector3, vector4: Vector3, value: number?, parent)
	local v = value or 0.1
	local clone = wedgePart:Clone()
	local clone2 = wedgePart:Clone()
	local vector5 = vector3 - vector2
	local vector6 = vector4 - vector2
	local vector7 = vector4 - vector3
	local dot = vector5:Dot(vector5)
	local dot2 = vector6:Dot(vector6)
	local dot3 = vector7:Dot(vector7)
	local v2, v3

	if dot < dot2 then
		v2 = vector4
		vector5 = vector6
		v3 = vector3
		dot = dot2
	else
		v2 = vector3
		v3 = vector4
	end

	if dot < dot3 then
		v2 = vector4
		vector5 = vector7
		v3 = vector2
		dot = dot3
	else
		vector3 = vector2
	end

	local v4 = math.sqrt(dot)
	local v5 = (v3 - vector3):Dot(vector5) / dot
	local v6 = v3 - (vector3 + vector5 * v5)
	local magnitude = v6.Magnitude
	local v7 = v5 * v4
	local v8 = v4 - v7
	local cframe2 = CFrame.lookAlong(createVector(0, 0, 0), -vector5, v6)
	clone.Size = Vector3.new(v, magnitude, v7)
	clone.CFrame = cframe2 + (vector3 + v3) * 0.5
	clone2.Size = Vector3.new(v, magnitude, v8)
	clone2.CFrame = cframe2 * cframe + (v2 + v3) * 0.5
	clone.Name = "w1"
	clone2.Name = "w2"
	clone.Parent = parent
	clone2.Parent = parent
	return clone, clone2
end

return DrawTriangle