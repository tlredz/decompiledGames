local shared = require(script.Parent.Parent:WaitForChild("shared"))
local REACT_PORTAL_TYPE = shared.ReactSymbols.REACT_PORTAL_TYPE
require(script.Parent.Parent:WaitForChild("shared"))
return {
	createPortal = function(children, containerInfo, implementation, p4: string?)
		if p4 ~= nil then
			p4 = tostring(p4)
		end

		return {
			["$$typeof"] = REACT_PORTAL_TYPE,
			key = p4,
			children = children,
			containerInfo = containerInfo,
			implementation = implementation
		}
	end
}