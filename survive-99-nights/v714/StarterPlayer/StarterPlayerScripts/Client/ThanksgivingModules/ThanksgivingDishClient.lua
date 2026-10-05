local TweenService = game:GetService("TweenService")
local ThanksgivingDishClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local proximityInteractions = {}
local v = {}

function ThanksgivingDishClient.AttemptPlaceDish(instance, model)
	if not model then
		local toolEquipped = Client.InventoryHandler.ToolEquipped()
		model = toolEquipped and toolEquipped.Model
	end

	if not model then
		return
	end

	local name = model.Name

	if instance:GetAttribute("HasDish") or name ~= instance:GetAttribute("DishName") then
		return
	end

	print("place dish", instance)
	local clone = model:Clone()

	for k, _ in pairs(clone:GetAttributes()) do
		clone:SetAttribute(k, nil)
	end

	clone:RemoveTag("Interaction")

	for _, part in pairs(clone:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = true
		part.CanCollide = false
	end

	clone:PivotTo(instance.PrimaryPart.DishPos.WorldCFrame)
	clone.Parent = workspace.Particles
	local parent = model.Parent
	model.Parent = game.ReplicatedStorage.TempStorage
	task.spawn(function()
		DishPlacedAnimation(instance)
	end)
	local v2 = Client.Events.RequestPlaceThanksgivingDish:InvokeServer(model, instance)

	if not (v2 and v2.Success) then
		model.Parent = parent
	end

	task.delay(0.1, function()
		clone:Destroy()
	end)
end

function DishPlacedAnimation(instance)
	if instance:GetAttribute("Animated") then
		return
	end

	instance:SetAttribute("Animated", true)
end

Client.Events.ThanksgivingDishPlacedAnimation:Connect(DishPlacedAnimation)
local name = nil

function FlashTarget(instance)
	if name and name == instance.Name then
		return
	end

	name = instance.Name
	task.spawn(function()
		while name and instance and name == instance.Name and instance:FindFirstChild("Circle") do
			TweenService:Create(
				instance.Circle.SurfaceGui.ImageLabel,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					ImageTransparency = 1
				}
			):Play()
			wait(0.2)

			if not (name and instance and name == instance.Name and instance:FindFirstChild("Circle")) then
				continue
			end

			TweenService:Create(
				instance.Circle.SurfaceGui.ImageLabel,
				TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					ImageTransparency = 0
				}
			):Play()
			wait(1)
		end

		if instance and instance:FindFirstChild("Circle") then
			TweenService:Create(
				instance.Circle.SurfaceGui.ImageLabel,
				TweenInfo.new(0.02, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
				{
					ImageTransparency = 0
				}
			):Play()
		end
	end)
end

function UpdatePrompts()
	local toolEquipped = Client.InventoryHandler.ToolEquipped()

	if not toolEquipped then
		name = nil
	end

	local model = toolEquipped and toolEquipped.Model
	local name2 = model and model.Name

	for _, v2 in pairs(proximityInteractions) do
		local parent = v2.Parent and v2.Parent.Parent and v2.Parent.Parent.Parent

		if not parent then
			continue
		end

		local parent2 = parent.Parent and parent.Parent.Parent

		if not parent2 then
			break
		end

		local circle = parent:FindFirstChild("Circle")
		local dishName = parent:GetAttribute("DishName")
		local hasDish = parent:GetAttribute("HasDish")

		if name2 and hasDish == nil and dishName == name2 and parent2:GetAttribute("ThanksgivingEventRunning") == nil then
			v2.Enabled = true

			if circle then
				FlashTarget(parent)
			end
		else
			v2.Enabled = false
		end
	end
end

function ListenForToolChange()
	Client.Events.EquippedItemChanged:Connect(function()
		UpdatePrompts()
		UpdateGlassPrompts()
	end)
	UpdatePrompts()
	UpdateGlassPrompts()
end

function DishSpotAdded(instance)
	local main = instance:WaitForChild("Main")
	main:WaitForChild("DishPos")
	local proximityInteraction = main:WaitForChild("ProximityAttachment"):WaitForChild("ProximityInteraction")
	table.insert(proximityInteractions, proximityInteraction)
end

function TableAdded(instance)
	local touchZone = instance:WaitForChild("TouchZone")
	local functional = instance.Parent:WaitForChild("Functional")
	touchZone.Touched:Connect(function(otherPart)
		if instance:GetAttribute("ThanksgivingEventRunning") then
			return
		end

		local parent = otherPart.Parent

		if parent:GetAttribute("Interaction") == nil or parent:GetAttribute("Owner") ~= localPlayer.UserId and parent:GetAttribute("LastOwner") ~= localPlayer.UserId then
			return
		end

		for _, child in pairs(functional:GetChildren()) do
			if not (child:GetAttribute("DishName") == parent.Name and child:GetAttribute("HasDish") == nil) then
				continue
			end

			ThanksgivingDishClient.AttemptPlaceDish(child, parent)
			break
		end
	end)
end

function ThanksgivingDishClient.RefillGlass(p)
	Client.Sound.Play("RefillCup", {
		Volume = 0.5,
		Replicate = true,
		ReplicationProperties = {
			Instance = localPlayer.Character.Head,
			Volume = 0.4
		}
	})
	Client.Events.RequestRefillThanksgivingGlass:FireServer(p)
end

function UpdateGlassPrompts()
	local toolEquipped = Client.InventoryHandler.ToolEquipped()
	local model = toolEquipped and toolEquipped.Model
	local name2 = model and model.Name

	for _, v2 in pairs(v) do
		if not (v2.Parent or v2.PrimaryPart) then
			continue
		end

		local empty = v2:GetAttribute("Empty")
		local drinking = v2:GetAttribute("Drinking")
		local proximityInteraction = v2.PrimaryPart.ProximityAttachment.ProximityInteraction

		if name2 == "Berry Juice Pitcher" and empty and not drinking then
			proximityInteraction.MaxActivationDistance = 8
			proximityInteraction.Enabled = true
			v2.DrinkFill.Enabled = true
		else
			proximityInteraction.Enabled = false
			v2.DrinkFill.Enabled = false
		end
	end
end

function DrinkGlassAdded(object)
	table.insert(v, object)
	object:GetAttributeChangedSignal("Empty"):Connect(function()
		UpdateGlassPrompts()
	end)
	object:GetAttributeChangedSignal("Drinking"):Connect(function()
		UpdateGlassPrompts()
	end)
end

function ThanksgivingDishClient.Init()
	Client.Utility.ForAllTagged("ThanksgivingDishSpot", DishSpotAdded)
	Client.Utility.ForAllTagged("ThanksgivingTable", TableAdded)
	Client.Utility.ForAllTagged("ThanksgivingGlass", DrinkGlassAdded)
	ListenForToolChange()
end

return ThanksgivingDishClient