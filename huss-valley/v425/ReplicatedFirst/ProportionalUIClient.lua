local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local UIProportions = require(script.Parent:WaitForChild("UIProportions"))
local v = UIProportions.watch(localPlayer:WaitForChild("PlayerGui"))
script.Destroying:Connect(v)