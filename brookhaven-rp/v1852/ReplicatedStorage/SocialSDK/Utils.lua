local Utils = {}

function Utils.createGameActivity(data)
	local PLAYING = Utils.ActivityType.PLAYING

	if data.type ~= nil then
		PLAYING = data.type
	end

	return {
		type = PLAYING,
		state = data.state,
		details = data.details or "Playing",
		assets = data.assets or nil,
		timestamps = data.timestamps or nil,
		platform = "desktop",
		party = data.party or nil,
		secret = data.secret or nil
	}
end

Utils.ActivityType = {
	PLAYING = 0,
	STREAMING = 1,
	LISTENING = 2,
	WATCHING = 3,
	COMPETING = 5
}
return Utils