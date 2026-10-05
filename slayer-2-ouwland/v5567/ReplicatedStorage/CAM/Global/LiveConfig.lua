local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local isServer = RunService:IsServer()
local ConfigService = isServer and game:GetService("ConfigService") or nil
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local LiveConfig = {}
LiveConfig.__index = LiveConfig
local deepEqual

deepEqual = function(items, items2)
	if items == items2 then
		return true
	end

	if typeof(items) ~= "table" or typeof(items2) ~= "table" then
		return false
	end

	for k, item in items do
		if not deepEqual(item, items2[k]) then
			return false
		end
	end

	for k in items2 do
		if items[k] == nil then
			return false
		end
	end

	return true
end

local cloneTable

cloneTable = function(items)
	if typeof(items) ~= "table" then
		return items
	end

	local result = {}

	for k, item in items do
		result[k] = cloneTable(item)
	end

	return result
end

local deepMerge

deepMerge = function(list, list2, items)
	if typeof(list) == "table" and typeof(list2) == "table" then
		if next(list2) == nil then
			return (cloneTable(list))
		end

		if next(list) == nil then
			return (cloneTable(list2))
		end

		if items and list2[1] ~= nil then
			local v = list[1] ~= nil
			local table2 = cloneTable(list)

			for _, v2 in list2 do
				local v3 = nil
				local v4 = ""

				if typeof(v2) == "table" then
					for _, item in items do
						if type(v2[item]) ~= "string" then
							continue
						end

						v3 = v2[item]
						v4 = item
						break
					end
				end

				if v3 == nil then
					return (cloneTable(list2))
				end

				local v5 = nil

				if v then
					for k, v7 in table2 do
						if not (typeof(v7) == "table" and v7[v4] == v3) then
							continue
						end

						v5 = k
						break
					end
				elseif typeof(table2[v3]) == "table" then
					v5 = v3
				end

				if v2.remove == true then
					if v5 ~= nil then
						if v then
							table.remove(table2, v5)
						else
							table2[v5] = nil
						end
					end
				elseif v5 == nil then
					if v then
						table2[#table2 + 1] = cloneTable(v2)
					else
						table2[v3] = cloneTable(v2)
					end
				else
					table2[v5] = deepMerge(table2[v5], v2, items)
				end
			end

			return table2
		else
			if list[1] ~= nil or list2[1] ~= nil then
				return (cloneTable(list2))
			end

			local table2 = cloneTable(list)

			for k, v in list2 do
				table2[k] = deepMerge(list[k], v, items)
			end

			return table2
		end
	else
		if list2 ~= nil then
			list = list2
		end

		return (cloneTable(list))
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function subscribe(list, p, fn)
	list[#list + 1] = p
	local flag = false
	return function()
		if flag then
			return
		end

		flag = true

		for k, v in list do
			if v ~= p then
				continue
			end

			table.remove(list, k)
			break
		end

		if fn and #list == 0 then
			fn()
		end
	end
end

local v = {}
local v2 = {}
local v3 = {}
local v4 = {}
local v5 = {}
local v6 = false
local object = setmetatable({}, {
	__mode = "k"
})

if isServer then
	SignalEvent:Connect(function(player, p: string)
		if p ~= "LiveConfigSync" or (typeof(player) ~= "Instance" or not player:IsA("Player")) then
			return
		end

		local now = os.clock()
		local v7 = object[player]

		if v7 ~= nil and now - v7 < 10 then
			return
		end

		object[player] = now

		for _, v8 in v do
			v8:_pushTo(player)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureClientConnection()
	if isServer or v6 then
		return
	end

	v6 = true
	SignalEvent:Connect(function(p: string, p2: string, p3)
		if p ~= "LiveConfigSync" then
			return
		end

		local v7 = v2[p2]
		v2[p2] = p3
		local v8 = v5[p2]

		if v8 then
			v5[p2] = nil

			for _, callback in v8 do
				task.spawn(callback, (cloneTable(p3)))
			end
		end

		local v9 = v4[p2]

		if v9 and typeof(p3) == "table" then
			local v10 = typeof(v7) ~= "table" and {} or v7

			for k, v11 in v9 do
				local v12 = v10[k]
				local v13 = p3[k]

				if deepEqual(v12, v13) then
					continue
				end

				local table2 = cloneTable(v12)
				local table3 = cloneTable(v13)

				for _, callback in v11 do
					task.spawn(callback, table2, table3)
				end
			end
		end

		local v10 = v3[p2]

		if v10 then
			local table2 = cloneTable(p3)

			for _, callback in v10 do
				task.spawn(callback, table2)
			end
		end
	end)
	SignalEvent.ToServer("LiveConfigSync")
end

local function resolveSource(p, p2: string, items)
	if not items then
		return p[p2]
	end

	for _, item in items do
		if p[item] ~= nil then
			return p[item]
		end
	end

	return nil
end

local function resolveField(p, p2: string, data)
	local from = data.from
	local transformed

	if from then
		local flag = true

		for _, v7 in from do
			if p[v7] == nil then
				continue
			end

			transformed = p[v7]
			flag = false
			break
		end

		if flag then
			transformed = nil
		end
	else
		transformed = p[p2]
	end

	if data.transform then
		transformed = data.transform(transformed)
	end

	if transformed == nil then
		return data.default
	end

	if typeof(transformed) == data.type then
		return transformed
	end

	return data.default
end

local function normalizeEntryFromSchema(p, items)
	if typeof(p) ~= "table" then
		return nil
	end

	local result = {}

	for k, item in items do
		if item.type == "array" then
			local v7 = {}
			local from = item.from
			local v8

			if from then
				local flag = true

				for _, v9 in from do
					if p[v9] == nil then
						continue
					end

					v8 = p[v9]
					flag = false
					break
				end

				if flag then
					v8 = nil
				end
			else
				v8 = p[k]
			end

			if typeof(v8) == "table" then
				for _, v9 in v8 do
					if not (typeof(v9) == "table" and (not item.entry or typeof(v9[item.entry]) == "string")) then
						continue
					end

					local values = {}

					for k2, field in item.fields do
						local from2 = field.from
						local transformed

						if from2 then
							local flag = true

							for _, v10 in from2 do
								if v9[v10] == nil then
									continue
								end

								transformed = v9[v10]
								flag = false
								break
							end

							if flag then
								transformed = nil
							end
						else
							transformed = v9[k2]
						end

						if field.transform then
							transformed = field.transform(transformed)
						end

						if transformed == nil then
							transformed = field.default
						elseif typeof(transformed) ~= field.type then
							transformed = field.default
						end

						values[k2] = transformed
					end

					v7[#v7 + 1] = values
				end
			end

			result[k] = v7
		else
			local from = item.from
			local transformed

			if from then
				local flag = true

				for _, v7 in from do
					if p[v7] == nil then
						continue
					end

					transformed = p[v7]
					flag = false
					break
				end

				if flag then
					transformed = nil
				end
			else
				transformed = p[k]
			end

			if item.transform then
				transformed = item.transform(transformed)
			end

			if transformed == nil then
				transformed = item.default
			elseif typeof(transformed) ~= item.type then
				transformed = item.default
			end

			if item.required and transformed == nil then
				return nil
			else
				result[k] = transformed
			end
		end
	end

	return result
end

local function buildSchemaCollectionNormalizer(p, p2: string, p3)
	return function(items)
		if typeof(items) ~= "table" then
			return (cloneTable(p3))
		end

		local entryFromSchemas = {}

		for _, item in items do
			local entryFromSchema = normalizeEntryFromSchema(item, p)

			if entryFromSchema and typeof(entryFromSchema[p2]) == "string" then
				entryFromSchemas[entryFromSchema[p2]] = entryFromSchema
			end
		end

		if next(entryFromSchemas) == nil then
			return (cloneTable(p3))
		end

		return entryFromSchemas
	end
end

function LiveConfig.new(data)
	local v7

	if typeof(data.key) == "string" then
		v7 = #data.key > 0
	else
		v7 = false
	end

	assert(v7, "[LiveConfig] options.key must be a non-empty string")
	assert(data.defaults ~= nil, "[LiveConfig] options.defaults is required")
	assert(data.schema ~= nil or data.normalize ~= nil, "[LiveConfig] options.schema or options.normalize is required")

	if data.entryKey and not data.schema then
		warn("[LiveConfig] options.entryKey has no effect without options.schema")
	end

	local object2 = setmetatable({}, LiveConfig)
	object2._key = data.key
	object2._clone = data.clone or cloneTable
	object2._state = object2._clone(data.defaults)
	object2._listeners = {}
	object2._keyListeners = {}
	object2._destroyed = false

	if data.schema then
		if data.entryKey then
			local schema = data.schema
			local entryKey = data.entryKey
			local defaults = data.defaults

			function object2._normalize(items)
				if typeof(items) ~= "table" then
					return (cloneTable(defaults))
				end

				local entryFromSchemas = {}

				for _, item in items do
					local entryFromSchema = normalizeEntryFromSchema(item, schema)

					if entryFromSchema and typeof(entryFromSchema[entryKey]) == "string" then
						entryFromSchemas[entryFromSchema[entryKey]] = entryFromSchema
					end
				end

				if next(entryFromSchemas) == nil then
					return (cloneTable(defaults))
				end

				return entryFromSchemas
			end
		else
			function object2._normalize(p)
				return normalizeEntryFromSchema(p, data.schema) or {}
			end
		end
	else
		object2._normalize = data.normalize
	end

	if data.merge then
		if data.entryKey then
			warn((`[LiveConfig] options.merge is not supported with entryKey collections for key "{data.key}", ignoring`))
		else
			local _normalize = object2._normalize
			local defaults

			if data.mergeBase == nil then
				defaults = data.defaults
			else
				defaults = data.mergeBase
			end

			local arrayKey = data.arrayKey

			function object2._normalize(p)
				if typeof(p) == "table" then
					p = deepMerge(defaults, p, arrayKey)
				end

				return _normalize(p)
			end
		end
	end

	if not data.replicate then
		return object2
	end

	assert(not isServer or v[data.key] == nil, (`[LiveConfig] Duplicate replicated key "{data.key}"`))
	object2._replicate = true
	object2._toPayload = data.replicate.toPayload

	if isServer then
		v[data.key] = object2
	end

	return object2
end

function LiveConfig:_buildPayload()
	local _clone = self._clone(self._state)

	if self._toPayload then
		return self._toPayload(_clone)
	end

	return _clone
end

function LiveConfig:_apply(p)
	if self._destroyed then
		return
	end

	if typeof(p) ~= "table" then
		warn((`[LiveConfig] Normalized state for key "{self._key}" is not a table, keeping current state`))
		return
	end

	if deepEqual(self._state, p) then
		return
	end

	local _state = self._state
	self._state = self._clone(p)

	for k, _keyListener in self._keyListeners do
		local v7 = _state[k]
		local v8 = self._state[k]

		if deepEqual(v7, v8) then
			continue
		end

		local _clone = self._clone(v7)
		local _clone2 = self._clone(v8)

		for _, callback in _keyListener do
			task.spawn(callback, _clone, _clone2)
		end
	end

	local _clone = self._clone(self._state)

	for _, callback in self._listeners do
		task.spawn(callback, _clone)
	end

	if self._replicate then
		local success, result = pcall(function()
			SignalEvent.ToAll("LiveConfigSync", self._key, self:_buildPayload())
		end)

		if not success then
			warn((`[LiveConfig] Could not replicate key "{self._key}": {result}`))
		end
	end
end

function LiveConfig:_pushTo(p)
	local success, result = pcall(function()
		SignalEvent.ToClient(p, "LiveConfigSync", self._key, self:_buildPayload())
	end)

	if not success then
		warn((`[LiveConfig] Could not replicate key "{self._key}": {result}`))
	end
end

function LiveConfig:_extractRaw(p2)
	local success, value = pcall(p2.GetValue, p2, self._key)

	if not success or value == nil then
		return nil
	end

	if typeof(value) ~= "string" then
		return value
	end

	local success2, result = pcall(HttpService.JSONDecode, HttpService, value)

	if success2 then
		return result
	end

	warn((`[LiveConfig] Failed to decode JSON for key "{self._key}"`))
	return nil
end

function LiveConfig:refresh()
	if self._updateConnection then
		self._updateConnection:Disconnect()
		self._updateConnection = nil
	end

	if self._valueChangedConnection then
		self._valueChangedConnection:Disconnect()
		self._valueChangedConnection = nil
	end

	local success, configAsync = pcall(ConfigService.GetConfigAsync, ConfigService)
	local v7 = success and configAsync or nil

	if not v7 then
		warn((`[LiveConfig] ConfigService unavailable for key "{self._key}", keeping current state`))
		return self:getState()
	end

	local function onConfigUpdated()
		local _extractRaw = self:_extractRaw(v7)

		if _extractRaw == nil then
			return
		end

		local success2, result = pcall(function()
			self:_apply(self._normalize(_extractRaw))
		end)

		if not success2 then
			warn((`[LiveConfig] Rejected live data for key "{self._key}", keeping current state: {result}`))
		end
	end

	local success2, result = pcall(function()
		self._updateConnection = v7.UpdateAvailable:Connect(function()
			if pcall(v7.Refresh, v7) then
				onConfigUpdated()
			end
		end)
		self._valueChangedConnection = v7:GetValueChangedSignal(self._key):Connect(onConfigUpdated)
	end)

	if not success2 then
		warn((`[LiveConfig] Not listening for live edits on key "{self._key}", a change needs a restart: {result}`))
	end

	onConfigUpdated()
	return self:getState()
end

function LiveConfig:getState()
	return self._clone(self._state)
end

function LiveConfig:set(p)
	self:_apply(p)
end

function LiveConfig:onChanged(callback)
	local _listeners = self._listeners
	_listeners[#_listeners + 1] = callback
	local flag = false
	local v7 = nil
	return function()
		if flag then
			return
		end

		flag = true

		for k, _listener in _listeners do
			if _listener ~= callback then
				continue
			end

			table.remove(_listeners, k)
			break
		end

		if v7 and #_listeners == 0 then
			v7()
		end
	end
end

function LiveConfig:onKeyChanged(p2: string, callback)
	local _keyListener = self._keyListeners[p2]

	if not _keyListener then
		_keyListener = {}
		self._keyListeners[p2] = _keyListener
	end

	local function fn()
		self._keyListeners[p2] = nil
	end

	return subscribe(_keyListener, callback, fn)
end

function LiveConfig:destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true

	if self._updateConnection then
		self._updateConnection:Disconnect()
		self._updateConnection = nil
	end

	if self._valueChangedConnection then
		self._valueChangedConnection:Disconnect()
		self._valueChangedConnection = nil
	end

	table.clear(self._listeners)
	table.clear(self._keyListeners)

	if self._replicate and isServer then
		v[self._key] = nil
	end
end

function LiveConfig.get(p: string)
	if isServer then
		local v7 = v[p]

		if v7 then
			return (v7:getState())
		end

		return nil
	else
		ensureClientConnection() -- equivalent call inferred; original call site unknown
		local v7 = v2[p]

		if v7 == nil then
			return nil
		end

		return (cloneTable(v7))
	end
end

function LiveConfig.waitFor(p: string, value: number?)
	if isServer then
		local v7 = v[p]

		if v7 then
			return (v7:getState())
		end

		return nil
	else
		ensureClientConnection() -- equivalent call inferred; original call site unknown

		if v2[p] ~= nil then
			return (cloneTable(v2[p]))
		end

		local threads = v5[p]

		if not threads then
			threads = {}
			v5[p] = threads
		end

		local thread = coroutine.running()
		threads[#threads + 1] = thread
		task.delay(value or 10, function()
			local v7 = v5[p]

			if not v7 then
				return
			end

			for k, v8 in v7 do
				if v8 ~= thread then
					continue
				end

				table.remove(v7, k)

				if #v7 == 0 then
					v5[p] = nil
				end

				task.spawn(thread, nil)
				break
			end
		end)
		return coroutine.yield()
	end
end

function LiveConfig.pushAllTo(p)
	if not isServer then
		return
	end

	for _, v7 in v do
		v7:_pushTo(p)
	end
end

function LiveConfig.listen(p: string, callback)
	if isServer then
		local v7 = v[p]

		if v7 then
			return (v7:onChanged(callback))
		end

		return function() end
	else
		ensureClientConnection() -- equivalent call inferred; original call site unknown
		local v7 = v3[p]

		if not v7 then
			v7 = {}
			v3[p] = v7
		end

		v7[#v7 + 1] = callback
		local flag = false
		local v8 = nil
		return function()
			if flag then
				return
			end

			flag = true

			for k, v9 in v7 do
				if v9 ~= callback then
					continue
				end

				table.remove(v7, k)
				break
			end

			if v8 and #v7 == 0 then
				v8()
			end
		end
	end
end

function LiveConfig.listenKey(p: string, p2: string, callback)
	if isServer then
		local v7 = v[p]

		if v7 then
			return (v7:onKeyChanged(p2, callback))
		end

		return function() end
	else
		ensureClientConnection() -- equivalent call inferred; original call site unknown
		local v7 = v4[p]

		if not v7 then
			v7 = {}
			v4[p] = v7
		end

		local v8 = v7[p2]

		if not v8 then
			v8 = {}
			v7[p2] = v8
		end

		local function fn()
			v7[p2] = nil
		end

		return subscribe(v8, callback, fn)
	end
end

return LiveConfig