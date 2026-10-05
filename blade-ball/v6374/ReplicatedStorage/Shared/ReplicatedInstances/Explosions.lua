local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3("../ReplicatedInstancesUtils")
local v2 = require3(ReplicatedStorage2.Common.StudioLogger)
local v3 = v2.warn()
v2.print()
RunService:IsServer()
RunService:IsClient()
local v4 = require3(script.Parent)

if RunService:IsServer() then
	for _, child in ServerStorage.Misc.Explosions:GetChildren() do
		local clone = table.clone(child:GetAttributes())
		clone.Name = child.Name
		v4:AddObjectToCollection("Explosions", child.Name, child, clone)
	end
end

local instanceReplicatorFor = v4.createInstanceReplicatorFor("Explosions")
local _ = instanceReplicatorFor.GetInstance

function instanceReplicatorFor:GetInstance(p: string)
	local instance = v.getInstance("Explosions", p)

	if not instance then
		instance = v.getInstance("Explosions", "Explosion Normal")
		v3("Explosion not found, using Base Explosion:", p)
	end

	return instance
end

function script.GetInstance.OnInvoke(p: string)
	return instanceReplicatorFor:GetInstance(p)
end

return instanceReplicatorFor