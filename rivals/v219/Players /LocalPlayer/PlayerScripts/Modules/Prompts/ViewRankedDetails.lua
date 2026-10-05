local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local ButtonEffect = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local RankIcon = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("RankIcon"))
local Prompt = require(Players.LocalPlayer.PlayerScripts.Modules:WaitForChild("Prompt"))
local rankGraphSlot = Players.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("RankGraphSlot")
local object = setmetatable({}, Prompt)
object.__index = object

function object.new(_, _)
	local self = setmetatable(Prompt.new(script.Name), object)
	self.CloseButton = self.PromptFrame:WaitForChild("Close")
	self.List = self.PromptFrame:WaitForChild("List")
	self.Container = self.List:WaitForChild("Container")
	self.Layout = self.Container:WaitForChild("Layout")
	self.ELOShieldMaxELOAllowedText = self.Container:WaitForChild("ELOShieldMaxELOAllowed")
	self.ELODecayPeriodText = self.Container:WaitForChild("ELODecayPeriod")
	self.ELODecayAmountText = self.Container:WaitForChild("ELODecayAmount")
	self.RanksFrame = self.Container:WaitForChild("Ranks")
	self.RanksContainer = self.RanksFrame:WaitForChild("Container")
	self._rank_icons = {}
	self:_Init()
	return self
end

function object:Destroy()
	for _, _rank_icon in pairs(self._rank_icons) do
		_rank_icon:Destroy()
	end

	Prompt.Destroy(self)
end

function object:_UpdateList()
	self.List.CanvasSize = UDim2.new(0, 0, 0, self.Layout.AbsoluteContentSize.Y)
	self.List.ClipsDescendants = true
end

function object:_GetELORange(p)
	local requiredELOLeaderboardRanking = SeasonLibrary.CurrentSeason.RankProfile.Ranks[SeasonLibrary.CurrentSeason.RankProfile.Groups[p].Ranks[1]].RequiredELOLeaderboardRanking

	if requiredELOLeaderboardRanking then
		return "Top " .. Utility:PrettyNumber(requiredELOLeaderboardRanking)
	end

	local requiredELO = nil
	local v = nil

	for _, v3 in pairs(SeasonLibrary.CurrentSeason.RankProfile.RanksOrder) do
		local rank = SeasonLibrary.CurrentSeason.RankProfile.Ranks[v3]

		if requiredELO or rank.RankGroupName ~= p then
			if requiredELO and rank.RankGroupName ~= p then
				v = rank.RequiredELO - 1
				break
			end
		else
			requiredELO = rank.RequiredELO
		end
	end

	if not requiredELO then
		return ""
	end

	if v then
	end

	return Utility:PrettyNumber(requiredELO) .. "+"
end

function object:_Setup()
	local v = #SeasonLibrary.CurrentSeason.RankProfile.GroupsOrder - 1

	for k, text in pairs(SeasonLibrary.CurrentSeason.RankProfile.GroupsOrder) do
		if k == 1 then
			continue
		end

		local group = SeasonLibrary.CurrentSeason.RankProfile.Groups[text]
		local color = group.Color
		local secondaryColor = group.SecondaryColor
		local visible = group.SecondaryColor ~= Color3.fromRGB(0, 0, 0)
		local clone = rankGraphSlot:Clone()
		clone.Bar.Title.Text = text
		local background = clone.Bar.Background

		if not visible then
			secondaryColor = color
		end

		background.ImageColor3 = secondaryColor
		clone.Bar.BackgroundStriped.ImageColor3 = color
		clone.Bar.BackgroundStriped.Visible = visible
		clone.Bar.Rank.ELO.UIStroke.Color = Color3.new(group.Color.R * 0.25, group.Color.G * 0.25, group.Color.B * 0.25)
		clone.Bar.Rank.ELO.Text = self:_GetELORange(text)
		clone.Bar.Size = UDim2.new(0.9, 0, 0.3 + 0.5 * (k - 2) / (v - 1), 0)
		clone.Size = UDim2.new(1 / v, 0, 1, 0)
		clone.LayoutOrder = k
		clone.ZIndex = k
		clone.Parent = self.RanksContainer
		local rank = SeasonLibrary.CurrentSeason.RankProfile.Ranks[group.Ranks[#group.Ranks]]
		local v4 = RankIcon.new(rank.RequiredELO, nil, rank.RequiredELOLeaderboardRanking or 1e999)
		v4:SetParent(clone.Bar.Rank)
		table.insert(self._rank_icons, v4)
	end

	self.ELOShieldMaxELOAllowedText.Visible = SeasonLibrary.CurrentSeason.ELOShieldMaxELOAllowed or false
	self.ELOShieldMaxELOAllowedText.Text = not self.ELOShieldMaxELOAllowedText.Visible and "" or string.format(
		" • Players with %s+ ELO do not receive ELO Shields",
		Utility:PrettyNumber(SeasonLibrary.CurrentSeason.ELOShieldMaxELOAllowed)
	)
	self.ELODecayPeriodText.Visible = SeasonLibrary.CurrentSeason.ELODecayThreshold or false
	self.ELODecayPeriodText.Text = not self.ELODecayPeriodText.Visible and "" or string.format(
		" • Players with %s+ ELO must play Ranked atleast once every %s to avoid ELO Decay",
		Utility:PrettyNumber(SeasonLibrary.CurrentSeason.ELODecayThreshold),
		Utility:TimeFormat2(SeasonLibrary.CurrentSeason.ELODecayInactivePeriodDays * 24 * 60 * 60, true)
	)
	self.ELODecayAmountText.Visible = SeasonLibrary.CurrentSeason.ELODecayThreshold or false
	self.ELODecayAmountText.Text = not self.ELODecayAmountText.Visible and "" or string.format(
		" • ELO Decay makes you lose %s ELO for every day you remain inactive",
		Utility:PrettyNumber((math.abs(SeasonLibrary.CurrentSeason.ELODecayPerInactiveDay)))
	)
end

function object:_Init()
	self.CloseButton.MouseButton1Click:Connect(function()
		self:CloseRequest()
	end)
	self.Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		self:_UpdateList()
	end)
	self.List:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		self:_UpdateList()
	end)
	self:_Setup()
	self:_UpdateList()
	ButtonEffect:Add(self.CloseButton)
end

return object