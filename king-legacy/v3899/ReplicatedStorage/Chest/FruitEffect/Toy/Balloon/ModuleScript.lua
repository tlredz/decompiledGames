local createVector = vector.create
return function()
	local v = math.random(1, 4)
	local v2 = {
		Color3.fromRGB(196, 40, 28),
		Color3.fromRGB(17, 255, 0),
		Color3.fromRGB(255, 247, 0),
		Color3.fromRGB(227, 15, 255)
	}
	local v3 = {
		Color3.fromRGB(255, 30, 30),
		Color3.fromRGB(17, 255, 0),
		Color3.fromRGB(255, 247, 0),
		Color3.fromRGB(227, 15, 255)
	}
	local parent = script.Parent
	parent.Size = Vector3.new()
	game.TweenService:Create(parent, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(30.244, 39.693, 30.246) * math.random(8, 10) / 10
	}):Play()
	parent.Color = v2[v]

	for _, emitter in pairs(parent:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		emitter.Color = ColorSequence.new(v3[v])
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end
end