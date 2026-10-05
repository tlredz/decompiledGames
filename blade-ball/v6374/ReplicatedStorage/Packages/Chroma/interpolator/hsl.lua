require(script.Parent.Parent:WaitForChild("io"):WaitForChild("hsl"))
require(script.Parent.Parent:WaitForChild("Color"))
local _hsx = require(script.Parent:WaitForChild("_hsx"))

local function hsl(p, p2, p3: number)
	return _hsx(p, p2, p3, "hsl")
end

local parentModule = require(script.Parent)
parentModule.hsl = hsl
return hsl