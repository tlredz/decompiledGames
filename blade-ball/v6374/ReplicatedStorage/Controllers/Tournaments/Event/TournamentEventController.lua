local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage3:WaitForChild("UserInputService"))
local GuiService = game:GetService("GuiService")
local v2 = require3(ReplicatedStorage2.Packages.Net)
local v3 = require3(ReplicatedStorage2.Packages.Replion)
require3(ReplicatedStorage2.Shared.ReplionUtils)
local v4 = require3(ReplicatedStorage2.Shared.Statable)
local v5 = require3(ReplicatedStorage2.ClientGameModules.GuiHandler)
local v6 = require3(ReplicatedStorage2.Packages.Observers)
local v7 = require3(ReplicatedStorage2.Common.Utils)
local v8 = require3(ReplicatedStorage2.Shared.FastUtils)
local v9 = require3(ReplicatedStorage2.Shared.ReplionUtils)
local fastTween = v8.fastTween
local v10 = require3(ReplicatedStorage2.Shared.TournamentEvent.TournamentEventData)
local v11 = require3(ReplicatedStorage2.Controllers.NotificationController)
local v12 = require3(ReplicatedStorage2.Controllers.GiftingController)
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local v13 = nil
local v14 = nil

local function getHoveredState(button)
	local state = v4.State(false)
	button.MouseEnter:Connect(function()
		state:Set(true)
	end)
	button.MouseLeave:Connect(function()
		state:Set(false)
	end)

	if button:IsA("GuiButton") then
		button.Activated:Connect(function()
			state:Set(false)
		end)
	end

	return state
end

local tournamentEvent = playerGui:WaitForChild("TournamentEvent")
local play = tournamentEvent.MainFrame.Frame.Views.Play
local remoteFunction = v2:RemoteFunction("JoinTournamentEventQueue")
local remoteFunction2 = v2:RemoteFunction("LeaveTournamentEventQueue")
local tournamentEventWaiting = playerGui:WaitForChild("TournamentEventWaiting")
local frame = tournamentEventWaiting.Frame
local connection = nil
local remoteEvent = v2:RemoteEvent("RequestTournamentEventStrikeReset")
v2:RemoteFunction("JoinTournamentEventParty")
local remoteFunction3 = v2:RemoteFunction("LeaveTournamentEventParty")
v2:RemoteFunction("SendTournamentEventInvite")
local TournamentEventController = {}
TournamentEventController.Remotes = {
	TournamentReturnToLobby = v2:RemoteEvent("TournamentEventReturnToLobby"),
	TournamentGetRewards = v2:RemoteFunction("TournamentEventGetRewards")
}
TournamentEventController.CurrentPage = v4.State("Play")
TournamentEventController.TournamentReplion = nil

function TournamentEventController:Update()
	if not v14 then
		return
	end

	local replion = v3.Client:GetReplion(v10.PartyReplionChannel)
	local players = replion and replion:Get("players") or { localPlayer }
	local v15 = (v14:Get("TournamentEventStrikes") or 0) < v10.Strikes.MaxStrikes

	for i = 1, v10.PlayersPerParty.Max do
		local player = players[i]
		local v16 = play.MyTeam.PlayersList[`Player{i}`]
		local leave = v16.Leave
		local visible

		if player then
			if player == localPlayer then
				visible = #players > 1
			else
				visible = false
			end
		else
			visible = player
		end

		leave.Visible = visible
		v16.AddPlayer.Visible = not player

		if i == 1 then
			local v18 = player == localPlayer
			play.PlayButton.Visible = v18 and v15
			play.ResetStrikes.Visible = v18 and not v15
		end

		if player then
			v16.Headshot.Visible = true
			v16.Headshot.Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=100&h=100`
			v16.PlayerName.Visible = true
			v16.PlayerName.Text = player.DisplayName
		else
			v16.Headshot.Visible = false
			v16.PlayerName.Visible = false
		end
	end
end

function TournamentEventController:UpdatePlayersInQueue()
	local queuePartition = localPlayer:GetAttribute("QueuePartition")
	local v15 = queuePartition and v13:Get(queuePartition)
	local numPlayers = v15 and v15.NumPlayers
	local lastUpdate = v15 and v15.LastUpdate

	if lastUpdate ~= nil then
		local _ = workspace:GetServerTimeNow() - lastUpdate <= 420
	end

	local visible

	if numPlayers then
		if numPlayers > 1 then
			visible = v7.FFlag.GetFFlag("TournamentEventQueueCountEnabled", true)
		else
			visible = false
		end
	else
		visible = numPlayers
	end

	local timer = tournamentEventWaiting.Frame.Timer
	local position

	if visible then
		position = UDim2.fromScale(0.5, 0.444)
	else
		position = UDim2.fromScale(0.5, 0.475)
	end

	timer.Position = position
	local timer2 = tournamentEventWaiting.Frame.Timer
	local size

	if visible then
		size = UDim2.fromScale(0.6, 0.24)
	else
		size = UDim2.fromScale(0.6, 0.35)
	end

	timer2.Size = size

	if visible then
		tournamentEventWaiting.Frame.PlayersInQueue.Text = `{numPlayers}+ players in queue`
	end

	tournamentEventWaiting.Frame.PlayersInQueue.Visible = visible
end

function TournamentEventController:OpenView(p2: string)
	self.CurrentPage:Set(p2)
end

function TournamentEventController:ObserveReplion(p: string, callback)
	local replion = v3.Client:GetReplion(p)
	local v15

	if replion then
		v15 = callback(replion, false)
	else
		v15 = nil
	end

	local v16 = v3.Client:OnReplionAdded(function(p2)
		if p2.Tags and table.find(p2.Tags, "TournamentEventParty") then
			if replion == p2 then
				return
			end

			if v15 then
				replion = nil
				v15()
				v15 = nil
			end

			replion = p2
			v15 = callback(p2, true)
		end
	end)
	local v17 = v3.Client:OnReplionRemoved(function(p2)
		if p2.Tags and table.find(p2.Tags, "TournamentEventParty") then
			if replion ~= p2 then
				return
			end

			if v15 then
				replion = nil
				v15()
				v15 = nil
			end
		end
	end)
	return function()
		v16:Destroy()
		v17:Destroy()

		if v15 then
			v15()
			v15 = nil
		end
	end
end

function TournamentEventController:Start()
	v14 = v3.Client:WaitReplion("Data")

	if not v14 then
		return
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateTickets()
		local text = v14:Get((`TournamentEvent{v10.TournamentId}Currency`)) or 0
		tournamentEvent.MainFrame.Frame.LeftButtons.Currency.Coins.Amount.Text = text
	end

	updateTickets() -- equivalent call inferred; original call site unknown
	v14:OnChange(`TournamentEvent{v10.TournamentId}Currency`, updateTickets)
	tournamentEvent.MainFrame.Frame.Close.Activated:Connect(function()
		v5:Close("TournamentEvent")
	end)
	workspace.Alive.ChildAdded:Connect(function(child)
		if child == localPlayer.Character then
			v5:Close("TournamentEvent")
		end
	end)
	local views = tournamentEvent.MainFrame.Frame.Views

	for _, guiObject in views:GetChildren() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local v15 = guiObject
		v4.setPropertyComputed(guiObject, "Visible", function(callback)
			return callback(self.CurrentPage) == v15.Name
		end)
		local timer = guiObject:FindFirstChild("Timer", true)
		local time = timer and timer:FindFirstChild("Time")

		if time then
			time:AddTag("TournamentEventTimer")
		end
	end

	for _, button in tournamentEvent.MainFrame.Frame.LeftButtons:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v15 = button
		button.Activated:Connect(function()
			if v15.Name == "CrateSpin" then
				v5:Open("TournamentEventCrate")
			else
				self:OpenView(v15.Name)
			end
		end)
		local v16 = button
		local v17 = getHoveredState(button)
		v4.Computed(function(callback)
			local v18 = callback(self.CurrentPage) == v16.Name or callback(v17)
			local v19 = v16
			local size

			if v18 then
				size = UDim2.fromScale(1.2078000000000002, 0.2519)
			else
				size = UDim2.fromScale(1.098, 0.229)
			end

			v19.Size = size
			v16.TextLabel.FontFace = Font.new(
				"rbxasset://fonts/families/SourceSansPro.json",
				Enum.FontWeight.Bold,
				Enum.FontStyle.Normal
			)
			local uIStroke = v16.TextLabel.UIStroke
			local color

			if v18 then
				color = Color3.fromRGB(79, 0, 118)
			else
				color = Color3.fromRGB(0, 0, 0)
			end

			uIStroke.Color = color
			return nil
		end)
	end

	local play2 = views.Play
	play2.PlayButton.Activated:Connect(function()
		local v15, v16 = remoteFunction:InvokeServer({
			AutoFill = true
		})

		if v15 then
			return
		end

		v7.Sounds:Play("error")
		v11:SendNotification(v16 or "Failed to join queue!")
	end)
	play2.ResetStrikes.Activated:Connect(function()
		remoteEvent:FireServer()
	end)
	play2.GiftStrikes.Activated:Connect(function()
		v12:SetGift("ResetTournamentEventStrikes")
	end)
	self:ObserveReplion(v10.PartyReplionChannel, function(object2)
		self:Update()
		local connection2 = object2:OnDataChange(function()
			self:Update()
		end)
		return function()
			self:Update()
			connection2:Disconnect()
		end
	end)
	self:Update()

	for _, guiObject in play2.MyTeam.PlayersList:GetChildren() do
		if not guiObject:IsA("GuiObject") then
			continue
		end

		local v15 = guiObject
		guiObject.AddPlayer.Activated:Connect(function()
			if not v15.AddPlayer.Visible then
				return
			end

			self.CurrentPage:Set("Invite")
		end)
		guiObject.Leave.Activated:Connect(function()
			remoteFunction3:InvokeServer()
		end)
	end

	v6.observeTagNoAncestry("TournamentEventEndTime", function(instance)
		instance:SetAttribute("EndTime", v10.EndTime.UnixTimestamp)
		return function()
			instance:SetAttribute("EndTime", nil)
		end
	end)
	v6.observeTagNoAncestry("TournamentEventTimer", function(p)
		local connection2 = nil
		connection2 = v7.Thread.Every(1, function()
			local v15 = v10.EndTime.UnixTimestamp - workspace:GetServerTimeNow()

			if v15 <= 0 then
				connection2:Disconnect()
			end

			p.Text = v7.ValueConvertor:FormatTimeWithDaysFull(v15)
		end)
		return function()
			if connection2.Connected then
				connection2:Disconnect()
			end
		end
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function onQueueTypeChanged()
		self:UpdatePlayersInQueue()
	end

	v13 = v3.Client:WaitReplion("MatchmakingPlayerCounts")
	v13:OnDataChange(function()
		onQueueTypeChanged() -- equivalent call inferred; original call site unknown
	end)
	localPlayer:GetAttributeChangedSignal("QueuePartition"):Connect(onQueueTypeChanged)
	onQueueTypeChanged() -- equivalent call inferred; original call site unknown
	v6.observeAttribute(localPlayer, "InTournamentEventQueue", function(_)
		self:ShowQueue()
		return function()
			if connection then
				connection:Disconnect()
				connection = nil
			end

			tournamentEventWaiting.Enabled = false
		end
	end)
	tournamentEventWaiting.Frame.Cancel.Activated:Connect(function()
		tournamentEventWaiting.Frame.Cancel.Active = false
		local inTournamentEventQueue = localPlayer:GetAttribute("InTournamentEventQueue")
		localPlayer:SetAttribute("InTournamentEventQueue", nil)

		if not remoteFunction2:InvokeServer() then
			localPlayer:SetAttribute("InTournamentEventQueue", inTournamentEventQueue)
		end

		tournamentEventWaiting.Frame.Cancel.Active = true
	end)
	frame.Hide.Activated:Connect(function()
		frame.Hide.Visible = false
		tournamentEventWaiting.Show.Visible = true
		local uDim = UDim2.fromOffset(0, GuiService.TopbarInset.Height)

		if not v.TouchEnabled then
			uDim = UDim2.fromOffset(0, 4)
		end

		fastTween(tournamentEventWaiting.Show, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Position = UDim2.fromScale(0.5, 0) + uDim
		})
		fastTween(frame, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 0)
		})
	end)
	tournamentEventWaiting.Show.Activated:Connect(function()
		frame.Hide.Visible = true
		tournamentEventWaiting.Show.Visible = false
		fastTween(tournamentEventWaiting.Show, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			Position = UDim2.fromScale(0.5, 0.225)
		})
		fastTween(frame, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0) + UDim2.fromOffset(0, GuiService.TopbarInset.Height)
		})
	end)
	self:ObserveReplion("TournamentEvent", function(tournamentReplion)
		self.TournamentReplion = tournamentReplion
		return function()
			self.TournamentReplion = nil
		end
	end)
	v9.observeReplionPath(v14, "TournamentEventStrikes", function(value)
		local v15 = value or 0

		for i = 1, v10.Strikes.MaxStrikes do
			local visible = i <= v15
			local dailyStrike = play2.DailyStrikes[tostring(i)]
			dailyStrike.HoverImage = visible and "rbxassetid://101827596158319" or "rbxassetid://85902594598634"
			dailyStrike.Image = visible and "rbxassetid://101102630128430" or "rbxassetid://96437766135441"
			dailyStrike.CloseText.Visible = visible
		end

		self:Update()
	end)

	if v10.Strikes.Enabled then
		v7.Thread.Every(1, function()
			local v15 = math.ceil((math.max(
				(v14:Get("TournamentEventStrikesReset") or 0) - workspace:GetServerTimeNow(),
				0
			)))
			play2.DailyStrikesTimer.Text = `Daily Strikes (Resets in {v7.ValueConvertor:FormatTimeHHMMSS(v15)})`
		end)
	end

	if not require3(ReplicatedStorage2.ServerInfo).isTournamentEventServer() then
		return
	end

	local roundKillCount = playerGui:WaitForChild("RoundKillCount")
	roundKillCount.Enabled = true
	roundKillCount.UIPadding.PaddingTop = UDim.new(0, 0)

	if v10.PlayersPerParty.Max == 1 then
		roundKillCount.Enabled = false
		roundKillCount.TeamsLeft.Visible = false
		roundKillCount.YourTeam.Visible = false
	else
		v6.observeAttribute(ReplicatedStorage2, "TournamentEventTeamsAlive", function(p)
			roundKillCount.TeamsLeft.Text = `TEAMS LEFT: {p}`
		end)
	end

	local v15 = nil

	for _, list in v3.Client:WaitReplion("TournamentEvent"):Get("Teams"), nil, nil do
		if not table.find(list, localPlayer.UserId) then
			continue
		end

		v15 = list
		break
	end

	if not v15 then
		return
	end

	for k, v17 in v15 do
		local clone = roundKillCount.Grid.UIGridLayout.Player:Clone()
		clone.Parent = roundKillCount.Grid
		clone.LayoutOrder = k
		clone.Content.PlayerIcon.Thumbnail.Image = `rbxthumb://type=AvatarHeadShot&id={v17}&w=150&h=150`
		clone.Dead.PlayerIcon.Thumbnail.Image = `rbxthumb://type=AvatarHeadShot&id={v17}&w=150&h=150`
		clone.Content.Score.Visible = false
		clone.Content.Score.Text = "0"
		clone.Dead.Visible = true
		local v18 = v17
		v6.observePlayer(function(p)
			if p.UserId ~= v18 then
				return
			end

			local v20 = v6.observeCharacter(p, function(p2, p3)
				local v21 = v6.observeProperty(p3, "Parent", function(p4)
					if p4 == workspace.Alive then
						clone.Dead.Visible = false
						clone.Content.Score.Visible = true
					end

					return function()
						clone.Content.Score.Visible = false
						clone.Dead.Visible = true
					end
				end)
				return function()
					v21()
				end
			end)
			v6.observeAttribute(p, "Kills", function(text)
				clone.Content.Score.Text = text
				return function() end
			end)
			return function()
				v20()
			end
		end)
	end
end

function TournamentEventController:ShowQueue()
	tournamentEventWaiting.Enabled = true
	local count = 0

	if connection then
		connection:Disconnect()
	end

	connection = v7.Thread.Every(1, function()
		count += 1
		frame.Timer.Text = string.format("%.2i:%.2i", math.floor(count / 60), count % 60)
	end)
end

return TournamentEventController