local parent = script.Parent
local useTagged = require(parent.useTagged)
local useChild = require(parent.useChild)
local shared = parent.Parent.Parent.Shared
require(shared.React)

local function useComponent(p: string, p2)
	local moduleScript = useChild(useTagged("RelicsComponents")[1], p)

	if moduleScript and moduleScript:IsA("ModuleScript") then
		local module = require(moduleScript)

		if type(module) == "function" then
			return module
		end
	end

	return p2
end

return useComponent