local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
local remoteEvent = Net:RemoteEvent("EggrotHunt/JumpShopTutorialShown")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local tutorialArrow = ReplicatedStorage.Controllers.FTUEController.TutorialArrow

local function FindJumpShopPart()
	for _, proximityPrompt in CollectionService:GetTagged("EggrotJumpShopPrompt") do
		if proximityPrompt:IsA("ProximityPrompt") and proximityPrompt.Parent and proximityPrompt.Parent:IsA("BasePart") then
			return proximityPrompt.Parent
		end
	end

	return nil
end

return table.freeze({
	Start = function(_)
		local maid = Trove.new()
		Synchronizer:WaitAndCall(localPlayer, function(object)
			if object:Get({ "EasterEvent", "JumpShopTutorialShown" }) or object:Get({ "EasterEvent", "JumpShop" }) ~= 0 then
				return
			end

			local v = false
			local flag = false
			local maid2 = Trove.new()
			maid:Add(maid2)

			local function dismiss()
				if flag then
					return
				end

				flag = true
				local main = playerGui:FindFirstChild("Main")
				local tutorial = main and main:FindFirstChild("Tutorial")

				if tutorial then
					local textLabel = tutorial:FindFirstChild("TextLabel")

					if textLabel and textLabel:IsA("TextLabel") then
						textLabel.Visible = false
					end
				end

				maid2:Destroy()
			end

			local function showTutorial()
				if v or flag then
					return
				end

				v = true
				local humanoidRootPart = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild(
					"HumanoidRootPart",
					5
				)

				if not humanoidRootPart then
					dismiss()
					return
				end

				local jumpShopPart = FindJumpShopPart()

				if not jumpShopPart then
					dismiss()
					return
				end

				local clone = maid2:Clone(tutorialArrow)
				clone.Start.CFrame = humanoidRootPart.CFrame
				local weldConstraint = Instance.new("WeldConstraint")
				weldConstraint.Part0 = humanoidRootPart
				weldConstraint.Part1 = clone.Start
				weldConstraint.Parent = clone.Start
				clone.End.CFrame = jumpShopPart.CFrame
				clone.Parent = workspace
				local textLabel = playerGui:WaitForChild("Main").Tutorial.TextLabel
				textLabel.Text = "Go buy your first double jump!"
				textLabel.Visible = true
				remoteEvent:FireServer()
				local v3 = object:Get({ "EasterEvent", "BunnyCoins" })
				maid2:Add(object:OnChanged({ "EasterEvent", "JumpShop" }, function(value)
					if type(value) == "number" and value >= 1 then
						dismiss()
					end
				end))
				maid2:Add(object:OnChanged({ "EasterEvent", "BunnyCoins" }, function(value)
					if type(value) == "number" and type(v3) == "number" and value < v3 then
						dismiss()
					end

					v3 = value
				end))
				maid2:Add(task.delay(60, dismiss))
			end

			maid:Add(object:OnChanged({ "EasterEvent", "BunnyCoins" }, function(value)
				if v or flag then
					return
				end

				if type(value) == "number" and value >= 25 then
					task.spawn(showTutorial)
				end
			end))
		end)
		return function()
			maid:Destroy()
		end
	end
})