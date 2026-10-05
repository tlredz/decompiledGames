local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Types.Analytics)
local v = require3(ReplicatedStorage2.Controllers.UI.NewShowcaseController)
return {
	RemoteConfig = "NewShowcase",
	DefaultValue = "Legacy",
	Disabled = false,
	TestConfigValues = {
		Legacy = 100,
		New = 0
	},
	Configs = {
		Legacy = function()
			v:SetExperimentVariant("Legacy")
		end,
		New = function()
			v:SetExperimentVariant("New")
		end
	}
}