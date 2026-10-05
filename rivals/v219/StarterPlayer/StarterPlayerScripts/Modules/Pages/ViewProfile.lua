local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local StatisticsLibrary = require(ReplicatedStorage.Modules.StatisticsLibrary)
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
require(ReplicatedStorage.Modules.ItemLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ComplianceController"))
local QueuePadController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("QueuePadController"))
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("FighterController"))
local SeasonController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SeasonController"))
local PartyController = require(Players.LocalPlayer.PlayerScripts.Controllers:WaitForChild("PartyController"))
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("WeaponStatusHandler"))
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local WeaponSlot = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("WeaponSlot"))
local RankIcon = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RankIcon"))
local Page = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Page"))
local object = setmetatable({}, Page)
object.__index = object

function object._new()
	local self = setmetatable(Page.new(script.Name), object)
	self.LoadingFrame = self.PageFrame:WaitForChild("Loading")
	self.DotsFrame = self.LoadingFrame:WaitForChild("Dots")
	self.ActiveFrame = self.PageFrame:WaitForChild("Active")
	self.PlayerFrame = self.ActiveFrame:WaitForChild("Player")
	self.MostPlayedWeaponsFrame = self.PlayerFrame:WaitForChild("MostPlayedWeapons")
	self.MostPlayedMap = self.PlayerFrame:WaitForChild("MostPlayedMap")
	self.DisplayNameText = self.PlayerFrame:WaitForChild("DisplayName")
	self.ControlsIcon = self.DisplayNameText:WaitForChild("Controls")
	self.UsernameText = self.PlayerFrame:WaitForChild("Username")
	self.HeadshotIcon = self.PlayerFrame:WaitForChild("Headshot")
	self.BraggingFrame = self.PlayerFrame:WaitForChild("Bragging")
	self.LevelImage = self.BraggingFrame:WaitForChild("Level")
	self.LevelText = self.LevelImage:WaitForChild("Value")
	self.StreakImage = self.BraggingFrame:WaitForChild("Streak")
	self.StreakText = self.StreakImage:WaitForChild("Value")
	self.RankFrame = self.BraggingFrame:WaitForChild("Rank")
	self.RankContainer = self.RankFrame:WaitForChild("Container")
	self.RankText = self.RankFrame:WaitForChild("Title")
	self.WinsButton = self.PlayerFrame:WaitForChild("WinsButton")
	self.WinsButtonCasualBackground = self.WinsButton:WaitForChild("CasualBackground")
	self.WinsButtonRankedBackground = self.WinsButton:WaitForChild("RankedBackground")
	self.CasualFrame = self.PlayerFrame:WaitForChild("Casual")
	self.CasualWinsText = self.CasualFrame:WaitForChild("Wins")
	self.CasualWinsTitle = self.CasualFrame:WaitForChild("Wins")
	self.CasualWinPercentText = self.CasualFrame:WaitForChild("WinPercent")
	self.RankedFrame = self.PlayerFrame:WaitForChild("Ranked")
	self.RankedWinsText = self.RankedFrame:WaitForChild("Wins")
	self.RankedWinsTitle = self.RankedWinsText:WaitForChild("Title")
	self.RankedWinPercentText = self.RankedFrame:WaitForChild("WinPercent")
	self.ButtonsFrame = self.ActiveFrame:WaitForChild("Buttons")
	self.CloseButton = self.ButtonsFrame:WaitForChild("Close")
	self.ChallengeButton = self.ButtonsFrame:WaitForChild("Challenge")
	self.ChallengeOnFrame = self.ChallengeButton:WaitForChild("On")
	self.ChallengeOffFrame = self.ChallengeButton:WaitForChild("Off")
	self.InviteButton = self.ButtonsFrame:WaitForChild("Invite")
	self.InviteOnFrame = self.InviteButton:WaitForChild("On")
	self.InviteOffFrame = self.InviteButton:WaitForChild("Off")
	self._fetch_hash = 0
	self._weapon_slots = {}
	self._last_player_object = nil
	self._wins_tab_is_casual = nil
	self._wins_tab_hash = 0
	self._rank_icon = nil
	self:_Init()
	return self
end

function object:Fetch(last_player_object)
	self._last_player_object = last_player_object
	self._fetch_hash += 1
	local _fetch_hash = self._fetch_hash
	self.DotsFrame:AddTag("UILoadingDots")
	self.LoadingFrame.Visible = true
	self.ActiveFrame.Visible = false

	for _, _weapon_slot in pairs(self._weapon_slots) do
		_weapon_slot:Destroy()
	end

	self._weapon_slots = {}

	if self._rank_icon then
		self._rank_icon:Destroy()
		self._rank_icon = nil
	end

	WeaponStatusHandler:ClearStatusElements(self.DisplayNameText)
	local v = ReplicatedStorage.Remotes.Misc.RequestProfile:InvokeServer(self._last_player_object)
	wait(0.25)

	if _fetch_hash ~= self._fetch_hash then
		return
	end

	if not v then
		self:CloseRequest()
		return
	end

	local fighter = FighterController:GetFighter(self._last_player_object)
	local highestELOLeaderboardRanking = SeasonLibrary:GetHighestELOLeaderboardRanking(
		v.RankedCurrentELO,
		self._last_player_object.UserId
	)
	local rank = SeasonLibrary:GetRank(v.RankedCurrentELO, self._last_player_object.UserId)
	local statisticDuelsWinStreak = self._last_player_object:GetAttribute("StatisticDuelsWinStreak")
	self.DotsFrame:RemoveTag("UILoadingDots")
	self.LoadingFrame.Visible = false
	self.ActiveFrame.Visible = true
	self.MostPlayedMap.Image = not (v.FavoriteMap and DuelLibrary.Maps[v.FavoriteMap]) and "" or DuelLibrary.Maps[v.FavoriteMap].Image or ""
	self.UsernameText.Text = "@" .. self._last_player_object.Name
	self.ControlsIcon.Image = CONSTANTS.CONTROLS_IMAGES[fighter and fighter:Get("Controls")] or ""
	self.HeadshotIcon.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, self._last_player_object.UserId)
	self.StreakImage.Visible = statisticDuelsWinStreak and statisticDuelsWinStreak > 0
	self.StreakText.Text = Utility:PrettyNumber(statisticDuelsWinStreak or 0)
	self.DisplayNameText.Text = ComplianceController:GetName(self._last_player_object)
	local rankText = self.RankText

	if highestELOLeaderboardRanking and highestELOLeaderboardRanking <= SeasonLibrary.CurrentSeason.TopPlayerLeaderboardRank then
		rank = "#" .. highestELOLeaderboardRanking
	end

	rankText.Text = rank
	self.CasualWinsTitle.Text = v.CasualWins and v.CasualWins ~= 1 and "wins" or "win"
	self.CasualWinsText.Text = StatisticsLibrary.Info.StatisticDuelsWon.TostringFunction(v.CasualWins)
	self.CasualWinPercentText.Text = StatisticsLibrary.Info.StatisticDuelsWinPercent.TostringFunction(v.CasualWinPercent)
	self.RankedWinsTitle.Text = v.RankedWins and v.RankedWins ~= 1 and "wins" or "win"
	self.RankedWinsText.Text = StatisticsLibrary.Info.StatisticRankedDuelsWon.TostringFunction(v.RankedWins)
	self.RankedWinPercentText.Text = StatisticsLibrary.Info.StatisticRankedDuelsWinPercent.TostringFunction(v.RankedWinPercent)
	self.LevelText.Text = Utility:PrettyNumber(v.Level)
	self.ChallengeButton.Visible = QueuePadController:CanChallenge(self._last_player_object)
	self.InviteButton.Visible = PartyController:CanInvitePlayerToParty(self._last_player_object)
	WeaponStatusHandler:ApplyItemStatusToText(
		self.DisplayNameText,
		self._last_player_object:GetAttribute("PlayerStatus")
	)
	self._rank_icon = RankIcon.new(v.RankedCurrentELO, self._last_player_object.UserId)
	self._rank_icon:SetParent(self.RankContainer)

	for k, favoriteWeapon in pairs(v.FavoriteWeapons) do
		local v2 = WeaponSlot.new(favoriteWeapon.Name, favoriteWeapon)
		v2.Frame.LayoutOrder = k
		v2.Frame.Parent = self.MostPlayedWeaponsFrame
		table.insert(self._weapon_slots, v2)
		v2:DisableButton()
	end

	self:_UpdateCooldowns()
	self:_UpdateTextBounds()
end

function object:SwitchWinsTab(p)
	local isRankedUnlocked = SeasonController:IsRankedUnlocked()
	self.WinsButton.Visible = isRankedUnlocked
	self.RankFrame.Visible = isRankedUnlocked
	self._wins_tab_is_casual = p or not isRankedUnlocked
	self.WinsButtonCasualBackground.BackgroundTransparency = self._wins_tab_is_casual and 0 or 0.75
	self.CasualFrame.Visible = self._wins_tab_is_casual
	self.WinsButtonRankedBackground.BackgroundTransparency = self._wins_tab_is_casual and 0.75 or 0
	self.RankedFrame.Visible = not self._wins_tab_is_casual
end

function object:Open(...)
	Page.Open(self, ...)
	self:SwitchWinsTab(true)
	task.spawn(self._SwitchWinsTabLoop, self)
end

function object:Close(...)
	self._wins_tab_hash += 1
	Page.Close(self, ...)
end

function object:_UpdateCooldowns()
	local _last_player_object = self._last_player_object
	self.ChallengeOnFrame.Visible = _last_player_object and not QueuePadController:IsChallengeRequestOnCooldown(_last_player_object)
	self.ChallengeOffFrame.Visible = not self.ChallengeOnFrame.Visible
	self.InviteOnFrame.Visible = _last_player_object and not PartyController:IsInviteRequestOnCooldown(_last_player_object)
	self.InviteOffFrame.Visible = not self.InviteOnFrame.Visible
end

function object:_SwitchWinsTabLoop()
	self._wins_tab_hash += 1
	local _wins_tab_hash = self._wins_tab_hash

	while true do
		wait(5)

		if _wins_tab_hash ~= self._wins_tab_hash then
			break
		end

		if self.WinsButton.Visible then
			self:SwitchWinsTab(not self._wins_tab_is_casual)
		end
	end
end

function object:_UpdateTextBounds()
	self.ControlsIcon.Position = UDim2.new(0, self.DisplayNameText.TextBounds.X, 0.5, 0)
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.ChallengeButton.MouseButton1Click:Connect(function()
		QueuePadController:SendChallengeRequest(self._last_player_object)
	end)
	self.InviteButton.MouseButton1Click:Connect(function()
		PartyController:SendPartyInvite(self._last_player_object)
	end)
	self.DisplayNameText:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateTextBounds()
	end)
	self.WinsButton.MouseButton1Click:Connect(function()
		self._wins_tab_hash += 1
		self:SwitchWinsTab(not self._wins_tab_is_casual)
	end)
	QueuePadController.ChallengeRequestCooldownChanged:Connect(function()
		self:_UpdateCooldowns()
	end)
	PartyController.InviteRequestCooldownChanged:Connect(function()
		self:_UpdateCooldowns()
	end)
	self:_UpdateCooldowns()
	self:_UpdateTextBounds()
	self:SwitchWinsTab(true)
	ButtonEffect:Add(self.CloseButton)
	ButtonEffect:Add(self.ChallengeButton)
	ButtonEffect:Add(self.InviteButton)
	ButtonEffect:Add(self.WinsButton)
end

return object._new()