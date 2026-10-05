local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DuelLibrary = require(ReplicatedStorage.Modules.DuelLibrary)
local BeginnerDuel = {}
BeginnerDuel.__index = BeginnerDuel

function BeginnerDuel.new(clientDuel)
	local self = setmetatable({}, BeginnerDuel)
	self.ClientDuel = clientDuel
	self:_Init()
	return self
end

function BeginnerDuel.Destroy(_) end

function BeginnerDuel:_Highlight()
	if not (self.ClientDuel.LocalDueler and self.ClientDuel:Get("IsSpectating")) then
		return
	end

	local queueName = self.ClientDuel:Get("QueueName")

	if not queueName or not DuelLibrary.MatchmakingQueues[queueName] or DuelLibrary.MatchmakingQueues[queueName].TitleName ~= "Beginner" then
		return
	end

	for _, dueler in pairs(self.ClientDuel.Duelers) do
		if not (dueler.ClientFighter and dueler.ClientFighter.Entity) then
			continue
		end

		if not (not self.ClientDuel.LocalDueler:Get("TeamID") or self.ClientDuel.LocalDueler:Get("TeamID") ~= dueler:Get("TeamID")) then
			continue
		end

		dueler.ClientFighter.Entity:SetRedFigureMode(true, true)
	end
end

function BeginnerDuel:_Init()
	self.ClientDuel:GetDataChangedSignal("IsSpectating"):Connect(function()
		self:_Highlight()
	end)
	self.ClientDuel:GetDataChangedSignal("Status"):Connect(function()
		if self.ClientDuel:Get("Status") == "RoundStarted" or self.ClientDuel:Get("Status") == "RoundStarting" then
			self:_Highlight()
		end
	end)
	task.defer(self._Highlight, self)
end

return BeginnerDuel