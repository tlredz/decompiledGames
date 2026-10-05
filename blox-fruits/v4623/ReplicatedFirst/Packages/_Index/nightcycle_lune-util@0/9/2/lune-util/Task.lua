local CONFIG = require(script.Parent:WaitForChild("CONFIG"))

if CONFIG.IS_LUNE_ENV then
	local module = require("@lune/task")
	return {
		spawn = module.spawn,
		defer = module.defer,
		delay = module.delay,
		wait = module.wait,
		cancel = module.cancel
	}
end

if CONFIG.IS_RBX_ENV then
	return {
		spawn = task.spawn,
		defer = task.defer,
		delay = task.delay,
		wait = task.wait,
		cancel = task.cancel
	}
end

error("Unsupported environment")
return nil