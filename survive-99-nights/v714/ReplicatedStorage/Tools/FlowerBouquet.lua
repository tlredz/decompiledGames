local FlowerBouquet = {}
FlowerBouquet.__index = FlowerBouquet
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()
game:GetService("RunService")
game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local addFlowerHighlight = workspace:WaitForChild("Highlights"):WaitForChild("AddFlowerHighlight")

function FlowerBouquet.new(model, realModel)
	local self = setmetatable({}, FlowerBouquet)
	self.Model = model
	self.RealModel = realModel

	for k, v in pairs(self.RealModel:GetAttributes()) do
		self[k] = v
	end

	self:CreatePrompt()
	return self
end

function FlowerBouquet:PickFlower(_)
	if self.RealModel:GetAttribute("NumberFlowers") >= 4 then
		return
	end

	local currentFocus = self.CurrentFocus
	Client.Sound.Play("AddToBouquet", {
		Volume = 0.4,
		Replicate = true,
		ReplicationProperties = {
			Instance = localPlayer.Character.Head,
			Volume = 0.4
		}
	})

	if currentFocus:HasTag("ValentinesFlower") then
		currentFocus.Parent = game.ReplicatedStorage
	end

	local v = Client.Events.RequestAddFlower:InvokeServer(self.RealModel, currentFocus)

	if not (v and v.Success) and currentFocus:HasTag("ValentinesFlower") then
		currentFocus.Parent = workspace.Items
	end
end

Client.Events.IncorrectBouquet:Connect(function(p)
	if not p then
		return
	end

	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 1
	highlight.OutlineTransparency = 1
	highlight.FillColor = Color3.fromRGB(255, 0, 0)
	highlight.Adornee = p
	highlight.Parent = p
	local tweenModule = Client.TweenModule.new(function(p2)
		highlight.FillTransparency = (math.cos(9.42477796076938 * (p2 * 2.66667)) + 1) / 2
	end, 2.66667)
	tweenModule:BindToComplete(function()
		highlight:Destroy()
	end)
	tweenModule:Play()
	Client.PopUpUI.AddPopUp("Those weren't the right flowers...", "valentines")
	print("WRONG FLOWERS")
end)

function FlowerBouquet:GiveFlowersToNPC(_)
	local realModel = self.RealModel
	realModel.Parent = game.ReplicatedStorage
	local v = Client.Events.RequestGiveFlowersToNPC:InvokeServer(self.RealModel, self.CurrentFocus)

	if not (v and v.Success) then
		task.delay(1, function()
			realModel.Parent = localPlayer.Inventory
		end)
	end
end

function FlowerBouquet:CreatePrompt()
	local attachment = Instance.new("Attachment")
	attachment.Parent = workspace.Terrain
	self.Attachment = attachment
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.MaxActivationDistance = 20
	proximityPrompt.ActionText = "Take Flower"
	proximityPrompt.HoldDuration = 0.75
	proximityPrompt.Enabled = false
	proximityPrompt.Parent = attachment
	proximityPrompt.RequiresLineOfSight = false
	self.Prompt = proximityPrompt
	proximityPrompt.Triggered:Connect(function()
		if self.CurrentFocus and self.CurrentFocus:HasTag("ValentinesNPC") then
			self:GiveFlowersToNPC(self.CurrentFocus)
		else
			self:PickFlower(self.CurrentFocus)
		end
	end)
end

function FlowerBouquet:PrepareStructures()
	if self.LoopChecking then
		return
	end

	self.LoopChecking = true
	self.StructureOptions = CollectionService:GetTagged("ValentinesFlower")

	for _, v in pairs(CollectionService:GetTagged("FullFlowerPot")) do
		table.insert(self.StructureOptions, v)
	end

	self.StructureAddedEvent = CollectionService:GetInstanceAddedSignal("ValentinesFlower"):Connect(function(p)
		table.insert(self.StructureOptions, p)
	end)
	self.StructureAddedEvent2 = CollectionService:GetInstanceAddedSignal("FullFlowerPot"):Connect(function(p)
		table.insert(self.StructureOptions, p)
	end)
	self.StructureRemovedEvent = CollectionService:GetInstanceRemovedSignal("ValentinesFlower"):Connect(function(p)
		local index = table.find(self.StructureOptions, p)

		if index then
			table.remove(self.StructureOptions, index)
		end
	end)
	self.StructureRemovedEvent2 = CollectionService:GetInstanceRemovedSignal("FullFlowerPot"):Connect(function(p)
		local index = table.find(self.StructureOptions, p)

		if index then
			table.remove(self.StructureOptions, index)
		end
	end)
	self.ValentinesOptions = CollectionService:GetTagged("ValentinesNPC")
	self.NPCAddedEvent = CollectionService:GetInstanceAddedSignal("ValentinesNPC"):Connect(function(p)
		table.insert(self.ValentinesOptions, p)
	end)
	self.NPCRemovedEvent = CollectionService:GetInstanceRemovedSignal("ValentinesNPC"):Connect(function(p)
		local index = table.find(self.ValentinesOptions, p)

		if index then
			table.remove(self.ValentinesOptions, index)
		end
	end)
end

function FlowerBouquet:GetClosestStructure()
	local v = nil
	local v2 = 1e999

	if localPlayer.Character == nil then
		return
	end

	local position = localPlayer.Character:GetPivot().Position
	local structureOptions = self.StructureOptions

	if self.RealModel:GetAttribute("NumberFlowers") >= 4 then
		structureOptions = self.ValentinesOptions
		self.Prompt.ActionText = "Give Flowers"
	end

	for _, structureOption in pairs(structureOptions) do
		if structureOption:GetAttribute("GivenFlowers") or structureOption:GetAttribute("FlowersGiven" .. localPlayer.UserId) then
			continue
		end

		if not (structureOption.Parent == workspace.Structures or structureOption.Parent == workspace.Items or structureOption.Parent == workspace.Characters or (structureOption.Name == "Fairy" or structureOption.Name == "Beekeeper") and structureOption:IsDescendantOf(workspace)) then
			continue
		end

		local magnitude = (position - structureOption:GetPivot().Position).Magnitude

		if not (magnitude < v2) then
			continue
		end

		v = structureOption
		v2 = magnitude
	end

	return v, v2
end

function FlowerBouquet:HighlightClosestStructure()
	local closestStructure, v = self:GetClosestStructure()
	local v2 = nil

	if closestStructure and v <= 12 then
		v2 = closestStructure
	end

	if v2 ~= self.CurrentFocus then
		if self.HiddenPrompt then
			self.HiddenPrompt.Enabled = true
			self.HiddenPrompt = nil
		end

		if v2 then
			addFlowerHighlight.Adornee = v2
			addFlowerHighlight.Enabled = true
			self.Attachment.WorldCFrame = v2:GetPivot()
			self.Prompt.Enabled = true

			if v2.PrimaryPart and v2.PrimaryPart:FindFirstChild("ProximityAttachment") and v2.PrimaryPart.ProximityAttachment:FindFirstChild("ProximityInteraction") then
				self.HiddenPrompt = v2.PrimaryPart.ProximityAttachment.ProximityInteraction
				self.HiddenPrompt.Enabled = false
			end
		else
			addFlowerHighlight.Adornee = nil
			addFlowerHighlight.Enabled = false
			self.Prompt.Enabled = false
		end
	end

	self.CurrentFocus = v2
end

function FlowerBouquet:LoopCheckClosestStructures()
	task.spawn(function()
		while self.Equipped do
			self:HighlightClosestStructure()
			task.wait(0.1)
		end
	end)
end

function FlowerBouquet:DestroyPrompt()
	addFlowerHighlight.Adornee = nil

	if self.Attachment then
		self.Attachment:Destroy()
	end

	if self.HiddenPrompt then
		self.HiddenPrompt.Enabled = true
		self.HiddenPrompt = nil
	end
end

function FlowerBouquet:Break()
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function FlowerBouquet.Activate(_)
	return Enum.ContextActionResult.Sink
end

function FlowerBouquet.Deactivate(_) end

function FlowerBouquet:OnEquip()
	self.Equipped = true
	self:PrepareStructures()
	self:LoopCheckClosestStructures()
	self.OnFlowerChanged = self.RealModel:GetAttributeChangedSignal("NumberFlowers"):Connect(function()
		if self.RealModel:GetAttribute("NumberFlowers") >= 4 then
			self:HighlightClosestStructure()
		end
	end)
end

function FlowerBouquet:OnUnequip()
	self.Equipped = false

	if self.StructureRemovedEvent then
		self.StructureRemovedEvent:Disconnect()
	end

	if self.StructureRemovedEvent2 then
		self.StructureRemovedEvent2:Disconnect()
	end

	if self.StructureAddedEvent then
		self.StructureAddedEvent:Disconnect()
	end

	if self.StructureAddedEvent2 then
		self.StructureAddedEvent2:Disconnect()
	end

	if self.NPCAddedEvent then
		self.NPCAddedEvent:Disconnect()
	end

	if self.NPCRemovedEvent then
		self.NPCRemovedEvent:Disconnect()
	end

	self.OnFlowerChanged:Disconnect()
	self.StructureOptions = {}
	self:DestroyPrompt()
end

return FlowerBouquet