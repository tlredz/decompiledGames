local createVector = vector.create
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeodizService = require(ReplicatedStorage.Chest.Modules.PeodizService)
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
		_G.PU:Dust(clone, 1)
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

		if sound and sound.Parent then
			TweenService:Create(sound, TweenInfo.new(0.6), {
				Volume = 0
			}):Play()
		end

		if sound2 and sound2.Parent then
			TweenService:Create(sound2, TweenInfo.new(0.6), {
				Volume = 0
			}):Play()
		end

		TweenService:Create(clone.PointLight, TweenInfo.new(0.5, Enum.EasingStyle.Sine), {
			Range = 0
		}):Play()
	end)
	clone.Attachment.BloodParticle:Emit(math.random(5, 9))
	clone.Attachment.Dust:Emit(math.random(15, 25))
	local v3 = true
	spawn(function()
		local v4 = nil
		local v5 = nil
		PeodizService.ForLoop({
			Step = 100
		}, function(p)
			local v6 = math.floor(p * 100)
			clone.CFrame = startCF * CFrame.new(0, 0, -math.sin(3.141592653589793 * v6 / 100) * data.Range) * CFrame.Angles(
				0,
				3.141592653589793,
				0
			) * CFrame.Angles(0, 0, 1.5707963267948966) * CFrame.Angles(31.41592653589793 * v6 / 100, 0, 0)

			if p >= 0.7 and not v4 then
				v4 = true
				TweenService:Create(clone, TweenInfo.new(0.65, Enum.EasingStyle.Exponential), {
					Size = createVector(1.166, 8.379, 7.263)
				}):Play()
			end

			if p >= 0.6 and not v5 then
				v5 = true
				local v7 = v * CFrame.new(0, 0, -data.Range)
				startCF = CFrame.new(data.Target.Position, v7.p)
			end

			if p > 0.05 and p < 0.6 and v3 then
				v3 = nil
				local clone2 = ReplicatedStorage.Chest.SwordEffect.Acroscyth.Slashes:Clone()
				clone2.CFrame = startCF * CFrame.new(0, 0, -math.sin(3.141592653589793 * v6 / 100) * data.Range) * CFrame.Angles(
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
				task.spawn(function()
					wait(0.03)
					v3 = true
				end)
			end
		end)
		clone:Destroy()
	end)
end