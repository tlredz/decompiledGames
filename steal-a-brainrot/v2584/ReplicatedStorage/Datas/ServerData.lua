local RunService = game:GetService("RunService")
local ServerData = {}
local v = game.GameId == 7766605450 or game.GameId == 10593523064
RunService:IsStudio()
local v2 = nil
ServerData.RootPlaceId = v and 120148879522453 or 109983668079237
ServerData.VoiceServersPlaceId = v and 73226809349189 or 128762245270197
ServerData.NewPlayersPlaceId = v and 119602771011506 or 96342491571673
ServerData.DuelsPlaceId = v and 87093272648144 or 99606176102979
ServerData.ContentPlaceId = v and 81599947855682 or 99392882090073
ServerData.TsunamiPlaceId = v and 80417370177041 or 85621847059032
ServerData.TradePlazaPlaceId = v and 128349076447535 or 78906538690694
ServerData.TradePlazaProPlaceId = v and 136849450458826 or 119594317142884
ServerData.TradePlazaOgPlaceId = v and 83778377599866 or 128855408206367
ServerData.CheaterServersPlaceId = v and 103253223176950 or 123923334828954
ServerData.JumpLTMPlaceId = ServerData.TsunamiPlaceId
ServerData.AllPlaces = {
	ServerData.RootPlaceId,
	ServerData.VoiceServersPlaceId,
	ServerData.NewPlayersPlaceId,
	ServerData.DuelsPlaceId,
	ServerData.ContentPlaceId,
	ServerData.TsunamiPlaceId,
	ServerData.TradePlazaPlaceId,
	ServerData.TradePlazaProPlaceId,
	ServerData.TradePlazaOgPlaceId,
	ServerData.CheaterServersPlaceId
}

function ServerData.IsContentCreatorGame()
	return v2 == "ContentCreatorGame" or game.GameId == 8049249507
end

function ServerData.IsDevGame()
	return v2 == "DevGame" or v
end

function ServerData.IsProdGame()
	return v2 == "ProdServer" or game.GameId == 7709344486
end

function ServerData.IsNewPlayersServer()
	return v2 == "NewPlayersServer" or game.PlaceId == ServerData.NewPlayersPlaceId
end

function ServerData.IsCheaterServer()
	return v2 == "CheaterServer" or game.PlaceId == ServerData.CheaterServersPlaceId
end

function ServerData.IsDuelsServer()
	return v2 == "Duels" or game.PlaceId == ServerData.DuelsPlaceId
end

function ServerData.IsTsunamiServer()
	return v2 == "Tsunami" or v2 == "StealABrainrotEgg" or v2 == "JumpLTM" or game.PlaceId == ServerData.TsunamiPlaceId
end

function ServerData.IsStealABrainrotEggServer()
	return false
end

function ServerData.IsJumpLTMServer()
	if v2 == "JumpLTM" then
		return true
	elseif ServerData.JumpLTMPlaceId == 0 then
		return false
	else
		return game.PlaceId == ServerData.JumpLTMPlaceId
	end
end

function ServerData.IsTradePlaza()
	if v2 == "TradePlaza" or game.PlaceId == ServerData.TradePlazaPlaceId or ServerData.TradePlazaProPlaceId ~= 0 and game.PlaceId == ServerData.TradePlazaProPlaceId then
		return true
	elseif ServerData.TradePlazaOgPlaceId == 0 then
		return false
	else
		return game.PlaceId == ServerData.TradePlazaOgPlaceId
	end
end

function ServerData.GetTradePlazaPartition()
	if ServerData.TradePlazaProPlaceId ~= 0 and game.PlaceId == ServerData.TradePlazaProPlaceId then
		return "Pro"
	end

	if ServerData.TradePlazaOgPlaceId == 0 or game.PlaceId ~= ServerData.TradePlazaOgPlaceId then
		return "Normal"
	end

	return "OG"
end

function ServerData.GetTradePlazaPlaceId(p: string)
	if p == "Pro" then
		return ServerData.TradePlazaProPlaceId
	elseif p == "OG" then
		return ServerData.TradePlazaOgPlaceId
	end

	return ServerData.TradePlazaPlaceId
end

function ServerData.IsBiggerServer()
	return v2 == "BiggerServer" or game.PlaceId == ServerData.ContentPlaceId
end

function ServerData.GetServerType()
	if ServerData.IsJumpLTMServer() then
		return "JumpLTM"
	end

	if ServerData.IsTsunamiServer() then
		return "Tsunami"
	end

	if ServerData.IsDuelsServer() then
		return "Duels"
	end

	if ServerData.IsTradePlaza() then
		return "TradePlaza"
	end

	if ServerData.IsBiggerServer() then
		return "DefaultBigger"
	end

	return "Default"
end

function ServerData.GetRobloxServerType()
	assert(RunService:IsServer())

	if game.PrivateServerId == "" then
		return "StandardServer"
	end

	if game.PrivateServerOwnerId == 0 then
		return "ReservedServer"
	end

	return "VIPServer"
end

return ServerData