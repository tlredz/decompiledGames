local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(p)
	local startCF = p.StartCF
	local success, result = pcall(function()
		return (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude > 1000
	end)

	if success and result then
		return
	end

	pcall(function()
		if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude <= 75 then
			_G.CamShake("Gura1")
		end
	end)
	coroutine.wrap(function()
		for i = 0, 1 do
			local clone = ReplicatedStorage.Chest.FruitEffect.Gura.QuakeShock1:Clone()
			clone.CFrame = startCF * CFrame.new(0, 0, -3 - i * 25) * CFrame.Angles(1.5707963267948966, 0, 0) * CFrame.Angles(
				0,
				6.283185307179586 * math.random(),
				0
			)
			clone.Parent = workspace.Effects
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = Vector3.new(60 - i * 11, 15, 60 - i * 11)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.375, Enum.EasingStyle.Sine), {
				CFrame = clone.CFrame * CFrame.Angles(0, 6.283185307179586 * math.random(), 0),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone, 1.25)
			wait(0.075)
		end
	end)()
	coroutine.wrap(function()
		for i = 1, 7 do
			local v = i
			spawn(function()
				local v2 = startCF * CFrame.Angles(0, 0, 6.283185307179586 * v / 7)
				local v3 = v2 * CFrame.new(0, 7.5, 0)
				local v4 = {}

				for i2 = 0, 7 do
					local cframe = CFrame.new(math.random(-100, 100) / 100, 0, 0)

					if i2 == 0 or i2 == 7 then
						cframe = CFrame.new()
					end

					local v5 = v2 * CFrame.new(0, (v2.Position - v3.Position).Magnitude / 7 * i2, 0) * cframe
					v4[#v4 + 1] = v5
				end

				PeodizService.ForceForLoop({
					Step = #v4
				}, function(p2)
					local v5 = math.floor(p2 * #v4)
					local v6 = v4[v5]
					local v7 = v4[v5 + 1]

					if v7 then
						local part = Instance.new("Part")
						part.Anchored = true
						part.CanCollide = false
						part.Material = "Glass"
						part.Reflectance = 10000
						part.BrickColor = BrickColor.new("Pastel Blue")
						part.Size = Vector3.new(1, 1, (v6.p - v7.p).Magnitude)
						part.CFrame = CFrame.new(v6.p, v7.p) * CFrame.new(0, 0, -(v6.p - v7.p).Magnitude / 2)
						part.Parent = workspace.Effects
						local TweenService2 = game:GetService("TweenService")
						TweenService2:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
							Size = Vector3.new(0.15, 0.15, part.Size.Z)
						}):Play()
						local TweenService3 = game:GetService("TweenService")
						TweenService3:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
							Transparency = 0.5
						}):Play()
						spawn(function()
							wait(2)
							local TweenService4 = game:GetService("TweenService")
							TweenService4:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
								Transparency = 1,
								Size = Vector3.new(0, 0, part.Size.Z)
							}):Play()
						end)
						_G.PU:Dust(part, 3)
						wait()
					end
				end)
				task.delay(10, function()
					table.clear(v4)
				end)
			end)
		end
	end)()
	spawn(function()
		local v = startCF * CFrame.new(0, 0, 9.5)
		PeodizService.ForceForLoop({
			Step = 6,
			WaitTime = 0.05
		}, function(p2)
			local v2 = math.floor(p2 * 6)
			coroutine.wrap(function()
				local v3 = v * CFrame.new(math.random(-20, 20), 0, math.random(-10, 10))
				PeodizService.ForLoop({
					Step = 5,
					WaitTime = 0.025
				}, function(p3)
					local v4 = math.floor(p3 * 5)
					local part = Instance.new("Part")
					part.BrickColor = math.random(1, 2) == 1 and BrickColor.new("Light blue") or BrickColor.new("Institutional white")
					part.Anchored = true
					part.CanCollide = false
					part.Material = Enum.Material.Neon
					part.Size = Vector3.new(v2 / 8 + 1 - v4 / 2.2, v2 / 8 + 1 - v4 / 2.2, v2 * 1.5 + 16)
					part.CFrame = v3 * CFrame.Angles(
						math.random() * 7,
						math.random() * 3.141592653589793 * 2,
						math.random() * 7
					) * CFrame.new(0, 0, -part.Size.z / 2)
					part.Parent = workspace.Effects
					v3 = part.CFrame * CFrame.new(0, 0, -part.Size.z / 2)
					_G.PU:Dust(part, 0.1)
				end)
			end)()
		end)
	end)
	local clone = ReplicatedStorage.Chest.FruitEffect.Gura.Tremor:Clone()
	_G.PU:Dust(clone, 10)
	clone.CFrame = startCF
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5304722289",
		Volume = 1.5
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6957267217",
		Volume = 4,
		PlaybackSpeed = 1.1
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone
	sound2:Play()
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Gura.SFXPart:Clone()
	_G.PU:Dust(clone2, 3)
	clone2.CFrame = startCF
	clone2.Parent = workspace.Effects
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5605730237",
		Volume = 1.6
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone2
	sound3:Play()
	local sound4 = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6948300574",
		PlaybackSpeed = 0.9,
		Volume = 2.5
	})
	_G.PU:Dust(sound4, 3)
	sound4.Parent = clone2
	sound4:Play()
	local sound5 = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5503900614",
		Volume = 1
	})
	_G.PU:Dust(sound5, 3)
	sound5.Parent = clone2
	sound5:Play()
	PeodizService.ForLoop({
		Step = 35
	}, function(p2)
		local v = math.floor(p2 * 35)
		local cFrame = startCF * CFrame.new(
			0,
			0,
			-(startCF.p - (startCF * CFrame.new(0, 0, -125)).p).Magnitude / 35 * v
		)
		clone.CFrame = cFrame

		if v % 15 == 5 then
			spawn(function()
				local cFrame2 = cFrame

				for i = 1, 6 do
					local v4 = i
					coroutine.wrap(function()
						local v5 = cFrame2 * CFrame.new(math.random(-20, 20), 0, math.random(-10, 10))

						for i2 = 1, 5 do
							local part = Instance.new("Part")
							part.BrickColor = math.random(1, 2) == 1 and BrickColor.new("Light blue") or BrickColor.new("Institutional white")
							part.Anchored = true
							part.CanCollide = false
							part.Material = Enum.Material.Neon
							part.Size = Vector3.new(v4 / 8 + 1 - i2 / 2.2, v4 / 8 + 1 - i2 / 2.2, v4 * 1.5 + 16)
							part.CFrame = v5 * CFrame.Angles(
								math.random() * 7,
								math.random() * 3.141592653589793 * 2,
								math.random() * 7
							) * CFrame.new(0, 0, -part.Size.z / 2)
							part.Parent = workspace.Effects
							v5 = part.CFrame * CFrame.new(0, 0, -part.Size.z / 2)
							_G.PU:Dust(part, 0.1)
							wait(0.025)
						end
					end)()
					wait(0.05)
				end
			end)
		end

		if v % 4 == 1 then
			for i = 1, 2 do
				local v3 = 30 - v / 35 * 17.5

				if i == 2 then
					v3 = -v3
				end

				local v4 = (cFrame * CFrame.new(-v3, 0, 0)).p + createVector(0, 5, 0)
				local ray = Ray.new(v4, createVector(0, -40, 0))
				local raycastParams = RaycastParams.new()
				raycastParams.FilterDescendantsInstances = { workspace.Island }
				raycastParams.FilterType = Enum.RaycastFilterType.Include
				local raycastResult = workspace:Raycast(ray.Origin, ray.Direction, raycastParams)
				local instance

				if raycastResult then
					instance = raycastResult.Instance or nil
				end

				local position = raycastResult and raycastResult.Position or ray.Origin + ray.Direction

				if instance and instance.Name ~= "Terrain" then
					local part = Instance.new("Part")
					part.Anchored = true
					part.CanCollide = false
					part.Material = instance.Material
					part.MaterialVariant = instance.MaterialVariant
					part.BrickColor = instance.BrickColor
					part.CFrame = CFrame.new(position) * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					)
					part.Size = createVector(10, 10, 10)
					part.Parent = workspace.Effects
					spawn(function()
						wait(1)
						TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
							Transparency = 1
						}):Play()
					end)
					_G.PU:Dust(part, 1.5)
				end

				Instance.new("Part")
			end
		end

		local clone3 = ReplicatedStorage.Chest.FruitEffect.Gura.Shockwave2:Clone()
		clone3.CFrame = cFrame * CFrame.Angles(0, 3.141592653589793, 0)
		clone3.Parent = workspace.Effects
		_G.PU:Dust(clone3, 0.55)
		TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = createVector(1, 1, 35)
		}):Play()
		TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Quad), {
			Transparency = 1,
			CFrame = cFrame * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.Angles(
				0,
				0,
				6.283185307179586 * math.random()
			)
		}):Play()

		if v % 5 == 1 and v <= 30 then
			local clone4 = ReplicatedStorage.Chest.FruitEffect.Gura.Ring4:Clone()
			clone4.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone4.Size = createVector(5, 1, 5)
			clone4.Parent = workspace.Effects
			TweenService:Create(clone4, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Size = Vector3.new(55 - v / 50 * 35, 1.5, 55 - v / 50 * 35)
			}):Play()
			TweenService:Create(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone4, 1)
		end
	end)
	TweenService:Create(clone, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		Size = Vector3.new(),
		Transparency = 1
	}):Play()
	TweenService:Create(clone.Part, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
		Size = Vector3.new(),
		Transparency = 1
	}):Play()
	spawn(function()
		wait(0.5)
		clone:Destroy()
	end)

	for i = 0.7, 1, 0.15 do
		clone.Trail.Transparency = NumberSequence.new(i)
		wait()
	end
end