local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers.ComplianceController)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local WeaponStatusHandler = require(Players.LocalPlayer.PlayerScripts.Modules.WeaponStatusHandler)
local RankIcon = require(Players.LocalPlayer.PlayerScripts.Modules.RankIcon)
local nametagGui = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("NametagGui")
local Nametag = {}
Nametag.__index = Nametag

function Nametag.new(player_object, controls, value, value2, elo, status, is_matchmaking)
	local self = setmetatable({}, Nametag)
	self.BillboardGui = nametagGui:Clone()
	self._player_object = player_object
	self._controls = controls
	self._win_streak = value or 0
	self._level = value2 or 0
	self._elo = elo
	self._status = status
	self._rank_icon = nil
	self._is_matchmaking = is_matchmaking
	self:_Init()
	return self
end

function Nametag:GetWinStreak()
	return self._win_streak
end

function Nametag:SetParent(parent)
	self.BillboardGui.Parent = parent
	self:_UpdateLayout()
end

function Nametag:Destroy()
	WeaponStatusHandler:ClearStatusElements(self.BillboardGui.Elements.NameDisplay.DisplayName)
	WeaponStatusHandler:ClearStatusElements(self.BillboardGui.Elements.NameDisplay.Username)
	self.BillboardGui:Destroy()

	if self._rank_icon then
		self._rank_icon:Destroy()
	end

	if self._matchmaking_connection then
		self._matchmaking_connection:Disconnect()
		self._matchmaking_connection = nil
	end
end

function Nametag:_UpdateLayout()
	self.BillboardGui.Elements.NameDisplay.Size = UDim2.new(
		0,
		math.max(
			self.BillboardGui.Elements.NameDisplay.DisplayName.TextBounds.X,
			self.BillboardGui.Elements.NameDisplay.Username.TextBounds.X
		),
		1,
		0
	)
	self.BillboardGui.Elements.Data.Streak.Position = UDim2.new(
		0.5,
		-math.max(
			0,
			(self.BillboardGui.Elements.Data.Streak.Value.TextBounds.X - self.BillboardGui.Elements.Data.Streak.AbsoluteSize.X) / 2
		),
		0.5,
		0
	)
	self.BillboardGui.Elements.Data.Level.Position = UDim2.new(
		0.5,
		-math.max(
			0,
			(self.BillboardGui.Elements.Data.Level.Title.TextBounds.X - self.BillboardGui.Elements.Data.Level.AbsoluteSize.X) / 2
		),
		0.5,
		0
	)
end

function Nametag:_SetupMatchmaking()
	self.BillboardGui.Matchmaking.Visible = self._is_matchmaking

	if not self.BillboardGui.Matchmaking.Visible then
		return
	end

	local container = self.BillboardGui.Matchmaking.Container
	local scroller = container.Scroller
	local icon1 = scroller.Icon1
	local icon2 = scroller.Icon2
	self._matchmaking_connection = RunService.RenderStepped:Connect(function()
		local v = math.sin(tick() * 0.75)
		local v2 = math.sin(tick() * 1.5)
		local rotation = v * 10
		local v4 = v * 0.025
		local v5 = v2 * 0.025
		local v6 = -v * 0.625 % icon1.Size.X.Scale
		local v7 = -v2 * 0.125
		container.Position = UDim2.new(v4 + 0.5, 0, v5 + 0.25, 0)
		container.Rotation = rotation
		scroller.Rotation = -rotation
		icon1.Position = UDim2.new(v6, 0, v7, 0)
		icon2.Position = UDim2.new(v6 - 1.5, 0, v7, 0)
	end)
end

function Nametag:_Setup()
	self.BillboardGui.Elements.Controls.Icon.Image = CONSTANTS.CONTROLS_IMAGES_CENTERED[self._controls] or ""
	local v = Utility:SanitizeName(self._player_object.Name)
	self.BillboardGui.Elements.NameDisplay.Username.Text = self._player_object.DisplayName == v and "" or "@" .. v
	self.BillboardGui.Elements.NameDisplay.DisplayName.Text = ComplianceController:GetName(self._player_object)
	WeaponStatusHandler:ApplyItemStatusToText(self.BillboardGui.Elements.NameDisplay.DisplayName, self._status)
	local setting = PlayerDataController:GetSetting("PlayerList Leaderstat")
	local rank = self.BillboardGui.Elements.Data.Rank
	rank.Visible = setting == "Current ELO" and self._elo

	if self._elo then
		self._rank_icon = RankIcon.new(self._elo, self._player_object.UserId)
		self._rank_icon:SetParent(self.BillboardGui.Elements.Data.Rank)
	end

	local streak = self.BillboardGui.Elements.Data.Streak
	streak.Visible = setting == "Win Streak" and self._win_streak > 0
	self.BillboardGui.Elements.Data.Streak.Value.Text = Utility:PrettyNumber(self._win_streak)
	self.BillboardGui.Elements.Data.Level.Visible = setting == "Level" or not (self.BillboardGui.Elements.Data.Streak.Visible or self.BillboardGui.Elements.Data.Rank.Visible)
	self.BillboardGui.Elements.Data.Level.Title.Text = Utility:PrettyNumber(self._level)
	self:_SetupMatchmaking()
	self:_UpdateLayout()
end

function Nametag:_Init()
	self.BillboardGui.Elements:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateLayout()
	end)
	self.BillboardGui.Elements.NameDisplay.DisplayName:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateLayout()
	end)
	self.BillboardGui.Elements.NameDisplay.Username:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateLayout()
	end)
	self.BillboardGui.Elements.Data.Streak:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateLayout()
	end)
	self.BillboardGui.Elements.Data.Streak.Value:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateLayout()
	end)
	self.BillboardGui.Elements.Data.Level:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateLayout()
	end)
	self.BillboardGui.Elements.Data.Level.Title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateLayout()
	end)
	task.spawn(self._Setup, self)
end

return Nametag