local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local replicatedStorage2 = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeoUtils = require(replicatedStorage2.Chest.Modules.PeoUtils)
return function(data, _)
	local humanoidRootPart = game.Players.LocalPlayer.Character.HumanoidRootPart
	local up = data.up
	local down = data.down

	if game.Players.LocalPlayer == data.plr then
		_G.shake("SmallestBump")
		local orientation, v, v2 = humanoidRootPart.CFrame:ToOrientation()
		TweenService:Create(
			humanoidRootPart,
			TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
			{
				CFrame = CFrame.new(up) * CFrame.fromOrientation(orientation, v, v2)
			}
		):Play()
		task.spawn(function()
			wait(0.3)
			humanoidRootPart.CFrame = CFrame.new(down) * CFrame.fromOrientation(orientation, v, v2)
			_G.shake("Bump")
		end)
	end

	local clone = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.jumptrail:Clone()
	clone.Parent = workspace.Effects
	clone.CFrame = CFrame.new(down)
	clone.Diable:Emit(20)
	_G.PU:Dust(clone, 2)
	wait(0.2)
	local cframe = CFrame.new(up, down)
	local magnitude = (up - down).magnitude
	local clone2 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.Diable.leg:Clone()
	_G.PU:Dust(clone2, 2)
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
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9597812848",
		Volume = 2
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone2
	sound3:Play()
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
	local clone3 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.Diable.FlameSpiral2:Clone()
	clone3.Parent = workspace.Effects
	clone3:SetPrimaryPartCFrame(cframe * CFrame.new(0, 0, -40))
	clone3.PrimaryPart.diable:Emit(15)
	clone3.PrimaryPart.diable2:Emit(10)
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

	local clone4 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.WindRing:Clone()
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
	local clone5 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.Diable.transfrom.Attachment:Clone()
	clone5.Parent = part
	clone5.Spark.Rotation = NumberRange.new(math.random(0, 180))
	task.spawn(function()
		local ModuleScript = require(clone5.ModuleScript)
		ModuleScript()
	end)
	task.spawn(function()
		local v = { createVector(0.75, 56.365, 56.365), createVector(0.75, 45.365, 45.365), createVector(
				0.75,
				34,
				34
			) }

		for i = 1, 3 do
			local clone6 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.CometAssault.Diable.Shockwave:Clone()
			clone6.CFrame = cframe * CFrame.new(0, 0, -magnitude / 3 * i) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(
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
			clone7.CFrame = cframe * CFrame.new(0, 0, -magnitude / 3 * i) * CFrame.Angles(0, 1.5707963267948966, 0) * CFrame.new(
				5,
				0,
				0
			) * CFrame.Angles(6.283185307179586 * math.random(), 0, 0)
			clone7.Size = Vector3.new()
			clone7.Color = Color3.fromRGB(172, 121, 108)
			clone7.Parent = workspace.Effects
			TweenService:Create(clone7, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
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
			clone6.Color = Color3.fromRGB(255, 91, 70)
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
	local clone6 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.ChasingKick.Diable.Crack:Clone()
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
	local rock = require(script.rock)
	rock(CFrame.new(down + createVector(0, 1, 0)))
end