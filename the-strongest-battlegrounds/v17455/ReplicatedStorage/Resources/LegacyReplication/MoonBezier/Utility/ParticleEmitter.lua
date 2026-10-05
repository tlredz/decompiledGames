local ParticleEmitter = {}

function ParticleEmitter.Emit(instance)
	task.spawn(function()
		for _, child in ipairs(instance:GetChildren()) do
			if child:IsA("ParticleEmitter") then
				local emitDuration = child:GetAttribute("EmitDuration")

				if emitDuration and emitDuration > 0 then
					child.Enabled = true
					local v = child
					task.delay(emitDuration, function()
						v.Enabled = false
					end)
				else
					local emitCount = child:GetAttribute("EmitCount")

					if emitCount then
						local emitDelay = child:GetAttribute("EmitDelay") or 0
						local v = child
						local v2 = emitCount
						task.delay(emitDelay, function()
							v:Emit(v2)
						end)
					end
				end
			elseif child:IsA("Attachment") or child:IsA("Folder") or child:IsA("Model") or child:IsA("BasePart") then
				ParticleEmitter.Emit(child)
			end
		end
	end)
end

return ParticleEmitter