local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local Utility = require(ReplicatedStorage.Modules.Utility)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local RewardSlot = require(Players.LocalPlayer.PlayerScripts.Modules.RewardSlot)
local GloryPayout = {}
GloryPayout.__index = GloryPayout

function GloryPayout.new(page)
	local self = setmetatable({}, GloryPayout)
	self.Page = page
	self.Frame = self.Page.Container:WaitForChild("GloryPayout")
	self.Container = self.Frame:WaitForChild("Container")
	self.Description = self.Frame:WaitForChild("Description")
	self.Description2 = self.Frame:WaitForChild("Description2")
	self._reward_slot = nil
	self:_Init()
	return self
end

function GloryPayout:Open()
	self:_Update()
end

function GloryPayout.Close(_) end

function GloryPayout:_Update()
	if self._reward_slot then
		self._reward_slot:Destroy()
		self._reward_slot = nil
	end

	local v = PlayerDataController:Get("Seasons")[SeasonLibrary.CurrentSeason.Name]
	local v2 = v and v.RankedPerformances[SeasonLibrary.UNIVERSAL_ELO_NAME]
	local visible = v2 and v2.CurrentELO ~= nil
	self.Frame.Visible = visible

	if not self.Frame.Visible then
		return
	end

	local gloryPayout = SeasonLibrary:GetGloryPayout(SeasonLibrary.CurrentSeason.Name, v)
	self.Description.Text = string.format(
		"You'll receive <font transparency=\"0\" weight=\"900\">%s Glory</font> when this season ends!",
		gloryPayout
	)
	self.Description2.Text = string.format(
		"Based on your total ranked wins (<font transparency=\"0\" weight=\"900\">%s</font> / %s) and your final ELO (<font transparency=\"0\" weight=\"900\">%s</font> / %s)",
		Utility:PrettyNumber((math.min(v2.DuelsWon, SeasonLibrary.CurrentSeason.GloryPayoutMaxWins))),
		Utility:PrettyNumber(SeasonLibrary.CurrentSeason.GloryPayoutMaxWins),
		Utility:PrettyNumber((math.min(v2.CurrentELO, SeasonLibrary.CurrentSeason.GloryPayoutMaxELO))),
		Utility:PrettyNumber(SeasonLibrary.CurrentSeason.GloryPayoutMaxELO)
	)
	self._reward_slot = RewardSlot.new({
		Name = "Glory",
		Quantity = gloryPayout
	})
	self._reward_slot:SetParent(self.Container)
end

function GloryPayout:_Init() end

return GloryPayout