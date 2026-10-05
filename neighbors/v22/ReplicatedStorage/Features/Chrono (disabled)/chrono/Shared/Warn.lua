local Config = require(script.Parent.Config)

-- equivalent calls inferred from this helper; original call sites unknown
local function checkLevel(upper)
	local v = {
		NONE = 0,
		LOW = 1,
		MEDIUM = 2,
		HIGH = 3
	}
	local v2 = v[Config._GetConfig("WARNING_SEVERITY")] or 0
	return v2 ~= 0 and v2 <= (v[upper] or 0)
end

return (setmetatable({}, {
	__index = function(_, value)
		-- equivalent call inferred; original call site unknown
		if checkLevel(value:upper()) then
			return warn
		end

		return function() end
	end
}))