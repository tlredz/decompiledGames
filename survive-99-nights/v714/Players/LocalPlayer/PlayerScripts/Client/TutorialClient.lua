local createVector = vector.create
local TutorialClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local clone = nil
local flag = false
local count = 0
TutorialClient.currentID = 0
TutorialClient.ChestTutorialActive = false
local flag2 = false
local clones = {}

function TutorialClient.NewTutorial(currentID, text, tag, extentsOffsetWorldSpace, size)
	task.spawn(function()
		wait(1.5)

		if flag2 then
			return
		end

		TutorialClient.currentID = currentID
		local tutorialLabel = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface"):WaitForChild("TutorialLabel")
		count += 1
		local v = count

		if flag then
			repeat
				wait()
			until flag == false
		end

		task.spawn(function()
			wait(125)

			if TutorialClient.currentID == currentID then
				TutorialClient.ClearTutorial(currentID)
			end
		end)

		if v == count then
			tutorialLabel.Text = text
			tutorialLabel.TextColor3 = Color3.fromRGB(242, 255, 0)
			tutorialLabel.Visible = true
			local model

			if tag then
				local count2 = 0

				repeat
					model = CollectionService:GetTagged(tag)[1]
					wait()
					count2 += 1
				until model or count2 == 200

				if model and model:IsA("Model") then
					local _ = model.PrimaryPart
				end
			end

			if currentID == 1 then
				task.spawn(function()
					wait()
					local children = {}

					for _, child in pairs(workspace.Map.Landmarks:GetChildren()) do
						if child.Name == "Small Tree" then
							table.insert(children, child)
						end
					end

					for _, child in pairs(workspace.Map.Foliage:GetChildren()) do
						if child.Name == "Small Tree" then
							table.insert(children, child)
						end
					end

					for _, v2 in pairs(children) do
						if not (v2 and v2.Parent and v2.PrimaryPart and (v2.PrimaryPart.Position - workspace.Map.Campground.MainFire.PrimaryPart.Position).Magnitude < 95) then
							continue
						end

						local clone2 = ReplicatedStorage.Assets.Particles.TreeDots:Clone()
						clone2.Parent = v2.PrimaryPart
						clone2.Adornee = v2.PrimaryPart
						table.insert(clones, clone2)
					end
				end)
			end

			if clone then
				clone:Destroy()
			end

			if model then
				clone = ReplicatedStorage.Assets.Interface.TutorialArrow:Clone()
				clone.Parent = model

				if extentsOffsetWorldSpace then
					clone.ExtentsOffsetWorldSpace = extentsOffsetWorldSpace
				end

				if size then
					clone.Size = size
				end
			end
		end
	end)
end

local count2 = 0

function TutorialClient.ClearTutorial(p, p2)
	task.spawn(function()
		if TutorialClient.currentID == p then
			local tutorialLabel = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Interface"):WaitForChild("TutorialLabel")

			if p2 then
				tutorialLabel.TextColor3 = Color3.fromRGB(34, 255, 0)
				clone.ImageLabel.ImageColor3 = Color3.fromRGB(34, 255, 0)
				flag = true
				count2 += 1
				local v = count2
				wait(3)

				if clone then
					clone:Destroy()
				end

				if count2 == v then
					flag = false
					tutorialLabel.Visible = false
				end
			else
				if clone then
					clone:Destroy()
				end

				count2 += 1
				tutorialLabel.Visible = false
				flag = false
			end

			TutorialClient.currentID = 0
		end

		for _, v in pairs(clones) do
			v:Destroy()
		end
	end)
end

Client.Events.TutorialEvent:Connect(function(p, p2, p3, p4, p5)
	TutorialClient.NewTutorial(p, p2, p3, p4, p5)
end)
Client.Events.TutorialEnd:Connect(function(p, p2)
	TutorialClient.ClearTutorial(p, p2)
end)
Client.Events.TutorialArrowEnd:Connect(function()
	if TutorialClient.currentID == 1 and clone then
		clone:Destroy()
		clone = nil
	end
end)
local v = false
local v2 = false
TutorialClient.HasAddedScrap = false
local v3 = false
local v4 = false

function ListenForScrapInSack()
	localPlayer:WaitForChild("ItemBag").ChildAdded:Connect(function(child)
		if workspace:GetAttribute("Progress") <= 2 and child:GetAttribute("Scrappable") and child:GetAttribute("Scrappable") > 0 and not (TutorialClient.HasAddedScrap or v2) then
			v2 = true
			TutorialClient.NewTutorial(2, "Place 🔩 Scrap 🔩 in the Grinder", "Tutorial2", createVector(0, 9, 0))
		end

		if not v3 and child and string.sub(child.Name, 1, 6) == "Lost C" then
			v3 = true
		elseif not v4 and child and child:GetAttribute("PlayerBody") then
			v4 = true
		end
	end)
end

TutorialClient.SomeoneHasOpenedChest = false
Client.Events.TryTestTutorial:Connect(function()
	if not Client.InteractionHandler.HasOpenedChest and TutorialClient.SomeoneHasOpenedChest then
		TutorialClient.ChestTutorialActive = true

		for _, tutorialCircle in pairs(Client.MapDrawClient.TutorialCircles) do
			tutorialCircle.Visible = true
		end

		Client.Interface.TopRight.Frame.Map.TutorialLabel.Visible = true
	end
end)

function TutorialClient.Init()
	task.spawn(function()
		Client.HighlightHandler.Init()
		local humanoidRootPart = (localPlayer.Character or localPlayer.CharacterAdded:Wait()):WaitForChild("HumanoidRootPart")
		ListenForScrapInSack()
		local center = workspace.Map.Campground:WaitForChild("MainFire").Center

		while workspace:GetAttribute("Progress") == 1 and not v do
			if (humanoidRootPart.Position - center.Position).Magnitude > 150 then
				v = true
				Client.PopUpUI.AddPopUp("upgrade the campfire to reveal the map")
			end

			wait(1)
		end
	end)
end

Client.Events.TargettedSound:Connect(function()
	Client.Sound.Play("AggroBass", {
		Duplicate = true
	})
end)
Client.Events.SantaTargetedSound:Connect(function()
	Client.Sound.Play("XmasTension", {
		Duplicate = true
	})
end)
local flag3 = false

function OnMissingHat(instance)
	instance:WaitForChild("TouchPart").Touched:Connect(function(otherPart)
		if flag3 then
			return
		end

		if otherPart.Parent and localPlayer.Character and otherPart.Parent == localPlayer.Character then
			flag3 = true
			task.spawn(function()
				wait(1.6)
				Client.PopUpUI.AddPopUp(
					"this is my friend's hat... she's been lost for so long. I just know she's in the forest somewhere...",
					"note"
				)
				wait(20)

				if instance:FindFirstChild("Handle") then
					instance.Handle:Destroy()
				end
			end)
		end
	end)
end

Client.Utility.ForAllTagged("MissingHat", OnMissingHat)
Client.Events.NotifyClassEquipped:Connect(function(p)
	if p ~= "None" then
		flag2 = true
		TutorialClient.ClearTutorial(1)
		Client.PopUpUI.AddPopUp(`Equipped class {p}`, "yellow", 12)
	end
end)
return TutorialClient