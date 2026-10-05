local HelpHappyClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local random = Random.new()
local v = {}
local v2 = 0
local v3 = {}
local v4 = false
local parent = nil
local v5 = false
local v6 = false
local v7 = false
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(255, 238, 88)
local color3 = Color3.fromRGB(255, 238, 88)

function RemoveStartModel(instance)
	if localPlayer:GetAttribute("HelpingHappyHalloween") then
		instance:Destroy()
	elseif localPlayer:GetAttribute("PickedUpHappysScythe") and instance:FindFirstChild("Happy's Scythe") then
		instance["Happy's Scythe"]:Destroy()
	end
end

function RemoveAllStartModels()
	for _, v8 in pairs(CollectionService:GetTagged("StartHelpHappyQuest")) do
		RemoveStartModel(v8)
	end
end

function RemoveRamHead(instance)
	if localPlayer:GetAttribute("PickedUpRamHappyHead") then
		instance:Destroy()
	end
end

function RemoveAllRamHeads()
	for _, v8 in pairs(CollectionService:GetTagged("RamHappyHead")) do
		RemoveRamHead(v8)
	end
end

function AnyPartPlaced(instance)
	for _, child in pairs(instance:GetChildren()) do
		if child:GetAttribute("Placed") then
			return true
		end
	end

	return false
end

function FigureVisible(p)
	if workspace:GetAttribute("RebuildHappyState") == 2 then
		return false
	end

	return localPlayer:GetAttribute("HelpingHappyHalloween") == true or AnyPartPlaced(p)
end

function GhostLook(instance)
	if not FigureVisible(instance.Parent) then
		return 1, color
	end

	if not localPlayer:GetAttribute("HelpingHappyHalloween") then
		return 0.7, color
	end

	local draggingItem = Client.InteractionHandler.GetDraggingItem()
	local halloweenPartId = draggingItem and draggingItem:GetAttribute("HalloweenPartId")

	if halloweenPartId == nil or instance:GetAttribute("HalloweenPartId") ~= halloweenPartId then
		return 0.7, color
	end

	return 0.3, color2
end

function SetGhostPart(instance, instance2, transparency: number, color4: Color3, p: number)
	if instance2:IsA("Light") then
		if instance2:GetAttribute("OrigEnabled") == nil then
			instance2:SetAttribute("OrigEnabled", instance2.Enabled)
		end

		local enabled

		if instance:GetAttribute("Placed") and FigureVisible(instance.Parent) then
			enabled = instance2:GetAttribute("OrigEnabled") or false
		else
			enabled = false
		end

		instance2.Enabled = enabled
	else
		if not instance2:IsA("BasePart") then
			return
		end

		if instance2:GetAttribute("OrigTransparency") == nil then
			instance2:SetAttribute("OrigTransparency", instance2.Transparency)
		end

		if instance2:GetAttribute("OrigColour") == nil then
			instance2:SetAttribute("OrigColour", instance2.Color)
		end

		if instance2:GetAttribute("OrigMaterial") == nil then
			instance2:SetAttribute("OrigMaterial", instance2.Material.Name)
		end

		if instance2:GetAttribute("OrigTransparency") >= 1 then
			return
		end

		if instance:GetAttribute("Placed") then
			instance2.Material = Enum.Material[instance2:GetAttribute("OrigMaterial")]
			instance2.Transparency = not FigureVisible(instance.Parent) and 1 or instance2:GetAttribute("OrigTransparency") or 1
			instance2.Color = instance2:GetAttribute("OrigColour")
		else
			instance2.Material = Enum.Material.SmoothPlastic

			if p == nil then
				instance2.Transparency = transparency
				instance2.Color = color4
			else
				local transparency2 = instance2.Transparency
				local color5 = instance2.Color
				Client.TweenModule.new(function(p2)
					if not (v2 == p and v[instance] ~= nil) then
						return true
					end

					instance2.Transparency = transparency2 + (transparency - transparency2) * p2
					instance2.Color = color5:Lerp(color4, p2)
				end, 0.5):Play()
			end
		end
	end
end

function RefreshGhost(folder, p: number)
	local v8, v9 = GhostLook(folder)

	for _, descendant in pairs(folder:GetDescendants()) do
		SetGhostPart(folder, descendant, v8, v9, p)
	end
end

function RefreshRebuildPrompt(instance)
	local prompt = instance:FindFirstChild("Prompt")
	local proximityInteraction = prompt and prompt:FindFirstChild("ProximityInteraction", true)

	if proximityInteraction then
		local v8

		if workspace:GetAttribute("RebuildHappyState") == 3 then
			v8 = not localPlayer:GetAttribute("PickedUpRamHappyHead")
		else
			v8 = false
		end

		proximityInteraction.Enabled = FigureVisible(instance) and not v8
	end
end

function RefreshGhosts()
	local v8 = v2 + 1
	v2 = v8

	for k, _ in v do
		if k.Parent == nil then
			v[k] = nil
		else
			RefreshGhost(k, v8)
		end
	end

	for _, v9 in pairs(CollectionService:GetTagged("RebuildHappyHalloween")) do
		RefreshRebuildPrompt(v9)
	end
end

function GhostAdded(model)
	if not model:IsA("Model") then
		return
	end

	v[model] = true
	RefreshGhost(model)
	model.DescendantAdded:Connect(function(descendant)
		local v8, v9 = GhostLook(model)
		SetGhostPart(model, descendant, v8, v9)
	end)
	model:GetAttributeChangedSignal("Placed"):Connect(function()
		RefreshGhosts()

		if model:GetAttribute("Placed") and FigureVisible(model.Parent) then
			Client.Utility.SpawnParticles("Construct_Spark", model:GetPivot())
		end
	end)
end

function GetGhostForPart(instance, p)
	for _, model in pairs(instance:GetChildren()) do
		if model:IsA("Model") and model:GetAttribute("HalloweenPartId") == p and not model:GetAttribute("Placed") then
			return model
		end
	end
end

function ListenForPartPlaced(instance)
	instance:WaitForChild("TouchZone").Touched:Connect(function(otherPart)
		if not localPlayer:GetAttribute("HelpingHappyHalloween") then
			return
		end

		local parent2 = otherPart.Parent

		if parent2 == nil or parent2.Parent ~= workspace.Items then
			return
		end

		local halloweenPartId = parent2:GetAttribute("HalloweenPartId")

		if halloweenPartId == nil or parent2:GetAttribute("Owner") ~= localPlayer.UserId and parent2:GetAttribute("LastOwner") ~= localPlayer.UserId then
			return
		end

		local v8 = GetGhostForPart(instance, halloweenPartId)

		if v8 == nil then
			return
		end

		parent2.Parent = game.ReplicatedStorage.TempStorage
		local v9 = Client.Events.RequestPlaceHappyHalloweenPart:InvokeServer(parent2, v8)

		if v9 and v9.Success then
			Client.Sound.Play("HappyPartAttach", {
				Duplicate = true,
				Replicate = true,
				ReplicationProperties = {
					Position = v8:GetPivot().Position
				}
			})
		else
			task.delay(0.5, function()
				parent2.Parent = workspace.Items
			end)
		end
	end)
end

function RebuildModelAdded(instance)
	for _, child in pairs(instance:GetChildren()) do
		GhostAdded(child)
	end

	instance.ChildAdded:Connect(GhostAdded)
	instance.ChildRemoved:Connect(function(child)
		v[child] = nil
	end)
	RefreshRebuildPrompt(instance)
	instance.DescendantAdded:Connect(function(proximityPrompt)
		if proximityPrompt:IsA("ProximityPrompt") then
			RefreshRebuildPrompt(instance)
		end
	end)
	ListenForPartPlaced(instance)
end

function RebuildModelRemoved(instance)
	for _, child in pairs(instance:GetChildren()) do
		v[child] = nil
	end
end

function ListenForPartDragged()
	Client.Events.StartDraggingItem:Connect(function(instance)
		if instance:GetAttribute("HalloweenPartId") ~= nil then
			RefreshGhosts()
		end
	end)
	Client.Events.ItemDraggingEnded:Connect(function(_)
		task.wait()
		RefreshGhosts()
	end)
end

function DistanceToCharacter(vector: Vector3)
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart then
		return (humanoidRootPart.Position - vector).Magnitude
	end

	return 1e999
end

function PieceAdded(parent2)
	local highlight = Instance.new("Highlight")
	highlight.Name = "PieceOutline"
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillTransparency = 1
	highlight.OutlineColor = color3
	highlight.Enabled = false
	highlight.Parent = parent2
	v3[parent2] = highlight

	if not v4 then
		v4 = true
		task.spawn(FadePieceOutlines)
	end
end

function PieceRemoved(p)
	if v3[p] then
		v3[p]:Destroy()
		v3[p] = nil
	end
end

function FadePieceOutlines()
	while next(v3) do
		local v8 = false

		for k, v9 in pairs(v3) do
			local outlineTransparency = math.clamp((DistanceToCharacter(k:GetPivot().Position) - 25) / 75, 0, 1)
			v9.OutlineTransparency = outlineTransparency
			v9.Enabled = outlineTransparency < 1

			if outlineTransparency < 1 then
				v8 = true
			end
		end

		task.wait(v8 and 0 or 0.5)
	end

	v4 = false
end

function HeadGoal(cframe: CFrame)
	local humanoidRootPart = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")

	if not humanoidRootPart then
		return nil
	end

	local v8 = humanoidRootPart.Position - cframe.Position
	local vector = Vector3.new(v8.X, 0, v8.Z)

	if vector.Magnitude < 0.01 then
		return nil
	end

	local v9 = math.atan2(-vector.X, -vector.Z)
	local v10 = math.clamp(math.atan2(v8.Y, vector.Magnitude), -0.5235987755982988, 0.5235987755982988)
	return CFrame.new(cframe.Position) * CFrame.Angles(0, v9, 0) * CFrame.Angles(v10, 0, 0)
end

function FollowCharacter(instance, cframe: CFrame)
	local rotation = instance:GetPivot().Rotation
	local v8 = os.clock() + random:NextNumber(3, 5)
	local renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
		local v9 = HeadGoal(cframe)

		if v9 then
			rotation = rotation:Lerp(v9.Rotation, 1 - math.exp(-8 * dt))
		end

		local v10 = 0
		local v11 = (os.clock() - v8) / 0.35

		if v11 >= 2 then
			v8 = os.clock() + random:NextNumber(3, 5)
		elseif v11 >= 0 then
			local v12 = v11 % 1
			v10 = 6 * v12 * (1 - v12)
		end

		instance:PivotTo(CFrame.new(cframe.Position + Vector3.new(0, v10, 0)) * rotation)
	end)
	return function()
		renderSteppedConnection:Disconnect()
		instance:PivotTo(CFrame.new(cframe.Position) * rotation)
	end
end

function StartQuest(instance)
	Client.Events.RequestStartHelpHappyQuest:FireServer()
	local head = instance:FindFirstChild("Head")
	local pivot = head:GetPivot()
	Client.FloatingHappyHeadClient.ShowHead(pivot, head:GetScale())
end

function TalkToHappy(p)
	parent = p
	v7 = true
	local v8 = v5 and "SawWhatHappened" or "PickedUpHead"
	local v9 = v6 and "GrabScytheReminder" or v8
	Client.Events.StartDialogue:Fire("HalloweenDialogue", v9)
end

function ScythePickedUp()
	RemoveAllStartModels()

	if not v6 then
		return
	end

	v6 = false

	if parent and parent.Parent then
		StartQuest(parent)
		Client.Events.StartDialogue:Fire("HalloweenDialogue", "GrabbedScythe")
	end
end

function PickUpRamHead(instance)
	Client.Events.RequestPickUpRamHead:FireServer()
	local head = instance:FindFirstChild("Head") or instance
	Client.FloatingHappyHeadClient.ShowHead(head:GetPivot(), head:GetScale())
end

function MovingHeadAdded(instance)
	local pivot = instance:GetPivot()
	task.spawn(function()
		while instance.Parent do
			if DistanceToCharacter(pivot.Position) <= 150 then
				local v8 = nil

				while instance.Parent and DistanceToCharacter(pivot.Position) <= 150 do
					local v9 = DistanceToCharacter(pivot.Position) <= 50

					if v9 and v8 == nil then
						v8 = FollowCharacter(instance, pivot)
					elseif not v9 and v8 then
						v8()
						v8 = nil
					end

					task.wait(0.2)
				end

				if v8 then
					v8()
				end
			end

			task.wait(1)
		end
	end)
end

function CountMissingPieces(instance)
	local count = 0

	for _, child in pairs(instance:GetChildren()) do
		if child:GetAttribute("HalloweenPartId") == nil or child:GetAttribute("Placed") then
			continue
		end

		count += 1
	end

	return count
end

function HelpHappyClient.Init()
	Client.InteractionHandler.RegisterInteraction("StartHelpHappyQuest", function(p)
		if localPlayer:GetAttribute("HelpingHappyHalloween") then
			return
		end

		TalkToHappy(p)
	end)
	Client.InteractionHandler.RegisterInteraction("PickUpHappysScythe", function(p)
		if localPlayer:GetAttribute("PickedUpHappysScythe") then
			return
		end

		parent = p.Parent
		Client.Events.RequestPickUpHappysScythe:FireServer()
		Client.Sound.Play("HappyScythePickup")

		if not v7 then
			TalkToHappy(p.Parent)
		end
	end)
	Client.Events.StartHelpHappyQuest:Connect(function()
		if not (parent and parent.Parent) then
			return
		end

		if localPlayer:GetAttribute("PickedUpHappysScythe") then
			StartQuest(parent)
			return
		end

		v6 = true
		task.defer(function()
			Client.Events.StartDialogue:Fire("HalloweenDialogue", "GrabScytheFirst")
		end)
	end)
	Client.Events.CutsceneComplete:Connect(function(p)
		if p == "UpdateCutscene52" then
			v5 = true
		elseif p == "HappyFinalRam" then
			task.delay(4, function()
				Client.Events.StartDialogue:Fire("HalloweenDialogue", "RamGotMe")
			end)
		end
	end)
	Client.InteractionHandler.RegisterInteraction("CheckRebuiltHappy", function(p)
		CountMissingPieces(p)
		Client.Events.StartDialogue:Fire("HalloweenDialogue", "FindMoreBodyPieces")
	end)
	Client.InteractionHandler.RegisterInteraction("PlaceHappyHead", function(p)
		local rebuildHappyState = workspace:GetAttribute("RebuildHappyState")

		if rebuildHappyState == 2 or rebuildHappyState == 4 then
			return
		end

		if rebuildHappyState == 3 then
			if not localPlayer:GetAttribute("PickedUpRamHappyHead") then
				return
			end
		elseif not localPlayer:GetAttribute("HelpingHappyHalloween") then
			return
		end

		Client.Events.RequestPlaceHappyHead:FireServer(p)
	end)
	Client.InteractionHandler.RegisterInteraction("RamHappyHead", function(p)
		if workspace:GetAttribute("RebuildHappyState") ~= 3 or localPlayer:GetAttribute("PickedUpRamHappyHead") then
			return
		end

		PickUpRamHead(p)
	end)
	Client.InteractionHandler.RegisterInteraction("TalkToRepairedHappy", function(_)
		if localPlayer:GetAttribute("CompletedHappyQuest") then
			Client.Events.StartDialogue:Fire("HalloweenDialogue", "HappyAfterQuestComplete")
		else
			Client.Events.StartDialogue:Fire("HalloweenDialogue", "HappyCompleteQuest")
		end
	end)
	Client.Events.RequestCompleteHappyQuest:Connect(function()
		if workspace:GetAttribute("RebuildHappyState") ~= 4 or localPlayer:GetAttribute("CompletedHappyQuest") then
			return
		end

		Client.HappyRewardClient.OpenMenu()
	end)
	Client.Utility.ForAllTagged("StartHelpHappyQuest", RemoveStartModel)
	localPlayer:GetAttributeChangedSignal("HelpingHappyHalloween"):Connect(RemoveAllStartModels)
	localPlayer:GetAttributeChangedSignal("PickedUpHappysScythe"):Connect(ScythePickedUp)
	Client.Utility.ForAllTagged("RamHappyHead", RemoveRamHead)
	localPlayer:GetAttributeChangedSignal("PickedUpRamHappyHead"):Connect(RemoveAllRamHeads)
	localPlayer:GetAttributeChangedSignal("PickedUpRamHappyHead"):Connect(RefreshGhosts)
	Client.Utility.ForAllTagged("RebuildHappyHalloween", RebuildModelAdded, RebuildModelRemoved)
	localPlayer:GetAttributeChangedSignal("HelpingHappyHalloween"):Connect(RefreshGhosts)
	workspace:GetAttributeChangedSignal("RebuildHappyState"):Connect(RefreshGhosts)
	Client.Utility.ForAllTagged("MovingHappyHead", MovingHeadAdded)
	Client.Utility.ForAllTagged("HappyBodyPiece", PieceAdded, PieceRemoved)
	ListenForPartDragged()
end

return HelpHappyClient