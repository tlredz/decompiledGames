if not game then
	local module = require("test/relative-string")
	script = module
end

local throw = require(script.Parent.throw)
local flags = require(script.Parent.flags)
local graph = require(script.Parent.graph)
local create_node = graph.create_node
local create_source_node = graph.create_source_node
local push_child_to_scope = graph.push_child_to_scope
local update_descendants = graph.update_descendants
local assert_stable_scope = graph.assert_stable_scope
local push_scope = graph.push_scope
local pop_scope = graph.pop_scope
local evaluate_node = graph.evaluate_node
local destroy = graph.destroy

local function check_primitives(items)
	if not flags.strict then
		return
	end

	for _, item in next, items, nil do
		if not (type(item) ~= "table" and type(item) ~= "userdata" and type(item) ~= "function") then
			continue
		end

		throw("table source map cannot return primitives")
	end
end

local function indexes(callback, callback2)
	local v = assert_stable_scope()
	local v2 = create_node(v, false, false)
	local v3 = {}
	local v4 = {}
	local v5 = {}
	local v6 = {}
	local v7 = {}

	local function update_children(items)
		for k in next, v3, nil do
			if items[k] == nil then
				table.insert(v6, k)
			end
		end

		for _, v8 in next, v6, nil do
			destroy(v7[v8])
			v3[v8] = nil
			v4[v8] = nil
			v5[v8] = nil
			v7[v8] = nil
		end

		table.clear(v6)
		push_scope(v2)

		for k, item in next, items, nil do
			local v8 = v3[k]

			if v8 == item then
				continue
			end

			if v8 == nil then
				local v9 = create_node(v2, false, false)
				v7[k] = v9
				local v10 = create_source_node(item)
				push_scope(v9)
				local success, result = pcall(callback2, function()
					push_child_to_scope(v10)
					return v10.cache
				end, k)
				pop_scope()

				if not success then
					pop_scope()
					error(result, 0)
				end

				v5[k] = v10
				v4[k] = result
			else
				v5[k].cache = item
				update_descendants(v5[k])
			end

			v3[k] = item
		end

		pop_scope()
		local result = table.create(#v7)

		for _, v8 in next, v4, nil do
			table.insert(result, v8)
		end

		check_primitives(result)
		return result
	end

	local v8 = create_node(v, function()
		return (update_children(callback()))
	end, false)
	evaluate_node(v8)
	return function()
		push_child_to_scope(v8)
		return v8.cache
	end
end

local function values(callback, callback2)
	local v = assert_stable_scope()
	local v2 = create_node(v, false, false)
	local v3 = {}
	local v4 = {}
	local v5 = {}
	local v6 = {}
	local v7 = {}

	local function update_children(items)
		local v8 = v3
		local v9 = v4

		if flags.strict then
			local v10 = {}

			for _, item in next, items, nil do
				if v10[item] ~= nil then
					throw("duplicate table value detected")
				end

				v10[item] = true
			end
		end

		push_scope(v2)

		for k, item in next, items, nil do
			v9[item] = k
			local v10 = v8[item]

			if v10 == nil then
				local v11 = create_node(v2, false, false)
				v7[item] = v11
				local v12 = create_source_node(k)
				push_scope(v11)
				local success, result = pcall(callback2, item, function()
					push_child_to_scope(v12)
					return v12.cache
				end)
				pop_scope()

				if not success then
					pop_scope()
					error(result, 0)
				end

				v6[item] = v12
				v5[item] = result
			else
				if v10 ~= k then
					v6[item].cache = k
					update_descendants(v6[item])
				end

				v8[item] = nil
			end
		end

		pop_scope()

		for k in next, v8, nil do
			destroy(v7[k])
			v5[k] = nil
			v6[k] = nil
			v7[k] = nil
		end

		table.clear(v8)
		v3 = v9
		v4 = v8
		local result = table.create(#v7)

		for _, v10 in next, v5, nil do
			table.insert(result, v10)
		end

		check_primitives(result)
		return result
	end

	local v8 = create_node(v, function()
		return (update_children(callback()))
	end, false)
	evaluate_node(v8)
	return function()
		push_child_to_scope(v8)
		return v8.cache
	end
end

return function()
	return indexes, values
end