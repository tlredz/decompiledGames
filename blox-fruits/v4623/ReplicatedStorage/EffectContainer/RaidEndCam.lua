local createVector = vector.create
local localPlayer = game.Players.LocalPlayer
local Util = require(game.ReplicatedStorage.Util)
return function(p)
	local v = Util.Sound:Play("KnockbackSFX", workspace.CurrentCamera)
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local raidGui = playerGui:FindFirstChild("RaidGui") or Instance.new("ScreenGui", playerGui)
	raidGui.Name = "RaidGui"
	raidGui.DisplayOrder = -10
	raidGui.Parent = playerGui
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = p and p.Color or Color3.new(0.85, 0.85, 0)
	frame.Size = UDim2.new(2, 0, 2, 0)
	frame.Position = UDim2.new(-0.25, 0, -0.25, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = raidGui
	local TweenService = game:GetService("TweenService")
	local tween = TweenService:Create(frame, TweenInfo.new(5), {
		BackgroundTransparency = 0
	})
	tween.Completed:Connect(function()
		wait(0.5)
		local TweenService2 = game:GetService("TweenService")
		local tween2 = TweenService2:Create(frame, TweenInfo.new(1.5), {
			BackgroundTransparency = 1
		})
		tween2.Completed:Connect(function()
			frame:Destroy()
		end)
		tween2:Play()
	end)
	tween:Play()
	Util.CameraShaker:ShakeOnce(3, 20, 5, 4, createVector(1, 1, 1), createVector(1, 1, 1))
	wait(4.5)
	Util.Sound:FadeOut(v, 1)
end