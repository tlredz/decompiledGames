local parent = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local RecolorPart = require(ReplicatedStorage.Shared.RecolorPart)
local value = script:WaitForChild("Reference").Value
RunService.RenderStepped:Connect(function(_: number)
	RecolorPart(parent, value:GetAttribute("Color"))
end)