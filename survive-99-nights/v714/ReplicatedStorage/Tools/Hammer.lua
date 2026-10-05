local Hammer = {}
Hammer.__index = Hammer
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()
game:GetService("RunService")
game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local pickUpHighlight = workspace:WaitForChild("Highlights"):WaitForChild("PickUpHighlight")
local color = Color3.fromRGB(0, 200, 0)
local color2 = Color3.fromRGB(220, 40, 40)

function Hammer.new(model, realModel)
	local self = setmetatable({}, Hammer)
	self.Model = model
	self.RealModel = realModel

	for k, v in pairs(self.RealModel:GetAttributes()) do
		self[k] = v
	end

	self:CreatePrompt()
	return self
end

function Hammer:CreatePrompt()
	local attachment = Instance.new("Attachment")
	attachment.Parent = workspace.Terrain
	self.Attachment = attachment
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.MaxActivationDistance = 15
	proximityPrompt.ActionText = "Pick Up"
	proximityPrompt.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
	proximityPrompt.HoldDuration = 0.75
	proximityPrompt.Enabled = false
	proximityPrompt.Parent = attachment
	proximityPrompt.RequiresLineOfSight = false
	self.Prompt = proximityPrompt
	proximityPrompt.Triggered:Connect(function()
		print("pick up", self.CurrentFocus)
		self:AttemptPickUpStructure(self.CurrentFocus)
	end)
	local proximityPrompt2 = Instance.new("ProximityPrompt")
	proximityPrompt2.MaxActivationDistance = 15
	proximityPrompt2.KeyboardKeyCode = Enum.KeyCode.F
	proximityPrompt2.GamepadKeyCode = Enum.KeyCode.ButtonY
	proximityPrompt2.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
	proximityPrompt2.HoldDuration = 0.5
	proximityPrompt2.UIOffset = Vector2.new(0, 80)
	proximityPrompt2.Enabled = false
	proximityPrompt2.Parent = attachment
	proximityPrompt2.RequiresLineOfSight = false
	self.SeatPrompt = proximityPrompt2
	proximityPrompt2.Triggered:Connect(function()
		if self.CurrentFocus then
			Client.Events.RequestToggleSeats:FireServer(self.CurrentFocus)
		end
	end)
	local model = Instance.new("Model")
	model.Name = "HammerSeats"
	model.Parent = workspace.Particles
	self.SeatProxies = model
	local highlight = Instance.new("Highlight")
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded
	highlight.FillTransparency = pickUpHighlight.FillTransparency
	highlight.Parent = model
	self.SeatHighlight = highlight
end

function Hammer:AttemptPickUpStructure(instance)
	if instance.Parent ~= workspace.Structures and instance.Parent ~= workspace.Map.Foliage or instance:GetAttribute("Driver") then
		return
	end

	if instance:HasTag("Turret") and instance:GetAttribute("Owner") ~= localPlayer.UserId then
		return
	end

	task.spawn(function()
		if instance:HasTag("FoliageNearFire") and instance.Parent == workspace.Map.Foliage then
			local index = table.find(self.DestroyOptions, instance)

			if index then
				table.remove(self.DestroyOptions, index)
			end

			instance.Parent = game.ReplicatedStorage.TempStorage
			self:HighlightClosestStructure()
			local v = Client.Events.RequestDestroyFoliage:InvokeServer(instance)

			if not (v and v.Success) and instance:GetAttribute("Destroyed") == nil then
				instance.Parent = workspace.Map.Foliage
				table.insert(self.DestroyOptions, instance)
				self:HighlightClosestStructure()
			end
		else
			local index = table.find(self.StructureOptions, instance)

			if index then
				table.remove(self.StructureOptions, index)
			end

			instance.Parent = game.ReplicatedStorage.TempStorage
			self:HighlightClosestStructure()
			local v = Client.Events.RequestPickUpStructure:InvokeServer(instance)

			if not (v and v.Success) and instance:GetAttribute("Destroyed") == nil then
				instance.Parent = workspace.Structures
				table.insert(self.StructureOptions, instance)
				self:HighlightClosestStructure()
			end
		end

		Client.Sound.Play("HammerBreak")
	end)
end

function Hammer:Break()
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function Hammer:PrepareStructures()
	if self.LoopChecking then
		return
	end

	self.LoopChecking = true
	self.StructureOptions = CollectionService:GetTagged("CanBePickedUp")
	self.DestroyOptions = CollectionService:GetTagged("FoliageNearFire")
	self.StructureAddedEvent = CollectionService:GetInstanceAddedSignal("CanBePickedUp"):Connect(function(p)
		table.insert(self.StructureOptions, p)
	end)
	self.StructureRemovedEvent = CollectionService:GetInstanceRemovedSignal("CanBePickedUp"):Connect(function(p)
		local index = table.find(self.StructureOptions, p)

		if index then
			table.remove(self.StructureOptions, index)
		end
	end)
	self.FoliageAddedEvent = CollectionService:GetInstanceAddedSignal("FoliageNearFire"):Connect(function(p)
		table.insert(self.DestroyOptions, p)
	end)
	self.FoliageRemovedEvent = CollectionService:GetInstanceRemovedSignal("FoliageNearFire"):Connect(function(p)
		local index = table.find(self.DestroyOptions, p)

		if index then
			table.remove(self.DestroyOptions, index)
		end
	end)
end

function Hammer:GetClosestStructure()
	local v = nil
	local v2 = 1e999

	if localPlayer.Character == nil then
		return
	end

	local position = localPlayer.Character:GetPivot().Position

	for _, structureOption in pairs(self.StructureOptions) do
		if structureOption:GetAttribute("Driver") or not (not structureOption:HasTag("Turret") or structureOption:GetAttribute("Owner") == localPlayer.UserId) then
			continue
		end

		if not ((not Client.GlobalSettings.TeleporterOwnerOnly or not structureOption:HasTag("Teleporter") or structureOption:GetAttribute("BuiltBy") == localPlayer.UserId) and structureOption.Parent == workspace.Structures) then
			continue
		end

		local magnitude = (position - structureOption:GetPivot().Position).Magnitude

		if not (magnitude < v2) then
			continue
		end

		v = structureOption
		v2 = magnitude
	end

	for _, destroyOption in pairs(self.DestroyOptions) do
		if not (destroyOption.Parent == workspace.Map.Foliage and destroyOption:HasTag("FoliageNearFire")) then
			continue
		end

		local magnitude = (position - destroyOption:GetPivot().Position).Magnitude

		if not (magnitude < v2) then
			continue
		end

		v = destroyOption
		v2 = magnitude
	end

	return v, v2
end

function Hammer:HighlightClosestStructure()
	local closestStructure, v = self:GetClosestStructure()
	local v2 = nil

	if self.Equipped and closestStructure and v <= 10 then
		v2 = closestStructure
	end

	if v2 ~= self.CurrentFocus then
		if v2 then
			pickUpHighlight.Adornee = v2
			pickUpHighlight.Enabled = true
			self.Attachment.WorldCFrame = v2:GetPivot()
			self.Prompt.Enabled = true
			Client.PromptHandler.HideAllPrompts("Hammer")

			if v2:HasTag("FoliageNearFire") then
				self.Prompt.ActionText = "Destroy"
			elseif v2:HasTag("Turret") then
				self.Prompt.ActionText = "Remove"
			else
				self.Prompt.ActionText = "Pick Up"
			end
		else
			pickUpHighlight.Adornee = nil
			pickUpHighlight.Enabled = false
			self.Prompt.Enabled = false
			Client.PromptHandler.ShowAllPrompts("Hammer")
		end
	end

	local seatsDisabled = v2 and v2:GetAttribute("SeatsDisabled")

	if v2 ~= self.CurrentFocus or seatsDisabled ~= self.SeatsDisabled then
		self.SeatsDisabled = seatsDisabled
		self:ShowSeats(v2)
	end

	self.CurrentFocus = v2
end

function Hammer:ShowSeats(folder)
	for _, part in pairs(self.SeatProxies:GetChildren()) do
		if part:IsA("BasePart") then
			part:Destroy()
		end
	end

	local v = self.SeatsDisabled and color2 or color
	local enabled = false

	if folder then
		for _, seat in pairs(folder:GetDescendants()) do
			if not seat:IsA("Seat") then
				continue
			end

			local part = Instance.new("Part")
			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CanTouch = false
			part.CastShadow = false
			part.Color = v
			part.Size = seat.Size
			part.CFrame = seat.CFrame
			part.Parent = self.SeatProxies
			enabled = true
		end
	end

	self.SeatHighlight.FillColor = v
	self.SeatHighlight.OutlineColor = v
	self.SeatPrompt.ActionText = self.SeatsDisabled and "Enable Seats" or "Disable Seats"
	self.SeatPrompt.Enabled = enabled
end

function Hammer:LoopCheckClosestStructures()
	task.spawn(function()
		while self.Equipped do
			self:HighlightClosestStructure()
			task.wait(0.1)
		end
	end)
end

function Hammer.Activate(_)
	return Enum.ContextActionResult.Sink
end

function Hammer.Deactivate(_) end

local v = true

function Hammer:OnEquip()
	self.Equipped = true

	if v and localPlayer:GetAttribute("DecoratorGamePass") == nil then
		v = false
		Client.PopUpUI.AddPopUp("use this to move structures in your base")
	end

	self:PrepareStructures()
	self:LoopCheckClosestStructures()
end

function Hammer:OnUnequip()
	self.Equipped = false
	pickUpHighlight.Adornee = nil
	self.Attachment:Destroy()
	self.SeatProxies:Destroy()
	Client.PromptHandler.ShowAllPrompts("Hammer")
	self.StructureRemovedEvent:Disconnect()
	self.StructureAddedEvent:Disconnect()
	self.StructureOptions = {}
	self.FoliageRemovedEvent:Disconnect()
	self.FoliageAddedEvent:Disconnect()
	self.DestroyOptions = {}
end

return Hammer