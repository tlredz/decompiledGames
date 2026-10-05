local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
warn((`BitsUtil is deprecated, please use 'Utils' instead. Traceback: {debug.traceback()}`))
local object = setmetatable({}, {
	__index = require3(script.Parent.Utils)
})
object.Utilities = script.Parent.Utils.Utilities
return object