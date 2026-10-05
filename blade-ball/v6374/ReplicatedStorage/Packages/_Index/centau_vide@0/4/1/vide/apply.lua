local typeof2 = game and typeof

if not typeof2 then
	local module = require("../test/mock")
	typeof2 = module.typeof
end

local module = require("./flags")
local module2 = require("./implicit_effect")
local module3 = require("./action")
local _, v = module3()
require("./graph")
local v2 = nil

local function borrow_cache()
	if not v2 then
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

	local v3 = v2
	v2 = nil
	return v3
end

local function return_cache(p)
	v2 = p
end

local process_properties

process_properties = function(items, parent, state, p: number)
	for k, item in items do
		if type(k) == "string" then
			if module.strict then
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
					module2.property(parent, k, item)
				end
			else
				parent[k] = item
			end
		elseif type(k) == "number" then
			if type(item) == "function" then
				module2.children(parent, item)
			elseif type(item) == "table" then
				if v(item) then
					table.insert(state.actions[item.priority], item.callback)
				elseif module.defer_nested_properties then
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

	local v3 = borrow_cache()
	local events = v3.events
	local actions = v3.actions
	local nested_debug = v3.nested_debug
	local nested_stack = v3.nested_stack
	local v4 = 1

	repeat
		process_properties(p2, p, v3, v4)
		v4 = table.remove(nested_stack)
		p2 = table.remove(nested_stack)
	until not p2

	for i = 1, #events, 2 do
		local event = events[i]
		local event2 = events[i + 1]
		p[event]:Connect(event2)
	end

	for _, action in actions do
		for _, v5 in action do
			v5(p)
		end
	end

	local parent = v3.parent

	if parent then
		if type(parent) == "function" then
			module2.parent(p, parent)
		else
			p.Parent = parent
		end
	end

	table.clear(events)

	for _, list in actions do
		table.clear(list)
	end

	v3.parent = nil

	if module.strict then
		table.clear(nested_debug)
	end

	table.clear(nested_stack)
	v2 = v3
	return p
end

return apply