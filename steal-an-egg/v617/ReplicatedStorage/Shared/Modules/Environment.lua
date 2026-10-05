local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = {
	[10563114921] = 107778070777162,
	[10650210095] = 135851379034158,
	[10737944401] = 121856883734174
}
local v2 = {
	[10563114921] = 133470009013038,
	[10650210095] = 117867539925583,
	[10737944401] = 99280404043876
}
local v3 = nil

local function inUniverse(p: number)
	return game.GameId == p
end

local function fillsRole(p: string)
	local placeIds = v3.PlaceIds
	return placeIds ~= nil and placeIds[p] == game.PlaceId
end

-- equivalent calls inferred from this helper; original call sites unknown
local function placesFor(gameId: number)
	local default = v[gameId]

	if default == nil then
		return nil
	end

	return {
		Default = default,
		NewPlayerServer = v2[gameId]
	}
end

v3 = {
	PlaceIds = placesFor(game.GameId),
	GetPlaceIds = function()
		return v3.PlaceIds
	end,
	IsDevPlace = function()
		return game.GameId == 10650210095
	end,
	IsTestPlace = function()
		return game.GameId == 10737944401
	end,
	IsDev3Place = function()
		return game.GameId == 10767176144
	end,
	IsQAPurchasesEnabled = function()
		return (game.GameId == 10650210095 or game.GameId == 10737944401 or game.GameId == 10767176144) and ReplicatedStorage:GetAttribute("QA_PURCHASES") == true
	end,
	GetEnvironmentName = function()
		if game.GameId == 10563114921 then
			return "prod"
		end

		if game.GameId == 10737944401 then
			return "test"
		end

		return "dev"
	end,
	IsDefaultPlace = function()
		local placeIds = v3.PlaceIds
		return placeIds ~= nil and placeIds.Default == game.PlaceId
	end,
	IsNewPlayerServer = function()
		local placeIds = v3.PlaceIds
		return placeIds ~= nil and placeIds.NewPlayerServer == game.PlaceId
	end
}
return v3