local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local RankIcon = require(Players.LocalPlayer.PlayerScripts.Modules.RankIcon)
local ELOBar = require(Players.LocalPlayer.PlayerScripts.Modules.ELOBar)
local uDim = UDim2.new(0.8, 0, 0.8, 0)
local uDim2 = UDim2.new(0.5, 0, 0.5, 0)
local uDim3 = UDim2.new(0.5, 0, 0.5, 0)
local uDim4 = UDim2.new(0.5, 0, 0.375, 0)
local Summary = {}
Summary.__index = Summary

function Summary.new(finalResults)
	local self = setmetatable({}, Summary)
	self.FinalResults = finalResults
	self.ELOBar = ELOBar.new()
	self.Frame = self.FinalResults.Frame:WaitForChild("Summary")
	self.Container = self.Frame:WaitForChild("Container")
	self.CardFrame = self.Container:WaitForChild("Card")
	self.BarContainer = self.CardFrame:WaitForChild("BarContainer")
	self.RankFrame = self.CardFrame:WaitForChild("Rank")
	self.RankHeaderFrame = self.RankFrame:WaitForChild("Header")
	self.RankHeaderText = self.RankHeaderFrame:WaitForChild("Title")
	self.RankHeaderTextLeftIcon = self.RankHeaderText:WaitForChild("Left")
	self.RankHeaderTextRightIcon = self.RankHeaderText:WaitForChild("Right")
	self.RankHeaderBackground = self.RankHeaderFrame:WaitForChild("Background")
	self._last_rank_icon = nil
	self._summary_details_hash = 0
	self._summary_details = nil
	self:_Init()
	return self
end

function Summary:GetLocalPlayerPreviousELO()
	if not self._summary_details then
		return Players.LocalPlayer:GetAttribute("DisplayELO")
	end

	if self._summary_details.SummaryType == "RankedELOChanged" then
		return self._summary_details.PreviousELO
	end

	return nil
end

function Summary:HasDetailsReady()
	return self._summary_details ~= nil
end

function Summary:SetDetails(summary_details)
	self._summary_details = summary_details
	self._summary_details_hash += 1
end

function Summary:SetVisible(visible)
	self.Frame.Visible = visible
	self._summary_details_hash += 1

	if visible then
		self:DisplaySummaryDetails()
	end
end

function Summary:DisplaySummaryDetails()
	self._summary_details_hash += 1
	local _summary_details_hash = self._summary_details_hash
	self:_PlayCountingSound(0)
	self:_PlayPromoteSound(0)
	self:_PlayDemoteSound(0)
	self:_PlayShieldSound(0)
	self.BarContainer.Visible = false
	self.RankFrame.Size = UDim2.new(0, 0, 0, 0)
	self.RankFrame.Position = UDim2.new(0.5, 0, 1, 0)
	self.RankFrame:TweenSizeAndPosition(uDim, uDim2, "Out", "Quint", 0.5, true)
	self.RankHeaderText.Text = ""
	self.RankHeaderTextLeftIcon.Visible = false
	self.RankHeaderTextRightIcon.Visible = false

	if self._summary_details.SummaryType == "RankedPlacementsProgress" then
		self:_CreateRankIcon(nil):SetParent(self.RankFrame)
		wait(0.5)

		if _summary_details_hash ~= self._summary_details_hash then
			return
		end
	elseif self._summary_details.SummaryType == "RankedPlacementsComplete" then
		local _CreateRankIcon = self:_CreateRankIcon(nil)
		_CreateRankIcon:SetLabelFromELOEvent(nil, nil, 0)
		_CreateRankIcon:SetParent(self.RankFrame)
		wait(0.5)

		if _summary_details_hash ~= self._summary_details_hash then
			return
		end

		self:_PlayCountingSound()
		Utility:RenderstepForLoop(0, 100, 2, function(p)
			if _summary_details_hash ~= self._summary_details_hash then
				return true
			end

			local v = p / 100
			_CreateRankIcon:SetLabelFromELOEvent(
				nil,
				nil,
				(math.floor(SeasonLibrary.CurrentSeason.RankProfile.NumPlacementDuels * v))
			)
		end)

		if _summary_details_hash ~= self._summary_details_hash then
			return
		end

		wait(1)

		if _summary_details_hash ~= self._summary_details_hash then
			return
		end

		self.RankHeaderText.Text = "Congratulations! You've placed " .. SeasonLibrary:GetRank(
			self._summary_details.PlacementELO,
			Players.LocalPlayer.UserId
		)
		self:_PlayPromoteSound()
		self:_CreateRankIcon(self._summary_details.PlacementELO):SetParent(self.RankFrame)
		self.RankFrame.Size = uDim + UDim2.new(0.4, 0, 0.4, 0)
		self.RankFrame:TweenSize(uDim, "Out", "Back", 0.25, true)
		wait(1)

		if _summary_details_hash ~= self._summary_details_hash then
			return
		end
	elseif self._summary_details.SummaryType == "RankedELOChanged" then
		local _CreateRankIcon = self:_CreateRankIcon(self._summary_details.PreviousELO)
		_CreateRankIcon:SetParent(self.RankFrame)
		wait(0.5)

		if _summary_details_hash ~= self._summary_details_hash then
			return
		end

		self:_PlayCountingSound()
		local v = self._summary_details.CurrentELO - self._summary_details.PreviousELO
		local eLOSaved = self._summary_details.ELOSaved or v
		Utility:RenderstepForLoop(0, 100, 2, function(p)
			if _summary_details_hash ~= self._summary_details_hash then
				return true
			end

			local v2 = p / 100
			_CreateRankIcon:SetLabelFromELOEvent(
				math.floor(eLOSaved * v2),
				self._summary_details.PreviousELO,
				SeasonLibrary.CurrentSeason.RankProfile.NumPlacementDuels
			)
		end)

		if _summary_details_hash ~= self._summary_details_hash then
			return
		end

		wait(1)

		if _summary_details_hash ~= self._summary_details_hash then
			return
		end

		local rank = SeasonLibrary:GetRank(self._summary_details.PreviousELO, Players.LocalPlayer.UserId)
		local rank2 = SeasonLibrary:GetRank(self._summary_details.CurrentELO, Players.LocalPlayer.UserId)

		if self._summary_details.ELOSaved then
			_CreateRankIcon:SetLabelFromELOEvent(
				v,
				self._summary_details.PreviousELO,
				SeasonLibrary.CurrentSeason.RankProfile.NumPlacementDuels
			)
			self.RankFrame.Position = uDim2 + UDim2.new(0, 0, 0.15, 0)
			self.RankFrame:TweenPosition(uDim2, "Out", "Quint", 0.25, true)
			self.RankHeaderText.Text = string.format(
				"Your ELO Shield saved you from <font color=\"rgb(255,50,50)\">%s ELO</font>",
				self._summary_details.ELOSaved
			)
			self.RankHeaderTextLeftIcon.Visible = true
			self.RankHeaderTextRightIcon.Visible = true
			self.RankHeaderTextLeftIcon.Image = "rbxassetid://118920750856778"
			self.RankHeaderTextRightIcon.Image = "rbxassetid://118920750856778"
			self:_PlayShieldSound()
			wait(1)

			if _summary_details_hash ~= self._summary_details_hash then
				return
			end
		elseif rank ~= rank2 then
			local _CreateRankIcon2 = self:_CreateRankIcon(self._summary_details.CurrentELO)
			_CreateRankIcon2:SetLabelFromELOEvent(
				eLOSaved,
				self._summary_details.CurrentELO,
				SeasonLibrary.CurrentSeason.RankProfile.NumPlacementDuels
			)
			_CreateRankIcon2:SetParent(self.RankFrame)
			self.RankFrame.Size = uDim + UDim2.new(0.4, 0, 0.4, 0)
			self.RankFrame:TweenSize(uDim, "Out", "Back", 0.25, true)

			if self._summary_details.CurrentELO > self._summary_details.PreviousELO then
				self.RankHeaderText.Text = "Congratulations! You've promoted to " .. rank2
				self:_PlayPromoteSound()
			else
				self.RankHeaderText.Text = "You've demoted to " .. rank2
				self:_PlayDemoteSound()
			end

			wait(1)

			if _summary_details_hash ~= self._summary_details_hash then
				return
			end
		end
	else
		assert(false, self._summary_details.SummaryType)
	end

	self.RankFrame:TweenSizeAndPosition(uDim3, uDim4, "Out", "Quint", 0.5, true)
	wait(0.1)

	if _summary_details_hash ~= self._summary_details_hash then
		return
	end

	self.BarContainer.Visible = true
	self.ELOBar:Update(true)
end

function Summary:Destroy()
	self._summary_details_hash += 1
	self.ELOBar:Destroy()
end

function Summary:_PlayCountingSound(value)
	self.FinalResults.DuelInterface:CreateSound("rbxassetid://99054764924747", 1 * (value or 1), 1, script, true, 10)
end

function Summary:_PlayPromoteSound(value)
	local v = value or 1
	self.FinalResults.DuelInterface:CreateSound("rbxassetid://138975587469438", 1 * v, 1, script, true, 10)
	task.delay(
		0.125,
		self.FinalResults.DuelInterface.CreateSound,
		self.FinalResults.DuelInterface,
		"rbxassetid://70643163489676",
		1 * v,
		1,
		script,
		true,
		10
	)
end

function Summary:_PlayDemoteSound(value)
	local v = value or 1
	self.FinalResults.DuelInterface:CreateSound("rbxassetid://70643163489676", 1 * v, 0.75, script, true, 10)
	self.FinalResults.DuelInterface:CreateSound("rbxassetid://91547731028928", 1 * v, 1, script, true, 10)
end

function Summary:_PlayShieldSound(value)
	local v = value or 1
	self.FinalResults.DuelInterface:CreateSound("rbxassetid://132313563275913", 0.75 * v, 2, script, true, 10)
	self.FinalResults.DuelInterface:CreateSound("rbxassetid://128864122802098", 1 * v, 1.5, script, true, 10)
end

function Summary:_CreateRankIcon(p2)
	if self._last_rank_icon then
		self._last_rank_icon:Destroy()
		self._last_rank_icon = nil
	end

	self._last_rank_icon = RankIcon.new(p2, Players.LocalPlayer.UserId)
	return self._last_rank_icon
end

function Summary:_UpdateHeader()
	local v = not (self.RankHeaderTextLeftIcon.Visible or self.RankHeaderTextRightIcon.Visible) and 0 or self.RankHeaderTextLeftIcon.AbsoluteSize.X + self.RankHeaderTextRightIcon.AbsoluteSize.X
	self.RankHeaderBackground.Size = UDim2.new(
		0,
		self.RankHeaderText.TextBounds.X + self.RankHeaderText.TextBounds.Y * 1.5 + v,
		1,
		0
	)
	self.RankHeaderBackground.Visible = self.RankHeaderText.TextBounds.X > 0
	self.RankHeaderTextLeftIcon.Position = UDim2.new(0.5, -self.RankHeaderText.TextBounds.X / 2, 0.5, 0)
	self.RankHeaderTextRightIcon.Position = UDim2.new(0.5, self.RankHeaderText.TextBounds.X / 2, 0.5, 0)
end

function Summary:_Setup()
	self.ELOBar:SetParent(self.BarContainer)
end

function Summary:_Init()
	self.RankHeaderText:GetPropertyChangedSignal("TextBounds"):Connect(function()
		self:_UpdateHeader()
	end)
	self.RankHeaderTextLeftIcon:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateHeader()
	end)
	self.RankHeaderTextLeftIcon:GetPropertyChangedSignal("Visible"):Connect(function()
		self:_UpdateHeader()
	end)
	self.RankHeaderTextRightIcon:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_UpdateHeader()
	end)
	self.RankHeaderTextRightIcon:GetPropertyChangedSignal("Visible"):Connect(function()
		self:_UpdateHeader()
	end)
	self:_Setup()
	self:_UpdateHeader()
end

return Summary