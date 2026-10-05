return function(instance)
	if instance:IsA("Player") then
		return instance
	end

	if instance:IsA("Tool") then
		if instance.Parent then
			if instance.Parent:IsA("Backpack") then
				return (instance:FindFirstAncestorOfClass("Player"))
			end

			return (game.Players:GetPlayerFromCharacter(instance.Parent))
		end
	else
		if instance:IsA("Model") then
			return (game.Players:GetPlayerFromCharacter(instance))
		end

		if instance:IsA("Humanoid") then
			return (game.Players:GetPlayerFromCharacter(instance.Parent))
		end

		if instance:IsA("BasePart") then
			local model = instance:FindFirstAncestorOfClass("Model")

			if model then
				return (game.Players:GetPlayerFromCharacter(model))
			end
		else
			error((`Unknown player type: {typeof(instance)}`))
		end
	end

	return nil
end