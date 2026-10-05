local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CosmeticLibrary = require(ReplicatedStorage.Modules.CosmeticLibrary)
local SpectateController = require(Players.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local EmoteSoundLogic = {}
EmoteSoundLogic.__index = EmoteSoundLogic

function EmoteSoundLogic.new(emoteController)
	local self = setmetatable({}, EmoteSoundLogic)
	self.EmoteController = emoteController
	self._emotes_order = {}
	self:_Init()
	return self
end

function EmoteSoundLogic:_GetDistance(p)
	local position = workspace.CurrentCamera.CFrame.Position
	local position2 = p.Entity and p.Entity.RootPart and p.Entity.RootPart.Position

	if position2 then
		return (position - position2).Magnitude
	end

	return nil
end

function EmoteSoundLogic:_IsValidFighter(object2)
	local environmentID

	if SpectateController.CurrentSubject then
		environmentID = SpectateController.CurrentSubject:Get("EnvironmentID")
	elseif SpectateController.CurrentDuelSubject then
		environmentID = SpectateController.CurrentDuelSubject:Get("EnvironmentID")
	end

	if environmentID ~= object2:Get("EnvironmentID") then
		return false
	end

	local _GetDistance = self:_GetDistance(object2)

	if _GetDistance and not (_GetDistance > 128) then
		return true
	end

	return false
end

function EmoteSoundLogic:_VerifyEmotesOrder()
	local v = {}

	for i = #self._emotes_order, 1, -1 do
		local v2 = self._emotes_order[i]
		v[v2.ClientFighter] = true

		if not (v2.Emote:IsDestroyed() or not self:_IsValidFighter(v2.ClientFighter)) then
			continue
		end

		v2.Emote:HideSounds(false)
		table.remove(self._emotes_order, i)
	end

	for _, object2 in pairs(FighterController.Objects) do
		if v[object2] then
			continue
		end

		local currentEmote = object2.Entity and object2.Entity:IsEmoting() and object2.Entity:GetCurrentEmote()

		if currentEmote and CosmeticLibrary.Cosmetics[currentEmote.Name].IsAudioIntrusive and self:_IsValidFighter(object2) then
			table.insert(self._emotes_order, {
				Emote = currentEmote,
				ClientFighter = object2
			})
		end
	end

	table.clear(v)
	table.sort(self._emotes_order, function(a, b)
		return self:_GetDistance(a.ClientFighter) < self:_GetDistance(b.ClientFighter)
	end)
end

function EmoteSoundLogic:_Check()
	self:_VerifyEmotesOrder()
	local isAudioIntrusive = SpectateController:IsSubjectEmoting() and CosmeticLibrary.Cosmetics[SpectateController.CurrentSubject.Entity:GetCurrentEmote().Name].IsAudioIntrusive

	for k, v in pairs(self._emotes_order) do
		if isAudioIntrusive then
			v.Emote:HideSounds(v.ClientFighter ~= SpectateController.CurrentSubject)
		else
			v.Emote:HideSounds(k > 1)
		end
	end
end

function EmoteSoundLogic:_CheckLoop()
	while true do
		self:_Check()
		wait(1)
	end
end

function EmoteSoundLogic:_FighterAdded(p, p2)
	local function entity_added(p3)
		p3.EmoteStatusChanged:Connect(function()
			self:_Check()
		end)

		if not p2 then
			self:_Check()
		end
	end

	p.EntityAdded:Connect(entity_added)

	if p.Entity then
		task.spawn(entity_added, p.Entity)
	end

	if not p2 then
		self:_Check()
	end
end

function EmoteSoundLogic:_Init()
	SpectateController.SubjectEmoteStatusChanged:Connect(function()
		self:_Check()
	end)
	FighterController.ObjectAdded:Connect(function(p)
		self:_FighterAdded(p)
	end)

	for _, object2 in pairs(FighterController.Objects) do
		task.spawn(self._FighterAdded, self, object2, true)
	end

	task.defer(self._CheckLoop, self)
end

return EmoteSoundLogic