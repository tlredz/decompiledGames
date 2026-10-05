workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
return function(data)
	local position = data.Position

	if (position - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.CFrame = CFrame.new(position)
	attachment.Parent = workspace.Terrain
	local clone = FX:WaitForChild("Shine"):Clone()
	clone.Parent = attachment

	if data.Size then
		clone.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(0.6, data.Size * 1.15),
			NumberSequenceKeypoint.new(1, 0)
		})
		clone.ZOffset = -1
	end

	if data.Lifetime then
		clone.Lifetime = NumberRange.new(data.Lifetime[1], data.Lifetime[2])
	end

	clone:Emit(1)
	Util.Debris:AddItem(attachment, data.Lifetime and data.Lifetime[2] + 1 or 2)
end