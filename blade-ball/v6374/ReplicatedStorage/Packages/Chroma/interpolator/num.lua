require(script.Parent.Parent:WaitForChild("io"):WaitForChild("num"))
local Color = require(script.Parent.Parent:WaitForChild("Color"))

local function num(object, object2, p: number)
	local num2 = object:num()
	local num3 = object2:num()
	return Color.new(num2 + p * (num3 - num2), "num")
end

local parentModule = require(script.Parent)
parentModule.num = num
return num