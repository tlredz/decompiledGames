return {
	WithinViewport = function(instance)
		local currentCamera = workspace.CurrentCamera
		local boundingBox, size

		if instance:IsA("Model") then
			boundingBox, size = instance:GetBoundingBox()
		elseif instance:IsA("BasePart") then
			boundingBox = instance.CFrame
			size = instance.Size
		else
			warn("Object is neither a Model nor a BasePart! Disregarding Camera check!")
			return false
		end

		for i = 1, 8 do
			local _, v = currentCamera:WorldToViewportPoint((boundingBox * CFrame.new(
				size.X * (i % 2 == 0 and 0.5 or -0.5),
				size.Y * (i % 4 > 1 and 0.5 or -0.5),
				size.Z * (i % 8 > 3 and 0.5 or -0.5)
			)).Position)

			if v then
				return true
			end
		end

		return false
	end
}