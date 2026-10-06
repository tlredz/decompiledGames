local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local replicatedStorage2 = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeoUtils = require(replicatedStorage2.Chest.Modules.PeoUtils)
return function(data, _)
	local localPlayer = game.Players.LocalPlayer
	local cf = data.cf
	local tocf = data.tocf

	if game.Players.LocalPlayer == data.plr then
		_G.shake("SmallestBump")
	end

	task.spawn(function()
		wait(0.085)

		if game.Players.LocalPlayer == data.plr then
			localPlayer.Character.HumanoidRootPart.CFrame = tocf
		end

		wait(0.115)

		if (localPlayer.Character.HumanoidRootPart.Position - tocf.p).Magnitude < 60 or game.Players.LocalPlayer == data.plr then
			_G.shake("Bump")
		end
	end)
	local clone = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.ChasingKick.Diable.teleport:Clone()
	clone.Parent = workspace.Effects
	clone.CFrame = cf
	clone.Attachment.Spark:Emit(2)
	clone.Attachment.big:Emit(20)
	clone.Attachment.specs:Emit(20)
	clone.Attachment.Ring:Emit(2)
	clone.Attachment.spark:Emit(12)
	clone.Attachment.Spark:Emit(2)
	clone.Attachment.spark2:Emit(7)
	clone.Attachment.wind:Emit(6)
	clone.Attachment.glow:Emit(5)
	clone.Attachment.Blast:Emit(5)
	_G.PU:Dust(clone, 2)
	local magnitude = (cf.p - tocf.p).Magnitude
	local clone2 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.ChasingKick.Diable.transition:Clone()
	clone2.CFrame = cf
	clone2.Parent = workspace.Effects
	clone2.spark3:Emit(5)
	clone2.specs:Emit(15)
	_G.PU:Dust(clone2, 1)
	task.spawn(function()
		for _ = 1, math.random(3, 4) do
			local clone3 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.ChasingKick.Diable.sphere:Clone()
			clone3.CFrame = CFrame.new(cf.p, tocf.p) * CFrame.new(
				math.random(-8, 8),
				math.random(-8, 8),
				-magnitude / 3
			) * CFrame.new(0, 0, math.random(-5, 5))
			clone3.Size = Vector3.new(1, 1, magnitude / 1.5)
			clone3.Transparency = -1
			clone3.Color = Color3.fromRGB(255, 121, 76)
			clone3.Parent = workspace.Effects
			TweenService:Create(clone3, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
			TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone3.CFrame * CFrame.new(0, 0, -magnitude) * CFrame.new(0, 0, magnitude / 3)
			}):Play()
			_G.PU:Dust(clone3, 0.6)
			task.spawn(function()
				wait(0.15)
				TweenService:Create(
					clone3,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
		end
	end)
	local clone3 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.ChasingKick.Diable.Shockwave:Clone()
	clone3.CFrame = CFrame.new(cf.p, tocf.p) * CFrame.new(0, 0, -40) * CFrame.Angles(0, 1.5707963267948966, 0)
	clone3.Size = createVector(0, 0, 0)
	clone3.Color = Color3.fromRGB(255, 102, 71)
	clone3.Parent = workspace.Effects
	clone3.Material = Enum.Material.Neon
	TweenService:Create(clone3, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = clone3.CFrame * CFrame.new(-35, 0, 0) * CFrame.Angles(3.141592653589793, 0, 0)
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(2, 45, 45)
	}):Play()
	_G.PU:Dust(clone3, 1)
	task.spawn(function()
		wait(0.2)
		TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
	local clone4 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.ChasingKick.Diable.sphere:Clone()
	_G.PU:Dust(clone4, 3)
	clone4.CFrame = CFrame.new(cf.p, tocf.p) * CFrame.new(0, 0, 0)
	clone4.Size = createVector(8, 8, 0)
	clone4.Transparency = 0
	clone4.Color = Color3.fromRGB(255, 121, 76)
	clone4.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 50,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5169902349",
		PlaybackSpeed = 2.25,
		Volume = 0.75
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone4
	sound:Play()
	TweenService:Create(clone4, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = Vector3.new(5, 5, magnitude)
	}):Play()
	TweenService:Create(clone4, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = CFrame.new(cf.p, tocf.p) * CFrame.new(0, 0, -magnitude / 2)
	}):Play()
	_G.PU:Dust(clone4, 1.25)
	task.spawn(function()
		wait()
		clone4.wave:Emit(5)
		clone4.wave2:Emit(7)
		clone4.Spark:Emit(10)
		clone4.Spark2:Emit(15)
		clone4.Spark3:Emit(15)
		TweenService:Create(clone4, TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(0, 0, magnitude)
		}):Play()
		wait(0.25)
		TweenService:Create(clone4, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
	wait(0.085)
	local cframe = CFrame.new(tocf.p, tocf.p - createVector(0, 1, 0))
	local clone5 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.ChasingKick.Diable.teleport2:Clone()
	clone5.Parent = workspace.Effects
	clone5.CFrame = tocf
	clone5.Attachment.Spark:Emit(2)
	clone5.Attachment.big:Emit(10)
	clone5.Attachment.specs:Emit(8)
	clone5.Attachment.Ring:Emit(2)
	clone5.Attachment.spark:Emit(5)
	clone5.Attachment.glow:Emit(5)
	clone5.Attachment.Blast:Emit(5)
	clone5.Attachment.spark3:Emit(15)
	_G.PU:Dust(clone5, 2)
	local clone6 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.ChasingKick.Diable.leg:Clone()
	clone6.Parent = workspace.Effects
	clone6.Size = createVector(0, 0, 20)
	clone6.CFrame = cframe * CFrame.Angles(0, 3.141592653589793, 0)
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 500,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://5801257793",
		Volume = 1.5
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone6
	sound2:Play()
	_G.PU:Dust(clone6, 2)
	TweenService:Create(clone6, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(5, 5, 56.25)
	}):Play()
	TweenService:Create(clone6, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = clone6.CFrame * CFrame.new(0, 0, 45)
	}):Play()
	local pointLight = clone6.PointLight
	pointLight.Range = 40
	TweenService:Create(pointLight, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Brightness = 0,
		Range = pointLight.Range / 2
	}):Play()
	task.spawn(function()
		wait(0.1)
		TweenService:Create(clone6, TweenInfo.new(0.15, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = createVector(0, 0, 75)
		}):Play()
		wait(0.1)
		TweenService:Create(clone6, TweenInfo.new(0.2, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
	local clone7 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.ChasingKick.Diable.FlameSpiral2:Clone()
	clone7.Parent = workspace.Effects
	clone7:SetPrimaryPartCFrame(cframe * CFrame.new(0, 0, -30))
	clone7.PrimaryPart.Blast:Emit(10)
	clone7.PrimaryPart.Spec1:Emit(10)
	clone7.PrimaryPart.Spec2:Emit(25)
	task.spawn(function()
		local ModuleScript = require(clone7.ModuleScript)
		ModuleScript()
		_G.PU:Dust(clone7, 0.75)
	end)

	for _, part in pairs(clone7:GetChildren()) do
		if part:IsA("BasePart") and part ~= clone7.PrimaryPart then
			TweenService:Create(part, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = part.CFrame * CFrame.new(40, 0, 0)
			}):Play()
		end
	end

	local clone8 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.ChasingKick.Diable.WindRing:Clone()
	clone8.CFrame = cframe * CFrame.new(0, 0, -5) * CFrame.Angles(0, -1.5707963267948966, 0)
	clone8.Parent = workspace.Effects
	_G.PU:Dust(clone8, 1)
	task.spawn(function()
		local ModuleScript = require(clone8.ModuleScript)
		ModuleScript()
	end)
	wait(0.115)
	local _ = data.hit
	local pos = data.pos
	local clone9 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.ChasingKick.Diable.Crack:Clone()
	_G.PU:Dust(clone9, 6)
	clone9.Parent = workspace.Effects
	clone9.CFrame = CFrame.new(pos)
	local ModuleScript = require(clone9.ModuleScript)
	ModuleScript()
	local sound3 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://8748164748",
		Volume = 2
	})
	_G.PU:Dust(sound3, 3)
	sound3.Parent = clone9
	sound3:Play()
	local rock = require(script.rock)
	rock(CFrame.new(pos + createVector(0, 1, 0)))
end