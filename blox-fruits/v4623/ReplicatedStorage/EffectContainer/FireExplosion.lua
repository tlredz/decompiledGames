workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(game.ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))

local function ScaleParticle(clone, scale)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, clone.Size.Keypoints, nil do
		local v = keypoint.Value * scale
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, v, v < keypoint.Envelope and v or keypoint.Envelope)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

return function(data)
	local position = data.Position
	local emit = data.Emit or 50

	if (position - workspace.CurrentCamera.CFrame.p).magnitude > 500 then
		return
	end

	local attachment = Instance.new("Attachment")
	attachment.CFrame = CFrame.new(position)
	attachment.Parent = workspace.Terrain
	local clone = game.ReplicatedStorage.Assets.Models.FireExplosion.Fire:Clone()
	clone.Parent = attachment

	if data.Speed then
		local speed = data.Speed
		clone.Speed = NumberRange.new(speed * 0.8, speed * 1.2)
	end

	if data.Lifetime then
		clone.Lifetime = NumberRange.new(data.Lifetime[1], data.Lifetime[2])
	end

	if data.Scale then
		clone.Size = ScaleParticle(clone, data.Scale)
	end

	clone:Emit(emit)
	Util.Debris:AddItem(attachment, data.Lifetime and data.Lifetime[2] + 1 or 2)
end