local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Packages.Replion)
local _ = ReplicatedStorage2.Shared.TournamentData
local TournamentsController = {}
TournamentsController.Remotes = {
	CreateTournamentRoom = v:RemoteFunction("CreateTournamentRoom"),
	JoinTournamentRoom = v:RemoteFunction("JoinTournamentRoom"),
	SearchTournamentRooms = v:RemoteFunction("SearchTournamentRooms"),
	JoinGlobalTournament = v:RemoteFunction("JoinGlobalTournament"),
	TournamentGoToNextServer = v:RemoteEvent("TournamentGoToNextServer"),
	TournamentReturnToLobby = v:RemoteEvent("TournamentReturnToLobby"),
	GetEventTournamentLeaderboard = v:RemoteFunction("GetEventTournamentLeaderboard"),
	TournamentGetRewards = v:RemoteFunction("TournamentGetRewards"),
	LeaveGlobalTournamentQueue = v:RemoteFunction("LeaveGlobalTournamentQueue"),
	TournamentSpectate = v:RemoteEvent("TournamentSpectate")
}
TournamentsController.TournamentReplion = nil

function TournamentsController:ObserveReplion(callback)
	local replion = v2.Client:GetReplion("Tournament")
	local v3

	if replion then
		v3 = callback(replion, false)
	else
		v3 = nil
	end

	local v4 = v2.Client:OnReplionAdded(function(p)
		if p._channel == "Tournament" then
			if replion == p then
				return
			end

			if v3 then
				replion = nil
				v3()
				v3 = nil
			end

			replion = p
			v3 = callback(p, true)
		end
	end)
	local v5 = v2.Client:OnReplionRemoved(function(p)
		if p._channel == "Tournament" then
			if replion == p then
				return
			end

			if v3 then
				replion = nil
				v3()
				v3 = nil
			end
		end
	end)
	return function()
		v4:Destroy()
		v5:Destroy()

		if v3 then
			v3()
			v3 = nil
		end
	end
end

function TournamentsController.HandleReplion(_, _) end

function TournamentsController:Start()
	self:ObserveReplion(function(tournamentReplion)
		self.TournamentReplion = tournamentReplion
		return function()
			self.TournamentReplion = nil
		end
	end)
end

return TournamentsController