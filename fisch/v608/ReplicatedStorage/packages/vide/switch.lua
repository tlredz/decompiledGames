if not game then
	local module = require("test/relative-string")
	script = module
end

local throw = require(script.Parent.throw)
local graph = require(script.Parent.graph)
local create_node = graph.create_node
local evaluate_node = graph.evaluate_node
local push_child_to_scope = graph.push_child_to_scope
local destroy = graph.destroy
local assert_stable_scope = graph.assert_stable_scope
local push_scope = graph.push_scope
local pop_scope = graph.pop_scope

local function switch(callback)
	local v = assert_stable_scope()
	return function(p)
		local v2 = nil
		local v3 = nil

		local function update(p2)
			local v4 = p[callback()]

			if v4 == v3 then
				return p2
			end

			v3 = v4

			if v2 then
				destroy(v2)
				v2 = nil
			end

			if v4 == nil then
				return nil
			end

			if type(v4) ~= "function" then
				throw("map must map a value to a function")
			end

			local v5 = create_node(v, false, false)
			v2 = v5
			push_scope(v5)
			local success, result = pcall(v4)
			pop_scope()

			if not success then
				error(result, 0)
			end

			return result
		end

		local v4 = create_node(v, update, nil)
		evaluate_node(v4)
		return function()
			push_child_to_scope(v4)
			return v4.cache
		end
	end
end

return switch