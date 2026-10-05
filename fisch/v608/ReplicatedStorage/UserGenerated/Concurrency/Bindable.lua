local function ErrorHandler(p)
	warn((`{tostring(p)}\nStack Begin\n{debug.traceback(nil, 3)}Stack End`))
end

local function WCall(callback, ...)
	return xpcall(callback, ErrorHandler, ...)
end

local function FindRight(list, p)
	local count = #list
	local v = 1
	local v2 = false

	while v <= count do
		local v3 = v + (count - v) // 2
		local v4 = list[v3].Pr - p.Pr

		if v4 > 0 then
			count = v3 - 1
		elseif v4 < 0 then
			v = v3 + 1
		else
			v = v3 + 1
			v2 = true
		end
	end

	return v2 and v or -v
end

local function FindLeft(list, p)
	local count = #list
	local v = 1
	local v2 = false

	while v <= count do
		local v3 = v + (count - v) // 2
		local v4 = list[v3].Pr - p.Pr

		if v4 > 0 then
			count = v3 - 1
		elseif v4 < 0 then
			v = v3 + 1
		else
			count = v3 - 1
			v2 = true
		end
	end

	return v2 and v or -v
end

local function InsertRight(list, p)
	local v = math.abs((FindRight(list, p)))
	table.insert(list, v, p)
	return v
end

local function Remove(cs, state)
	local left = FindLeft(cs, state)

	if left > 0 then
		for i = left, #cs do
			if cs[i] ~= state then
				continue
			end

			table.remove(cs, i)
			return true
		end
	end

	return false
end

local function Connection_IsConnected(p)
	return p.Ow ~= nil
end

local function Connection_Disconnect(state)
	local ow = state.Ow

	if ow ~= nil then
		state.Ow = nil

		if not Remove(ow.Cs, state) then
			warn("BindableConnectionDisconnect")
		end

		for _, callback in ipairs(state.Wt) do
			task.spawn(callback)
		end

		table.clear(state.Wt)
	end
end

local function Connection_GetPriority(p)
	return p.Pr
end

local frozen = table.freeze({
	IsConnected = Connection_IsConnected,
	Disconnect = Connection_Disconnect,
	GetPriority = Connection_GetPriority
})
local frozen2 = table.freeze({
	__index = frozen
})

-- equivalent calls inferred from this helper; original call sites unknown
local function Connection_new(ow, cb, pr: number)
	return (setmetatable({
		Ow = ow,
		Cb = cb,
		Pr = pr,
		Wt = {}
	}, frozen2))
end

local function Connection_IsA(p)
	return type(p) == "table" and getmetatable(p) == frozen2
end

local function Connection_Assert(p)
	local v

	if type(p) == "table" then
		v = getmetatable(p) == frozen2
	else
		v = false
	end

	if not v then
		error("Connection", 2)
	end

	return p
end

local function Bindable_Connect(ow, cb, value: number?)
	local v

	if value == nil then
		v = true
	elseif type(value) == "number" then
		v = value == value
	else
		v = false
	end

	assert(v)
	local pr = value or 1e999
	local connection_new = Connection_new(ow, cb, pr) -- equivalent call inferred; original call site unknown

	if pr == 1e999 then
		table.insert(ow.Cs, connection_new)
		return connection_new
	end

	local cs = ow.Cs
	table.insert(cs, math.abs((FindRight(cs, connection_new))), connection_new)
	return connection_new
end

local function Bindable_Fire(p, ...)
	local cs = p.Cs
	local v = 1

	while v <= #cs do
		local v2 = cs[v]
		task.spawn(v2.Cb, ...)

		if cs[v] == v2 then
			v += 1
		end
	end
end

local function Bindable_FireAndWait(p, ...)
	local cs = p.Cs

	if #cs == 0 then
		return
	end

	local v = 1
	local thread = coroutine.running()

	local function executor(callback, ...)
		WCall(callback, ...)
		v -= 1

		if v == 0 then
			task.spawn(thread)
		end
	end

	local v2 = 1

	while v2 <= #cs do
		local v3 = cs[v2]
		v += 1
		task.spawn(executor, v3.Cb, ...)

		if cs[v2] == v3 then
			v2 += 1
		end
	end

	v -= 1

	if v > 0 then
		coroutine.yield()
	end
end

local function Bindable_FireSync(p, ...)
	local cs = p.Cs
	local v = 1

	while v <= #cs do
		local v2 = cs[v]
		WCall(v2.Cb, ...)

		if cs[v] == v2 then
			v += 1
		end
	end
end

local function Bindable_Invoke(p, ...)
	local cs = p.Cs

	if #cs >= 1 then
		return cs[1].Cb(...)
	end

	error("Invoke")
end

local function Bindable_Wait(ow)
	local thread = coroutine.running()
	local flag = true
	local v = nil

	local function fn(...)
		local index = table.find(v.Wt, thread)

		if index then
			table.remove(v.Wt, index)
		end

		flag = false
		Connection_Disconnect(v)
		task.spawn(thread, ...)
	end

	assert(true)
	local connection_new = Connection_new(ow, fn, 1e999) -- equivalent call inferred; original call site unknown
	table.insert(ow.Cs, connection_new)
	v = connection_new
	table.insert(v.Wt, thread)
	local v3 = table.pack(coroutine.yield())

	if flag then
		error("Disconnected")
	end

	return table.unpack(v3)
end

local function Bindable_Once(ow, callback, value: number?)
	local v = nil

	local function fn(...)
		Connection_Disconnect(v)
		return callback(...)
	end

	local v2

	if value == nil then
		v2 = true
	elseif type(value) == "number" then
		v2 = value == value
	else
		v2 = false
	end

	assert(v2)
	local pr = value or 1e999
	local connection_new = Connection_new(ow, fn, pr) -- equivalent call inferred; original call site unknown

	if pr == 1e999 then
		table.insert(ow.Cs, connection_new)
	else
		local cs = ow.Cs
		table.insert(cs, math.abs((FindRight(cs, connection_new))), connection_new)
	end

	v = connection_new
	return v
end

local function Bindable_DisconnectAll(p)
	local cs = p.Cs

	for i = #cs, 1, -1 do
		Connection_Disconnect(cs[i])
	end
end

local function Bindable_GetSize(p)
	return #p.Cs
end

local function Bindable_IsEmpty(p)
	return #p.Cs == 0
end

local frozen3 = table.freeze({
	Fire = Bindable_Fire,
	FireAndWait = Bindable_FireAndWait,
	FireSync = Bindable_FireSync,
	Invoke = Bindable_Invoke,
	Connect = Bindable_Connect,
	Wait = Bindable_Wait,
	Once = Bindable_Once,
	DisconnectAll = Bindable_DisconnectAll,
	GetSize = Bindable_GetSize,
	IsEmpty = Bindable_IsEmpty
})
local frozen4 = table.freeze({
	__index = frozen3
})
return table.freeze({
	new = function(_)
		return (table.freeze((setmetatable({
			Cs = {}
		}, frozen4))))
	end,
	IsA = function(p)
		return type(p) == "table" and getmetatable(p) == frozen4
	end,
	Assert = function(p)
		local v

		if type(p) == "table" then
			v = getmetatable(p) == frozen4
		else
			v = false
		end

		if not v then
			error("Bindable", 2)
		end

		return p
	end,
	IsAConnection = Connection_IsA,
	AssertConnection = Connection_Assert
})