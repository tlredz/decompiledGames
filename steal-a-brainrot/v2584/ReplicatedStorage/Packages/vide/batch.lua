local flags = require(script.Parent.flags)
local graph = require(script.Parent.graph)

local function batch(callback)
	local batch2 = flags.batch
	local v

	if not batch2 then
		flags.batch = true
		v = graph.get_update_queue_length()
	end

	local v2, v3 = xpcall(callback, debug.traceback)

	if not batch2 then
		flags.batch = false
		graph.flush_update_queue(v)
	end

	if not v2 then
		error(`error occured while batching updates: {v3}`, 0)
	end
end

return batch