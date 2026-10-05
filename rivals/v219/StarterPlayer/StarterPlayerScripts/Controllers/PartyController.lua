local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Signal = require(ReplicatedStorage.Modules.Signal)
local DuelController = require(Players.LocalPlayer.PlayerScripts.Controllers.DuelController)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.PartyChanged = Signal.new()
	self.InviteRequestCooldownChanged = Signal.new()
	self.CurrentParty = nil
	self._invite_cooldowns = {}
	self:_Init()
	return self
end

function class:IsPartyLeader()
	return not self.CurrentParty or self.CurrentParty[1] == Players.LocalPlayer
end

function class:IsInParty(p2)
	return self.CurrentParty and table.find(self.CurrentParty, p2)
end

function class:IsInviteRequestOnCooldown(p2)
	return tick() < (self._invite_cooldowns[p2] or 0)
end

function class:CanInvitePlayerToParty(p)
	return p and (p ~= Players.LocalPlayer or CONSTANTS.IS_STUDIO) and self:IsPartyLeader() and not (self:IsInParty(p) or DuelController:GetDuel(p))
end

function class:SendPartyInvite(p)
	if not self:CanInvitePlayerToParty(p) or self:IsInviteRequestOnCooldown(p) then
		return
	end

	self._invite_cooldowns[p] = tick() + 15
	self.InviteRequestCooldownChanged:Fire()
	task.delay(15, self.InviteRequestCooldownChanged.Fire, self.InviteRequestCooldownChanged)
	ReplicatedStorage.Remotes.Matchmaking.SendPartyInvite:FireServer(p)
end

function class._FetchParty(_)
	ReplicatedStorage.Remotes.Matchmaking.RequestOneTimePartyReplication:FireServer()
end

function class:_Init()
	ReplicatedStorage.Remotes.Matchmaking.UpdateParty.OnClientEvent:Connect(function(currentParty)
		self.CurrentParty = currentParty
		self.PartyChanged:Fire()
	end)
	task.defer(self._FetchParty, self)
end

return class._new()