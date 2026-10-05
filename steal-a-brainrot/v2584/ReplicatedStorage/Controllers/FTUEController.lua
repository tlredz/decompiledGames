local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Synchronizer = require(ReplicatedStorage.Packages.Synchronizer)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Net = require(ReplicatedStorage.Packages.Net)
require(ReplicatedStorage.Controllers.NotificationController)
local AnimalController = require(ReplicatedStorage.Controllers.AnimalController)
local PlotController = require(ReplicatedStorage.Controllers.PlotController)
local maid = Trove.new()
local localPlayer = Players.LocalPlayer
local tutorial = localPlayer.PlayerGui:WaitForChild("Main").Tutorial
local textLabel = tutorial.TextLabel
local remoteEvent = Net:RemoteEvent("TutorialService/StartTutorial")
local remoteEvent2 = Net:RemoteEvent("TutorialService/FinishTutorial")
local remoteEvent3 = Net:RemoteEvent("PlotService/CashCollected")
local remoteEvent4 = Net:RemoteEvent("StealService/StealingSuccess")
Net:RemoteEvent("StealService/StealingFailure")

local function Setup(object)
	local flag = false
	local v = false
	local updateTutorial

	updateTutorial = function()
		task.wait(0.5)

		if localPlayer:GetAttribute("InNorthPole") then
			maid:Clean()
			return
		end

		local humanoidRootPart = (localPlayer.Character and localPlayer.Character.Parent == workspace and localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild(
			"HumanoidRootPart",
			5
		)

		if not humanoidRootPart then
			return
		end

		if not flag then
			textLabel.Visible = false
		end

		maid:Clean()

		if object:Get("TutorialFinished") == true then
			v = true
			maid:Destroy()
		else
			local hasAnimal, v2 = AnimalController:HasAnimal("Noobini Pizzanini")

			if flag then
				if localPlayer:GetAttribute("StealingPlayer") then
					maid:Add(remoteEvent4.OnClientEvent:Connect(function()
						textLabel.Visible = false
					end))
					local myPlot = PlotController:GetMyPlot()
					local deliveryHitbox = myPlot and myPlot.PlotModel:FindFirstChild("DeliveryHitbox")

					if deliveryHitbox then
						local clone = script.TutorialArrow:Clone()
						clone.Parent = workspace
						clone.Start.CFrame = humanoidRootPart.CFrame
						local weldConstraint = Instance.new("WeldConstraint", clone.Start)
						weldConstraint.Part0 = humanoidRootPart
						weldConstraint.Part1 = clone.Start
						clone.End.CFrame = deliveryHitbox.CFrame - createVector(0, 7.5, 0)
						maid:Add(clone)
					end
				end

				maid:Add(localPlayer:GetAttributeChangedSignal("StealingPlayer"):Connect(function()
					updateTutorial()
				end))
			elseif hasAnimal then
				local myPlot = PlotController:GetMyPlot()
				local animalPodiums = myPlot and myPlot.PlotModel:FindFirstChild("AnimalPodiums")
				local child = animalPodiums and animalPodiums:FindFirstChild(v2[1])
				local claim = child and child:FindFirstChild("Claim")
				local claimMain = claim and claim:FindFirstChild("Main")

				if claimMain then
					local clone = script.TutorialArrow:Clone()
					clone.Parent = workspace
					clone.Start.CFrame = humanoidRootPart.CFrame
					local weldConstraint = Instance.new("WeldConstraint", clone.Start)
					weldConstraint.Part0 = humanoidRootPart
					weldConstraint.Part1 = clone.Start
					clone.End.CFrame = claimMain.CFrame
					maid:Add(clone)
				end

				textLabel.Text = "Go collect your cash!"
				textLabel.Visible = true
				maid:Add(remoteEvent3.OnClientEvent:Connect(function()
					textLabel.Text = "Steal Brainrots from other players and bring them back to your base!"
					textLabel.Visible = true
					task.delay(10, function()
						textLabel.Visible = false
					end)
					flag = true
					updateTutorial()
					remoteEvent2:FireServer()
				end))
				maid:Add(object:OnChanged("AnimalAddedOrRemoved", updateTutorial))
			else
				local hasAnimalMovingToBase = AnimalController:HasAnimalMovingToBase("Noobini Pizzanini")

				if hasAnimalMovingToBase then
					local UID = hasAnimalMovingToBase.UID
					textLabel.Text = "Wait for Noobini Pizzanini to reach your base!"
					textLabel.Visible = true
					maid:Add(AnimalController.OnAnimalDestroyed:Connect(function(p)
						if UID == p then
							updateTutorial()
						end
					end))
					maid:Add(AnimalController.OnFollowingChanged:Connect(function(p, _, _)
						if p == "Noobini Pizzanini" then
							updateTutorial()
						end
					end))
					local primaryPart = hasAnimalMovingToBase.Instance and hasAnimalMovingToBase.Instance.PrimaryPart
					local promptAttachment = primaryPart and primaryPart:FindFirstChild("PromptAttachment")
					local proximityPrompt = promptAttachment and promptAttachment:FindFirstChildOfClass("ProximityPrompt")

					if proximityPrompt then
						maid:Add(proximityPrompt:GetAttributeChangedSignal("TargetPlayer"):Connect(updateTutorial))
					end
				else
					local clone = maid:Clone(script.TutorialArrow)
					clone.Start.CFrame = humanoidRootPart.CFrame
					local weldConstraint = Instance.new("WeldConstraint")
					weldConstraint.Part0 = humanoidRootPart
					weldConstraint.Part1 = clone.Start
					weldConstraint.Parent = clone.Start
					clone.Parent = workspace
					textLabel.Text = "Go buy a Noobini Pizzanini"
					local v3 = nil
					maid:Add(Timer.Simple(0.1, function()
						local character = localPlayer.Character

						if not character then
							return
						end

						local pivot = character:GetPivot()
						local v4 = 1e999
						local v5 = nil

						for _, v6 in AnimalController:GetAnimals() do
							if v6.Index ~= "Noobini Pizzanini" then
								continue
							end

							local primaryPart = v6.Instance and v6.Instance.PrimaryPart
							local promptAttachment = primaryPart and primaryPart:FindFirstChild("PromptAttachment")
							local proximityPrompt = promptAttachment and promptAttachment:FindFirstChildOfClass("ProximityPrompt")

							if not proximityPrompt or proximityPrompt:GetAttribute("TargetPlayer") then
								continue
							end

							local primaryPart2 = v6.AnimalModel and v6.AnimalModel.PrimaryPart

							if not primaryPart2 then
								continue
							end

							local cFrame = primaryPart2.CFrame
							local magnitude = (pivot.Position - cFrame.Position).Magnitude

							if not (magnitude < v4) then
								continue
							end

							v5 = v6
							v4 = magnitude
						end

						v3 = v5
					end, true))
					maid:Add(RunService.PostSimulation:Connect(function()
						debug.profilebegin("FTUEController")
						local start = clone:FindFirstChild("Start")

						if not start then
							debug.profileend()
							return
						end

						local primaryPart = v3 and v3.AnimalModel and v3.AnimalModel.PrimaryPart
						start.Beam.Enabled = primaryPart ~= nil
						textLabel.Visible = primaryPart ~= nil

						if primaryPart then
							clone.End.CFrame = primaryPart.CFrame
						end

						debug.profileend()
					end))
					maid:Add(AnimalController.OnFollowingChanged:Connect(function(p, _, _)
						if p == "Noobini Pizzanini" then
							updateTutorial()
						end
					end))
				end
			end
		end
	end

	if object:Get("TutorialFinished") == true then
		return
	end

	object:OnChanged("TutorialFinished", updateTutorial, true)
	localPlayer:GetAttributeChangedSignal("InNorthPole"):Connect(updateTutorial)

	if localPlayer.Character then
		task.spawn(updateTutorial)
	else
		localPlayer.CharacterAdded:Once(updateTutorial)
	end

	remoteEvent:FireServer()
end

return {
	Start = function(_)
		Synchronizer:WaitAndCall(localPlayer, Setup)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function onTopbarInsetUpdate()
			tutorial.Position = UDim2.fromScale(0.5, 0) + UDim2.fromOffset(0, GuiService.TopbarInset.Height)
		end

		GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(onTopbarInsetUpdate)
		onTopbarInsetUpdate() -- equivalent call inferred; original call site unknown
	end
}