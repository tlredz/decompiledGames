local RunService = game:GetService("RunService")
local parentModule = require(script.Parent.Parent)
local Config = require(script.Config)
local ServerRuntime = require(script.ServerRuntime)
local ClientRuntime = require(script.ClientRuntime)
parentModule.register(script.Name, {
	displayName = "Lighting Event",
	slot = "event",
	needsDuration = true,
	defaultDurationSeconds = Config.defaultDurationSeconds,
	maxDurationSeconds = Config.maxDurationSeconds,
	load = function(p)
		if RunService:IsServer() then
			return (ServerRuntime.create(p))
		end

		return (ClientRuntime.create(p))
	end
})
return {}