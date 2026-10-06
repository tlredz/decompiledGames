local createVector = vector.create
local TweenService = game:GetService("TweenService")

-- equivalent calls inferred from this helper; original call sites unknown
local function randomnumber(p, p2)
	return Random.new():NextNumber(p, p2)
end

return function(p)
	task.spawn(function()
		for i = 1, 12 do
			local v = 0.5235987755982988 * i
			local v2 = math.random(40, 85) / 100 * 1
			local v3 = randomnumber(6, 11.100000000000001) -- equivalent call inferred; original call site unknown
			local v4 = p.p + Vector3.new(
				math.cos(v) * (30 * v2),
				-Random.new():NextNumber(1.65, 2.5) * 2.25,
				math.sin(v) * (30 * v2)
			)
			local part = Instance.new("Part")
			part.Size = createVector(6, 3, 3) * Random.new():NextNumber(2.5, 3)
			part.Anchored = true
			part.CanCollide = false
			part.CFrame = CFrame.new(v4, p.p - Vector3.new(0, v3, 0))
			_G.PU:Dust(part, 3)
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

			local v5 = position + createVector(0, 2.25, 0) + Vector3.new(
				0,
				-Random.new():NextNumber(1.65, 2.5) * 2.25,
				0
			)
			local orientation, v6, v7 = CFrame.new(v4, p.p - Vector3.new(0, v3, 0)):ToOrientation()
			part.Parent = workspace.Effects
			part.CFrame = CFrame.new(v5) * CFrame.fromOrientation(orientation, v6, v7) * CFrame.new(0, -5, 0)
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			local v8 = instance.Color.R * 255
			local v9 = instance.Color.G * 255
			local v10 = instance.Color.B * 255
			local v11 = math.random(-10, 30)
			part.Color = Color3.fromRGB(v8 - v11, v9 - v11, v10 - v11)
			TweenService:Create(
				part,
				TweenInfo.new(
					(0.25 + Random.new():NextNumber(0.1, 0.2)) * 0.75,
					Enum.EasingStyle.Back,
					Enum.EasingDirection.Out
				),
				{
					CFrame = CFrame.new(v5) * CFrame.fromOrientation(orientation, v6, v7)
				}
			):Play()
			local v14 = part
			task.spawn(function()
				wait(1)
				task.wait(randomnumber(0.1, 0.3))
				TweenService:Create(v14, TweenInfo.new(0.5, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out), {
					CFrame = CFrame.new(v5) * CFrame.fromOrientation(orientation, v6, v7) * CFrame.new(0, -5, 0)
				}):Play()
			end)
		end
	end)
end