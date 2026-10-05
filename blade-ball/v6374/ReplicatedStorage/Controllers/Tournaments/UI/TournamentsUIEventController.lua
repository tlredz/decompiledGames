local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local v = require3(ReplicatedStorage2.Packages.Net)
local v2 = require3(ReplicatedStorage2.Common.Utils)
local v3 = require3(ReplicatedStorage2.Packages.Trove)
local v4 = require3(ReplicatedStorage2.Packages.Replion)
local v5 = require3(ReplicatedStorage2.Shared.ReplionUtils)
local v6 = require3(ReplicatedStorage2.ServerInfo)
local v7 = require3(ReplicatedStorage2.Shared.PlayerUtility)
local v8 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v9 = require3(ReplicatedStorage2.Shared.TournamentData)
require3(ReplicatedStorage2.Common.MarketplaceService)
local tournaments = ReplicatedStorage2.Controllers.Tournaments
local v10 = require3(tournaments.TournamentsController)
local v11 = require3(tournaments.UI.TournamentsUIController)
local v12 = require3(ReplicatedStorage2.ClientGameModules.FFlagClient)
local v13 = require3(ReplicatedStorage2.Controllers.Trading.TradeTokensController)
local localPlayer = Players.LocalPlayer
local event = v11.TabsFolder.Event
local scrollingFrame = event.ScrollingFrame
local template = scrollingFrame.UIListLayout.Template
local v14 = {}
local maid = v3.new()
local TournamentsUIEventController = {}

function TournamentsUIEventController:UpdateLeaderboard()
	maid:Clean()
	local v15, v16 = v10.Remotes.GetEventTournamentLeaderboard:InvokeServer()

	if not v15 then
		return
	end

	local v17 = {}

	for k, _ in v16 do
		table.insert(v17, k)
	end

	table.sort(v17, function(a, b)
		return v16[a].Trophies > v16[b].Trophies
	end)

	for k, v18 in v17 do
		local v19 = v16[v18]
		local v20 = maid:Add(template:Clone())
		v20.Rank.Text = `#{k}`
		v20.LayoutOrder = k

		if tostring(v18) == tostring(localPlayer.UserId) then
			v20.PlayerName.Text = localPlayer.Name
		else
			local text = v14[v18]

			if text then
				v20.PlayerName.Text = text
			else
				v20.PlayerName.Text = "..."
				local v22 = v18
				local v23 = v20
				task.spawn(function()
					local v24, v25 = v7:GetUsername(v22):await()

					if v24 and v23:IsDescendantOf(localPlayer) then
						v14[v22] = v25
						v23.PlayerName.Text = v25 or ""
					end
				end)
			end
		end

		v20.Headshot.ProfilePicture.Image = `rbxthumb://type=AvatarHeadShot&id={v18}&w=150&h=150`
		v20.TrophyCounter.Amount.Text = v2.ValueConvertor:AddCommas(v19.Trophies)

		for i = 1, 5 do
			v20.LostCount[`LostBox{i}`].X.Visible = i - 1 + v19.StrikesLeft < v9.DailyStrikes
		end

		v20.Parent = scrollingFrame
	end
end

function TournamentsUIEventController:Start()
	local function updateEventVisible()
		local v15 = v12:GetKey("TournamentStrikeEnabled") == true

		if event.Visible and not v15 then
			event.Visible = false
		end

		self._strikeTournamentEnabled = v15
		v11.ScreenGui.TopButtons.Event.Visible = v15
	end

	v12.DataUpdatedEvent:Connect(updateEventVisible)
	task.spawn(updateEventVisible)
	event.LeaveButton.Activated:Connect(function()
		v10.Remotes.TournamentReturnToLobby:FireServer()
	end)
	event.PlayButton.Visible = not v6.isTournamentMatchServer()
	event.LeaveButton.Visible = v6.isTournamentMatchServer()
	event.InfoButton.Activated:Connect(function()
		v11.ScreenGui.Info.Visible = true
	end)
	v11.ScreenGui.Info.Frame.Close.Activated:Connect(function()
		v11.ScreenGui.Info.Visible = false
	end)
	local v15 = v4.Client:WaitReplion("Data")
	v8:OnGuiOpen("Tournaments", function()
		self:UpdateLeaderboard()

		if not v15:Get("HasOpenedTournamentsUI") then
			v:Invoke("OpenedTournamentUIFirstTime")
		end
	end)
	v5.observeReplionPath(v15, "TournamentTickets", function(value)
		event.TrophyViewer.Amount.Text = v2.ValueConvertor:AddCommas(value or 0)
	end)
	local buyAttempts = v11.ScreenGui.BuyAttempts
	buyAttempts.Close.Activated:Connect(function()
		buyAttempts.Visible = false
	end)
	buyAttempts.Buy.Activated:Connect(function()
		v13:PromptPurchase(1762115858, Enum.InfoType.Product)
		buyAttempts.Visible = false
	end)
	local connection = nil
	v5.observeReplionPath(v15, "TournamentStrikes", function(p)
		if connection then
			connection:Disconnect()
			connection = nil
		end

		if p <= 0 then
			connection = v2.Thread.Every(1, function()
				local v16 = (v15:Get("LastTournamentStrikesReset") or 0) + 86400 - workspace:GetServerTimeNow()
				event.PlayButton.Label.Text = `Resets in:{v2.ValueConvertor:FormatTimeHHMMSS(v16)}`
			end)
		else
			event.PlayButton.Label.Text = "Play"
		end
	end)
	event.PlayButton.Activated:Connect(function()
		if not self._strikeTournamentEnabled then
			return
		end

		local v16, _ = v10.Remotes.JoinGlobalTournament:InvokeServer({
			type = "Event"
		})

		if v16 then
			v8:Close("Tournaments")
			v11:PromptGlobal()
		elseif (v15:Get("TournamentStrikes") or 0) <= 0 then
			buyAttempts.Visible = true
			buyAttempts.Buy.Visible = (v15:Get("TournamentStrikesPurchased") or 0) < 2
		end
	end)

	local function updateLocalPlayer()
		local tournamentStrikes = v15:Get("TournamentStrikes") or 0
		local tournamentTrophies = v15:Get("TournamentTrophies") or 0
		local localPlayer2 = event.LocalPlayer
		localPlayer2.Rank.Text = ""
		localPlayer2.PlayerName.Text = localPlayer.Name
		localPlayer2.Headshot.ProfilePicture.Image = `rbxthumb://type=AvatarHeadShot&id={localPlayer.UserId}&w=150&h=150`
		localPlayer2.TrophyCounter.Amount.Text = v2.ValueConvertor:AddCommas(tournamentTrophies)

		for i = 1, 5 do
			localPlayer2.LostCount[`LostBox{i}`].X.Visible = i - 1 + tournamentStrikes < v9.DailyStrikes
		end

		localPlayer2.Parent = event
	end

	v15:OnChange("TournamentStrikes", updateLocalPlayer)
	v15:OnChange("TournamentTrophies", updateLocalPlayer)
	task.spawn(updateLocalPlayer)
	local time = event.Timer.Time
	v2.Thread.Every(1, function()
		local serverTimeNow = workspace:GetServerTimeNow()
		local v16 = (serverTimeNow - v9.TOURNAMENTS_RELEASE_UNIX) / 1209600
		local v17 = v9.TOURNAMENTS_RELEASE_UNIX + math.ceil(v16) * 1209600
		time.Text = v2.ValueConvertor:FormatTimeWithDaysFull(v17 - serverTimeNow)
	end)
end

return TournamentsUIEventController