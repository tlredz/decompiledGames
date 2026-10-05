local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.packages.Signal)
local modulesByConfigName = {}
local ApplyOverrideConfig = {}

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)
	modulesByConfigName[module.ConfigName] = module
end

ApplyOverrideConfig.ConfigChanged = Signal.new()

function ApplyOverrideConfig.Apply(_, p: string, p2)
	local v = modulesByConfigName[p]

	if not v then
		warn((`Received update for unknown config "{p}"`))
		return
	end

	if v.ApplyEnvironment == "Server" and not RunService:IsServer() or v.ApplyEnvironment == "Client" and not RunService:IsClient() then
		return
	end

	modulesByConfigName[p].Apply(p2)
	ApplyOverrideConfig.ConfigChanged:FireDeferred(p, p2)
end

function ApplyOverrideConfig.GetConfigNames(_)
	local result = {}

	for k in modulesByConfigName do
		table.insert(result, k)
	end

	return result
end

function ApplyOverrideConfig.GetEnvironment(_, p: string)
	return modulesByConfigName[p].ApplyEnvironment
end

return ApplyOverrideConfig