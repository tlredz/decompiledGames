local createVector = vector.create
local TweenService = game:GetService("TweenService")

-- equivalent calls inferred from this helper; original call sites unknown
local function randomnumber(p, p2)
	return Random.new():NextNumber(p, p2)
end

return function(p)
	task.spawn(function()
		for i = 1, 10 do
			local v = 0.6283185307179586 * i
			local v2 = math.random(60, 85) / 100 * 1.8
			local v3 = randomnumber(10, 18.5) -- equivalent call inferred; original call site unknown
			local v4 = p.p + Vector3.new(
				math.cos(v) * (30 * v2),
				-Random.new():NextNumber(1.65, 2.5) * 2.25,
				math.sin(v) * (30 * v2)
			)
			local part = Instance.new("Part")
			part.Size = createVector(6, 3, 3) * Random.new():NextNumber(3, 4)
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = CFrame.new(v4, p.p - Vector3.new(0, v3, 0))
			_G.PU:Dust(part, 1)
			local ray = Ray.new(part.CFrame.p + createVector(0, 5, 0), createVector(0, -15, 0))
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = { workspace.Island }
			raycastParams.FilterType = Enum.RaycastFilterType.Include
			local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
			local instance

			if raycastResult then
				instance = raycastResult.Instance or nil
			end

			local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

			if not instance then
				continue
			end

			part.Parent = workspace.Effects
			part.CFrame = CFrame.new(v4, p.p - Vector3.new(0, v3, 0)) * CFrame.new(0, -5, 0)
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			part.Position = position
			local vector2 = Vector3.new(v4.X, position.Y - 3, v4.Z)
			local v5 = instance.Color.R * 255
			local v6 = instance.Color.G * 255
			local v7 = instance.Color.B * 255
			local v8 = math.random(-10, 30)
			part.Color = Color3.fromRGB(v5 - v8, v6 - v8, v7 - v8)
			TweenService:Create(
				part,
				TweenInfo.new(
					(0.25 + Random.new():NextNumber(0.1, 0.2)) * 0.75,
					Enum.EasingStyle.Back,
					Enum.EasingDirection.Out
				),
				{
					CFrame = CFrame.new(vector2, p.p - Vector3.new(0, v3, 0))
				}
			):Play()
			local v9 = part
			local v10 = v3
			task.spawn(function()
				wait(0.5)
				task.wait(randomnumber(0.1, 0.3))
				TweenService:Create(v9, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					CFrame = CFrame.new(vector2, p.p - Vector3.new(0, v10, 0)) * CFrame.new(0, -5, 0)
				}):Play()
			end)
		end
	end)
end