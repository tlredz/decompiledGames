local createVector = vector.create
local TweenService = game:GetService("TweenService")
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
return function(p)
	local _ = {
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random(),
		6.283185307179586 * math.random()
	}
	PeodizService.ForLoop({
		Step = 3
	}, function(p2)
		local v = math.floor(p2 * 3)
		local v2 = p * CFrame.Angles(0, 2.0943951023931953 * v, 0) * CFrame.new(0, 0, -34)
		local clone = game.ReplicatedStorage.Chest.Etc.BlackLeg.DiableV2.length:Clone()
		clone.CFrame = v2 * CFrame.new(0, 0, -15)
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 2)
		clone.diable.Enabled = true
		clone.diable2.Enabled = true
		clone.spark3:Emit(15)
		clone.sakura:Emit(15)
		task.spawn(function()
			wait(1)
			clone.diable.Enabled = false
			clone.diable2.Enabled = false
		end)
		PeodizService.ForLoop({
			Step = 6
		}, function(p3)
			local v3 = math.floor(p3 * 6)
			local v4 = v3 % 2
			local v5 = v4 == 0 and -1 or v4
			local part = Instance.new("Part")
			part.Parent = workspace.Effects
			part.Size = createVector(10, 6, 6)
			part.CFrame = v2 * CFrame.new(v5 * math.random(20, 40) / 10, 0, -v3 * math.random(45, 55) / 10)
			part.CFrame = part.CFrame * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(
				math.rad(-math.random(10, 25)) * v5,
				0,
				0
			)
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
				part.Position = position - createVector(0, 2, 0)
				local size = part.Size
				local cFrame = part.CFrame
				local v6 = instance.Color.R * 255
				local v7 = instance.Color.G * 255
				local v8 = instance.Color.B * 255
				local v9 = math.random(-10, 30)
				part.Color = Color3.fromRGB(v6 - v9, v7 - v9, v8 - v9)
				part.Size *= 0.85
				part.CFrame *= CFrame.new(0, -7, 0)
				TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					CFrame = cFrame,
					Size = size
				}):Play()
				task.spawn(function()
					wait(1)
					task.wait(math.random(1, 20) * 0.01)
					TweenService:Create(
						part,
						TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							CFrame = cFrame * CFrame.new(0, -7, 0),
							Size = size * 0.75
						}
					):Play()
				end)
			else
				part.Parent = nil
			end

			_G.PU:Dust(part, 3)
		end)
	end)
end