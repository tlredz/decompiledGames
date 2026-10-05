local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules.RewardSlot)
local RankIcon = require(Players.LocalPlayer.PlayerScripts.Modules.RankIcon)
local TopReward = {}
TopReward.__index = TopReward

function TopReward.new(page)
	local self = setmetatable({}, TopReward)
	self.Page = page
	self.Frame = self.Page.Container:WaitForChild("TopReward")
	self.RankContainer = self.Frame:WaitForChild("RankContainer")
	self.Container = self.Frame:WaitForChild("Container")
	self.Title = self.Frame:WaitForChild("Title")
	self.Description = self.Frame:WaitForChild("Description")
	self.Description2 = self.Frame:WaitForChild("Description2")
	self:_Init()
	return self
end

function TopReward:Open()
	self:_Update()
end

function TopReward.Close(_) end

function TopReward:_GetTopRankDetails()
	local rank = SeasonLibrary:GetRank(1e999, nil, SeasonLibrary.CurrentSeason.TopPlayerLeaderboardRank)
	return rank, SeasonLibrary.CurrentSeason.RankProfile.Ranks[rank].RequiredELO
end

function TopReward:_Update()
	if not SeasonLibrary.CurrentSeason.TopPlayerRewardSkinName then
		self.Frame.Visible = false
		return
	end

	local v = PlayerDataController:Get("Seasons")[SeasonLibrary.CurrentSeason.Name]
	local v2 = v and v.RankedPerformances[SeasonLibrary.UNIVERSAL_ELO_NAME]
	local currentELO = v2 and v2.CurrentELO
	local _, v3 = self:_GetTopRankDetails()
	self.Frame.Visible = currentELO and v3 <= currentELO
end

function TopReward:_Setup()
	local _GetTopRankDetails, _ = self:_GetTopRankDetails()
	local topPlayerRewardSkinName = SeasonLibrary.CurrentSeason.TopPlayerRewardSkinName

	if not topPlayerRewardSkinName then
		return
	end

	local cosmetic = CosmeticLibrary.Cosmetics[topPlayerRewardSkinName]
	self.Title.Text = topPlayerRewardSkinName
	self.Description.Text = string.format(
		"Become %s by reaching top %s on the Ranked Leaderboard!",
		_GetTopRankDetails,
		SeasonLibrary.CurrentSeason.TopPlayerLeaderboardRank
	)
	self.Description2.Text = string.format(
		"The %s %s skin will be rewarded to %s players at season end!",
		cosmetic.Rarity,
		topPlayerRewardSkinName,
		_GetTopRankDetails
	)
	RankIcon.new(1e999, nil, SeasonLibrary.CurrentSeason.TopPlayerLeaderboardRank):SetParent(self.RankContainer)
	RewardSlot.new({
		Name = topPlayerRewardSkinName,
		Weapon = cosmetic.ItemName
	}):SetParent(self.Container)
end

function TopReward:_Init()
	self:_Setup()
end

return TopReward