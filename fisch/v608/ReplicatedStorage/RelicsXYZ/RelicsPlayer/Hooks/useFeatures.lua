local shared = script:FindFirstAncestor("RelicsXYZ").Shared
local React = require(shared.React)
local parent = script.Parent
local useTagged = require(parent.useTagged)
local useAttribute = require(parent.useAttribute)

-- equivalent calls inferred from this helper; original call sites unknown
local function useBoolean(p, p2: string, flag: boolean?)
	return useAttribute(p, p2, function(p3)
		if type(p3) == "boolean" then
			return p3
		end

		return flag or false
	end)
end

local function useFeatures()
	local v = useTagged("RelicsFeatures")[1]
	local v2 = useTagged("RelicsUGCSkin")[1]
	local v3 = useTagged("RelicsEmote")[1]
	local v4 = useTagged("RelicsAura")[1]
	local v5 = useTagged("RelicsPlaylist")[1]
	local v7 = useBoolean(v, "RelicsPlaylists", nil) -- equivalent call inferred; original call site unknown
	local v8 = nil
	local v9 = useAttribute(v, "Playlists", function(p)
		if type(p) == "boolean" then
			return p
		end

		return v8 or false
	end) or v7
	local v11 = useBoolean(v, "Emotes", false) -- equivalent call inferred; original call site unknown
	local v13 = useBoolean(v, "Auras", false) -- equivalent call inferred; original call site unknown
	local v15 = useBoolean(v, "Skins", false) -- equivalent call inferred; original call site unknown

	if not v then
		v11 = true
		v13 = true
		v15 = true
	end

	local emotes = v11 and (v3 and true or false)
	local auras = v13 and (v4 and true or false)
	local skins = v15 and (v2 and true or false)
	local playlists = v9 and (v5 and true or false)
	local spectrogram = useBoolean(v, "Spectrogram", true) -- equivalent call inferred; original call site unknown
	local favorites = useBoolean(v, "Favorites", true) -- equivalent call inferred; original call site unknown
	local autoPlay = useBoolean(v, "AutoPlay", true) -- equivalent call inferred; original call site unknown
	local startActive = useBoolean(v, "StartActive", false) -- equivalent call inferred; original call site unknown
	local publicPlaylists = useBoolean(v, "PublicPlaylists", false) -- equivalent call inferred; original call site unknown
	local v30 = false
	local emoteWheel = useAttribute(v, "EmoteWheel", function(p)
		if type(p) == "boolean" then
			return p
		end

		return v30 or false
	end) and (emotes or auras or skins)
	return React.useMemo(function()
		return {
			Spectrogram = spectrogram,
			Favorites = favorites,
			AutoPlay = autoPlay,
			StartActive = startActive,
			PublicPlaylists = publicPlaylists,
			EmoteWheel = emoteWheel,
			Playlists = playlists,
			Emotes = emotes,
			Skins = skins,
			Auras = auras
		}
	end, {
		spectrogram,
		favorites,
		autoPlay,
		publicPlaylists,
		emoteWheel,
		playlists,
		emotes,
		skins,
		auras
	})
end

return useFeatures