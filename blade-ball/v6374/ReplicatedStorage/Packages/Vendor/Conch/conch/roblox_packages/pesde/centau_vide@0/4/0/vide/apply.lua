local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local typeof2 = game and typeof or require3("../test/mock").typeof
local v = require3("./flags")
local v2 = require3("./implicit_effect")
local _, v3 = require3("./action")()
require3("./graph")
local v4 = nil

local function borrow_cache()
	if not v4 then
		return {
			events = {},
			actions = setmetatable({}, {
				__index = function(p, p2)
					p[p2] = {}
					return p[p2]
				end
			}),
			parent = nil,
			nested_debug = setmetatable({}, {
				__index = function(p, p2: number)
					p[p2] = {}
					return p[p2]
				end
			}),
			nested_stack = {}
		}
	end

	local v5 = v4
	v4 = nil
	return v5
end

local function return_cache(p)
	v4 = p
end

local process_properties

process_properties = function(items, parent, state, p: number)
	for k, item in items do
		if type(k) == "string" then
			if v.strict then
				if state.nested_debug[p][k] then
					error(`duplicate property {k} at depth {p}`, 0)
				end

				state.nested_debug[p][k] = true
			end

			if k == "Parent" then
				state.parent = item
			elseif type(item) == "function" then
				if typeof2(parent[k]) == "RBXScriptSignal" then
					table.insert(state.events, k)
					table.insert(state.events, item)
				else
					v2.property(parent, k, item)
				end
			else
				parent[k] = item
			end
		elseif type(k) == "number" then
			if type(item) == "function" then
				v2.children(parent, item)
			elseif type(item) == "table" then
				if v3(item) then
					table.insert(state.actions[item.priority], item.callback)
				elseif v.defer_nested_properties then
					table.insert(state.nested_stack, item)
					table.insert(state.nested_stack, p + 1)
				else
					process_properties(item, parent, state, p + 1)
				end
			elseif type(item) == "userdata" then
				item.Parent = parent
			end
		end
	end
end

local function apply(p, p2)
	if not p2 then
		error("attempt to call a constructor returned by create() with no properties")
	end

	local v5 = borrow_cache()
	local events = v5.events
	local actions = v5.actions
	local nested_debug = v5.nested_debug
	local nested_stack = v5.nested_stack
	local v6 = 1

	repeat
		process_properties(p2, p, v5, v6)
		v6 = table.remove(nested_stack)
		p2 = table.remove(nested_stack)
	until not p2

	for i = 1, #events, 2 do
		local event = events[i]
		local event2 = events[i + 1]
		p[event]:Connect(event2)
	end

	for _, action in actions do
		for _, v7 in action do
			v7(p)
		end
	end

	local parent = v5.parent

	if parent then
		if type(parent) == "function" then
			v2.parent(p, parent)
		else
			p.Parent = parent
		end
	end

	table.clear(events)

	for _, list in actions do
		table.clear(list)
	end

	v5.parent = nil

	if v.strict then
		table.clear(nested_debug)
	end

	table.clear(nested_stack)
	v4 = v5
	return p
end

return apply