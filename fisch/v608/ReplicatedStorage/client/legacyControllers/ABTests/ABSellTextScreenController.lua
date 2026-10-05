local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
game:GetService("ServerScriptService")
local packages = ReplicatedStorage:WaitForChild("packages")
local _ = ReplicatedStorage.shared.modules
local Net = require(packages:WaitForChild("Net"))
local WorldController = require(ReplicatedStorage.client.legacyControllers.WorldController)
local localPlayer = Players.LocalPlayer
localPlayer:WaitForChild("PlayerGui"):WaitForChild("hud")
local remoteEvent = Net:RemoteEvent("ABSellTextScreen/GuideAppraisal")
local remoteEvent2 = Net:RemoteEvent("ABSellTextScreen/GuideMerchant")
local remoteEvent3 = Net:RemoteEvent("ABSellTextScreen/GuideDestroy")
return {
	Start = function(_)
		remoteEvent.OnClientEvent:Connect(function()
			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			local clone = ReplicatedStorage2:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("ui"):WaitForChild("ABSellTextScreenGuideAppraisal"):Clone()
			clone.poiBeam.Attachment0 = clone:WaitForChild("a0")
			clone.poiBeam.Attachment1 = localPlayer.Character:WaitForChild("HumanoidRootPart"):WaitForChild(
				"RootAttachment",
				10
			)
			clone.Parent = workspace.active
		end)
		remoteEvent2.OnClientEvent:Connect(function()
			local active = workspace.active
			local aBSellTextScreenGuideAppraisal = active:FindFirstChild("ABSellTextScreenGuideAppraisal")

			if aBSellTextScreenGuideAppraisal then
				aBSellTextScreenGuideAppraisal:Destroy()
			end

			local aBSellTextScreenGuideMerchant = active:FindFirstChild("ABSellTextScreenGuideMerchant")

			if aBSellTextScreenGuideMerchant then
				aBSellTextScreenGuideMerchant:Destroy()
			end

			local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
			local clone = ReplicatedStorage2:WaitForChild("resources"):WaitForChild("replicated"):WaitForChild("instances"):WaitForChild("ui"):WaitForChild("ABSellTextScreenGuideMerchant"):Clone()
			clone.poiBeam.Attachment0 = clone:WaitForChild(WorldController:GetCurrentWorldIndex())
			clone.poiBeam.Attachment1 = localPlayer.Character:WaitForChild("HumanoidRootPart"):WaitForChild(
				"RootAttachment",
				10
			)
			clone.Parent = workspace.active
		end)
		remoteEvent3.OnClientEvent:Connect(function()
			local aBSellTextScreenGuideMerchant = workspace.active:FindFirstChild("ABSellTextScreenGuideMerchant")

			if aBSellTextScreenGuideMerchant then
				aBSellTextScreenGuideMerchant:Destroy()
			end
		end)
	end
}