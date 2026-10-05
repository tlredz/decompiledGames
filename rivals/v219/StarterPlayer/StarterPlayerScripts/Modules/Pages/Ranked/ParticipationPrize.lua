local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local SeasonLibrary = require(ReplicatedStorage.Modules.SeasonLibrary)
local PlayerDataController = require(Players.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local BaseContractSlot = require(Players.LocalPlayer.PlayerScripts.Modules.BaseContractSlot)
local ParticipationPrize = {}
ParticipationPrize.__index = ParticipationPrize

function ParticipationPrize.new(page)
	local self = setmetatable({}, ParticipationPrize)
	self.Page = page
	self._base_contract_slot = BaseContractSlot.new()
	self:_Init()
	return self
end

function ParticipationPrize:Open()
	self:_Update()
end

function ParticipationPrize.Close(_) end

function ParticipationPrize:_Update()
	local v = PlayerDataController:Get("Seasons")[SeasonLibrary.CurrentSeason.Name]
	local v2 = v and v.RankedPerformances[SeasonLibrary.UNIVERSAL_ELO_NAME]
	local visible = v2 and v2.CurrentELO ~= nil
	self._base_contract_slot.Frame.Visible = visible

	if not self._base_contract_slot.Frame.Visible then
		return
	end

	local v4 = v2.DuelsWon * SeasonLibrary.CurrentSeason.ParticipationPointsPerWin + v2.DuelsLost * SeasonLibrary.CurrentSeason.ParticipationPointsPerLoss
	self._base_contract_slot:SetProgress(v4)
end

function ParticipationPrize:_Setup()
	local participationPointsPerWin = SeasonLibrary.CurrentSeason.ParticipationPointsPerWin
	local participationPointsPerLoss = SeasonLibrary.CurrentSeason.ParticipationPointsPerLoss
	local v = string.format(
		"Earn %s point%s from every ranked win",
		participationPointsPerWin,
		participationPointsPerWin == 1 and "" or "s"
	)
	local v2 = string.format(
		"Earn %s point%s from every ranked loss",
		participationPointsPerLoss,
		participationPointsPerLoss == 1 and "" or "s"
	)

	if participationPointsPerWin > 0 and participationPointsPerLoss > 0 then
		v ..= " • " .. v2
	elseif not (participationPointsPerWin > 0) then
		v = not (participationPointsPerLoss > 0) and "???" or v2
	end

	local v3 = v .. "   •   Only available during Season " .. SeasonLibrary.CurrentSeason.Version
	self._base_contract_slot:SetImage("rbxassetid://117835427046796")
	self._base_contract_slot:SetTitle("Ranked Contract")
	self._base_contract_slot:SetDescription(v3)
	self._base_contract_slot:SetScale(0.75)

	for _, list in pairs(SeasonLibrary.CurrentSeason.ParticipationPrizes) do
		local v4, v5 = table.unpack(list)
		self._base_contract_slot:AddMilestone(v4, v5)
	end

	self._base_contract_slot.Frame.LayoutOrder = 30
	self._base_contract_slot.Frame.Parent = self.Page.Container
end

function ParticipationPrize:_Init()
	self:_Setup()
end

return ParticipationPrize