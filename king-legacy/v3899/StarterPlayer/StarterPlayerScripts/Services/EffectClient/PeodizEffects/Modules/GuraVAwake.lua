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
		if (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude <= 150 then
			_G.CamShake("Gura1")
		end
	end)

	for i = 1, 2 do
		local v = i == 2 and -7.5 or 7.5
		coroutine.wrap(function()
			for i2 = 1, 9 do
				local v2 = i2
				spawn(function()
					local v3 = startCF * CFrame.new(v, 0, 0) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.Angles(
						0,
						0,
						6.283185307179586 * v2 / 9
					)
					local v4 = v3 * CFrame.new(0, 35, 0)
					local v5 = {}

					for i3 = 0, 7 do
						local cframe = CFrame.new(math.random(-100, 100) / 75, 0, 0)

						if i3 == 0 or i3 == 7 then
							cframe = CFrame.new()
						end

						local v6 = v3 * CFrame.new(0, (v3.Position - v4.Position).Magnitude / 9 * i3, 0) * cframe
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
							local TweenService = game:GetService("TweenService")
							TweenService:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
								Size = Vector3.new(0.15, 0.15, part.Size.Z)
							}):Play()
							local TweenService2 = game:GetService("TweenService")
							TweenService2:Create(part, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
								Transparency = 0.5
							}):Play()
							spawn(function()
								wait(2)
								local TweenService3 = game:GetService("TweenService")
								TweenService3:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Sine), {
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
end