local createVector = vector.create

local function bezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
return function(p)
	local cf = p.cf
	local _ = game.Players.LocalPlayer
	local clone = ReplicatedStorage.Chest.FruitEffect.Venom.New.venom_pit_Demon:Clone()
	clone.CFrame = cf * CFrame.Angles(0, 0, -1.5707963267948966)
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
	_G.PU:Dust(clone, 7)
end