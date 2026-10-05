local Signal = require(script.Parent.Parent.Parent.Signal)
require(script.Parent.Types)
local v = {
	n = 0
}

local function get(p, p2: string)
	if p and type(p) == "table" then
		return p[p2]
	end

	return nil
end

local function getPathTable(value)
	if type(value) == "table" then
		return value
	end

	if type(value) == "string" then
		return string.split(value, ".")
	end

	return { value }
end

local function destroySignal(state, p: string)
	if not state.events then
		return
	end

	local event = state.events[p]

	if not event then
		return
	end

	event:Destroy()
	state.events[p] = nil

	if next(state.events) then
		return
	end

	state.events = nil

	while state.parent do
		local parent = state.parent

		if state.events or state.children and next(state.children) then
			break
		end

		assert(parent.children, "Parent node has no children!")
		parent.children[state.id] = nil
		state = parent
	end
end

function getSignal(state, p: string, value, flag: boolean?)
	local v2 = flag == nil or flag

	if not state then
		error("You are trying to use a destroyed Replion!")
	end

	local v3, v4

	if type(value) ~= "table" then
		if type(value) == "string" then
			value, v3, v4 = string.split(value, ".")
		else
			value = { value }
		end
	end

	for _, item in value, v3, v4 do
		if not (state.children and state.children[item]) then
			if not v2 then
				return nil
			end

			local children = state.children or {}
			children[item] = {
				parent = state,
				id = item
			}
			state.children = children
		end

		if state.children then
			state = state.children[item]
		else
			state = nil
		end

		if not state then
			return nil
		end
	end

	local events = state.events

	if v2 and not (events and events[p]) then
		local v5 = Signal.new()
		local connect2 = v5.Connect

		function v5:Connect(p3)
			local v6 = connect2(self, p3)
			local disconnect = v6.Disconnect

			function v6.Disconnect(p4)
				disconnect(p4)

				if not v5._handlerListHead then
					destroySignal(state, p)
				end
			end

			v6.Destroy = v6.Disconnect
			return v6
		end

		if events then
			events[p] = v5
		else
			events = {
				[p] = v5
			}
			state.events = events
		end
	end

	local v5

	if events then
		return events[p]
	end

	return v5
end

function fireEvent(p, p2: string, p3, ...)
	assert(p, "You cannot connect to a destroyed Replion!")
	local signal = getSignal(p, p2, p3, false)

	if signal then
		signal:Fire(...)
	end
end

function connect(p, p2: string, value, callback)
	assert(p, "You cannot connect to a destroyed Replion!")

	if not _G.__DEV__ or _G.__IGNORE_INSTANCES_WARNING__ then
		return assert(getSignal(p, p2, value), "Signal does not exist!"):Connect(callback)
	end

	local flag = false
	local v2, v3, v4

	if type(value) == "table" then
		v2 = value
	elseif type(value) == "string" then
		v2, v3, v4 = string.split(value, ".")
	else
		v2 = { value }
	end

	for _, v6 in v2, v3, v4 do
		if typeof(v6) ~= "Instance" then
			continue
		end

		flag = true
		break
	end

	if flag then
		local v6, v7 = debug.info(3, "sl")
		task.spawn(
			error,
			`[Memory Leak Warning] Instance used as a Connection index at {v6}:{v7}. ` .. "Using Instances will cause memory leaks as Replion cannot automatically dispose of such connections. Consider using a string or number as your index to prevent this issue."
		)
	end

	return assert(getSignal(p, p2, value), "Signal does not exist!"):Connect(callback)
end

local Graph = {}

function Graph.createRootNode()
	v.n += 1
	local v3 = {
		children = {}
	}
	v[v.n] = v3
	return v3
end

function Graph.destroyRootNode(p)
	if not p then
		return
	end

	local index = table.find(v, p)

	if not index then
		return
	end

	v[index] = v[v.n]
	v[v.n] = nil
	v.n -= 1
	local v3 = 1
	local v4 = 1
	local v5 = { p }

	while v3 <= v4 do
		local v6 = v5[v3]
		v3 += 1

		if v6.events then
			for _, event in v6.events do
				event:Destroy()
			end

			v6.events = nil
		end

		if v6.children then
			for _, v7 in v6.children do
				v4 += 1
				v5[v4] = v7
			end
		end

		v6.children = nil
		v6.parent = nil
	end
end

Graph.getSignal = getSignal

function Graph.fireChange(p, value, p2, p3)
	assert(p, "You cannot connect to a destroyed Replion!")

	if not p.children then
		return
	end

	local v2, v3, v4

	if value then
		local v5

		if type(value) == "table" then
			v5 = value
		else
			v5 = type(value) ~= "string" and { value } or string.split(value, ".")
		end

		v2 = p3
		v3 = p2
		v4 = p

		for i = 1, #v5 + 1 do
			if p.events and p.events.onChange then
				if p2 ~= p3 then
					p.events.onChange:Fire(p2, p3)
				end

				v2 = p3
				v3 = p2
				v4 = p
			end

			if not (i <= #v5) then
				continue
			end

			local v6 = v5[i]

			if not (p.children and p.children[v6]) then
				return
			end

			p = p.children[v6]

			if p2 and type(p2) == "table" then
				p2 = p2[v6]
			else
				p2 = nil
			end

			if p3 and type(p3) == "table" then
				p3 = p3[v6]
			else
				p3 = nil
			end
		end
	else
		v2 = p3
		v3 = p2
		v4 = p
	end

	local v5 = 1
	local v6 = 0
	local v7 = {}
	local v8 = {}
	local v9 = {}
	local v10, v11, v12, v13, v14

	if value then
		if not v4.children or type(v3) ~= "table" or type(v2) ~= "table" then
			return
		end

		for k, v15 in v4.children do
			local v16 = v3[k]
			local v17 = v2[k]

			if v16 == v17 then
				continue
			end

			v6 += 1
			v7[v6] = v15
			v8[v6] = v16
			v9[v6] = v17
		end
	else
		v7[1] = v4
		v8[1] = v3
		v9[1] = v2
		v6 = 1
	end

	while v5 <= v6 do
		v10 = v7[v5]
		v11 = v8[v5]
		v12 = v9[v5]
		v5 += 1

		if v10.events and v10.events.onChange then
			v10.events.onChange:Fire(v11, v12)
		end

		if not (v10.children and type(v11) == "table" and type(v12) == "table") then
			continue
		end

		for k, v15 in v10.children do
			v13 = v11[k]
			v14 = v12[k]

			if v13 == v14 then
				continue
			end

			v6 += 1
			v7[v6] = v15
			v8[v6] = v13
			v9[v6] = v14
		end
	end
end

Graph.fireEvent = fireEvent
Graph.connect = connect
return Graph