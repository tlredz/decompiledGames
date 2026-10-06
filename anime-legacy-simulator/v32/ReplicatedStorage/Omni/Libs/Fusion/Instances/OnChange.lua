local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local v = {}

local function OnChange(p: string)
	local v2 = v[p]

	if v2 == nil then
		v2 = {
			type = "SpecialKey",
			kind = "OnChange",
			stage = "observer",
			apply = function(_, connections, callback, instance)
				local success, propertyChangedSignal = pcall(instance.GetPropertyChangedSignal, instance, p)

				if not success then
					External.logError("cannotConnectChange", nil, instance.ClassName, p)
				elseif typeof(callback) == "function" then
					table.insert(connections, propertyChangedSignal:Connect(function()
						callback(instance[p])
					end))
				else
					External.logError("invalidChangeHandler", nil, p)
				end
			end
		}
		v[p] = v2
	end

	return v2
end

return OnChange