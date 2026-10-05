local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
require3(ReplicatedStorage2.Packages.Net)
local v = require3(ReplicatedStorage2.Common.RewardInfo)
return {
	v.createSwordReward("Sparkler Saber"),
	v.createSwordReward("Celestial Saber"),
	v.createSwordReward("Glittering Horizon"),
	v.createGachaSpinsReward(1, "New Year Spins"),
	v.createExplosionReward("Radiant Glow"),
	v.createEmoteReward("Balloon Pop"),
	v.createSwordReward("New Year's Lance"),
	(v.createEmoteReward("New Year's Lance Emote"))
}