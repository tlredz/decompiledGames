local createVector = vector.create
return function(_)
	local cframe = CFrame.Angles(
		math.rad((math.random(-15, 15))),
		math.rad((math.random(-15, 15))),
		(math.rad((math.random(-15, 15))))
	)
	local cframe2 = CFrame.Angles(
		math.rad((math.random(-15, 15))),
		math.rad((math.random(-15, 15))),
		(math.rad((math.random(-15, 15))))
	)
	local _ = {
		box_ribbon = cframe,
		top_ribbon = cframe2,
		box = cframe,
		top = cframe2
	}
	local v = {
		box_ribbon = createVector(39.441, 39.819, 39.442),
		top_ribbon = createVector(45.366, 13.331, 45.366),
		box = createVector(38.382, 38.382, 38.382),
		top = createVector(43.817, 12.32, 43.817),
		Cube = createVector(48.612, 56.589, 52.684),
		HumanoidRootPart = createVector(44.267, 38.983, 44.267)
	}

	for _, part in pairs(script.Parent:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Size = Vector3.new()
		local cFrame = part.CFrame
		part.CFrame = part.CFrame
		game.TweenService:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = v[part.Name]
		}):Play()
		game.TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CFrame = cFrame
		}):Play()
	end

	for _, emitter in pairs(script.Parent.HumanoidRootPart:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end

	wait(0.15)

	for _, part in pairs(script.Parent:GetChildren()) do
		if not part:IsA("BasePart") then
			continue
		end

		game.TweenService:Create(part, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = Vector3.new()
		}):Play()
		game.TweenService:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CFrame = script.Parent.PrimaryPart.CFrame * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
		}):Play()
	end
end