local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
return function(instance)
	if not instance then
		return
	end

	local v = { "RightHand", "RightUpperArm", "RightLowerArm" }
	pcall(function()
		local child = instance:FindFirstChild(v[math.random(1, #v)])
		local clone = replicatedStorage.Chest.FruitEffect.Smoke.SmokeCube:Clone()
		clone.Size = Vector3.new()
		clone.CanCollide = false
		clone.Massless = true
		clone.Anchored = false
		clone.Parent = workspace.Effects
		local weld = Instance.new("Weld")
		weld.Parent = child
		weld.Part0 = child
		weld.Part1 = clone
		weld.C0 = CFrame.new(
			math.random(-child.Size.X / 2, child.Size.X / 2),
			math.random(-child.Size.Y / 2, child.Size.Y / 2),
			math.random(-child.Size.Z / 2, child.Size.Z / 2)
		)
		local v3 = math.random(0, 5) / 10
		TweenService:Create(
			clone,
			TweenInfo.new(math.random(20, 35) / 100, Enum.EasingStyle.Back, Enum.EasingDirection.Out, 0, true, 0),
			{
				Size = createVector(1.5, 1.5, 1.5) + Vector3.new(v3, v3, v3)
			}
		):Play()
		task.spawn(function()
			wait(0.2)
			TweenService:Create(weld, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				C0 = weld.C0 * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				) * CFrame.new(0, 0, -1)
			}):Play()
			_G.PU:Dust(clone, 0.75)
		end)
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			C0 = weld.C0 * CFrame.Angles(0, 0, 6.283185307179586 * math.random())
		}):Play()
	end)
end