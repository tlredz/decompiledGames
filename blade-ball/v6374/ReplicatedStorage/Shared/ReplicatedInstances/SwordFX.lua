local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local v = require3("../ReplicatedInstancesUtils")
RunService:IsServer()
RunService:IsClient()
local v2 = require3(script.Parent)

if RunService:IsServer() then
	for _, child in ServerStorage.Misc.SwordFX:GetChildren() do
		local clone = table.clone(child:GetAttributes())
		clone.Name = child.Name
		v2:AddObjectToCollection("SwordFX", child.Name, child, clone)
	end
end

local instanceReplicatorFor = v2.createInstanceReplicatorFor("SwordFX")

function instanceReplicatorFor:GetInstance(p: string)
	return v.getInstance("SwordFX", p)
end

function script.GetInstance.OnInvoke(p: string)
	return instanceReplicatorFor:GetInstance(p)
end

return instanceReplicatorFor