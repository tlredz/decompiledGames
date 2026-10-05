if not game then
	local module = require("test/relative-string")
	script = module
end

local throw = require(script.Parent.throw)
local graph = require(script.Parent.graph)
local create_node = graph.create_node
local get_scope = graph.get_scope
local push_scope = graph.push_scope
local pop_scope = graph.pop_scope
local set_context = graph.set_context
local v = newproxy()
local count = 0

local function context(...)
	count += 1
	local v2 = count
	local v3 = select("#", ...) > 0
	local v4 = ...
	return function(...)
		local owner = get_scope()

		if select("#", ...) == 0 then
			while owner do
				local context2 = owner.context

				if context2 then
					local v5 = context2[v2]

					if v5 ~= nil then
						if v5 == v then
							return nil
						else
							return v5
						end
					end
				end

				owner = owner.owner
			end

			if v3 ~= nil then
				return v4
			end

			throw("attempt to get context when no context is set and no default context is set")
			return nil
		else
			if not owner then
				return throw("attempt to set context outside of a vide scope")
			end

			local v5, v6 = ...
			local v7 = create_node(owner, false, false)

			if v5 == nil then
				v5 = v
			end

			set_context(v7, v2, v5)
			push_scope(v7)

			local function efn(p: string)
				return debug.traceback(p, 3)
			end

			local v10, v11 = xpcall(v6, efn)
			pop_scope()

			if not v10 then
				throw((`error while running context:\n\n{v11}`))
			end

			return v11
		end
	end
end

return context