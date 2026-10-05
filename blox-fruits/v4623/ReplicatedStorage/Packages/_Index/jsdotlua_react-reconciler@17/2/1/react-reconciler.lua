require(script:WaitForChild("ReactInternalTypes"))
require(script:WaitForChild("ReactRootTags"))

local function initialize(items)
	local ReactFiberHostConfig = require(script:WaitForChild("ReactFiberHostConfig"))

	for k, item in items do
		ReactFiberHostConfig[k] = item
	end

	return require(script:WaitForChild("ReactFiberReconciler"))
end

return initialize