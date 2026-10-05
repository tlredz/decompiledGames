if not game then
	local module = require("test/relative-string")
	script = module
end

local throw = require(script.Parent.throw)
local flags = require(script.Parent.flags)
local scopes = {
	n = 0
}

local function ycall(effect, cache)
	local thread = coroutine.create(xpcall)

	local function efn(p: string)
		return debug.traceback(p, 3)
	end

	local v2, v3, v4 = coroutine.resume(thread, effect, efn, cache)
	assert(v2)

	if coroutine.status(thread) == "dead" then
		return v3, v4
	end

	return false, debug.traceback(thread, "attempt to yield in reactive scope")
end

local function flush_cleanups(state)
	if state.cleanups then
		for _, callback in next, state.cleanups, nil do
			local success, result = pcall(callback)

			if not success then
				throw((`cleanup error: {result}`))
			end
		end

		table.clear(state.cleanups)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function find_and_swap_pop(list, p)
	local index = table.find(list, p)
	local count = #list
	list[index] = list[count]
	list[count] = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function unparent(p)
	local parents = p.parents

	for k, parent in parents do
		find_and_swap_pop(parent, p) -- equivalent call inferred; original call site unknown
		parents[k] = nil
	end
end

local destroy

destroy = function(state)
	flush_cleanups(state)
	unparent(state) -- equivalent call inferred; original call site unknown

	if state.owner then
		find_and_swap_pop(state.owner.owned, state) -- equivalent call inferred; original call site unknown
		state.owner = false
	end

	if state.owned then
		local owned = state.owned

		while owned[1] do
			destroy(owned[1])
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function destroy_owned(state)
	if state.owned then
		local owned = state.owned

		while owned[1] do
			destroy(owned[1])
		end
	end
end

local v2 = {
	n = 0
}

local function evaluate_node(state)
	if flags.strict then
		local cache = state.cache

		for _ = 1, 2 do
			local cache2 = state.cache
			flush_cleanups(state)
			destroy_owned(state) -- equivalent call inferred; original call site unknown
			local v3 = scopes.n + 1
			scopes.n = v3
			scopes[v3] = state
			local v4, cache3 = ycall(state.effect, cache2)
			local n = scopes.n
			scopes.n = n - 1
			scopes[n] = nil

			if not v4 then
				table.clear(v2)
				v2.n = 0
				throw((`effect stacktrace:\n{cache3}`))
			end

			state.cache = cache3
		end

		return cache ~= state.cache
	else
		local cache = state.cache
		flush_cleanups(state)
		destroy_owned(state) -- equivalent call inferred; original call site unknown
		local v3 = scopes.n + 1
		scopes.n = v3
		scopes[v3] = state
		local success, result = pcall(state.effect, state.cache)
		local n = scopes.n
		scopes.n = n - 1
		scopes[n] = nil

		if not success then
			table.clear(v2)
			v2.n = 0
			throw((`effect stacktrace:\n{result}\n`))
		end

		state.cache = result
		return cache ~= result
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function queue_children_for_update(list)
	local n = v2.n

	while list[1] do
		n += 1
		v2[n] = list[1]
		unparent(list[1]) -- equivalent call inferred; original call site unknown
	end

	v2.n = n
end

return table.freeze({
	push_scope = function(p)
		local v3 = scopes.n + 1
		scopes.n = v3
		scopes[v3] = p
	end,
	pop_scope = function()
		local n = scopes.n
		scopes.n = n - 1
		scopes[n] = nil
	end,
	evaluate_node = evaluate_node,
	get_scope = function()
		return scopes[scopes.n]
	end,
	assert_stable_scope = function()
		local v3 = scopes[scopes.n]

		if not v3 then
			return throw((`cannot use {debug.info(2, "n")}() outside a stable or reactive scope`))
		end

		if v3.effect then
			throw("cannot create a new reactive scope inside another reactive scope")
		end

		return v3
	end,
	push_cleanup = function(p, callback)
		if p.cleanups then
			table.insert(p.cleanups, callback)
		else
			p.cleanups = { callback }
		end
	end,
	destroy = destroy,
	flush_cleanups = flush_cleanups,
	push_child_to_scope = function(list)
		local v3 = scopes[scopes.n]

		if v3 and v3.effect then
			table.insert(list, v3)
			table.insert(v3.parents, list)
		end
	end,
	update_descendants = function(list)
		local n = v2.n
		queue_children_for_update(list) -- equivalent call inferred; original call site unknown

		if flags.batch then
			return
		end

		local v3 = n + 1

		while v3 <= v2.n do
			local v4 = v2[v3]

			if v4.owner and evaluate_node(v4) then
				queue_children_for_update(v4) -- equivalent call inferred; original call site unknown
			end

			v2[v3] = false
			v3 += 1
		end

		v2.n = n
	end,
	push_child = function(list, p)
		table.insert(list, p)
		table.insert(p.parents, list)
	end,
	create_node = function(owner, effect, cache)
		local v3 = {
			cache = cache,
			effect = effect,
			cleanups = false,
			context = false,
			owner = owner,
			owned = false,
			parents = {}
		}

		if not owner then
			return v3
		end

		if owner.owned then
			table.insert(owner.owned, v3)
			return v3
		end

		owner.owned = { v3 }
		return v3
	end,
	create_source_node = function(cache)
		return {
			cache = cache
		}
	end,
	get_children = function(list)
		return { unpack(list) }
	end,
	flush_update_queue = function(p: number)
		local v3 = p + 1

		while v3 <= v2.n do
			local v4 = v2[v3]

			if v4.owner and evaluate_node(v4) then
				queue_children_for_update(v4) -- equivalent call inferred; original call site unknown
			end

			v2[v3] = false
			v3 += 1
		end

		v2.n = p
	end,
	get_update_queue_length = function()
		return v2.n
	end,
	set_context = function(p, p2: number, p3)
		if p.context then
			p.context[p2] = p3
		else
			p.context = {
				[p2] = p3
			}
		end
	end,
	scopes = scopes
})