require(script.Parent.Parent:WaitForChild("io"):WaitForChild("hsi"))
require(script.Parent.Parent:WaitForChild("Color"))
local _hsx = require(script.Parent:WaitForChild("_hsx"))

local function hsi(p, p2, p3: number)
	return _hsx(p, p2, p3, "hsi")
end

local parentModule = require(script.Parent)
parentModule.hsi = hsi
return hsi