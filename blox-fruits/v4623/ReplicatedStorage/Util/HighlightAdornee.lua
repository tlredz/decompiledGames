return function(instance)
	local highlightAdornee = instance:GetAttribute("HighlightAdornee")

	if typeof(highlightAdornee) ~= "string" then
		return nil
	end

	local instance2 = instance:FindFirstChild(highlightAdornee, true)

	if instance2 and (instance2:IsA("Model") or instance2:IsA("BasePart")) then
		return instance2
	end

	return nil
end