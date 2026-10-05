local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Audio = require(ReplicatedStorage.Shared.Audio)
local OverlayRoot = require(ReplicatedStorage.Client.UI.VFX.OverlayRoot)

local function quintOut(duration: number, value: number?)
	return TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, value or 0)
end

local v = {
	pitch = 1,
	cues = {
		{
			id = 91650233387983,
			volume = 0.8
		},
		{
			id = 112792997660073,
			volume = 1
		}
	},
	sheetProperties = {
		BackgroundColor3 = Color3.fromRGB(255, 175, 0),
		BackgroundTransparency = 0,
		Size = UDim2.new(1, 0, 1, 0)
	},
	sheetFade = TweenInfo.new(1.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0.05),
	lensPush = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0.05),
	lensSettle = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, 0),
	lensWide = 100,
	lensResting = 70
}

-- equivalent calls inferred from this helper; original call sites unknown
local function stage(p, p2, p3)
	return TweenService:Create(p, p2, p3)
end

return function()
	for _, cue in v.cues do
		Audio.Play(cue.id, script, {
			PlaybackSpeed = v.pitch,
			Volume = cue.volume
		})
	end

	local frame = Instance.new("Frame")

	for k, sheetProperty in v.sheetProperties do
		frame[k] = sheetProperty
	end

	frame.Parent = OverlayRoot()
	local currentCamera = workspace.CurrentCamera
	local v3 = stage(currentCamera, v.lensSettle, {
		FieldOfView = v.lensResting
	}) -- equivalent call inferred; original call site unknown
	local v5 = stage(currentCamera, v.lensPush, {
		FieldOfView = v.lensWide
	}) -- equivalent call inferred; original call site unknown
	local v6 = stage(frame, v.sheetFade, {
		BackgroundTransparency = 1
	}) -- equivalent call inferred; original call site unknown
	v5.Completed:Once(function()
		v3:Play()
	end)
	v6.Completed:Once(function()
		frame:Destroy()
	end)
	v5:Play()
	v6:Play()
end