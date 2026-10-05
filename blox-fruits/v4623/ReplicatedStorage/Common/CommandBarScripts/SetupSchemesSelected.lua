local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SetupSchemes = require(ReplicatedStorage:FindFirstChild("InterpolationScheme", true).SetupSchemes)
local Selection = game:GetService("Selection")

for _, folder in ipairs(Selection:Get()) do
	SetupSchemes(folder)
	SetupSchemes(folder:GetDescendants())
end