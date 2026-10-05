local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local shared = ReplicatedStorage.shared
local Net = require(ReplicatedStorage.packages.Net)
local GeneralUIModule = require(shared.modules.GeneralUIModule)
local remoteEvent = Net:RemoteEvent("CupidPromise/OpenUI")
local remoteEvent2 = Net:RemoteEvent("CupidPromise/ClaimRewards")
local remoteEvent3 = Net:RemoteEvent("CupidPromise/CheckForCupidRewards")
local sfx = ReplicatedStorage.resources.sounds.sfx
local parent = script.Parent
local bg = parent:WaitForChild("bg")
local claimButton = parent:WaitForChild("claimButton")
parent.Visible = false
ContentProvider:PreloadAsync({ bg.Image })
task.delay(5, function()
	remoteEvent3:FireServer()
end)
remoteEvent.OnClientEvent:Connect(function()
	bg.Position = UDim2.fromScale(0.5, 0.7)
	bg.ImageTransparency = 1
	parent.Visible = true
	TweenService:Create(bg, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
		Position = UDim2.fromScale(0.5, 0.5),
		ImageTransparency = 0
	}):Play()
end)
claimButton.MouseButton1Click:Connect(function()
	local tween = TweenService:Create(bg, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {
		ImageTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.7)
	})
	tween:Play()
	tween.Completed:Once(function()
		parent.Visible = false
	end)
	sfx.ui.claimReward:Play()
	GeneralUIModule:FadedBorder(Color3.fromRGB(255, 97, 242), 0.3, 0.6)
	remoteEvent2:FireServer()
end)