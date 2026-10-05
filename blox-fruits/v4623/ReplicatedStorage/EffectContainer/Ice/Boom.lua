local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function emberBlob(value, p, p2, p3)
	local part = Instance.new("Part")
	part.CanCollide = false
	part.Anchored = true
	part.Size = createVector(2, 2, 5)
	part.Color = Color3.fromRGB(188, 155, 93)
	part.Material = Enum.Material.Neon
	part.CFrame = p3.CFrame
	local specialMesh = Instance.new("SpecialMesh")
	specialMesh.MeshType = Enum.MeshType.Brick
	specialMesh.Parent = part
	local v = value or 3

	for k, v2 in pairs(p3) do
		part[k] = v2
	end

	part.Parent = workspace._WorldOrigin
	local tween = TweenService:Create(
		part,
		TweenInfo.new(v, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 0),
		{
			Size = createVector(0, 0, 0),
			Color = part.Color:Lerp(Color3.new(1, 1, 1), 0.4)
		}
	)
	tween.Completed:Connect(function()
		part:Destroy()
	end)
	local lastTime = tick()
	coroutine.wrap(function()
		tween:Play()
		local v2 = 1

		while tick() - lastTime < v do
			local _ = (tick() - lastTime) / v
			part.CFrame = part.CFrame * CFrame.new(0, 0, -p2) * CFrame.Angles(
				math.rad(p * math.cos(v2 / 5 + math.random(-15, 15) / 10)),
				0,
				0
			)
			v2 += 1
			RunService.RenderStepped:Wait()
		end

		if part then
			part:Destroy()
		end
	end)()
end

return function(data)
	local cFrame = data.CFrame
	local duration = data.Duration or 0.25
	local width = data.Width or 15
	local color = data.Color or Color3.fromRGB(110, 153, 202)
	local magnitude = (cFrame.p - workspace.CurrentCamera.CFrame.p).Magnitude

	if 500 + width * 2 < magnitude then
		return
	end

	if not data.NoShockwave then
		local part = Instance.new("Part")
		part.Material = "ForceField"
		part.Anchored = true
		part.CastShadow = false
		part.Transparency = 0
		part.CanCollide = false
		part.CFrame = cFrame
		part.Size = createVector(1, 1, 1)
		part.Color = color
		local specialMesh = Instance.new("SpecialMesh", part)
		specialMesh.MeshType = "Sphere"
		specialMesh.Scale = createVector(1, 1, 1)
		part.Parent = workspace._WorldOrigin
		TweenService:Create(part, TweenInfo.new(duration * 1.15), {
			Color = color:Lerp(Color3.new(1, 1, 1), 0.3),
			Transparency = 1
		}):Play()
		local tween = TweenService:Create(specialMesh, TweenInfo.new(duration * 1.15, Enum.EasingStyle.Quad), {
			Scale = createVector(1, 1, 1) * width
		})
		tween.Completed:Connect(function()
			part:Destroy()
		end)
		tween:Play()
	end

	for i = 1, (data.EmbersExtra or 0) + math.random(6, 8) do
		emberBlob(
			duration * 1.25 * (0.5 + math.random() * 2.5),
			8 + math.random() * 3,
			(1.5 + math.random() * 0.5) * width / math.random(80, 120),
			{
				Size = createVector(1, 1, 1) * width * 0.09 * (1 + math.random() * 0.5),
				CFrame = cFrame * CFrame.Angles(
					math.random() * 3.141592653589793 * 2,
					math.random() * 3.141592653589793 * 2,
					math.random() * 3.141592653589793 * 2
				) * CFrame.new(0, 0, -width / 12),
				Color = i % 2 == 0 and color or color:Lerp(Color3.new(1, 1, 1), 0.3)
			}
		)
	end

	local clone = script.SpikedBall:Clone()
	clone.PointLight.Range = 0
	clone.Size = Vector3.new()
	clone.Color = Color3.new(1, 1, 1)
	clone.Transparency = data.NoShockwave and 1 or 0.95
	clone.CFrame = cFrame * CFrame.Angles(
		3.141592653589793 * math.random() * 2,
		3.141592653589793 * math.random() * 2,
		3.141592653589793 * math.random() * 2
	)
	clone.Parent = workspace._WorldOrigin
	clone.ParticleEmitter.Size = NumberSequence.new(width / 4, width / 2)
	clone.ParticleEmitter.Color = ColorSequence.new(color:Lerp(Color3.new(1, 1, 1), 0.3), color)
	clone.ParticleEmitter.Speed = NumberRange.new(width * 0.25, width * 1.25)
	clone.ParticleEmitter.Lifetime = NumberRange.new(duration * 2, duration * 6)
	clone.ParticleEmitter:Emit(9)
	local tween = TweenService:Create(clone, TweenInfo.new(duration, Enum.EasingStyle.Sine), {
		Size = createVector(1, 1, 1) * width * 0.9,
		Color = color,
		Transparency = 1,
		CFrame = clone.CFrame * CFrame.Angles(0, 1.5707963267948966, 0)
	})
	tween.Completed:Connect(function()
		wait(duration * 5)
		clone:Destroy()
	end)
	tween:Play()
end