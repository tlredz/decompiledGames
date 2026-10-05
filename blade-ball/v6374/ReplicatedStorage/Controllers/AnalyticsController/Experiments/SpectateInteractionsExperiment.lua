local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Types.Analytics)
local v = require3(ReplicatedStorage2.Controllers.UI.SpectateController)
local v2 = require3(ReplicatedStorage2.ServerInfo)
return {
	RemoteConfig = "SpectateInteractionsEnabled",
	Disabled = true,
	DefaultValue = false,
	TestConfigValues = {
		[false] = 50,
		[true] = 50
	},
	Configs = {
		[true] = function(_)
			if v2.isNewPlayerLobbyServer() or v2.isTutorialServer() then
				v:SetOptionsVisibility(false)
			else
				v:SetOptionsVisibility(true)
			end
		end,
		[false] = function(_)
			v:SetOptionsVisibility(false)
		end
	}
}