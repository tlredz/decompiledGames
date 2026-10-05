local TweenService = game:GetService("TweenService")
local assets = script:WaitForChild("Assets")
local Utils = require(script:WaitForChild("Utils"))
local random = Random.new()
return {
	Create = function(_, p, color, p2, timeScale)
		local folder = Instance.new("Folder")
		folder.Name = "Rift " .. tick()
		folder.Parent = workspace
		local clone = assets.Rift1:Clone()
		clone:PivotTo(p * CFrame.Angles(0, math.rad((random:NextNumber(-360, 360))), 0))
		clone:ScaleTo(p2)

		for _, part in pairs(clone:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			part:SetAttribute("OriginalSize", part.Size)
			part.Size = Vector3.new(0, 0, part.Size.Z)
			part.Color = color
		end

		local v = Utils.Create(folder, p2, p, timeScale, color)

		for _ = 1, 35 do
			v:CreateShard(true)
		end

		local clone2 = assets.Particles:Clone()
		clone2.Parent = folder
		clone2:PivotTo(p * CFrame.new(0, 0, 0))
		clone2:ScaleTo(p2)

		for _, emitter in pairs(clone2:GetDescendants()) do
			if not emitter:IsA("ParticleEmitter") then
				continue
			end

			emitter.Color = ColorSequence.new(color)
			emitter.TimeScale = timeScale
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end

		for i = 1, #clone:GetChildren() do
			for _, child in pairs(clone[i]:GetChildren()) do
				TweenService:Create(
					child,
					TweenInfo.new(0.25 * timeScale, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
					{
						Size = Vector3.new(
							child:GetAttribute("OriginalSize").X,
							child:GetAttribute("OriginalSize").Y,
							child:GetAttribute("OriginalSize").Z
						)
					}
				):Play()
			end

			task.wait(0.02 * timeScale)
		end

		task.delay(1.5 * timeScale, function()
			for i = 1, #clone:GetChildren() do
				for _, child in pairs(clone[i]:GetChildren()) do
					TweenService:Create(
						child,
						TweenInfo.new(0.5 * timeScale, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
						{
							Size = Vector3.new(0, 0, child.Size.Z)
						}
					):Play()
				end
			end

			task.delay(0.5 * timeScale, function()
				clone:Destroy()
				task.wait(5 * timeScale)
				folder:Destroy()
			end)
		end)
	end
}