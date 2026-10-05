local EmotesConfig = {
	remoteConfigDirectory = "Emotes/Emotes",
	isPublic = true,
	isLoaded = false,
	cache = nil,
	emoteNames = {},
	emoteIdsToEmote = {},
	emoteIdsToIsSyncable = {}
}
EmotesConfig.middlewares = {
	buildNameCache = function(items)
		for _, item in items do
			EmotesConfig.emoteNames[item.Name] = item
		end

		return items
	end,
	buildIdCache = function(items)
		for _, item in items do
			EmotesConfig.emoteIdsToEmote[tonumber(item.Id)] = item
		end

		return items
	end,
	buildIsSyncableCache = function(items)
		for _, item in items do
			EmotesConfig.emoteIdsToIsSyncable[tonumber(item.Id)] = item.Repeat and true or false
		end

		return items
	end
}

function EmotesConfig.ContainsEmote(p: string)
	while not EmotesConfig.isLoaded do
		task.wait()
	end

	return EmotesConfig.emoteNames[p] ~= nil
end

function EmotesConfig.GetNameFromId(p: number)
	while not EmotesConfig.isLoaded do
		task.wait()
	end

	local v = EmotesConfig.emoteIdsToEmote[tonumber(p)]

	if v then
		return v.Name
	end

	return nil
end

function EmotesConfig.GetEmoteFromId(p: number)
	while not EmotesConfig.isLoaded do
		task.wait()
	end

	local v = EmotesConfig.emoteIdsToEmote[tonumber(p)]
	return v or nil
end

function EmotesConfig.GetIsSyncableFromId(p: number)
	while not EmotesConfig.isLoaded do
		task.wait()
	end

	return EmotesConfig.emoteIdsToIsSyncable[tonumber(p)]
end

function EmotesConfig.GetFromName(p: string)
	while not EmotesConfig.isLoaded do
		task.wait()
	end

	return EmotesConfig.emoteNames[p]
end

function EmotesConfig.GetConfig()
	while not EmotesConfig.isLoaded do
		task.wait()
	end

	return EmotesConfig.cache
end

return EmotesConfig