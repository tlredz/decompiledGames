local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local v = {}

local function AttributeChange(attributeName: string)
	local v2 = v[attributeName]

	if v2 == nil then
		v2 = {
			type = "SpecialKey",
			kind = "AttributeChange",
			stage = "observer",
			apply = function(_, connections, callback, instance)
				if typeof(callback) ~= "function" then
					External.logError("invalidAttributeChangeHandler", nil, attributeName)
				end

				table.insert(connections, instance:GetAttributeChangedSignal(attributeName):Connect(function()
					callback(instance:GetAttribute(attributeName))
				end))
			end
		}
		v[attributeName] = v2
	end

	return v2
end

return AttributeChange