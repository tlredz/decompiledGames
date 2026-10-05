local CameraShake = require(script.CameraShake)
local CameraShakeOffset = require(script.Parent.CameraShakeOffset)
local v = true
local v2 = CameraShake.new(Enum.RenderPriority.Camera.Value + 2, function(p)
	if not v then
		return
	end

	CameraShakeOffset.apply(p)
end)
v2:Start()
local CameraShake_2 = {}

function CameraShake_2.SetEnabled(_, flag: boolean)
	v = flag and true or false
end

function CameraShake_2:Shake(p: string)
	v2:Shake(CameraShake.Presets[p])
end

function CameraShake_2:ShakeOnce(p, p2, p3, p4, p5, p6)
	v2:ShakeOnce(p, p2, p3, p4, p5, p6)
end

function CameraShake_2:ShakeSustain(p: string)
	v2:ShakeSustain(CameraShake.Presets[p])
end

function CameraShake_2:StopSustained(p: number)
	v2:StopSustained(p)
end

return CameraShake_2