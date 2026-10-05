local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
require(ReplicatedStorage.Modules.ItemLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers.ComplianceController)
local TeammateSlot = require(Players.LocalPlayer.PlayerScripts.Modules.TeammateSlot)
local RankIcon = require(Players.LocalPlayer.PlayerScripts.Modules.RankIcon)
local scoreboardPlayerSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("ScoreboardPlayerSlot")
local ScoreboardPlayerSlot = {}
ScoreboardPlayerSlot.__index = ScoreboardPlayerSlot

function ScoreboardPlayerSlot.new(scoreboard, clientDueler)
	local self = setmetatable({}, ScoreboardPlayerSlot)
	self.Scoreboard = scoreboard
	self.ClientDueler = clientDueler
	self.Frame = scoreboardPlayerSlot:Clone()
	self.UIGradient = self.Frame:WaitForChild("UIGradient")
	self.TeammateSlotContainer = self.Frame:WaitForChild("TeammateSlotContainer")
	self.RankContainer = self.Frame:WaitForChild("RankContainer")
	self.ConnectionLevel = self.Frame:WaitForChild("ConnectionLevel")
	self.ConnectionLevelIcon = self.ConnectionLevel:WaitForChild("Icon")
	self.DisplayNameText = self.Frame:WaitForChild("DisplayName")
	self.UsernameText = self.Frame:WaitForChild("Username")
	self.EliminationsText = self.Frame:WaitForChild("Eliminations")
	self.DeathsText = self.Frame:WaitForChild("Deaths")
	self.AssistsText = self.Frame:WaitForChild("Assists")
	self.PingText = self.Frame:WaitForChild("Ping")
	self.ScoreText = self.Frame:WaitForChild("Score")
	self.WeaponIcon = self.Frame:WaitForChild("Weapon")
	self._destroyed = false
	self._update_ping_connection = nil
	self._teammate_slot = nil
	self._rank_icon = nil
	self:_Init()
	return self
end

function ScoreboardPlayerSlot:UpdatePreferredTransparency(p2)
	self.UIGradient.Transparency = NumberSequence.new(0, p2 or self.Scoreboard:GetBackgroundTransparency())
end

function ScoreboardPlayerSlot:Update()
	self:_Clear()

	if self._destroyed then
		return
	end

	local teamID = self.ClientDueler:Get("TeamID")
	local controls = self.ClientDueler.ClientFighter:Get("Controls")
	local index = table.find(self.Scoreboard.DuelInterface.ClientDuel.Duelers, self.ClientDueler)
	local v = self.ClientDueler:GetHealth() / self.ClientDueler:GetMaxHealth()
	local v2 = math.floor(self.ClientDueler:Get("Damage") + 0.5)
	local statisticDuelsWinStreak

	if not (self.Scoreboard.DuelInterface.ClientDuel.IsRanked or self.Scoreboard.DuelInterface.ClientDuel:Get("ScoresBehavior") ~= "Teams" or self.Scoreboard.DuelInterface.ClientDuel:Get("ScoreNeededToWin")) then
		statisticDuelsWinStreak = self.ClientDueler.Player:GetAttribute("StatisticDuelsWinStreak")
	end

	local level = self.ClientDueler.Player:GetAttribute("Level")
	local v3

	if self.Scoreboard.DuelInterface.ClientDuel:Get("ScoresBehavior") == "Duelers" then
		v3 = self.Scoreboard.DuelInterface.ClientDuel:Get("Scores")[self.ClientDueler:Get("DuelerID")]
	else
		v3 = false
	end

	local v4 = Utility:SanitizeName(self.ClientDueler.Player.Name)
	self.Frame.BackgroundColor3 = self.Scoreboard:GetTeamColor(teamID)
	self.UsernameText.Text = self.ClientDueler.Player.DisplayName == v4 and "" or "@" .. v4
	self.DisplayNameText.Text = ComplianceController:GetName(self.ClientDueler.Player)
	self.DisplayNameText.Position = self.UsernameText.Text == "" and UDim2.new(0.1, 0, 0.5, 0) or UDim2.new(
		0.1,
		0,
		0.375,
		0
	)
	self.EliminationsText.Text = Utility:PrettyNumber(self.ClientDueler:Get("Eliminations"))
	self.DeathsText.Text = Utility:PrettyNumber(self.ClientDueler:Get("Deaths"))
	self.AssistsText.Text = Utility:PrettyNumber(self.ClientDueler:Get("Assists"))
	self.ConnectionLevelIcon.Image = Utility:GetConnectionLevelIcon(self.ClientDueler.ClientFighter:Get("ConnectionLevel")) or ""
	self.ConnectionLevel.Position = self.ClientDueler.IsLocalPlayer and UDim2.new(0.925, 0, 0.55, 0) or UDim2.new(
		0.925,
		0,
		0.5,
		0
	)
	self.ConnectionLevel.AnchorPoint = self.ClientDueler.IsLocalPlayer and Vector2.new(0.5, 1) or Vector2.new(0.5, 0.5)
	self.PingText.Visible = self.ClientDueler.IsLocalPlayer
	self.ScoreText.Text = v3 and Utility:PrettyNumber(v3) or Utility:PrettyNumber(v2)
	self.WeaponIcon.Image = ""
	local v5 = TeammateSlot.new(
		self.ClientDueler.Player.UserId,
		controls,
		v,
		not index,
		true,
		statisticDuelsWinStreak,
		level
	)
	v5.SlotFrame.Parent = self.TeammateSlotContainer

	if self.ClientDueler:GetStaggeredSpawnsTurn() then
		v5:SetStaggeredSpawnsTurn(self.ClientDueler:GetStaggeredSpawnsTurn(), teamID)
	end

	if self.Scoreboard.DuelInterface.ClientDuel.IsRanked and self.ClientDueler:CanShowRankToLocalPlayer() then
		self._rank_icon = RankIcon.new(
			self.ClientDueler.Player:GetAttribute("DisplayELO"),
			self.ClientDueler.Player.UserId
		)
		self._rank_icon:SetParent(self.RankContainer)
	end

	self:UpdatePreferredTransparency()
end

function ScoreboardPlayerSlot:Destroy()
	self._destroyed = true

	if self._update_ping_connection then
		self._update_ping_connection:Disconnect()
		self._update_ping_connection = nil
	end

	self:_Clear()
	self.Frame:Destroy()
end

function ScoreboardPlayerSlot:_UpdatePing()
	local localConnectionPing = Utility:GetLocalConnectionPing()
	local connectionLevelIcon = Utility:GetConnectionLevelIcon((Utility:GetConnectionLevel(localConnectionPing)))
	self.PingText.Text = localConnectionPing
	self.ConnectionLevelIcon.Image = connectionLevelIcon or ""
end

function ScoreboardPlayerSlot:_Clear()
	if self._teammate_slot then
		self._teammate_slot:Destroy()
		self._teammate_slot = nil
	end

	if self._rank_icon then
		self._rank_icon:Destroy()
		self._rank_icon = nil
	end
end

function ScoreboardPlayerSlot:_Setup()
	if self.ClientDueler.IsLocalPlayer then
		self._update_ping_connection = RunService.RenderStepped:Connect(function()
			self:_UpdatePing()
		end)
		self:_UpdatePing()
	end
end

function ScoreboardPlayerSlot:_Init()
	self:_Setup()
	self:Update()
end

return ScoreboardPlayerSlot