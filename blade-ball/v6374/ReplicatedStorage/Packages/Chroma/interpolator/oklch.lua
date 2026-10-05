require(script.Parent.Parent:WaitForChild("io"):WaitForChild("lch"))
require(script.Parent.Parent:WaitForChild("Color"))
local _hsx = require(script.Parent:WaitForChild("_hsx"))

local function oklch(p, p2, p3: number)
	return _hsx(p, p2, p3, "oklch")
end

local parentModule = require(script.Parent)
parentModule.oklch = oklch
return oklch