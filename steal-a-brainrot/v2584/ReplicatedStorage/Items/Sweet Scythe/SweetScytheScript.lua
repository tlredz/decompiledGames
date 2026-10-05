game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local packages = ReplicatedStorage:WaitForChild("Packages")
require(packages.Net)
require(packages.Debounce)
local _ = script.Parent.Parent.Parent