local luaupolyfill = require(script.Parent.Parent:WaitForChild("luau-polyfill"))
local console = luaupolyfill.console
local consoleWithStackDev = require(script.Parent:WaitForChild("consoleWithStackDev"))

if _G.__DEV__ then
	return (setmetatable({
		warn = consoleWithStackDev.warn,
		error = consoleWithStackDev.error
	}, {
		__index = console
	}))
end

return console