debug.setmemorycategory(script.Name)
local value = script.target.Value
local module = require(value)

if typeof(module) == "table" then
	if script:GetAttribute("doStart") and typeof(module.Start) == "function" then
		module:Start()
	elseif script:GetAttribute("doInit") and typeof(module.init) == "function" then
		module.init()
	end
end