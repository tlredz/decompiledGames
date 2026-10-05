return {
	BaseScreenGui = require(script:WaitForChild("Container"):WaitForChild("BaseScreenGui")),
	ScreenGui = require(script:WaitForChild("Container"):WaitForChild("ScreenGui")),
	ScreenGui2D = require(script:WaitForChild("Container"):WaitForChild("ScreenGui2D")),
	ScreenGui3D = require(script:WaitForChild("Container"):WaitForChild("ScreenGui3D")),
	PartUtility = require(script:WaitForChild("Utility"):WaitForChild("PartUtility")),
	GetResource = function(_, value: string)
		local script2 = script

		for _, v in string.split(value, ".") do
			script2 = script2[v]
		end

		local module = require(script2)
		return module
	end
}