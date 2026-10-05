game:GetService("Debris")
local Players = game:GetService("Players")
game:GetService("RunService")
local TweenService = game:GetService("TweenService")
game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("ServerScriptService")
local packages = ReplicatedStorage:WaitForChild("Packages")
local Net = require(packages.Net)
require(packages.Debounce)
local main = Players.LocalPlayer.PlayerGui:WaitForChild("Main")
Net:RemoteEvent("UseItem").OnClientEvent:Connect(function(p, p2)
	if p ~= "PaintballHitted" then
		return
	end

	for _ = 1, p2 or math.random(1, 2) do
		local clone = script:GetChildren()[math.random(#script:GetChildren())]:Clone()
		clone.Parent = main
		clone.Rotation = math.random(360)
		clone.Position = UDim2.new(math.random(10, 90) / 100, 0, math.random(10, 90) / 100, 0)
		clone.ImageColor3 = Color3.fromRGB(math.random(255), math.random(255), math.random(255))
		task.delay(p2 and 2 or 4, function()
			local tween = TweenService:Create(
				clone,
				TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
				{
					Size = UDim2.new()
				}
			)
			tween:Play()
			tween.Completed:Wait()
			clone:Destroy()
		end)
	end
end)
return {}