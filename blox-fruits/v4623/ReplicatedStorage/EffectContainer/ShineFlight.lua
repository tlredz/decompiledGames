local util = game.ReplicatedStorage:WaitForChild("Util")
require(util.Sound)
game:GetService("TweenService")
game:GetService("RunService")
local _ = game.ReplicatedStorage.Assets.Models.LightSword
local _ = workspace._WorldOrigin
local _ = workspace.Map

local function ScaleParticle(p, p2)
	local numberSequenceKeypoints = {}

	for _, keypoint in next, p.Size.Keypoints, nil do
		table.insert(
			numberSequenceKeypoints,
			NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * p2, keypoint.Envelope)
		)
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local function func(p)
	local attachment = p.Attachment

	while attachment.Parent and attachment:IsDescendantOf(workspace) do
		attachment.Star:Emit(2)
		attachment.Star_Color:Emit(2)
		wait(0.1)
	end
end

return func