local _WorldOrigin = workspace:FindFirstChild("_WorldOrigin") or workspace
return function(data)
	if data.Mode == "Start" then
		local clone = script.Splash:Clone()
		clone.CFrame = CFrame.new(data.Bobber.Position)
		clone.Parent = _WorldOrigin

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end

		task.spawn(function()
			while data.Bobber:IsDescendantOf(workspace) do
				clone.CFrame = CFrame.new(data.Bobber.Position)
				task.wait()
			end

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.wait(2)
			clone:Destroy()
		end)
	elseif data.Mode == "Reeling" then
		local clone = script.Droplets:Clone()
		clone.CFrame = CFrame.new(data.Bobber.Position)
		clone.Parent = _WorldOrigin
		task.spawn(function()
			while data.Bobber:IsDescendantOf(workspace) do
				clone.CFrame = CFrame.new(data.Bobber.Position)
				task.wait()
			end

			for _, emitter in pairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			task.wait(2)
			clone:Destroy()
		end)
	elseif data.Mode == "Aim" then
		local clone = script.Aim:Clone()
		clone.CFrame = CFrame.new(0, -100, 0)
		clone.Parent = _WorldOrigin

		for _, emitter in pairs(clone:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Lifetime = NumberRange.new(20)
			emitter.TimeScale = 0.01
			emitter:Emit(1)
		end

		return clone
	else
		if data.Mode ~= "Warn" then
			return
		end

		local clone = script.Warning.Attachment:Clone()
		clone.ParticleEmitter.Lifetime = NumberRange.new(data.Duration)
		clone.Parent = data.Head
		clone.ParticleEmitter:Emit(1)
		return clone
	end
end