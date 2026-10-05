local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local GlobalUtil = require(game.ReplicatedStorage.GlobalUtil)
local v = {}

local function onPlayerAdded(p)
	v[p] = {
		Ping = 0.1,
		PastPing = {},
		Requesting = false
	}
end

local RunService2 = game:GetService("RunService")

if RunService2:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
	for _, v2 in pairs(Players:GetPlayers()) do
		task.spawn(onPlayerAdded, v2)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	game.Players.PlayerRemoving:Connect(function(player)
		v[player] = nil
	end)
end

local class = {}
class.__index = class
class.ClassName = "MasterClock"

function class.new(syncEvent, p)
	local object = setmetatable({}, class)
	object.SyncEvent = syncEvent
	object.DelayedRequestFunction = p or error("No DelayedRequestFunction")
	local RunService3 = game:GetService("RunService")

	if not RunService3:IsRunning() or GlobalUtil.FFlags.IsUnitTest ~= false then
		return object
	end

	object.DelayedRequestFunction.OnServerInvoke = function(player, p2)
		local _handleDelayRequest = object:_handleDelayRequest(p2, player)
		task.spawn(function()
			if v[player].Requesting then
				return
			end

			v[player].Requesting = true
			local lastTime = tick()
			pcall(function()
				object.DelayedRequestFunction:InvokeClient(player)
			end)

			if not v[player] then
				return
			end

			v[player].Requesting = false
			local v2 = tick() - lastTime

			if #v[player].PastPing >= 10 then
				table.remove(v[player].PastPing, 1)
			end

			table.insert(v[player].PastPing, v2)

			if #v[player].PastPing >= 5 then
				local v3 = #v[player].PastPing
				local total = 0

				for _, v4 in pairs(v[player].PastPing) do
					total += v4
				end

				local ping = total / v3
				v[player].Ping = ping
			end
		end)
		return _handleDelayRequest
	end

	object.SyncEvent.OnServerEvent:Connect(function(player)
		object.SyncEvent:FireClient(player, object:GetTime())
	end)
	spawn(function()
		while true do
			wait(2)
			object:Sync()
		end
	end)
	return object
end

function class:IsSynced()
	return true
end

function class:GetTime()
	return tick()
end

function class.GetPing(_, p)
	return v[p] and v[p].Ping or 0
end

function class:Sync()
	local time = self:GetTime()
	self.SyncEvent:FireAllClients(time)
end

function class:_handleDelayRequest(p, _)
	return self:GetTime() - p
end

local class2 = {}
class2.__index = class2
class2.ClassName = "SlaveClock"
class2.Offset = -1

function class2.new(syncEvent, delayedRequestFunction)
	local object = setmetatable({}, class2)
	object.SyncEvent = syncEvent
	object.DelayedRequestFunction = delayedRequestFunction
	local RunService3 = game:GetService("RunService")

	if RunService3:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
		object.SyncEvent.OnClientEvent:Connect(function(p)
			object:_handleSyncEvent(p)
		end)

		object.DelayedRequestFunction.OnClientInvoke = function()
			return true
		end

		object.SyncEvent:FireServer()
	end

	return object
end

function class2:GetTime()
	self:IsSynced()
	return self:_getLocalTime() - self.Offset
end

function class2:IsSynced()
	return self.Offset ~= -1
end

function class2:_getLocalTime()
	return tick()
end

function class2:_handleSyncEvent(p)
	local v2 = self:_getLocalTime() - p
	local _sendDelayRequest = self:_sendDelayRequest((self:_getLocalTime()))
	local offset = (v2 - _sendDelayRequest) / 2
	local oneWayDelay = (v2 + _sendDelayRequest) / 2
	self.Offset = offset
	self.OneWayDelay = oneWayDelay
end

function class2:_sendDelayRequest(p2)
	return self.DelayedRequestFunction:InvokeServer(p2)
end

local function BuildClock()
	local timeSyncEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Clock"):WaitForChild("TimeSyncEvent")
	local delayedRequestFunction = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Clock"):WaitForChild("DelayedRequestFunction")

	if RunService:IsClient() and RunService:IsServer() then
		local v2 = class.new(timeSyncEvent, delayedRequestFunction)
		local RunService3 = game:GetService("RunService")

		if RunService3:IsRunning() and GlobalUtil.FFlags.IsUnitTest == false then
			timeSyncEvent.OnClientEvent:Connect(function() end)
		end

		return v2
	elseif RunService:IsClient() then
		return class2.new(timeSyncEvent, delayedRequestFunction)
	else
		return class.new(timeSyncEvent, delayedRequestFunction)
	end
end

return BuildClock()