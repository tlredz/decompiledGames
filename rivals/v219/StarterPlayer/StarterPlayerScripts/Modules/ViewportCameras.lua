local RunService = game:GetService("RunService")
local ViewportCameras = {
	ZOOM_OUT_FACTOR = 3,
	Charm = Instance.new("Camera")
}
ViewportCameras.Charm.FieldOfView = 25
ViewportCameras.CharmZoomedOut = Instance.new("Camera")
ViewportCameras.CharmZoomedOut.FieldOfView = 25
ViewportCameras.Skin = Instance.new("Camera")
ViewportCameras.Skin.FieldOfView = 25
ViewportCameras.SkinZoomedOut = Instance.new("Camera")
ViewportCameras.SkinZoomedOut.FieldOfView = 25
ViewportCameras.Wrap = Instance.new("Camera")
ViewportCameras.Wrap.FieldOfView = 25
ViewportCameras.Wrap.CFrame = CFrame.Angles(0, 3.490658503988659, 0) * CFrame.Angles(-0.2617993877991494, 0, 0) * CFrame.new(
	0,
	0,
	1
)
ViewportCameras.WrapZoomedOut = Instance.new("Camera")
ViewportCameras.WrapZoomedOut.FieldOfView = 25
ViewportCameras.WrapZoomedOut.CFrame = CFrame.Angles(0, 3.490658503988659, 0) * CFrame.Angles(-0.2617993877991494, 0, 0) * CFrame.new(
	0,
	0,
	1 * ViewportCameras.ZOOM_OUT_FACTOR
)
ViewportCameras.Emote = Instance.new("Camera")
ViewportCameras.Emote.FieldOfView = 10
ViewportCameras.EmoteZoomedOut = Instance.new("Camera")
ViewportCameras.EmoteZoomedOut.FieldOfView = 10
RunService.RenderStepped:Connect(function(_)
	ViewportCameras.Charm.CFrame = CFrame.Angles(0, tick() * 0.5 % 6.283185307179586, 0) * CFrame.Angles(
		-0.2617993877991494,
		0,
		0
	) * CFrame.new(0, 0, 0.3)
	ViewportCameras.CharmZoomedOut.CFrame = CFrame.Angles(0, tick() * 0.5 % 6.283185307179586, 0) * CFrame.Angles(
		-0.2617993877991494,
		0,
		0
	) * CFrame.new(0, 0, 0.3 * ViewportCameras.ZOOM_OUT_FACTOR)
	ViewportCameras.Skin.CFrame = CFrame.Angles(0, tick() * 0.5 % 6.283185307179586, 0) * CFrame.Angles(
		-0.2617993877991494,
		0,
		0
	) * CFrame.new(0, 0, 5)
	ViewportCameras.SkinZoomedOut.CFrame = CFrame.Angles(0, tick() * 0.5 % 6.283185307179586, 0) * CFrame.Angles(
		-0.2617993877991494,
		0,
		0
	) * CFrame.new(0, 0, 5 * ViewportCameras.ZOOM_OUT_FACTOR)
	ViewportCameras.Emote.CFrame = CFrame.Angles(
		0,
		3.141592653589793 + math.sin(tick() * 0.25 % 6.283185307179586) * 0.2617993877991494,
		0
	) * CFrame.Angles(-0.4363323129985824, 0, 0) * CFrame.new(0, 0, 40)
	ViewportCameras.EmoteZoomedOut.CFrame = CFrame.Angles(
		0,
		3.141592653589793 + math.sin(tick() * 0.25 % 6.283185307179586) * 0.2617993877991494,
		0
	) * CFrame.Angles(-0.4363323129985824, 0, 0) * CFrame.new(0, 0, 40 * ViewportCameras.ZOOM_OUT_FACTOR)
end)
return ViewportCameras