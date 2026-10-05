if not game then
	local module = require("test/relative-string")
	script = module
end

local typeof2 = game and typeof

if not typeof2 then
	local module = require("test/mock")
	typeof2 = module.typeof
end

local vector2 = game and Vector2

if not vector2 then
	local module = require("test/mock")
	vector2 = module.Vector2
end

local uDim2 = game and UDim2

if not uDim2 then
	local module = require("test/mock")
	uDim2 = module.UDim2
end

local flags = require(script.Parent.flags)
local throw = require(script.Parent.throw)
local bind = require(script.Parent.bind)
local action = require(script.Parent.action)
local _, v = action()
require(script.Parent.graph)
local v2 = nil

local function borrow_caches()
	if not v2 then
		return {
			events = {},
			actions = setmetatable({}, {
				__index = function(p, p2)
					p[p2] = {}
					return p[p2]
				end
			}),
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

local function return_caches(p)
	v2 = p
end

local news = {}

for k, v3 in {
	CFrame = CFrame,
	Color3 = Color3,
	UDim = UDim,
	UDim2 = uDim2,
	Vector2 = vector2,
	Vector3 = Vector3,
	Rect = Rect
} do
	news[k] = v3.new
end

local function apply(parent, p)
	if not p then
		throw("attempt to call a constructor returned by create() with no properties")
	end

	local strict = flags.strict
	local parent2 = p.Parent
	local v3 = borrow_caches()
	local events = v3.events
	local actions = v3.actions
	local nested_debug = v3.nested_debug
	local nested_stack = v3.nested_stack
	local v4 = 1

	while true do
		for k, v5 in p do
			if k == "Parent" then
				continue
			end

			if type(k) == "string" then
				if strict then
					if nested_debug[v4][k] then
						throw((`duplicate property {k} at depth {v4}`))
					end

					nested_debug[v4][k] = true
				end

				if type(v5) == "table" then
					local v6 = news[typeof2(parent[k])]

					if v6 == nil then
						throw((`cannot aggregate type {typeof2(v5)} for property {k}`))
					end

					parent[k] = v6(unpack(v5))
				elseif type(v5) == "function" then
					if typeof2(parent[k]) == "RBXScriptSignal" then
						events[k] = v5
					else
						bind.property(parent, k, v5)
					end
				else
					parent[k] = v5
				end
			elseif type(k) == "number" then
				if type(v5) == "function" then
					bind.children(parent, v5)
				elseif type(v5) == "table" then
					if v(v5) then
						table.insert(actions[v5.priority], v5.callback)
					else
						table.insert(nested_stack, v5)
						table.insert(nested_stack, v4 + 1)
					end
				else
					v5.Parent = parent
				end
			end
		end

		v4 = table.remove(nested_stack)
		p = table.remove(nested_stack)

		if p then
			continue
		end

		for k, event in next, events, nil do
			parent[k]:Connect(event)
		end

		for _, action2 in next, actions, nil do
			for _, v5 in next, action2, nil do
				v5(parent)
			end
		end

		if parent2 then
			if type(parent2) == "function" then
				bind.parent(parent, parent2)
			else
				parent.Parent = parent2
			end
		end

		table.clear(events)

		for _, list in next, actions, nil do
			table.clear(list)
		end

		if strict then
			table.clear(nested_debug)
		end

		table.clear(nested_stack)
		v2 = v3
		return parent
	end
end

return apply