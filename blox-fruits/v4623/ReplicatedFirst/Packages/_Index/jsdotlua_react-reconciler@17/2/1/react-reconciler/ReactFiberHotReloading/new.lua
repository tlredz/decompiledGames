require(script.Parent.Parent:WaitForChild("shared"))
require(script.Parent:WaitForChild("ReactInternalTypes"))
local shared = require(script.Parent.Parent:WaitForChild("shared"))
local _ = shared.ReactSymbols.REACT_FORWARD_REF_TYPE
local New = {}

function New.resolveFunctionForHotReloading(p)
	if _G.__DEV__ then
	end

	return p
end

function New.resolveClassForHotReloading(p)
	if _G.__DEV__ then
	end

	return p
end

function New.resolveForwardRefForHotReloading(p)
	if _G.__DEV__ then
	end

	return p
end

function New.isCompatibleFamilyForHotReloading(_, _)
	warn("isCompatibleFamilyForHotReloading is stubbed (returns false)")
	return false
end

function New.markFailedErrorBoundaryForHotReloading(_)
	if _G.__DEV__ then
	end
end

return New