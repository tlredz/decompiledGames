if _G.__ReplicatorClientReference then
	error("replicator has already been required on the client in another module.")
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v = utf8.char(0)
local v2 = utf8.char(1)
local v3 = utf8.char(2)
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local ReplicatorSignal = require(script.ReplicatorSignal)
local Buff = require(script.Buff)
local v9 = {}
local v10 = {}
local ReplicatorClient = {}

local function ensureDescendantPath(_signal_descendants, list)
	for i = 1, #list do
		local v11 = list[i]
		local v12 = _signal_descendants[v11]

		if not v12 then
			v12 = {}
			_signal_descendants[v11] = v12
		end

		_signal_descendants = v12
	end

	return _signal_descendants
end

local deepCopy

deepCopy = function(p)
	local clone = table.clone(p)

	for k, v11 in clone do
		if type(v11) == "table" then
			clone[k] = deepCopy(v11)
		end
	end

	return clone
end

local function makeDotCallsError(items)
	for k, item in items do
		if type(item) ~= "function" then
			continue
		end

		local v11 = k
		local v12 = item

		items[k] = function(...)
			if select(1, ...) == items then
				return v12(...)
			end

			error((`called {v11} with .{v11}() instead of :{v11}()`))
		end
	end
end

local fireInitialSignals

fireInitialSignals = function(items, object)
	local item = items[v6]

	if item then
		item.signal:Fire(object:TryIndex(item.path))
	end

	local item2 = items[v7]

	if item2 then
		item2.signal:Fire(object:TryIndex(item2.path), nil)
	end

	local item3 = items[v8]

	if item3 then
		local v11 = object:TryIndex(item3.path)

		if v11 then
			for k, v12 in v11 do
				item3.signal:Fire(k, v12)
			end
		end
	end

	for k, item4 in items do
		if type(k) == "string" then
			fireInitialSignals(item4, object)
		end
	end
end

local disconnectAllSignals

disconnectAllSignals = function(items)
	local item = items[v6]

	if item then
		item.signal:DisconnectAll()
	end

	local item2 = items[v7]

	if item2 then
		item2.signal:DisconnectAll()
	end

	for k, item3 in items do
		if type(k) == "string" then
			disconnectAllSignals(item3)
		end
	end
end

local function handlePacket(list)
	local v11 = list[1]
	local v12 = list[2]

	if v11 == v then
		local v13 = list[3]
		local v14 = list[4]

		for k, v15 in v9 do
			if v15 == v13 and k ~= v12 then
				error((`client received 2 Replicators with the same Id "{v13}"`))
			end
		end

		v9[v12] = v13
		ReplicatorClient.get(v13)
		local v15 = v10[v13]
		v15.Data = deepCopy(v14)
		fireInitialSignals(v15._signal_descendants, v15)
		v15._listen_raw_signal:Fire(v15.Data, v15.Data)
	elseif v11 == v2 then
		local v13 = v9[v12]

		if not v13 then
			return
		end

		local v14 = v10[v13]

		if not v14 then
			return
		end

		local v15 = {}
		local fireNilDescendants

		fireNilDescendants = function(items, items2)
			local item = items2[v8]

			if item and type(items) == "table" then
				for k in items do
					table.insert(v15, { item.signal, k, v4 })
				end
			end

			for k, item2 in items2 do
				if type(k) ~= "string" then
					continue
				end

				local v16

				if type(items) == "table" then
					v16 = items[k] or nil
				end

				local v17 = item2[v6]

				if v17 then
					table.insert(v15, { v17.signal, v4, nil })
				end

				local v18 = item2[v7]

				if v18 then
					local signal = v18.signal

					if type(v16) == "table" then
						v16 = deepCopy(v16)
					end

					table.insert(v15, { signal, v4, v16 })
				end

				fireNilDescendants(v16, item2)
			end
		end

		local v16 = list[3]
		local apply

		apply = function(list2, p, p2)
			if type(p) == "table" and p.__none == "__none" then
				if p2 then
					fireNilDescendants(list2, p2)
				end

				return nil
			else
				if type(list2) ~= "table" or type(p) ~= "table" then
					return p
				end

				local v17 = list2[1] ~= nil
				local v18 = p2 and p2[v8]

				for k, v19 in next, p, nil do
					if v17 and type(k) == "string" then
						k = tonumber(k) or k
					end

					local v20 = p2 and p2[tostring(k)]
					local v21 = apply(list2[k] or {}, v19, v20)

					if v18 and list2[k] == nil ~= (v21 == nil) then
						local signal = v18.signal
						local v24

						if v21 == nil then
							v24 = v4
						else
							v24 = v21
						end

						table.insert(v15, { signal, k, v24 })
					end

					if v20 then
						local v22 = v20[v6]

						if v22 then
							local signal = v22.signal
							local v25

							if v21 == nil then
								v25 = v4
							else
								v25 = v21
							end

							table.insert(v15, { signal, v25, p })
						end

						local v23 = v20[v7]

						if v23 then
							local v24 = list2[k]
							local signal = v23.signal
							local v27

							if v21 == nil then
								v27 = v4
							else
								v27 = v21
							end

							if type(v24) == "table" then
								v24 = deepCopy(v24)
							end

							table.insert(v15, { signal, v27, v24 })
						end
					end

					list2[k] = v21
				end

				return list2
			end
		end

		local v17 = apply(v14.Data, v16, v14._signal_descendants)

		if v14.Data ~= v17 then
			v14.Data = v17
		end

		for _, list2 in v15 do
			local v18 = list2[1]
			local v19, v20 = unpack(list2, 2, 3)

			if v19 == v4 then
				v19 = nil
			end

			if v20 == v4 then
				v20 = nil
			end

			v18:Fire(v19, v20)
		end

		v14._listen_raw_signal:Fire(v14.Data, v16)
	elseif v11 == v3 then
		local v13 = v9[v12]
		local v14 = v10[v13]

		if not v14 then
			return
		end

		if v14._destroyed == true then
			error("received 2 DESTROY_CMD for the same replicator")
		end

		v14.Destroying:Fire()
		disconnectAllSignals(v14._signal_descendants)
		table.clear(v14._signal_descendants)
		v14._destroyed = true
		v10[v13] = nil
	end
end

function ReplicatorClient.get(id: string)
	local v11 = v10[id]

	if v11 then
		return v11
	end

	local v12 = {
		Id = id,
		Data = nil,
		Ready = false,
		Destroying = ReplicatorSignal.new(),
		_indices_signals = {},
		_listen_raw_signal = ReplicatorSignal.new(),
		_destroyed = false,
		_signal_descendants = {}
	}

	local function registerListener(path, p2, onSignal)
		if #path == 0 and path ~= v5 then
			warn("path:", path)
			error("invalid path to register listener.")
		end

		local descendantPath = ensureDescendantPath(v12._signal_descendants, path)
		local v13 = descendantPath[p2]

		if not v13 then
			v13 = {
				signal = ReplicatorSignal.new(),
				path = path,
				connected = 0
			}
			descendantPath[p2] = v13
		end

		local signalConnection = v13.signal:Connect(onSignal)
		v13.connected += 1
		return function()
			signalConnection:Disconnect()
			v13.connected -= 1

			if v13.connected == 0 then
				descendantPath[p2] = nil
			end
		end
	end

	function v12.Listen(_, path, p2)
		if type(path[1]) ~= "table" then
			return (registerListener(path, v6, p2))
		end

		local v13 = {}

		for _, v14 in path do
			table.insert(v13, (registerListener(v14, v6, p2)))
		end

		return function()
			for _, v14 in v13 do
				v14()
			end

			table.clear(v13)
		end
	end

	function v12.ListenRaw(_, on_listen_raw_signal)
		return v12._listen_raw_signal:Connect(on_listen_raw_signal)
	end

	function v12.Observe(_, path, callback)
		task.spawn(callback, v12:TryIndex(path), nil)
		return (registerListener(path, v7, callback))
	end

	function v12.ObserveKeys(_, path, callback)
		local v13 = v12:TryIndex(path)

		if v13 then
			for k, v14 in v13 do
				callback(k, v14)
			end
		end

		return (registerListener(path, v8, callback))
	end

	function v12.ListenKeys(_, path, p3)
		return (registerListener(path, v8, p3))
	end

	function v12.Index(_, list)
		local data = v12.Data

		if type(data) ~= "table" then
			error("Replicator:Index() failed Data is not a table.")
		end

		local v13 = #list

		for k, v14 in list do
			data = data[v14]

			if k < v13 and type(data) ~= "table" then
				error((`Replicator:Index() failed {table.concat(list, "/", 1, k)} is not a table.`))
			end
		end

		return data
	end

	function v12:TryIndex(list)
		local data = v12.Data

		if type(data) ~= "table" then
			return nil
		end

		local v13 = #list

		for k, v14 in list do
			data = data[v14]

			if k < v13 and type(data) ~= "table" then
				return nil
			end
		end

		return data
	end

	function v12.Path(_, value)
		local v13 = type(value) == "string" and { value } or value
		return function(value2)
			local clone = table.clone(v13)

			if value2 == nil then
				return clone
			end

			if type(value2) == "string" then
				table.insert(clone, value2)
				return clone
			end

			table.move(value2, 1, #value2, #clone + 1, clone)
			return clone
		end
	end

	function v12.WaitForLoaded(_)
		if not v12.Data then
			v12._listen_raw_signal:Wait()
		end
	end

	v10[id] = v12
	makeDotCallsError(v12)
	return v12
end

local flag = false

function ReplicatorClient.init()
	if flag then
		return
	end

	flag = true
	local thread = coroutine.running()
	local v11 = false
	local remoteEvent = ReplicatedStorage:WaitForChild("__ReplicatorInternal", 1e999):WaitForChild("RemoteEvent", 1e999)
	remoteEvent.OnClientEvent:Connect(function(p, p2)
		local decoded = Buff.decode(p, p2)

		for k, v12 in decoded do
			debug.profilebegin((`replicator::handlepacket::{k}`))
			handlePacket(v12)
			debug.profileend()
		end

		if v11 and coroutine.status(thread) == "suspended" then
			task.spawn(thread)
			v11 = false
		end
	end)
	remoteEvent:FireServer()
	v11 = true
	coroutine.yield()
end

_G.__ReplicatorClientReference = ReplicatorClient
return ReplicatorClient