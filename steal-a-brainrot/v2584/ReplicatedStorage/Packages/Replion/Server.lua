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
local v6 = {}

local function getCache(p, p2)
	local v7 = p[p2]

	if not v7 then
		v7 = {}
		p[p2] = v7
	end

	return v7
end

local function cancelWait(list, thread: thread)
	for k, v7 in list do
		if v7.thread ~= thread then
			continue
		end

		table.remove(list, k)

		if v7.async then
			Utils.safeCancelThread(thread)
		else
			pcall(task.spawn, thread)
		end

		v6[thread] = nil
		break
	end
end

local function createTimeout(p, duration: number, thread: thread)
	return task.delay(duration, cancelWait, p, thread)
end

local Replion = {
	new = function(p)
		local v7 = assert(p.Channel, "Channel is required!")
		local v8 = v3
		local v9 = v8[v7]

		if not v9 then
			v9 = {}
			v8[v7] = v9
		end

		local replicateTo = p.ReplicateTo

		for _, v10 in v9 do
			local replicateTo2 = v10.ReplicateTo
			local v11 = replicateTo2 == replicateTo

			if not v11 and type(replicateTo2) == "table" and type(replicateTo) == "table" then
				for _, item in replicateTo2 do
					v11 = table.find(replicateTo, item) ~= nil

					if v11 then
						break
					end
				end
			end

			if not v11 then
				continue
			end

			local v12 = nil

			if typeof(replicateTo2) == "Instance" or typeof(replicateTo2) == "userdata" then
				v12 = tostring(replicateTo2)
			elseif type(replicateTo2) == "string" then
				v12 = replicateTo2
			elseif type(replicateTo2) == "table" then
				for _, item in replicateTo2 do
					v12 = (not v12 and "" or v12 .. ", ") .. tostring(item)
				end
			end

			error((`Channel "{v7}" already exists! for "{v12}"`))
		end

		local v10 = ServerReplion.new(p)
		v10:BeforeDestroy(function()
			v9[v10._id] = nil

			if not next(v9) then
				v3[v7] = nil
			end

			v2:Fire(v7, v10)
			v10 = nil
		end)
		v10._replicateToChanged:Connect(function(player, player2)
			if typeof(player2) == "Instance" and player2:IsA("Player") then
				local v11 = v5[player2]

				if v11 then
					v11[v7] = nil
				end
			elseif typeof(player2) == "table" then
				for _, item in player2 do
					local v11 = v5[item]

					if v11 then
						v11[v7] = nil
					end
				end
			end

			if typeof(player) == "Instance" and player:IsA("Player") then
				local v11 = v5
				local _ids = v11[player]

				if not _ids then
					_ids = {}
					v11[player] = _ids
				end

				_ids[v7] = v10._id
			elseif typeof(player) == "table" then
				for _, item in player do
					local v11 = v5
					local _ids = v11[item]

					if not _ids then
						_ids = {}
						v11[item] = _ids
					end

					_ids[v7] = v10._id
				end
			end
		end)
		v9[v10._id] = v10
		v:Fire(v7, v10)

		if typeof(replicateTo) == "Instance" or Utils.ShouldMock and typeof(replicateTo) == "userdata" then
			local v11 = v5
			local _ids = v11[replicateTo]

			if not _ids then
				_ids = {}
				v11[replicateTo] = _ids
			end

			_ids[v7] = v10._id
		elseif type(replicateTo) == "table" then
			for _, item in replicateTo do
				local v11 = v5
				local _ids = v11[item]

				if not _ids then
					_ids = {}
					v11[item] = _ids
				end

				_ids[v7] = v10._id
			end
		end

		local v11 = v4[v7]

		if not v11 then
			return v10
		end

		for i = #v11, 1, -1 do
			local v12 = v11[i]
			local thread = v12.thread
			local player = v12.player

			if player then
				local v13 = false

				if typeof(replicateTo) == "Instance" or typeof(replicateTo) == "userdata" then
					v13 = replicateTo == player
				elseif type(replicateTo) == "table" then
					v13 = table.find(replicateTo, player) ~= nil
				end

				if not v13 then
					continue
				end
			end

			local v13 = v6[thread]

			if v13 then
				Utils.safeCancelThread(v13)
				v6[thread] = nil
			end

			if coroutine.status(thread) == "suspended" then
				task.spawn(thread, v10)
			end

			table.remove(v11, i)
		end

		return v10
	end,
	GetReplion = function(self, p: string)
		local v7 = v3[p]

		if not v7 then
			return nil
		end

		assert(
			Freeze.Dictionary.count(v7) == 1,
			(`There are multiple replions with the channel "{p}". Did you mean to use GetReplionFor?`)
		)
		local _, v8 = next(v7)
		return v8
	end,
	GetReplionFor = function(self, p, p2)
		local v7 = v3[p2]

		if not v7 then
			return nil
		end

		local v8 = v5[p]

		if v8 then
			return v7[v8[p2]]
		end

		return nil
	end,
	GetReplionsFor = function(self, p)
		local result = {}

		for _, v7 in v3 do
			for _, v8 in v7 do
				local replicateTo = v8.ReplicateTo
				local v9 = replicateTo == "All"

				if not v9 then
					if type(replicateTo) == "table" then
						v9 = table.find(replicateTo, p) ~= nil
					else
						v9 = replicateTo == p or v9
					end
				end

				if v9 then
					table.insert(result, v8)
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
		local v7 = v4
		local v8 = v7[p]

		if not v8 then
			v8 = {}
			v7[p] = v8
		end

		if duration then
			v6[thread] = task.delay(duration, cancelWait, v8, thread)
		end

		table.insert(v8, {
			thread = thread
		})
		return coroutine.yield()
	end,
	WaitReplionFor = function(self, instance, p: string, duration: number?)
		local replionFor = self:GetReplionFor(instance, p)

		if replionFor then
			return replionFor
		end

		if typeof(instance) == "Instance" and not instance:IsDescendantOf(Players) then
			if _G.__DEV__ then
				local v7, v8 = debug.info(2, "sl")
				warn((`Warning: Trying to wait for a player that is not in the game at {v7}:{v8}`))
			end

			return nil
		else
			local thread = coroutine.running()
			local v7 = v4
			local v8 = v7[p]

			if not v8 then
				v8 = {}
				v7[p] = v8
			end

			if duration then
				v6[thread] = task.delay(duration, cancelWait, v8, thread)
			end

			table.insert(v8, {
				thread = thread,
				player = instance
			})
			return coroutine.yield()
		end
	end,
	AwaitReplion = function(self, p, callback, duration)
		local replion = self:GetReplion(p)

		if replion then
			return callback(replion)
		end

		local v7 = v4
		local v8 = v7[p]

		if not v8 then
			v8 = {}
			v7[p] = v8
		end

		local thread = coroutine.create(callback)

		if duration then
			v6[thread] = task.delay(duration, cancelWait, v8, thread)
		end

		table.insert(v8, {
			thread = thread,
			async = true
		})
		return function()
			cancelWait(v8, thread)
		end
	end,
	AwaitReplionFor = function(self, instance, p, callback, duration)
		local replionFor = self:GetReplionFor(instance, p)

		if replionFor then
			return callback(replionFor)
		end

		if typeof(instance) == "Instance" and instance.Parent == nil then
			if _G.__DEV__ then
				local v7, v8 = debug.info(2, "sl")
				warn((`Warning: Trying to await for a player that is not in the game at {v7}:{v8}`))
			end

			return nil
		else
			local v7 = v4
			local v8 = v7[p]

			if not v8 then
				v8 = {}
				v7[p] = v8
			end

			local thread = coroutine.create(callback)

			if duration then
				v6[thread] = task.delay(duration, cancelWait, v8, thread)
			end

			table.insert(v8, {
				thread = thread,
				player = instance,
				async = true
			})
			return function()
				cancelWait(v8, thread)
			end
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
		local v7 = {}

		for _, v8 in replionsFor do
			table.insert(v7, v8:_serialize())
		end

		if #v7 > 0 then
			Network.sendTo(p, "Added", v7)
		end
	end

	for _, v7 in Players:GetPlayers() do
		task.spawn(onPlayerAdded, v7)
	end

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(function(player)
		local v7 = {}

		for _, v8 in v3 do
			for _, v9 in v8 do
				local replicateTo = v9.ReplicateTo

				if replicateTo == "All" then
					continue
				end

				if type(replicateTo) == "table" then
					v9:SetReplicateTo(Freeze.List.removeValue(replicateTo, player))
				elseif replicateTo == player then
					if v9.DisableAutoDestroy then
						local v10 = v9
						v9:BeforeDestroy(function()
							local index = table.find(v7, v10)

							if not index then
								return
							end

							table.remove(v7, index)

							if #v7 == 0 then
								v5[player] = nil
							end
						end)
						table.insert(v7, v9)
					else
						v9:Destroy()
					end
				end
			end
		end

		if #v7 == 0 then
			v5[player] = nil
		end

		for k, list in v4 do
			for i = #list, 1, -1 do
				local v8 = list[i]
				local thread = v8.thread

				if v8.player ~= player then
					continue
				end

				if v8.async then
					Utils.safeCancelThread(thread)
				else
					pcall(task.spawn, thread)
				end

				v6[thread] = nil
				table.remove(list, i)
			end

			if #list == 0 then
				v4[k] = nil
			end
		end
	end)
end

return Replion