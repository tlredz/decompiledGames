local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
local Players = game:GetService("Players")
Players = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
return function(data)
	local root = data.Root
	local holding = data.Holding
	local cFrame = data.CFrame

	if (root.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	Util.Sound:Play("Mera_FlameStartup", root)

	for i = 1, 2 do
		local clone = game.ReplicatedStorage.Assets.Models.CurvedRing:Clone()
		clone.CFrame = cFrame * CFrame.new(0, 0, -10 - i) * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone.Color = Color3.new(1, 1, 1)
		clone.Size = createVector(0.05, 0.05, 0.05)
		clone.Transparency = 0
		clone.Parent = Workspace._WorldOrigin
		local tween = TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Quad), {
			Transparency = 1,
			Size = createVector(30, 3, 30) * (i / 2 + 0.5),
			CFrame = cFrame * CFrame.new(0, 0, -12 - (i - 1) * 6) * CFrame.Angles(-1.5707963267948966, 0, 0)
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()
	end

	task.wait(0.2)
	local v = Util.Sound:Play("FireFistBallLoop", root)

	while holding:IsDescendantOf(Workspace) and holding.Value and data.Proxy:IsDescendantOf(Workspace) do
		local clone = game.ReplicatedStorage.Assets.Models.CurvedRing:Clone()
		clone.CFrame = root.CFrame * CFrame.new(0, 0, -10) * CFrame.Angles(-1.5707963267948966, 0, 0)
		clone.Color = Color3.new(1, 1, 1)
		clone.Size = createVector(0.05, 0.05, 0.05)
		clone.Transparency = 0
		clone.Parent = Workspace._WorldOrigin
		local tween = TweenService:Create(clone, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			Transparency = 1,
			Size = createVector(20, 2, 20)
		})
		tween.Completed:Connect(function()
			clone:Destroy()
		end)
		tween:Play()
		task.wait(0.2)
	end

	Util.Sound:FadeOut(v, 0.5)
end