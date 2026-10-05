local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MusicsConfig = require(ReplicatedStorage.Modules.Shared.DB.Musics.MusicsConfig)
require(ReplicatedStorage.Modules.Client.Music.MusicContext)
local MusicNavigationUtil = {
	getNextTrackId = function(p: number?)
		if not p then
			return nil
		end

		local config = MusicsConfig.GetConfig()

		for k, v in config do
			if v.AssetID ~= p then
				continue
			end

			local v2 = config[k % #config + 1]

			if v2 then
				return v2.AssetID
			end
		end

		return nil
	end,
	getPreviousTrackId = function(p: number?)
		if not p then
			return nil
		end

		local config = MusicsConfig.GetConfig()

		for k, v in config do
			if v.AssetID ~= p then
				continue
			end

			local v2 = config[(k - 2) % #config + 1]

			if v2 then
				return v2.AssetID
			end
		end

		return nil
	end
}

function MusicNavigationUtil.selectNext(object)
	local status = object:GetStatus()
	local nextTrackId = MusicNavigationUtil.getNextTrackId(status.trackId)

	if nextTrackId then
		object:Select(nextTrackId)
	end
end

function MusicNavigationUtil.selectPrevious(object)
	local status = object:GetStatus()
	local previousTrackId = MusicNavigationUtil.getPreviousTrackId(status.trackId)

	if previousTrackId then
		object:Select(previousTrackId)
	end
end

return MusicNavigationUtil