return function(instance)
	if typeof(instance) == "Instance" then
		if instance:IsA("Player") then
			local character = instance.Character

			if character then
				return character:GetPivot()
			end
		else
			if instance:IsA("Model") then
				return instance:GetPivot()
			end

			if instance:IsA("BasePart") then
				return instance.CFrame
			end

			if instance:IsA("Attachment") then
				return instance.WorldCFrame
			end
		end
	else
		if typeof(instance) == "CFrame" then
			return instance
		end

		if typeof(instance) == "Vector3" then
			return CFrame.new(instance)
		else
			error((`Unsupported: {typeof(instance)}`))
		end
	end

	return nil
end