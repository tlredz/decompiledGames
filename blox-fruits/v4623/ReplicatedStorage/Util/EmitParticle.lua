return function(emitter)
	if not emitter:IsA("ParticleEmitter") then
		return
	end

	task.delay(emitter:GetAttribute("EmitDelay") or 0, function()
		local emitDuration = emitter:GetAttribute("EmitDuration")
		local emitCount = emitter:GetAttribute("EmitCount")

		if not emitDuration then
			emitter:Emit(emitCount or 1)
			return
		end

		emitter:Emit(emitCount or 0)
		local _ = emitter.Enabled
		emitter.Enabled = true
		task.wait(emitDuration)
		emitter.Enabled = false
	end)
end