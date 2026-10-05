local RunService = game:GetService("RunService")
local Utils = require(script.Parent.Internal.Utils)
local Signal = require(script.Parent.Parent.Signal)
local Network = require(script.Parent.Internal.Network)
local ClientReplion = require(script.ClientReplion)
require(script.Parent.Internal.Types)
local v = {}
local v2 = {}
local v3 = {}
local v4 = Signal.new()
local v5 = Signal.new()

local function getWaitList(p: string)
	local v6 = v2[p]

	if not v6 then
		v6 = {}
		v2[p] = v6
	end

	return assert(v6, "Invalid wait list")
end

local function cancelWait(list, thread: thread)
	for k, v6 in list do
		if v6.thread ~= thread then
			continue
		end

		table.remove(list, k)

		if v6.async then
			Utils.safeCancelThread(thread)
		else
			pcall(task.spawn, thread)
		end

		v3[thread] = nil
		break
	end
end

local function createTimeout(p, duration: number, thread: thread)
	return task.delay(duration, cancelWait, p, thread)
end

local function createReplion(list)
	local v6 = list[2]

	if v[v6] then
		return
	end

	local v7 = ClientReplion.new(list)
	v[v6] = v7
	v[list[1]] = v7
	v4:Fire(v7)
	local v8 = v2[v6]

	if v8 then
		for _, v9 in v8 do
			pcall(task.spawn, v9.thread, v7)
		end

		v2[v6] = nil
	end
end

local v6 = {
	OnReplionAdded = function(self, p)
		return v4:Connect(p)
	end,
	OnReplionRemoved = function(self, p)
		return v5:Connect(p)
	end,
	OnReplionAddedWithTag = function(self, p, callback)
		return self:OnReplionAdded(function(p2)
			local tags = p2.Tags

			if tags and table.find(tags, p) ~= nil then
				callback(p2)
			end
		end)
	end,
	OnReplionRemovedWithTag = function(self, p, callback)
		return self:OnReplionRemoved(function(p2)
			local tags = p2.Tags

			if tags and table.find(tags, p) ~= nil then
				callback(p2)
			end
		end)
	end,
	GetReplion = function(_, p)
		return v[p]
	end,
	WaitReplion = function(_, p, duration)
		local v7 = v[p]

		if v7 then
			return v7
		end

		local thread = coroutine.running()
		local v8 = v2[p]

		if not v8 then
			v8 = {}
			v2[p] = v8
		end

		local v9 = assert(v8, "Invalid wait list")

		if duration then
			v3[thread] = task.delay(duration, cancelWait, v9, thread)
		end

		table.insert(v9, {
			thread = thread
		})
		return coroutine.yield()
	end,
	AwaitReplion = function(_, p, callback, duration)
		local v7 = v[p]

		if v7 then
			return callback(v7)
		end

		local v8 = v2[p]

		if not v8 then
			v8 = {}
			v2[p] = v8
		end

		local v9 = assert(v8, "Invalid wait list")
		local thread = coroutine.create(callback)

		if duration then
			v3[thread] = task.delay(duration, cancelWait, v9, thread)
		end

		table.insert(v9, {
			thread = thread,
			async = true
		})
		return function()
			cancelWait(v9, thread)
		end
	end
}

if Utils.ShouldMock or not RunService:IsClient() then
	return table.freeze(v6)
end

local added = Network.get("Added")
local removed = Network.get("Removed")
local update = Network.get("Update")
local set = Network.get("Set")
local updateReplicateTo = Network.get("UpdateReplicateTo")
local arrayUpdate = Network.get("ArrayUpdate")
added.OnClientEvent:Connect(function(list)
	if type(list[1]) ~= "table" then
		createReplion(list)
		return
	end

	for _, v7 in list do
		createReplion(v7)
	end
end)
removed.OnClientEvent:Connect(function(p: string)
	local v7 = v[p]

	if v7 then
		v[p] = nil
		v[v7._channel] = nil
		v5:Fire(v7)
		v7:Destroy()
	end
end)
update.OnClientEvent:Connect(function(p: string, p2, p3, flag: boolean?)
	local v7 = v[p]

	if v7 then
		v7:_update(p2, p3, flag)
	end
end)
updateReplicateTo.OnClientEvent:Connect(function(p: string, replicateTo)
	local v7 = v[p]

	if v7 then
		v7.ReplicateTo = replicateTo
	end
end)
set.OnClientEvent:Connect(function(p: string, p2, p3)
	local v7 = v[p]

	if v7 then
		v7:_set(p2, p3)
	end
end)
arrayUpdate.OnClientEvent:Connect(function(p: string, p2: string, ...)
	local v7 = v[p]

	if v7 then
		if p2 == "i" then
			v7:_insert(...)
		elseif p2 == "r" then
			v7:_remove(...)
		elseif p2 == "c" then
			v7:_clear(...)
		end
	end
end)
return table.freeze(v6)