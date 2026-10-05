local shared = require(script.Parent.Parent:WaitForChild("shared"))
local console = shared.console
local New = {}
require(script.Parent.Parent:WaitForChild("shared"))
require(script.Parent:WaitForChild("ReactInternalTypes"))
local ReactFiberHostConfig = require(script.Parent:WaitForChild("ReactFiberHostConfig"))
local isPrimaryRenderer = ReactFiberHostConfig.isPrimaryRenderer
local v = {}
local v2 = _G.__DEV__ and {} or nil

function New.markSourceAsDirty(p)
	table.insert(v, p)
end

function New.resetWorkInProgressVersions()
	for _, v3 in v do
		if isPrimaryRenderer then
			v3._workInProgressVersionPrimary = nil
		else
			v3._workInProgressVersionSecondary = nil
		end
	end

	table.clear(v)
end

function New:getWorkInProgressVersion()
	if isPrimaryRenderer then
		return self._workInProgressVersionPrimary
	end

	return self._workInProgressVersionSecondary
end

function New:setWorkInProgressVersion(p2)
	if isPrimaryRenderer then
		self._workInProgressVersionPrimary = p2
	else
		self._workInProgressVersionSecondary = p2
	end

	table.insert(v, self)
end

function New:warnAboutMultipleRenderersDEV()
	if _G.__DEV__ then
		if isPrimaryRenderer then
			if self._currentPrimaryRenderer == nil then
				self._currentPrimaryRenderer = v2
			elseif self._currentPrimaryRenderer ~= v2 then
				console.error("Detected multiple renderers concurrently rendering the same mutable source. This is currently unsupported.")
			end
		elseif self._currentSecondaryRenderer == nil then
			self._currentSecondaryRenderer = v2
		elseif self._currentSecondaryRenderer ~= v2 then
			console.error("Detected multiple renderers concurrently rendering the same mutable source. This is currently unsupported.")
		end
	end
end

function New:registerMutableSourceForHydration(p2)
	local _getVersion = p2._getVersion(p2._source)

	if self.mutableSourceEagerHydrationData == nil then
		self.mutableSourceEagerHydrationData = { p2, _getVersion }
	end
end

return New