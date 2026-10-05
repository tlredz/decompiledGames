if not game then
	local module = require("test/relative-string")
	script = module
end

local flags = require(script.Parent.flags)
local throw = require(script.Parent.throw)
local graph = require(script.Parent.graph)

local function batch(callback)
	local batch2 = flags.batch
	local v

	if not batch2 then
		flags.batch = true
		v = graph.get_update_queue_length()
	end

	local success, result = pcall(callback)

	if not batch2 then
		flags.batch = false
		graph.flush_update_queue(v)
	end

	if not success then
		throw((`error occured while batching updates: {result}`))
	end
end

return batch