local parent = script.Parent.Parent
local Shared = require(parent.Shared)
local REACT_PORTAL_TYPE = Shared.ReactSymbols.REACT_PORTAL_TYPE
require(parent.Shared)
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