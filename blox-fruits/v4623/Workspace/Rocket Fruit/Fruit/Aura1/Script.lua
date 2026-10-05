local parent = script.Parent.Parent
local parent2 = script.Parent
game:GetService("TweenService")
local animation = parent.Animation
local track = parent.AnimationController.Animator:LoadAnimation(animation)
track:Play()
local descendants = parent2:GetDescendants()

for _, emitter in pairs(descendants) do
	if emitter:IsA("ParticleEmitter") then
		emitter.Enabled = false
	end
end

track:GetMarkerReachedSignal("JUMP"):Connect(function()
	if not parent:IsDescendantOf(workspace) then
		return
	end

	for _, emitter in pairs(descendants) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Enabled = true
		local v = emitter
		task.spawn(function()
			task.wait(1)
			v.Enabled = false
		end)
	end
end)