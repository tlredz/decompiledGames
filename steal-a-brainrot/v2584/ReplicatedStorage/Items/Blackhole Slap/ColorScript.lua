local parent = script.Parent
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
	ColorSequenceKeypoint.new(0.16666666666666666, Color3.fromRGB(255, 180, 110)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 62, 48)),
	ColorSequenceKeypoint.new(0.8333333333333334, Color3.fromRGB(97, 160, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
})
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local EvalColorSequence = require(ReplicatedStorage.Shared.EvalColorSequence)
local RecolorPart = require(ReplicatedStorage.Shared.RecolorPart)
local track = RecolorPart.track(parent)
local total = 0
local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt: number)
	total += dt * script:GetAttribute("Speed")
	local evalColorSequence = EvalColorSequence(colorSequence, total % 1)
	script:SetAttribute("Color", evalColorSequence)
	track:Recolor(evalColorSequence)
end)
script.Destroying:Connect(function()
	renderSteppedConnection:Disconnect()
	track:Destroy()
end)