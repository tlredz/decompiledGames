local _ = game.ReplicatedStorage
local replicatedStorage = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
game:GetService("RunService")
return function(data, _)
	local localPlayer = game.Players.LocalPlayer

	-- equivalent calls inferred from this helper; original call sites unknown
	local function localshake(p)
		if localPlayer == data.plr then
			_G.shake(p)
		end
	end

	local function rangeshake(p, value)
		if (value or 100) > (localPlayer.Character.HumanoidRootPart.Position - data.cf.p).Magnitude then
			_G.shake(p)
		end
	end

	local function local_rangeshake(p, value, p2)
		task.spawn(function()
			value = value or 100

			if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < value then
				_G.shake(p)
			end
		end)
	end

	local cf = data.cf
	local _ = data.value

	if data.mode == "Heal" then
		local clone = replicatedStorage.Chest.SwordEffect.Avalon.heal_part1:Clone()
		_G.PU:Dust(clone, 2.5)
		clone.Parent = workspace.Effects
		clone.CFrame = cf
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://14039914598",
			Volume = 2
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()
		local clone2 = replicatedStorage.Chest.SwordEffect.Avalon.heal_part2:Clone()
		_G.PU:Dust(clone2, 2.5)
		clone2.CFrame = cf * CFrame.new(0, 15, 0)
		clone2.Parent = workspace.Effects
		localshake("SmallerBump") -- equivalent call inferred; original call site unknown

		for _, emitter in pairs(clone.Attachment2:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end

		wait(0.2)

		for _, emitter in pairs(clone.Attachment:GetChildren()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end

		for _, emitter in pairs(clone2:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
			end
		end

		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://14039911485",
			Volume = 1
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = clone2
		sound2:Play()
		task.spawn(function()
			PeodizService.ForLoop({
				Step = 12
			}, function(p)
				local v = math.floor(p * 12)
				local clone3 = replicatedStorage.Chest.SwordEffect.Avalon.flower:Clone()
				clone3.CFrame = cf * CFrame.new(0, -0.3333333333333333, 0) * CFrame.Angles(0, 0.8975979010256552 * v, 0) * CFrame.new(
					0,
					0,
					math.random(5, 35)
				) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
				clone3.Parent = workspace.Effects
				clone3.Size = clone3.Size * math.random(40, 70) / 100
				clone3.Transparency = 1
				local clone4 = clone3:Clone()
				clone4.Parent = clone3
				clone4.Material = Enum.Material.Neon
				clone4.Transparency = 1
				clone4.Color = Color3.fromRGB(74, 255, 101)
				clone3.Size *= 0.9
				clone4.Size *= 0.9
				local clone5 = replicatedStorage.Chest.SwordEffect.Avalon.flower_fx:Clone()
				clone5.Parent = workspace.Effects
				clone5.CFrame = clone3.CFrame
				_G.PU:Dust(clone5, 2)
				clone5.SmallSparksLonger:Emit(math.random(5, 7))
				TweenService:Create(
					clone5,
					TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone5.CFrame * CFrame.Angles(0, 2.0943951023931953, 0)
					}
				):Play()
				TweenService:Create(clone4, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Transparency = 0
				}):Play()
				TweenService:Create(clone4, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = clone4.Size * 1.1
				}):Play()
				TweenService:Create(clone3, TweenInfo.new(0.75, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = clone3.Size * 1.1
				}):Play()
				task.spawn(function()
					wait(0.025)
					TweenService:Create(clone4, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						CFrame = clone4.CFrame * CFrame.new(0, 0.3333333333333333, 0)
					}):Play()
					TweenService:Create(clone3, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						CFrame = clone3.CFrame * CFrame.new(0, 0.3333333333333333, 0)
					}):Play()
					wait(0.1)
					TweenService:Create(
						clone3,
						TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 0
						}
					):Play()
					TweenService:Create(
						clone4,
						TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
					wait(0.75 + math.random(10, 50) / 100)
					TweenService:Create(
						clone3,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end)
				_G.PU:Dust(clone3, 2.2)
			end)
		end)
		TweenService:Create(clone2, TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone2.CFrame * CFrame.Angles(0, 2.0943951023931953, 0)
		}):Play()
		local pointLight = Instance.new("PointLight")
		pointLight.Color = Color3.fromRGB(60, 255, 0)
		pointLight.Range = 60
		pointLight.Brightness = 1
		pointLight.Parent = clone
		TweenService:Create(pointLight, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Brightness = 0.5,
			Range = 0
		}):Play()
		localshake("SmallBump2") -- equivalent call inferred; original call site unknown
		local clone3 = replicatedStorage.Chest.SwordEffect.Avalon.buff_Heal2:Clone()
		clone3.CFrame = cf
		clone3.Parent = workspace.Effects
		_G.PU:Dust(clone3, 2)
		clone3.Attachment.buff:Emit(1)
		wait(0.72)
		_G.shake("SmallestBump")
		local sound3 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://14050585700",
			Volume = 3
		})
		_G.PU:Dust(sound3, 3)
		sound3.Parent = clone3
		sound3:Play()
		clone3.Attachment2.SmallSparksLonger:Emit(math.random(8, 12))
		TweenService:Create(clone3, TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone3.CFrame * CFrame.Angles(0, 2.0943951023931953, 0)
		}):Play()
	else
		local v = { Color3.fromRGB(141, 0, 0), Color3.fromRGB(125, 0, 0), Color3.fromRGB(177, 0, 0) }
		local clone = replicatedStorage.Chest.SwordEffect.Avalon.buff_Damage:Clone()
		clone.CFrame = cf
		clone.Parent = workspace.Effects
		_G.PU:Dust(clone, 2)
		clone.Attachment.buff:Emit(1)
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://14076513318",
			Volume = 3.5
		})
		_G.PU:Dust(sound, 3)
		sound.Parent = clone
		sound:Play()

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end
		end

		localshake("SmallerBump") -- equivalent call inferred; original call site unknown
		wait(0.2)
		PeodizService.ForLoop({
			Step = 25
		}, function(p)
			local v2 = math.floor(p * 25)
			local v3 = cf * data.cf2[v2]
			local v4 = v3 * data.cf3[v2]
			local clone2 = replicatedStorage.Chest.SwordEffect.Avalon.arrow:Clone()
			clone2.Parent = workspace.Effects
			clone2.CFrame = v4 * CFrame.new(0, 97, 0) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
			clone2.Size = clone2.Size * math.random(150, 175) / 100
			clone2.Color = v[math.random(1, #v)]
			_G.PU:Dust(clone2, 1)
			local sound2 = PeoUtils.CreateSound({
				RollOffMaxDistance = 1000,
				RollOffMinDistance = 10,
				RollOffMode = Enum.RollOffMode.InverseTapered,
				SoundId = "rbxassetid://14073525743",
				Volume = 1,
				TimePosition = 0.5
			})
			_G.PU:Dust(sound2, 3)
			sound2.Parent = clone2
			sound2:Play()
			task.spawn(function()
				wait(0.25)
				TweenService:Create(
					clone2,
					TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
			TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.new(0, -90, 0)
			}):Play()
			wait()
			local v5 = 20
			local p2 = v3.p
			local v6 = "SmallBump2"
			task.spawn(function()
				v5 = v5 or 100

				if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - p2).Magnitude < v5 then
					_G.shake(v6)
				end
			end)
			local clone3 = replicatedStorage.Chest.SwordEffect.Avalon.exp:Clone()
			clone3.Parent = workspace.Effects
			clone3.CFrame = v3 * CFrame.new(0, 1, 0)
			_G.PU:Dust(clone3, 1)

			for _, emitter in pairs(clone3:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end
		end)
	end
end