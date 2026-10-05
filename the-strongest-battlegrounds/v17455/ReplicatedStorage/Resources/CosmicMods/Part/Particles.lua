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
				if effect:IsA("Beam") then
					local v = effect
					task.delay(effect:GetAttribute("EmitDelay") or 0.001, function()
						v.Enabled = true
						task.wait(v:GetAttribute("EmitDuration"))
						v.Enabled = false
					end)
				end

				if not effect:IsA("ParticleEmitter") then
					continue
				end

				if effect:GetAttribute("EmitCount") then
					local v = effect
					task.delay(effect:GetAttribute("EmitDelay") or 0.001, function()
						v:Emit(v:GetAttribute("EmitCount"))
					end)
				end

				if not effect:GetAttribute("EmitDuration") then
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
	end
}

function Particles.EnableEmitChildrenAndRepeatForAttachments(instance)
	task.spawn(function()
		for _, child in instance:GetChildren() do
			if child:IsA("Beam") then
				local v = child
				task.delay(child:GetAttribute("EmitDelay") or 0.001, function()
					v.Enabled = true
					task.wait(v:GetAttribute("EmitDuration"))
					v.Enabled = false
				end)
			end

			if child:IsA("ParticleEmitter") then
				if child:GetAttribute("EmitCount") then
					local v = child
					task.delay(child:GetAttribute("EmitDelay") or 0.001, function()
						v:Emit(v:GetAttribute("EmitCount"))
					end)
				end

				if child:GetAttribute("EmitDuration") then
					local v = child
					task.delay(child:GetAttribute("EmitDelay") or 0.001, function()
						v.Enabled = true
						task.wait(v:GetAttribute("EmitDuration"))
						v.Enabled = false
					end)
				end
			end

			if child:IsA("Attachment") then
				Particles.EnableEmitChildrenAndRepeatForAttachments(child)
			end
		end
	end)
end

function Particles:EnableEmitSingle()
	task.spawn(function()
		if self:IsA("ParticleEmitter") then
			if self:IsA("Beam") then
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
		end
	end)
end

return Particles