local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SignalEvent = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalEvent)
local SignalFunction = require(ReplicatedStorage.Communication.ServerAndClient.Signals.SignalFunction)
local modulesByName = {}

for _, moduleScript in ipairs(script.Parent:QueryDescendants("ModuleScript")) do
	local name = moduleScript.Name
	local module = require(moduleScript)
	modulesByName[name] = module
end

local function fn(p, ...)
	if p == nil then
		return
	end

	if modulesByName[p] == nil then
		return
	else
		return (modulesByName[p](...))
	end
end

SignalEvent:Connect(fn)
SignalFunction:Connect(fn)
SignalEvent.ToServer("ClientReady")