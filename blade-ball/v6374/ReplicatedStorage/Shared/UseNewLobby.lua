local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
RunService:IsClient()
local isServer = RunService:IsServer()
local v = require3(ReplicatedStorage2:WaitForChild("ServerInfo"))

local function UseNewLobby()
	if v.isTournamentMatchServer() then
		return true
	end

	if v.isDuelLobbyServer() then
		return false
	end

	if v.isFiftyPlayersServer() or isServer then
		return true
	end

	return not workspace:GetAttribute("NewLobbyDisabled")
end

return UseNewLobby