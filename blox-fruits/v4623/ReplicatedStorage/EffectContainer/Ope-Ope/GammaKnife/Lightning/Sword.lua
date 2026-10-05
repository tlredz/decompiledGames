local util = game.ReplicatedStorage.Util
local LightningBolt = require(util.LightningBolt)
local LightningSparks = require(util.LightningBolt.LightningSparks)
return function(list)
	local v, v2, v3, v4, thickness, v6, v7, v8, v9 = unpack(list)
	local random = Random.new()
	local v10 = LightningBolt.new(v, v2, v3, v4, v6, v8)

	if v10 then
		v10.PulseLength = v7 / 2
		v10.FadeLength = v7 / 2
		v10.PulseSpeed = random:NextNumber(2, 4)
		v10.MinThicknessMultiplier = 0.1
		v10.MaxThicknessMultiplier = 1
		v10.AnimationSpeed = 8
		v10.Thickness = thickness
		v10.AddTransparency = 0.1

		if v9 then
			LightningSparks.new(v10, v6)
		end
	end
end