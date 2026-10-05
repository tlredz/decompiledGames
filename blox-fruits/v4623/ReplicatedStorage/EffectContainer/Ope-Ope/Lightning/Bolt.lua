local util = game.ReplicatedStorage.Util
local LightningBolt = require(util.LightningBolt)
local LightningSparks = require(util.LightningBolt.LightningSparks)
return function(list)
	local v, v2, v3, v4, thickness, v6, pulseLength, v8, v9 = unpack(list)
	Random.new()
	local v10 = LightningBolt.new(v, v2, v3, v4, v6, v8)
	v10.PulseLength = pulseLength
	v10.FadeLength = 0.5
	v10.PulseSpeed = 1 / pulseLength
	v10.MinThicknessMultiplier = 0.1
	v10.MaxThicknessMultiplier = 1
	v10.AnimationSpeed = 8
	v10.Thickness = thickness
	v10.AddTransparency = 0.1

	if v9 then
		LightningSparks.new(v10, v6)
	end
end