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
require3(ReplicatedStorage2.Shared.TournamentData)
require3(ReplicatedStorage2.Controllers.UI.SpectateController)
local tournaments = ReplicatedStorage2.Controllers.Tournaments
local v2 = require3(tournaments.Event.TournamentEventController)
require3(tournaments.UI.TournamentsUIController)
local v3 = require3(ReplicatedStorage2.Shared.ReplionUtils)
local localPlayer = Players.LocalPlayer
local eventTournamentEnd = localPlayer.PlayerGui:WaitForChild("EventTournamentEnd")
local RunService = game:GetService("RunService")

if RunService:IsStudio() or game.GameId ~= 4777817887 then
	local _ = print
end

local maid = v.new()
local TournamentEventUIEndController = {}

function TournamentEventUIEndController:Prompt(visible: boolean?)
	local tournamentReplion = v2.TournamentReplion

	if not tournamentReplion then
		return
	end

	maid:Clean()
	eventTournamentEnd.Enabled = true

	for k, v4 in tournamentReplion:Get("Winners"), nil, nil do
		print(k, v4, (typeof(v4)))
	end

	if visible == nil then
		visible = tournamentReplion:Find("Winners", localPlayer.UserId) ~= nil
	end

	eventTournamentEnd.YouWin.Visible = visible
	eventTournamentEnd.YouLost.Visible = not visible
	local rewardFrame = (visible and eventTournamentEnd.YouWin or eventTournamentEnd.YouLost).RewardFrame
	maid:Add(task.delay(0.5, function()
		local v4 = v2.Remotes.TournamentGetRewards:InvokeServer()

		if not v4 then
			return
		end

		local rewardTemplate = rewardFrame.UIListLayout.RewardTemplate

		for k, v5 in v4 do
			local v6 = maid:Add(rewardTemplate:Clone())
			v6.LayoutOrder = k
			v6.Reward.Image = v5.Icon or ""
			v6.Reward.Text.Text = v5.DisplayName or ""
			v6.Parent = rewardFrame
		end
	end))
end

function TournamentEventUIEndController:Start()
	v2:ObserveReplion("TournamentEvent", function(object2)
		maid:Add(v3.observeReplionPath(object2, "MatchEnded", function(p)
			if not p then
				return
			end

			self:Prompt()
		end))
		maid:Add(v3.observeReplionPath(object2, "GroupWinners", function(p)
			local groups = object2:Get("Groups")

			if not groups then
				return
			end

			for k, group in groups do
				local v4 = nil

				for _, list in group do
					v4 = table.find(list, localPlayer.UserId) ~= nil

					if v4 then
						break
					end
				end

				if not (v4 and p[k]) then
					continue
				end

				if table.find(p[k], localPlayer.UserId) ~= nil then
					break
				end

				self:Prompt(false)
				break
			end
		end))
		return function()
			maid:Clean()
		end
	end)
	eventTournamentEnd.YouWin.LobbyButton.Activated:Connect(function()
		v2.Remotes.TournamentReturnToLobby:FireServer()
	end)
	eventTournamentEnd.YouLost.LeaveButton.Activated:Connect(function()
		v2.Remotes.TournamentReturnToLobby:FireServer()
	end)
end

return TournamentEventUIEndController