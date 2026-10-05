local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local HudStyle = require(chickenOrHero:WaitForChild("Presentation"):WaitForChild("HudStyle"))
local colors = HudStyle.Colors
local game2 = chickenOrHero:WaitForChild("Game")
local session = game2:WaitForChild("Session")
local gameAction = game2:WaitForChild("GameAction")
local parent = script.Parent
local NotificationLayout = require(chickenOrHero.Presentation:WaitForChild("NotificationLayout"))
local connection, v = NotificationLayout.apply(parent)
local mainFrame = parent:WaitForChild("MainFrame")
local frame = mainFrame:WaitForChild("NotificationsF"):WaitForChild("Frame")
local whatsHappening = frame:WaitForChild("WhatsHappening")
local location = frame:WaitForChild("Location")
local hint = frame:WaitForChild("Hint")
local choices = mainFrame:WaitForChild("Choices")
local ChoiceController = require(chickenOrHero.Presentation:WaitForChild("ChoiceController"))
local v2 = ChoiceController.new(parent, session, gameAction)
local EscapeStreakController = require(chickenOrHero.Presentation:WaitForChild("EscapeStreakController"))
local v3 = EscapeStreakController.new(parent, session, localPlayer, colors)
local CrossingBalanceNotice = require(chickenOrHero.Presentation:WaitForChild("CrossingBalanceNotice"))
local v4 = CrossingBalanceNotice.new(parent, localPlayer)
local v5 = true
local v6 = nil
local matchId = nil
local v7 = 0
local v8 = {
	MapVote = "MAP VOTE",
	Lobby = "LOBBY",
	Countdown = "STARTING",
	Prepare = "GET READY",
	SelectHero = "SELECTION",
	HeroChoice = "YOUR CHOICE",
	ChoiceReveal = "CHOICE",
	HeroRun = "HERO RUN",
	GroupRun = "CROSSING",
	FinalRun = "FINAL RUN",
	RunResolution = "COMPLETE",
	Results = "RESULTS",
	Intermission = "LOBBY BREAK"
}

local function update()
	v()
	local serverTimeNow = workspace:GetServerTimeNow()
	local phase = session:GetAttribute("Phase") or "Lobby"
	v2:update(phase)
	v3:update(phase)
	v4:update(phase)
	local runNumber = session:GetAttribute("RunNumber") or 0
	location.Text = runNumber > 0 and phase ~= "Lobby" and phase ~= "Countdown" and phase ~= "MapVote" and phase ~= "Intermission" and ("ROUND %02d"):format(runNumber) or v8[phase] or phase
	local gameRole = localPlayer:GetAttribute("GameRole") or "Lobby"
	local runState = localPlayer:GetAttribute("RunState") or "Lobby"
	local AFK = localPlayer:GetAttribute("AFK") == true
	local v9

	if gameRole == "Lobby" then
		v9 = localPlayer:GetAttribute("InMatch") ~= true
	else
		v9 = false
	end

	if v9 then
		location.Text = "LOBBY"
	end

	local mint = runState == "Safe" and colors.Mint or gameRole == "Catcher" and colors.Red or (phase == "HeroChoice" or phase == "HeroRun") and colors.Gold or colors.Text
	location.TextColor3 = mint
	local endsAt = session:GetAttribute("EndsAt") or 0
	local v10 = math.max(0, (math.ceil(endsAt - serverTimeNow)))
	local v11

	if AFK then
		v11 = "AFK · Staying in lobby"
	elseif runState == "Safe" then
		v11 = "Safe"
	elseif runState == "Caught" then
		v11 = "Caught"
	elseif gameRole == "Lobby" then
		v11 = phase == "Intermission" and "Next match soon" or "Waiting for players"
	else
		v11 = gameRole
	end

	hint.Text = v11 .. ((not (endsAt > 0) or AFK or v9 and phase ~= "Countdown" and phase ~= "Intermission") and "" or ("  ·  %d:%02d"):format(
		math.floor(v10 / 60),
		v10 % 60
	) or "")
	hint.TextColor3 = endsAt > 0 and v10 <= 5 and colors.Gold or colors.Text
	local notice = session:GetAttribute("Notice") or ""
	local v12

	if serverTimeNow < (session:GetAttribute("NoticeUntil") or 0) and notice ~= "" then
		v12 = not choices.Visible
	else
		v12 = false
	end

	local text = v12 and notice or session:GetAttribute("Announcement") or "Connecting to the match..."

	if v9 and AFK then
		v12 = false
		text = "AFK enabled — you’ll sit out until you turn it off."
	elseif v9 and phase ~= "Lobby" and phase ~= "Countdown" and phase ~= "MapVote" and phase ~= "Intermission" then
		v12 = false
		text = "Match in progress — you’ll join the next one."
	end

	local snapshot = v3.snapshot

	if phase == "Prepare" and runNumber == 1 and not v9 and snapshot.eligible and matchId ~= snapshot.matchId then
		matchId = snapshot.matchId
		v7 = serverTimeNow + math.min(4, (math.max(0, endsAt - serverTimeNow)))
	end

	if phase == "Prepare" and serverTimeNow < v7 and not (v9 or v12) then
		text = gameRole == "Catcher" and "Catch runners to break their escape streak." or "Get everyone across 3 times in a row to win."
	end

	local queuedAdminMode = session:GetAttribute("QueuedAdminMode")

	if type(queuedAdminMode) == "string" and queuedAdminMode ~= "" then
		text = "Next mode: " .. (({
			CrossyRoad = "Crossy Roads",
			DonkeyKong = "Donkey Kong",
			FFACatchers = "FFA Chasers Only"
		})[queuedAdminMode] or queuedAdminMode) .. "!"
		v12 = false
	end

	whatsHappening.Text = text
	whatsHappening.TextColor3 = queuedAdminMode and colors.Gold or v12 and colors.Mint or colors.Text

	if text ~= v6 then
		v6 = text
		whatsHappening.TextTransparency = 0.35
		TweenService:Create(whatsHappening, TweenInfo.new(0.18), {
			TextTransparency = 0
		}):Play()
	end
end

script.Destroying:Connect(function()
	v5 = false
	connection:Disconnect()

	if game.GuiService.SelectedObject and game.GuiService.SelectedObject:IsDescendantOf(mainFrame) then
		game.GuiService.SelectedObject = nil
	end

	v2:destroy()
	v3:destroy()
	v4:destroy()
end)

while v5 and parent.Parent do
	update()
	task.wait(0.1)
end