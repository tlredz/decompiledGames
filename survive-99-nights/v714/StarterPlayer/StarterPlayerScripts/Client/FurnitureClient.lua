local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local ContentProvider = game:GetService("ContentProvider")
local FurnitureClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local viewportThumbnail = Client.ViewportThumbnail
local furnitureTrader = ReplicatedStorage.Shops["Furniture Trader"]
local basics = furnitureTrader.Basics
local rares = furnitureTrader.Rares
local furniture = nil
local mainUI = nil
local itemsContent = nil
local template = nil
local navigator = nil
local shopButton = nil
local inventoryButton = nil
local preview = nil
local info = nil
local textLabel = nil
local furniture2 = nil
local color = Color3.fromRGB(255, 255, 255)
local color2 = Color3.fromRGB(255, 255, 255)
local color3 = Color3.fromRGB(255, 255, 255)
local color4 = Color3.fromRGB(131, 131, 131)
local color5 = Color3.fromRGB(255, 0, 0)
local v = {
	Common = {
		Primary = Color3.fromRGB(185, 185, 185),
		Secondary = Color3.fromRGB(255, 255, 255),
		TextColour = Color3.fromRGB(255, 255, 255)
	},
	Rare = {
		Primary = Color3.fromRGB(0, 136, 255),
		Secondary = Color3.fromRGB(255, 255, 255),
		TextColour = Color3.fromRGB(0, 234, 255)
	},
	Legendary = {
		Primary = Color3.fromRGB(255, 191, 0),
		Secondary = Color3.fromRGB(255, 42, 0),
		TextColour = Color3.fromRGB(255, 170, 0)
	},
	Mythic = {
		Primary = Color3.fromRGB(81, 0, 181),
		Secondary = Color3.fromRGB(212, 0, 255),
		TextColour = Color3.fromRGB(238, 0, 255)
	}
}
local v2 = {
	Common = {
		Background = Color3.fromRGB(14, 14, 14)
	},
	Rare = {
		Background = Color3.fromRGB(6, 38, 67)
	},
	Legendary = {
		Background = Color3.fromRGB(46, 39, 13)
	},
	Mythic = {
		Background = Color3.fromRGB(33, 10, 61)
	}
}
local v3 = {
	Mythic = 1,
	Legendary = 2,
	Rare = 3,
	Common = 4
}
local v4 = "Shop"
local v5 = {}
local count = 0
local v6 = {}
local v7 = {}
local v8 = nil
local activatedConnection = nil
local v9 = nil
local count2 = 0
local unit = (createVector(-0.35, 0.2, -1)).Unit
local v10 = {}

local function GetPrice(instance)
	local price = instance:GetAttribute("Price")

	if not price then
		return nil
	end

	if localPlayer:GetAttribute("DecoratorGamePass") then
		price = math.ceil(price * 0.75)
	end

	return price
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetCoins()
	return Client.FlowerAndCoinsClient.CoinAmount or 0
end

-- equivalent calls inferred from this helper; original call sites unknown
local function CanAfford(p)
	if v4 == "Inventory" then
		return p <= GetCoins() or p <= (localPlayer:GetAttribute("Coins") or 0)
	end

	return p <= GetCoins()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetRarityColours(rarity)
	return v[rarity] or v.Common
end

local function GetRarityStyle(p)
	return v2[p] or v2.Common
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetGlowColour(rarity)
	if v[rarity] then
		return v[rarity].Primary
	end

	return Color3.fromRGB(255, 255, 255)
end

local function Brighten(p)
	return p:Lerp(Color3.fromRGB(255, 255, 255), 0.2)
end

local function GetDescription(instance)
	local eventName = instance:GetAttribute("EventName")
	local v11 = GetPetPortrait(instance)

	if v11 then
		return "A portrait of " .. (v11:GetAttribute("PetName") or "your pet")
	end

	if eventName then
		return "Obtained during " .. eventName
	end

	return "A " .. (instance:GetAttribute("Rarity") or "Common") .. " piece of furniture for your base"
end

local function GetNameDisplay(p, p2)
	if p2 and p2 > 1 then
		return p .. " (" .. p2 .. ")"
	end

	return p
end

function GetPetPortrait(instance)
	local petPortraitId = instance:GetAttribute("PetPortraitId")
	return petPortraitId and ReplicatedStorage.Assets.PetPortraits:FindFirstChild(petPortraitId)
end

function IsForLocalPlayer(instance)
	local ownerId = instance:GetAttribute("OwnerId")
	return ownerId == nil or ownerId == localPlayer.UserId
end

function ShowPetPortrait(parent, instance)
	local worldModel = Instance.new("WorldModel")
	local clone = instance:Clone()
	clone.Parent = worldModel
	worldModel.Parent = parent
	local camera = Instance.new("Camera")
	camera.FieldOfView = 30
	camera.Parent = parent
	parent.CurrentCamera = camera
	task.defer(function()
		local animator = clone:FindFirstChildWhichIsA("Animator", true)
		local animations = clone:FindFirstChild("Animations")
		local sit = animations and (animations:FindFirstChild("Sit") or animations:FindFirstChild("Idle"))

		if animator and sit then
			ContentProvider:PreloadAsync({ sit })

			if not parent:IsDescendantOf(game) then
				return
			end

			animator:LoadAnimation(sit):Play(0, 1, 0)
			RunService.Heartbeat:Wait()
		end

		local pivot = clone:GetPivot()
		local v11 = createVector(1, 1, 1) * 1e999
		local v12 = -v11

		for _, part in pairs(clone:GetDescendants()) do
			if not (part:IsA("BasePart") and part.Transparency < 1) then
				continue
			end

			local pointToObjectSpace = pivot:PointToObjectSpace(part.Position)
			local v13 = createVector(1, 1, 1) * part.Size.Magnitude / 2
			v11 = v11:Min(pointToObjectSpace - v13)
			v12 = v12:Max(pointToObjectSpace + v13)
		end

		local v13 = v12 - v11
		local v14 = pivot * ((v11 + v12) / 2)
		local v15 = parent.AbsoluteSize.Y > 0 and parent.AbsoluteSize.X / parent.AbsoluteSize.Y or 1
		local v16 = math.max(v13.Y, v13.X / v15) / 2 / math.tan((math.rad(camera.FieldOfView / 2))) + v13.Z / 2
		camera.CFrame = CFrame.lookAt(v14 + pivot:VectorToWorldSpace(unit) * v16, v14)
	end)
end

function PetPortraitAdded(instance)
	local v11 = GetPetPortrait(instance:FindFirstAncestorWhichIsA("Model"))

	if not v11 then
		return
	end

	local parent = instance.Parent
	local clone = parent:Clone()
	clone.PetView:RemoveTag("PetPortrait")
	clone.Adornee = parent.Parent
	clone.ResetOnSpawn = false
	clone.Parent = localPlayer.PlayerGui
	parent.Enabled = false
	v10[instance] = clone
	ShowPetPortrait(clone.PetView, v11)
end

function PetPortraitRemoved(p)
	if v10[p] then
		v10[p]:Destroy()
		v10[p] = nil
	end
end

local function AddViewport(icon, itemName, p)
	local child = ReplicatedStorage.Assets.FurnitureThumbnail:FindFirstChild(itemName)
	local v11 = viewportThumbnail.AddToButton(icon, child, {
		Size = UDim2.fromScale(1, 1),
		Position = UDim2.fromScale(0, 0)
	})

	if p then
		ShowPetPortrait(v11, p)
	end

	return v11
end

local count3 = 0

local function UpdatePreviewViewport(itemName, p)
	count3 += 1
	local v11 = count3
	local child = ReplicatedStorage.Assets.FurnitureThumbnail:FindFirstChild(itemName)

	if not (child or p) then
		return
	end

	local viewportFrame = Instance.new("ViewportFrame")
	viewportFrame.Name = "PreviewViewport"
	viewportFrame.BackgroundTransparency = 1
	viewportFrame.BorderSizePixel = 0
	viewportFrame.Ambient = Color3.fromRGB(200, 200, 200)
	viewportFrame.LightColor = Color3.fromRGB(255, 255, 255)
	viewportFrame.Size = UDim2.fromScale(1, 1)
	viewportFrame.Position = UDim2.fromScale(0, 0)
	viewportThumbnail.PopulateViewport(viewportFrame, child, {})

	if p then
		ShowPetPortrait(viewportFrame, p)
	end

	viewportFrame.Parent = preview.ImageLabel
	task.spawn(function()
		RunService.Heartbeat:Wait()
		RunService.Heartbeat:Wait()

		if v11 ~= count3 then
			return
		end

		for _, child2 in ipairs(preview.ImageLabel:GetChildren()) do
			if child2 ~= viewportFrame and child2.Name == "PreviewViewport" then
				child2:Destroy()
			end
		end
	end)
end

local function GetFolderFor(childName)
	if v4 == "Inventory" then
		return furniture2:FindFirstChild(childName)
	end

	return basics:FindFirstChild(childName) or rares:FindFirstChild(childName)
end

function CloseMenu()
	GuiService.TouchControlsEnabled = true
	furniture.Visible = false
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
	Client.Sound.Play("CloseButton")
end

Client.Events.HideFurnitureStore:Connect(function()
	CloseMenu()
end)

function UpdatePriceColours()
	for _, v11 in pairs(v5) do
		local textLabel2 = v11.CurrencyCounter.TextLabel
		local text = tonumber(textLabel2.Text) or 0

		-- equivalent call inferred; original call site unknown
		if CanAfford(text) then
			textLabel2.TextColor3 = (v[v11:GetAttribute("Rarity")] or v.Common).TextColour
		else
			textLabel2.TextColor3 = Color3.fromRGB(255, 0, 0)
		end
	end
end

function FurnitureClient.UpdateCoinAmount()
	if not furniture then
		return
	end

	textLabel.Text = tostring(GetCoins())
	UpdatePriceColours()
end

function FlashRedText()
	if not furniture then
		return
	end

	task.spawn(function()
		count2 += 1
		local v11 = count2

		for _ = 1, 3 do
			if count2 ~= v11 then
				break
			end

			textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
			wait(0.15)

			if count2 ~= v11 then
				break
			end

			textLabel.TextColor3 = color
			wait(0.15)
		end
	end)
end

local function AttemptBuy(instance)
	local itemName = instance:GetAttribute("ItemName")
	local price = instance:GetAttribute("Price")

	if price then
		if localPlayer:GetAttribute("DecoratorGamePass") then
			price = math.ceil(price * 0.75)
		end
	else
		price = nil
	end

	local rarity = instance:GetAttribute("Rarity")
	local stock = instance:GetAttribute("Stock")

	if not (itemName and price and rarity) or stock ~= nil and stock <= 0 then
		return
	end

	-- equivalent call inferred; original call site unknown
	if CanAfford(price) then
		Client.FlowerAndCoinsClient.CoinAmount -= price

		if v4 == "Inventory" then
			Client.Events.RequestBuyOwnedFurniture:FireServer(itemName)
		else
			Client.Events.RequestBuyFurniture:FireServer(itemName)
		end

		if stock then
			instance:SetAttribute("Stock", stock - 1)
		end

		Client.Sound.Play("BuyItem", {
			Volume = 0.4,
			Duplicate = true
		})
		Client.PopUpUI.AddPopUp(itemName .. " purchased!")
	else
		Client.PopUpUI.AddPopUp("not enough coins", "warning")
		FlashRedText()
	end
end

function ClearPreview()
	v8 = nil

	if activatedConnection then
		activatedConnection:Disconnect()
		activatedConnection = nil
	end

	count3 += 1

	for _, child in ipairs(preview.ImageLabel:GetChildren()) do
		if child.Name == "PreviewViewport" then
			child:Destroy()
		end
	end

	preview.Visible = false
end

function ShowPreview(p, instance)
	if not instance then
		ClearPreview()
		return
	end

	local itemName = instance:GetAttribute("ItemName")
	local rarity = instance:GetAttribute("Rarity")
	local stock = instance:GetAttribute("Stock")
	local price = instance:GetAttribute("Price")

	if price then
		if localPlayer:GetAttribute("DecoratorGamePass") then
			price = math.ceil(price * 0.75)
		end
	else
		price = nil
	end

	if not (itemName and price and rarity) then
		ClearPreview()
		return
	end

	v8 = instance

	if v9 and v9 ~= p and v9.Parent then
		v9.BackgroundColor3 = (v2[v9:GetAttribute("Rarity")] or v2.Common).Background
	end

	if p then
		p.BackgroundColor3 = (v2[rarity] or v2.Common).Background:Lerp(Color3.fromRGB(255, 255, 255), 0.2)
	end

	v9 = p
	preview.Visible = true
	UpdatePreviewViewport(itemName, GetPetPortrait(instance))
	local rarityColours = GetRarityColours(rarity) -- equivalent call inferred; original call site unknown
	local imageColor = GetGlowColour(rarity) -- equivalent call inferred; original call site unknown
	local itemName2 = info.ItemName

	if stock and stock > 1 then
		itemName ..= " (" .. stock .. ")"
	end

	itemName2.Text = itemName
	info.Rarity.Text = rarity
	info.Rarity.TextColor3 = rarityColours.TextColour
	info.Description.Text = GetDescription(instance)
	mainUI.ColorGlow.ImageColor3 = imageColor
	info.ColorGlow.ImageColor3 = imageColor
	preview.Glow.ImageColor3 = imageColor
	preview.Glow.ImageLabel.ImageColor3 = imageColor
	local purchaseButton_Lower = info.PurchaseButton_Lower
	local disabledButton_Lower = info.DisabledButton_Lower
	purchaseButton_Lower.ImageButton.TextLabel.Text = "$" .. price
	local v13 = stock and stock <= 0
	local v14 = not v13

	if v14 then
		if v4 == "Inventory" then
			v14 = price <= GetCoins() or price <= (localPlayer:GetAttribute("Coins") or 0)
		else
			v14 = price <= GetCoins()
		end
	end

	if activatedConnection then
		activatedConnection:Disconnect()
		activatedConnection = nil
	end

	if v14 then
		purchaseButton_Lower.Visible = true
		disabledButton_Lower.Visible = false
		activatedConnection = purchaseButton_Lower.ImageButton.Activated:Connect(function()
			if v8 then
				AttemptBuy(v8)
			end
		end)
	else
		purchaseButton_Lower.Visible = false
		disabledButton_Lower.Visible = true
		disabledButton_Lower.Active = true

		if v13 then
			disabledButton_Lower.Upper.TextLabel.Text = "Sold Out"
		else
			disabledButton_Lower.Upper.TextLabel.Text = "$" .. price
		end

		activatedConnection = disabledButton_Lower.InputBegan:Connect(function(input)
			if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and v8 then
				AttemptBuy(v8)
			end
		end)
	end
end

local function CreateOrUpdateButton(instance)
	local name = instance.Name
	local itemName = instance:GetAttribute("ItemName")
	local price = instance:GetAttribute("Price")

	if price then
		if localPlayer:GetAttribute("DecoratorGamePass") then
			price = math.ceil(price * 0.75)
		end
	else
		price = nil
	end

	local rarity = instance:GetAttribute("Rarity")
	local stock = instance:GetAttribute("Stock")

	if not (itemName and price and rarity) then
		return
	end

	local clone = v5[name]

	if not clone then
		clone = template:Clone()
		v5[name] = clone
		clone:SetAttribute("CreateOrder", count)
		count += 1
		v6[name] = v6[name] or {}
		v6[name].click = clone.Activated:Connect(function()
			Client.Sound.Play("KeyPress", {
				Duplicate = true
			})
			ShowPreview(clone, instance)
		end)
		clone.Name = name
		clone.Parent = itemsContent
	end

	clone:SetAttribute("Rarity", rarity)
	clone.ItemName.Text = itemName
	clone.CurrencyCounter.TextLabel.Text = tostring(price)

	if stock and stock <= 0 then
		clone.StockCounter.TextLabel.Text = "x0"
		clone.StockCounter.TextLabel.TextColor3 = color5
		clone.StockCounter.Visible = true
	elseif stock and stock > 1 then
		clone.StockCounter.TextLabel.Text = "x" .. stock
		clone.StockCounter.TextLabel.TextColor3 = color2
		clone.StockCounter.Visible = true
	else
		clone.StockCounter.Visible = false
	end

	if clone ~= v9 then
		clone.BackgroundColor3 = (v2[rarity] or v2.Common).Background
	end

	clone.UIStroke.Color = (v2[rarity] or v2.Common).Stroke
	clone.BackgroundTransparency = stock and stock <= 0 and 0.5 or 0

	if clone:GetAttribute("ViewportItem") ~= itemName then
		clone:SetAttribute("ViewportItem", itemName)
		AddViewport(clone.ItemIconFrame.Icon, itemName, GetPetPortrait(instance))
	end

	clone.LayoutOrder = (v3[rarity] or 4) * 1000 + (clone:GetAttribute("CreateOrder") or 0)
	clone.Visible = true
end

local function RemoveButton(p)
	local v11 = v5[p]

	if v11 then
		if v9 == v11 then
			v9 = nil
		end

		v11:Destroy()
		v5[p] = nil
	end

	if v6[p] then
		for _, connection in pairs(v6[p]) do
			if connection then
				connection:Disconnect()
			end
		end

		v6[p] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ClearButtons()
	v9 = nil
	count = 0

	for k, _ in pairs(v5) do
		RemoveButton(k)
	end
end

local function ClearDataConnections()
	for _, connection in pairs(v7) do
		if connection then
			connection:Disconnect()
		end
	end

	v7 = {}
end

local function SetupFolderListener(folder)
	local name = folder.Name
	v6[name] = v6[name] or {}
	v6[name].attributeChanged = folder.AttributeChanged:Connect(function(p)
		if p == "ItemName" or p == "Price" or p == "Rarity" or p == "Stock" or p == "EventName" then
			if p == "ItemName" and not folder:GetAttribute("ItemName") then
				RemoveButton(name)
			else
				CreateOrUpdateButton(folder)
			end

			if v8 == folder then
				ShowPreview(v5[name], folder)
			end
		end
	end)
end

local function FocusFirst()
	local v11 = nil
	local v12 = nil

	for k, v13 in pairs(v5) do
		if not (v11 == nil or v13.LayoutOrder < v11.LayoutOrder) then
			continue
		end

		v12 = k
		v11 = v13
	end

	if v11 then
		ShowPreview(v11, GetFolderFor(v12))
	else
		ClearPreview()
	end
end

local function BuildShop()
	for _, folder in pairs(basics:GetChildren()) do
		if not folder:IsA("Folder") then
			continue
		end

		CreateOrUpdateButton(folder)
		SetupFolderListener(folder)
	end

	for _, folder in pairs(rares:GetChildren()) do
		if not (folder:IsA("Folder") and IsForLocalPlayer(folder)) then
			continue
		end

		CreateOrUpdateButton(folder)
		SetupFolderListener(folder)
	end

	v7.basicsAdded = basics.ChildAdded:Connect(function(folder)
		if folder:IsA("Folder") then
			CreateOrUpdateButton(folder)
			SetupFolderListener(folder)
		end
	end)
	v7.basicsRemoved = basics.ChildRemoved:Connect(function(folder)
		if folder:IsA("Folder") then
			RemoveButton(folder.Name)
		end
	end)
	v7.raresAdded = rares.ChildAdded:Connect(function(folder)
		if folder:IsA("Folder") and IsForLocalPlayer(folder) then
			CreateOrUpdateButton(folder)
			SetupFolderListener(folder)
		end
	end)
	v7.raresRemoved = rares.ChildRemoved:Connect(function(folder)
		if folder:IsA("Folder") then
			RemoveButton(folder.Name)
		end
	end)
end

local function BuildInventory()
	for _, folder in pairs(furniture2:GetChildren()) do
		if not folder:IsA("Folder") then
			continue
		end

		CreateOrUpdateButton(folder)
		SetupFolderListener(folder)
	end

	v7.inventoryAdded = furniture2.ChildAdded:Connect(function(folder)
		if folder:IsA("Folder") then
			CreateOrUpdateButton(folder)
			SetupFolderListener(folder)
		end
	end)
	v7.inventoryRemoved = furniture2.ChildRemoved:Connect(function(folder)
		if folder:IsA("Folder") then
			RemoveButton(folder.Name)
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function StyleTab(instance, p)
	local v11 = p and color3 or color4
	instance.TextLabel.TextColor3 = v11
	local imageLabel = instance:FindFirstChild("ImageLabel")

	if imageLabel then
		imageLabel.ImageColor3 = v11
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateTabVisuals()
	StyleTab(shopButton, v4 == "Shop") -- equivalent call inferred; original call site unknown
	StyleTab(inventoryButton, v4 == "Inventory") -- equivalent call inferred; original call site unknown
end

function SwitchTab(p)
	v4 = p
	ClearDataConnections()
	ClearButtons() -- equivalent call inferred; original call site unknown
	ClearPreview()
	UpdateTabVisuals() -- equivalent call inferred; original call site unknown

	if v4 == "Inventory" then
		BuildInventory()
	else
		BuildShop()
	end

	FurnitureClient.UpdateCoinAmount()
	FocusFirst()
end

Client.Events.InitizalizeFurniture:Connect(function()
	if v4 == "Inventory" then
		SwitchTab("Inventory")
	end
end)
Client.Events.NewRotationFurniture:Connect(function()
	ClearPreview()

	if v4 == "Shop" then
		SwitchTab("Shop")
	end
end)

function FurnitureClient.Init()
	Client.Utility.ForAllTagged("PetPortrait", PetPortraitAdded, PetPortraitRemoved)
	task.spawn(function()
		furniture = Client.Interface.Furniture
		mainUI = furniture:WaitForChild("MainUI")
		itemsContent = mainUI:WaitForChild("ItemsContent")
		template = itemsContent:WaitForChild("Template")
		navigator = mainUI:WaitForChild("Navigator")
		shopButton = navigator:WaitForChild("ShopButton")
		inventoryButton = navigator:WaitForChild("InventoryButton")
		preview = furniture:WaitForChild("Preview")
		info = preview:WaitForChild("Info")
		textLabel = mainUI:WaitForChild("CurrencyCounter"):WaitForChild("Coins"):WaitForChild("TextLabel")
		color = textLabel.TextColor3
		color2 = template.StockCounter.TextLabel.TextColor3
		furniture2 = localPlayer:WaitForChild("RewardsInventory"):WaitForChild("Furniture")
		itemsContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
		itemsContent.CanvasSize = UDim2.new()
		itemsContent.UIGridLayout.CellSize = UDim2.fromScale(0.3, 0.25)
		template.Parent = nil
		local templateRare = itemsContent:WaitForChild("TemplateRare")
		local templateLegendary = itemsContent:WaitForChild("TemplateLegendary")
		v2.Common.Stroke = template.UIStroke.Color
		v2.Rare.Stroke = templateRare.UIStroke.Color
		v2.Legendary.Stroke = templateLegendary.UIStroke.Color
		v2.Mythic.Stroke = v.Mythic.Primary
		shopButton.MouseButton1Down:Connect(function()
			Client.Sound.Play("KeyPress", {
				Duplicate = true
			})

			if v4 ~= "Shop" then
				SwitchTab("Shop")
			end
		end)
		inventoryButton.MouseButton1Down:Connect(function()
			Client.Sound.Play("KeyPress", {
				Duplicate = true
			})

			if v4 ~= "Inventory" then
				SwitchTab("Inventory")
			end
		end)
		mainUI.CloseButton.MouseButton1Down:Connect(function()
			CloseMenu()
		end)
		localPlayer:GetAttributeChangedSignal("Coins"):Connect(function()
			FurnitureClient.UpdateCoinAmount()
		end)
		SwitchTab("Shop")
	end)
end

return FurnitureClient