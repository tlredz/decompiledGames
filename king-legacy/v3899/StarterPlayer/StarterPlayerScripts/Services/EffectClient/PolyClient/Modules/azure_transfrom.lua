local createVector = vector.create
local TweenService = game:GetService("TweenService")
local replicatedStorage = game.ReplicatedStorage
local PeoUtils = require(replicatedStorage.Chest.Modules.PeoUtils)
return function(p, _)
	local cf = p.cf
	local clone = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.AzureFlame.transition:Clone()
	clone.CFrame = cf
	clone.Parent = workspace.Effects
	clone.spark3:Emit(10)
	clone.specs:Emit(20)
	_G.PU:Dust(clone, 1)
	local part = Instance.new("Part")
	part.CFrame = cf
	part.Size = createVector(1, 1, 1)
	part.CanCollide = false
	part.Anchored = true
	part.Color = Color3.fromRGB(255, 0, 0)
	part.Transparency = 1
	part.Parent = workspace.Effects
	_G.PU:Dust(part, 1.5)
	local clone2 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.AzureFlame.transfrom.Attachment:Clone()
	clone2.Parent = part
	clone2.Spark.Rotation = NumberRange.new(math.random(0, 180))
	task.spawn(function()
		local ModuleScript = require(clone2.ModuleScript)
		ModuleScript()
	end)
	wait()
	local clone3 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.AzureFlame.swirl:Clone()
	clone3.CFrame = cf * CFrame.new(0, 10, 0)
	clone3.Size = createVector(0, 20, 0)
	clone3.Parent = workspace.Effects
	TweenService:Create(clone3, TweenInfo.new(0.1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		CFrame = cf * CFrame.new(0, 12.5, 0)
	}):Play()
	TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(25, 25, 25)
	}):Play()
	_G.PU:Dust(clone3, 2)
	local clone4 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.AzureFlame.transition2:Clone()
	clone4.CFrame = cf * CFrame.new(0, 10, 0)
	clone4.Parent = workspace.Effects
	clone4.glow.Enabled = true
	clone4.smokez.Enabled = true
	clone4.specs.Enabled = true
	_G.PU:Dust(clone4, 2)

	for i = 1, 2 do
		local clone5 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.AzureFlame.spiral2:Clone()
		clone5.Parent = workspace.Effects
		clone5.Size = createVector(11.536, 15.03, 12.061)
		clone5.CFrame = cf * CFrame.new(0, 7.5, 0) * CFrame.Angles(0, 3.141592653589793 * i, 0)
		_G.PU:Dust(clone5, 2)
		local v2 = i
		task.spawn(function()
			TweenService:Create(clone5, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				CFrame = cf * CFrame.new(0, 17, 0) * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.Angles(
					0,
					3.141592653589793 * v2,
					0
				)
			}):Play()
			TweenService:Create(clone5, TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(54.7925, 34.961, 46.70625)
			}):Play()
			TweenService:Create(clone5, TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			wait(0.5)
		end)
		wait()
	end

	for i = 1, 14 do
		TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Orientation = clone3.Orientation + Vector3.new(0, i * 35 + 120, 0)
		}):Play()
		clone4.glow.Speed = NumberRange.new(i * 5 + 60)
		clone4.smokez.Speed = NumberRange.new(i * 5 + 60)
		clone4.specs.Speed = NumberRange.new(i * 5 + 60)

		if game.Players.LocalPlayer == p.player then
			_G.shake("SmallestBump")
		end

		wait(0.1)

		if i == 13 then
			TweenService:Create(clone3, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = createVector(31.25, 31.25, 31.25)
			}):Play()
		end
	end

	clone4.glow.Enabled = false
	clone4.smokez.Enabled = false
	clone4.specs.Enabled = false
	TweenService:Create(clone3, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = createVector(0, 30, 0)
	}):Play()
	local clone5 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.AzureFlame.azurecenter:Clone()
	clone5.CFrame = cf
	clone5.Parent = workspace.Effects
	_G.PU:Dust(clone5, 1)
	clone5.Attachment.Blast:Emit(25)
	clone5.Attachment.wind:Emit(3)
	clone5.Attachment.glow:Emit(35)
	clone5.Attachment.smokez:Emit(35)
	clone5.Attachment.sparkl1:Emit(2)
	clone5.Attachment.sparkl2:Emit(2)
	clone5.Attachment.big:Emit(2)

	if game.Players.LocalPlayer == p.player then
		_G.shake("Bump")
		local crack = require(script.crack)
		crack(cf)
	end

	task.spawn(function()
		local part2 = Instance.new("Part")
		part2.Shape = "Ball"
		part2.Material = Enum.Material.Neon
		part2.Color = Color3.fromRGB(83, 143, 255)
		part2.Anchored = true
		part2.CanCollide = false
		part2.CastShadow = false
		part2.Size = createVector(3, 3, 3)
		part2.Parent = workspace.Effects
		part2.CFrame = cf
		_G.PU:Dust(part2, 0.5)
		TweenService:Create(part2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
			Size = part2.Size * 20
		}):Play()
		task.spawn(function()
			wait(0.1)
			TweenService:Create(part2, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
		end)
	end)
	local clone6 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.wind:Clone()
	clone6.Parent = workspace.Effects
	clone6.CFrame = CFrame.new(cf.p)
	task.spawn(function()
		local ModuleScript = require(clone6.ModuleScript)
		ModuleScript()
	end)
	local part2 = Instance.new("Part")
	part2.CFrame = cf
	part2.Size = createVector(1, 1, 1)
	part2.CanCollide = false
	part2.Anchored = true
	part2.Color = Color3.fromRGB(255, 0, 0)
	part2.Transparency = 1
	part2.Parent = workspace.Effects
	_G.PU:Dust(part2, 3)
	local clone7 = replicatedStorage.Chest.Etc.BlackLeg.DiableV2.AzureFlame.transfrom.Attachment:Clone()
	clone7.Parent = part2
	clone7.Spark.Rotation = NumberRange.new(math.random(0, 180))
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://9201395294",
		Volume = 2
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = part2
	sound:Play()
	task.spawn(function()
		local ModuleScript = require(clone7.ModuleScript)
		ModuleScript()
	end)
end