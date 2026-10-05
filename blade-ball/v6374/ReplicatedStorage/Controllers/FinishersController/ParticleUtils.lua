local v = {
	Beam = true,
	ParticleEmitter = true
}
return table.freeze({
	emitParticles = function(items)
		for _, folder in items do
			for _, emitter in folder:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local emitCount = emitter:GetAttribute("EmitCount")

				if not (emitCount and emitCount ~= 0) then
					continue
				end

				local emitDelay = emitter:GetAttribute("EmitDelay")

				if emitDelay and emitDelay ~= 0 then
					task.delay(emitDelay, emitter.Emit, emitter, emitCount)
				else
					emitter:Emit(emitCount)
				end
			end
		end
	end,
	disableParticles = function(items)
		for _, folder in items do
			for _, descendant in folder:GetDescendants() do
				if v[descendant.ClassName] then
					descendant.Enabled = false
				end
			end
		end
	end
})