local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local rankIconLabel = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("RankIconLabel")
local rankIcon = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("RankIcon")
local RankIcon = {}
RankIcon.__index = RankIcon

function RankIcon.new(ELO, userID, p)
	local self = setmetatable({}, RankIcon)
	self.ELO = ELO
	self.UserID = userID
	self.ELOLeaderboardRanking = p or SeasonLibrary:GetHighestELOLeaderboardRanking(self.ELO, self.UserID)
	self.RankName = SeasonLibrary:GetRank(self.ELO, self.UserID, self.ELOLeaderboardRanking)
	self.RankInfo = SeasonLibrary.CurrentSeason.RankProfile.Ranks[self.RankName]
	self.Frame = rankIcon:Clone()
	self.Icon = self.Frame:WaitForChild("Icon")
	self._destroyed = false
	self._label = nil
	self._label_text = nil
	self:_Init()
	return self
end

function RankIcon:GetLabelText()
	return self._label_text
end

function RankIcon:GetLabel()
	return self._label
end

function RankIcon.SetParent(p, parent)
	pcall(function()
		p.Frame.Parent = parent
	end)
end

function RankIcon:SetLabel(p, p2)
	if not self._label then
		self._label = rankIconLabel:Clone()
		self._label.Parent = self.Frame
		self._label_text = self._label:WaitForChild("Title")
	end

	self._label_text.Text = p or self._label_text.Text
	self._label_text.TextColor3 = p2 or self._label_text.TextColor3
end

function RankIcon:SetLabelFromELOEvent(p, p2, p3)
	if p and math.abs(p) < 0.001 then
		p = math.abs(p)
	end

	self:SetLabel(
		p and string.format("%s%s ", p >= 0 and "+" or "", p) or p2 and Utility:PrettyNumber(p2) or p3 and p3 .. "/" .. SeasonLibrary.CurrentSeason.RankProfile.NumPlacementDuels or "",
		not p and Color3.fromRGB(255, 255, 255) or p > 0 and Color3.fromRGB(100, 255, 50) or p < 0 and Color3.fromRGB(
			255,
			50,
			50
		) or Color3.fromRGB(255, 215, 0)
	)
end

function RankIcon:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	pcall(function()
		self.Frame:Destroy()
	end)
end

function RankIcon:_Setup()
	self.Icon.Image = self.RankInfo.Image
end

function RankIcon:_Init()
	self.Frame.Destroying:Connect(function()
		self:Destroy()
	end)
	self:_Setup()
end

return RankIcon