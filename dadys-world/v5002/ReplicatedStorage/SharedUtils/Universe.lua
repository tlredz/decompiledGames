local _ = {
	LOBBY = "Lobby",
	GAME = "Game",
	ROLEPLAY = "Roleplay"
}
local placeId = game.PlaceId
local Universe = {
	TRANSACTION_QA_PLACE_IDS = {
		LOBBY = 130056003221956,
		ROLEPLAY = 92081680962610,
		GAME = 90277829760326
	}
}
local v = {
	[16116270224] = true,
	[16552821455] = true,
	[18984416148] = true
}
local v2 = {
	[6081694032] = true
}
local currentPlace = nil

for k, v5 in pairs({
	Lobby = {
		[16116270224] = true,
		[103859886184393] = true,
		[130056003221956] = true,
		[109747661202918] = true,
		[81859130340552] = true,
		[116444038034105] = true,
		[131674413462471] = true,
		[82275294116230] = true,
		[128508838222206] = true,
		[139246670272408] = true,
		[124783609374710] = true,
		[110218283693617] = true,
		[139737981377787] = true,
		[91699630509460] = true,
		[123578472252117] = true,
		[71946103689687] = true
	},
	Game = {
		[16552821455] = true,
		[86208660902318] = true,
		[90277829760326] = true,
		[17754702286] = true,
		[90308649853496] = true,
		[85432272336674] = true,
		[83158246224765] = true,
		[139756463992800] = true,
		[129131175066670] = true,
		[121680555900760] = true,
		[71899162366070] = true,
		[130935865683881] = true,
		[89952610916122] = true
	},
	Roleplay = {
		[18984416148] = true,
		[96720956644419] = true,
		[92081680962610] = true,
		[111391360367795] = true,
		[18984409256] = true,
		[96059811329290] = true
	}
}) do
	if not v5[placeId] then
		continue
	end

	currentPlace = k
	break
end

local v5 = currentPlace ~= nil

if currentPlace == nil then
	warn("PLACE ID IS NOT REGISTERED IN UNIVERSE. UPDATE Universe.lua ASAP.")
	local teleportDestinations = workspace:FindFirstChild("TeleportDestinations")
	local baseplateTrigger = workspace:FindFirstChild("BaseplateTrigger")
	currentPlace = teleportDestinations and "Roleplay" or baseplateTrigger and "Game" or "Lobby"
	warn("> AUTO DETECTED PLACE TYPE AS '" .. tostring(currentPlace) .. "', PLEASE ADD " .. tostring(placeId) .. " TO Universe.lua")
end

Universe.CurrentPlace = currentPlace

function Universe.IsLobby(_)
	return currentPlace == "Lobby"
end

function Universe.IsGame(_)
	return currentPlace == "Game"
end

function Universe.IsRoleplay(_)
	return currentPlace == "Roleplay"
end

function Universe.IsTransactionQA(_)
	for _, v6 in pairs(Universe.TRANSACTION_QA_PLACE_IDS) do
		if game.PlaceId == v6 then
			return true
		end
	end

	return false
end

function Universe.IsProductionPlace(_)
	return v[game.PlaceId] == true
end

function Universe:IsTestRealm()
	local RunService = game:GetService("RunService")

	if RunService:IsStudio() then
		return true
	end

	if v[game.PlaceId] then
		return false
	end

	if v2[game.GameId] or v5 and not v[game.PlaceId] then
		return true
	end

	return false
end

function Universe.GetPlaceSubversion(_)
	if Universe:IsTestRealm() then
		return string.format("_v%d", game.PlaceVersion)
	end

	return ""
end

return Universe