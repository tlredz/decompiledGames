local Yueliang = require(script:WaitForChild("Yueliang"))
local FiOne = require(script:WaitForChild("FiOne"))
return function(p, p2, p3, p4)
	local success, result = pcall(function()
		return FiOne(Yueliang(p, p2 or p3.script and p3.script:GetFullName()), p4, p3)
	end)
	return success and result, not success and result
end