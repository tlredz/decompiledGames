local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local LeaderboardLibrary = require(ReplicatedStorage.Modules.LeaderboardLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local LeaderboardController = require(Players.LocalPlayer.PlayerScripts.Controllers.LeaderboardController)
local ComplianceController = require(Players.LocalPlayer.PlayerScripts.Controllers.ComplianceController)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules.ButtonEffect)
local RankIcon = require(Players.LocalPlayer.PlayerScripts.Modules.RankIcon)
local leaderboardPlayerSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("LeaderboardPlayerSlot")
local leaderboardButton = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("LeaderboardButton")
local leaderboardGui = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("LeaderboardGui")
local LeaderboardDisplay = {}
LeaderboardDisplay.__index = LeaderboardDisplay

function LeaderboardDisplay.new(part)
	local self = setmetatable({}, LeaderboardDisplay)
	self.Part = part
	self.SurfaceGui = leaderboardGui:Clone()
	self._display_id = self.Part:GetAttribute("DisplayID")
	self._leaderboard_buttons = {}
	self._leaderboard_name = nil
	self._leaderboard_serial = nil
	self._leaderboard_connections = {}
	self._generate_hash = 0
	self._player_slots = {}
	self:_Init()
	return self
end

function LeaderboardDisplay:SelectLeaderboard(leaderboard_name)
	for _, _leaderboard_connection in pairs(self._leaderboard_connections) do
		_leaderboard_connection:Disconnect()
	end

	self._leaderboard_connections = {}
	self._leaderboard_name = leaderboard_name
	self._leaderboard_serial = LeaderboardController.LeaderboardSerials[self._leaderboard_name]
	self:_UpdateButtons()
	task.spawn(self._Generate, self)

	if not self._leaderboard_name then
		return
	end

	table.insert(
		self._leaderboard_connections,
		LeaderboardController:GetLeaderboardRefreshedSignal(self._leaderboard_name):Connect(function()
			self:Refresh()
		end)
	)
end

function LeaderboardDisplay:Refresh()
	self:SelectLeaderboard(self._leaderboard_name)
end

function LeaderboardDisplay:_UpdateCanvasSize()
	self.SurfaceGui.List.CanvasSize = UDim2.new(0, 0, 0, self.SurfaceGui.List.Container.Layout.AbsoluteContentSize.Y)
end

function LeaderboardDisplay:_UpdateButtons()
	for k, _leaderboard_button in pairs(self._leaderboard_buttons) do
		_leaderboard_button.Button.Icon.Image = LeaderboardLibrary.DisplayInfo[k][k == self._leaderboard_name and "IconFilled" or "Icon"]
		_leaderboard_button.Button.Icon.Size = k == self._leaderboard_name and UDim2.new(1, 0, 1, 0) or UDim2.new(
			0.6,
			0,
			0.6,
			0
		)
	end
end

function LeaderboardDisplay:_LiveDisplay(p2)
	while true do
		self.SurfaceGui.Live.Text = "• LIVE"
		wait(1)

		if p2 ~= self._generate_hash then
			break
		end

		self.SurfaceGui.Live.Text = "LIVE"
		wait(0.25)

		if p2 ~= self._generate_hash then
			break
		end
	end
end

function LeaderboardDisplay:_Generate()
	for _, _player_slot in pairs(self._player_slots) do
		_player_slot:Destroy()
	end

	self._player_slots = {}
	self._generate_hash += 1
	self.SurfaceGui.Title.Text = "Loading..."
	self.SurfaceGui.LiveBackground.Visible = false
	self.SurfaceGui.Live.Visible = false
	local v = LeaderboardLibrary.DisplayInfo[self._leaderboard_name] or {}
	local _generate_hash = self._generate_hash
	local v2 = {}

	for _, v3 in pairs(not self._leaderboard_serial and {} or self._leaderboard_serial.Players or {}) do
		table.insert(v2, (tonumber(v3.key)))
	end

	local v3 = (not self._leaderboard_serial or #self._leaderboard_serial.Players == 0 or #v2 == 0) and {} or ComplianceController:GetUserInfos(
		v2,
		25
	)

	if _generate_hash ~= self._generate_hash then
		return
	end

	self.SurfaceGui.Title.Text = not v and "• • •" or v.DisplayName or "• • •"
	self.SurfaceGui.Live.Visible = v.LiveDisplayEnabled
	self.SurfaceGui.LiveBackground.Visible = v.LiveDisplayEnabled

	if v.LiveDisplayEnabled then
		task.spawn(self._LiveDisplay, self, _generate_hash)
	end

	for k, v4 in pairs(not self._leaderboard_serial and {} or self._leaderboard_serial.Players or {}) do
		local key = v4.key
		local value = v4.value
		local v5 = v3[key]
		local text = not v5 and "• • •" or v5.DisplayName .. (v5.HasVerifiedBadge and utf8.char(57344) or "") or "• • •"
		local username

		if v5 and v5.Username then
			if v.SanitizeUsernames then
				username = Utility:SanitizeName(v5.Username)
			else
				username = v5.Username
			end
		end

		local text2 = v5 and username and "@" .. username or ""
		local clone = leaderboardPlayerSlot:Clone()
		clone.Left.Headshot.Image = string.format(CONSTANTS.HEADSHOT_IMAGE, key)
		clone.Left.Rank.Text = "#" .. k
		clone.Left.Rank.TextColor3 = k == 1 and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 255, 255)
		clone.Left.Rank[k == 1 and "Normal" or "First"]:Destroy()
		clone.Left.DisplayName.Text = text
		clone.Left.DisplayName.Size = k == 1 and UDim2.new(2, 0, 0.4, 0) or UDim2.new(3, 0, 0.4, 0)
		clone.Left.Username.Text = text2
		clone.Left.UserID.Text = "#" .. key
		clone.Right.Icon.Value.Text = Utility:PrettyNumber(value)
		clone.Right.Icon.Image = not v and "" or v.Icon or ""
		clone.Right.Icon.UIGradient.Color = v.ColorSequence
		clone.Right.Icon.Value.Position = v.TextPosition
		clone.Right.Icon.Value.UIStroke.UIGradient.Color = v.DarkColorSequence
		clone.Size = k == 1 and UDim2.new(1, 0, 0.25, 0) or UDim2.new(1, 0, 0.15, 0)
		clone.LayoutOrder = k
		clone.Parent = self.SurfaceGui.List.Container
		table.insert(self._player_slots, clone)

		if self._leaderboard_name == "Highest ELO" then
			clone.Right.Icon.Visible = false
			clone.Right.Rank.Size = k == 1 and UDim2.new(1, 0, 1, 0) or UDim2.new(1.5, 0, 1.5, 0)
			local v8 = RankIcon.new(value, tonumber(key), k)
			v8:SetParent(clone.Right.Rank)
			v8:SetLabelFromELOEvent(nil, value, 10)
			local label = v8:GetLabel()
			label.BackgroundTransparency = 1
			local uIStroke = Instance.new("UIStroke")
			uIStroke.Thickness = 2
			uIStroke.Parent = v8:GetLabelText()
		end

		wait(0.06)

		if _generate_hash ~= self._generate_hash then
			break
		end
	end
end

function LeaderboardDisplay:_Setup()
	local v = nil

	for k, v2 in pairs(LeaderboardLibrary.Order) do
		if LeaderboardLibrary.DisplayInfo[v2].DisplayID ~= self._display_id then
			continue
		end

		local clone = leaderboardButton:Clone()
		clone.LayoutOrder = k
		clone.Parent = self.SurfaceGui.Buttons
		self._leaderboard_buttons[v2] = clone
		local v3 = v2
		clone.Button.MouseButton1Click:Connect(function()
			self:SelectLeaderboard(v3)
		end)
		ButtonEffect:Add(clone.Button, nil, {
			HoverRatio = 1.05,
			ReleaseRatio = 1.05
		})
		v = v or v2
	end

	self:SelectLeaderboard(v)
	self.SurfaceGui.Adornee = self.Part
	self.SurfaceGui.Parent = Players.LocalPlayer.PlayerGui
end

function LeaderboardDisplay:_Init()
	self.SurfaceGui.List.Container.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateCanvasSize()
	end)
	self:_Setup()
	self:_UpdateButtons()
	self:_UpdateCanvasSize()
end

return LeaderboardDisplay