local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local packages = ReplicatedStorage:WaitForChild("packages")
local _ = ReplicatedStorage.shared.modules
local Net = require(packages:WaitForChild("Net"))
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
playerGui:WaitForChild("hud")
local remoteEvent = Net:RemoteEvent("ABShipGuidance/GuideLocation")
local remoteEvent2 = Net:RemoteEvent("ABShipGuidance/DestroyGuideLocation")
local ABShipGuidanceController = {
	SetupUi = function(self)
		local rowboat = playerGui:WaitForChild("hud"):WaitForChild("safezone"):WaitForChild("shipwright"):WaitForChild("ships"):WaitForChild("main"):WaitForChild("safezone"):WaitForChild("Rowboat")
		local spawn = rowboat:WaitForChild("spawn")

		if not rowboat then
			return
		end

		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Parent = rowboat
		imageLabel.Size = UDim2.new(0, 32, 0, 34)
		imageLabel.Position = UDim2.new(0.816, 0, 0.426, 0)
		imageLabel.ScaleType = Enum.ScaleType.Fit
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = "rbxassetid://93795886994695"
		imageLabel.Name = "ABShipGuidanceArrow"
		imageLabel.ImageColor3 = Color3.fromRGB(255, 0, 0)
		local tween = TweenService:Create(
			imageLabel,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				Position = UDim2.new(0.816, 0, 0.4, 0)
			}
		)
		local tween2 = TweenService:Create(
			imageLabel,
			TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
			{
				Position = UDim2.new(0.816, 0, 0.426, 0)
			}
		)
		tween.Completed:Connect(function()
			tween2:Play()
		end)
		tween2.Completed:Connect(function()
			tween:Play()
		end)
		tween:Play()
		spawn.MouseButton1Click:Connect(function()
			local aBShipGuidanceArrow = spawn.Text == "[Spawn]" and rowboat:FindFirstChild("ABShipGuidanceArrow")

			if aBShipGuidanceArrow then
				aBShipGuidanceArrow:Destroy()
			end
		end)
	end
}

function ABShipGuidanceController.Start(_)
	remoteEvent.OnClientEvent:Connect(function()
		local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
		local clone = ReplicatedStorage2:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("ui"):WaitForChild("ABShipGuidance"):Clone()
		clone.poiBeam.Attachment0 = clone:WaitForChild("a0")
		clone.poiBeam.Attachment1 = localPlayer.Character:WaitForChild("HumanoidRootPart"):WaitForChild(
			"RootAttachment",
			10
		)
		clone.Parent = workspace.active
		ABShipGuidanceController:SetupUi()
	end)
	remoteEvent2.OnClientEvent:Connect(function()
		local aBShipGuidance = workspace.active:FindFirstChild("ABShipGuidance")

		if aBShipGuidance then
			aBShipGuidance:Destroy()
		end
	end)
end

return ABShipGuidanceController