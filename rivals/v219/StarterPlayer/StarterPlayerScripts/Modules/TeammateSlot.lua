local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local LeaderboardController = require(Players.LocalPlayer.PlayerScripts.Controllers.LeaderboardController)
require(Players.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local RankIcon = require(Players.LocalPlayer.PlayerScripts.Modules.RankIcon)
local teammateSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("TeammateSlot")
local uDim = UDim2.new(0.5, 0, 0.5, 0)
local TeammateSlot = {}
TeammateSlot.__index = TeammateSlot

function TeammateSlot.new(user_id, controls, value, disconnected, hide_health, win_streak, p)
	local self = setmetatable({}, TeammateSlot)
	self.SlotFrame = teammateSlot:Clone()
	self._destroyed = false
	self._connections = {}
	self._user_id = user_id
	self._controls = controls
	self._health_percent = value or 1
	self._disconnected = disconnected
	self._hide_health = hide_health

	if not (win_streak and win_streak > 0 and win_streak) then
		win_streak = nil
	end

	self._win_streak = win_streak
	self._level = p or nil
	self._display_elo_set = false
	self._display_elo = nil
	self._rank_icon = nil
	self._override_icon = nil
	self._override_icon_size = nil
	self._override_icon_color = nil
	self._override_icon_text = nil
	self._override_icon_text_color = nil
	self:_Init()
	return self
end

function TeammateSlot:SetDetails(controls, p, p2, hide_health, win_streak, p3)
	self._controls = controls
	self:SetHealthPercent(p, true)
	self:SetDisconnected(p2, true)
	self._hide_health = hide_health

	if not (win_streak and win_streak > 0 and win_streak) then
		win_streak = nil
	end

	self._win_streak = win_streak
	self._level = p3 or nil
	self:_UpdateDetails()
end

function TeammateSlot:SetDisplayELO(display_elo)
	self._display_elo_set = true
	self._display_elo = display_elo
	self:_UpdateRankIcon()
end

function TeammateSlot:SetDisconnected(disconnected, p)
	if disconnected then
		self:OverrideIcon(nil, nil, nil, nil, nil, p)
	end

	self._disconnected = disconnected

	if not p then
		self:_UpdateDetails()
	end
end

function TeammateSlot:SetHealthPercent(value, p)
	self._health_percent = value or 1

	if not p then
		self:_UpdateDetails()
	end
end

function TeammateSlot:OverrideIcon(override_icon, override_icon_size, override_icon_color, override_icon_text, override_icon_text_color, p)
	if self._disconnected then
		return
	end

	self._override_icon = override_icon
	self._override_icon_size = override_icon_size
	self._override_icon_color = override_icon_color
	self._override_icon_text = override_icon_text
	self._override_icon_text_color = override_icon_text_color

	if not p then
		self:_UpdateDetails()
	end
end

function TeammateSlot:SetStaggeredSpawnsTurn(p, p2)
	if p then
		self:OverrideIcon(
			"rbxassetid://15319354627",
			UDim2.new(0.75, 0, 0.75, 0),
			Color3.fromRGB(0, 0, 0),
			p,
			DuelLibrary:GetTeamColor(p2, Color3.fromRGB(255, 255, 255))
		)
	else
		self:OverrideIcon()
	end
end

function TeammateSlot:Destroy()
	self._destroyed = true

	for _, _connection in pairs(self._connections) do
		_connection:Disconnect()
	end

	self._connections = {}
	self:SetDisplayELO(nil)
	pcall(function()
		self.SlotFrame:Destroy()
	end)
end

function TeammateSlot:_UpdateRankIcon()
	if self._rank_icon then
		self._rank_icon:Destroy()
		self._rank_icon = nil
	end

	if self._destroyed or not self._display_elo_set then
		return
	end

	local rank = self.SlotFrame:FindFirstChild("Container") and self.SlotFrame.Container:FindFirstChild("Rank")

	if not rank then
		return
	end

	self._rank_icon = RankIcon.new(self._display_elo, self._user_id)
	self._rank_icon:SetParent(rank)
end

function TeammateSlot:_UpdateDetails()
	if self._destroyed then
		return
	end

	local lerped = Color3.fromRGB(255, 50, 50):Lerp(
		Color3.fromRGB(255, 215, 0):Lerp(Color3.fromRGB(100, 255, 50), self._health_percent),
		self._health_percent
	)
	local color = Color3.new(lerped.R / 2, lerped.G / 2, lerped.B / 2)
	local visible = not self._disconnected and self._health_percent > 0
	self.SlotFrame.Container.Health.Visible = visible and not self._hide_health
	self.SlotFrame.Container.Health.Bar.Size = UDim2.new(self._health_percent, 0, 1, 0)
	self.SlotFrame.Container.Health.BackgroundColor3 = color
	self.SlotFrame.Container.Health.UIStroke.Color = Color3.new(lerped.R * 0.25, lerped.G * 0.25, lerped.B * 0.25)
	self.SlotFrame.Container.Health.Bar.BackgroundColor3 = lerped
	self.SlotFrame.Container.Health.Bar.UIStroke.Color = lerped
	self.SlotFrame.Container.Headshot.ImageTransparency = visible and 0 or 0.75
	self.SlotFrame.Container.Icon.Visible = not visible
	self.SlotFrame.Container.Icon.Image = self._override_icon or self._disconnected and "rbxassetid://16782728353" or visible and "" or "rbxassetid://16802957270"
	self.SlotFrame.Container.Icon.Size = self._override_icon_size or uDim
	self.SlotFrame.Container.Icon.ImageColor3 = self._override_icon_color or Color3.fromRGB(255, 255, 255)
	self.SlotFrame.Container.Icon.TextLabel.Text = self._override_icon_text or ""
	self.SlotFrame.Container.Icon.TextLabel.TextColor3 = self._override_icon_text_color or Color3.fromRGB(0, 0, 0)
	self.SlotFrame.Container.Controls.Image = (not visible or self._win_streak or not self._controls) and "" or CONSTANTS.CONTROLS_IMAGES[self._controls] or ""
	self.SlotFrame.Container.Streak.Visible = visible and self._win_streak and self._win_streak > 0
	self.SlotFrame.Container.Streak.Value.Text = Utility:PrettyNumber(self._win_streak or 0)
	self.SlotFrame.Container.Level.Visible = visible and self._level
	self.SlotFrame.Container.Level.Title.Text = Utility:PrettyNumber(self._level or 0)
	self.SlotFrame.Container.Rank.Visible = visible
end

function TeammateSlot:_Setup()
	self.SlotFrame.Container.Headshot.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, self._user_id)
end

function TeammateSlot:_Init()
	table.insert(
		self._connections,
		LeaderboardController:GetLeaderboardRefreshedSignal("Highest ELO"):Connect(function()
			self:_UpdateRankIcon()
		end)
	)
	self.SlotFrame.Destroying:Connect(function()
		self:Destroy()
	end)
	self:_Setup()
	self:_UpdateDetails()
end

return TeammateSlot