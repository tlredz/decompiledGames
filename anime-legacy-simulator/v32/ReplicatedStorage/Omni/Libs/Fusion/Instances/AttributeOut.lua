local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local checkLifetime = require(parent.Memory.checkLifetime)
local castToState = require(parent.State.castToState)
local v = {}

local function AttributeOut(attributeName: string)
	local v2 = v[attributeName]

	if v2 == nil then
		v2 = {
			type = "SpecialKey",
			kind = "AttributeOut",
			stage = "observer",
			apply = function(_, connections, object, instance)
				local attributeChangedSignal = instance:GetAttributeChangedSignal(attributeName)

				if not castToState(object) then
					External.logError("invalidAttributeOutType")
				end

				if object.kind ~= "Value" then
					External.logError("invalidAttributeOutType")
				end

				checkLifetime.bOutlivesA(
					connections,
					instance,
					object.scope,
					object.oldestTask,
					checkLifetime.formatters.attributeOutputsTo,
					attributeName
				)
				object:set(instance:GetAttribute(attributeName))
				table.insert(connections, attributeChangedSignal:Connect(function()
					object:set(instance:GetAttribute(attributeName))
				end))
			end
		}
		v[attributeName] = v2
	end

	return v2
end

return AttributeOut