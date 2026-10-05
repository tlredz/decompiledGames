local HideToolsEmotes = {
	remoteConfigDirectory = "Emotes/HideTools",
	isPublic = true,
	isLoaded = false,
	cache = nil,
	emoteNames = {}
}
HideToolsEmotes.middlewares = {
	buildIdCache = function(items)
		HideToolsEmotes.emoteNames = {}

		for _, item in items do
			HideToolsEmotes.emoteNames[item.Name] = true
		end

		return items
	end
}

function HideToolsEmotes.ContainsEmote(p: string)
	while not HideToolsEmotes.isLoaded do
		task.wait()
	end

	return HideToolsEmotes.emoteNames[p] ~= nil
end

function HideToolsEmotes.GetConfig()
	while not HideToolsEmotes.isLoaded do
		task.wait()
	end

	return HideToolsEmotes.cache
end

return HideToolsEmotes