return {
	createBoundary = function(parent, cFrame: CFrame, size: Vector3)
		local part2 = assert(parent.PrimaryPart, (`{parent:GetFullName()} requires a primary part`))
		local part = Instance.new("Part")
		part.Name = "__BoundingBox"
		part.Size = size
		part.CFrame = cFrame
		part.Transparency = 1
		part.Color = Color3.fromRGB(81, 255, 0)
		part.Anchored = false
		part.Massless = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Parent = parent
		local weldConstraint = Instance.new("WeldConstraint")
		weldConstraint.Part0 = part
		weldConstraint.Part1 = part2
		weldConstraint.Parent = part
		return part
	end
}