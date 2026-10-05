require(script.Parent:WaitForChild("types"):WaitForChild("blend-types"))
require(script.Parent:WaitForChild("types"):WaitForChild("brewer-types"))
local Color = require(script.Parent:WaitForChild("Color"))
require(script.Parent:WaitForChild("types"):WaitForChild("cubehelix-types"))
require(script.Parent:WaitForChild("types"):WaitForChild("interpolation-mode"))
require(script.Parent:WaitForChild("types"):WaitForChild("scale-types"))
require(script.Parent:WaitForChild("utils"):WaitForChild("analyze"))
local self = setmetatable({}, {
	__call = function(p, ...)
		return p.Color.new(...)
	end
})
self.Color = Color
self.version = "2.4.2"
return self