local util = game.ReplicatedStorage.Util
local LightningExplosion = require(util.LightningBolt.LightningExplosion)
local Sound = require(util.Sound)
return function(list)
	local v, v2, v3, v4 = unpack(list)
	local v5 = Sound:Play("Ope.Explosion.ElectricLoop", v, 20 * v3)
	Sound:Play("Ope.Explosion.Flare", v, 20 * v3)

	if v4 then
		Sound:Play(v4, v, 20 * v3)
	else
		Sound:Play("Ope.Explosion.Lightning", v, 20 * v3)
	end

	LightningExplosion(v, v2, v3)
	wait(1)
	Sound:FadeOut(v5, 1)
end