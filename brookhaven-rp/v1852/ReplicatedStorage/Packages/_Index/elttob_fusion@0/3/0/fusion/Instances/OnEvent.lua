local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local v = {}

local function getProperty_unsafe(p, p2: string)
	return p[p2]
end

local function OnEvent(p: string)
	local v2 = v[p]

	if v2 == nil then
		v2 = {
			type = "SpecialKey",
			kind = "OnEvent",
			stage = "observer",
			apply = function(_, connections, callback, instance)
				local success, result = pcall(getProperty_unsafe, instance, p)

				if not success or typeof(result) ~= "RBXScriptSignal" then
					External.logError("cannotConnectEvent", nil, instance.ClassName, p)
				elseif typeof(callback) == "function" then
					table.insert(connections, result:Connect(callback))
				else
					External.logError("invalidEventHandler", nil, p)
				end
			end
		}
		v[p] = v2
	end

	return v2
end

return OnEvent