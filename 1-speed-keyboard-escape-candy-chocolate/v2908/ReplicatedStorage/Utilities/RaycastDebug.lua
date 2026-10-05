local createVector = vector.create
local Debris = game:GetService("Debris")
local color = Color3.fromRGB(0, 255, 0)
local color2 = Color3.fromRGB(255, 0, 0)
local color3 = Color3.fromRGB(0, 255, 255)
return {
	visualize = function(vector2: Vector3, vector3: Vector3, raycastResult: RaycastResult?, value: number?)
		local position = raycastResult and raycastResult.Position or vector2 + vector3
		local magnitude = (position - vector2).Magnitude
		local v = value or 5
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.CastShadow = false
		part.Material = Enum.Material.Neon
		part.Color = raycastResult and color or color2
		part.Size = Vector3.new(0.15, 0.15, (math.max(magnitude, 0.15)))
		part.CFrame = CFrame.lookAt(vector2, position) * CFrame.new(0, 0, -magnitude / 2)
		part.Parent = workspace
		Debris:AddItem(part, v)

		if not raycastResult then
			return part
		end

		local part2 = Instance.new("Part")
		part2.Anchored = true
		part2.CanCollide = false
		part2.CanQuery = false
		part2.CastShadow = false
		part2.Shape = Enum.PartType.Ball
		part2.Material = Enum.Material.Neon
		part2.Color = color3
		part2.Size = createVector(1.5, 1.5, 1.5)
		part2.CFrame = CFrame.new(raycastResult.Position)
		part2.Parent = workspace
		Debris:AddItem(part2, v)
		return part
	end
}