local createVector = vector.create
local part = Instance.new("Part")
part.Name = "ForceField"
part.Anchored = true
part.CanCollide = false
part.CanQuery = false
part.CanTouch = false
part.Transparency = 0
part.Size = createVector(1, 1, 1)
part.Material = Enum.Material.ForceField
part.Color = Color3.fromRGB(255, 0, 0)
part.Shape = Enum.PartType.Ball
part.CastShadow = false
return function(p)
	local clone = part:Clone()
	clone.CFrame = CFrame.new(p.Position)
	clone.Parent = workspace._WorldOrigin
	task.delay(5, function()
		clone:Destroy()
	end)

	while clone.Size.Magnitude < p.Radius * 2 do
		local v = task.wait()
		clone.Size += createVector(1, 1, 1) * (p.Radius * v)
		clone.CFrame *= CFrame.Angles(0, 0.06283185307179587 * v, 0)
	end

	clone:Destroy()
end