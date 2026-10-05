local module = require("./state")
require("./types")
local Context = {}

function Context.create_command_context(executor, invocation_id)
	assert(not module.command_context[coroutine.running()], "there is already a command context for this thread")
	module.command_context[coroutine.running()] = {
		executor = executor,
		invocation_id = invocation_id
	}
	return function()
		module.command_context[coroutine.running()] = nil
	end
end

function Context.get_command_context()
	return module.command_context[coroutine.running()]
end

return Context