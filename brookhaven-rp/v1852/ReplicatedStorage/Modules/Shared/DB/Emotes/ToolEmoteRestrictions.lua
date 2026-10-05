local ToolEmoteRestrictions = {
	remoteConfigDirectory = "Emotes/Tools",
	isPublic = true,
	isLoaded = false,
	cache = nil,
	toolNames = {}
}
ToolEmoteRestrictions.middlewares = {
	buildIdCache = function(items)
		ToolEmoteRestrictions.toolNames = {}

		for _, item in items do
			ToolEmoteRestrictions.toolNames[item.Name] = true
		end

		return items
	end
}

function ToolEmoteRestrictions.ContainsTool(p: string)
	while not ToolEmoteRestrictions.isLoaded do
		task.wait()
	end

	return ToolEmoteRestrictions.toolNames[p] ~= nil
end

function ToolEmoteRestrictions.GetConfig()
	while not ToolEmoteRestrictions.isLoaded do
		task.wait()
	end

	return ToolEmoteRestrictions.cache
end

return ToolEmoteRestrictions