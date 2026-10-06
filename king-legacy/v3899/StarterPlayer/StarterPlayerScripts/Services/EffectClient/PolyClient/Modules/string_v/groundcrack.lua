local createVector = vector.create
return function(p)
	local function heatline(part, p2, i)
		local part2 = Instance.new("Part")
		part2.CFrame = part.CFrame * CFrame.new(math.random(-50, 50) / 10, 0, 0)
		part2.Size = Vector3.new(0.2, part.Size.Y + 0.2, part.Size.Z + 0.2)
		part2.Material = Enum.Material.Neon
		part2.Color = Color3.fromRGB(255, 116, 52)
		part2.Anchored = true
		part2.CanCollide = false
		part2.Parent = part
		part2.CFrame *= CFrame.new(0, 0, 10 + p2)
		game.TweenService:Create(part2, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CFrame = part2.CFrame * CFrame.new(0, 0, -(10 + p2))
		}):Play()
		task.spawn(function()
			wait(1)
			game.TweenService:Create(part2, TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = CFrame.new(part2.CFrame.p) * CFrame.new(0, -10, 0) * CFrame.Angles(
					0,
					0.5235987755982988 * i,
					0
				) * CFrame.Angles(0.3141592653589793, 0, 0),
				Transparency = 1
			}):Play()
		end)
	end

	for i = 1, 12 do
		local ray = Ray.new(
			(p * CFrame.Angles(0, 0.5235987755982988 * i, 0) * CFrame.new(0, 5, -40)).p,
			createVector(0, -13, 0)
		)
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
		local instance

		if raycastResult then
			instance = raycastResult.Instance or nil
		end

		local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction
		local v = 3 * math.random(0, 10) / 10
		local part = Instance.new("Part")
		part.CFrame = CFrame.new(position - createVector(0, 1.25, 0)) * CFrame.Angles(0, 0.5235987755982988 * i, 0) * CFrame.Angles(
			0.3141592653589793,
			0,
			0
		)
		part.Size = Vector3.new(28, 5 + v, 10 + v)
		part.Material = Enum.Material.SmoothPlastic
		part.Color = Color3.fromRGB(255, 255, 255)
		part.Anchored = true
		part.CanCollide = false

		if instance then
			part.Color = instance.Color
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			part.MaterialVariant = instance.MaterialVariant
			part.Parent = workspace.Effects
		end

		if math.random(1, 3) == 1 then
			heatline(part, v, i)
		end

		part.CFrame *= CFrame.new(0, 0, 10 + v)
		game.TweenService:Create(part, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			CFrame = part.CFrame * CFrame.new(0, 0, -(10 + v))
		}):Play()
		_G.PU:Dust(part, 3)
		local v3 = i
		task.spawn(function()
			wait(1)
			game.TweenService:Create(part, TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = CFrame.new(part.CFrame.p) * CFrame.new(0, -10, 0) * CFrame.Angles(
					0,
					0.5235987755982988 * v3,
					0
				) * CFrame.Angles(0.3141592653589793, 0, 0),
				Transparency = 1
			}):Play()
		end)
	end
end