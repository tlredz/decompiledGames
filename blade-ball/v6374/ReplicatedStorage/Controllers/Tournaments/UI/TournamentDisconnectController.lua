local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
require3(ReplicatedStorage2.Shared.RankedSeasonData)
local v3 = require3(ReplicatedStorage2.ServerInfo)
local v4 = require3(ReplicatedStorage2.Shared.TournamentData)
local localPlayer = Players.LocalPlayer
local remoteEvent = v2:RemoteEvent("RejoinTournamentMatch")
local tournamentMatchDisconnected = localPlayer.PlayerGui:WaitForChild("TournamentMatchDisconnected")
local TournamentDisconnectController = {}

function TournamentDisconnectController:ShowRejoin(currentMatch)
	if self._currentMatch then
		return
	end

	self._currentMatch = currentMatch
	tournamentMatchDisconnected.Enabled = true
end

function TournamentDisconnectController:Close()
	self._currentMatch = nil
	tournamentMatchDisconnected.Enabled = false
end

function TournamentDisconnectController:Start()
	local v5 = v.Client:WaitReplion("Data")

	if v3.isTournamentLobbyServer() or v3.isTournamentMatchServer() then
		return
	end

	tournamentMatchDisconnected.Main.Abandon.Activated:Connect(function()
		self:Close()
	end)
	tournamentMatchDisconnected.Main.CloseButton.Activated:Connect(function()
		self:Close()
	end)
	local v6 = 0
	tournamentMatchDisconnected.Main.Rejoin.Activated:Connect(function()
		if not self._currentMatch then
			return
		end

		local now = os.clock()

		if now - v6 < 5 then
			return
		end

		v6 = now
		remoteEvent:FireServer(self._currentMatch.MatchUUID)
		self:Close()
	end)

	local function searchForMatch()
		if localPlayer:GetAttribute("InTournamentQueue") then
			return
		end

		local serverTimeNow = workspace:GetServerTimeNow()
		local v7 = nil
		local tournamentMatchHistory = v5:Get("TournamentMatchHistory")

		if not tournamentMatchHistory then
			return
		end

		for _, v8 in tournamentMatchHistory do
			local canceled = v8.Canceled
			local inProgress = v8.InProgress

			if canceled or not inProgress or serverTimeNow - (v8.FinalsStartTime or v8.StartTime) > v4.MAX_REJOIN_TIME or not (not v7 or v7.StartTime > v8.StartTime) then
				continue
			end

			v7 = v8
		end

		if v7 then
			self:ShowRejoin(v7)
		end
	end

	v5:OnChange("TournamentMatchHistory", searchForMatch)
	task.spawn(searchForMatch)
end

return TournamentDisconnectController