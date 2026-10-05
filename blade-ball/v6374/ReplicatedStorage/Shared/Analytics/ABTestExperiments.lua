local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
game:GetService("RunService")
game:GetService("ReplicatedStorage")
require3(script.ABTestTypes)
local ABTestExperiments = {}

for _, moduleScript in script.Experiments:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local v = require3(moduleScript)
	local remoteConfig = v.RemoteConfig

	if #remoteConfig > 16 then
		warn((`RemoteConfig '{remoteConfig}' is longer than the maximum of 15 characters, skipping '{moduleScript.Name}' experiment.`))
	else
		ABTestExperiments[moduleScript.Name] = v
	end
end

return ABTestExperiments