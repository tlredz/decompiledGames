workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local sound = Util.Sound
local _ = Util.MasterClock
local _ = workspace._WorldOrigin
game:GetService("TweenService")
game:GetService("RunService")
return function(p)
	local rootPart = p.RootPart
	local move = p.Move

	if FX:WaitForChild("SerpentBow").AttachHold.Attachment:FindFirstChild(move) then
		sound:Play("BowPull", rootPart, nil, math.random(1, 8) / 10 + 1.5, 2)
		local clone = FX:WaitForChild("SerpentBow").AttachHold.Attachment:Clone()
		local v = clone[move]
		v.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 20 * (rootPart.Size.Z / 2)),
			NumberSequenceKeypoint.new(1, 0)
		})
		clone.Parent = rootPart
		v:Emit(1)
		Util.Debris:AddItem(clone, 0.8)
	end
end