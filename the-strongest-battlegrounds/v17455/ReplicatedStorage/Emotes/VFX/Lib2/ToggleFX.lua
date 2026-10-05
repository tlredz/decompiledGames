return function(folder, enabled)
	for _, emitter in folder:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = enabled
		end
	end
end