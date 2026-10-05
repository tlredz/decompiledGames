local parent = script.Parent.Parent
local ReactGlobals = require(parent.ReactGlobals)
require(parent.Shared)

local function createMutableSource(source, getVersion)
	local v = {
		_getVersion = getVersion,
		_source = source,
		_workInProgressVersionPrimary = nil,
		_workInProgressVersionSecondary = nil
	}

	if ReactGlobals.__DEV__ then
		v._currentPrimaryRenderer = nil
		v._currentSecondaryRenderer = nil
	end

	return v
end

return createMutableSource