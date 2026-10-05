local Sound = require(game.ReplicatedStorage.Util.Sound)
local frozen = table.freeze({
	"DesertBonusMoments.BF_DesertBonus_Drink_Cactus_Juice_01",
	"DesertBonusMoments.BF_DesertBonus_Drink_Cactus_Juice_03",
	"DesertBonusMoments.BF_DesertBonus_Drink_Cactus_Juice_04"
})
return function(p)
	if p.Stage ~= "Woozy" then
		Sound:Play(frozen[math.random(1, #frozen)])
		return
	end

	local v = Sound:Play("DesertBonusMoments.BF_DesertBonus_Woozy_Cactus_Juice_Drank_01")
	v.Looped = true
	task.delay(p.Duration or 0, function()
		Sound:FadeOut(v, 2)
	end)
end