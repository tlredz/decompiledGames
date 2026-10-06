local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local doCleanup = require(parent.Memory.doCleanup)

local function legacyCleanup(p)
	External.logWarn("cleanupWasRenamed")
	return doCleanup(p)
end

return legacyCleanup