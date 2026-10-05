local createVector = vector.create
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
return {
	play = function(position)
		if typeof(position) ~= "Vector3" then
			return
		end

		local currentCamera = workspace.CurrentCamera

		if not currentCamera or (currentCamera.CFrame.Position - position).Magnitude > 140 then
			return
		end

		local part = Instance.new("Part")
		part.Name = "CloneSplitBurst"
		part.Size = createVector(1, 1, 1)
		part.CFrame = CFrame.new(position)
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
		part.CastShadow = false
		local particleEmitter = Instance.new("ParticleEmitter")
		particleEmitter.Name = "SharedSplitMist"
		particleEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
		particleEmitter.Rate = 0
		particleEmitter.Lifetime = NumberRange.new(0.24, 0.42)
		particleEmitter.Speed = NumberRange.new(6, 13)
		particleEmitter.SpreadAngle = Vector2.new(180, 180)
		particleEmitter.Rotation = NumberRange.new(0, 360)
		particleEmitter.RotSpeed = NumberRange.new(-75, 75)
		particleEmitter.Drag = 12
		particleEmitter.LightEmission = 0.4
		particleEmitter.LightInfluence = 0
		particleEmitter.Color = ColorSequence.new(Color3.fromRGB(110, 145, 255), Color3.fromRGB(143, 106, 215))
		particleEmitter.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 5),
			NumberSequenceKeypoint.new(0.4, 8),
			NumberSequenceKeypoint.new(1, 10)
		})
		particleEmitter.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.3),
			NumberSequenceKeypoint.new(0.35, 0.45),
			NumberSequenceKeypoint.new(1, 1)
		})
		particleEmitter.Parent = part
		part.Parent = workspace
		particleEmitter:Emit(16)
		Debris:AddItem(part, 0.5)
		local part2 = Instance.new("Part")
		part2.Name = "CloneSplitFlash"
		part2.Shape = Enum.PartType.Ball
		part2.Size = createVector(4, 6, 4)
		part2.CFrame = CFrame.new(position)
		part2.Material = Enum.Material.Neon
		part2.Color = Color3.fromRGB(147, 177, 255)
		part2.Transparency = 0.7
		part2.Anchored = true
		part2.CanCollide = false
		part2.CanTouch = false
		part2.CanQuery = false
		part2.CastShadow = false
		part2.Parent = workspace
		TweenService:Create(part2, TweenInfo.new(0.26, Enum.EasingStyle.Quad), {
			Size = createVector(13, 8, 13),
			Transparency = 1
		}):Play()
		Debris:AddItem(part2, 0.3)
	end
}