local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3("../ReplicatedInstancesUtils")
RunService:IsServer()
RunService:IsClient()
local v2 = require3(ReplicatedStorage2.Common.StudioLogger)
v2.warn()
v2.print()
local v3 = require3(script.Parent)

if RunService:IsServer() then
	for _, child in ServerStorage.Misc.EmoteVFX:GetChildren() do
		local clone = table.clone(child:GetAttributes())
		clone.Name = child.Name
		v3:AddObjectToCollection("EmoteVFX", child.Name, child, clone)
	end
end

local instanceReplicatorFor = v3.createInstanceReplicatorFor("EmoteVFX")

function instanceReplicatorFor:GetInstance(p: string)
	return (v.getInstance("EmoteVFX", p))
end

function instanceReplicatorFor:GetEmoteVFX(p: string)
	return self:GetCollection()[p]
end

function script.GetEmoteVFX.OnInvoke(p: string)
	return instanceReplicatorFor:GetEmoteVFX(p)
end

function script.GetInstance.OnInvoke(p: string)
	return instanceReplicatorFor:GetInstance(p)
end

return instanceReplicatorFor