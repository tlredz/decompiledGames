local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
game:GetService("Players")
local v = require3(ReplicatedStorage2:WaitForChild("ServerInfo"))
local v2 = require3(ReplicatedStorage2:WaitForChild("Shared"):WaitForChild("UniverseIds"))
return function()
	if v.isTutorialServer() or v.isTrainingServer() or (v.isRankedLobbyServer() or v.isRankedMatchServer()) then
		return false
	end

	if v.isDuelLobbyServer() or v.isDuelMatchServer() or (v.isDungeonsMatchServer() or v.isDungeonsLobbyServer()) then
		return false
	end

	if v.isTradingPlazaServer() or v.isRegionalTournamentMatch() then
		return false
	end

	if v.isLTMServer() then
		return require3(ReplicatedStorage2:WaitForChild("Shared"):WaitForChild("LTM")).getPriorityLTM().UseMapVoting
	end

	if v.isProServer() or v.isMobileServer() or v.isVoiceServer() or v.isTournamentEventServer() or game.PlaceId == v2.Default.PlaceId then
		return true
	end

	return false
end