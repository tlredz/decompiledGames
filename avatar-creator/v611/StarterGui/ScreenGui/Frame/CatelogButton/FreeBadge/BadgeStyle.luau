local parent = script.Parent

local function style()
	parent.BackgroundColor3 = Color3.fromRGB(35, 142, 77)
	parent.TextColor3 = Color3.fromRGB(235, 255, 239)
	parent.TextSize = 12
end

task.defer(style)