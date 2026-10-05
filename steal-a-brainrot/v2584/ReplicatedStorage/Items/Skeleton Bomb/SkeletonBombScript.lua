game:GetService("RunService")
game:GetService("TweenService")
game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local _ = ReplicatedStorage:WaitForChild("Models").ToolsExtras
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
require(packages.Debounce)
local parent = script.Parent
local _ = parent.Parent.Parent
parent.Activated:Connect(function()
	Net:RemoteEvent("UseItem"):FireServer()
end)