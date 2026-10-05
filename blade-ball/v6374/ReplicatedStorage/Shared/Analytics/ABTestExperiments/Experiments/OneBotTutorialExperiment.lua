local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Shared.Analytics.ABTestExperiments.ABTestTypes)
local v = require3(ReplicatedStorage2.ServerInfo)
return {
	RemoteConfig = "OneBotTutorial",
	Disabled = false,
	DefaultState = false,
	States = {
		[true] = {
			Server = function(_, _)
				local ServerScriptService = game:GetService("ServerScriptService")
				local v2 = require3(ServerScriptService.Game.Services.TutorialService)

				if v.isTutorialServer() and #workspace.Alive:GetChildren() == 0 then
					workspace:SetAttribute("AB_IsOneBotTutorial", true)
					v2:SetBotCount(1)
				end
			end
		}
	}
}