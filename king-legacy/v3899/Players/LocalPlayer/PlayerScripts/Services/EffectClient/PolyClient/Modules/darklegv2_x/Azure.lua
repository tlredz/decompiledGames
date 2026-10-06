local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local replicatedStorage2 = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeodizService = require(replicatedStorage.Chest.Modules.PeodizService)
local PeoUtils = require(replicatedStorage2.Chest.Modules.PeoUtils)
return function(data, _)
	local humanoidRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
	local up = data.up
	local down = data.down

	if game.Players.LocalPlayer == data.plr then
		_G.shake("SmallestBump")
		local orientation, v, v2 = humanoidRootPart.CFrame:ToOrientation()
		local _ = (up - down).Magnitude
		local cFrame = humanoidRootPart.CFrame
		PeodizService.Heartbeat({
			Time = 0.25,
			WaitTime = 0.03
		}, function(p)
			humanoidRootPart.CFrame = cFrame:Lerp(CFrame.new(up) * CFrame.fromOrientation(orientation, v, v2), p)
		end)
		task.spawn(function()
			wait(0.2)
			task.spawn(function()
				local clone = script.inverse:Clone()
				clone.Parent = game.Lighting
				clone.Enabled = true
				task.wait(0.15)
				clone:Destroy()
			end)
			wait(0.1)
			humanoidRootPart.CFrame = CFrame.new(down) * CFrame.fromOrientation(orientation, v, v2)
			_G.shake("Bump")
		end)
	end

	local clone = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.jumptrail:Clone()
	clone.Parent = workspace.Effects
	clone.CFrame = CFrame.new(down)
	clone.Azure:Emit(20)
	_G.PU:Dust(clone, 2)
	wait(0.2)
	local cframe = CFrame.new(up, down)
	local magnitude = (up - down).magnitude
	local clone2 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.LastKick.leg:Clone()
	clone2.Parent = workspace.Effects
	clone2.Size = createVector(0, 0, 22)
	clone2.CFrame = cframe * CFrame.Angles(0, 3.141592653589793, 0)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://8748164748",
		Volume = 2
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone2
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5801257793",
		Volume = 1.5
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone2
	sound2:Play()
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9597812848",
		Volume = 2
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone2
	sound3:Play()
	_G.PU:Dust(clone2, 2)
	TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = Vector3.new(4, 4, magnitude - 10) * 1.25
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = clone2.CFrame * CFrame.new(0, 0, magnitude / 2)
	}):Play()
	local pointLight = clone2.PointLight
	pointLight.Range = 40
	TweenService:Create(pointLight, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Brightness = 0,
		Range = pointLight.Range / 2
	}):Play()
	task.spawn(function()
		wait(0.1)
		TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(0, 0, 75)
		}):Play()
		wait(0.1)
		TweenService:Create(clone2, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
	local clone3 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.LastKick.FlameSpiral2:Clone()
	clone3.Parent = workspace.Effects
	clone3:SetPrimaryPartCFrame(cframe * CFrame.new(0, 0, -40))
	clone3.PrimaryPart.diable:Emit(25)
	clone3.PrimaryPart.diable2:Emit(20)
	clone3.PrimaryPart.Blast:Emit(10)
	clone3.PrimaryPart.Spec1:Emit(10)
	clone3.PrimaryPart.Spec2:Emit(25)
	task.spawn(function()
		local ModuleScript = require(clone3.ModuleScript)
		ModuleScript()
		_G.PU:Dust(clone3, 0.75)
	end)

	for _, part in pairs(clone3:GetChildren()) do
		if part:IsA("BasePart") and part ~= clone3.PrimaryPart then
			TweenService:Create(part, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = part.CFrame * CFrame.new(40, 0, 0)
			}):Play()
		end
	end

	local clone4 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.LastKick.WindRing:Clone()
	clone4.CFrame = cframe * CFrame.new(0, 0, -5) * CFrame.Angles(0, -1.5707963267948966, 0)
	clone4.Parent = workspace.Effects
	_G.PU:Dust(clone4, 1)
	task.spawn(function()
		local ModuleScript = require(clone4.ModuleScript)
		ModuleScript()
	end)
	local part = Instance.new("Part")
	part.CFrame = cframe
	part.Size = createVector(1, 1, 1)
	part.CanCollide = false
	part.Anchored = true
	part.Color = Color3.fromRGB(255, 0, 0)
	part.Transparency = 1
	part.Parent = workspace.Effects
	_G.PU:Dust(part, 1.5)
	local clone5 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.Azure.transfrom.Attachment:Clone()
	clone5.Parent = part
	clone5.Spark.Rotation = NumberRange.new(math.random(0, 180))
	task.spawn(function()
		local ModuleScript = require(clone5.ModuleScript)
		ModuleScript()
	end)
	task.spawn(function()
		local v = {
			createVector(0.9375, 70.45625, 70.45625),
			createVector(0.9375, 56.706253, 56.706253),
			createVector(0.9375, 42.5, 42.5),
			createVector(0.9375, 27.5, 27.5)
		}

		for i = 1, 4 do
			local clone6 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.Spectre.Azure.LastKick.Shockwave:Clone()
			clone6.CFrame = cframe * CFrame.new(0, 0, -magnitude / 4 * i) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(
				0,
				0,
				0
			) * CFrame.Angles(6.283185307179586 * math.random(), 0, 0)
			clone6.Size = Vector3.new()
			clone6.Parent = workspace.Effects
			TweenService:Create(clone6, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone6.CFrame * CFrame.new(-10, 0, 0) * CFrame.Angles(3.141592653589793, 0, 0)
			}):Play()
			TweenService:Create(clone6, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = v[i] * 1.25
			}):Play()
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
			clone2.Spark2:Emit(2.5)
			clone2.Spark:Emit(2.5)
			clone2.wave:Emit(2)
			wait()
			local clone7 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.Diable.Shockwave:Clone()
			clone7.CFrame = cframe * CFrame.new(0, 0, -magnitude / 4 * i) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(
				5,
				0,
				0
			) * CFrame.Angles(6.283185307179586 * math.random(), 0, 0)
			clone7.Size = Vector3.new()
			clone7.Color = Color3.fromRGB(103, 131, 172)
			clone7.Parent = workspace.Effects
			TweenService:Create(clone7, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone7.CFrame * CFrame.new(-15, 0, 0) * CFrame.Angles(3.141592653589793, 0, 0)
			}):Play()
			TweenService:Create(clone7, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = v[i] * 0.5
			}):Play()
			_G.PU:Dust(clone7, 1)
			task.spawn(function()
				wait(0.2)
				TweenService:Create(
					clone7,
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
			local clone6 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.sphere:Clone()
			clone6.CFrame = cframe * CFrame.new(math.random(-7, 7), math.random(-7, 7), -magnitude / 3) * CFrame.new(
				0,
				0,
				math.random(-5, 5)
			)
			clone6.Size = Vector3.new(1, 1, magnitude / 1.5)
			clone6.Transparency = -1
			clone6.Color = Color3.fromRGB(65, 179, 255)
			clone6.Parent = workspace.Effects
			TweenService:Create(clone6, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
			TweenService:Create(clone6, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone6.CFrame * CFrame.new(0, 0, -magnitude) * CFrame.new(0, 0, magnitude / 3)
			}):Play()
			_G.PU:Dust(clone6, 0.5)
			task.spawn(function()
				wait(0.15)
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
	local clone6 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.ChasingKick.Azure.Crack3:Clone()
	_G.PU:Dust(clone6, 6)
	clone6.Parent = workspace.Effects
	clone6.CFrame = CFrame.new(down)
	local ModuleScript = require(clone6.ModuleScript)
	ModuleScript()
	local sound4 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://8748164748",
		Volume = 2
	})
	_G.PU:Dust(sound4, 3)
	sound4.Parent = clone6
	sound4:Play()
	local sound5 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9201395294",
		Volume = 2
	})
	_G.PU:Dust(sound5, 3)
	sound5.Parent = clone6
	sound5:Play()
	local downcf = data.downcf
	local rock2 = require(script.rock2)
	rock2(downcf * CFrame.new(0, 1, 0))
	local rock = require(script.rock)
	rock(CFrame.new(down + createVector(0, 1, 0)))
end