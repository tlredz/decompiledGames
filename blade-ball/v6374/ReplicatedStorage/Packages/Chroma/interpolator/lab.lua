require(script.Parent.Parent:WaitForChild("io"):WaitForChild("lab"))
local Color = require(script.Parent.Parent:WaitForChild("Color"))

local function lab(object, object2, p: number)
	local lab2 = object:lab()
	local lab3 = object2:lab()
	return Color.new(
		lab2[1] + p * (lab3[1] - lab2[1]),
		lab2[2] + p * (lab3[2] - lab2[2]),
		lab2[3] + p * (lab3[3] - lab2[3]),
		"lab"
	)
end

local parentModule = require(script.Parent)
parentModule.lab = lab
return lab