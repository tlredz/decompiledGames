local emittersByEmitter = {}

for _, emitter in pairs(script.Parent:GetDescendants()) do
	if emitter:IsA("ParticleEmitter") then
		emittersByEmitter[emitter] = emitter
	end
end

while true do
	task.wait(0.5)
	local v = -(time() * 25) % 360

	for _, v2 in pairs(emittersByEmitter) do
		v2:Clear()
		v2:Emit(1)
		v2.Rotation = NumberRange.new(v, v)
	end
end