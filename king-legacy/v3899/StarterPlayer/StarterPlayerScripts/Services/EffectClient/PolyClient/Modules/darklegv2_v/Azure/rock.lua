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
		Step = 9
	}, function(p2)
		local v2 = math.floor(p2 * 9)
		local part = Instance.new("Part")
		part.Parent = workspace.Effects
		part.Size = createVector(5, 3, 3)
		part.CFrame = p * CFrame.Angles(0, v[1], 0) * CFrame.Angles(0, 0.6981317007977318 * v2, 0) * CFrame.Angles(
			0,
			math.rad((math.random(-10, 10))),
			0
		) * CFrame.new(0, 0, -24)
		part.CFrame *= CFrame.Angles(-0.4363323129985824, 0, 0)
		part.Anchored = true
		part.CanCollide = false
		part.Massless = true
		local p3 = part.CFrame.p
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		local raycastResult = workspace:Raycast(p3, createVector(0, -15, 0), raycastParams)
		local instance

		if raycastResult then
			instance = raycastResult.Instance or nil
		end

		local position = raycastResult and raycastResult.Position or p3 + createVector(0, -15, 0)

		if instance then
			part.Color = instance.Color
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			part.Position = position
			local size = part.Size
			local cFrame = part.CFrame
			local v3 = instance.Color.R * 255
			local v4 = instance.Color.G * 255
			local v5 = instance.Color.B * 255
			local v6 = math.random(-10, 30)
			part.Color = Color3.fromRGB(v3 - v6, v4 - v6, v5 - v6)
			part.Size *= 0.85
			part.CFrame *= CFrame.new(0, -3, 0)
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				CFrame = cFrame,
				Size = size
			}):Play()
			task.spawn(function()
				for _ = 1, 5 do
					wait(0.6)
					game.TweenService:Create(
						part,
						TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, true, 0),
						{
							Size = part.Size * 1.25
						}
					):Play()
				end

				task.wait(math.random(1, 20) * 0.01)
				TweenService:Create(part, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					CFrame = cFrame * CFrame.new(0, -4, 0),
					Size = size * 0.75
				}):Play()
			end)
		else
			part.Parent = nil
		end

		_G.PU:Dust(part, 5)
	end)
	wait()
	PeodizService.ForLoop({
		Step = 9
	}, function(p2)
		local v2 = math.floor(p2 * 9)
		local part = Instance.new("Part")
		part.Parent = workspace.Effects
		part.Size = createVector(7, 3.5, 3.5)
		part.CFrame = p * CFrame.Angles(0, v[2], 0) * CFrame.Angles(0, 0.6981317007977318 * v2, 0) * CFrame.Angles(
			0,
			math.rad((math.random(-10, 10))),
			0
		) * CFrame.new(0, 0, -28)
		part.CFrame *= CFrame.Angles(-0.4363323129985824, 0, 0)
		part.Anchored = true
		part.CanCollide = false
		part.Massless = true
		local p3 = part.CFrame.p
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		local raycastResult = workspace:Raycast(p3, createVector(0, -15, 0), raycastParams)
		local instance

		if raycastResult then
			instance = raycastResult.Instance or nil
		end

		local position = raycastResult and raycastResult.Position or p3 + createVector(0, -15, 0)

		if instance then
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
			part.CFrame *= CFrame.new(0, -3, 0)
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				CFrame = cFrame,
				Size = size
			}):Play()
			task.spawn(function()
				for _ = 1, 5 do
					wait(0.6)
					game.TweenService:Create(
						part,
						TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, true, 0),
						{
							Size = part.Size * 1.25
						}
					):Play()
				end

				task.wait(math.random(1, 20) * 0.01)
				TweenService:Create(part, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					CFrame = cFrame * CFrame.new(0, -4, 0),
					Size = size * 0.75
				}):Play()
			end)
		else
			part.Parent = nil
		end

		_G.PU:Dust(part, 5)
	end)
	wait()
	PeodizService.ForLoop({
		Step = 10
	}, function(p2)
		local v2 = math.floor(p2 * 10)
		local part = Instance.new("Part")
		part.Parent = workspace.Effects
		part.Size = createVector(11, 5.5, 5.5)
		part.CFrame = p * CFrame.Angles(0, v[2], 0) * CFrame.Angles(0, 0.6283185307179586 * v2, 0) * CFrame.Angles(
			0,
			math.rad((math.random(-5, 5))),
			0
		) * CFrame.new(0, 0, -32)
		part.CFrame *= CFrame.Angles(-0.4363323129985824, 0, 0)
		part.Anchored = true
		part.CanCollide = false
		part.Massless = true
		local p3 = part.CFrame.p
		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = { workspace.Island }
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		local raycastResult = workspace:Raycast(p3, createVector(0, -15, 0), raycastParams)
		local instance

		if raycastResult then
			instance = raycastResult.Instance or nil
		end

		local position = raycastResult and raycastResult.Position or p3 + createVector(0, -15, 0)

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
			part.CFrame *= CFrame.new(0, -3, 0)
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				CFrame = cFrame,
				Size = size
			}):Play()
			task.spawn(function()
				for _ = 1, 5 do
					wait(0.6)
					game.TweenService:Create(
						part,
						TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, true, 0),
						{
							Size = part.Size * 1.25
						}
					):Play()
				end

				task.wait(math.random(1, 20) * 0.01)
				TweenService:Create(part, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					CFrame = cFrame * CFrame.new(0, -4, 0),
					Size = size * 0.75
				}):Play()
			end)
		else
			part.Parent = nil
		end

		_G.PU:Dust(part, 5)
	end)
end