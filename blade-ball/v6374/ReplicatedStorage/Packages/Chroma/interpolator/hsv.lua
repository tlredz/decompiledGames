require(script.Parent.Parent:WaitForChild("io"):WaitForChild("hsv"))
require(script.Parent.Parent:WaitForChild("Color"))
local _hsx = require(script.Parent:WaitForChild("_hsx"))

local function hsv(p, p2, p3: number)
	return _hsx(p, p2, p3, "hsv")
end

local parentModule = require(script.Parent)
parentModule.hsv = hsv
return hsv