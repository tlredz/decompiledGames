local RunService = game:GetService("RunService")
local Util = require(script.Shared:WaitForChild("Util"))

if RunService:IsServer() == false then
	error("Cmdr server module is somehow running on a client!")
end

local object = setmetatable({
	ReplicatedRoot = nil,
	RemoteFunction = nil,
	RemoteEvent = nil,
	Util = Util,
	DefaultCommandsFolder = script.BuiltInCommands
}, {
	__index = function(p, p2)
		local v = p.Registry[p2]

		if v and type(v) == "function" then
			return function(_, ...)
				return v(p.Registry, ...)
			end
		end
	end
})
local Registry = require(script.Shared.Registry)
object.Registry = Registry(object)
local Dispatcher = require(script.Shared.Dispatcher)
object.Dispatcher = Dispatcher(object)
local Initialize = require(script.Initialize)
Initialize(object)

object.RemoteFunction.OnServerInvoke = function(p, list, p2)
	if #list > 500000 then
		return "Input too long"
	end

	return object.Dispatcher:EvaluateAndRun(list, p, p2)
end

return object