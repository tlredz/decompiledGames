local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Net = require(ReplicatedStorage.packages.Net)
local remoteEvent = Net:RemoteEvent("Boats/FailPreview", -1)
local BoatPlacementPreviewController = {}
local v = nil

function BoatPlacementPreviewController.ShowFail(position: Vector3, size: Vector3)
	if v then
		v:Destroy()
	end

	local clone = script.Preview:Clone()
	local tween = TweenService:Create(
		clone,
		TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 3, true),
		{
			Transparency = 0
		}
	)

	for _, child in clone:GetChildren() do
		TweenService:Create(child, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 3, true), {
			Transparency = 0
		}):Play()
	end

	tween.Completed:Once(function()
		if v == clone then
			v = nil
		end

		clone:Destroy()
	end)
	clone.CFrame = CFrame.new(position)
	clone.Size = size
	clone.Parent = workspace.active.debrisfx
	tween:Play()
	v = clone
end

function BoatPlacementPreviewController.Start(_)
	remoteEvent.OnClientEvent:Connect(BoatPlacementPreviewController.ShowFail)
end

return BoatPlacementPreviewController