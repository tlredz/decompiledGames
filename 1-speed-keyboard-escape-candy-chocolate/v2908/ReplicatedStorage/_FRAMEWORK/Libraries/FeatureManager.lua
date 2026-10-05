local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local clones = {}
local v = "InternalStart"

local function requireFeatureModules(object)
	if object == nil then
		return
	end

	for _, moduleScript in object:QueryDescendants("ModuleScript") do
		if moduleScript:IsA("ModuleScript") then
			require(moduleScript)
		end
	end
end

local FeatureManager = {}

function FeatureManager.RegisterFeature(name: string, p)
	local clone = table.clone(p)
	clone.Name = name
	clone.Priority = p.Priority or 0
	table.insert(clones, clone)
end

function FeatureManager.RetrieveAllFeatures()
	requireFeatureModules(ReplicatedStorage._FRAMEWORK:FindFirstChild("Features"))

	if RunService:IsServer() then
		local _FRAMEWORK = ServerScriptService:FindFirstChild("_FRAMEWORK")
		local v2

		if _FRAMEWORK then
			v2 = _FRAMEWORK:FindFirstChild("ServerFeatures")
		end

		requireFeatureModules(v2)
	end

	table.sort(clones, function(a, b)
		local priority = a.Priority
		local priority2 = b.Priority

		if priority == priority2 then
			return a.Name < b.Name
		end

		return priority < priority2
	end)
	return table.clone(clones)
end

function FeatureManager.SetFeatureStage(p: string)
	v = p
end

function FeatureManager.GetFeatureStage()
	return v
end

return FeatureManager