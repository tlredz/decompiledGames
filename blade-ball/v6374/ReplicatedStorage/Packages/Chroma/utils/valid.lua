local Color = require(script.Parent.Parent:WaitForChild("Color"))

local function valid(...)
	return (pcall(Color.new, ...))
end

return valid