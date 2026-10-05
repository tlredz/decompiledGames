local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local React = require(shared.React)
local State = require(parent.State)

local function useCurrentSong()
	local v = React.useContext(State.Context)
	local songOverrides = v.SongOverrides
	local sampleMode = v.SampleMode
	local song = v.Song
	local title2 = nil
	local artist2 = nil
	return React.useMemo(function()
		local isOverride = false

		if songOverrides and next(songOverrides) then
			local v5 = -1e999
			local song2 = nil
			local v6 = false
			local title = nil
			local artist = nil

			for _, songOverride in songOverrides do
				local priority = songOverride.Priority

				if not (v5 < priority) then
					continue
				end

				v6 = songOverride.SampleMode and true or false
				song2 = songOverride.Song
				title = songOverride.Title
				artist = songOverride.Artist
				v5 = priority
			end

			if song2 then
				sampleMode = sampleMode or v6
				isOverride = true
				song = song2
				title2 = title
				artist2 = artist
			end
		end

		return {
			Song = song,
			Title = title2,
			Artist = artist2,
			SampleMode = sampleMode,
			IsOverride = isOverride
		}
	end, { song, songOverrides, sampleMode })
end

return useCurrentSong