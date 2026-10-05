local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemService = require(ReplicatedStorage:WaitForChild("ClientServices"):WaitForChild("ItemService"))
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local ItemPopupService = require(ReplicatedStorage2:WaitForChild("ClientServices"):WaitForChild("ItemPopupService"))
local ReplicatedStorage3 = game:GetService("ReplicatedStorage")
local inventory = ReplicatedStorage3:WaitForChild("Remotes"):WaitForChild("Inventory")
local ReplicatedStorage4 = game:GetService("ReplicatedStorage")
local shop = ReplicatedStorage4:WaitForChild("Remotes"):WaitForChild("Shop")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage5 = game:GetService("ReplicatedStorage")
local itemGift = ReplicatedStorage5:WaitForChild("ItemGift")
local parent = script.Parent
local medium = parent:WaitForChild("Medium")
local claim = medium:WaitForChild("Container"):WaitForChild("Claim")
local newItem = medium:WaitForChild("Container"):WaitForChild("NewItem")
local Lighting = game:GetService("Lighting")
local newItemBlur = Lighting:WaitForChild("NewItemBlur")
local v = {}
local v2 = 1
local count = 0
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function playInventoryAnimation(ID: string, type: string, _)
	local icon = newItem:WaitForChild("Container"):WaitForChild("Icon")
	local animationTargetLocation = ItemPopupService.AnimationTargetLocation
	local clone = script:WaitForChild("ItemIcon"):Clone()
	clone.Image = ItemService:GetDisplayInfo(ID, type).Image
	local uDim = UDim2.fromOffset(icon.AbsoluteSize.X, icon.AbsoluteSize.Y)
	local uDim2 = UDim2.fromOffset(icon.AbsolutePosition.X, icon.AbsolutePosition.Y)
	local uDim3 = UDim2.fromOffset(25, 25)
	local uDim4

	if animationTargetLocation then
		uDim4 = UDim2.fromOffset(animationTargetLocation.AbsolutePosition.X, animationTargetLocation.AbsolutePosition.Y)
	else
		uDim4 = UDim2.new(0.5, 0, 1, 25)
	end

	clone.Size = uDim
	clone.Position = uDim2
	clone.Parent = parent:WaitForChild("Animation")
	TweenService:Create(clone, tweenInfo, {
		Position = uDim4 + UDim2.fromOffset(12, 8),
		Size = uDim3
	}):Play()
	game.Debris:AddItem(clone, 0.5)
end

local function showNewItem()
	local v3 = v[1]
	local ID = v3.ID
	local type = v3.Type
	local amount = v3.Amount or 1
	local displayInfo = ItemService:GetDisplayInfo(ID, type)
	local icon = newItem:WaitForChild("Container"):WaitForChild("Icon")
	icon.Image = displayInfo.Image
	local label = newItem:WaitForChild("ItemName"):WaitForChild("Label")
	label.Text = displayInfo.Name
	local itemName = newItem:WaitForChild("ItemName")
	itemName.BackgroundColor3 = displayInfo.Color
	local chroma = newItem:WaitForChild("Tags"):WaitForChild("Chroma")
	chroma.Visible = displayInfo.Chroma
	local starburst = medium:WaitForChild("Container"):WaitForChild("Starburst")
	starburst.ImageColor3 = displayInfo.Color
	newItem.Container.Amount.Text = amount > 1 and `x{amount}` or ""

	if count > 1 then
		local claim_2 = medium:WaitForChild("Container"):WaitForChild("Claim")
		claim_2.Text = `Claim ({v2}/{count})`
	else
		local claim_3 = medium:WaitForChild("Container"):WaitForChild("Claim")
		claim_3.Text = "Claim"
	end

	newItemBlur.Enabled = true
	medium.Visible = true
	local visible = UserInputService.PreferredInput == Enum.PreferredInput.Gamepad

	if visible then
		GuiService.SelectedObject = claim
	end

	claim.ImageLabel.Visible = visible
end

local function onNewItem(ID: string, p2: string, amount: number?)
	table.insert(v, {
		ID = ID,
		Type = p2,
		Amount = amount
	})
	count += 1
	showNewItem()
end

local function onItemClaimed()
	playInventoryAnimation(v[1].ID, v[1].Type)
	table.remove(v, 1)

	if v[1] == nil then
		GuiService.SelectedObject = nil
		medium.Visible = false
		shop:WaitForChild("NewItemsClaimed"):Fire()
		count = 0
		v2 = 1
		newItemBlur.Enabled = false
		ItemPopupService.ItemClaimsComplete:Fire()
	else
		v2 += 1
		showNewItem()
	end
end

local function onInitialize()
	medium.Visible = false
	medium:WaitForChild("Container"):WaitForChild("Claim").Activated:Connect(onItemClaimed)
	ItemPopupService.ItemReceived.Event:Connect(onNewItem)
	shop.NewItemReceived.Event:Connect(onNewItem)
	inventory.ItemReceived.OnClientEvent:Connect(onNewItem)
	itemGift.OnClientEvent:Connect(onNewItem)

	if GuiService:IsTenFootInterface() then
		local uIScale = medium:WaitForChild("Container"):WaitForChild("UIScale")
		uIScale.Scale = 1.5
	end
end

onInitialize()