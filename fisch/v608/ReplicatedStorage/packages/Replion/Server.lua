local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Freeze = require(script.Parent.Parent.Freeze)
local Utils = require(script.Parent.Internal.Utils)
local Network = require(script.Parent.Internal.Network)
local ServerReplion = require(script.ServerReplion)
local Signal = require(script.Parent.Parent.Signal)
require(script.Parent.Internal.Types)
local v = Signal.new()
local v2 = Signal.new()
local v3 = {}
local v4 = {}
local v5 = {}

local function getCache(p, p2: string)
	local v6 = p[p2]

	if not v6 then
		v6 = {}
		p[p2] = v6
	end

	return v6
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
			task.spawn(thread)
		end

		v5[thread] = nil
		break
	end
end

local function createTimeout(p, duration: number, thread: thread)
	return task.delay(duration, cancelWait, p, thread)
end

local Replion = {
	new = function(p)
		local v6 = assert(p.Channel, "Channel is required!")
		local v7 = v3
		local v8 = v7[v6]

		if not v8 then
			v8 = {}
			v7[v6] = v8
		end

		local replicateTo = p.ReplicateTo

		for _, v9 in v8 do
			local replicateTo2 = v9.ReplicateTo
			local v10 = replicateTo2 == replicateTo

			if not v10 and type(replicateTo2) == "table" and type(replicateTo) == "table" then
				for _, item in replicateTo2 do
					v10 = table.find(replicateTo, item) ~= nil

					if v10 then
						break
					end
				end
			end

			if not v10 then
				continue
			end

			local v11 = nil

			if typeof(replicateTo2) == "Instance" then
				v11 = tostring(replicateTo2)
			elseif type(replicateTo2) == "string" then
				v11 = replicateTo2
			elseif type(replicateTo2) == "table" then
				for _, item in replicateTo2 do
					v11 = (not v11 and "" or v11 .. ", ") .. tostring(item)
				end
			end

			error((`Channel "{v6}" already exists! for "{v11}"`))
		end

		local v9 = ServerReplion.new(p)
		v9:BeforeDestroy(function()
			local index = table.find(v8, v9)

			if index then
				table.remove(v8, index)
			end

			if #v8 == 0 then
				v3[v6] = nil
			end

			v2:Fire(v6, v9)
		end)
		table.insert(v8, v9)
		v:Fire(v6, v9)
		local v10 = v4[v6]

		if not v10 then
			return v9
		end

		for i = #v10, 1, -1 do
			local v11 = v10[i]
			local thread = v11.thread
			local player = v11.player
			local replicateTo2 = v9.ReplicateTo

			if player then
				local v12 = false

				if typeof(replicateTo2) == "Instance" then
					v12 = replicateTo2 == player
				elseif type(replicateTo2) == "table" then
					v12 = table.find(replicateTo2, player) ~= nil
				end

				if not v12 then
					continue
				end
			end

			local v12 = v5[thread]

			if v12 then
				Utils.safeCancelThread(v12)
				v5[thread] = nil
			end

			task.spawn(thread, v9)
			table.remove(v10, i)
		end

		return v9
	end,
	GetReplion = function(self, p: string)
		local v6 = v3[p]

		if not v6 then
			return nil
		end

		assert(#v6 == 1, (`There are multiple replions with the channel "{p}". Did you mean to use GetReplionFor?`))
		return v6[1]
	end,
	GetReplionFor = function(self, p, p2)
		local v6 = v3[p2]

		if v6 then
			for _, v7 in v6 do
				if v7.ReplicateTo == p and v7.Channel == p2 then
					return v7
				end
			end
		end

		return nil
	end,
	GetReplionsFor = function(self, p)
		local result = {}

		for _, v6 in v3 do
			for _, v7 in v6 do
				local replicateTo = v7.ReplicateTo
				local v8 = replicateTo == "All"

				if not v8 then
					if type(replicateTo) == "table" then
						v8 = table.find(replicateTo, p) ~= nil
					else
						v8 = replicateTo == p or v8
					end
				end

				if v8 then
					table.insert(result, v7)
				end
			end
		end

		return result
	end,
	WaitReplion = function(self, p, duration)
		local replion = self:GetReplion(p)

		if replion then
			return replion
		end

		local thread = coroutine.running()
		local v6 = v4
		local v7 = v6[p]

		if not v7 then
			v7 = {}
			v6[p] = v7
		end

		if duration then
			v5[thread] = task.delay(duration, cancelWait, v7, thread)
		end

		table.insert(v7, {
			thread = thread
		})
		return coroutine.yield()
	end,
	WaitReplionFor = function(self, player, p2, duration)
		local replionFor = self:GetReplionFor(player, p2)

		if replionFor then
			return replionFor
		end

		local thread = coroutine.running()
		local v6 = v4
		local v7 = v6[p2]

		if not v7 then
			v7 = {}
			v6[p2] = v7
		end

		if duration then
			v5[thread] = task.delay(duration, cancelWait, v7, thread)
		end

		table.insert(v7, {
			thread = thread,
			player = player
		})
		return coroutine.yield()
	end,
	AwaitReplion = function(self, p, callback, duration)
		local replion = self:GetReplion(p)

		if replion then
			return callback(replion)
		end

		local v6 = v4
		local v7 = v6[p]

		if not v7 then
			v7 = {}
			v6[p] = v7
		end

		local thread = coroutine.create(callback)

		if duration then
			v5[thread] = task.delay(duration, cancelWait, v7, thread)
		end

		table.insert(v7, {
			thread = thread,
			async = true
		})
		return function()
			cancelWait(v7, thread)
		end
	end,
	AwaitReplionFor = function(self, player, p2, callback, duration)
		local replionFor = self:GetReplionFor(player, p2)

		if replionFor then
			return callback(replionFor)
		end

		local v6 = v4
		local v7 = v6[p2]

		if not v7 then
			v7 = {}
			v6[p2] = v7
		end

		local thread = coroutine.create(callback)

		if duration then
			v5[thread] = task.delay(duration, cancelWait, v7, thread)
		end

		table.insert(v7, {
			thread = thread,
			player = player,
			async = true
		})
		return function()
			cancelWait(v7, thread)
		end
	end,
	OnReplionAdded = function(_, p)
		return v:Connect(p)
	end,
	OnReplionRemoved = function(_, p)
		return v2:Connect(p)
	end
}

if not Utils.ShouldMock and RunService:IsServer() then
	Network.create({
		"Added",
		"Removed",
		"Update",
		"UpdateReplicateTo",
		"Set",
		"ArrayUpdate"
	})

	local function onPlayerAdded(p)
		local replionsFor = Replion:GetReplionsFor(p)
		local v6 = {}

		for _, v7 in replionsFor do
			table.insert(v6, v7:_serialize())
		end

		if #v6 > 0 then
			Network.sendTo(p, "Added", v6)
		end
	end

	for _, v6 in Players:GetPlayers() do
		task.spawn(onPlayerAdded, v6)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(function(player)
		for _, v6 in v3 do
			for _, v7 in v6 do
				local replicateTo = v7.ReplicateTo

				if replicateTo == "All" then
					continue
				end

				if type(replicateTo) == "table" then
					v7:SetReplicateTo((Freeze.List.removeValue(replicateTo, player)))
				elseif replicateTo == player then
					v7:Destroy()
				end
			end
		end

		for _, list in v4 do
			for i = #list, 1, -1 do
				local v6 = list[i]
				local thread = v6.thread

				if v6.player ~= player then
					continue
				end

				if v6.async then
					Utils.safeCancelThread(thread)
				else
					task.spawn(thread)
				end

				v5[thread] = nil
				table.remove(list, i)
			end
		end
	end)
end

return Replion