local InventoryHandler = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local RunService = game:GetService("RunService")
RunService:IsStudio()
game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local v = {}
local v2 = nil

function InventoryHandler.HasTool(p)
	for _, child in pairs(localPlayer.Inventory:GetChildren()) do
		if child.Name == p then
			return true
		end
	end

	return false
end

function InventoryHandler.ToolEquipped()
	return v2
end

function LocalItemAdded(instance)
	if instance:GetAttribute("LocalToPlayer") ~= localPlayer.UserId then
		instance.Parent = game.ReplicatedStorage.TempStorage
	end
end

function LocalItemRemoved(instance)
	local _ = instance:GetAttribute("LocalToPlayer") == localPlayer.UserId

	if not instance:HasTag("LocalToPlayer") and instance.Parent and instance.Parent == game.ReplicatedStorage.TempStorage then
		instance.Parent = workspace.Items
	end
end

Client.Utility.ForAllTagged("LocalToPlayer", LocalItemAdded, LocalItemRemoved)
Client.Utility.ForAllTagged("CultistCorpse", function(instance)
	for _, part in pairs(instance:GetChildren()) do
		if not (part:IsA("BasePart") and (part.Name == "Right Arm" or part.Name == "Left Arm" or part.Name == "Right Leg" or part.Name == "Left Leg")) then
			continue
		end

		part.CanCollide = true
	end
end)
local v3 = {}

function CheckActivateTool(_, p, _)
	if not Client.PlayerHandler.Alive then
		return
	end

	if p == Enum.UserInputState.Begin and Client.CutsceneModuleClient.IsCutsceneRunning() and workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable then
		return Enum.ContextActionResult.Pass
	end

	tostring(p)
	local v4 = v3[p] or 0

	if time() - v4 < 0.05 then
		return Enum.ContextActionResult.Pass
	end

	v3[p] = time()

	if v2 and v2.Tool then
		local v5 = nil

		if p == Enum.UserInputState.Begin then
			v5 = v2.Tool:Activate()
		elseif p == Enum.UserInputState.End then
			v5 = v2.Tool:Deactivate()
		end

		if v5 == Enum.ContextActionResult.Sink then
			return Enum.ContextActionResult.Sink
		end
	end

	return Enum.ContextActionResult.Pass
end

ContextActionService:BindActionAtPriority(
	"CheckActivateTool",
	CheckActivateTool,
	false,
	Enum.ContextActionPriority.High.Value + 1,
	Enum.UserInputType.MouseButton1,
	Enum.KeyCode.ButtonR2
)

function InventoryHandler.ActivateTool(p, ...)
	if v2 and v2.Tool then
		v2.Tool:Activate(p, ...)
	end
end

function InventoryHandler.DeactivateTool(...)
	if v2 and v2.Tool then
		v2.Tool:Deactivate(...)
	end
end

Client.Events.ChangeWeaponAmmo:Connect(function(p, p2: number)
	local tool = v2 and v2.Model == p and v2.Tool

	if tool then
		tool:ChangeAmmo(p2)
	end
end)

function EquipItemToCharacter(folder, parent, p)
	if not (folder:FindFirstChild("Handle") or folder:FindFirstChild("Main")) then
		local _ = folder.PrimaryPart
	end

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.Anchored = false
		part.Massless = true
		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
	end

	if folder:GetAttribute("ToolName") == "Shield" then
		for _, part in pairs(folder:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanQuery = true
			end
		end
	end

	if folder:GetAttribute("SplitHanded") then
		local right = folder.Right
		local left = folder.Left
		Client.Utility.AttachTool(parent, right, p)
		Client.Utility.AttachTool(parent, left, p)
		folder.PrimaryPart:Destroy()
		folder.PrimaryPart = right.PrimaryPart
		folder.Parent = parent
	else
		Client.Utility.AttachTool(parent, folder, p)
		folder.Parent = parent
	end
end

Client.Events.PlayWeaponSound:Connect(function(player)
	local toolHandle = player.Character and player.Character:FindFirstChild("ToolHandle")

	if toolHandle and toolHandle.PrimaryPart:FindFirstChild("FireSound") then
		toolHandle.PrimaryPart.FireSound:Play()
	end
end)
local v4 = {
	Hat = true
}

function UpdateHatVisibility(instance)
	local v5 = instance:FindFirstChild("HeadArmour") ~= nil

	for _, accoutrement in pairs(instance:GetChildren()) do
		if not (accoutrement:IsA("Accoutrement") and v5 and v4[accoutrement.AccessoryType.Name]) then
			continue
		end

		accoutrement:SetAttribute("HatHidden", true)

		for _, part in pairs(accoutrement:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Transparency = 1
			end
		end
	end
end

function UpdateFlowerBouquet(instance, parent)
	local v5 = {}

	for _, child in pairs(parent:GetChildren()) do
		if child.Name == "ServerFlower" then
			child:Destroy()
		end
	end

	local function update()
		for i = 1, 4 do
			if not (instance:GetAttribute("Flower" .. i) and v5[i] == nil) then
				continue
			end

			v5[i] = true
			local attribute = instance:GetAttribute("Flower" .. i)
			local child = game.ReplicatedStorage.Assets.Flowers:FindFirstChild(attribute)

			if not child then
				continue
			end

			local clone = child:Clone()
			clone.Parent = parent
			clone:PivotTo(parent.PrimaryPart:FindFirstChild("Flower" .. i .. "CF").WorldCFrame)
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Parent = clone.PrimaryPart
			weldConstraint.Part0 = clone.PrimaryPart
			weldConstraint.Part1 = parent.PrimaryPart
		end
	end

	local numberFlowersChangedConnection = nil
	update()
	numberFlowersChangedConnection = instance:GetAttributeChangedSignal("NumberFlowers"):Connect(function()
		if parent.Parent == nil then
			numberFlowersChangedConnection:Disconnect()
		else
			update()
		end
	end)
end

function UpdateEasterBasket(instance, _, parent)
	local eggBasket = instance:WaitForChild("EggBasket")
	local v5 = {}

	local function update()
		local children = eggBasket:GetChildren()

		for i = 1, 10 do
			if v5[i] and (children[i] == nil or v5[i].Name ~= children[i].Name) then
				v5[i]:Destroy()
				v5[i] = nil
			end

			if not (children[i] and v5[i] == nil) then
				continue
			end

			local egg = parent.Eggs["Egg" .. i]
			local clone = children[i]:Clone()
			clone:ScaleTo(0.3)

			for k, _ in pairs(clone:GetAttributes()) do
				clone:SetAttribute(k, nil)
			end

			for _, tag in pairs(clone:GetTags()) do
				clone:RemoveTag(tag)
			end

			for _, descendant in pairs(clone:GetDescendants()) do
				if descendant:IsA("BasePart") then
					descendant.CanCollide = false
					descendant.Massless = true
				elseif descendant:IsA("PointLight") then
					descendant:Destroy()
				end
			end

			clone:PivotTo(egg.CFrame)
			local weldConstraint = Instance.new("WeldConstraint")
			weldConstraint.Parent = clone.PrimaryPart
			weldConstraint.Part0 = clone.PrimaryPart
			weldConstraint.Part1 = egg
			clone.Parent = parent
			v5[i] = clone
		end
	end

	local childAddedConnection = nil
	local childRemovedConnection = nil
	update()
	childAddedConnection = eggBasket.ChildAdded:Connect(function()
		if parent.Parent ~= nil then
			update()
			return
		end

		childAddedConnection:Disconnect()
		childRemovedConnection:Disconnect()
	end)
	childRemovedConnection = eggBasket.ChildRemoved:Connect(function()
		if parent.Parent ~= nil then
			update()
			return
		end

		childAddedConnection:Disconnect()
		childRemovedConnection:Disconnect()
	end)
end

function UpdateWoodsmanAxe(instance, _, folder)
	local function update(p)
		for _, part in pairs(folder:GetDescendants()) do
			if not part:IsA("BasePart") then
				continue
			end

			local v5 = tonumber(string.match(part.Name, "^Axe(%d+)$"))

			if v5 then
				part.Transparency = v5 <= p and 0 or 1
			end
		end
	end

	update(1)
	local woodsmanClassStats = instance:WaitForChild("WoodsmanClassStats", 10)

	if not woodsmanClassStats then
		return
	end

	update(woodsmanClassStats:GetAttribute("AxeLevel") or 1)
	local axeLevelChangedConnection = nil
	axeLevelChangedConnection = woodsmanClassStats:GetAttributeChangedSignal("AxeLevel"):Connect(function()
		if folder.Parent == nil then
			axeLevelChangedConnection:Disconnect()
			return
		end

		update(woodsmanClassStats:GetAttribute("AxeLevel") or 1)

		if instance == localPlayer then
			Client.Utility.RunParticles(folder)
		end
	end)
end

function ShowLevelParticles(folder, p)
	for _, descendant in pairs(folder:GetDescendants()) do
		if descendant:GetAttribute("ShowAtLevel") then
			descendant.Enabled = descendant:GetAttribute("ShowAtLevel") == p
		end
	end
end

function UpdateHappysScythe(p, instance, p2)
	local scytheLevelChangedConnection = nil
	scytheLevelChangedConnection = instance:GetAttributeChangedSignal("ScytheLevel"):Connect(function()
		if p2.Parent == nil then
			scytheLevelChangedConnection:Disconnect()
			return
		end

		local scytheLevel = instance:GetAttribute("ScytheLevel")
		ShowLevelParticles(p2, scytheLevel)
		local v5 = p2
		local tool = Client.FirstPersonModule.GetTool()

		if p == localPlayer and tool then
			ShowLevelParticles(tool, scytheLevel)

			if Client.FirstPersonModule.IsVisible() then
				v5 = tool
			end
		end

		if scytheLevel > 1 then
			Client.Utility.SpawnParticles("Construct_Spark", v5.Head.CFrame, {
				Color = ColorSequence.new(Color3.fromRGB(150, 50, 255))
			})
		end
	end)
end

function EquipItemHandle(player, instance)
	local toolHandle = player.Character and player.Character:FindFirstChild("ToolHandle")

	if toolHandle then
		toolHandle:Destroy()
	end

	local clone = instance:Clone()
	clone.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	CollectionService:RemoveTag(clone, "Interaction")
	clone:SetAttribute("Interaction", nil)
	clone.Name = "ToolHandle"
	local objectValue = Instance.new("ObjectValue", clone)
	objectValue.Name = "OriginalItem"
	objectValue.Value = instance
	EquipItemToCharacter(clone, player.Character)

	if instance.Name == "Bouquet" then
		task.spawn(function()
			UpdateFlowerBouquet(instance, clone)
		end)
	elseif instance.Name == "Egg Basket" then
		task.spawn(function()
			UpdateEasterBasket(player, instance, clone)
		end)
	elseif instance.Name == "Woodsman's Axe" then
		task.spawn(function()
			UpdateWoodsmanAxe(player, instance, clone)
		end)
	elseif instance.Name == "Happy's Scythe" then
		UpdateHappysScythe(player, instance, clone)
	end

	if clone.PrimaryPart and clone.PrimaryPart:FindFirstChild("EquipSound") then
		clone.PrimaryPart.EquipSound:Play()
	end

	return clone
end

Client.Events.EquipItemHandle:Connect(EquipItemHandle)
Client.Events.UnequipItemHandle:Connect(function(player, p)
	local toolHandle = player.Character and player.Character:FindFirstChild("ToolHandle")

	if toolHandle and toolHandle:FindFirstChild("OriginalItem") and toolHandle.OriginalItem.Value == p then
		toolHandle:Destroy()
	end
end)

function InventoryHandler:ClearItemFromInventory()
	if v2 and v2.Model == self then
		InventoryHandler.UnequipCurrentItem()
	end

	self.Parent = game.ReplicatedStorage.TempStorage
end

Client.Events.UnequipCurrentItem:Connect(function()
	InventoryHandler.UnequipCurrentItem()
end)

function InventoryHandler.GetCurrentlyEquipped()
	return v2 and v2.Model
end

function InventoryHandler.GetCurrentlyEquippedClass()
	return v2
end

function MatchModelColours(folder, instance)
	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		local child = instance:FindFirstChild(part.Name, true)

		if not child then
			continue
		end

		part.Color = child.Color
		part.Material = child.Material
		part.MaterialVariant = child.MaterialVariant
		part.Transparency = child.Transparency

		if not child:FindFirstChild("GoldSparkles") then
			continue
		end

		local clone = child.GoldSparkles:Clone()
		clone.Parent = part
	end
end

function EnableArmourTrim(folder)
	for _, part in pairs(folder:GetDescendants()) do
		if not (part:IsA("BasePart") and part:GetAttribute("GoldTrim")) then
			continue
		end

		part.Transparency = 0
		part.Material = "Metal"
		part.MaterialVariant = ""
		part.Color = Color3.fromRGB(239, 224, 107)
	end
end

Client.Events.UpdateToolHandleColours:Connect(function(player, instance)
	if instance:GetAttribute("Interaction") == "Armour" then
		local torsoArmour = player.Character and player.Character:FindFirstChild("TorsoArmour")

		if torsoArmour then
			EnableArmourTrim(torsoArmour)
		end
	elseif player == localPlayer then
		if not (v2 and v2.Model == instance and v2.Tool) then
			return
		end

		if v2.Tool.UpdateParams then
			v2.Tool:UpdateParams()
		end

		MatchModelColours(v2.Tool.Model, instance)
		local tool = Client.FirstPersonModule.GetTool()

		if tool then
			MatchModelColours(tool, instance)
		end
	else
		local toolHandle = player.Character and player.Character:FindFirstChild("ToolHandle")

		if toolHandle and toolHandle:FindFirstChild("OriginalItem") and toolHandle.OriginalItem.Value == instance then
			MatchModelColours(toolHandle, instance)
		end
	end
end)

function InventoryHandler.RequestEquipItem(instance)
	if not Client.PlayerHandler.Alive or instance.Parent ~= localPlayer.Inventory or localPlayer:GetAttribute("Undead") or Client.Utility.IsDisabled(localPlayer) then
		return
	end

	if localPlayer:GetAttribute("Class") == "Brawler" and (instance:GetAttribute("ToolName") == "Firearm" or instance:GetAttribute("ToolName") == "ThrownWeapon") and instance.Name ~= "Air Rifle" then
		Client.Events.SetPopUpMessage:Fire("Brawler class can't use ranged weapons", "warning")
		return
	end

	if v2 and v2.Model ~= instance and v2.Tool then
		Client.Events.StopAnimation:Fire(v2.Tool.ToolHoldAnim or "DefaultToolHold")
		Client.FirstPersonModule.ClearTool(v2.Tool.ToolHoldAnim)
		v2.Tool:Deactivate()
		v2.Tool:OnUnequip()
		Client.GuiButtonHandler.HideButton("Drop")
	end

	if instance:GetAttribute("ToolName") and instance:GetAttribute("ToolName") == "Firearm" then
		Client.Sound.Play("HolsterGun")
	end

	local fakeModel = EquipItemHandle(localPlayer, instance)
	v2 = {
		Model = instance,
		FakeModel = fakeModel
	}
	Client.FirstPersonModule.ClearTool()
	local toolName = instance:GetAttribute("ToolName") or instance.Name

	if v[toolName] then
		local tool = v[toolName].new(fakeModel, instance)
		v2.Tool = tool
		tool:OnEquip()
	end

	Client.FirstPersonModule.AddTool(instance, v2.Tool and v2.Tool.ToolHoldAnim)
	Client.InventoryUI.SetEquippedButton(instance)
	Client.Events.EquippedItemChanged:Fire(instance)
	local _ = v2.Tool and v2.Tool.ToolHoldAnim
	Client.Events.PlayAnimation:Fire(v2.Tool and v2.Tool.ToolHoldAnim or "DefaultToolHold")
	Client.Events.EquipItemHandle:FireOtherClients(instance)

	if not instance:GetAttribute("NoDropping") then
		Client.GuiButtonHandler.ShowButton("Drop")
	end
end

Client.Events.PlayerDied:Connect(function()
	print("player died")
	InventoryHandler.UnequipCurrentItem()
end)

function InventoryHandler.UnequipCurrentItem()
	local toolHoldAnim

	if v2 then
		toolHoldAnim = v2.Tool and v2.Tool.ToolHoldAnim

		if v2.Tool then
			print("deactivate and unequip")
			v2.Tool:Deactivate()
			v2.Tool:OnUnequip()
		end

		Client.Events.UnequipItemHandle:FireAllClients(v2.Model)
		Client.FirstPersonModule.ClearTool(toolHoldAnim)
	end

	v2 = nil
	Client.InventoryUI.SetEquippedButton(nil)
	Client.Events.StopAnimation:Fire(toolHoldAnim or "DefaultToolHold")
	Client.Events.EquippedItemChanged:Fire()
	Client.GuiButtonHandler.HideButton("Drop")
end

function InventoryHandler.DropEquippedItem()
	local pivot = v2.FakeModel:GetPivot()
	local model = v2.Model

	if model:GetAttribute("NoDropping") then
		InventoryHandler.UnequipCurrentItem()
		return
	end

	local latest = Client.InventoryUI.GetLatestFromItemStack(model)
	latest:PivotTo(pivot)
	latest.Parent = workspace.Items
	Client.Events.RequestDropItem:FireServer(latest, pivot)
end

function EquipArmour(player, childName)
	local child = game.ReplicatedStorage.Assets.ArmourModels:WaitForChild(childName)
	local armourSlot = child:GetAttribute("ArmourSlot")
	local character = player.Character or player.CharacterAdded:Wait()
	local child2 = character:FindFirstChild(armourSlot .. "Armour")

	if child2 then
		child2:Destroy()
	end

	local folder = Client.Utility.CloneArmourModel(character, child)
	folder:PivotTo(character:GetPivot())
	folder.Name = armourSlot .. "Armour"
	folder.Parent = character

	for _, part in pairs(folder:GetDescendants()) do
		if not part:IsA("BasePart") then
			continue
		end

		part.CanCollide = false
		part.CanQuery = false
		part.CanTouch = false
		part.Massless = true
	end

	for _, child3 in pairs(folder:GetChildren()) do
		Client.Utility.AttachTool(character, child3, true)
	end

	UpdateHatVisibility(player.Character)
	task.spawn(function()
		local child3 = player.Armour:FindFirstChild(childName)

		if child3 and child3:GetAttribute("GoldTrimmed") then
			EnableArmourTrim(folder)
		end
	end)
end

Client.Events.EquipArmourModel:Connect(EquipArmour)
Client.Events.UnequipArmourModel:Connect(function(player, p)
	local child = player.Character:FindFirstChild(p .. "Armour")

	if child then
		child:Destroy()
	end

	UpdateHatVisibility(player.Character)
end)

function ArmourAdded(p)
	Client.Events.EquipArmourModel:FireAllClients(p.Name)
	task.spawn(function()
		if p.Name == "Vampire Cloak" then
			print("cloak")
			Client.LifestealClient.EnableBar()
		end
	end)
end

function ArmourRemoved(instance)
	local armourSlot = instance:GetAttribute("ArmourSlot")
	local v5 = false

	for _, child in pairs(localPlayer.Armour:GetChildren()) do
		if child:GetAttribute("ArmourSlot") ~= armourSlot then
			continue
		end

		Client.Events.EquipArmourModel:FireAllClients(child.Name)
		v5 = true
		break
	end

	if not v5 then
		Client.Events.UnequipArmourModel:FireAllClients(armourSlot)
	end

	UpdateHatVisibility(localPlayer.Character)
end

localPlayer.CharacterAppearanceLoaded:Connect(function(character)
	task.wait(1)
	local children = localPlayer:WaitForChild("Armour"):GetChildren()

	for _, v5 in pairs(children) do
		print("equip", v5.Name)
		Client.Events.EquipArmourModel:FireAllClients(v5.Name)
	end

	UpdateHatVisibility(character)
end)
ContextActionService:BindActionAtPriority("DropEquippedItem", function(_, p, _)
	if p ~= Enum.UserInputState.Begin then
		return
	end

	if not v2 then
		return Enum.ContextActionResult.Pass
	end

	InventoryHandler.DropEquippedItem()
	return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.Backspace, Enum.KeyCode.DPadLeft)

function LoadToolModules()
	for _, moduleScript in pairs(game.ReplicatedStorage.Tools:GetChildren()) do
		local v5 = v
		local name = moduleScript.Name
		local module = require(moduleScript)
		v5[name] = module
	end
end

function InventoryHandler.Init()
	task.spawn(function()
		localPlayer:WaitForChild("Armour").ChildAdded:Connect(ArmourAdded)
		localPlayer:WaitForChild("Armour").ChildRemoved:Connect(ArmourRemoved)

		for _, child in pairs(localPlayer.Armour:GetChildren()) do
			ArmourAdded(child)
		end
	end)
	task.spawn(function()
		localPlayer:GetAttributeChangedSignal("Undead"):Connect(function()
			InventoryHandler.UnequipCurrentItem()
		end)
		localPlayer:GetAttributeChangedSignal("HalloweenTransformed"):Connect(function()
			InventoryHandler.UnequipCurrentItem()
		end)
	end)
	LoadToolModules()
end

return InventoryHandler