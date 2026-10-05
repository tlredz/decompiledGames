local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
return {
	Icon = "rbxassetid://17106475817",
	RewardInfo = require3(ReplicatedStorage2.Common.RewardInfo).createSwordReward("Axe of Balance"),
	Function = function(p)
		return require3(game.ServerScriptService.Game.Server.AwardService):AddSwordSkin(p, "Axe of Balance", false)
	end,
	Arguments = {}
}