require(script.Parent.Parent:WaitForChild("shared"))

local function createMutableSource(source, getVersion)
	local v = {
		_getVersion = getVersion,
		_source = source,
		_workInProgressVersionPrimary = nil,
		_workInProgressVersionSecondary = nil
	}

	if _G.__DEV__ then
		v._currentPrimaryRenderer = nil
		v._currentSecondaryRenderer = nil
	end

	return v
end

return createMutableSource