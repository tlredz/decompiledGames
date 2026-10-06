local Particles = {
	Emit = function(self)
		for _, emitter in self:GetDescendants() do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			local v = emitter
			task.delay(emitter:GetAttribute("EmitDelay") or 0.001, function()
				v:Emit(v:GetAttribute("EmitCount"))
			end)
		end
	end,
	EnableEmit = function(folder)
		task.spawn(function()
			for _, effect in folder:GetDescendants() do
				if effect:IsA("ParticleEmitter") then
					if effect:GetAttribute("EmitCount") then
						local v = effect
						task.delay(effect:GetAttribute("EmitDelay") or 0.001, function()
							v:Emit(v:GetAttribute("EmitCount"))
						end)
					end

					if effect:GetAttribute("EmitDuration") then
						local v = effect
						task.delay(effect:GetAttribute("EmitDelay") or 0.001, function()
							v.Enabled = true
							task.wait(v:GetAttribute("EmitDuration"))
							v.Enabled = false
						end)
					end
				end

				if not (effect:IsA("Trail") and effect:GetAttribute("EmitDuration")) then
					continue
				end

				local v = effect
				task.delay(effect:GetAttribute("EmitDelay") or 0.001, function()
					v.Enabled = true
					task.wait(v:GetAttribute("EmitDuration"))
					v.Enabled = false
				end)
			end
		end)
	end,
	EmitTrail = function(instance)
		if instance:GetAttribute("EmitDuration") then
			task.delay(instance:GetAttribute("EmitDelay") or 0.001, function()
				instance.Enabled = true
				task.wait(instance:GetAttribute("EmitDuration"))
				instance.Enabled = false
			end)
		end
	end,
	EnableEmitSingle = function(self)
		task.spawn(function()
			if self:IsA("Trail") and self:GetAttribute("EmitDuration") then
				task.delay(self:GetAttribute("EmitDelay") or 0.001, function()
					self.Enabled = true
					task.wait(self:GetAttribute("EmitDuration"))
					self.Enabled = false
				end)
			end

			if self:IsA("ParticleEmitter") then
				if self:GetAttribute("EmitCount") then
					task.delay(self:GetAttribute("EmitDelay") or 0.001, function()
						self:Emit(self:GetAttribute("EmitCount"))
					end)
				end

				if self:GetAttribute("EmitDuration") then
					task.delay(self:GetAttribute("EmitDelay") or 0.001, function()
						self.Enabled = true
						task.wait(self:GetAttribute("EmitDuration"))
						self.Enabled = false
					end)
				end
			end
		end)
	end
}

function Particles.EnableEmitChildrenAndRepeatForAttachments(instance)
	task.spawn(function()
		for _, attachment in instance:GetChildren() do
			Particles.EnableEmitSingle(attachment)

			if attachment:IsA("Attachment") then
				Particles.EnableEmitChildrenAndRepeatForAttachments(attachment)
			end
		end
	end)
end

return Particles