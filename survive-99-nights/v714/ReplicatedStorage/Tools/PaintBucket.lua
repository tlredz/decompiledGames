local PaintBucket = {}
PaintBucket.__index = PaintBucket
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()
game:GetService("RunService")
game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local paintHighlight = workspace:WaitForChild("Highlights"):WaitForChild("PaintHighlight")
local color = Color3.fromRGB(13, 105, 172)

function PaintBucket:UpdatePaintColour()
	local paintPart = self.Model:FindFirstChild("PaintPart")

	if paintPart then
		paintPart.Color = color
	end

	local tool = Client.FirstPersonModule.GetTool()
	local paintPart2 = tool and tool:FindFirstChild("PaintPart")

	if paintPart2 then
		paintPart2.Color = color
	end
end

function PaintBucket.new(model, realModel)
	local self = setmetatable({}, PaintBucket)
	self.Model = model
	self.RealModel = realModel

	for k, v in pairs(self.RealModel:GetAttributes()) do
		self[k] = v
	end

	self:UpdatePaintColour()
	self:CreatePrompt()
	return self
end

function PaintBucket:CreatePrompt()
	local attachment = Instance.new("Attachment")
	attachment.Parent = workspace.Terrain
	self.Attachment = attachment
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.MaxActivationDistance = 16
	proximityPrompt.ActionText = "Paint"
	proximityPrompt.HoldDuration = 0.75
	proximityPrompt.Enabled = false
	proximityPrompt.Parent = attachment
	proximityPrompt.RequiresLineOfSight = false
	self.Prompt = proximityPrompt
	proximityPrompt.Triggered:Connect(function()
		print("paint", self.CurrentFocus)
		self:AttemptPaintStructure(self.CurrentFocus)
	end)
end

function PaintBucket:AttemptPaintStructure(adornee)
	if adornee.Parent ~= workspace.Structures then
		return
	end

	task.spawn(function()
		for _, child in pairs(adornee.Colourable:GetChildren()) do
			local vibrance = child:GetAttribute("Vibrance") or 1
			local HSV, v, v2 = color:ToHSV()
			child.Color = Color3.fromHSV(HSV, v, v2 * vibrance)
		end

		adornee:SetAttribute("PaintColour", color)
		self:HighlightClosestStructure()
		task.spawn(function()
			Client.Events.RequestPaintStructure:InvokeServer(adornee, color)
		end)
		task.spawn(function()
			local clone = paintHighlight:Clone()
			clone.Enabled = true
			clone.Name = "AnimHightlight"
			clone.Parent = workspace.Particles
			clone.Adornee = adornee
			TweenService:Create(clone, TweenInfo.new(0.3), {
				FillTransparency = 0
			}):Play()
			task.wait(0.3)
			TweenService:Create(clone, TweenInfo.new(1), {
				FillTransparency = 1
			}):Play()
			task.wait(1)
			clone:Destroy()
		end)
	end)
end

function PaintBucket:Break()
	self.Broken = true
	Client.InventoryHandler.ClearItemFromInventory(self.RealModel)
end

function PaintBucket:PrepareStructures()
	if self.LoopChecking then
		return
	end

	self.LoopChecking = true
	self.StructureOptions = CollectionService:GetTagged("Colourable")
	self.StructureAddedEvent = CollectionService:GetInstanceAddedSignal("Colourable"):Connect(function(p)
		table.insert(self.StructureOptions, p)
	end)
	self.StructureRemovedEvent = CollectionService:GetInstanceRemovedSignal("Colourable"):Connect(function(p)
		local index = table.find(self.StructureOptions, p)

		if index then
			table.remove(self.StructureOptions, index)
		end
	end)
end

function PaintBucket:GetClosestStructure()
	local v = nil
	local v2 = 1e999

	if localPlayer.Character == nil then
		return
	end

	local position = localPlayer.Character:GetPivot().Position

	for _, structureOption in pairs(self.StructureOptions) do
		if not (structureOption.Parent == workspace.Structures and structureOption:GetAttribute("PaintColour") ~= color) then
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

function PaintBucket:HighlightClosestStructure()
	local closestStructure, v = self:GetClosestStructure()
	local v2 = nil

	if closestStructure and v <= 16 then
		v2 = closestStructure
	end

	if v2 ~= self.CurrentFocus then
		if v2 then
			paintHighlight.OutlineColor = color
			paintHighlight.Adornee = v2
			paintHighlight.Enabled = true
			self.Attachment.WorldCFrame = v2:GetPivot()
			self.Prompt.Enabled = true
		else
			paintHighlight.Adornee = nil
			paintHighlight.Enabled = false
			self.Prompt.Enabled = false
		end
	end

	self.CurrentFocus = v2
end

function PaintBucket:LoopCheckClosestStructures()
	task.spawn(function()
		while self.Equipped do
			self:HighlightClosestStructure()
			task.wait(0.1)
		end
	end)
end

function PaintBucket.Activate(_)
	return Enum.ContextActionResult.Sink
end

function PaintBucket.Deactivate(_) end

local v = true
Client.Events.SetPaintColour:Connect(function(p)
	color = p
	paintHighlight.OutlineColor = color
end)

function PaintBucket:OnEquip()
	self.Equipped = true

	if v and localPlayer:GetAttribute("DecoratorGamePass") == nil then
		v = false
		Client.PopUpUI.AddPopUp("use this to paint structures in your base")
	end

	Client.StructureInterfaceClient.Recolour()
	self:PrepareStructures()
	self:LoopCheckClosestStructures()
	self.ColourEvent = Client.Events.SetPaintColour:Connect(function(p)
		color = p
		paintHighlight.OutlineColor = color
		self:UpdatePaintColour()
	end)
end

function PaintBucket:OnUnequip()
	self.Equipped = false
	Client.StructureInterfaceClient.CloseMenu()
	paintHighlight.Adornee = nil
	self.Attachment:Destroy()
	self.StructureRemovedEvent:Disconnect()
	self.StructureAddedEvent:Disconnect()
	self.StructureOptions = {}
	self.ColourEvent:Disconnect()
end

return PaintBucket