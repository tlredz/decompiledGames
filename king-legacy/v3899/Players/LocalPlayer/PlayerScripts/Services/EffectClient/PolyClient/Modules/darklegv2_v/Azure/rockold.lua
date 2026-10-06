local createVector = vector.create
local TweenService = game:GetService("TweenService")
require(game.ReplicatedStorage.Chest.Modules.PeodizService)
return function(p)
	local v = {
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random()
	}

	for i = 1, 9 do
		local part = Instance.new("Part")
		part.Parent = workspace.Effects
		part.Size = createVector(5, 3, 3)
		part.CFrame = p * CFrame.Angles(0, v[1], 0) * CFrame.Angles(0, 0.6981317007977318 * i, 0) * CFrame.Angles(
			0,
			math.rad((math.random(-10, 10))),
			0
		) * CFrame.new(0, 0, -24)
		part.CFrame *= CFrame.Angles(-0.4363323129985824, 0, 0)
		part.Anchored = true
		part.CanCollide = false
		part.Massless = true
		local ray = Ray.new(part.CFrame.p, createVector(0, -15, 0))
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
		local instance

		if raycastResult then
			instance = raycastResult.Instance or nil
		end

		local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

		if instance then
			part.Color = instance.Color
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			part.Position = position
			local size = part.Size
			local cFrame = part.CFrame
			local v2 = instance.Color.R * 255
			local v3 = instance.Color.G * 255
			local v4 = instance.Color.B * 255
			local v5 = math.random(-10, 30)
			part.Color = Color3.fromRGB(v2 - v5, v3 - v5, v4 - v5)
			part.Size *= 0.85
			part.CFrame *= CFrame.new(0, -3, 0)
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				CFrame = cFrame,
				Size = size
			}):Play()
			local v6 = part
			task.spawn(function()
				wait(3)
				task.wait(math.random(1, 20) * 0.01)
				TweenService:Create(v6, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					CFrame = cFrame * CFrame.new(0, -4, 0),
					Size = size * 0.75
				}):Play()
			end)
		else
			part.Parent = nil
		end

		_G.PU:Dust(part, 5)
	end

	wait()

	for i = 1, 9 do
		local part = Instance.new("Part")
		part.Parent = workspace.Effects
		part.Size = createVector(7, 3.5, 3.5)
		part.CFrame = p * CFrame.Angles(0, v[2], 0) * CFrame.Angles(0, 0.6981317007977318 * i, 0) * CFrame.Angles(
			0,
			math.rad((math.random(-10, 10))),
			0
		) * CFrame.new(0, 0, -28)
		part.CFrame *= CFrame.Angles(-0.4363323129985824, 0, 0)
		part.Anchored = true
		part.CanCollide = false
		part.Massless = true
		local ray = Ray.new(part.CFrame.p, createVector(0, -15, 0))
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
		local instance

		if raycastResult then
			instance = raycastResult.Instance or nil
		end

		local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

		if instance then
			part.Color = instance.Color
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			part.Position = position - createVector(0, 0.25, 0)
			local size = part.Size
			local cFrame = part.CFrame
			local v2 = instance.Color.R * 255
			local v3 = instance.Color.G * 255
			local v4 = instance.Color.B * 255
			local v5 = math.random(-10, 30)
			part.Color = Color3.fromRGB(v2 - v5, v3 - v5, v4 - v5)
			part.Size *= 0.85
			part.CFrame *= CFrame.new(0, -3, 0)
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				CFrame = cFrame,
				Size = size
			}):Play()
			local v6 = part
			task.spawn(function()
				wait(3)
				task.wait(math.random(1, 20) * 0.01)
				TweenService:Create(v6, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					CFrame = cFrame * CFrame.new(0, -4, 0),
					Size = size * 0.75
				}):Play()
			end)
		else
			part.Parent = nil
		end

		_G.PU:Dust(part, 5)
	end

	wait()

	for i = 1, 10 do
		local part = Instance.new("Part")
		part.Parent = workspace.Effects
		part.Size = createVector(11, 5.5, 5.5)
		part.CFrame = p * CFrame.Angles(0, v[2], 0) * CFrame.Angles(0, 0.6283185307179586 * i, 0) * CFrame.Angles(
			0,
			math.rad((math.random(-5, 5))),
			0
		) * CFrame.new(0, 0, -32)
		part.CFrame *= CFrame.Angles(-0.4363323129985824, 0, 0)
		part.Anchored = true
		part.CanCollide = false
		part.Massless = true
		local ray = Ray.new(part.CFrame.p, createVector(0, -15, 0))
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
		local instance

		if raycastResult then
			instance = raycastResult.Instance or nil
		end

		local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

		if instance then
			part.Color = instance.Color
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			part.Position = position - createVector(0, 0.5, 0)
			local size = part.Size
			local cFrame = part.CFrame
			local v2 = instance.Color.R * 255
			local v3 = instance.Color.G * 255
			local v4 = instance.Color.B * 255
			local v5 = math.random(-10, 30)
			part.Color = Color3.fromRGB(v2 - v5, v3 - v5, v4 - v5)
			part.Size *= 0.85
			part.CFrame *= CFrame.new(0, -3, 0)
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				CFrame = cFrame,
				Size = size
			}):Play()
			local v6 = part
			task.spawn(function()
				wait(3)
				task.wait(math.random(1, 20) * 0.01)
				TweenService:Create(v6, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					CFrame = cFrame * CFrame.new(0, -4, 0),
					Size = size * 0.75
				}):Play()
			end)
		else
			part.Parent = nil
		end

		_G.PU:Dust(part, 5)
	end
end