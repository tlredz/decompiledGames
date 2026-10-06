local createVector = vector.create

local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PeoUtils = require(ReplicatedStorage.Chest.Modules.PeoUtils)
local TweenService = game:GetService("TweenService")
return function(p)
	local cf = p.cf
	local _ = game.Players.LocalPlayer
	local clone = ReplicatedStorage.Chest.FruitEffect.Venom.New.venom_pit:Clone()
	_G.PU:Dust(clone, 7)
	clone.CFrame = cf * CFrame.Angles(0, 0, 1.5707963267948966)
	clone.Size = createVector(1, 1, 1)
	clone.Parent = workspace.Effects
	clone.Blast.Enabled = true
	clone.Blast2.Enabled = true
	clone.Attachment.sm.Enabled = true
	TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		Size = createVector(1, 200, 200)
	}):Play()
	task.spawn(function()
		wait(5)
		clone.Blast.Enabled = false
		clone.Blast2.Enabled = false
		clone.Attachment.sm.Enabled = false
	end)
	task.spawn(function()
		local sound = PeoUtils.CreateSound({
			RollOffMaxDistance = 1000,
			RollOffMinDistance = 10,
			RollOffMode = Enum.RollOffMode.InverseTapered,
			SoundId = "rbxassetid://165970126",
			Volume = 0
		})
		_G.PU:Dust(sound, 10)
		sound.Parent = clone
		sound:Play()
		TweenService:Create(sound, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Volume = 1
		}):Play()
		wait(5)

		if sound and sound.Parent then
			TweenService:Create(sound, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Volume = 0
			}):Play()
		end
	end)
end