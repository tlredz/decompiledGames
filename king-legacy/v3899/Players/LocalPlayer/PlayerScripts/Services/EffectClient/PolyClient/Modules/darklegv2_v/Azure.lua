local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local replicatedStorage2 = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage2.Chest.Modules.PeoUtils)
return function(data, _)
	local localPlayer = game.Players.LocalPlayer
	local char = data.char
	local cf = data.cf

	if data.action and data.action == "kick" then
		local tocf = data.tocf
		local cf2 = data.cf

		if (localPlayer.Character.HumanoidRootPart.Position - tocf.p).Magnitude < 60 or game.Players.LocalPlayer == data.player then
			_G.shake("SmallBump")
		end

		task.spawn(function()
			for _ = 1, 5 do
				wait(0.6)

				if not ((localPlayer.Character.HumanoidRootPart.Position - tocf.p).Magnitude < 60 or game.Players.LocalPlayer == data.player) then
					continue
				end

				_G.shake("SmallBump")
			end
		end)
		local clone = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.LastKick.leg:Clone()
		clone.Parent = workspace.Effects
		clone.Size = createVector(0, 0, 22)
		clone.CFrame = cf2 * CFrame.Angles(0, 3.141592653589793, 0)
		_G.PU:Dust(clone, 2)
		TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(5, 5, 62.5)
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			CFrame = clone.CFrame * CFrame.new(0, 0, 50)
		}):Play()
		local pointLight = clone.PointLight
		pointLight.Range = 60
		TweenService:Create(pointLight, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Brightness = 0,
			Range = pointLight.Range / 2
		}):Play()
		task.spawn(function()
			wait(0.1)
			TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 75)
			}):Play()
			wait(0.1)
			TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end)
		local clone2 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.LastKick.FlameSpiral2:Clone()
		clone2.Parent = workspace.Effects
		clone2:SetPrimaryPartCFrame(cf2 * CFrame.new(0, 0, -30))
		clone2.PrimaryPart.diable:Emit(15)
		clone2.PrimaryPart.diable2:Emit(10)
		clone2.PrimaryPart.Blast:Emit(10)
		clone2.PrimaryPart.Spec1:Emit(10)
		clone2.PrimaryPart.Spec2:Emit(25)
		task.spawn(function()
			local ModuleScript = require(clone2.ModuleScript)
			ModuleScript()
			_G.PU:Dust(clone2, 0.75)
		end)

		for _, part in pairs(clone2:GetChildren()) do
			if part:IsA("BasePart") and part ~= clone2.PrimaryPart then
				TweenService:Create(part, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					CFrame = part.CFrame * CFrame.new(40, 0, 0)
				}):Play()
			end
		end

		local clone3 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.LastKick.WindRing:Clone()
		clone3.CFrame = cf2 * CFrame.new(0, 0, -5) * CFrame.Angles(0, -1.5707963267948966, 0)
		clone3.Parent = workspace.Effects
		_G.PU:Dust(clone3, 1)
		task.spawn(function()
			local ModuleScript = require(clone3.ModuleScript)
			ModuleScript()
		end)
		local part = Instance.new("Part")
		part.CFrame = cf2
		part.Size = createVector(1, 1, 1)
		part.CanCollide = false
		part.Anchored = true
		part.Color = Color3.fromRGB(255, 0, 0)
		part.Transparency = 1
		part.Parent = workspace.Effects
		_G.PU:Dust(part, 1.5)
		local clone4 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.LastKick.transfrom.Attachment:Clone()
		clone4.Parent = part
		clone4.Spark.Rotation = NumberRange.new(math.random(0, 180))
		task.spawn(function()
			local ModuleScript = require(clone4.ModuleScript)
			ModuleScript()
		end)
		task.spawn(function()
			local v = { createVector(1, 43.365, 43.365), createVector(1, 31, 31), createVector(1, 18, 18) }

			for i = 1, 3 do
				local clone5 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.LastKick.Shockwave:Clone()
				clone5.CFrame = cf2 * CFrame.new(0, 0, i * -25) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(
					0,
					0,
					0
				) * CFrame.Angles(6.283185307179586 * math.random(), 0, 0)
				clone5.Size = Vector3.new()
				clone5.Parent = workspace.Effects
				TweenService:Create(
					clone5,
					TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone5.CFrame * CFrame.new(-10, 0, 0) * CFrame.Angles(3.141592653589793, 0, 0)
					}
				):Play()
				TweenService:Create(
					clone5,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = v[i] * 1.25
					}
				):Play()
				_G.PU:Dust(clone5, 1)
				task.spawn(function()
					wait(0.2)
					TweenService:Create(
						clone5,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end)
				clone.Spark2:Emit(1)
				clone.Spark:Emit(1)
				clone.wave:Emit(2)
				wait()
				local clone6 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.LastKick.Shockwave:Clone()
				clone6.CFrame = cf2 * CFrame.new(0, 0, i * -25) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(
					5,
					0,
					0
				) * CFrame.Angles(6.283185307179586 * math.random(), 0, 0)
				clone6.Size = Vector3.new()
				clone6.Color = Color3.fromRGB(103, 131, 172)
				clone6.Parent = workspace.Effects
				TweenService:Create(
					clone6,
					TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone6.CFrame * CFrame.new(-15, 0, 0) * CFrame.Angles(3.141592653589793, 0, 0)
					}
				):Play()
				TweenService:Create(
					clone6,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = v[i] * 0.5
					}
				):Play()
				_G.PU:Dust(clone6, 1)
				task.spawn(function()
					wait(0.2)
					TweenService:Create(
						clone6,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end)
			end
		end)
		task.spawn(function()
			wait(math.random() * wait())

			for _ = 1, math.random(2, 3) do
				local clone5 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.LastKick.sphere:Clone()
				clone5.CFrame = cf2 * CFrame.new(math.random(-7, 7), math.random(-7, 7), -25) * CFrame.new(
					0,
					0,
					math.random(-5, 5)
				)
				clone5.Size = createVector(1, 1, 50)
				clone5.Transparency = -1
				clone5.Color = Color3.fromRGB(65, 179, 255)
				clone5.Parent = workspace.Effects
				TweenService:Create(
					clone5,
					TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = Vector3.new()
					}
				):Play()
				TweenService:Create(
					clone5,
					TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						CFrame = clone5.CFrame * CFrame.new(0, 0, -75) * CFrame.new(0, 0, 25)
					}
				):Play()
				_G.PU:Dust(clone5, 0.5)
				task.spawn(function()
					wait(0.15)
					TweenService:Create(
						clone5,
						TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end)
			end
		end)
		local clone5 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.Crack2:Clone()
		_G.PU:Dust(clone5, 6)
		clone5.CFrame = CFrame.new(tocf.p)
		clone5.Parent = workspace.Effects
		local ModuleScript = require(clone5.ModuleScript)
		ModuleScript()

		if (localPlayer.Character.HumanoidRootPart.Position - tocf.p).Magnitude < 60 or game.Players.LocalPlayer == data.player then
			task.spawn(function()
				local clone6 = script.inverse:Clone()
				clone6.Parent = game.Lighting
				clone6.Enabled = true
				task.wait(0.15)
				clone6:Destroy()
			end)
		end

		local rock = require(script.rock)
		rock(CFrame.new(tocf.p + createVector(0, 2, 0)))
	else
		local humanoidRootPart = char:FindFirstChild("HumanoidRootPart")

		if not humanoidRootPart then
			return
		end

		local sound = Instance.new("Sound", humanoidRootPart)
		sound.SoundId = "rbxassetid://6605151904"
		sound.MaxDistance = 600
		sound.Volume = 2.5
		sound.Looped = true
		sound:Play()
		sound.TimePosition = 0.55
		_G.PU:Dust(sound, 5)
		local lastTime = tick()
		tick()
		PeodizService.HeartbeatWait({
			Time = 4,
			WaitTime = 0.05
		}, function()
			if not (char:IsDescendantOf(workspace.PlayerCharacters) and char:FindFirstChild("RapidKick")) then
				return true
			end

			local humanoidRootPart2 = char:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return true
			end

			if tick() - lastTime > 0.2 then
				local sound2 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://8748164748",
					Volume = 1.75
				})
				_G.PU:Dust(sound2, 3)
				sound2.Parent = humanoidRootPart2
				sound2:Play()
				lastTime = tick()
			end

			if not char:FindFirstChild("RapidKick") then
				return true
			end

			if (localPlayer.Character.HumanoidRootPart.Position - cf.p).Magnitude < 20 or game.Players.LocalPlayer == data.player then
				_G.shake("SmallerBump")
			end

			local cFrame = humanoidRootPart2.CFrame

			for i = 1, 2 do
				local cframe = CFrame.Angles(math.rad((math.random(-10, 10))), math.rad((math.random(-10, 10))), 0)
				local clone = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.leg:Clone()
				clone.Parent = workspace.Effects
				clone.Size = createVector(0, 0, 13.5)
				clone.CFrame = cFrame * CFrame.Angles(0, 3.141592653589793, 0) * cframe
				clone.Anchored = false
				_G.PU:Dust(clone, 0.5)
				TweenService:Create(clone, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
					Size = createVector(2.1875, 2.1875, 31.25)
				}):Play()
				local v = i
				task.spawn(function()
					if v == 1 then
						local clone2 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.Shockwave:Clone()
						clone2.Size = createVector(2, 5, 5)
						clone2.Parent = workspace.Effects

						if tick() * 10 % 2 < 1 then
							clone2.Color = Color3.fromRGB(105, 149, 172)
						end

						local weld = Instance.new("Weld")
						weld.Parent = humanoidRootPart2
						weld.Part0 = humanoidRootPart2
						weld.Part1 = clone2
						weld.C0 = CFrame.new(0, 0, -30) * cframe * CFrame.Angles(0, 1.5707963267948966, 0)
						local TweenService2 = game:GetService("TweenService")
						TweenService2:Create(
							weld,
							TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								C0 = weld.C0 * CFrame.new(-30, 0, 0) * CFrame.Angles(3.141592653589793, 0, 0)
							}
						):Play()
						local TweenService3 = game:GetService("TweenService")
						TweenService3:Create(
							clone2,
							TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Size = createVector(2, 22, 22)
							}
						):Play()
						wait()
						local TweenService4 = game:GetService("TweenService")
						TweenService4:Create(
							clone2,
							TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Transparency = 1
							}
						):Play()
						local TweenService5 = game:GetService("TweenService")
						TweenService5:Create(
							clone2,
							TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
							{
								Size = createVector(0, 22, 22)
							}
						):Play()
						_G.PU:Dust(clone2, 0.5)
					end
				end)
				local clone2 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.FlameSpiral:Clone()
				clone2.Parent = workspace.Effects
				clone2:SetPrimaryPartCFrame(cFrame * CFrame.new(0, 0, -30) * cframe)
				clone2.PrimaryPart.Anchored = false
				clone2.PrimaryPart.diable:Emit(3)
				clone2.PrimaryPart.Blast:Emit(3)
				task.spawn(function()
					local ModuleScript = require(clone2.ModuleScript)
					ModuleScript()
					_G.PU:Dust(clone2, 0.75)
				end)

				for _, part in pairs(clone2:GetChildren()) do
					if not (part:IsA("BasePart") and part ~= clone2.PrimaryPart) then
						continue
					end

					part.Anchored = false
					local weld = Instance.new("Weld")
					weld.Parent = humanoidRootPart2
					weld.Part0 = humanoidRootPart2
					weld.Part1 = part
					weld.C0 = part.CFrame:Inverse() * clone2.PrimaryPart.CFrame * CFrame.Angles(
						0,
						-1.5707963267948966,
						0
					)
					weld.C0 *= CFrame.new(10, 0, 0)
					_G.PU:Dust(weld, 0.75)
					TweenService:Create(
						weld,
						TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							C0 = weld.C0 * CFrame.new(40, 0, 0)
						}
					):Play()
				end

				local weld = Instance.new("Weld")
				weld.Parent = humanoidRootPart2
				weld.Part0 = humanoidRootPart2
				weld.Part1 = clone2.PrimaryPart
				weld.C0 = CFrame.new(0, 0, -30) * cframe
				_G.PU:Dust(weld, 0.75)
				local weld2 = Instance.new("Weld")
				weld2.Parent = humanoidRootPart2
				weld2.Part0 = humanoidRootPart2
				weld2.Part1 = clone
				weld2.C0 = CFrame.Angles(0, 3.141592653589793, 0) * cframe
				_G.PU:Dust(weld2, 1)
				TweenService:Create(
					weld2,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						C0 = weld2.C0 * CFrame.new(0, 0, 40)
					}
				):Play()
				local pointLight = clone.PointLight
				TweenService:Create(
					pointLight,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Brightness = 0,
						Range = pointLight.Range / 2
					}
				):Play()
				task.spawn(function()
					wait(0.1)
					TweenService:Create(
						clone,
						TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Transparency = 1
						}
					):Play()
				end)
			end
		end)
		sound:Destroy()
		local sound2 = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://9201395294",
			Volume = 2
		})
		_G.PU:Dust(sound2, 3)
		sound2.Parent = humanoidRootPart
		sound2:Play()
		local sound3 = PeoUtils.CreateSound({
			RollOffMaxDistance = 500,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://5801257793",
			Volume = 1.5
		})
		_G.PU:Dust(sound3, 3)
		sound3.Parent = humanoidRootPart
		sound3:Play()
	end
end