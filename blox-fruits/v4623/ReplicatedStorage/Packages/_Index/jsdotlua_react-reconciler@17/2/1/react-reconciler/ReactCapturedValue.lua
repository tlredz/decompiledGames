require(script.Parent:WaitForChild("ReactInternalTypes"))
local ReactFiberComponentStack = require(script.Parent:WaitForChild("ReactFiberComponentStack"))
local getStackByFiberInDevAndProd = ReactFiberComponentStack.getStackByFiberInDevAndProd
return {
	createCapturedValue = function(p, source)
		return {
			value = p,
			source = source,
			stack = getStackByFiberInDevAndProd(source)
		}
	end
}