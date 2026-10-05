local module = require("./graph")
local create_node = module.create_node
local assert_stable_scope = module.assert_stable_scope
local get_scope = module.get_scope
local evaluate_node = module.evaluate_node
local push_cleanup = module.push_cleanup

local function update_property_effect(data)
	data.instance[data.property] = data.source()
	return data
end

local function update_parent_effect(p)
	p.instance.Parent = p.source()
	return p
end

local update_children_effect

update_children_effect = function(state)
	local cur_children_set = state.cur_children_set
	local new_children_set = state.new_children_set
	local source = state.source()
	local process_child

	process_child = function(source2)
		if type(source2) == "userdata" then
			if new_children_set[source2] then
				return
			end

			new_children_set[source2] = true

			if cur_children_set[source2] then
				cur_children_set[source2] = nil
			else
				source2.Parent = state.instance
			end
		elseif type(source2) == "table" then
			for _, item in source2 do
				process_child(item)
			end
		elseif type(source2) == "function" then
			local v = create_node(assert(get_scope()), update_children_effect, {
				instance = state.instance,
				cur_children_set = {},
				new_children_set = {},
				source = source2
			})
			evaluate_node(v)
			push_cleanup(assert(get_scope()), function()
				for k in v.cache.cur_children_set do
					k.Parent = nil
				end
			end)
		end
	end

	process_child(source)

	for k in cur_children_set do
		k.Parent = nil
	end

	table.clear(cur_children_set)
	state.cur_children_set = new_children_set
	state.new_children_set = cur_children_set
	return state
end

local ImplicitEffect = {}

function ImplicitEffect.property(instance, property, source)
	local v = create_node(assert_stable_scope(), update_property_effect, {
		instance = instance,
		property = property,
		source = source
	})
	evaluate_node(v)
	return v
end

function ImplicitEffect.parent(instance, source)
	local v = create_node(assert_stable_scope(), update_parent_effect, {
		instance = instance,
		source = source
	})
	evaluate_node(v)
	return v
end

function ImplicitEffect.children(instance, source)
	local v = create_node(assert_stable_scope(), update_children_effect, {
		instance = instance,
		cur_children_set = {},
		new_children_set = {},
		source = source
	})
	evaluate_node(v)
	push_cleanup(assert_stable_scope(), function()
		for k in v.cache.cur_children_set do
			k.Parent = nil
		end
	end)
	return v
end

return ImplicitEffect