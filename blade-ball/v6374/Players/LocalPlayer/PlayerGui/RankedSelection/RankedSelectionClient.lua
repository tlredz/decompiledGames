local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local remotes = ReplicatedStorage.Remotes
local shared = ReplicatedStorage.Shared

while not workspace:GetAttribute("ClientStarted") do
	workspace:GetAttributeChangedSignal("ClientStarted"):Wait()
end

local RankData = require(shared.RankData)
local RankedSeasonData = require(shared.RankedSeasonData)
local FFlagClient = require(ReplicatedStorage.ClientGameModules.FFlagClient)
local RankedPenaltyController = require(ReplicatedStorage.Controllers.Ranked.RankedPenaltyController)
local Replion = require(ReplicatedStorage.Packages.Replion)
local v = Replion.Client:WaitReplion("Data")
local v2 = Replion.Client:WaitReplion("PartyData")
local GuiHandler = require(ReplicatedStorage.ClientGameModules.GuiHandler)
local Net = require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Controllers.Ranked.RankedQueueController)
local RankedSignalController = require(ReplicatedStorage.Controllers.Ranked.RankedSignalController)
local Utils = require(ReplicatedStorage.Common.Utils)
local NotificationController = require(ReplicatedStorage.Controllers.NotificationController)
local autoQueueRankType = RankedSeasonData.GetRankedType()
local openMainMenuSignal = RankedSignalController:GetOpenMainMenuSignal()
local updateRankedMenuSignal = RankedSignalController:GetUpdateRankedMenuSignal()
local remoteEvent = Net:RemoteEvent("PlaceTeleport")
local v3 = nil
task.defer(function()
	v3 = Net:RemoteFunction("PartyServiceCreatePartyWait")
end)
require(script.LeaderboardLoader)
require(script.HistoryLoader)
require(script.StatsLoader)
local localPlayer = game.Players.LocalPlayer
local searching = script.Parent:WaitForChild("Searching")
local periods = searching:WaitForChild("Periods")
local page = script.Parent.Page
local windows = page.Windows
local playInfo = script.Parent.PlayInfo
local playButton = playInfo.PlayButton
local partyButton = playInfo.PartyButton
local leaveButton = playInfo.LeaveButton
local closeButton = page.CloseButton
local partyInvitePrompt = script.Parent.PartyInvitePrompt
local leaderboard = page.Windows.Leaderboard
local history = page.Windows.History
local statistics = page.Windows.Statistics
local party = page.Windows.Party
local list = party.List
local playerList = list.PlayerList
local main = list.Main
local options = main.Options
local _ = options.MyPartyButton
local _ = options.InvitesButton
local _ = main.Title
local scroll = main.Scroll
local template = scroll.UIListLayout.Template
local type = playerList.SearchBarBox.Type
local scroll2 = playerList.Scroll
local template2 = scroll2.UIListLayout.Template
local gamemodes = page.Windows.Gamemodes
local list2 = gamemodes.List
local FFA = list2.FFA
local duo = list2.Duo
local currentElo = FFA.Top.CurrentElo
local playerRank = FFA.Bottom.PlayerRank
local currentElo2 = duo.Top.CurrentElo
local playerRank2 = duo.Bottom.PlayerRank
local play = page.Windows.Play
local list3 = play.List
local title = list3.Title
local template3 = title.UIListLayout.Template
local inviteTemplate = title.UIListLayout.InviteTemplate
local frame = list3.Frame
local _ = frame.Title
local _ = frame.Scroll.UIListLayout.Template
local playButton2 = list3.PlayButton
local modeButton = list3.ModeButton
local cancelButton = list3.CancelButton
local regionSelection = play.RegionSelection
local rankedType = RankedSeasonData.GetRankedType()
script.Parent.Enabled = false
local ServerInfo = require(ReplicatedStorage.ServerInfo)
local rankedLobbyServer = ServerInfo.isRankedLobbyServer()
local v4 = {
	[play] = "Play",
	[leaderboard] = "Ranks",
	[statistics] = "Stats",
	[history] = "Matches",
	[party] = "Party"
}
local v5 = {
	HistoryButton = history,
	PlayButton = play,
	StatisticsButton = statistics,
	RankedButton = leaderboard
}
local v6 = {}
local autoQueueMode = "FFA"
local v7 = 0
local v8 = nil
local playerRemovingConnection = nil
local v9 = {
	FFA = false,
	Duo = false,
	Duel = false
}
local v10 = "Auto"

for k, v11 in v5 do
	v6[v11] = k
end

local v11 = false

function ToggleWindow(p)
	for _, guiObject in windows:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject.Visible = guiObject == p
		end
	end

	page.Title.Text = v4[p] or ""
	page.Title.Visible = p ~= gamemodes
	local tabs = page.Tabs
	tabs.Visible = p ~= gamemodes and p ~= party
	page.LeaderboardRewards.Visible = p == leaderboard
	playInfo.Visible = playInfo == p
	page.Visible = playInfo ~= p

	for _, button in page.Tabs:GetChildren() do
		if button:IsA("GuiButton") then
			button.BackgroundColor3 = button.Name == v6[p] and Color3.fromRGB(43, 71, 161) or Color3.fromRGB(
				63,
				107,
				238
			)
		end
	end

	if p ~= party then
		v11 = false
	end
end

function DeployPlayerCard(player)
	if scroll2:FindFirstChild(player.Name) or player == localPlayer then
		return
	end

	local clone = template2:Clone()
	task.spawn(function()
		local userThumbnailAsync, v12 = Players:GetUserThumbnailAsync(
			player.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size420x420
		)
		local box = clone:FindFirstChild("Box")

		if box then
			box.Icon.Image = v12 and userThumbnailAsync or ""
		end
	end)
	clone.Name = player.Name
	clone.PlayerName.Text = player.Name
	clone.PlayerDisplay.Text = `@{player.DisplayName}`
	clone.Visible = not type:IsFocused()
	clone.Activated:Connect(function()
		remotes.SendPartyInvite:FireServer(player, autoQueueRankType)
	end)
	clone.Parent = scroll2
end

function DeployPartyMember(p)
	if scroll:FindFirstChild(p.UserId) then
		return
	end

	local clone = template:Clone()
	task.spawn(function()
		local userThumbnailAsync, v12 = Players:GetUserThumbnailAsync(
			p.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size420x420
		)
		local box = clone:FindFirstChild("Box")

		if box then
			box.Icon.Image = v12 and userThumbnailAsync or ""
		end
	end)
	clone.Name = p.UserId
	clone.PlayerName.Text = p.Name
	clone.Parent = scroll
end

function DeployPlayParty(p, p2)
	local v12 = title:FindFirstChild(p.UserId) or template3:Clone()
	local banner = v12.Banner
	local v13 = p2[autoQueueMode]
	local rank = RankData.GetRank(v13)
	local inParty = localPlayer:GetAttribute("InParty")
	local v14 = not inParty or inParty == tostring(p.UserId)
	local v15 = inParty == tostring(localPlayer.UserId)
	local kick = v12.Kick
	local v16 = inParty and v15 and p ~= localPlayer
	local v17 = inParty and not v15 and p == localPlayer
	kick.Label.Text = v17 and "Leave" or "Kick"
	kick.Visible = v16 or v17
	kick.Activated:Connect(function()
		remotes.LeaveParty:FireServer()
	end)
	task.spawn(function()
		local userThumbnailAsync, v18 = Players:GetUserThumbnailAsync(
			p.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size420x420
		)
		local playerAvatarIcon = banner:FindFirstChild("PlayerAvatarIcon")

		if playerAvatarIcon then
			playerAvatarIcon.Image = v18 and userThumbnailAsync or ""
		end
	end)
	v12.Name = p.UserId
	banner.PlayerRankIcon.Image = rank.Icon
	banner.PlayerRank.Text = rank.Name
	banner.PlayerRank.TextColor3 = rank.TextColor
	banner.PlayerElo.Text = v13 or "???"
	banner.PlayerName.Text = `{v14 and "👑" or ""} {p.Name}`
	v12.Parent = title

	if rankedType == "NoAbility" then
		list3.CurrentMode.Mode.Text = `No Ability {RankedSeasonData.Modes[autoQueueMode].DisplayName}`
	else
		list3.CurrentMode.Mode.Text = RankedSeasonData.Modes[autoQueueMode].DisplayName
	end
end

function OnPartyInvite(p)
	local userThumbnailAsync, v12 = Players:GetUserThumbnailAsync(
		p.UserId,
		Enum.ThumbnailType.HeadShot,
		Enum.ThumbnailSize.Size420x420
	)
	v7 = 30
	v8 = p

	if playerRemovingConnection then
		playerRemovingConnection:Disconnect()
	end

	playerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
		if player == p then
			v7 = 0
		end
	end)
	partyInvitePrompt.Visible = true
	partyInvitePrompt.Icon.Image = v12 and userThumbnailAsync or ""
	partyInvitePrompt.PlayerName.Text = p.Name
end

function SearchResults()
	for _, child in scroll2:GetChildren() do
		if not child:IsA(template2.ClassName) then
			continue
		end

		local v12 = string.find(string.lower(child.PlayerName.Text), string.lower(type.Text), 1, true)
		local v13 = string.find(string.lower(child.PlayerDisplay.Text), string.lower(type.Text), 1, true)
		child.Visible = v12 or v13
	end
end

function UpdateLocalElo()
	rankedType = RankedSeasonData.GetRankedType()
	local currentSeason = RankedSeasonData.GetCurrentSeason(rankedType)
	local v12 = v:Get({ "Elo", rankedType, (`Season{currentSeason}`) })
	title:FindFirstChild(localPlayer.Name)
	local rank = RankData.GetRank(v12.rankedTypeFFA)
	local rank2 = RankData.GetRank(v12.Duo)
	currentElo.Text = `{v12.FFA} Elo`
	playerRank.Text = rank.Name
	playerRank.TextColor3 = rank.TextColor
	currentElo2.Text = `{v12.Duo} Elo`
	playerRank2.TextColor3 = rank2.TextColor
	playerRank2.Text = rank2.Name
	DeployPlayParty(localPlayer, v12)
end

function DisplayParty()
	local parties = v2:Get("Parties")
	local inParty = localPlayer:GetAttribute("InParty")
	local v12 = inParty and parties[inParty] or parties[tostring(localPlayer.UserId)] or {
		Members = {}
	}
	autoQueueMode = inParty and "Duo" or autoQueueMode

	for k, _ in v12.Members do
		DeployPartyMember(Players:GetPlayerByUserId(k))
	end

	local count = 0

	for k, member in v12.Members do
		count += 1
		DeployPlayParty(Players:GetPlayerByUserId(k), member)
	end

	for _, child in scroll:GetChildren() do
		if not child:IsA(template.ClassName) or v12.Members[child.Name] then
			continue
		end

		child:Destroy()
	end

	for _, child in title:GetChildren() do
		if not child:IsA(template3.ClassName) or child.Name == localPlayer.Name or v12.Members[child.Name] then
			continue
		end

		child:Destroy()
	end

	if count == 0 then
		local clone = inviteTemplate:Clone()
		clone.Parent = title
		clone.Invite.Activated:Connect(function()
			ToggleWindow(party)
		end)
	end

	partyButton.Visible = not inParty
	leaveButton.Visible = inParty

	if partyInvitePrompt.Visible then
		if not (rankedLobbyServer or page.Visible) then
			script.Parent.Enabled = false
			page.Visible = true
		end

		partyInvitePrompt.Visible = false
	end

	UpdateLocalElo()
end

for _, button in page.Tabs:GetChildren() do
	if not button:IsA("GuiButton") then
		continue
	end

	local v12 = button
	button.Activated:Connect(function()
		ToggleWindow(v5[v12.Name])
	end)
end

playButton.Activated:Connect(function()
	ToggleWindow(play)
end)
partyButton.Activated:Connect(function()
	v11 = true
	ToggleWindow(party)
end)
leaveButton.Activated:Connect(function()
	remotes.LeaveParty:FireServer()
end)
partyInvitePrompt.Activated:Connect(function()
	remotes.AcceptPartyInvite:FireServer(v8)
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function joinQueue(autoQueueRankType2: string?)
	if not v9[autoQueueMode] then
		remotes.JoinQueue:FireServer("Ranked", autoQueueMode, autoQueueRankType2 or autoQueueRankType, v10)
	end
end

playButton2.Activated:Connect(function()
	joinQueue() -- equivalent call inferred; original call site unknown
end)

local function leaveQueue(p: string)
	local v12 = p or localPlayer:GetAttribute("QueueType") or "Ranked"
	local v13

	if v12 == "Ranked" then
		v13 = autoQueueMode
	else
		v13 = localPlayer:GetAttribute("QueueGameMode")
	end

	remotes.LeaveQueue:FireServer(v12, v13)

	if v12 == "Ranked" then
		openMainMenuSignal:Fire(true)
	end
end

cancelButton.Activated:Connect(function()
	local v12 = autoQueueMode
	remotes.LeaveQueue:FireServer("Ranked", v12)
	openMainMenuSignal:Fire(true)
end)
_G.LeaveRankedQueue = leaveQueue
modeButton.Activated:Connect(function()
	ToggleWindow(gamemodes)
end)
closeButton.Activated:Connect(function()
	if rankedLobbyServer then
		local toggleWindow = ToggleWindow
		local v12

		if gamemodes.Visible or party.Visible and not v11 then
			v12 = play
		else
			v12 = playInfo
		end

		toggleWindow(v12)
	elseif party.Visible then
		ToggleWindow(play)
	else
		script.Parent.Enabled = false
	end
end)
type:GetPropertyChangedSignal("Text"):Connect(SearchResults)

for _, v12 in Players:GetPlayers() do
	task.spawn(DeployPlayerCard, v12)
end

local clone = inviteTemplate:Clone()
clone.Parent = title
clone.Invite.Activated:Connect(function()
	ToggleWindow(party)
end)
game.Players.PlayerAdded:Connect(DeployPlayerCard)
game.Players.PlayerRemoving:Connect(function(player)
	local child = scroll2:FindFirstChild(player.Name)

	if child then
		child:Destroy()
	end
end)
ToggleWindow(rankedLobbyServer and playInfo or statistics)

if not rankedLobbyServer then
	for _, guiObject in page.Tabs:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject.Visible = false
		end
	end

	playInfo.Visible = false
end

script.Parent.Enabled = rankedLobbyServer
script.Parent:GetPropertyChangedSignal("Enabled"):Connect(function()
	if script.Parent.Enabled then
		playInfo.Visible = rankedLobbyServer and not play.Visible
	end
end)
openMainMenuSignal:Connect(function(enabled: boolean)
	script.Parent.Enabled = enabled
	ToggleWindow(play)

	for _, guiObject in page.Tabs:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject.Visible = true
		end
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function updateRegionVisibility()
	local inParty = localPlayer:GetAttribute("InParty")
	local v12 = not inParty or inParty == tostring(localPlayer.UserId)
	regionSelection.Visible = Utils.FFlag.GetFFlag("RankedRegionSelectEnabled", false) and v12
end

local function updateParty()
	DisplayParty()
	local inParty = localPlayer:GetAttribute("InParty")
	list3.FFA.LockedOverlay.Visible = not (inParty or v9.FFA)
	list3.Duel.LockedOverlay.Visible = not (inParty or v9.Duel)
	updateRegionVisibility() -- equivalent call inferred; original call site unknown
end

local function selectMode(p: string)
	if v9[p] then
		Utils.Sounds:Play("error")
		return
	end

	remotes.SwitchMode:FireServer(p)
	autoQueueMode = p
	ToggleWindow(play)
	UpdateLocalElo()

	for _, v12 in { list3.Duel, list3.FFA, list3.Duo } do
		v12.Image = v12.Name == autoQueueMode and "rbxassetid://130220287908778" or "rbxassetid://92962016976974"
	end
end

FFA.Activated:Connect(function()
	selectMode("FFA")
end)
duo.Activated:Connect(function()
	selectMode("Duo")
end)
list3.FFA.Activated:Connect(function()
	if list3.FFA.LockedOverlay.Visible then
		return
	end

	selectMode("FFA")
end)
list3.Duo.Activated:Connect(function()
	selectMode("Duo")
end)
list3.Duel.Activated:Connect(function()
	if list3.Duel.LockedOverlay.Visible then
		return
	end

	selectMode("Duel")
end)
regionSelection.Region.Activated:Connect(function()
	regionSelection.Dropdown.Visible = not regionSelection.Dropdown.Visible
end)
regionSelection.Dropdown.Visible = false
task.defer(updateRegionVisibility)
Utils.FFlag.OnChange(updateRegionVisibility)

local function selectRegion(p: string)
	local inParty = localPlayer:GetAttribute("InParty")
	local v12 = not inParty or inParty == tostring(localPlayer.UserId)

	if not v12 then
		NotificationController:SendNotification("Only the party leader can change the region!")
		return
	end

	for _, button in regionSelection.Dropdown.Contents:GetChildren() do
		if not button:IsA("GuiButton") then
			continue
		end

		local v13 = button.Name == p
		button.Image = v13 and "rbxassetid://120602131579300" or "rbxassetid://73882225834596"
		button.HoverImage = v13 and "rbxassetid://105327464056132" or "rbxassetid://122849015433885"
	end

	regionSelection.Dropdown.Visible = false
	v10 = p

	if localPlayer:GetAttribute("InRankedQueue") and v12 then
		local v13 = autoQueueMode
		remotes.LeaveQueue:FireServer("Ranked", v13)
		openMainMenuSignal:Fire(true)
		joinQueue() -- equivalent call inferred; original call site unknown
	end
end

for _, button in regionSelection.Dropdown.Contents:GetChildren() do
	if not button:IsA("GuiButton") then
		continue
	end

	local v12 = button
	button.Activated:Connect(function()
		selectRegion(v12.Name)
	end)
end

selectRegion("Auto")
play.RankList.Activated:Connect(function()
	GuiHandler:Open("RankedRewardList")
end)
UpdateLocalElo()
v:OnDescendantChange("Elo", UpdateLocalElo)
v2:OnChange("Parties", updateParty)
localPlayer:GetAttributeChangedSignal("InParty"):Connect(updateParty)
task.spawn(updateParty)
remotes.SendPartyInvite.OnClientEvent:Connect(function(p, _)
	if not rankedLobbyServer then
		if not script.Parent.Enabled then
			page.Visible = false
			playInfo.Visible = false
		end

		script.Parent.Enabled = true
	end

	OnPartyInvite(p)
end)
remotes.SwitchMode.OnClientEvent:Connect(function(_, _)
	ToggleWindow(play)
end)
local v12 = 0
local now = 0
RunService.Heartbeat:Connect(function(dt)
	if v7 > 0 then
		v7 = math.max(0, v7 - dt)
		partyInvitePrompt.Bar.BarProgress.Size = UDim2.fromScale(v7 / 30, 1)
	else
		partyInvitePrompt.Visible = false

		if not (rankedLobbyServer or page.Visible) then
			script.Parent.Enabled = false
			page.Visible = true
		end
	end

	if searching.Visible then
		local now2 = tick()

		if now2 - now >= 1 then
			v12 += 1

			if v12 > 3 then
				v12 = 1
			end

			now = now2
			periods.Text = string.rep(".", v12)
		end
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateSearchingText()
	local visible = searching.Visible
	local inRankedQueue = localPlayer:GetAttribute("InRankedQueue") == true
	searching.Visible = inRankedQueue

	if searching.Visible ~= visible then
		v12 = 0
		now = tick()
	end

	playButton2.Visible = not inRankedQueue
	cancelButton.Visible = inRankedQueue
	v7 = 0
end

UpdateSearchingText() -- equivalent call inferred; original call site unknown
localPlayer:GetAttributeChangedSignal("InRankedQueue"):Connect(UpdateSearchingText)

local function UpdateQueues()
	for childName, _ in RankedSeasonData.Modes do
		local attribute = ReplicatedStorage:GetAttribute(childName .. "Queue") or 0
		local child = list2:FindFirstChild(childName)

		if not child then
			continue
		end

		local playerQueue = child:WaitForChild("PlayerQueue")
		playerQueue.Visible = attribute > 0
		playerQueue.Text = string.format("%s Players in queue", attribute)
	end
end

for k, _ in RankedSeasonData.Modes do
	ReplicatedStorage:GetAttributeChangedSignal(k .. "Queue"):Connect(UpdateQueues)
end

UpdateQueues()

local function reflectDisabledModes()
	local v13 = FFlagClient:GetKey("RankedModeEnabled") ~= true
	v9 = {
		FFA = v13 or FFlagClient:GetKey("RankedFFAEnabled") ~= true,
		Duo = v13 or FFlagClient:GetKey("RankedDuoEnabled") ~= true,
		Duel = v13 or FFlagClient:GetKey("RankedDuelEnabled") ~= true
	}
	list2.FFA.Disabled.Visible = v9.FFA == true
	list2.Duo.Disabled.Visible = v9.Duo == true
	local inParty = localPlayer:GetAttribute("InParty")
	list3.FFA.LockedOverlay.Visible = v9.FFA == true or inParty
	list3.Duo.LockedOverlay.Visible = v9.Duo == true
	list3.Duel.LockedOverlay.Visible = v9.Duel == true or inParty
end

task.defer(function()
	FFlagClient:WaitForData()
	reflectDisabledModes()

	if rankedLobbyServer then
		if RankedSeasonData.GetRankedType() == "NoAbility" then
			local header = statistics:WaitForChild("Header")

			if header then
				header.Text = "Personal Ranked No Ability Stats"
			end

			for _, button in list2:GetChildren() do
				if not button:IsA("ImageButton") then
					continue
				end

				local mode = button:FindFirstChild("Mode")

				if mode then
					mode.Visible = true
				end
			end
		end

		local localPlayerTeleportData = TeleportService:GetLocalPlayerTeleportData() or {}

		if localPlayerTeleportData.AutoQueue then
			autoQueueMode = localPlayerTeleportData.AutoQueueMode
			ToggleWindow(play)
			UpdateLocalElo()
			script.Parent.Enabled = true

			if not v9[autoQueueMode] then
				if localPlayerTeleportData.AutoQueueMode == "Duo" then
					local autoQueueTeamData = localPlayerTeleportData.AutoQueueTeamData

					if autoQueueTeamData then
						local index = table.find(autoQueueTeamData, localPlayer.UserId)
						table.remove(autoQueueTeamData, index)

						if RankedPenaltyController:IsRankedRestricted(localPlayerTeleportData.AutoQueueRankType) then
							return
						end

						if v3:InvokeServer(autoQueueTeamData[1], localPlayerTeleportData.AutoQueueRankType) == true then
							joinQueue(localPlayerTeleportData.AutoQueueRankType) -- equivalent call inferred; original call site unknown
						end
					end
				else
					if RankedPenaltyController:IsRankedRestricted(localPlayerTeleportData.AutoQueueRankType) then
						return
					end

					joinQueue(localPlayerTeleportData.AutoQueueRankType) -- equivalent call inferred; original call site unknown
				end
			end
		end
	else
		local localPlayerTeleportData = TeleportService:GetLocalPlayerTeleportData() or {}

		if localPlayerTeleportData.AutoQueue and localPlayerTeleportData.AutoQueueRankType then
			autoQueueRankType = localPlayerTeleportData.AutoQueueRankType
			updateRankedMenuSignal:Fire(localPlayerTeleportData.AutoQueueRankType)
			openMainMenuSignal:Fire(true)
			autoQueueMode = localPlayerTeleportData.AutoQueueMode
			ToggleWindow(play)
			UpdateLocalElo()
			script.Parent.Enabled = true

			if not v9[autoQueueMode] then
				if localPlayerTeleportData.AutoQueueMode == "Duo" then
					local autoQueueTeamData = localPlayerTeleportData.AutoQueueTeamData

					if autoQueueTeamData then
						local index = table.find(autoQueueTeamData, localPlayer.UserId)
						table.remove(autoQueueTeamData, index)

						if RankedPenaltyController:IsRankedRestricted(localPlayerTeleportData.AutoQueueRankType) then
							return
						end

						if v3:InvokeServer(autoQueueTeamData[1], localPlayerTeleportData.AutoQueueRankType) == true then
							joinQueue(localPlayerTeleportData.AutoQueueRankType) -- equivalent call inferred; original call site unknown
						end
					end
				else
					if RankedPenaltyController:IsRankedRestricted(localPlayerTeleportData.AutoQueueRankType) then
						return
					end

					joinQueue(localPlayerTeleportData.AutoQueueRankType) -- equivalent call inferred; original call site unknown
				end
			end
		end
	end
end)
FFlagClient.DataUpdatedEvent:Connect(reflectDisabledModes)
local RankedSeasonData2 = require(ReplicatedStorage.Shared.RankedSeasonData)
local items = page.LeaderboardRewards.Items

local function updateLeaderboardRewards()
	local currentSeason = RankedSeasonData2.GetCurrentSeason(rankedType)
	local v13 = RankedSeasonData2.Rewards[rankedType][tostring(currentSeason)]

	if not v13 and RunService:IsStudio() then
		warn("No Ranked Season rewards found for Season", currentSeason, rankedType)
	end

	updateRewardsDisplay(v13, rankedType)
end

function updateRewardsDisplay(list4, p)
	local children = {}

	for _, child in items:GetChildren() do
		local icon = child:FindFirstChild("Icon")
		local questionMark = child:FindFirstChild("QuestionMark")

		if icon then
			local imageColor

			if list4 == nil then
				imageColor = Color3.fromRGB(0, 0, 0)
			else
				imageColor = Color3.fromRGB(255, 255, 255)
			end

			icon.ImageColor3 = imageColor
		end

		if questionMark then
			questionMark.Visible = list4 == nil
		end
	end

	if not list4 then
		list4 = {}

		for _, child in items:GetChildren() do
			table.insert(children, child)
		end
	end

	local v13 = { 1, 50, 200 }

	for k, v14 in pairs(list4) do
		local child = items:FindFirstChild((`Top{v13[k]}`))
		local child2 = items:FindFirstChild((`Top{v13[k]}Text`))

		if not child then
			continue
		end

		local reward = v14.Rewards[1]
		child.Icon.Image = not reward and "" or reward.Icon or ""

		if p == "NoAbility" and not reward.Sword then
			child.Visible = true
			child.Icon.Size = UDim2.new(1, 0, 1, 0)
			child.Icon.Rotation = 0
		end

		if child2 then
			child2.Text = `{v14.Rank == 1 and "Rank" or "Top"} {v14.Rank}`
			table.insert(children, child2)
		end

		table.insert(children, child)
	end

	if #list4 < 3 and #list4 > 0 then
		items.UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	end

	for _, guiObject in items:GetChildren() do
		if not guiObject:IsA("GuiObject") or table.find(children, guiObject) then
			continue
		end

		guiObject.Visible = false
	end
end

updateLeaderboardRewards()
leaderboard.DisabledOverlay.Visible = not rankedLobbyServer
leaderboard.DisabledOverlay.JoinRanked.Activated:Connect(function()
	remoteEvent:FireServer("Ranked")
end)
updateRankedMenuSignal:Connect(function(p: string)
	rankedType = p
	autoQueueRankType = p
	local header = statistics:WaitForChild("Header")

	if p == "NoAbility" then
		if header then
			header.Text = "Personal Ranked No Ability Stats"
		end

		for _, button in list2:GetChildren() do
			if not button:IsA("ImageButton") then
				continue
			end

			local mode = button:FindFirstChild("Mode")

			if mode then
				mode.Visible = true
			end
		end
	else
		if header then
			header.Text = "Personal Ranked Ability Stats"
		end

		for _, button in list2:GetChildren() do
			if not button:IsA("ImageButton") then
				continue
			end

			local mode = button:FindFirstChild("Mode")

			if mode then
				mode.Visible = false
			end
		end
	end

	local currentSeason = RankedSeasonData2.GetCurrentSeason(p)
	local v13 = RankedSeasonData2.Rewards[p][tostring(currentSeason)]

	if not v13 and RunService:IsStudio() then
		warn("No Ranked Season rewards found for Season", currentSeason, p)
	end

	updateRewardsDisplay(v13, p)
	UpdateLocalElo()
	updateLeaderboardRewards()
end)
RankedSeasonData2.SeasonChanged:Connect(updateLeaderboardRewards)