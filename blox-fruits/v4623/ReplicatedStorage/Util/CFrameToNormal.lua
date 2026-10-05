local createVector = vector.create
return function(data, p, p2)
	local p3 = data.p
	local unit = data.LookVector:Cross(p).Unit
	local unit2 = (unit.Magnitude > 0.001 and unit or data.RightVector).Unit
	local unit3 = unit2:Cross(p).Unit.Unit

	if not p2 then
		return CFrame.fromMatrix(p3, unit2, p, unit3)
	end

	local part = Instance.new("Part")
	part.TopSurface = 0
	part.BottomSurface = 0
	part.FrontSurface = 6
	part.Anchored = true
	part.CanCollide = false
	part.Size = createVector(1, 1, 1)
	part.Color = Color3.new(0, 1, 0)
	local clone = part:Clone()
	clone.Color = Color3.new(1, 1, 0)
	local clone2 = part:Clone()
	clone2.Color = Color3.new(1, 0, 0)
	part.CFrame = CFrame.new(p3, p3 + unit2)
	clone.CFrame = CFrame.new(p3, p3 + p)
	clone2.CFrame = CFrame.new(p3, p3 + unit3)
	local _WorldOrigin = workspace._WorldOrigin
	local _WorldOrigin2 = workspace._WorldOrigin
	local _WorldOrigin3 = workspace._WorldOrigin
	part.Parent = _WorldOrigin
	clone.Parent = _WorldOrigin2
	clone2.Parent = _WorldOrigin3
	return CFrame.fromMatrix(p3, unit2, p, unit3)
end