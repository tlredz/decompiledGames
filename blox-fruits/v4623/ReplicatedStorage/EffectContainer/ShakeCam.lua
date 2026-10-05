local createVector = vector.create
local Util = require(game.ReplicatedStorage.Util)
local cameraShaker = Util.CameraShaker
return function(list)
	if not list then
		cameraShaker:ShakeOnce(unpack({
			17,
			11,
			0.2,
			2,
			createVector(1, 1, 1),
			createVector(1, 1, 5)
		}))
	elseif list.Preset then
		cameraShaker:Shake(cameraShaker.Presets[list.Preset], list.Power)
	elseif list[1] then
		cameraShaker:ShakeOnce(unpack(list))
	else
		cameraShaker:ShakeOnce(
			list.Magnitude,
			list.Roughness,
			list.FadeIn,
			list.FadeOut,
			list.PosInfluence,
			list.RotInfluence,
			list.Power
		)
	end
end