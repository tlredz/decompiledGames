local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local v = require3("@game/ReplicatedStorage/Common/RewardInfo")
local startTimestamp

if require3("@game/ReplicatedStorage/ServerInfo").isTestGame() then
	startTimestamp = DateTime.fromUniversalTime(2026, 5, 26, 17).UnixTimestamp
else
	startTimestamp = DateTime.fromUniversalTime(2026, 5, 30, 17).UnixTimestamp
end

return {
	DreamySet1 = {
		name = "Dreamy Set",
		startTimestamp = startTimestamp,
		endTimestamp = DateTime.fromUniversalTime(2026, 6, 6, 17).UnixTimestamp,
		rewards = {
			v.createSwordReward("Pillow"),
			v.createEmoteReward("Emote1221"),
			(v.createExplosionReward("Featherplosion"))
		},
		options = {
			{
				product = 3573514469,
				giftProduct = 3574024187,
				amount = 500
			},
			{
				product = 3573514471,
				giftProduct = 3574024186,
				amount = 1500
			},
			{
				product = 3573514472,
				giftProduct = 3574024188,
				amount = 3000
			}
		}
	}
}