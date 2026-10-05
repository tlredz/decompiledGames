local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GamepadUI = require(ReplicatedStorage:WaitForChild("GameServices"):WaitForChild("GamepadUI"))
local RunService = game:GetService("RunService")
game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local PurchaseCue = require(ReplicatedStorage2:WaitForChild("GameServices"):WaitForChild("PurchaseCue"))
game:GetService("ContextActionService")
game:GetService("GuiService")
local services = game.ReplicatedStorage:WaitForChild("Services")
local String = require(services:WaitForChild("String"))
local Monetization = require(services:WaitForChild("Monetization"))
local Main = require(services:WaitForChild("FormatNumber"):WaitForChild("Main"))
local v = Main.NumberFormatter.with()
local gameData = game.ReplicatedStorage:WaitForChild("GameData")
local Shop = require(gameData:WaitForChild("Shop"))
local Monetization2 = require(gameData:WaitForChild("Monetization"))
local localPlayer = game.Players.LocalPlayer
local parent = script.Parent.Parent
local holders = parent:WaitForChild("Holders")
local header = parent:WaitForChild("Header")
local restockButton = header:WaitForChild("RestockButton")
local title = header:WaitForChild("Title")
local closeButton = header:WaitForChild("CloseButton")
local itemTemplate = script:WaitForChild("ItemTemplate")
local reusable = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Reusable")
local Handler = require(reusable:WaitForChild("GameMessages"):WaitForChild("Handler"))
local cash = localPlayer:WaitForChild("SavedData"):WaitForChild("Cash")
local SFX = game.SoundService:WaitForChild("SFX")
local UIController = require(game.ReplicatedStorage:WaitForChild("UIController"))
local game2 = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
local restock = game2:WaitForChild("Restock")
local shopStock = game2:WaitForChild("ShopStock")
local buyWithCash = game2:WaitForChild("BuyWithCash")
local setOpenShop = game2:WaitForChild("SetOpenShop")
local autobuy = game2:WaitForChild("Autobuy")
local serverData = game.ReplicatedStorage:WaitForChild("ServerData")
local gifting = parent.Parent:WaitForChild("Gifting")
local productId = gifting:WaitForChild("Data"):WaitForChild("ProductId")
local productName = gifting:WaitForChild("Header"):WaitForChild("ProductName")
local updatePlayerToGift = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Reusable"):WaitForChild("UpdatePlayerToGift")
local v2 = {
	Mythic = "Mythical",
	Uncommon = "Common"
}
local color = Color3.fromRGB(69, 73, 76)
local color2 = Color3.fromRGB(255, 45, 45)
local v3 = { 1, 3, 10 }
local v4 = utf8.char(57346)
local unit = (createVector(1, 0.95, 1)).Unit

local function PeriodFor(_)
	return 300
end

local function OnPress(object, callback)
	object.Activated:Connect(function()
		callback()
	end)
	object:GetAttributeChangedSignal("GamepadPress"):Connect(function()
		callback()
	end)
end

local function ShowModelInViewport(imageViewport, child)
	for _, child2 in imageViewport:GetChildren() do
		if not (child2:IsA("Model") or child2:IsA("BasePart") or child2:IsA("Camera")) then
			continue
		end

		child2:Destroy()
	end

	local clone = child:Clone()

	if clone:IsA("Tool") then
		local model = Instance.new("Model")

		for _, child2 in clone:GetChildren() do
			child2.Parent = model
		end

		clone:Destroy()
		clone = model
	end

	for _, descendant in clone:GetDescendants() do
		if descendant:IsA("BasePart") then
			descendant.Anchored = true
			descendant.CanCollide = false
		elseif descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("Sound") then
			descendant:Destroy()
		end
	end

	if not clone:FindFirstChildWhichIsA("BasePart", true) then
		clone:Destroy()
		return false
	end

	clone:PivotTo(CFrame.new())
	clone.Parent = imageViewport
	local boundingBox, v5 = clone:GetBoundingBox()
	local v6 = math.max(v5.Magnitude / 2, 0.1)
	local v7 = 0.30543261909900765
	local absoluteSize = imageViewport.AbsoluteSize

	if absoluteSize.X > 0 and absoluteSize.Y > 0 and absoluteSize.X < absoluteSize.Y then
		v7 = math.atan(math.tan(v7) * (absoluteSize.X / absoluteSize.Y))
	end

	local v8 = v6 / math.sin(v7) * 1.15
	local camera = Instance.new("Camera")
	camera.FieldOfView = 35
	camera.CFrame = CFrame.lookAt(boundingBox.Position + unit * v8, boundingBox.Position)
	camera.Parent = imageViewport
	imageViewport.CurrentCamera = camera
	imageViewport.Ambient = Color3.fromRGB(200, 200, 200)
	imageViewport.LightColor = Color3.fromRGB(255, 255, 255)
	imageViewport.LightDirection = (createVector(-1, -1.5, -1)).Unit
	imageViewport.BackgroundTransparency = 1
	return true
end

local function GetOpenHolder()
	for _, guiObject in holders:GetChildren() do
		if guiObject:IsA("GuiObject") and guiObject.Visible then
			return guiObject
		end
	end

	return nil
end

local v5 = nil
local text2 = nil
RunService.RenderStepped:Connect(function()
	if not parent.Visible then
		return
	end

	local openHolder = GetOpenHolder()

	if not openHolder then
		return
	end

	local child = serverData:FindFirstChild("LastRestockTime_" .. openHolder.Name)
	local v8

	if child then
		local _ = openHolder.Name
		v8 = math.max(300 - (workspace:GetServerTimeNow() - child.Value), 0)
	else
		v8 = child
	end

	local v9 = openHolder.Name .. ":" .. tostring(v8 and math.floor(v8)) .. ":" .. tostring(v8 and v8 % 60 == 0)

	if v9 == v5 and title.Text == text2 then
		return
	end

	v5 = v9
	local v10 = string.lower(Shop.GetDisplayName(openHolder.Name))

	if child then
		text2 = string.format("New %s in %s", v10, String:FormatTimeInInitials(v8))

		if title.Text ~= text2 then
			title.Text = text2
		end
	else
		text2 = string.format("New %s soon", v10)
		title.Text = text2
	end
end)
OnPress(restockButton, function()
	local openHolder = GetOpenHolder()

	if not openHolder then
		return
	end

	setOpenShop:FireServer(openHolder.Name)
	local restock2 = Monetization2.Restock

	if not restock2 then
		warn("Shop: no Restock product id in GameData.Monetization")
		return
	end

	PurchaseCue.Play()
	MarketplaceService:PromptProductPurchase(localPlayer, restock2)
end)
OnPress(closeButton, function()
	UIController.close(parent)
end)
GamepadUI.Watch(parent, function()
	UIController.close(parent)
end, closeButton)
local v7 = {}
local v8 = {}

local function IsAutobuyOn(p: string, p2: string)
	local v9 = v7[p]
	return v9 ~= nil and v9[p2] == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PaintAutobuy(data)
	local category = data.Category
	local name = data.Name
	local v9 = v7[category]
	local visible

	if v9 == nil then
		visible = false
	else
		visible = v9[name] == true
	end

	data.Green.Visible = visible
	data.Red.Visible = not visible
end

autobuy.OnClientEvent:Connect(function(options)
	v7 = options or {}

	for k, v9 in v8 do
		if k.Parent then
			PaintAutobuy(v9) -- equivalent call inferred; original call site unknown
		else
			v8[k] = nil
		end
	end
end)
autobuy:FireServer()
local v9 = {}
local PaintTile

local function BindRobuxHover(child, label, productId2: number?)
	local text = label.Text
	local text3 = nil

	if productId2 then
		task.spawn(function()
			local basePrice = Monetization:GetBasePrice(productId2, false)

			if basePrice then
				text3 = string.format("%s%d", v4, basePrice)
			end
		end)
	end

	child.MouseEnter:Connect(function()
		if text3 then
			label.Text = text3
		end
	end)
	child.MouseLeave:Connect(function()
		label.Text = text
	end)
	child.SelectionGained:Connect(function()
		if text3 then
			label.Text = text3
		end
	end)
	child.SelectionLost:Connect(function()
		label.Text = text
	end)
end

local function BuildTile(parent2, name: string, config)
	local clone = itemTemplate:Clone()
	clone.Name = name
	clone.Parent = parent2
	local productExpander = clone:WaitForChild("ProductExpander")
	local displayName = config.DisplayName or name
	local title = productExpander:WaitForChild("Title")
	title.Text = displayName
	local v10 = v2[config.Rarity] or config.Rarity
	local rarities = productExpander:FindFirstChild("Rarities")
	local v11 = false

	if rarities then
		for _, guiObject in rarities:GetChildren() do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			local visible = guiObject.Name == v10
			guiObject.Visible = visible

			if not visible then
				continue
			end

			v11 = true
			local title2 = guiObject:FindFirstChild("Title")

			if title2 then
				title2.Text = config.Rarity
			end
		end
	end

	if not v11 then
		warn(string.format("Shop: no rarity plate for %q on %s", tostring(config.Rarity), name))
	end

	local imageShower = productExpander:WaitForChild("ImageShower")
	local imageViewport = productExpander:FindFirstChild("ImageViewport")
	local v12

	if config.ImageId == nil then
		v12 = false
	else
		v12 = config.ImageId ~= ""
	end

	if v12 then
		imageShower.Image = config.ImageId
		imageShower.Visible = true

		if imageViewport then
			imageViewport.Visible = false
		end
	elseif imageViewport then
		local child = game.ReplicatedStorage.Assets:FindFirstChild(config.Source or "")
		local child2 = child and child:FindFirstChild(name)

		if child2 and ShowModelInViewport(imageViewport, child2) then
			imageShower.Visible = false
			imageViewport.Visible = true
		end
	end

	OnPress(clone:WaitForChild("CashPayment"):WaitForChild("Frame"):WaitForChild("Dollar"), function()
		local v13 = v9[parent2.Name] and v9[parent2.Name][name]
		local v14 = not v13 and 0 or v13.Amount or 0
		local v15

		if localPlayer:GetAttribute("TutorialActive") == true and localPlayer:GetAttribute("TutorialRadarGranted") ~= true and parent2.Name == "Gears" then
			v15 = name == "Advanced Radar"
		else
			v15 = false
		end

		if v14 <= 0 and not v15 then
			SFX.Error:Play()
			Handler:AddMessage("Out Of Stock!")
		elseif cash.Value < (config.Price or 0) and not v15 then
			SFX.Error:Play()
			Handler:AddMessage("Not Enough Cash!")
		else
			SFX.Click:Play()

			if v13 then
				v13.Amount -= 1
			end

			PaintTile(clone, config, v13 and v13.Amount or 0, false)
			buyWithCash:FireServer(parent2.Name, name)
		end
	end)
	local frame = clone:WaitForChild("RobuxPayment"):WaitForChild("Frame")

	for _, v13 in v3 do
		local child = frame:FindFirstChild(string.format("x%d", v13))

		if child then
			local productId2 = Shop.GetProductId(parent2.Name, name, v13)
			local label = child:FindFirstChild("Label")

			if label then
				BindRobuxHover(child, label, productId2)
			end

			if productId2 then
				local v14 = productId2
				OnPress(child, function()
					SFX.Click:Play()
					updatePlayerToGift:FireServer(nil)
					PurchaseCue.Play()
					MarketplaceService:PromptProductPurchase(localPlayer, v14)
				end)
			else
				child.Visible = false

				if config.ProductKey then
					warn(string.format("Shop: no product id for x%d %s", v13, name))
				end
			end
		end

		local child2 = frame:FindFirstChild(string.format("Giftx%d", v13))

		if not child2 then
			continue
		end

		local productId2 = Shop.GetProductId(parent2.Name, name, v13)

		if productId2 then
			local v14 = productId2
			local v15 = v13
			OnPress(child2, function()
				SFX.Click:Play()
				productId.Value = tostring(v14)
				productName.Text = string.format("Gifting: x%d %s", v15, displayName)
				UIController.open(gifting)
			end)
		else
			child2.Visible = false
		end
	end

	local greenAutoBuy = productExpander:FindFirstChild("GreenAutoBuy")
	local redAutoBuy = productExpander:FindFirstChild("RedAutoBuy")

	if greenAutoBuy and redAutoBuy then
		local v13 = {
			Category = parent2.Name,
			Name = name,
			Green = greenAutoBuy,
			Red = redAutoBuy
		}
		v8[clone] = v13
		PaintAutobuy(v13) -- equivalent call inferred; original call site unknown

		local function Toggle()
			SFX.Click:Play()
			local name2 = parent2.Name
			local v15 = v7[name2]
			local v17 = v15 == nil or v15[name] ~= true
			local price = config.Price or 0

			if v17 and cash.Value < price then
				SFX.Error:Play()
				Handler:AddMessage(string.format("You need $%s More", v:Format(price - cash.Value)))
			else
				autobuy:FireServer(parent2.Name, name, v17)
			end
		end

		OnPress(greenAutoBuy, Toggle)
		OnPress(redAutoBuy, Toggle)
	end

	return clone
end

PaintTile = function(instance, p, amount: number, _: boolean)
	local productExpander = instance:WaitForChild("ProductExpander")
	local stock = productExpander:WaitForChild("Stock")
	local price = productExpander:WaitForChild("Price")
	local dollar = instance:WaitForChild("CashPayment"):WaitForChild("Frame"):WaitForChild("Dollar")
	local label = dollar:FindFirstChild("Label")
	local uIStroke = label and label:FindFirstChildOfClass("UIStroke")

	if instance:GetAttribute("StockImage") == nil then
		instance:SetAttribute("StockImage", dollar.Image)
		instance:SetAttribute("StockPriceColor", price.TextColor3)

		if uIStroke then
			instance:SetAttribute("StockStroke", uIStroke.Color)
		end
	end

	stock.Text = string.format("x%d Stock", amount)
	local text = string.format("$%s", v:Format(p.Price or 0))

	if amount > 0 then
		price.Text = text
		price.TextColor3 = instance:GetAttribute("StockPriceColor")
		dollar.Image = instance:GetAttribute("StockImage")

		if uIStroke and instance:GetAttribute("StockStroke") then
			uIStroke.Color = instance:GetAttribute("StockStroke")
		end

		if label then
			label.Text = text
		end
	else
		price.Text = "No Stock"
		price.TextColor3 = color2
		dollar.Image = "rbxassetid://128574896311791"

		if uIStroke then
			uIStroke.Color = color
		end

		if label then
			label.Text = "NO STOCK"
		end
	end
end

local function Restock(instance, p, options)
	local v10 = options or {}
	local category = Shop.Categories[instance.Name]

	if not category then
		return
	end

	local v11 = p[instance.Name] or {}
	v9[instance.Name] = v11
	local v12 = {}
	local v13 = {
		Common = 1,
		Uncommon = 2,
		Rare = 3,
		Epic = 4,
		Legendary = 5,
		Mythic = 6,
		Mythical = 6,
		Divine = 7,
		Ethereal = 8
	}

	for k, config in category do
		table.insert(v12, {
			Name = k,
			Config = config
		})
	end

	table.sort(v12, function(a, b)
		local v14 = Shop.SourceOrder[a.Config.Source] or 1e999
		local v15 = Shop.SourceOrder[b.Config.Source] or 1e999

		if v14 ~= v15 then
			return v14 < v15
		end

		local v16 = v13[a.Config.Rarity] or 0
		local v17 = v13[b.Config.Rarity] or 0

		if v16 ~= v17 then
			return v16 < v17
		end

		local price = a.Config.Price or 0
		local price2 = b.Config.Price or 0

		if price == price2 then
			return a.Name < b.Name
		end

		return price < price2
	end)

	for k, v14 in v12 do
		local v15 = instance:FindFirstChild(v14.Name) or BuildTile(instance, v14.Name, v14.Config)
		v15.LayoutOrder = k
		local v16 = v11[v14.Name]
		PaintTile(v15, v14.Config, v16 and v16.Amount or 0, v10.ReduceStock ~= true)

		if v10.ReduceStock ~= true then
			task.wait(0.05)
		end
	end
end

local flag = false
restock.OnClientEvent:Connect(function(options, p)
	local v10 = options or {}
	flag = true

	for _, scrollingFrame in holders:GetChildren() do
		if scrollingFrame:IsA("ScrollingFrame") then
			task.spawn(Restock, scrollingFrame, v10, p)
		end
	end
end)
task.spawn(function()
	for _ = 1, 10 do
		if flag then
			return
		end

		shopStock:FireServer()
		task.wait(2)
	end

	if not flag then
		warn("Shop: no stock received from the server after 10 requests")
	end
end)