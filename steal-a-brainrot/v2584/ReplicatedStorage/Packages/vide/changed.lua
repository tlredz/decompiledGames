local action = require(script.Parent.action)
local v = action()
local cleanup = require(script.Parent.cleanup)

local function changed(propertyName: string, callback)
	return v(function(instance)
		local connection = instance:GetPropertyChangedSignal(propertyName):Connect(function()
			callback(instance[propertyName])
		end)
		cleanup(function()
			connection:Disconnect()
		end)
		callback(instance[propertyName])
	end)
end

return changed