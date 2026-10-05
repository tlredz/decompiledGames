local function needsDestruction(instance)
	return typeof(instance) == "Instance"
end

return needsDestruction