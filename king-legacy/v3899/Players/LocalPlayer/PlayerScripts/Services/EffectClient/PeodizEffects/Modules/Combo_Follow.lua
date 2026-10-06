local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
return function(data)
	local startCF = data.StartCF
	local v = startCF
	local success, result = pcall(function()
		return (game.Players.LocalPlayer.Character.HumanoidRootPart.Position - startCF.p).Magnitude > 1000
	end)

	if success and result then
		return
	end

	for _ = 1, 3 do
		local clone = ReplicatedStorage.Chest.SwordEffect.Acroscyth.Shock:Clone()
		clone.CFrame = CFrame.new(startCF.p) * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
		clone.Parent = workspace.Effects
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
			Size = createVector(15.291, 10, 15.328),
			Transparency = 1
		}):Play()
		TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			CFrame = clone.CFrame * CFrame.Angles(0, 6.283185307179586 * math.random(), 0)
		}):Play()
	end

	local clone = ReplicatedStorage.Chest.SwordEffect.Acroscyth.Scyth:Clone()
	clone.CFrame = startCF * CFrame.Angles(0, 3.141592653589793, 0) * CFrame.Angles(0, 0, 1.5707963267948966)
	clone.Parent = workspace.Effects
	local sound = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://7521202156",
		Volume = 3
	})
	_G.PU:Dust(sound, 3)
	sound.Parent = clone
	sound:Play()
	local sound2 = PeoUtils.CreateSound({
		RollOffMaxDistance = 1000,
		RollOffMinDistance = 10,
		RollOffMode = Enum.RollOffMode.InverseTapered,
		SoundId = "rbxassetid://7521188299",
		Volume = 4
	})
	_G.PU:Dust(sound2, 3)
	sound2.Parent = clone
	sound2:Play()
	TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
		Size = createVector(7.08, 76.338, 66.171)
	}):Play()
	clone.Attachment.BloodParticle.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 2),
		NumberSequenceKeypoint.new(1, 7)
	})
	clone.Attachment2.Dust.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 0.5)
	})
	TweenService:Create(clone.PointLight, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
		Range = 100
	}):Play()
	spawn(function()
		wait(0.7)
		clone.Attachment2.Dust.Enabled = false
		wait(0.5)
		TweenService:Create(clone.Hurricane, TweenInfo.new(0.6), {
			Volume = 0
		}):Play()
		TweenService:Create(clone.Roar, TweenInfo.new(0.6), {
			Volume = 0
		}):Play()
		TweenService:Create(clone.PointLight, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			Range = 0
		}):Play()
	end)
	clone.Attachment.BloodParticle:Emit(math.random(5, 9))
	clone.Attachment.Dust:Emit(math.random(15, 25))
	spawn(function()
		for i = 1, 100 do
			clone.CFrame = startCF * CFrame.new(0, 0, -math.sin(3.141592653589793 * i / 100) * data.Range) * CFrame.Angles(
				0,
				3.141592653589793,
				0
			) * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.Angles(31.41592653589793 * i / 100, 0, 0)

			if i == 70 then
				TweenService:Create(clone, TweenInfo.new(0.65, Enum.EasingStyle.Exponential), {
					Size = createVector(1.166, 8.379, 7.263)
				}):Play()
			end

			if i >= 60 then
				local v3 = v * CFrame.new(0, 0, -data.Range)
				startCF = CFrame.new(data.Target.Position, v3.p)
			end

			if i >= 10 and i < 60 then
				local clone2 = ReplicatedStorage.Chest.SwordEffect.Acroscyth.Slashes:Clone()
				clone2.CFrame = startCF * CFrame.new(0, 0, -math.sin(3.141592653589793 * i / 100) * data.Range) * CFrame.Angles(
					0,
					6.283185307179586 * math.random(),
					0
				)
				clone2.Transparency = 0.7
				clone2.Parent = workspace.Effects
				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
					Size = createVector(85, 3, 85),
					Transparency = 1
				}):Play()
				TweenService:Create(clone2, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
					CFrame = clone2.CFrame * CFrame.Angles(0, 6.283185307179586 * math.random(), 0),
					Color = Color3.fromRGB(255, 0, 0)
				}):Play()
				_G.PU:Dust(clone2, 1)
			end

			local RunService = game:GetService("RunService")
			RunService.RenderStepped:Wait()
		end

		clone:Destroy()
	end)
end