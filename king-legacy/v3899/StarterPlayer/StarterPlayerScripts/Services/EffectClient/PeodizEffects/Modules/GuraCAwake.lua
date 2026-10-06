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
			spawn(function()
				_G.CamShake("Gura2")
				wait(0.2)
				_G.CamShake("Earthquake")
			end)
		end
	end)

	for i = 1, 2 do
		local v = i == 2 and -7.5 or 7.5
		coroutine.wrap(function()
			for i2 = 1, 7 do
				local v2 = i2
				spawn(function()
					local v3 = startCF * CFrame.new(v, 0, 0) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(
						0,
						0,
						6.283185307179586 * v2 / 7
					)
					local v4 = v3 * CFrame.new(0, 12.5, 0)
					local v5 = {}

					for i3 = 0, 7 do
						local cframe = CFrame.new(math.random(-100, 100) / 100, 0, 0)

						if i3 == 0 or i3 == 7 then
							cframe = CFrame.new()
						end

						local v6 = v3 * CFrame.new(0, (v3.Position - v4.Position).Magnitude / 7 * i3, 0) * cframe
						v5[#v5 + 1] = v6
					end

					PeodizService.ForceForLoop({
						Step = #v5
					}, function(p2)
						local v6 = math.floor(p2 * #v5)
						local v7 = v5[v6]
						local v8 = v5[v6 + 1]

						if v8 then
							local part = Instance.new("Part")
							part.Anchored = true
							part.CanCollide = false
							part.Material = "Glass"
							part.Reflectance = 10000
							part.BrickColor = BrickColor.new("Pastel Blue")
							part.Size = Vector3.new(1, 1, (v7.p - v8.p).Magnitude)
							part.CFrame = CFrame.new(v7.p, v8.p) * CFrame.new(0, 0, -(v7.p - v8.p).Magnitude / 2)
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
						table.clear(v5)
					end)
				end)
			end
		end)()
		local clone = ReplicatedStorage.Chest.FruitEffect.Gura.Ring5:Clone()
		clone.CFrame = startCF * CFrame.new(v, 0, 0) * CFrame.Angles(0, 0, 1.5707963267948966)
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
			Size = createVector(55, 1.5, 55)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.45, Enum.EasingStyle.Quint), {
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone, 1.5)
	end

	local clone = ReplicatedStorage.Chest.FruitEffect.Gura.SFXPart:Clone()
	clone.CFrame = startCF
	clone.Parent = workspace.Effects
	_G.PU:Dust(clone, 3)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5605730237",
		Volume = 1.6
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6948300574",
		PlaybackSpeed = 0.9,
		Volume = 2.5
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone
	sound2:Play()
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 300,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5503900614",
		Volume = 1
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone
	sound3:Play()
	local clone2 = ReplicatedStorage.Chest.FruitEffect.Gura.Shock5:Clone()
	clone2.CFrame = startCF * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
	clone2.Parent = workspace.Effects
	_G.PU:Dust(clone2, 5)
	TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
		Size = createVector(50, 10, 50)
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
		Transparency = 1,
		CFrame = clone2.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
	}):Play()

	for i = 1, 2 do
		local v = i
		spawn(function()
			local v2 = startCF * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(0, 0, -8.5)
			local v3

			if v == 2 then
				v2 = startCF * CFrame.Angles(0, -1.5707963267948966, 0) * CFrame.new(0, 0, -8.5)
				v3 = 1.2566370614359172
			else
				v3 = -1.2566370614359172
			end

			for i2 = 0, 4 do
				local v4 = i2
				coroutine.wrap(function()
					local v5 = v2 * CFrame.Angles(0, v3 + 2.6179938779914944 * v4 / 4, 0)

					if v == 2 then
						v5 = v2 * CFrame.Angles(0, v3 - 2.6179938779914944 * v4 / 4, 0)
					end

					PeodizService.ForLoop({
						Step = 7,
						WaitTime = 0.15
					}, function(p2)
						local v6 = math.floor(p2 * 7)
						local v7 = v5 * CFrame.new(0, 0, v6 * -10.714285714285714)
						local ray = Ray.new(v7.Position, createVector(0, -25, 0))
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
							local part = Instance.new("Part")
							part.Anchored = true
							part.CanCollide = false
							part.CFrame = CFrame.new(position) - createVector(0, 10, 0)
							part.Size = createVector(6.5, 6.5, 6.5)
							part.Material = instance.Material
							part.MaterialVariant = instance.MaterialVariant
							part.BrickColor = instance.BrickColor
							part.Parent = workspace.Effects
							TweenService:Create(part, TweenInfo.new(1.2, Enum.EasingStyle.Quad), {
								CFrame = CFrame.new(position) * CFrame.Angles(
									6.283185307179586 * math.random(),
									6.283185307179586 * math.random(),
									6.283185307179586 * math.random()
								)
							}):Play()
							spawn(function()
								wait(3.5)
								TweenService:Create(part, TweenInfo.new(1.2, Enum.EasingStyle.Quad), {
									CFrame = CFrame.new(position) * CFrame.Angles(
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random(),
										6.283185307179586 * math.random()
									) - createVector(0, 10, 0)
								}):Play()
							end)
							_G.PU:Dust(part, 5)
						end
					end)
				end)()
			end
		end)
	end

	spawn(function()
		local v = startCF
		PeodizService.ForLoop({
			Step = 10,
			WaitTime = 0.03
		}, function(p2)
			local v2 = math.floor(p2 * 10)
			local v3 = v * CFrame.new(math.random(-5, 5), 0, math.random(-5, 5))
			task.spawn(function()
				PeodizService.ForceForLoop({
					Step = 9
				}, function(p3)
					local v4 = math.floor(p3 * 9)
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
			end)
		end)
	end)
end