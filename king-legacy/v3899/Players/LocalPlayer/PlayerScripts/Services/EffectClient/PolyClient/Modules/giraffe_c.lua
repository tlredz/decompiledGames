local createVector = vector.create
local replicatedStorage = game.ReplicatedStorage
local replicatedStorage2 = game.ReplicatedStorage
local TweenService = game:GetService("TweenService")
local PeoUtils = require(replicatedStorage2.Chest.Modules.PeoUtils)
game:GetService("RunService")
return function(data, _)
	local localPlayer = game.Players.LocalPlayer

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
	local tocf = data.tocf

	if game.Players.LocalPlayer == data.plr then
		_G.shake("SmallestBump")
	end

	task.spawn(function()
		wait(0.085)

		if game.Players.LocalPlayer == data.plr then
			localPlayer.Character.HumanoidRootPart.CFrame = tocf * CFrame.new(0, 3, 0)
		end

		wait(0.115)

		if (localPlayer.Character.HumanoidRootPart.Position - tocf.p).Magnitude < 60 or game.Players.LocalPlayer == data.plr then
			_G.shake("SmallBump")
		end
	end)
	local clone = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.ChasingKick.teleport:Clone()
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
	_G.PU:Dust(clone, 2)
	local magnitude = (cf.p - tocf.p).Magnitude
	task.spawn(function()
		for _ = 1, math.random(3, 4) do
			local clone2 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.ChasingKick.sphere:Clone()
			clone2.CFrame = CFrame.new(cf.p, tocf.p) * CFrame.new(
				math.random(-8, 8),
				math.random(-8, 8),
				-magnitude / 3
			) * CFrame.new(0, 0, math.random(-5, 5))
			clone2.Size = Vector3.new(1, 1, magnitude / 1.5)
			clone2.Transparency = -1
			clone2.Color = Color3.fromRGB(255, 255, 255)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = Vector3.new()
			}):Play()
			TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = clone2.CFrame * CFrame.new(0, 0, -magnitude) * CFrame.new(0, 0, magnitude / 3)
			}):Play()
			_G.PU:Dust(clone2, 0.6)
			task.spawn(function()
				wait(0.15)
				TweenService:Create(
					clone2,
					TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Transparency = 1
					}
				):Play()
			end)
		end
	end)
	local clone2 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.ChasingKick.Shockwave:Clone()
	clone2.CFrame = CFrame.new(cf.p, tocf.p) * CFrame.new(0, 0, -40) * CFrame.Angles(0, 1.5707963267948966, 0)
	clone2.Size = createVector(0, 0, 0)
	clone2.Parent = workspace.Effects
	clone2.Material = Enum.Material.Neon
	TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = clone2.CFrame * CFrame.new(-35, 0, 0) * CFrame.Angles(3.141592653589793, 0, 0)
	}):Play()
	TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(2, 45, 45)
	}):Play()
	_G.PU:Dust(clone2, 1)
	task.spawn(function()
		wait(0.2)
		TweenService:Create(clone2, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
	local clone3 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.ChasingKick.sphere:Clone()
	clone3.CFrame = CFrame.new(cf.p, tocf.p) * CFrame.new(0, 0, 0)
	clone3.Size = createVector(8, 8, 0)
	clone3.Transparency = 0
	clone3.Color = Color3.fromRGB(255, 255, 255)
	clone3.Parent = workspace.Effects
	TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = Vector3.new(5, 5, magnitude)
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = CFrame.new(cf.p, tocf.p) * CFrame.new(0, 0, -magnitude / 2)
	}):Play()
	_G.PU:Dust(clone3, 1)
	task.spawn(function()
		wait()
		clone3.Spark2:Emit(15)
		clone3.Spark3:Emit(15)
		TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = Vector3.new(0, 0, magnitude)
		}):Play()
		wait(0.25)
		TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Transparency = 1
		}):Play()
	end)
	wait(0.085)
	CFrame.new(tocf.p, tocf.p - createVector(0, 1, 0))
	local clone4 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.ChasingKick.teleport2:Clone()
	clone4.Parent = workspace.Effects
	clone4.CFrame = tocf
	clone4.Attachment.Spark:Emit(2)
	clone4.Attachment.big:Emit(10)
	clone4.Attachment.specs:Emit(8)
	clone4.Attachment.Ring:Emit(2)
	clone4.Attachment.spark:Emit(10)
	_G.PU:Dust(clone4, 2)
	wait(0.115)
	local clone5 = replicatedStorage2.Chest.FruitEffect.Giraffe.smash_fx:Clone()
	clone5.CFrame = CFrame.new(tocf.p + createVector(0, 2, 0)) * CFrame.Angles(0, 0, -1.5707963267948966)
	clone5.Parent = workspace.Effects
	_G.PU:Dust(clone5, 2)
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://6814067199",
		Volume = 2.5,
		PlaybackSpeed = 0.75
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone5
	sound:Play()
	local crack = require(replicatedStorage2.Chest.FruitEffect.Giraffe.crack)
	crack(CFrame.new(tocf.p + createVector(0, 2, 0)))
	local v = 50
	local cframe = CFrame.new(tocf.p)
	local v2 = "Bump"
	task.spawn(function()
		v = v or 100

		if localPlayer == data.plr or (localPlayer.Character.HumanoidRootPart.Position - cframe).Magnitude < v then
			_G.shake(v2)
		end
	end)

	for _, emitter in pairs(clone5:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 1)
		end
	end
end