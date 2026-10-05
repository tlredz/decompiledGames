local createVector = vector.create
workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = game.ReplicatedStorage.Util
local _ = Util.Sound
local _ = Util.MasterClock
local _WorldOrigin = workspace._WorldOrigin
local _ = workspace.Map
local FX = require(game.ReplicatedStorage.FX)
local TweenService = game:GetService("TweenService")
game:GetService("RunService")

for _, emitter in pairs(script.Charging2:GetDescendants()) do
	if emitter:IsA("ParticleEmitter") then
		Util.ScaleParticle({
			Emitter = emitter,
			Time = 0,
			Scale = 4
		})
	end
end

return function(instance)
	local cframe = CFrame.new(instance.HRP.Position - Vector3.new(0, instance.HRP.Size.Y * 1.8, 0))
	local caster = instance.Caster
	local humanoid = instance.Humanoid
	local holding = instance.Holding

	if (cframe.p - workspace.CurrentCamera.CFrame.p).magnitude > 400 then
		return
	end

	local scale = instance.Scale or 100
	local part = Instance.new("Part")
	part.CanCollide = false
	part.Anchored = true
	part.Material = "Neon"
	part.Size = createVector(1, 1, 1)
	part.Color = Color3.new(0.25, 0, 0.25)
	part.CFrame = cframe
	local specialMesh = Instance.new("SpecialMesh", part)
	specialMesh.Scale = Vector3.new()
	specialMesh.MeshType = "Sphere"
	part.Parent = _WorldOrigin
	TweenService:Create(part, TweenInfo.new(2, Enum.EasingStyle.Quad), {
		Color = Color3.new()
	}):Play()
	local tween = TweenService:Create(specialMesh, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		Scale = Vector3.new(scale, 0.25, scale)
	})
	tween.Completed:Connect(function()
		TweenService:Create(specialMesh, TweenInfo.new(1.7, Enum.EasingStyle.Quad), {
			Scale = Vector3.new(scale * 1.5, 1, scale * 1.5)
		}):Play()
	end)
	tween:Play()
	local clone = script.Charging2:Clone()
	clone.CFrame = cframe * CFrame.new(0, -0.1, 0)
	clone.Parent = _WorldOrigin

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			Util.ScaleParticle({
				Emitter = emitter,
				Time = 1.25,
				Scale = 1.5
			})
		end
	end

	local v = Util.Sound:Play("Blackhole", cframe)
	wait(0.1)
	pcall(function()
		local lastTime = tick()

		while tick() - lastTime < 1.65 do
			local v2 = (tick() - lastTime) / 1.65

			if humanoid.Health <= 0 or not caster.Parent or tick() - lastTime > 0.4 and not (holding and holding.Value) then
				break
			end

			for _ = 1, math.random(4, 5) do
				local v3 = CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(
					0,
					0,
					math.random() * 0.5 * scale * (1 + v2 * 0.5)
				)
				local cFrame = cframe
				local attachment = Instance.new("Attachment")
				attachment.CFrame = cFrame * v3
				attachment.Parent = workspace.Terrain
				local attachment2 = Instance.new("Attachment")
				attachment2.CFrame = cFrame * v3 * CFrame.new(0, (10 + math.random() * 6) * (1 + v2 * 0.5), 0)
				attachment2.Parent = workspace.Terrain
				local clone2 = FX:WaitForChild("Attachments").DarkGrab.Beam:Clone()
				clone2.Segments = 1
				clone2.Width0 = 6 * (1 + v2 * 0.5)
				clone2.Attachment0 = attachment
				clone2.Attachment1 = attachment2
				clone2.Parent = _WorldOrigin
				local tweenInfo = TweenInfo.new(0.25)
				TweenService:Create(attachment2, tweenInfo, {
					CFrame = cFrame * v3
				}):Play()
				local tween2 = TweenService:Create(clone2, tweenInfo, {
					Width0 = 0
				})
				tween2.Completed:Connect(function()
					attachment:Destroy()
					attachment2:Destroy()
					clone2:Destroy()
				end)
				tween2:Play()
			end

			Effect.new("Slash"):replicate({
				CFrame = cframe,
				Radius = { 6, 8 },
				RadiusOffset = (10 + 5 * v2) * 5,
				Length = { -5, 5 },
				LengthOffset = 2.5,
				Width = { 25, 0 },
				WidthOffset = 0,
				Color = Color3.new(),
				Cycles = { 1.2, 1.8 },
				Duration = { 0.3, 0.4 },
				Transparency = { 0, 0.4 },
				LightEmission = 0,
				Segments = 120,
				Repeat = 2,
				Ease = Util.Tween.ease["in"].linear
			})
			wait()
		end
	end)
	Util.Sound:FadeOut(v, 0.5)

	for _, emitter in pairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = false
		end
	end

	task.delay(1.5, function()
		clone:Destroy()
	end)
	wait(0.1)
	local tween2 = TweenService:Create(
		specialMesh,
		TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{
			Scale = Vector3.new()
		}
	)
	tween2.Completed:Connect(function()
		part:Destroy()
	end)
	tween2:Play()
end