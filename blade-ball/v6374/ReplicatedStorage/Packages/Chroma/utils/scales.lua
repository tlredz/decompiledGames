local chroma = require(script.Parent.Parent:WaitForChild("chroma"))
require(script.Parent.Parent:WaitForChild("io"):WaitForChild("hsl"))
local scale = require(script.Parent.Parent:WaitForChild("generator"):WaitForChild("scale"))
local Scales = {}

function Scales.cool()
	return scale({ chroma.hsl(180, 1, 0.9), chroma.hsl(250, 0.7, 0.4) })
end

function Scales.hot()
	return scale({
		"#000",
		"#f00",
		"#ff0",
		"#fff"
	}).mode("rgb")
end

return Scales