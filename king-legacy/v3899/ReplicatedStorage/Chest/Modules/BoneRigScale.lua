function scaleRecursive(p, instance, p2, p3)
	if instance:isA("Bone") then
		local cFrame = instance.Parent.CFrame
		local v = p.CFrame:Inverse() * cFrame
		local v2 = v - v.Position
		local v3 = v2 * instance.Position * p2
		game.TweenService:Create(instance, p3, {
			Position = v2:inverse() * v3
		}):Play()
	end

	local children = instance:GetChildren()

	for i = 1, #children do
		local v = children[i]
		scaleRecursive(p, v, p2, p3)
	end
end

return function(instance, p, value)
	if not instance then
		return
	end

	local v = p or TweenInfo.new(0.5)
	local v2 = value or 2

	for _, part in pairs(instance:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		scaleRecursive(part, part, v2, v)
		game.TweenService:Create(part, v, {
			Size = Vector3.new(part.Size.x * v2, part.Size.y * v2, part.Size.z * v2)
		}):Play()
	end
end