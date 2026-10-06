local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local replicatedStorage2 = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeodizService = require(game.ReplicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage2.Chest.Modules.PeoUtils)
return function(data, _)
	local localPlayer = game.Players.LocalPlayer
	local cf = data.cf
	local tocf = data.tocf

	if (localPlayer.Character.HumanoidRootPart.Position - cf.p).Magnitude < 45 or game.Players.LocalPlayer == data.plr then
		_G.shake("Bump")
	end

	task.spawn(function()
		if game.Players.LocalPlayer == data.plr then
			localPlayer.Character.HumanoidRootPart.CFrame = tocf * CFrame.new(0, 2.45, 0)
			local part = Instance.new("Part")
			part.CFrame = cf
			part.Size = createVector(5, 5, 5)
			part.CanCollide = false
			part.Anchored = true
			part.Color = Color3.fromRGB(255, 0, 0)
			part.Transparency = 1
			part.Name = "Cam"
			part.Parent = workspace.Effects
			_G.PU:Dust(part, 1)
			workspace.CurrentCamera.CameraSubject = part
			TweenService:Create(part, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = tocf
			}):Play()
			wait(0.3)
			workspace.CurrentCamera.CameraSubject = localPlayer.Character.Humanoid
		end
	end)
	local tocf2 = data.tocf
	local cf2 = data.cf
	local range = data.range
	local clone = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.LastKick.leg:Clone()
	_G.PU:Dust(clone, 2)
	clone.Parent = workspace.Effects
	clone.Size = createVector(0, 0, 22)
	clone.CFrame = cf2 * CFrame.Angles(0, 3.141592653589793, 0)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://8748164748",
		Volume = 2
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5801257793",
		Volume = 1.5
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone
	sound2:Play()
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9597812848",
		Volume = 2
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone
	sound3:Play()
	TweenService:Create(clone, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = Vector3.new(5, 5, range - 10) * 1.25
	}):Play()
	TweenService:Create(clone, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = clone.CFrame * CFrame.new(0, 0, 50)
	}):Play()
	local pointLight = clone.PointLight
	pointLight.Range = 75
	TweenService:Create(pointLight, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Brightness = 0,
		Range = pointLight.Range / 2
	}):Play()
	task.spawn(function()
		wait(0.1)
		TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(0, 0, range) * 1.25
		}):Play()
		wait(0.1)
		TweenService:Create(clone, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
	local clone2 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.LastKick.FlameSpiral2:Clone()
	clone2.Parent = workspace.Effects
	clone2:SetPrimaryPartCFrame(cf2 * CFrame.new(0, 0, -30))
	clone2.PrimaryPart.diable:Emit(25)
	clone2.PrimaryPart.diable2:Emit(20)
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
		local v = {
			createVector(1.125, 84.5475, 84.5475),
			createVector(1.125, 68.0475, 68.0475),
			createVector(1.125, 51, 51),
			createVector(1.125, 33, 33)
		}

		for i = 1, 4 do
			local clone5 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.LastKick.Shockwave:Clone()
			clone5.CFrame = cf2 * CFrame.new(0, 0, -range / 4 * i) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(
				0,
				0,
				0
			) * CFrame.Angles(6.283185307179586 * math.random(), 0, 0)
			clone5.Size = Vector3.new()
			clone5.Parent = workspace.Effects
			TweenService:Create(clone5, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone5.CFrame * CFrame.new(-10, 0, 0) * CFrame.Angles(3.141592653589793, 0, 0)
			}):Play()
			TweenService:Create(clone5, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = v[i] * 1.25
			}):Play()
			_G.PU:Dust(clone5, 1)
			task.spawn(function()
				wait(0.25)
				TweenService:Create(
					clone5,
					TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
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
			clone6.CFrame = cf2 * CFrame.new(0, 0, -range / 4 * i) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(
				5,
				0,
				0
			) * CFrame.Angles(6.283185307179586 * math.random(), 0, 0)
			clone6.Size = Vector3.new()
			clone6.Color = Color3.fromRGB(103, 131, 172)
			clone6.Parent = workspace.Effects
			TweenService:Create(clone6, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone6.CFrame * CFrame.new(-20, 0, 0) * CFrame.Angles(3.141592653589793, 0, 0)
			}):Play()
			TweenService:Create(clone6, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = v[i] * 0.75
			}):Play()
			_G.PU:Dust(clone6, 1)
			task.spawn(function()
				wait(0.25)
				TweenService:Create(
					clone6,
					TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
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
			clone5.CFrame = cf2 * CFrame.new(math.random(-7, 7), math.random(-7, 7), -range / 3) * CFrame.new(
				0,
				0,
				math.random(-5, 5)
			)
			clone5.Size = Vector3.new(3, 3, range / 1.5)
			clone5.Transparency = -1
			clone5.Color = Color3.fromRGB(65, 179, 255)
			clone5.Parent = workspace.Effects
			TweenService:Create(clone5, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
			TweenService:Create(clone5, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone5.CFrame * CFrame.new(0, 0, -range) * CFrame.new(0, 0, range / 3)
			}):Play()
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
	wait()
	task.spawn(function()
		local clone5 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.Shockwave2:Clone()
		clone5.Size = createVector(2.5, 5, 5)
		clone5.Position = tocf2.p + createVector(0, 11, 0)
		clone5.Parent = workspace.Effects
		clone5.Color = Color3.fromRGB(83, 138, 255)
		clone5.Transparency = 0.25
		clone5.Material = Enum.Material.Neon
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(clone5, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(10, 100, 100),
			Orientation = clone5.Orientation + createVector(0, 180, 0)
		}):Play()
		task.wait(0.3)
		local TweenService3 = game:GetService("TweenService")
		TweenService3:Create(clone5, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = createVector(0, 105, 105),
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone5, 0.5)
	end)
	task.spawn(function()
		wait(0.1)
		local clone5 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.Shockwave2:Clone()
		clone5.Size = createVector(2, 4, 4)
		clone5.Position = tocf2.p + createVector(0, 25, 0)
		clone5.Parent = workspace.Effects
		clone5.Color = Color3.fromRGB(98, 148, 255)
		clone5.Transparency = 0.25
		clone5.Material = Enum.Material.Neon
		local TweenService2 = game:GetService("TweenService")
		TweenService2:Create(
			clone5,
			TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out, 0, true, 0),
			{
				Size = createVector(4, 60, 60),
				Position = tocf2.p + createVector(0, 40, 0),
				Orientation = clone5.Orientation + createVector(0, 180, 0)
			}
		):Play()
		task.wait(0.3)
		local TweenService3 = game:GetService("TweenService")
		TweenService3:Create(clone5, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = createVector(0, 70, 70),
			Transparency = 1
		}):Play()
		_G.PU:Dust(clone5, 0.5)
	end)
	task.spawn(function()
		if (localPlayer.Character.HumanoidRootPart.Position - tocf2.p).Magnitude < 75 or game.Players.LocalPlayer == data.player then
			local clone5 = script.inverse:Clone()
			clone5.Parent = game.Lighting
			clone5.Enabled = true
			task.wait(0.1)
			clone5:Destroy()
		end
	end)
	task.spawn(function()
		local clone5 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.Azure.Explosion.Crack3:Clone()
		clone5.Parent = workspace.Effects
		clone5.CFrame = CFrame.new(tocf2.p)
		_G.PU:Dust(clone5, 2)
		local ModuleScript = require(clone5.ModuleScript)
		ModuleScript()
	end)

	if (localPlayer.Character.HumanoidRootPart.Position - tocf2.p).Magnitude < 75 or game.Players.LocalPlayer == data.plr then
		_G.shake("Bump")
	end

	local clone5 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.Azure.Explosion.core:Clone()
	clone5.Parent = workspace.Effects
	clone5.CFrame = CFrame.new(tocf2.p)
	_G.PU:Dust(clone5, 2.5)
	local clone6 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.Azure.Explosion.sparko:Clone()
	clone6.Parent = workspace.Effects
	clone6.CFrame = CFrame.new(tocf2.p)
	_G.PU:Dust(clone6, 2.5)
	local clone7 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.Azure.Explosion.sparkup:Clone()
	clone7.Parent = workspace.Effects
	clone7.CFrame = CFrame.new(tocf2.p)
	_G.PU:Dust(clone7, 2.5)
	clone7.Lines:Emit(35)
	clone7.Lines:Emit(35)
	clone5.Attachment2.Ring:Emit(3)
	clone5.Attachment2.Ball:Emit(1)
	clone5.Attachment2.big:Emit(3)
	clone5.Attachment2.Spark2:Emit(3)
	clone5.Attachment2.sparkl2:Emit(10)
	clone5.Attachment2.sparkl1:Emit(10)
	clone5.Attachment2.spark:Emit(25)
	clone5.Attachment2.pillar:Emit(15)
	clone5.Attachment.Spark2:Emit(5)
	wait(0.35)
	clone6.spark3:Emit(40)
	clone6.specs:Emit(30)
	clone5.Attachment3.big:Emit(2)
	clone5.Attachment3.Ring:Emit(2)
	clone5.Attachment3.Ball:Emit(2)
	task.spawn(function()
		wait(0.1)
		clone5.Attachment2.sparkl3:Emit(15)
		wait(0.1)
		local v = {
			1,
			2,
			3,
			4,
			5,
			6,
			7
		}
		clone7.Lines:Emit(15)
		clone7.Lines:Emit(15)

		local function Shuffle(list)
			for i = 1, #list - 1 do
				local v2 = math.random(i, #list)
				local v3 = list[v2]
				local v4 = list[i]
				list[i] = v3
				list[v2] = v4
			end
		end

		Shuffle(v)
		task.spawn(function()
			PeodizService.ForLoop({
				Step = 7,
				WaitTime = 0.1
			}, function(p)
				local v2 = math.floor(p * 7)
				local clone8 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.Azure.Explosion.miniflare:Clone()
				clone8.CFrame = CFrame.new(tocf2.p) * CFrame.new(math.random(-15, 15), v[v2] * 12, math.random(-15, 15))
				clone8.Parent = workspace.Effects
				clone8.Attachment.big:Emit(1)
				clone8.Attachment.ring:Emit(1)
				_G.PU:Dust(clone8, 1)

				if v2 % 2 == 1 then
					local sound4 = PeoUtils.CreateSound({
						RollOffMaxDistance = 1000,
						RollOffMinDistance = 10,
						RollOffMode = Enum.RollOffMode.InverseTapered,
						SoundId = "rbxassetid://9769503074",
						Volume = 4.5
					})
					_G.PU:Dust(sound4, 3)
					sound4.Parent = clone8
					sound4:Play()
					_G.PU:Dust(clone8, 1)
				end
			end)
		end)

		if (localPlayer.Character.HumanoidRootPart.Position - tocf2.p).Magnitude < 75 or game.Players.LocalPlayer == data.player then
			local clone8 = script.inverse:Clone()
			clone8.Parent = game.Lighting
			clone8.Enabled = true
			task.wait(0.2)
			clone8.Contrast = 1
			task.wait(0.15)
			task.spawn(function()
				local clone9 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.Shockwave2:Clone()
				clone9.Size = createVector(3, 7, 7)
				clone9.Position = tocf2.p + createVector(0, 10, 0)
				clone9.Parent = workspace.Effects
				clone9.Color = Color3.fromRGB(83, 138, 255)
				clone9.Transparency = 0.25
				clone9.Material = Enum.Material.Neon
				local TweenService2 = game:GetService("TweenService")
				TweenService2:Create(
					clone9,
					TweenInfo.new(0.8, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Size = createVector(10, 120, 120),
						Orientation = clone9.Orientation + createVector(0, 180, 0)
					}
				):Play()
				task.wait(0.4)
				local TweenService3 = game:GetService("TweenService")
				TweenService3:Create(clone9, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = createVector(0, 125, 125),
					Transparency = 1
				}):Play()
				_G.PU:Dust(clone9, 0.5)
			end)
			_G.PU:Dust(clone8, 0.2)

			if (localPlayer.Character.HumanoidRootPart.Position - tocf2.p).Magnitude < 75 or game.Players.LocalPlayer == data.plr then
				_G.shake("Bump")
			end

			task.spawn(function()
				local clone9 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.Azure.Explosion.Crack4:Clone()
				_G.PU:Dust(clone9, 2.5)
				clone9.Parent = workspace.Effects
				clone9.CFrame = CFrame.new(tocf2.p)
				local sound4 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://9769505023",
					Volume = 2.5
				})
				_G.PU:Dust(sound4, 3)
				sound4.Parent = clone9
				sound4:Play()
				local sound5 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://9769509877",
					PlaybackSpeed = 0.85,
					Volume = 2.5
				})
				_G.PU:Dust(sound5, 3)
				sound5.Parent = clone9
				sound5:Play()
				local sound6 = PeoUtils.CreateSound({
					RollOffMaxDistance = 1000,
					RollOffMinDistance = 10,
					RollOffMode = Enum.RollOffMode.InverseTapered,
					SoundId = "rbxassetid://8748164748",
					Volume = 2
				})
				_G.PU:Dust(sound6, 3)
				sound6.Parent = clone9
				sound6:Play()
				local ModuleScript = require(clone9.ModuleScript)
				ModuleScript()
			end)
			local clone9 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.Azure.Explosion.explode:Clone()
			clone9.Parent = workspace.Effects
			clone9.CFrame = CFrame.new(tocf2.p)
			_G.PU:Dust(clone9, 1.5)
			clone9.Attachment4.Ring:Emit(2)
			clone9.Attachment4.Spark2:Emit(2)
			clone9.Attachment4.spark:Emit(20)
			clone9.Attachment4.sparkl2:Emit(10)
			clone9.Attachment4.sparkl1:Emit(10)
			clone9.Attachment4.Ball:Emit(1)
			clone9.Attachment4.specs:Emit(20)
			clone9.Attachment4.big:Emit(10)
			clone9.Attachment4.glow:Emit(20)
			clone9.Attachment4.smoke:Emit(20)
			clone9.Attachment4.wind:Emit(2)
			clone9.Attachment4.pillar:Emit(15)
			clone9.Attachment4.Spark:Emit(5)
			local rock = require(script.rock)
			rock(CFrame.new(tocf2.p + createVector(0, 2, 0)))
		end
	end)
end