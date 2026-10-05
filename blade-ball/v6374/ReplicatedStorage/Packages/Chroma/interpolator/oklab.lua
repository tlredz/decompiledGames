require(script.Parent.Parent:WaitForChild("io"):WaitForChild("oklab"))
local Color = require(script.Parent.Parent:WaitForChild("Color"))

local function oklab(object, object2, p: number)
	local oklab2 = object:oklab()
	local oklab3 = object2:oklab()
	return Color.new(
		oklab2[1] + p * (oklab3[1] - oklab2[1]),
		oklab2[2] + p * (oklab3[2] - oklab2[2]),
		oklab2[3] + p * (oklab3[3] - oklab2[3]),
		"oklab"
	)
end

local parentModule = require(script.Parent)
parentModule.oklab = oklab
return oklab