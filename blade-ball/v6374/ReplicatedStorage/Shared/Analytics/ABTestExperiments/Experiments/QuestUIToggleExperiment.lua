local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Shared.Analytics.ABTestExperiments.ABTestTypes)
require3(ReplicatedStorage2.ServerInfo)
return {
	RemoteConfig = "QuestUIToggle",
	Disabled = false,
	DefaultState = false,
	States = {
		[true] = {
			Client = function(_, _)
				require3(ReplicatedStorage2.Controllers.UI.QuestsController):SetToggleEnabled(true)
			end
		},
		[false] = {
			Client = function(_, _)
				require3(ReplicatedStorage2.Controllers.UI.QuestsController):SetToggleEnabled(false)
			end
		}
	}
}