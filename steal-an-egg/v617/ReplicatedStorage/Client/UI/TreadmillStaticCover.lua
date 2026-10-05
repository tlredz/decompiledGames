local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GUI = require(ReplicatedStorage.Client.GUI)
local TreadmillVideoController = require(ReplicatedStorage.Shared.TreadmillVideoController)
require(ReplicatedStorage.Shared.TreadmillVideoController.Types.Interface)
local surfaceGui = GUI.StaticTreadmillImageSurfaceGui()
assert(surfaceGui:IsA("SurfaceGui"), "Static treadmill image GUI must be a SurfaceGui")
local TreadmillStaticCover = {
	Create = function(name: string, adornee)
		local clone = surfaceGui:Clone()
		clone.Name = name
		clone.Adornee = adornee
		clone.Enabled = true
		clone.Parent = surfaceGui.Parent
		return clone
	end,
	SetEnabled = function(p, enabled: boolean)
		p.Enabled = enabled
	end,
	ApplyMedia = function(p, p2)
		p.VideoFrame.Image.Image = TreadmillVideoController.ResolveCoverImage(p2)
		p.VideoFrame.StopPlay.Image = TreadmillVideoController.GetStoppedIconImage()
		p.VideoFrame.StopPlay.Visible = true
	end
}

function TreadmillStaticCover.ApplyFeed(p, p2)
	TreadmillStaticCover.ApplyMedia(p, TreadmillVideoController.GetCurrentMediaEntry(p2))
end

return TreadmillStaticCover