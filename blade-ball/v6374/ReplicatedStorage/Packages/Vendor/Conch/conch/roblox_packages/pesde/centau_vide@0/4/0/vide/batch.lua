local module = require("./flags")
local module2 = require("./graph")

local function batch(callback)
	local batch2 = module.batch
	local v

	if not batch2 then
		module.batch = true
		v = module2.get_update_queue_length()
	end

	local v2, v3 = xpcall(callback, debug.traceback)

	if not batch2 then
		module.batch = false
		module2.flush_update_queue(v)
	end

	if not v2 then
		error(`error occured while batching updates: {v3}`, 0)
	end
end

return batch