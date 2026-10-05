game:GetService("RunService")
game:GetService("ReplicatedStorage")
require(script.ABTestTypes)
local ABTestExperiments = {}

for _, moduleScript in script.Experiments:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)
	local remoteConfig = module.RemoteConfig

	if #remoteConfig > 16 then
		warn((`RemoteConfig '{remoteConfig}' is longer than the maximum of 15 characters, skipping '{moduleScript.Name}' experiment.`))
	else
		ABTestExperiments[moduleScript.Name] = module
	end
end

return ABTestExperiments