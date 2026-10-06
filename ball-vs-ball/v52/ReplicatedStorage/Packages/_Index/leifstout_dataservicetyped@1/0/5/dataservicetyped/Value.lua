local class = {}
local Value = {
	shouldRecordPath = false
}

local function adoptChildren(callback)
	local v = callback()

	if type(v) ~= "table" then
		return
	end

	local v2 = rawget(callback, "___C")

	if not v2 then
		v2 = {}
		rawset(callback, "___C", v2)
	end

	for k, _ in v do
		if not v2[k] then
			v2[k] = Value.new(v, k, callback)
		end
	end

	for k, v3 in v2 do
		rawset(v3, "___X", v)

		if v[k] == nil and rawget(v3, "_ChangedCbs") == nil then
			v2[k] = nil
		end
	end
end

local sendChangedSignalToChildren

sendChangedSignalToChildren = function(callback, flag: boolean?)
	if not flag then
		local v = rawget(callback, "_ChangedCbs")

		if v then
			local v2 = callback()

			for _, callback2 in v do
				task.spawn(callback2, v2)
			end
		end
	end

	local v = rawget(callback, "___C")

	if not v then
		return
	end

	for _, v2 in v do
		sendChangedSignalToChildren(v2)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function createCallbackFn(p: string)
	return function(p2)
		return function(callback)
			local v = rawget(p2, p)

			if not v then
				v = {}
				rawset(p2, p, v)
			end

			table.insert(v, callback)
			return function()
				local v2 = rawget(p2, p)

				if not v2 then
					return
				end

				local index = table.find(v2, callback)

				if not index then
					return
				end

				table.remove(v2, index)

				if #v2 == 0 then
					rawset(p2, p, nil)
				end
			end
		end
	end
end

local v = "_ChangedCbs"
local v2 = "_OnInsertCbs"
local v3 = "_OnRemoveCbs"
local v4 = "_OnKeyAddedCbs"
local callbackFn = createCallbackFn("_OnKeyRemovedCbs") -- equivalent call inferred; original call site unknown

local function fireChangeAndReplicate(callback, p, p2: string?, flag: boolean?, ...)
	local v6 = flag ~= false
	local v7 = Value.shouldRecordPath and v6 and {} or nil
	local v8 = nil
	local v9 = nil
	local v10 = rawget(callback, "___P")

	if v10 ~= nil and p2 == "set" then
		local v11 = rawget(callback, "___K")
		local v12 = callback()

		if p == nil and v12 ~= nil then
			local v13 = rawget(v10, "_OnKeyAddedCbs")

			if v13 then
				for _, callback2 in v13 do
					task.spawn(callback2, v11, v12)
				end
			end
		elseif p ~= nil and v12 == nil then
			local v13 = rawget(v10, "_OnKeyRemovedCbs")

			if v13 then
				for _, callback2 in v13 do
					task.spawn(callback2, v11, p)
				end
			end
		end
	end

	while true do
		local v11 = rawget(callback, "___K")

		if v7 and v11 ~= nil then
			table.insert(v7, v11)
		end

		v9 = v9 or rawget(callback, "___R")
		local v12 = rawget(callback, "_ChangedCbs")

		if v12 then
			local v13 = callback()

			for _, callback2 in v12 do
				task.spawn(callback2, v13, p, v8)
			end
		end

		callback = rawget(callback, "___P")

		if callback == nil then
			if v6 and v9 then
				v9(p2, v7, ...)
			end

			break
		else
			v8 = v11
		end
	end
end

local function ArrayInsert(callback)
	return function(p, p2: number?, flag: boolean?)
		local v6 = callback()

		if p2 then
			table.insert(v6, p2, p)
		else
			table.insert(v6, p)
		end

		adoptChildren(callback)
		fireChangeAndReplicate(callback, nil, "insert", flag, p, p2)
		local v7 = rawget(callback, "_OnInsertCbs")

		if v7 then
			local v8 = p2 or table.find(v6, p)

			for _, callback2 in v7 do
				task.spawn(callback2, p, v8)
			end
		end
	end
end

local function ArrayRemove(callback)
	return function(p: number?, flag: boolean?)
		local v6 = callback()
		local v7 = table.remove(v6, p)
		adoptChildren(callback)
		fireChangeAndReplicate(callback, nil, "remove", flag, p)
		local v8 = rawget(callback, "_OnRemoveCbs")

		if v8 then
			local v9 = p or #v6 + 1

			for _, callback2 in v8 do
				task.spawn(callback2, v7, v9)
			end
		end

		return v7
	end
end

local v6 = {
	Changed = function(p)
		return function(callback)
			local v7 = rawget(p, v)

			if not v7 then
				v7 = {}
				rawset(p, v, v7)
			end

			table.insert(v7, callback)
			return function()
				local v8 = rawget(p, v)

				if not v8 then
					return
				end

				local index = table.find(v8, callback)

				if not index then
					return
				end

				table.remove(v8, index)

				if #v8 == 0 then
					rawset(p, v, nil)
				end
			end
		end
	end,
	Insert = ArrayInsert,
	Remove = ArrayRemove,
	OnInsert = function(p)
		return function(callback)
			local v7 = rawget(p, v2)

			if not v7 then
				v7 = {}
				rawset(p, v2, v7)
			end

			table.insert(v7, callback)
			return function()
				local v8 = rawget(p, v2)

				if not v8 then
					return
				end

				local index = table.find(v8, callback)

				if not index then
					return
				end

				table.remove(v8, index)

				if #v8 == 0 then
					rawset(p, v2, nil)
				end
			end
		end
	end,
	OnRemove = function(p)
		return function(callback)
			local v7 = rawget(p, v3)

			if not v7 then
				v7 = {}
				rawset(p, v3, v7)
			end

			table.insert(v7, callback)
			return function()
				local v8 = rawget(p, v3)

				if not v8 then
					return
				end

				local index = table.find(v8, callback)

				if not index then
					return
				end

				table.remove(v8, index)

				if #v8 == 0 then
					rawset(p, v3, nil)
				end
			end
		end
	end,
	OnKeyAdded = function(p)
		return function(callback)
			local v7 = rawget(p, v4)

			if not v7 then
				v7 = {}
				rawset(p, v4, v7)
			end

			table.insert(v7, callback)
			return function()
				local v8 = rawget(p, v4)

				if not v8 then
					return
				end

				local index = table.find(v8, callback)

				if not index then
					return
				end

				table.remove(v8, index)

				if #v8 == 0 then
					rawset(p, v4, nil)
				end
			end
		end
	end,
	OnKeyRemoved = callbackFn
}

function class.__index(callback, p: string)
	local v7 = v6[p]

	if v7 then
		return v7(callback)
	end

	local v8 = callback()
	assert(
		type(v8) == "table",
		(`attempted to index '{rawget(callback, "___K")}'({typeof(v8)}) with '{p}'({typeof(p)})`)
	)
	local v9 = rawget(callback, "___C")

	if v9 and v9[p] ~= nil then
		return v9[p]
	end

	local v10 = Value.new(v8, p, callback)

	if not v9 then
		v9 = {}
		rawset(callback, "___C", v9)
	end

	v9[p] = v10
	return v10
end

function class.__call(p, ...)
	local v7 = rawget(p, "___X")
	local v8 = rawget(p, "___K")
	local selected

	if v8 == nil then
		selected = v7
	else
		selected = v7[v8]
	end

	if select("#", ...) == 0 then
		return selected
	end

	local v10, v11 = ...

	if type(v10) == "function" then
		v7[v8] = v10(selected)
	else
		v7[v8] = v10
	end

	local v12 = v7[v8]
	adoptChildren(p)
	local v13 = rawget(p, "___C")

	if v13 then
		for _, v14 in v13 do
			sendChangedSignalToChildren(v14)
		end
	end

	fireChangeAndReplicate(p, selected, "set", v11, v12)
	return v12
end

function Value.new(p, p2: string?, p3, callback)
	local self = setmetatable({
		___K = p2,
		___P = p3,
		___X = p,
		___R = callback,
		___C = nil
	}, class)
	adoptChildren(self)
	return self
end

return Value