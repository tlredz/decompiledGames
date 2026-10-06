local createVector = vector.create
local TweenService = game:GetService("TweenService")
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
return function(p)
	local v = {
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random()
	}
	PeodizService.ForLoop({
		Time = 9
	}, function(p2)
		local v2 = math.floor(p2 * 9)
		local part = Instance.new("Part")
		part.Parent = workspace.Effects
		part.Size = createVector(10, 6, 6)
		part.CFrame = p * CFrame.Angles(0, v[1], 0) * CFrame.Angles(0, 0.6981317007977318 * v2, 0) * CFrame.Angles(
			0,
			math.rad((math.random(-10, 10))),
			0
		) * CFrame.new(0, 0, -44)
		part.CFrame *= CFrame.Angles(-0.4363323129985824, 0, 0)
		part.Anchored = true
		part.CanCollide = false
		part.Massless = true
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		local raycastResult = workspace:Raycast(part.CFrame.p, createVector(0, -15, 0), raycastParams)

		if raycastResult then
			local instance = raycastResult.Instance
			local position = raycastResult.Position
			part.Color = instance.Color
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			part.Position = position - createVector(0, 0.25, 0)
			local size = part.Size
			local cFrame = part.CFrame
			local v3 = instance.Color.R * 255
			local v4 = instance.Color.G * 255
			local v5 = instance.Color.B * 255
			local v6 = math.random(-10, 30)
			part.Color = Color3.fromRGB(v3 - v6, v4 - v6, v5 - v6)
			part.Size *= 0.85
			part.CFrame *= CFrame.new(0, -10, 0)
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				CFrame = cFrame,
				Size = size
			}):Play()
			task.spawn(function()
				wait(1)
				task.wait(math.random(1, 20) * 0.01)
				TweenService:Create(part, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					CFrame = cFrame * CFrame.new(0, -10, 0),
					Size = size * 0.75
				}):Play()
			end)
		else
			part.Parent = nil
		end

		_G.PU:Dust(part, 3)
	end)
	wait()
	PeodizService.ForLoop({
		Time = 9
	}, function(p2)
		local v2 = math.floor(p2 * 9)
		local part = Instance.new("Part")
		part.Parent = workspace.Effects
		part.Size = createVector(14, 7, 7)
		part.CFrame = p * CFrame.Angles(0, v[2], 0) * CFrame.Angles(0, 0.6981317007977318 * v2, 0) * CFrame.Angles(
			0,
			math.rad((math.random(-10, 10))),
			0
		) * CFrame.new(0, 0, -51)
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
			local v3 = instance.Color.R * 255
			local v4 = instance.Color.G * 255
			local v5 = instance.Color.B * 255
			local v6 = math.random(-10, 30)
			part.Color = Color3.fromRGB(v3 - v6, v4 - v6, v5 - v6)
			part.Size *= 0.85
			part.CFrame *= CFrame.new(0, -10, 0)
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				CFrame = cFrame,
				Size = size
			}):Play()
			task.spawn(function()
				wait(1)
				task.wait(math.random(1, 20) * 0.01)
				TweenService:Create(part, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					CFrame = cFrame * CFrame.new(0, -10, 0),
					Size = size * 0.75
				}):Play()
			end)
		else
			part.Parent = nil
		end

		_G.PU:Dust(part, 3)
	end)
	wait()
	PeodizService.ForLoop({
		Time = 10
	}, function(p2)
		local v2 = math.floor(p2 * 10)
		local part = Instance.new("Part")
		part.Parent = workspace.Effects
		part.Size = createVector(22, 11, 11)
		part.CFrame = p * CFrame.Angles(0, v[2], 0) * CFrame.Angles(0, 0.6283185307179586 * v2, 0) * CFrame.Angles(
			0,
			math.rad((math.random(-5, 5))),
			0
		) * CFrame.new(0, 0, -57)
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
			part.Position = position - createVector(0, 0.75, 0)
			local size = part.Size
			local cFrame = part.CFrame
			local v3 = instance.Color.R * 255
			local v4 = instance.Color.G * 255
			local v5 = instance.Color.B * 255
			local v6 = math.random(-10, 30)
			part.Color = Color3.fromRGB(v3 - v6, v4 - v6, v5 - v6)
			part.Size *= 0.85
			part.CFrame *= CFrame.new(0, -10, 0)
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				CFrame = cFrame,
				Size = size
			}):Play()
			task.spawn(function()
				wait(1)
				task.wait(math.random(1, 20) * 0.01)
				TweenService:Create(part, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					CFrame = cFrame * CFrame.new(0, -10, 0),
					Size = size * 0.75
				}):Play()
			end)
		else
			part.Parent = nil
		end

		_G.PU:Dust(part, 3)
	end)
end