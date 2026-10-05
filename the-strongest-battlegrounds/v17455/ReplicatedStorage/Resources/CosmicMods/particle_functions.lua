local _ = {
	"ParticleEmitter",
	"Beam",
	"Trail",
	"PointLight",
	"SpotLight"
}
local ParticleFunctions = {}

function ParticleFunctions.SetTimeScale(descendants, timeScale: number)
	if typeof(descendants) == "Instance" then
		descendants = descendants:GetDescendants()
	end

	for _, emitter in descendants do
		if emitter:IsA("ParticleEmitter") then
			emitter.TimeScale = timeScale
		end
	end
end

function ParticleFunctions.Enable(folder, flag: boolean, flag2: boolean, flag3: boolean)
	if not folder then
		warn("⚠️ VFXModule.EffectToggle: EffectPart is nil!")
	elseif flag3 then
		for _, beam in pairs(folder:GetDescendants()) do
			if not beam:IsA("Beam") or flag2 then
				continue
			end

			beam.Enabled = flag or false
		end
	else
		for _, effect in pairs(folder:GetDescendants()) do
			if not (effect:IsA("ParticleEmitter") or effect:IsA("Beam") or effect:IsA("Trail")) then
				continue
			end

			effect.Enabled = flag or false
		end
	end
end

function ParticleFunctions:Emit(p: number, duration: number)
	if p and p > 0 then
		for _ = 1, p do
			for _, emitter in pairs(self:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				local emitDelay = emitter:GetAttribute("EmitDelay")
				local emitCount = emitter:GetAttribute("EmitCount")
				local emitDuration = emitter:GetAttribute("EmitDuration")

				if emitDuration then
					emitter.Enabled = true
					local v = emitter
					task.delay(emitDuration, function()
						v.Enabled = false
					end)
				end

				if emitDelay then
					local v = emitCount
					local v2 = emitter
					task.delay(emitDelay, function()
						if v and v > 0 then
							v2:Emit(v)
						end
					end)
				elseif emitCount and emitCount > 0 then
					emitter:Emit(emitCount)
				end
			end

			task.wait(duration)
		end
	else
		for _, emitter in pairs(self:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local emitDelay = emitter:GetAttribute("EmitDelay")
			local emitCount = emitter:GetAttribute("EmitCount")
			local emitDuration = emitter:GetAttribute("EmitDuration")

			if emitDuration then
				emitter.Enabled = true
				local v = emitter
				task.delay(emitDuration, function()
					v.Enabled = false
				end)
			end

			if emitDelay then
				local v = emitCount
				local v2 = emitter
				task.delay(emitDelay, function()
					if v and v > 0 then
						v2:Emit(v)
					end
				end)
			elseif emitCount and emitCount > 0 then
				emitter:Emit(emitCount)
			end
		end
	end
end

return ParticleFunctions