local module = require("./action")
local v = module()
local module2 = require("./cleanup")

local function changed(propertyName: string, callback)
	return v(function(instance)
		local connection = instance:GetPropertyChangedSignal(propertyName):Connect(function()
			callback(instance[propertyName])
		end)
		module2(function()
			connection:Disconnect()
		end)
		callback(instance[propertyName])
	end)
end

return changed