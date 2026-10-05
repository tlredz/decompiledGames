local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
require3(ReplicatedStorage2.Packages.Net)
require3(ReplicatedStorage2.Common.Utils)
local v = require3(ReplicatedStorage2.Packages.Trove)
require3(ReplicatedStorage2.Packages.Replion)
local v2 = require3(ReplicatedStorage2.Shared.ReplionUtils)
local v3 = require3(ReplicatedStorage2.Shared.TournamentData)
require3(ReplicatedStorage2.Controllers.UI.SpectateController)
local tournaments = ReplicatedStorage2.Controllers.Tournaments
local v4 = require3(tournaments.TournamentsController)
require3(tournaments.UI.TournamentsUIController)
local localPlayer = Players.LocalPlayer
local tournamentEnd = localPlayer.PlayerGui:WaitForChild("TournamentEnd")
local RunService = game:GetService("RunService")
local fn = not RunService:IsStudio() and game.GameId == 4777817887 and function(...) end or print
local maid = v.new()
local TournamentsUIEndController = {}

function TournamentsUIEndController:Prompt()
	local tournamentReplion = v4.TournamentReplion

	if not tournamentReplion then
		return
	end

	maid:Clean()
	tournamentEnd.Enabled = true
	local visible = ((tournamentReplion:Get("PlayersWin") or {})[localPlayer.Name] or 0) >= v3.WinsNeededToWin
	tournamentEnd.YouWin.Visible = visible
	tournamentEnd.YouLost.Visible = not visible
	local rewardFrame = (visible and tournamentEnd.YouWin or tournamentEnd.YouLost).RewardFrame
	local isFinalServer = tournamentReplion:Get("IsFinalServer")
	maid:Add(task.delay(0.5, function()
		local v6 = v4.Remotes.TournamentGetRewards:InvokeServer()

		if not v6 then
			return
		end

		local rewardTemplate = rewardFrame.UIListLayout.RewardTemplate

		for k, v7 in v6 do
			local v8 = maid:Add(rewardTemplate:Clone())
			v8.LayoutOrder = k
			v8.Reward.Image = v7.Icon or ""
			v8.Reward.Text.Text = v7.DisplayName or ""
			v8.Parent = rewardFrame
		end
	end))

	if visible then
		tournamentEnd.YouWin.FinalButton.Visible = not isFinalServer
		tournamentEnd.YouWin.LobbyButton.Visible = isFinalServer
		tournamentEnd.YouWin.FinalButton.Text.Text = isFinalServer and "Leave" or "Go to Final"
		maid:Add(task.delay(10, function()
			v4.Remotes.TournamentReturnToLobby:FireServer()
		end))
	else
		local isSpectator = localPlayer:GetAttribute("IsSpectator")
		fn("spectate should be visible:", not isFinalServer)
		fn("is spectator:", isSpectator)
		local visible2 = not (isSpectator or isFinalServer)
		tournamentEnd.YouLost.SpectateButton.Visible = visible2

		if not visible2 then
			tournamentEnd.YouLost.LeaveButton.Position = UDim2.fromScale(0.5, 0.842)
		end

		tournamentEnd.YouLost.WinFade.Title.Text = isSpectator and "Match ended" or "You Lost"
		tournamentEnd.YouLost.LeaveButton.Position = isSpectator and UDim2.fromScale(0.5, 0.842) or UDim2.fromScale(
			0.232,
			0.842
		)
	end
end

function TournamentsUIEndController:Start()
	v4:ObserveReplion(function(p)
		maid:Add(v2.observeReplionPath(p, "MatchEnded", function(p2)
			if not p2 then
				return
			end

			self:Prompt()
		end))
		return function()
			maid:Clean()
		end
	end)
	tournamentEnd.YouWin.FinalButton.Activated:Connect(function()
		v4.Remotes.TournamentGoToNextServer:FireServer()
	end)
	tournamentEnd.YouWin.LobbyButton.Activated:Connect(function()
		v4.Remotes.TournamentReturnToLobby:FireServer()
	end)
	tournamentEnd.YouLost.LeaveButton.Activated:Connect(function()
		v4.Remotes.TournamentReturnToLobby:FireServer()
	end)
	tournamentEnd.YouLost.SpectateButton.Activated:Connect(function()
		fn("clicked spectate")
		v4.Remotes.TournamentSpectate:FireServer()
	end)
end

return TournamentsUIEndController