local wedgePart = Instance.new("WedgePart")
wedgePart.Material = Enum.Material.SmoothPlastic
wedgePart.Anchored = true
wedgePart.CanCollide = false
wedgePart.Color = Color3.new(1, 1, 1)
return function(parent, p, p2, p3)
	local vector = p2 - p
	local vector2 = p3 - p
	local vector3 = p3 - p2
	local dot = vector:Dot(vector)
	local dot2 = vector2:Dot(vector2)
	local dot3 = vector3:Dot(vector3)

	if dot2 < dot and dot3 < dot then
		p3, p = p, p3
	elseif dot3 < dot2 and dot < dot2 then
		p, p2 = p2, p
	end

	local vector4 = p2 - p
	local vector5 = p3 - p
	local vector6 = p3 - p2
	local unit = vector5:Cross(vector4).Unit
	local unit2 = vector6:Cross(unit).Unit
	local unit3 = vector6.Unit
	local v = math.abs((vector4:Dot(unit2)))
	local v2 = math.abs((vector4:Dot(unit3)))
	local v3 = math.abs((vector5:Dot(unit3)))
	local clone = wedgePart:Clone()
	clone.Size = Vector3.new(0, v, v2)
	clone.CFrame = CFrame.fromMatrix((p + p2) / 2, unit, unit2, unit3)
	clone.Parent = parent
	local clone2 = wedgePart:Clone()
	clone2.Size = Vector3.new(0, v, v3)
	clone2.CFrame = CFrame.fromMatrix((p + p3) / 2, -unit, unit2, -unit3)
	clone2.Parent = parent
	return clone, clone2
end