local gameId = game.GameId
local placeId = game.PlaceId
local placeVersion = game.PlaceVersion
return table.freeze({
	GameId = gameId,
	PlaceId = placeId,
	PlaceVersion = placeVersion,
	ClientMajorVersion = 2,
	ClientMinorVersion = 23,
	ClientVersion = 131095
})