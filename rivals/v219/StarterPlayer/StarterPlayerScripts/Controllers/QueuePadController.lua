game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CONSTANTS = require(ReplicatedStorage.Modules.CONSTANTS)
local Signal = require(ReplicatedStorage.Modules.Signal)
local MatchmakingController = require(Players.LocalPlayer.PlayerScripts.Controllers.MatchmakingController)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local DuelController = require(Players.LocalPlayer.PlayerScripts.Controllers.DuelController)
local MatchmakingCountdown = require(Players.LocalPlayer.PlayerScripts.Modules.UserInterface.MatchmakingCountdown)
local ReplicatedController = require(Players.LocalPlayer.PlayerScripts.Modules.ReplicatedController)
local object = setmetatable({}, ReplicatedController)
object.__index = object

function object._new()
	local self = setmetatable(ReplicatedController.new("QueuePad"), object)
	self.LocalPlayerActivity = Signal.new()
	self.ChallengeRequestCooldownChanged = Signal.new()
	self._local_fighter = nil
	self._update_loop_active = false
	self._challenge_cooldowns = {}
	self._actively_on_queue_pad = false
	self:_Init()
	return self
end

function object:IsChallengeRequestOnCooldown(p2)
	return tick() < (self._challenge_cooldowns[p2] or 0)
end

function object:GetQueuePad(p2)
	for _, object2 in pairs(self.Objects) do
		local isInQueue = object2:IsInQueue(p2)

		if isInQueue then
			return object2, isInQueue
		end
	end
end

function object:CanChallenge(p)
	return p and (p ~= Players.LocalPlayer or CONSTANTS.IS_STUDIO) and CONSTANTS.QUEUES_ACTIVE and not DuelController:GetDuel(p)
end

function object:SendChallengeRequest(p)
	if not self:CanChallenge(p) or self:IsChallengeRequestOnCooldown(p) then
		return
	end

	self._challenge_cooldowns[p] = tick() + 15
	self.ChallengeRequestCooldownChanged:Fire()
	task.delay(15, self.ChallengeRequestCooldownChanged.Fire, self.ChallengeRequestCooldownChanged)
	ReplicatedStorage.Remotes.Misc.SendChallengeRequest:FireServer(p)
end

function object:_QueueLeave()
	ReplicatedStorage.Remotes.Misc.QueueLeave:InvokeServer()
	self._actively_on_queue_pad = false
end

function object:_QueueJoin(object2, p2)
	self._actively_on_queue_pad = true
	ReplicatedStorage.Remotes.Misc.QueueJoin:InvokeServer(object2:Get("ObjectID"), p2)
end

function object:_CheckQueueStatus()
	local player = self._local_fighter:IsAlive() and self._local_fighter.Player
	local queuePad, v = self:GetQueuePad(Players.LocalPlayer)
	local isVisible = MatchmakingCountdown:IsVisible()

	if queuePad then
		if not player or self._local_fighter:Get("IsInDuel") or self._local_fighter:Get("IsInShootingRange") or not queuePad:IsWithin(
			player,
			v
		) or isVisible then
			self:_QueueLeave()
		end
	elseif player then
		for _, object3 in pairs(self.Objects) do
			local isWithin = object3:IsWithin(player)

			if not isWithin then
				continue
			end

			if isVisible then
				MatchmakingController:TryLeaveQueue()
			else
				self:_QueueJoin(object3, isWithin)
			end
		end
	end
end

function object:_UpdateLoop()
	if self._update_loop_active then
		return
	end

	self._update_loop_active = true

	while true do
		wait(0.1)

		if CONSTANTS.IS_STUDIO then
			self:_CheckQueueStatus()
		else
			local success, result = pcall(self._CheckQueueStatus, self)

			if not success then
				warn("Failed to check queue status, error:", result)
			end
		end

		if self._actively_on_queue_pad or not (self._local_fighter:Get("IsInDuel") or self._local_fighter:Get("IsInShootingRange")) then
			continue
		end

		self:_QueueLeave()
		self._update_loop_active = false
		break
	end
end

function object:_HookLocalFighter()
	self._local_fighter = FighterController:WaitForLocalFighter()
	self._local_fighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		self:_UpdateLoop()
	end)
	self._local_fighter:GetDataChangedSignal("IsInShootingRange"):Connect(function()
		self:_UpdateLoop()
	end)
	self:_UpdateLoop()
end

function object:_Init()
	self.ObjectAdded:Connect(function(p)
		p.LocalPlayerActivity:Connect(function()
			self.LocalPlayerActivity:Fire()
		end)
	end)
	task.defer(self._HookLocalFighter, self)
end

return object._new()