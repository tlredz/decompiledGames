local module = require("./plugin_api")
local module2 = require("./state")
local v = {}
local RuntimePluginApi = {
	set_history = function(history)
		module2.history = history
		v.fire_history(module2.history)
	end,
	get_history = function()
		return module2.history
	end,
	add = function(p: string)
		local index = table.find(module2.history, p)

		if index then
			table.remove(module2.history, index)
		end

		table.insert(module2.history, 1, p)

		if #module2.history > 500 then
			table.remove(module2.history)
		end

		v.fire_history(module2.history)
	end
}
local get_signal, fire_history = module.get_signal()
RuntimePluginApi.updated_history = get_signal
v.fire_history = fire_history
return RuntimePluginApi