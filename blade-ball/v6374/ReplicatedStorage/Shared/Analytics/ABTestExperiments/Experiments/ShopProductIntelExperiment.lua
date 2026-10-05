local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Shared.Analytics.ABTestExperiments.ABTestTypes)
return {
	RemoteConfig = "ShopProdIntel",
	Disabled = false,
	DefaultState = require3(ReplicatedStorage2.ServerInfo).isTestGame(),
	States = {
		[true] = {
			Server = function(instance, _)
				instance:SetAttribute("ShopProductIntelligence", true)
			end,
			Client = function(instance, _)
				instance:SetAttribute("ShopProductIntelligence", true)
			end
		}
	}
}