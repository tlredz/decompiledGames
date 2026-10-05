local ThrottleEmotes = {
	remoteConfigDirectory = "Emotes/Throttle",
	isPublic = true,
	isLoaded = false,
	cache = nil,
	emoteNames = {}
}
ThrottleEmotes.middlewares = {
	buildIdCache = function(items)
		ThrottleEmotes.emoteNames = {}

		for _, item in items do
			ThrottleEmotes.emoteNames[item.Name] = true
		end

		return items
	end
}

function ThrottleEmotes.ContainsEmote(p: string)
	while not ThrottleEmotes.isLoaded do
		task.wait()
	end

	return ThrottleEmotes.emoteNames[p] ~= nil
end

function ThrottleEmotes.GetConfig()
	while not ThrottleEmotes.isLoaded do
		task.wait()
	end

	return ThrottleEmotes.cache
end

return ThrottleEmotes