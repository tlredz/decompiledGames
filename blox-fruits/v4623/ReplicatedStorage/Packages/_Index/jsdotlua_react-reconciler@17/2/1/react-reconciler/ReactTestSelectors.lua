require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local ReactFiberHostConfig = require(script.Parent:WaitForChild("ReactFiberHostConfig"))
local supportsTestSelectors = ReactFiberHostConfig.supportsTestSelectors
local v = {}
return {
	onCommitRoot = function()
		if supportsTestSelectors then
			for _, v2 in v do
				v2()
			end
		end
	end
}