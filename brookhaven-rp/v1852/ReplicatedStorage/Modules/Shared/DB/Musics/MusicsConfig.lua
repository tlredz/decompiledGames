local MusicsConfig = {
	remoteConfigDirectory = "Musics/Config",
	isPublic = true,
	isLoaded = false,
	cache = nil,
	musicIdToMusic = {}
}
MusicsConfig.middlewares = {
	buildIdCache = function(items)
		for _, item in items do
			MusicsConfig.musicIdToMusic[tonumber(item.AssetID)] = item
		end

		return items
	end
}

function MusicsConfig.GetMusicFromId(p: number)
	while not MusicsConfig.isLoaded do
		task.wait()
	end

	return MusicsConfig.musicIdToMusic[tonumber(p)]
end

function MusicsConfig.IsMusicFree(p: number)
	while not MusicsConfig.isLoaded do
		task.wait()
	end

	local v = MusicsConfig.musicIdToMusic[tonumber(p)]

	if not v then
		return false
	end

	if v.IsFree then
		return true
	end

	return v.FreeCategory ~= nil and v.FreeCategory ~= nil
end

function MusicsConfig.GetConfig()
	while not MusicsConfig.isLoaded do
		task.wait()
	end

	return MusicsConfig.cache
end

return MusicsConfig