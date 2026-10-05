return function(instance, vector: Vector3?)
	local cFrame = instance.CFrame
	local size = instance.Size

	if vector then
		size *= vector
	end

	return cFrame * CFrame.new(
		math.random(-size.X / 2, size.X / 2),
		math.random(-size.Y / 2, size.Y / 2),
		math.random(-size.Z / 2, size.Z / 2)
	)
end