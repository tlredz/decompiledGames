local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local Util = require(game.ReplicatedStorage.Util)
return function(player)
	local character = player.Character
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	local upperTorso = character:FindFirstChild("UpperTorso")
	local humanoid = character:FindFirstChild("Humanoid")
	local side = player.Side

	if not (humanoidRootPart and upperTorso and humanoid) or (workspace.CurrentCamera.CFrame.p - humanoidRootPart.Position).Magnitude > 750 then
		return
	end

	local clone = script.Effect:Clone()
	clone.CFrame = upperTorso.CFrame
	Util.ResizeModel(clone, humanoidRootPart.Size.Y / 2, clone.Position)
	clone.Size *= humanoidRootPart.Size.Y / 2
	clone.Parent = _WorldOrigin
	local v = Util.Sound:Play("KenDodge", humanoidRootPart)
	task.delay(0.16666666666666666, function()
		Util.Sound:FadeOut(v, 0.3333333333333333)
	end)
	local v2 = math.min(100, humanoidRootPart.Size.Y * 0.5 + humanoid.HipHeight) + 1
	local ray, _, _ = Util.Ray(
		humanoidRootPart.Position,
		createVector(0, 1, 0) * -v2,
		{ workspace.Characters, workspace.Enemies }
	)

	if ray then
		clone.Attachment.sm2.Color = ColorSequence.new(ray.Color)
	else
		clone.Attachment:Destroy()
	end

	task.spawn(function()
		task.wait()
		local children = clone:GetChildren()

		for _, instance in pairs(children) do
			if instance:IsA("ParticleEmitter") then
				instance.Enabled = false
			elseif instance:IsA("Attachment") then
				for _, emitter in pairs(instance:GetChildren()) do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = false
					end
				end
			end
		end

		local lastTime = os.clock()
		local v3 = 0.016666666666666666
		local now = 0

		while os.clock() - lastTime < 0.15 do
			local v4 = 1 / v3
			local flag = false

			for _, instance in pairs(children) do
				if instance:IsA("ParticleEmitter") then
					local v5 = instance.Rate / v4

					if instance.Name == "ParticleColor1" or instance.Name == "ParticleColor2" then
						if os.clock() - now > 0.041666666666666664 then
							instance:Emit(1)
							flag = true
						end
					elseif math.random() < v5 then
						instance:Emit(v5)
					end
				elseif instance:IsA("Attachment") then
					for _, emitter in pairs(instance:GetChildren()) do
						if not emitter:IsA("ParticleEmitter") then
							continue
						end

						local v5 = emitter.Rate / v4

						if math.random() < v5 then
							emitter:Emit(v5)
						end
					end
				end
			end

			if flag then
				now = os.clock()
			end

			clone.CFrame = upperTorso.CFrame + humanoidRootPart.CFrame.RightVector * side * -1
			v3 = task.wait()
		end

		task.wait(1)
		clone:Destroy()
	end)
end