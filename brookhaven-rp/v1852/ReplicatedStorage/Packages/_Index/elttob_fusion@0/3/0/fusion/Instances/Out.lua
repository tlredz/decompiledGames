local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local checkLifetime = require(parent.Memory.checkLifetime)
local castToState = require(parent.State.castToState)
local v = {}

local function Out(p: string)
	local v2 = v[p]

	if v2 == nil then
		v2 = {
			type = "SpecialKey",
			kind = "Out",
			stage = "observer",
			apply = function(_, connections, object, instance)
				local success, propertyChangedSignal = pcall(instance.GetPropertyChangedSignal, instance, p)

				if not success then
					External.logError("invalidOutProperty", nil, instance.ClassName, p)
				end

				if not castToState(object) then
					External.logError("invalidOutType")
				end

				if object.kind ~= "Value" then
					External.logError("invalidOutType")
				end

				checkLifetime.bOutlivesA(
					connections,
					instance,
					object.scope,
					object.oldestTask,
					checkLifetime.formatters.propertyOutputsTo,
					p
				)
				object:set(instance[p])
				table.insert(connections, propertyChangedSignal:Connect(function()
					object:set(instance[p])
				end))
			end
		}
		v[p] = v2
	end

	return v2
end

return Out