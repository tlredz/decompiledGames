local Signal = require(script.Parent.Parent.Parent.Signal)
require(script.Parent.Types)
local Utils = require(script.Parent.Utils)
local v = {
	n = 0
}

-- equivalent calls inferred from this helper; original call sites unknown
local function get(p, p2: string)
	if p and type(p) == "table" then
		return p[p2]
	end

	return nil
end

local function destroySignal(parent, p: string)
	if not parent.events then
		return
	end

	local event = parent.events[p]

	if not event then
		return
	end

	event:Destroy()
	parent.events[p] = nil

	if next(parent.events) then
		return
	end

	parent.events = nil

	while parent.parent do
		if not (parent.events or parent.children and next(parent.children)) and parent.parent then
			assert(parent.parent.children, "Parent node has no children!")
			parent.parent.children[parent.id] = nil
		end

		parent = parent.parent
	end
end

function getSignal(p, p2: string, p3, flag: boolean?)
	local v2 = flag == nil or flag
	local parent = assert(p, "You're trying to use a destroyed Replion!")

	for _, id in Utils.getPathTable(p3) do
		if not (parent.children and parent.children[id]) then
			if not v2 then
				return nil
			end

			local children = parent.children or {}
			children[id] = {
				parent = parent,
				id = id
			}
			parent.children = children
		end

		if parent.children then
			parent = parent.children[id]
		else
			parent = nil
		end

		if not parent then
			return nil
		end
	end

	local events = parent.events

	if v2 and not (events and events[p2]) then
		local v4 = Signal.new()
		local connect2 = v4.Connect

		function v4:Connect(p5)
			local v5 = connect2(self, p5)
			local disconnect = v5.Disconnect

			function v5.Disconnect(p6)
				disconnect(p6)

				if not v4._handlerListHead then
					destroySignal(parent, p2)
				end
			end

			v5.Destroy = v5.Disconnect
			return v5
		end

		if events then
			events[p2] = v4
		else
			events = {
				[p2] = v4
			}
			parent.events = events
		end
	end

	local v4

	if events then
		return events[p2]
	end

	return v4
end

function fireEvent(p, p2: string, p3, ...)
	assert(p, "You cannot connect to a destroyed Replion!")
	local signal = getSignal(p, p2, p3, false)

	if signal then
		signal:Fire(...)
	end
end

function connect(p, p2: string, p3, callback)
	assert(p, "You cannot connect to a destroyed Replion!")

	if not _G.__DEV__ or _G.__IGNORE_INSTANCES_WARNING__ then
		return assert(getSignal(p, p2, p3), "Signal does not exist!"):Connect(callback)
	end

	local flag = false

	for _, v3 in Utils.getPathTable(p3) do
		if typeof(v3) ~= "Instance" then
			continue
		end

		flag = true
		break
	end

	if flag then
		local v3, v4 = debug.info(3, "sl")
		task.spawn(
			error,
			`[Memory Leak Warning] Instance used as a Connection index at {v3}:{v4}. ` .. "Using Instances will cause memory leaks as Replion cannot automatically dispose of such connections. Consider using a string or number as your index to prevent this issue."
		)
	end

	return assert(getSignal(p, p2, p3), "Signal does not exist!"):Connect(callback)
end

local Graph = {}

function Graph.createRootNode()
	v.n += 1
	v[v.n] = {
		children = {}
	}
	return v[v.n]
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
	local destroySignals

	destroySignals = function(state)
		if state.events then
			for _, event in state.events do
				event:Destroy()
			end

			state.events = nil
		end

		if state.children and next(state.children) then
			for _, v3 in state.children do
				destroySignals(v3)
			end
		end
	end

	destroySignals(p)
end

Graph.getSignal = getSignal

function Graph.fireChange(p, list, p2, p3)
	assert(p, "You cannot connect to a destroyed Replion!")

	if list then
		p = p.children[list[1]]
	end

	if not p then
		return
	end

	local onDescendantChanges = {}
	local v2 = {}
	local fireSignals

	fireSignals = function(p4, list2, items, items2, flag: boolean?)
		local events = p4.events
		local onChange = events and events.onChange
		local onDescendantChange = events and events.onDescendantChange

		if items ~= items2 then
			if onChange and not v2[p4] then
				v2[p4] = true
				onChange:Fire(items, items2)
			end

			for _, v3 in onDescendantChanges do
				v3:Fire(list2, items, items2)
			end
		end

		if onDescendantChange and not onDescendantChanges[p4] then
			onDescendantChanges[p4] = onDescendantChange
		end

		if next(onDescendantChanges) ~= nil then
			if items == items2 then
				return
			end

			local v3

			if list then
				v3 = #list2 <= #list
			else
				v3 = false
			end

			if flag and not v3 then
				return
			end

			local v4 = {}

			local function fireChild(k)
				if v4[k] then
					return
				end

				v4[k] = true
				local v6 = get(items, k) -- equivalent call inferred; original call site unknown
				local v8 = get(items2, k) -- equivalent call inferred; original call site unknown

				if v6 == v8 then
					return
				end

				local clone = table.clone(list2)
				table.insert(clone, k)
				fireSignals(p4, clone, v6, v8, true)
			end

			if type(items) == "table" then
				for k in items do
					fireChild(k)
				end
			end

			if type(items2) == "table" then
				for k in items2 do
					fireChild(k)
				end
			end
		else
			if not p4.children then
				return
			end

			for k, v3 in p4.children do
				local v4 = get(items, k) -- equivalent call inferred; original call site unknown
				local v5 = get(items2, k) -- equivalent call inferred; original call site unknown
				local clone = table.clone(list2)
				table.insert(clone, k)
				fireSignals(v3, clone, v4, v5, flag)
			end
		end
	end

	if list then
		local v3 = list[1]

		if p2 and type(p2) == "table" then
			p2 = p2[v3]
		else
			p2 = nil
		end
	end

	if list then
		local v3 = list[1]

		if p3 and type(p3) == "table" then
			p3 = p3[v3]
		else
			p3 = nil
		end
	end

	fireSignals(p, list and { list[1] } or {}, p2, p3)
end

Graph.fireEvent = fireEvent
Graph.connect = connect
return Graph