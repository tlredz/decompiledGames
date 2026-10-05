require(script.Parent.Parent:WaitForChild("io"):WaitForChild("hcg"))
require(script.Parent.Parent:WaitForChild("Color"))
local _hsx = require(script.Parent:WaitForChild("_hsx"))

local function hcg(p, p2, p3: number)
	return _hsx(p, p2, p3, "hcg")
end

local parentModule = require(script.Parent)
parentModule.hcg = hcg
return hcg