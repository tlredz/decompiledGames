local SupplyCrateClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local viewportThumbnail = Client.ViewportThumbnail
local v = {}
local v2 = "Upgrade Flames"
local supplyCrate = Client.Interface.SupplyCrate
local v3 = nil
local v4 = {}
local layoutOrder = 2
local layoutOrder2 = 100
local v7 = nil
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local GamepadService = game:GetService("GamepadService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local v8 = {
	["Upgrade Flames"] = "Offerings are one time use. Place on campfire for a bonus",
	Toys = "Place plushies on shelf for small bonuses",
	Tools = "Tools from gamepasses",
	["Pet Skins"] = "Equips a random pet skin when you tame a pet",
	Furniture = "Furniture to place around your base"
}
local v9 = {}
local color = Color3.fromRGB(161, 0, 0)
local v10 = {
	Common = Color3.fromRGB(255, 255, 255),
	Rare = Color3.fromRGB(0, 234, 255),
	Legendary = Color3.fromRGB(255, 170, 0),
	Mythic = Color3.fromRGB(238, 0, 255)
}
ContextActionService:BindActionAtPriority("CloseSupplyChest", function(_, p, _)
	if not supplyCrate.Visible or p ~= Enum.UserInputState.Begin then
		return Enum.ContextActionResult.Pass
	end

	supplyCrate.Visible = false
	GamepadService:DisableGamepadCursor()
	Client.Sound.Play("CloseButton")
	return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.High.Value + 1, Enum.KeyCode.ButtonB)

function ApplyIconViewport(parent, p)
	if not parent then
		return false
	end

	local function build()
		if not parent.Parent then
			return false
		end

		local supplyViewport = parent:FindFirstChild("SupplyViewport")

		if supplyViewport then
			supplyViewport:Destroy()
		end

		local parent2 = viewportThumbnail.CreateFromName(p)

		if not parent2 then
			return false
		end

		parent2.Name = "SupplyViewport"
		local imageLabel = parent:FindFirstChild("ImageLabel")

		if imageLabel then
			parent2.Size = imageLabel.Size
			parent2.Position = imageLabel.Position
			parent2.AnchorPoint = imageLabel.AnchorPoint
			local uIAspectRatioConstraint = imageLabel:FindFirstChildOfClass("UIAspectRatioConstraint")

			if uIAspectRatioConstraint then
				local clone = uIAspectRatioConstraint:Clone()
				clone.Parent = parent2
			end

			imageLabel.Visible = false
		else
			parent2.Size = UDim2.fromScale(1, 1)
		end

		parent2.Parent = parent
		return true
	end

	if build() then
		return true
	end

	local furnitureThumbnail = game.ReplicatedStorage.Assets:FindFirstChild("FurnitureThumbnail")

	if furnitureThumbnail then
		local childAddedConnection = nil
		childAddedConnection = furnitureThumbnail.ChildAdded:Connect(function(child)
			if child.Name == p then
				childAddedConnection:Disconnect()
				build()
			end
		end)
	end

	return false
end

function ApplyPetSkinViewport(parent, childName)
	if not parent then
		return false
	end

	local function build()
		if not parent.Parent then
			return false
		end

		local petSkinThumbnail = game.ReplicatedStorage.Assets:FindFirstChild("PetSkinThumbnail")
		local viewportFrame = petSkinThumbnail and petSkinThumbnail:FindFirstChild(childName)

		if not (viewportFrame and viewportFrame:IsA("ViewportFrame")) then
			return false
		end

		local supplyViewport = parent:FindFirstChild("SupplyViewport")

		if supplyViewport then
			supplyViewport:Destroy()
		end

		local clone = viewportFrame:Clone()
		clone.Name = "SupplyViewport"
		clone.BackgroundTransparency = 1
		local imageLabel = parent:FindFirstChild("ImageLabel")

		if imageLabel then
			clone.Size = imageLabel.Size
			clone.Position = imageLabel.Position
			clone.AnchorPoint = imageLabel.AnchorPoint
			local uIAspectRatioConstraint = imageLabel:FindFirstChildOfClass("UIAspectRatioConstraint")

			if uIAspectRatioConstraint then
				local clone_2 = uIAspectRatioConstraint:Clone()
				clone_2.Parent = clone
			end

			imageLabel.Visible = false
		else
			clone.Size = UDim2.fromScale(1, 1)
		end

		clone.Parent = parent
		return true
	end

	if build() then
		return true
	end

	local petSkinThumbnail = game.ReplicatedStorage.Assets:FindFirstChild("PetSkinThumbnail")

	if petSkinThumbnail then
		local childAddedConnection = nil
		childAddedConnection = petSkinThumbnail.ChildAdded:Connect(function(child)
			if child.Name == childName then
				childAddedConnection:Disconnect()
				build()
			end
		end)
	end

	return false
end

local v11 = {}

function ScaleGrid(state, p, p2, p3)
	if not v11[state] then
		v11[state] = {
			Cell = state.CellSize,
			Pad = state.CellPadding
		}
	end

	local v12 = v11[state]
	local X = p.AbsoluteSize.X
	local Y = p.AbsoluteSize.Y

	if X < 1 or Y < 1 then
		return
	end

	local v13 = X * p2
	local v14 = Y * p3
	state.CellSize = UDim2.fromOffset(
		v12.Cell.X.Scale * v13 + v12.Cell.X.Offset,
		v12.Cell.Y.Scale * v14 + v12.Cell.Y.Offset
	)
	state.CellPadding = UDim2.fromOffset(
		v12.Pad.X.Scale * v13 + v12.Pad.X.Offset,
		v12.Pad.Y.Scale * v14 + v12.Pad.Y.Offset
	)
end

function SetupAutoScale()
	for _, scrollingFrame in pairs(supplyCrate:GetChildren()) do
		if not scrollingFrame:IsA("ScrollingFrame") then
			continue
		end

		local uIGridLayout = scrollingFrame:FindFirstChildOfClass("UIGridLayout")

		if not uIGridLayout then
			continue
		end

		local v12 = math.max(1, scrollingFrame.CanvasSize.X.Scale)
		local v13 = math.max(1, scrollingFrame.CanvasSize.Y.Scale) * 1.3
		scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scrollingFrame.CanvasSize = UDim2.new()
		-- equivalent calls inferred from this helper; original call sites unknown
		local v14 = uIGridLayout
		local v15 = scrollingFrame

		local function update()
			ScaleGrid(v14, v15, v12, v13)
		end

		scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
		update() -- equivalent call inferred; original call site unknown
	end
end

function RefreshPreview()
	if not (v4 and v4.folder) then
		return
	end

	local folder = v4.folder
	local v12

	if folder.Parent and folder.Parent.Name == "Furniture" then
		v12 = folder:GetAttribute("Stock") or 0
	else
		v12 = (folder:GetAttribute("Quantity") or 0) - (folder:GetAttribute("ServerWithdrawn") or 0)
	end

	SetPreview(folder, v4.image, v4.name, v4.desc, v12)
end

function SetPreview(folder, image, childName, p2, p3)
	local previewFrame = supplyCrate.PreviewFrame

	if folder and image and childName and p2 and p3 then
		previewFrame.Visible = true
		previewFrame.Visible = true
		local name = folder.Parent and folder.Parent.Name
		local useButton = previewFrame.UseButton
		useButton.Visible = name ~= "Pet Skins" and p3 > 0
		previewFrame.AmountOwnedFrame.Visible = name == "Upgrade Flames"
		previewFrame.AmountOwnedFrame.Amount.Text = p3

		if p3 > 0 then
			previewFrame.AmountOwnedFrame.Amount.TextColor3 = Color3.fromRGB(229, 229, 229)
		else
			previewFrame.AmountOwnedFrame.Amount.TextColor3 = Color3.fromRGB(161, 0, 0)
		end

		local function changeButtonVisuals(_)
			local useButton2 = previewFrame.UseButton
			local color2, text

			if name == "Upgrade Flames" then
				color2 = Color3.fromRGB(85, 225, 80)
				text = "Use 1"
			elseif name == "Tools" or name == "Toys" then
				color2 = Color3.fromRGB(85, 147, 71)
				text = "Take"
			else
				color2 = Color3.fromRGB(85, 147, 71)
				text = "Use"
			end

			useButton2.ImageColor3 = color2
			useButton2.TextLabel.Text = text
			useButton2.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			useButton2.UIStroke.Color = color2
		end

		if folder.Parent and folder.Parent.Name == "Upgrade Flames" then
			previewFrame.CountdownWarning.Visible = false
			changeButtonVisuals()
		else
			changeButtonVisuals()
			previewFrame.CountdownWarning.Visible = false
		end

		local useButton2 = previewFrame.UseButton
		local coinAmount = useButton2:FindFirstChild("CoinAmount")

		if name == "Furniture" then
			local price = folder:GetAttribute("Price") or 0

			if localPlayer:GetAttribute("DecoratorGamePass") then
				price = math.ceil(price * 0.75)
			end

			useButton2.ImageColor3 = Color3.fromRGB(255, 200, 0)

			if useButton2:FindFirstChild("UIStroke") then
				useButton2.UIStroke.Color = Color3.fromRGB(255, 200, 0)
			end

			if useButton2:FindFirstChild("TextLabel") then
				useButton2.TextLabel.Visible = false
			end

			if coinAmount then
				coinAmount.Visible = true

				if coinAmount:FindFirstChild("CoinAmount") then
					coinAmount.CoinAmount.Text = tostring(price)
				end
			end
		else
			if useButton2:FindFirstChild("TextLabel") then
				useButton2.TextLabel.Visible = true
			end

			if coinAmount then
				coinAmount.Visible = false
			end
		end

		local previewViewport = previewFrame.PreviewLabel:FindFirstChild("PreviewViewport")

		if previewViewport then
			previewViewport:Destroy()
		end

		local clone = nil

		if name == "Pet Skins" then
			local petSkinThumbnail = game.ReplicatedStorage.Assets:FindFirstChild("PetSkinThumbnail")
			local viewportFrame = petSkinThumbnail and petSkinThumbnail:FindFirstChild(childName)

			if viewportFrame and viewportFrame:IsA("ViewportFrame") then
				clone = viewportFrame:Clone()
				clone.BackgroundTransparency = 1
			end
		elseif image == "rbxassetid://75002580261891" then
			clone = viewportThumbnail.CreateFromName(childName)
		end

		if clone then
			clone.Name = "PreviewViewport"
			clone.Size = UDim2.fromScale(1, 1)
			clone.Position = UDim2.fromScale(0.5, 0.5)
			clone.AnchorPoint = Vector2.new(0.5, 0.5)
			clone.ZIndex = 0
			clone.Parent = previewFrame.PreviewLabel
			previewFrame.PreviewLabel.ImageTransparency = 1
		else
			previewFrame.PreviewLabel.ImageTransparency = 0
			previewFrame.PreviewLabel.Image = image
		end

		if name == "Furniture" then
			local eventName = folder:GetAttribute("EventName")

			if eventName then
				previewFrame.DescriptionLabel.Text = "Obtained during " .. eventName
			else
				previewFrame.DescriptionLabel.Text = "A " .. (folder:GetAttribute("Rarity") or "Common") .. " piece of furniture for your base"
			end

			local textLabel = previewFrame.TextLabel
			local text

			if p3 > 1 then
				text = childName .. " (" .. p3 .. ")" or childName
			else
				text = childName
			end

			textLabel.Text = text
		elseif name == "Toys" then
			previewFrame.DescriptionLabel.Text = p2
			local textLabel = previewFrame.TextLabel
			local text

			if p3 > 1 then
				text = childName .. " (" .. p3 .. ")" or childName
			else
				text = childName
			end

			textLabel.Text = text
		elseif name == "Pet Skins" then
			local eventName = folder:GetAttribute("EventName")

			if eventName then
				previewFrame.DescriptionLabel.Text = "Obtained during " .. eventName
			else
				previewFrame.DescriptionLabel.Text = ""
			end

			previewFrame.TextLabel.Text = childName
		else
			local descriptionLabel = previewFrame.DescriptionLabel
			local text

			if name == "Upgrade Flames" then
				text = Client.SpecialFireClient.GetDescription(childName) or p2
			else
				text = p2
			end

			descriptionLabel.Text = text
			local text2 = string.gsub(childName, "[Ff][Ll][Aa][Mm][Ee]", "Offering")
			previewFrame.TextLabel.Text = text2
		end

		local rarity = folder:GetAttribute("Rarity")
		local v13 = rarity and v10[rarity] or Color3.fromRGB(255, 255, 255)

		if (name == "Furniture" or name == "Tools" or name == "Toys") and p3 <= 0 then
			previewFrame.TextLabel.TextColor3 = color
		else
			previewFrame.TextLabel.TextColor3 = v13
		end

		local glow = previewFrame:FindFirstChild("Glow")

		if glow then
			glow.ImageColor3 = v13
		end

		if v3 and v3 ~= folder then
			v3:SetAttribute("Selected", nil)
			v4 = {}
		end

		folder:SetAttribute("Selected", true)
		v3 = folder
		v4.folder = folder
		v4.image = image
		v4.name = childName
		v4.desc = p2
		v4.stock = p3
	else
		previewFrame.Visible = false

		if v3 then
			v3:SetAttribute("Selected", nil)
		end

		v3 = nil
		v4 = {}
	end
end

function RefreshMenu(instance)
	local child = supplyCrate:FindFirstChild(instance.Name .. "ScrollingFrame")
	local clone = nil

	for _, child2 in pairs(instance:GetChildren()) do
		if child2.Name == "Toy Shelf" then
			continue
		end

		if child2:GetAttribute("Equipped") == false then
			if v[child2] then
				v[child2]:Destroy()
				v[child2] = nil
			end
		else
			local quantity = child2:GetAttribute("Quantity") or 0
			local serverWithdrawn = child2:GetAttribute("ServerWithdrawn") or 0

			if instance.Name == "Furniture" then
				quantity = child2:GetAttribute("Stock") or 0
				serverWithdrawn = 0
			end

			local image = " "
			local description = " "
			local name = child2.Name
			clone = v[child2]
			local v12 = child2

			local function makeButton()
				if instance.Name == "Toys" then
					clone = child.PlushiesRow.Template:Clone()
					clone.Parent = child.PlushiesRow
					local v14 = Client.Databases.RewardsDatabase.Toys[v12.Name] or {}
					description = v14.Description or ""
					image = v14.Image or ""
					local text = string.gsub(v12.Name, "[Ff][Ll][Aa][Mm][Ee]", "Offering")
					clone.TitleLabel.Text = text
					clone.DescriptionLabel.Text = description

					if image == "" or image == "rbxassetid://75002580261891" then
						ApplyIconViewport(clone.ItemIconFrame, v14.Model or v12.Name)
					else
						clone.ItemIconFrame.ImageLabel.Image = image
						clone.ItemIconFrame.ImageLabel.Visible = true
					end
				elseif instance.Name == "Tools" then
					clone = child.Template:Clone()
					clone.Parent = child
					local v14 = Client.Databases.RewardsDatabase.Tools[v12.Name] or {}
					description = v14.Description or ""
					image = v14.Image or ""
					clone.ItemIconFrame.ImageLabel.Image = image
					clone.TitleLabel.Text = v12.Name
					clone.TitleLabel.TextColor3 = v14.Colour or Color3.fromRGB(255, 255, 255)
					clone.DescriptionLabel.Text = description
				elseif instance.Name == "Furniture" then
					clone = child.Template:Clone()
					clone.Parent = child
					image = "rbxassetid://75002580261891"
					description = ""
					ApplyIconViewport(clone.ItemIconFrame, v12.Name)
				elseif instance.Name == "Pet Skins" then
					clone = child.Template:Clone()
					clone.Parent = child
					description = (Client.Databases.RewardsDatabase.PetSkins[v12.Name] or {}).Description or ""
					clone.TitleLabel.Text = v12.Name
					ApplyPetSkinViewport(clone.ItemIconFrame, v12.Name)
				else
					clone = child.Template:Clone()
					clone.Parent = child
					local v14 = Client.Databases.RewardsDatabase.FireUpgrades[v12.Name] or {}
					description = v14.Description or ""
					image = v14.Image or ""
					local colour = v14.Colour or Color3.fromRGB(255, 94, 0)
					clone.ItemIconFrame.ImageLabel.Image = image
					clone.TitleLabel.TextColor3 = colour
					local text = string.gsub(v12.Name, "[Ff][Ll][Aa][Mm][Ee]", "Offering")
					clone.TitleLabel.Text = text
				end

				if quantity - serverWithdrawn > 0 then
					layoutOrder += 1
					clone.LayoutOrder = layoutOrder
				else
					layoutOrder2 += 1
					clone.LayoutOrder = layoutOrder2
				end

				clone.Activated:Connect(function()
					Client.Sound.Play("KeyPress")
					local v14

					if instance.Name == "Furniture" then
						v14 = v12:GetAttribute("Stock") or 0
					else
						v14 = (v12:GetAttribute("Quantity") or 0) - (v12:GetAttribute("ServerWithdrawn") or 0)
					end

					SetPreview(v12, image, name, description, v14)
				end)
			end

			if not clone then
				makeButton()
			end

			if instance.Name == "Upgrade Flames" then
				clone.DescriptionLabel.Text = Client.SpecialFireClient.GetDescription(child2.Name)
			end

			local amountOwnedFrame = clone:FindFirstChild("AmountOwnedFrame")

			if amountOwnedFrame then
				amountOwnedFrame.Amount.Text = math.clamp(quantity - serverWithdrawn, 0, 99)

				if quantity - serverWithdrawn > 0 then
					amountOwnedFrame.Amount.TextColor3 = Color3.fromRGB(229, 229, 229)
				else
					amountOwnedFrame.Amount.TextColor3 = color
				end
			end

			if instance.Name == "Furniture" then
				local v14 = quantity
				clone.TitleLabel.Text = child2.Name
				clone.TitleLabel.Visible = v14 <= 0
				local coinAmount = clone:FindFirstChild("CoinAmount")

				if coinAmount then
					local price = child2:GetAttribute("Price") or 0

					if localPlayer:GetAttribute("DecoratorGamePass") then
						price = math.ceil(price * 0.75)
					end

					if coinAmount:FindFirstChild("CoinAmount") then
						coinAmount.CoinAmount.Text = tostring(price)
					end

					coinAmount.Visible = v14 > 0
				end
			end

			if instance.Name == "Toys" then
				local v14 = quantity - serverWithdrawn
				clone.TitleLabel.Text = v14 > 1 and child2.Name .. " (" .. v14 .. ")" or child2.Name
			end

			if (instance.Name == "Tools" or instance.Name == "Toys") and amountOwnedFrame then
				amountOwnedFrame.Visible = false
			end

			local rarity = child2:GetAttribute("Rarity")

			if instance.Name == "Furniture" and quantity <= 0 then
				clone.TitleLabel.TextColor3 = color
			elseif instance.Name == "Tools" and quantity - serverWithdrawn <= 0 then
				clone.TitleLabel.TextColor3 = color
			elseif instance.Name == "Tools" then
				local v14 = Client.Databases.RewardsDatabase.Tools[child2.Name] or {}
				clone.TitleLabel.TextColor3 = v14.Colour or Color3.fromRGB(255, 255, 255)
			elseif instance.Name == "Toys" then
				clone.TitleLabel.TextColor3 = quantity - serverWithdrawn <= 0 and color or Color3.fromRGB(255, 255, 255)
			elseif rarity and v10[rarity] then
				clone.TitleLabel.TextColor3 = v10[rarity]
			end

			if child2:GetAttribute("Selected") then
				RefreshPreview()
				clone.SelectedCornerDetails.Visible = true
				clone.UIStroke.Thickness = 0.036
				clone.UIStroke.Transparency = 0
				local _ = (child2:GetAttribute("Quantity") or 0) - (child2:GetAttribute("ServerWithdrawn") or 0)
			else
				clone.SelectedCornerDetails.Visible = false
				clone.UIStroke.Thickness = 0.012
				clone.UIStroke.Transparency = 0.85
			end

			clone.Visible = true
			v[child2] = clone
		end
	end

	local count = 0

	for _, child2 in pairs(instance:GetChildren()) do
		if child2.Name ~= "Toy Shelf" and child2:GetAttribute("Equipped") ~= false then
			count += 1
		end
	end

	if v2 == instance.Name and count == 0 then
		print(v2 .. " is selected")
		child.Visible = false
		local child2 = supplyCrate.EmptyState:FindFirstChild(instance.Name)

		if child2 then
			child2.Visible = true
			supplyCrate.EmptyState.Visible = true
		end
	elseif v2 == instance.Name then
		child.Visible = true
		local child2 = supplyCrate.EmptyState:FindFirstChild(instance.Name)

		if child2 then
			child2.Visible = false
			supplyCrate.EmptyState.Visible = false
		end
	end
end

function RefreshFlameDescriptions()
	local rewardsInventory = localPlayer:FindFirstChild("RewardsInventory")
	local upgradeFlames = rewardsInventory and rewardsInventory:FindFirstChild("Upgrade Flames")

	if upgradeFlames then
		RefreshMenu(upgradeFlames)
	end
end

function FolderSetup(p, p2)
	p.AttributeChanged:Connect(function()
		RefreshMenu(p2)
	end)
end

function FolderInitialSetupAndListeners()
	local rewardsInventory = localPlayer:WaitForChild("RewardsInventory")

	local function newRewardsFolder(child)
		child.ChildAdded:Connect(function(child2)
			FolderSetup(child2, child)
			RefreshMenu(child)
		end)
		child.ChildRemoved:Connect(function(child2)
			if v[child2] then
				v[child2]:Destroy()
			end

			RefreshMenu(child)
		end)

		for _, child2 in pairs(child:GetChildren()) do
			FolderSetup(child2, child)
		end

		RefreshMenu(child)
	end

	for _, child in pairs(rewardsInventory:GetChildren()) do
		newRewardsFolder(child)
	end

	rewardsInventory.ChildAdded:Connect(function(child)
		newRewardsFolder(child)
	end)
end

local coinAmount = localPlayer.PlayerGui.Interface:FindFirstChild("CoinAmount")
local visibleChangedConnection = nil

function UpdateFurnitureCoinDisplay()
	if not coinAmount then
		return
	end

	if visibleChangedConnection then
		visibleChangedConnection:Disconnect()
		visibleChangedConnection = nil
	end

	if not supplyCrate.Visible or v2 ~= "Furniture" then
		coinAmount.Visible = false
		return
	end

	coinAmount.TextLabel.Text = localPlayer:GetAttribute("Coins") or 0
	coinAmount.Visible = true
	visibleChangedConnection = coinAmount:GetPropertyChangedSignal("Visible"):Connect(function()
		if not coinAmount.Visible and supplyCrate.Visible and v2 == "Furniture" then
			coinAmount.Visible = true
		end
	end)
end

function BottomMenuSetup()
	local buttons = {}

	local function setEquippedButton(childName)
		v2 = childName
		local v12 = nil

		for _, v13 in pairs(buttons) do
			if v13.Name == childName then
				v13.TextLabel.TextTransparency = 0
				v13.Icon.ImageTransparency = 0
				v13.Icon.UIGradient.Enabled = false
				v12 = v13
			else
				v13.TextLabel.TextTransparency = 0.5
				v13.Icon.ImageTransparency = 0.5
				v13.Icon.UIGradient.Enabled = true
			end
		end

		supplyCrate.Header.HeaderTitle.Text = v12.TextLabel.Text == "Upgrade Flames" and "Offerings" or v12.TextLabel.Text
		supplyCrate.Header.HeaderDescription.Text = v8[childName] or ""
		supplyCrate.Header.ImageLabel.Image = v12.Icon.Image
		supplyCrate.Header.Visible = true

		for _, child in pairs(supplyCrate:GetChildren()) do
			if not string.find(child.Name, "ScrollingFrame") then
				continue
			end

			local v13 = child.Name:gsub("ScrollingFrame", "")

			if string.find(child.Name, childName) then
				if supplyCrate.EmptyState:FindFirstChild(childName) and supplyCrate.EmptyState:FindFirstChild(childName).Visible then
					child.Visible = false
					supplyCrate.EmptyState.Visible = true

					for _, child2 in pairs(supplyCrate.EmptyState:FindFirstChild(childName):GetChildren()) do
						child2.Visible = true
					end
				else
					child.Visible = true
					supplyCrate.EmptyState.Visible = false
				end
			else
				child.Visible = false

				if supplyCrate.EmptyState:FindFirstChild(v13) and supplyCrate.EmptyState:FindFirstChild(v13).Visible then
					for _, child2 in pairs(supplyCrate.EmptyState:FindFirstChild(v13):GetChildren()) do
						child2.Visible = false
					end
				end
			end
		end

		UpdateFurnitureCoinDisplay()
	end

	local tabs = supplyCrate.TabNavigator.Tabs

	for _, button in pairs(tabs:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		table.insert(buttons, button)
		local v12 = button
		button.Activated:Connect(function()
			if v12.Name == v2 then
				return
			end

			Client.Sound.Play("KeyPress")
			SetPreview()
			local child = localPlayer.RewardsInventory:FindFirstChild(v12.Name)
			local child2 = supplyCrate.EmptyState:FindFirstChild(v12.Name)

			if child2 then
				child2.Visible = not child or #child:GetChildren() == 0
			end

			setEquippedButton(v12.Name)

			if child then
				RefreshMenu(child)
			end
		end)
	end

	setEquippedButton(v2)
end

function PreviewButtonsSetup()
	supplyCrate.PreviewFrame.UseButton.Activated:Connect(function()
		if not v3 then
			return
		end

		local name = v3.Parent.Name

		if name == "Furniture" then
			local v12 = v3

			if (v12:GetAttribute("Stock") or 0) <= 0 then
				Client.PopUpUI.AddPopUp("none left", "warning")
				return
			end

			local price = v12:GetAttribute("Price") or 0

			if localPlayer:GetAttribute("DecoratorGamePass") then
				price = math.ceil(price * 0.75)
			end

			if not (price <= Client.FlowerAndCoinsClient.CoinAmount or price <= (localPlayer:GetAttribute("Coins") or 0)) then
				Client.PopUpUI.AddPopUp("not enough coins", "warning")
				return
			end

			Client.FlowerAndCoinsClient.CoinAmount -= price
			Client.Events.RequestBuyOwnedFurniture:FireServer(v12.Name)

			if v12:GetAttribute("Stock") then
				v12:SetAttribute("Stock", v12:GetAttribute("Stock") - 1)
			end

			Client.Sound.Play("BuyItem", {
				Volume = 0.4,
				Duplicate = true
			})
			Client.Sound.Play("SupplyChest")
			Client.PopUpUI.AddPopUp("spawned " .. v12.Name)
		else
			if name == "Upgrade Flames" and v9[v3.Name] then
				return
			end

			if not ((v3:GetAttribute("Quantity") or 1) - (v3:GetAttribute("ServerWithdrawn") or 0) > 0) then
				Client.PopUpUI.AddPopUp("none left", "warning")
				return
			end

			local v12 = string.gsub(v3.Name, "[Ff][Ll][Aa][Mm][Ee]", "Offering")
			Client.PopUpUI.AddPopUp("taken " .. v12)
			Client.Events.SpawnSupplyChest:FireServer(v3, v7)
			Client.Sound.Play("SupplyChest")
			local name2 = v3.Name
			v9[name2] = true
			task.spawn(function()
				wait(5)
				v9[name2] = false
			end)
		end
	end)
end

function ToyShelfButtonSetup()
	local toys = localPlayer.RewardsInventory:WaitForChild("Toys")
	local template = supplyCrate.ToysScrollingFrame.Template
	local connections = {}

	local function clearConns()
		for _, connection in pairs(connections) do
			connection:Disconnect()
		end

		connections = {}
	end

	local function setupShelf(instance)
		clearConns()
		template.Visible = true

		local function onChanged()
			if instance:GetAttribute("Selected") then
				RefreshPreview()
			end

			local text = (instance:GetAttribute("Quantity") or 0) - (instance:GetAttribute("ServerWithdrawn") or 0)
			template.AmountOwnedFrame.Amount.Text = text
			template.AmountOwnedFrame.Amount.TextColor3 = text > 0 and Color3.fromRGB(229, 229, 229) or Color3.fromRGB(
				161,
				0,
				0
			)
			template.TitleLabel.TextColor3 = text > 0 and Color3.fromRGB(255, 255, 255) or color
		end

		table.insert(connections, template.Activated:Connect(function()
			Client.Sound.Play("CloseButton")
			SetPreview(
				instance,
				"rbxassetid://96621424589037",
				"Toy Shelf",
				template.DescriptionLabel.Text,
				(instance:GetAttribute("Quantity") or 0) - (instance:GetAttribute("ServerWithdrawn") or 0)
			)
		end))
		table.insert(connections, instance:GetAttributeChangedSignal("Selected"):Connect(function()
			if instance:GetAttribute("Selected") then
				template.SelectedCornerDetails.Visible = true
				template.UIStroke.Thickness = 0.036
				template.UIStroke.Transparency = 0
			else
				template.SelectedCornerDetails.Visible = false
				template.UIStroke.Thickness = 0.012
				template.UIStroke.Transparency = 0.85
			end
		end))
		table.insert(connections, instance:GetAttributeChangedSignal("ServerWithdrawn"):Connect(onChanged))
		table.insert(connections, instance:GetAttributeChangedSignal("Quantity"):Connect(onChanged))
		onChanged()
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function removeShelf()
		clearConns()
		template.Visible = false

		if v3 and v3.Name == "Toy Shelf" then
			SetPreview()
		end
	end

	local toyShelf = toys:FindFirstChild("Toy Shelf")

	if toyShelf then
		setupShelf(toyShelf)
	else
		template.Visible = false
	end

	toys.ChildAdded:Connect(function(child)
		if child.Name == "Toy Shelf" then
			setupShelf(child)
		end
	end)
	toys.ChildRemoved:Connect(function(child)
		if child.Name == "Toy Shelf" then
			removeShelf() -- equivalent call inferred; original call site unknown
		end
	end)
end

function MenuOpenStateSetup()
	local v12 = nil
	local coreGuiEnabled = nil
	supplyCrate:GetPropertyChangedSignal("Visible"):Connect(function()
		UpdateFurnitureCoinDisplay()

		if supplyCrate.Visible then
			if coreGuiEnabled == nil then
				coreGuiEnabled = StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Chat)
			end

			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
		elseif coreGuiEnabled ~= nil then
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, coreGuiEnabled)
			coreGuiEnabled = nil
		end

		if supplyCrate.Visible and v7 then
			v12 = v7
			Client.Events.SupplyCrateMenuState:FireServer(v12, true)
		elseif not supplyCrate.Visible and v12 then
			Client.Events.SupplyCrateMenuState:FireServer(v12, false)
			v12 = nil
		end
	end)
end

Client.InteractionHandler.RegisterInteraction("OpenSupplyCrate", function(p)
	v7 = p

	if supplyCrate.Visible then
		Client.Sound.Play("CloseButton")
		supplyCrate.Visible = false
		GamepadService:DisableGamepadCursor()
	else
		supplyCrate.Visible = true

		if UserInputService:GetLastInputType() == Enum.UserInputType.Gamepad1 then
			GamepadService:EnableGamepadCursor(supplyCrate)
		end
	end
end)
local v12 = {}
local v13 = {}

function BumpChestLid(instance)
	local chestLid = instance:FindFirstChild("ChestLid")
	local cframe = v12[instance]

	if not (chestLid and cframe) then
		return
	end

	local _, v14 = (cframe:Inverse() * chestLid:GetPivot()):ToAxisAngle()

	if math.abs(v14) > 0.17453292519943295 then
		return
	end

	if v13[instance] then
		v13[instance]:Cancel()
	end

	local cFrameValue = Instance.new("CFrameValue")
	cFrameValue.Value = chestLid:GetPivot()
	cFrameValue.Changed:Connect(function(cframe2)
		chestLid:PivotTo(cframe2)
	end)
	local tween = TweenService:Create(
		cFrameValue,
		TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		{
			Value = cframe * CFrame.Angles(-0.20943951023931956, 0, 0)
		}
	)
	local tween2 = TweenService:Create(
		cFrameValue,
		TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
		{
			Value = cframe
		}
	)
	v13[instance] = tween
	tween.Completed:Once(function(p)
		if p ~= Enum.PlaybackState.Completed then
			cFrameValue:Destroy()
			return
		end

		v13[instance] = tween2
		tween2.Completed:Once(function()
			cFrameValue:Destroy()
		end)
		tween2:Play()
	end)
	tween:Play()
end

function SupplyCrateAdded(instance)
	if instance.Parent ~= workspace.Structures then
		return
	end

	local touchZone = instance:WaitForChild("TouchZone")
	local chestLid = instance:WaitForChild("ChestLid", 5)

	if chestLid then
		v12[instance] = chestLid:GetPivot()
		instance.Destroying:Connect(function()
			v12[instance] = nil
			v13[instance] = nil
		end)
	end

	touchZone.Touched:Connect(function(otherPart)
		local parent = otherPart.Parent

		if parent.Parent ~= workspace.Items and not parent.Parent.Parent:IsA("Player") then
			return
		end

		if parent:GetAttribute("Owner") ~= localPlayer.UserId and parent:GetAttribute("LastOwner") ~= localPlayer.UserId then
			return
		end

		if parent:HasTag("SpecialFlame") then
			if parent:GetAttribute("AdminSpawned") then
				return
			end

			parent.Parent = game.ReplicatedStorage.TempStorage
			Client.Sound.Play("BagGet", {
				Volume = 0.5
			})
			BumpChestLid(instance)
			local v14 = Client.Events.RequestStoreSupplyCrate:InvokeServer(instance, parent)

			if not (v14 and v14.Success) then
				task.delay(0.5, function()
					parent.Parent = workspace.Items
				end)
			end
		end
	end)
end

function SupplyCrateClient.Init()
	MenuOpenStateSetup()
	task.spawn(function()
		supplyCrate.CloseButton.Activated:Connect(function()
			Client.Sound.Play("CloseButton")
			supplyCrate.Visible = false
		end)
		FolderInitialSetupAndListeners()
		BottomMenuSetup()
		PreviewButtonsSetup()
		ToyShelfButtonSetup()
		SetupAutoScale()
	end)
	Client.Utility.ForAllTagged("SupplyCrate", SupplyCrateAdded)
	task.spawn(function()
		workspace:GetAttributeChangedSignal("RealDayCounter"):Connect(function()
			local _ = supplyCrate.PreviewFrame.CountdownWarning.TextLabel
			RefreshFlameDescriptions()
		end)
		workspace:GetAttributeChangedSignal("State"):Connect(RefreshFlameDescriptions)
	end)
end

return SupplyCrateClient