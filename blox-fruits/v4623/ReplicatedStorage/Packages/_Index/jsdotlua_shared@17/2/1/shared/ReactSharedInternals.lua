local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local console = luaupolyfill.console

local function onlyInTestError(p: string)
	return function()
		console.error(p .. " is only available in tests, not in production")
	end
end

local ReactCurrentDispatcher = require(script:WaitForChild("ReactCurrentDispatcher"))
local ReactCurrentBatchConfig = require(script:WaitForChild("ReactCurrentBatchConfig"))
local ReactCurrentOwner = require(script:WaitForChild("ReactCurrentOwner"))
local ReactDebugCurrentFrame = require(script:WaitForChild("ReactDebugCurrentFrame"))
return {
	ReactCurrentDispatcher = ReactCurrentDispatcher,
	ReactCurrentBatchConfig = ReactCurrentBatchConfig,
	ReactCurrentOwner = ReactCurrentOwner,
	IsSomeRendererActing = require(script:WaitForChild("IsSomeRendererActing")),
	ReactDebugCurrentFrame = not _G.__DEV__ and {
		setExtraStackFrame = function(_: string?) end
	} or ReactDebugCurrentFrame
}