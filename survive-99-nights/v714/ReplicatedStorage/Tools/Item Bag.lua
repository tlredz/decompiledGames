local ItemBag = {}
ItemBag.__index = ItemBag
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
localPlayer:GetMouse()
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")

function ItemBag.new(model, realModel)
	local self = setmetatable({}, ItemBag)
	self.Model = model
	self.RealModel = realModel
	self.EasterBasket = realModel:GetAttribute("EasterBasket")
	self.ItemsFolder = self.EasterBasket and localPlayer.EggBasket or localPlayer.ItemBag
	return self
end

function ItemBag.Break(p)
	Client.InventoryHandler.ClearItemFromInventory(p.RealModel)
end

function ItemBag.Activate(_) end

function ItemBag.Deactivate(_) end

function ItemBag:UpdateLabel(p2, list, p3)
	local itemBagUsedSpace = Client.Utility.GetItemBagUsedSpace(list, localPlayer)
	p2.TextLabel.Text = `{#list}/{p3}`

	if p3 <= itemBagUsedSpace then
		p2.TextLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
	elseif self.EasterBasket then
		p2.TextLabel.TextColor3 = Color3.fromRGB(255, 170, 255)
	else
		p2.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	end

	p2.Enabled = true
end

function ItemBag:UpdateCapacityUI(lastUpdatedItems, p)
	local itemBagSpace = Client.Utility.GetItemBagSpace(self.RealModel, localPlayer)
	self.LastUpdatedItems = lastUpdatedItems

	if lastUpdatedItems and self.RealModel then
		self.RealModel:SetAttribute("NumberItems", #lastUpdatedItems)
		self.RealModel:SetAttribute("CountedItems", Client.Utility.GetItemBagUsedSpace(lastUpdatedItems, localPlayer))
	end

	if p then
		self.Model.PrimaryPart.BagAmount.Enabled = false
		local tool = Client.FirstPersonModule.GetTool()

		if tool then
			tool.PrimaryPart.BagAmount.Enabled = false
		end
	else
		local tool = Client.FirstPersonModule.GetTool()

		if tool and Client.FirstPersonModule.IsVisible() then
			self:UpdateLabel(tool.PrimaryPart.BagAmount, lastUpdatedItems, itemBagSpace)
			self.Model.PrimaryPart.BagAmount.Enabled = false
		else
			self:UpdateLabel(self.Model.PrimaryPart.BagAmount, lastUpdatedItems, itemBagSpace)

			if tool then
				tool.PrimaryPart.BagAmount.Enabled = false
			end
		end
	end
end

function ItemBag:FirstPersonToggled()
	local lastUpdatedItems = self.LastUpdatedItems or {}
	local itemBagSpace = Client.Utility.GetItemBagSpace(self.RealModel, localPlayer)
	local tool = Client.FirstPersonModule.GetTool()

	if tool and Client.FirstPersonModule.IsVisible() then
		self:UpdateLabel(tool.PrimaryPart.BagAmount, lastUpdatedItems, itemBagSpace)
		self.Model.PrimaryPart.BagAmount.Enabled = false
	else
		self:UpdateLabel(self.Model.PrimaryPart.BagAmount, lastUpdatedItems, itemBagSpace)

		if tool then
			tool.PrimaryPart.BagAmount.Enabled = false
		end
	end
end

function ItemBag:BagItem(instance)
	if instance:HasTag("ItemBag") or instance:GetAttribute("Ignited") or instance:GetAttribute("Destroyed") then
		return
	end

	if self.EasterBasket and instance:GetAttribute("EasterEggId") == nil then
		return
	end

	if not self.EasterBasket and instance:GetAttribute("EasterEggId") then
		Client.PopUpUI.AddPopUp("You need an egg basket to collect this", "easterwarning")
		return
	end

	if instance:GetAttribute("Interaction") == "NightPlant" then
		Client.Events.SetPopUpMessage:Fire("You can only pick this at night", "night")
		return
	end

	if instance.Parent ~= workspace.Items and (instance.Parent ~= workspace.Characters or not instance:GetAttribute("CanBeBagged")) then
		return
	end

	if instance:GetAttribute("Locked") and instance:GetAttribute("LockedMessage") then
		Client.PopUpUI.AddPopUp(instance:GetAttribute("LockedMessage"), "warning")
		return
	end

	if Client.InteractionHandler.CheckCollectCurrency(instance, "ItemBag") then
		return
	end

	local itemBagSpace = Client.Utility.GetItemBagSpace(self.RealModel, localPlayer)
	local children = self.ItemsFolder:GetChildren()

	if Client.Utility.ItemNeedsBagSpace(instance, localPlayer) and itemBagSpace <= Client.Utility.GetItemBagUsedSpace(
		children,
		localPlayer
	) then
		print("Your bag is full")
		return
	end

	if instance.Parent == workspace.Characters and instance:GetAttribute("CanBeBagged") and instance:FindFirstChild("Head") and instance.Head:FindFirstChild("KidCrying") then
		Client.Sound.Play("KidInBag", {
			Replicate = true,
			ReplicationProperties = {
				Position = instance.Head.Position
			}
		})
	end

	if instance.PrimaryPart then
		instance.PrimaryPart.AssemblyLinearVelocity = Vector3.new()
	end

	table.insert(children, instance)
	self:UpdateCapacityUI(children)
	local parent = instance.Parent
	instance.Parent = game.ReplicatedStorage.TempStorage
	local v = Client.Events.RequestBagStoreItem:InvokeServer(self.RealModel, instance)
	local v2 = self.EasterBasket and "EasterBasketGet" or "BagGet"
	Client.Sound.Play(v2, {
		Volume = 0.7,
		Replicate = true,
		Duplicate = true,
		ReplicationProperties = {
			Instance = localPlayer.Character.Head,
			Volume = 0.25
		}
	})

	if v and v.Success then
		if v.Cooked then
			Client.Sound.Play("CookFire", {
				Duplicate = true
			})
			Client.Sound.Play("CookInBag", {
				Duplicate = true
			})
			task.spawn(function()
				for _, emitter in pairs(self.Model.PrimaryPart:GetChildren()) do
					if emitter:IsA("ParticleEmitter") and emitter.Name == "EmitMe" then
						emitter:Emit(emitter:GetAttribute("EmitCount"))
					end
				end
			end)
		end
	elseif not (v and v.Success) then
		print("Failed to pick up")
		instance.Parent = parent
		self:UpdateCapacityUI((self.ItemsFolder:GetChildren()))
	end
end

function ItemBag:DropAllItems()
	if not self.ItemsFolder then
		return
	end

	local children = self.ItemsFolder:GetChildren()

	if #children <= 0 then
		return
	end

	task.spawn(function()
		local count = 0

		while children and #children > 0 do
			self:DropItem()
			count += 1

			if #children == 0 or count == 50 then
				break
			end
		end
	end)
end

function ItemBag:DropItem()
	if not self.Equipped then
		return
	end

	local children = self.ItemsFolder:GetChildren()

	if #children > 0 then
		local v = children[#children]
		local v2 = localPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(1, 0, -3)

		if v:HasTag("NPC") or v:GetAttribute("PlayerBody") then
			v.Parent = game.ReplicatedStorage.TempStorage
		else
			v:SetAttribute("LastOwner", localPlayer.UserId)
			v:SetAttribute("LastDropTime", time())
			v:PivotTo(v2)
			v.Parent = workspace.Items
		end

		if v:GetAttribute("RagdollBody") or v:GetAttribute("PlayerBody") then
			for _, part in pairs(v:GetChildren()) do
				if not part:IsA("BasePart") then
					continue
				end

				if part.Name ~= "HumanoidRootPart" then
					part.CanCollide = true
					part.Massless = true
				end

				part.AssemblyLinearVelocity = Vector3.new()
			end
		end

		Client.Events.RequestBagDropItem:FireServer(self.RealModel, v, #children <= 1)
		local v3 = self.EasterBasket and "EasterBasketDrop" or "BagDrop"
		Client.Sound.Play(v3, {
			Volume = 0.8,
			Replicate = true,
			Duplicate = true,
			ReplicationProperties = {
				Instance = localPlayer.Character.Head,
				Volume = 0.25
			}
		})
		self:UpdateCapacityUI(self.ItemsFolder:GetChildren())
	end
end

local v = nil
local count = 0

function HoldBar(p, duration, value)
	local dropBar = Client.Interface.DropBar
	dropBar.Visible = true
	local fill = dropBar:FindFirstChild("Fill")
	dropBar.TextLabel.Text = value or "dropping..."

	if v then
		v:Cancel()
	end

	fill.Size = UDim2.new(0, 0, 0.9, 0)
	v = TweenService:Create(fill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Size = UDim2.new(0.95, 0, 0.8, 0)
	})
	v:Play()
	task.spawn(function()
		wait(duration)

		if p == count then
			dropBar.Visible = false
			fill.Size = UDim2.new(0, 0, 0.9, 0)
		end
	end)
end

function ItemBag:OnEquip()
	self.Equipped = true
	self:UpdateCapacityUI((self.ItemsFolder:GetChildren()))
	local lastTime = nil
	ContextActionService:BindActionAtPriority("AddToItemBag", function(_, p, _)
		if not Client.PlayerHandler.Alive then
			return Enum.ContextActionResult.Pass
		end

		if p == Enum.UserInputState.Begin then
			local focusItem = Client.InteractionHandler.GetFocusItem()
			local interaction = focusItem and focusItem:GetAttribute("Interaction")

			if interaction == "Tool" or interaction == "Armour" then
				return
			end

			if focusItem then
				self:BagItem(focusItem)
			else
				lastTime = tick()
				local v2 = lastTime
				task.delay(0.75, function()
					if lastTime == v2 then
						count += 1
						local v3 = count

						if Client.InventoryHandler.ToolEquipped() then
							HoldBar(v3, 0.75, "dropping all...")
						end
					end
				end)
				task.delay(1.5, function()
					if lastTime == v2 then
						print("Long pressed - drop all")
						self:DropAllItems()
						lastTime = nil
					end
				end)
			end

			return Enum.ContextActionResult.Sink
		elseif p == Enum.UserInputState.End then
			if not lastTime then
				return Enum.ContextActionResult.Sink
			end

			local v2 = tick() - lastTime >= 1.5
			lastTime = nil

			if not v2 then
				Client.Interface.DropBar.Visible = false
				count += 1
				self:DropItem()
			end

			return Enum.ContextActionResult.Sink
		elseif p == Enum.UserInputState.Cancel and lastTime then
			lastTime = nil
			Client.Interface.DropBar.Visible = false
			count += 1
		end
	end, false, Enum.ContextActionPriority.High.Value, Enum.KeyCode.F, Enum.KeyCode.ButtonY)
	self.StoreEvent = Client.Events.RequestStoreItem:Connect(function()
		local flowerHover = Client.InteractionHandler.GetFocusItem()

		if not flowerHover and Client.InteractionHandler.FlowerHover then
			flowerHover = Client.InteractionHandler.FlowerHover
		end

		if flowerHover then
			self:BagItem(flowerHover)
		end
	end)
	self.UnstoreEvent = Client.Events.RequestUnstoreItem:Connect(function()
		self:DropItem()
	end)
	self.UnstoreAllEvent = Client.Events.RequestUnstoreAll:Connect(function()
		self:DropAllItems()
	end)
	self.ItemRemovedEvent = self.ItemsFolder.ChildRemoved:Connect(function()
		self:UpdateCapacityUI(self.ItemsFolder:GetChildren())
	end)
	ContextActionService:BindActionAtPriority("ItemBagDrop", function(_, p, _)
		if not self.Equipped or p ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		self:DropItem()
		return Enum.ContextActionResult.Sink
	end, false, Enum.ContextActionPriority.Medium.Value, Enum.KeyCode.ButtonB)
	self.FirstPersonEvent = Client.Events.FirstPersonToggled:Connect(function()
		self:FirstPersonToggled()
	end)
end

function ItemBag:OnUnequip()
	self.Equipped = false
	ContextActionService:UnbindAction("AddToItemBag")
	task.spawn(function()
		self:UpdateCapacityUI(nil, true)
	end)

	if self.FirstPersonEvent then
		self.FirstPersonEvent:Disconnect()
	end

	if self.StoreEvent then
		self.StoreEvent:Disconnect()
	end

	if self.UnstoreEvent then
		self.UnstoreEvent:Disconnect()
	end

	if self.UnstoreAllEvent then
		self.UnstoreAllEvent:Disconnect()
	end

	if self.ItemRemovedEvent then
		self.ItemRemovedEvent:Disconnect()
	end

	ContextActionService:UnbindAction("ItemBagDrop")
end

return ItemBag