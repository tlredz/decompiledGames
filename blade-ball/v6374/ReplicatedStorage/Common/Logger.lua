local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local RunService = game:GetService("RunService")
local LogService = game:GetService("LogService")
local v = require3("@game/ReplicatedStorage/ServerInfo")
local v2 = require3("@game/ReplicatedStorage/Common/Utils/Utilities/FFlag")
local v3 = RunService:IsStudio() or v.isDevPlaceGame() or v.isTestGame() or v2.GetFFlag("ServerDebugMode")
local v4 = {}
local v5 = {}
local v6 = {
	__index = v4
}
local v7 = {
	__index = v5
}
local v8 = {}
local v9 = {}
local object = setmetatable({}, {
	__mode = "k"
})
local object2 = setmetatable({}, {
	__mode = "k"
})
local object3 = setmetatable({}, {
	__mode = "k"
})
local v10 = {}
local data = {}
local testGame = v.isTestGame()

-- equivalent calls inferred from this helper; original call sites unknown
local function getThread()
	return coroutine.running()
end

local function getContext(flag: boolean)
	local thread = getThread() -- equivalent call inferred; original call site unknown
	local v11 = object3[thread]

	if not v11 and flag then
		v11 = {
			groups = {}
		}
		object3[thread] = v11
	end

	return v11
end

-- equivalent calls inferred from this helper; original call sites unknown
local function removeEmptyContext()
	local thread = getThread() -- equivalent call inferred; original call site unknown
	local v11 = object3[thread]

	if v11 and #v11.groups == 0 and v11.buffer == nil then
		object3[thread] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyConfig(p, data2)
	if data2.enabled ~= nil then
		p.enabled = data2.enabled
	end

	if data2.levels then
		for k, level in data2.levels do
			p.levels[k] = level
		end
	end

	if data2.filter ~= nil then
		p.filter = data2.filter
	end
end

local function findActor(list)
	local player = list[1]

	if typeof(player) == "Instance" and player:IsA("Player") then
		return player
	end

	return nil
end

local function formatEvent(p)
	local v11 = table.create(p.arguments.n)

	for i = 1, p.arguments.n do
		v11[i] = tostring(p.arguments[i])
	end

	if not p.fields or next(p.fields) == nil then
		return table.concat(v11, " ")
	end

	local v12 = {}

	for k, field in p.fields do
		table.insert(v12, (`{k}={tostring(field)}`))
	end

	table.sort(v12)
	table.insert(v11, "{" .. table.concat(v12, " ") .. "}")
	return table.concat(v11, " ")
end

local function isEnabled(p)
	local enabled = p.enabled == true

	if p.enabled == false then
		return false
	end

	local namespace = p.namespace

	while namespace do
		if namespace.enabled == false then
			return false
		end

		enabled = enabled or namespace.enabled == true
		namespace = namespace.parent
	end

	return enabled or v3
end

local function resolveLevel(p, level: string)
	if p.levels[level] ~= nil then
		return p.levels[level]
	end

	local namespace = p.namespace

	while namespace do
		if namespace.levels[level] ~= nil then
			return namespace.levels[level]
		end

		namespace = namespace.parent
	end

	return nil
end

local function resolveFilter(p)
	if p.filter then
		return p.filter
	end

	local namespace = p.namespace

	while namespace do
		if namespace.filter then
			return namespace.filter
		else
			namespace = namespace.parent
		end
	end

	return nil
end

local function passesConfig(p, p2, flag: boolean)
	if flag then
		return true
	end

	if not (isEnabled(p) and resolveLevel(p, p2.level) ~= false) then
		return false
	end

	local filter

	if p.filter then
		filter = p.filter
	else
		local namespace = p.namespace

		while true do
			if not namespace then
				filter = nil
				break
			end

			if namespace.filter then
				filter = namespace.filter
				break
			else
				namespace = namespace.parent
			end
		end
	end

	return filter == nil or filter(p2)
end

local function deliver(data2, value: string?, flag: boolean?)
	if testGame then
		table.insert(data, data2)

		if #data > 1000 then
			table.remove(data, 1)
		end
	end

	for _, callback in v10 do
		task.spawn(callback, data2)
	end

	local v11 = (value or "") .. formatEvent(data2)

	if data2.level == "warn" or data2.level == "error" or data2.level == "assert" then
		if flag ~= false then
			v11 = `[{data2.scope}] {v11}`
		end

		warn(v11)
	else
		if flag ~= false then
			v11 = `[{data2.scope}] {v11}`
		end

		print(v11)
	end

	if data2.trace then
		print(data2.trace)
	end
end

local flushTree

flushTree = function(data2, p: string, flag: boolean)
	if data2.kind == "event" then
		deliver(data2.event, p .. (flag and "└─ " or "├─ "), false)
		return
	end

	local v11 = object2[data2.scope]
	deliver({
		time = os.time(),
		clock = os.clock(),
		level = data2.level,
		namespace = v11.namespace.path,
		scope = v11.path,
		arguments = table.pack(data2.title)
	}, p .. (flag and "└─ " or "├─ "), false)
	local v13 = p .. (flag and "   " or "│  ")

	for k, v14 in data2.children do
		flushTree(v14, v13, k == #data2.children)
	end
end

local function flushGroup(group)
	local v11 = object2[group.scope]
	deliver({
		time = os.time(),
		clock = os.clock(),
		level = group.level,
		namespace = v11.namespace.path,
		scope = v11.path,
		arguments = table.pack(group.title)
	})

	for k, v13 in group.children do
		flushTree(v13, "", k == #group.children)
	end
end

local function emit(p, level: string, fields, arguments, flag: boolean, trace: string?)
	local v11 = object2[p]
	local event = {
		time = os.time(),
		clock = os.clock(),
		level = level,
		namespace = v11.namespace.path,
		scope = v11.path,
		actor = 0,
		arguments = 0,
		fields = 0,
		trace = 0
	}
	local player = arguments[1]

	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		player = nil
	end

	event.actor = player
	event.arguments = arguments
	event.fields = fields
	event.trace = trace
	local v13

	if flag then
		v13 = true
	elseif isEnabled(v11) and resolveLevel(v11, event.level) ~= false then
		local filter

		if v11.filter then
			filter = v11.filter
		else
			local namespace = v11.namespace

			while true do
				if not namespace then
					filter = nil
					break
				end

				if namespace.filter then
					filter = namespace.filter
					break
				else
					namespace = namespace.parent
				end
			end
		end

		if filter == nil then
			v13 = true
		else
			v13 = filter(event)
		end
	else
		v13 = false
	end

	if not v13 then
		return
	end

	local context = getContext(false)

	if context and #context.groups > 0 then
		table.insert(context.groups[#context.groups].children, {
			kind = "event",
			event = event
		})
	elseif context and context.buffer then
		table.insert(context.buffer.events, event)
	else
		deliver(event)
	end
end

function v4.path(p)
	return object[p].path
end

function v4:configure(data2)
	applyConfig(object[self], data2) -- equivalent call inferred; original call site unknown
end

function v4.isEnabled(p)
	local namespace = object[p]
	return (isEnabled({
		label = namespace.name,
		path = namespace.path,
		namespace = namespace,
		levels = {},
		seen = {}
	}))
end

function v4.setEnabled(p, flag: boolean?)
	object[p].enabled = flag and true or false
end

function v4.setLevelEnabled(p, p2: string, flag: boolean?)
	object[p].levels[p2] = flag and true or false
end

function v4.setFilter(p, filter)
	object[p].filter = filter
end

function v4.namespace(p, name: string, p3)
	local parent = object[p]
	local path = parent.path .. "/" .. name
	local v13 = v8[path]

	if v13 then
		if p3 then
			v13:configure(p3)
		end

		return v13
	else
		local self = setmetatable({}, v6)
		object[self] = {
			name = name,
			path = path,
			parent = parent,
			levels = {}
		}
		v8[path] = self

		if p3 then
			self:configure(p3)
		end

		return self
	end
end

function v5.path(p)
	return object2[p].path
end

function v5:configure(data2)
	applyConfig(object2[self], data2) -- equivalent call inferred; original call site unknown
end

function v5.isEnabled(p)
	return (isEnabled(object2[p]))
end

function v5.setEnabled(p, flag: boolean?)
	object2[p].enabled = flag and true or false
end

function v5.setLevelEnabled(p, p2: string, flag: boolean?)
	object2[p].levels[p2] = flag and true or false
end

function v5.setFilter(p, filter)
	object2[p].filter = filter
end

function v5.emit(p, level: string, fields, ...)
	emit(p, level, fields, table.pack(...), false, nil)
end

function v5.debug(p, ...)
	emit(p, "debug", nil, table.pack(...), false, nil)
end

function v5:info(...)
	emit(self, "info", nil, table.pack(...), false, nil)
end

function v5:print(...)
	self:info(...)
end

function v5.warn(p, ...)
	emit(p, "warn", nil, table.pack(...), false, nil)
end

function v5.trace(p, ...)
	emit(p, "trace", nil, table.pack(...), false, debug.traceback("", 2))
end

function v5.error(p, ...)
	local arguments = table.pack(...)
	emit(p, "error", nil, arguments, true, nil)
	error(`[{object2[p].path}] {formatEvent({
		time = 0,
		clock = 0,
		level = "error",
		namespace = "",
		scope = "",
		arguments = arguments
	})}`, 2)
end

function v5.assert(p, p2, ...)
	if p2 then
		return
	end

	local arguments = table.pack(...)
	emit(p, "assert", nil, arguments, true, nil)
	error(`[{object2[p].path}] {formatEvent({
		time = 0,
		clock = 0,
		level = "assert",
		namespace = "",
		scope = "",
		arguments = arguments
	})}`, 2)
end

function v5.once(p, p2, level: string, ...)
	local v11 = object2[p]

	if v11.seen[p2] then
		return
	end

	v11.seen[p2] = true
	emit(p, level, nil, table.pack(...), false, nil)
end

function v5.profile(p, p2: string)
	debug.profilebegin((`[{object2[p].path}] {p2}`))
	local v11 = false
	return {
		finish = function()
			if not v11 then
				v11 = true
				debug.profileend()
			end
		end
	}
end

local function createGroupControl(self)
	return {
		begin = function(_, title: string, value: string?)
			local context = getContext(true)
			local v11 = {
				kind = "group",
				title = title,
				level = value or "info",
				scope = self,
				children = {}
			}

			if #context.groups > 0 then
				table.insert(context.groups[#context.groups].children, v11)
			end

			table.insert(context.groups, v11)
		end,
		finish = function(_)
			local context = getContext(false)

			if not context or #context.groups == 0 then
				error(`[{object2[self].path}] no group is open in this coroutine`, 2)
			end

			local group = context.groups[#context.groups]

			if group.scope ~= self then
				error(`[{object2[self].path}] groups must finish in LIFO order`, 2)
			end

			table.remove(context.groups)

			if #context.groups == 0 and #group.children > 0 then
				flushGroup(group)
			end

			removeEmptyContext() -- equivalent call inferred; original call site unknown
		end,
		isOpen = function(_)
			local context = getContext(false)
			return context ~= nil and #context.groups > 0
		end
	}
end

local function createBufferControl(self)
	return {
		begin = function(_)
			local context = getContext(true)

			if context.buffer then
				error(`[{object2[self].path}] a buffer is already open in this coroutine`, 2)
			end

			context.buffer = {
				scope = self,
				events = {}
			}
		end,
		flush = function(_)
			local context = getContext(false)
			local buffer

			if context then
				buffer = context.buffer
			end

			if not buffer or buffer.scope ~= self then
				error(`[{object2[self].path}] no buffer is open in this coroutine`, 2)
			end

			context.buffer = nil

			for _, event in buffer.events do
				deliver(event)
			end

			removeEmptyContext() -- equivalent call inferred; original call site unknown
		end,
		discard = function(_)
			local context = getContext(false)

			if not context or not context.buffer or context.buffer.scope ~= self then
				error(`[{object2[self].path}] no buffer is open in this coroutine`, 2)
			end

			context.buffer = nil
			removeEmptyContext() -- equivalent call inferred; original call site unknown
		end,
		isOpen = function(_)
			local context = getContext(false)
			return context ~= nil and context.buffer ~= nil
		end
	}
end

function v4.scope(p, label: string, p3)
	local namespace = object[p]
	local path = namespace.path .. "/" .. label
	local v13 = v9[path]

	if v13 then
		if p3 then
			v13:configure(p3)
		end

		return v13
	else
		local self = setmetatable({}, v7)
		object2[self] = {
			label = label,
			path = path,
			namespace = namespace,
			levels = {},
			seen = {}
		}
		self.group = createGroupControl(self)
		self.buffer = createBufferControl(self)
		v9[path] = self

		if p3 then
			self:configure(p3)
		end

		return self
	end
end

local Logger = {}

function Logger.namespace(p: string, p2)
	local v11 = v8[p]

	if v11 then
		if p2 then
			v11:configure(p2)
		end

		return v11
	else
		local self = setmetatable({}, v6)
		object[self] = {
			name = p,
			path = p,
			levels = {}
		}
		v8[p] = self

		if p2 then
			self:configure(p2)
		end

		return self
	end
end

function Logger.getNamespace(p: string)
	return v8[p]
end

function Logger.getScope(p: string)
	return v9[p]
end

function Logger.addSink(callback)
	table.insert(v10, callback)
	return function()
		local index = table.find(v10, callback)

		if index then
			table.remove(v10, index)
		end
	end
end

function Logger.setHistoryEnabled(flag: boolean)
	testGame = flag
end

function Logger.clearHistory()
	table.clear(data)
end

function Logger.getHistory(callback)
	local result = {}

	for _, v11 in data do
		if not callback or callback(v11) then
			table.insert(result, v11)
		end
	end

	return result
end

function Logger.clearOutput()
	LogService:ClearOutput()
end

return Logger