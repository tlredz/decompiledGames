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
		if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude <= 120 then
			_G.CamShake("Gura1")
		end
	end)
	coroutine.wrap(function()
		for i = 1, 7 do
			local v = i
			spawn(function()
				local v2 = startCF * CFrame.Angles(0, 6.283185307179586 * v / 7, 0) - createVector(0, 2.5, 0)
				local v3 = v2 * CFrame.new(0, 0, 35)
				local v4 = {}

				for i2 = 0, 7 do
					local cframe = CFrame.new(math.random(-100, 100) / 25, 0, 0)

					if i2 == 0 or i2 == 7 then
						cframe = CFrame.new()
					end

					local v5 = v2 * CFrame.new(0, 0, (v2.Position - v3.Position).Magnitude / 7 * i2) * cframe
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
						part.Size = Vector3.new(2, 1, (v6.p - v7.p).Magnitude)
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
		local v = startCF
		PeodizService.ForLoop({
			Step = 20,
			WaitTime = 0.03
		}, function(p2)
			local v2 = math.floor(p2 * 20)
			task.spawn(function()
				local v3 = v * CFrame.new(math.random(-5, 5), 0, math.random(-5, 5))
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
	spawn(function()
		wait(0.1)
		local clone = ReplicatedStorage.Chest.FruitEffect.Gura.Shock4:Clone()
		clone.CFrame = startCF * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.75, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = createVector(200, 12.5, 200)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Sine), {
			CFrame = clone.CFrame * CFrame.Angles(0, 3.141592653589793, 0) + createVector(0, 5, 0),
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone, 1.5)
	end)
	local clone = ReplicatedStorage.Chest.FruitEffect.Gura.SFXPart2:Clone()
	_G.PU:Dust(clone, 3)
	clone.CFrame = startCF
	clone.Parent = workspace.Effects
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
		SoundId = "rbxassetid://6965944068",
		Volume = 1
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
	coroutine.wrap(function()
		for _ = 1, 4 do
			local clone2 = ReplicatedStorage.Chest.FruitEffect.Gura.Shock2:Clone()
			clone2.CFrame = startCF * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.3333333333333333, Enum.EasingStyle.Exponential), {
				Size = createVector(150, 20, 150)
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.Angles(0, math.rad((math.random(-360, 360))), 0) + createVector(
					0,
					30,
					0
				),
				Transparency = 1
			}):Play()
			_G.PU:Dust(clone2, 1.5)
			wait(0.05)
		end
	end)()
	PeodizService.ForLoop({
		Step = 25
	}, function(p2)
		local v = math.floor(p2 * 25)
		local v2 = CFrame.new(startCF.p) * CFrame.Angles(0, 6.283185307179586 * v / 25, 0) * CFrame.new(0, 0, -75)
		local ray = Ray.new(v2.p + createVector(0, 2.5, 0), createVector(0, -50, 0))
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
			part.Material = instance.Material
			part.MaterialVariant = instance.MaterialVariant
			part.BrickColor = instance.BrickColor
			part.CFrame = CFrame.new(startCF.X, position.Y, startCF.Z) * CFrame.Angles(
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random(),
				6.283185307179586 * math.random()
			)
			part.Size = createVector(5, 5, 5)
			part.Parent = workspace.Effects
			TweenService:Create(part, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {
				CFrame = CFrame.new(position) * CFrame.Angles(
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random(),
					6.283185307179586 * math.random()
				),
				Size = createVector(10, 10, 10)
			}):Play()
			spawn(function()
				wait(2)
				TweenService:Create(part, TweenInfo.new(1, Enum.EasingStyle.Sine), {
					CFrame = CFrame.new(position) * CFrame.Angles(
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random(),
						6.283185307179586 * math.random()
					) - createVector(0, 7.5, 0),
					Transparency = 1
				}):Play()
			end)
			_G.PU:Dust(part, 3)
		end
	end)
end