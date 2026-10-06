local PlaySound = require(script.PlaySound)
local PlaySfx = {}

function PlaySfx.play(p)
	p.playBackSpeed = p.playBackSpeed or { 1, 1.5 }
	PlaySound(p)
end

function PlaySfx.stop(object)
	object:Stop()
end

PlaySfx.ref = script.sounds
return PlaySfx