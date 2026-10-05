if not game then
	local module = require("test/relative-string")
	script = module
end

local graph = require(script.Parent.graph)
local create_node = graph.create_node
local assert_stable_scope = graph.assert_stable_scope
local evaluate_node = graph.evaluate_node

function create_implicit_effect(callback, p)
	evaluate_node(create_node(assert_stable_scope(), callback, p))
end

local function update_property_effect(data)
	data.instance[data.property] = data.source()
	return data
end

local function update_parent_effect(p)
	p.instance.Parent = p.parent()
	return p
end

local function update_children_effect(state)
	local cur_children_set = state.cur_children_set
	local new_children_set = state.new_children_set
	local children = state.children()
	local process_child

	process_child = function(items)
		if type(items) == "table" then
			for _, item in next, items, nil do
				process_child(item)
			end
		else
			if new_children_set[items] then
				return
			end

			new_children_set[items] = true

			if cur_children_set[items] then
				cur_children_set[items] = nil
			else
				items.Parent = state.instance
			end
		end
	end

	process_child(type(children) ~= "table" and { children } or children)

	for k in next, cur_children_set, nil do
		k.Parent = nil
	end

	table.clear(cur_children_set)
	state.cur_children_set = new_children_set
	state.new_children_set = cur_children_set
	return state
end

local Bind = {}

function Bind.property(instance, property, source)
	return create_implicit_effect(update_property_effect, {
		instance = instance,
		property = property,
		source = source
	})
end

function Bind.parent(instance, parent)
	return create_implicit_effect(update_parent_effect, {
		instance = instance,
		parent = parent
	})
end

function Bind.children(instance, children)
	return create_implicit_effect(update_children_effect, {
		instance = instance,
		cur_children_set = {},
		new_children_set = {},
		children = children
	})
end

return Bind