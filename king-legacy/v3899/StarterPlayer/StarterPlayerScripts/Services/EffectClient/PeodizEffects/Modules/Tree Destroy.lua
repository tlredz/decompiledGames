local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
return function(p)
	local tree = p.Tree

	if not tree or (workspace.CurrentCamera.CFrame.Position - tree:GetModelCFrame().Position).Magnitude >= 600 then
		return
	end

	local clone = tree:Clone()
	clone.Name = "FakeTree"
	local part = Instance.new("Part")
	part.Size = Vector3.new()
	part.Transparency = 1
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.CastShadow = false
	part.CFrame = tree:GetModelCFrame()
	part.Parent = workspace.Effects
	local sound = _G.PU.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 50,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://129215652595037",
		Volume = 0.35
	})
	sound.Parent = part
	sound:Play()
	_G.PU:Dust({ part, sound }, 3)

	for _, part2 in pairs(clone:GetDescendants()) do
		if not part2:IsA("BasePart") then
			continue
		end

		if part2.ClassName == "WedgePart" then
			part2:Destroy()
		else
			part2.Transparency = 0
			part2.Anchored = false
			part2.CollisionGroup = "Effect"
			part2.Velocity = Vector3.new(math.random(-50, 50), math.random(5, 20), math.random(-50, 50))
			part2.RotVelocity = Vector3.new(math.random(-25, 25), math.random(-10, 10), math.random(-25, 25))
			local parent = part2
			task.spawn(function()
				for i, emitter in pairs(ReplicatedStorage.Chest.Etc.DestroyT:GetChildren()) do
					if not emitter:IsA("ParticleEmitter") then
						continue
					end

					local clone2 = emitter:Clone()

					if clone2.Name == "Smoke" then
						clone2.Color = ColorSequence.new(parent.Color)
					elseif clone2.Name == "Leaf" and parent.Material == Enum.Material.Grass then
						clone2.Color = ColorSequence.new(parent.Color)
					end

					clone2.Enabled = true
					clone2.Parent = parent
					_G.PU:Dust(clone2, 4)
					pcall(function()
						task.spawn(function()
							wait(1)

							if clone2 then
								clone2.Enabled = false
							end
						end)
					end)
				end
			end)
			part2.CanCollide = true
			TweenService:Create(
				part2,
				TweenInfo.new(0.75, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false, 3),
				{
					Size = createVector(0, 0, 0)
				}
			):Play()
		end
	end

	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 4)
end