local NexusInstance = require(script.Parent.Parent:WaitForChild("Packages"):WaitForChild("NexusInstance"))
local BaseScreenGui = require(script.Parent:WaitForChild("BaseScreenGui"))
local v = {
	ClassName = "ScreenGui2D"
}
v.__index = v
setmetatable(v, BaseScreenGui)

function v.__new(p)
	BaseScreenGui.__new(p, Instance.new("ScreenGui"))
end

function v.IsA(p, p2: string)
	return BaseScreenGui.IsA(p, p2) or p2 == "ScreenGui2D"
end

return (NexusInstance.ToInstance(v))