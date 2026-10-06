local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
return function(player)
	local lightFolder = player.LightFolder
	local character = player.Character
	local rootPart = player.RootPart
	local mouseValue = player.MouseValue
	local renderCF = player.RenderCF
	local A0 = player.A0

	if (workspace.CurrentCamera.CFrame.Position - renderCF.Position).Magnitude > 700 then
		return
	end

	local lastTime = tick()
	local clone = player.Sound:Clone()
	clone.Parent = rootPart
	clone:Play()
	_G.PU:Dust(clone, 10)
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Light.Part2:Clone()
	clone2.CFrame = CFrame.new(mouseValue.Value)
	clone2.Parent = workspace.Effects
	_G.PU:Dust(clone2, 10)
	A0.Beam1.Attachment1 = clone2.A1
	A0.Beam2.Attachment1 = clone2.A1
	A0.Beam1.Enabled = true
	A0.Beam2.Enabled = true
	TweenService:Create(A0.Beam1, TweenInfo.new(0.25), {
		Width0 = 5,
		Width1 = 5
	}):Play()
	TweenService:Create(A0.Beam2, TweenInfo.new(0.25), {
		Width0 = 5,
		Width1 = 5
	}):Play()

	for _, emitter in pairs(clone2.A1:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	repeat
		CFrame.new(rootPart.Position, mouseValue.Value)
		local value = mouseValue.Value
		local _ = (rootPart.Position - value).Magnitude
		local v = math.clamp((rootPart.Position - value).Magnitude, 0, 250)
		local cFrame = CFrame.new(rootPart.Position, value) * CFrame.new(0, 0, -v)
		TweenService:Create(clone2, TweenInfo.new(0.1, Enum.EasingStyle.Linear), {
			CFrame = cFrame
		}):Play()
		wait()
	until tick() - lastTime > 5 or not lightFolder:IsDescendantOf(character)

	if A0 then
		TweenService:Create(A0.Beam1, TweenInfo.new(0.5), {
			Width0 = 0,
			Width1 = 0
		}):Play()
		TweenService:Create(A0.Beam2, TweenInfo.new(0.5), {
			Width0 = 0,
			Width1 = 0
		}):Play()
	end

	_G.PU:Dust(clone2, 1.5)
	TweenService:Create(clone, TweenInfo.new(0.5), {
		Volume = 0
	}):Play()
	_G.PU:Dust(clone, 1)

	for _, emitter in pairs(clone2.A1:GetChildren()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end
end