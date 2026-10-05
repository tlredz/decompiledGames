require(script.Parent.Parent:WaitForChild("io"):WaitForChild("lch"))
require(script.Parent.Parent:WaitForChild("Color"))
local _hsx = require(script.Parent:WaitForChild("_hsx"))

local function lch(p, p2, p3: number)
	return _hsx(p, p2, p3, "lch")
end

local parentModule = require(script.Parent)
parentModule.lch = lch
local parentModule2 = require(script.Parent)
parentModule2.hcl = lch
return lch