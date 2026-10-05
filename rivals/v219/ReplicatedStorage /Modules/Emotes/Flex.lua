local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Utility = require(ReplicatedStorage.Modules.Utility)
local Emote = require(ReplicatedStorage.Modules.Emote)
local RankIcon = CONSTANTS.IS_CLIENT and require(Players.LocalPlayer.PlayerScripts.Modules.RankIcon)
local object = setmetatable({}, Emote)
object.__index = object

function object.new(...)
	local self = setmetatable(Emote.new(nil, script.Name, ...), object)
	self:_Init()
	return self
end

function object:PlayClient(...)
	Emote.PlayClient(self, ...)
	self:_PlayAnimation("rbxassetid://110098633210491", "rbxassetid://125433333048429", 4.85)
	local playerFromCharacter = self._humanoid and self._humanoid.Parent and Players:GetPlayerFromCharacter(self._humanoid.Parent) or Players.LocalPlayer
	local statisticDuelsWinStreak = playerFromCharacter and playerFromCharacter:GetAttribute("StatisticDuelsWinStreak")
	local level = playerFromCharacter and playerFromCharacter:GetAttribute("Level")
	local displayELO = playerFromCharacter and playerFromCharacter:GetAttribute("DisplayELO")
	local userId = playerFromCharacter and playerFromCharacter.UserId
	local _SetupMultipleProps = self:_SetupMultipleProps(script.FlexProp)
	_SetupMultipleProps.Pillow1.Attachment.BillboardGui.Streak.Value.Text = Utility:PrettyNumber(statisticDuelsWinStreak or 0)
	_SetupMultipleProps.Pillow2.Attachment.BillboardGui.Level.Title.Text = Utility:PrettyNumber(level or 1)
	RankIcon.new(displayELO, userId):SetParent(_SetupMultipleProps.Pillow3.Attachment.BillboardGui.Rank)
	self:CreateSound("rbxassetid://97330697628857", 0.75, 1, nil, true)
end

function object:_Init() end

return object