local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Signal = require(ReplicatedStorage.Modules.Signal)
local FighterController = require(Players.LocalPlayer.PlayerScripts.Controllers.FighterController)
local class = {}
class.__index = class

function class._new()
	local self = setmetatable({}, class)
	self.Refreshed = Signal.new()
	self.LeaderboardSerials = {}
	self._leaderboard_refreshed_signals = {}
	self._leaderboard_refresh_requests = {}
	self._local_fighter = nil
	self._next_request = 0
	self:_Init()
	return self
end

function class:GetLeaderboardRefreshedSignal(p2)
	if not self._leaderboard_refreshed_signals[p2] then
		self._leaderboard_refreshed_signals[p2] = Signal.new()
	end

	return self._leaderboard_refreshed_signals[p2]
end

function class.GetRankingByUserID(p, p2, p3)
	local leaderboardSerial = p.LeaderboardSerials[p2]

	if not leaderboardSerial then
		return
	end

	local v = tostring(p3)

	for k, player in pairs(leaderboardSerial.Players) do
		if v == player.key then
			return k
		end
	end
end

function class.GetRankingByValue(p, p2, p3)
	local leaderboardSerial = p.LeaderboardSerials[p2]

	if not leaderboardSerial then
		return
	end

	for k, player in pairs(leaderboardSerial.Players) do
		if player.value <= p3 then
			return k
		end
	end
end

function class:_FetchLeaderboards()
	if #self._leaderboard_refresh_requests == 0 or self._local_fighter and (self._local_fighter:Get("IsInDuel") or self._local_fighter:Get("IsInShootingRange")) then
		return
	end

	if tick() < self._next_request then
		task.delay(self._next_request - tick(), self._FetchLeaderboards, self)
		return
	end

	self._next_request = tick() + 2
	ReplicatedStorage.Remotes.Misc.RequestLeaderboards:FireServer(self._leaderboard_refresh_requests)
	self._leaderboard_refresh_requests = {}
end

function class:_HookFighter()
	self._local_fighter = FighterController:WaitForLocalFighter()
	self._local_fighter:GetDataChangedSignal("IsInDuel"):Connect(function()
		self:_FetchLeaderboards()
	end)
	self._local_fighter:GetDataChangedSignal("IsInShootingRange"):Connect(function()
		self:_FetchLeaderboards()
	end)
	self:_FetchLeaderboards()
end

function class:_Setup()
	ReplicatedStorage.Remotes.Misc.RequestLeaderboards:FireServer()
end

function class:_Init()
	self.Refreshed:Connect(function(p)
		if self._leaderboard_refreshed_signals[p] then
			self._leaderboard_refreshed_signals[p]:Fire()
		end
	end)
	ReplicatedStorage.Remotes.Misc.LeaderboardRefreshed.OnClientEvent:Connect(function(p)
		if not table.find(self._leaderboard_refresh_requests, p) then
			table.insert(self._leaderboard_refresh_requests, p)
		end

		self:_FetchLeaderboards()
	end)
	ReplicatedStorage.Remotes.Misc.UpdateLeaderboard.OnClientEvent:Connect(function(p)
		self.LeaderboardSerials[p.Name] = p
		self.Refreshed:Fire(p.Name)
	end)
	self:_Setup()
	task.defer(self._HookFighter, self)
end

return class._new()