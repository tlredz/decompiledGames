local Debris = game:GetService("Debris")
game:GetService("ContentProvider")
local Effects = {
	PlayParticle = function(self, instance)
		task.spawn(function()
			local emitCount = instance:GetAttribute("EmitCount") or 1
			local emitDelay = instance:GetAttribute("EmitDelay") or 0
			local emitDuration = instance:GetAttribute("EmitDuration") or 0

			if emitDelay ~= 0 then
				task.wait(emitDelay)
			end

			instance:Emit(emitCount)

			if emitDuration ~= 0 then
				instance:Emit(emitCount)
				instance.Enabled = true
				task.wait(emitDuration)
				instance.Enabled = false
			end
		end)
	end
}

function Effects:PlayThenCleanup(instance, options)
	local shouldCleanup = (options or {}).ShouldCleanup or false
	task.spawn(function()
		if instance:IsA("Sound") or instance:IsA("AnimationTrack") then
			local delay = instance:GetAttribute("Delay") or 0

			if delay ~= 0 then
				task.wait(delay)
			end

			instance:Play()

			if instance.Looped == true then
				return
			end

			local timeLength = nil

			if instance:IsA("Sound") then
				timeLength = instance.TimeLength
			elseif instance:IsA("AnimationTrack") then
				timeLength = instance.Length
			end

			task.wait(timeLength)

			if shouldCleanup == true then
				instance:Destroy()
			end
		elseif instance:IsA("ParticleEmitter") then
			Effects:PlayParticle(instance)

			if shouldCleanup == true then
				Debris:AddItem(instance, 3)
			end
		end
	end)
end

function Effects.PlayVFX(_, folder, p)
	local v = { "ParticleEmitter", "Sound", "AnimationTrack" }

	for _, descendant in folder:GetDescendants() do
		if table.find(v, descendant.ClassName) then
			Effects:PlayThenCleanup(descendant, p)
		end
	end
end

return Effects