local RunService = game:GetService("RunService")

local function noop() end

local Logger = {
	printStudio = print,
	printLive = print,
	print = print,
	warnStudio = warn,
	warnLive = warn,
	warn = warn
}

if RunService:IsStudio() then
	Logger.printLive = noop
	Logger.warnLive = noop
else
	Logger.printStudio = noop
	Logger.warnStudio = noop
end

return Logger