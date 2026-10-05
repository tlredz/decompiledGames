local createVector = vector.create
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
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
local restock = header:WaitForChild("Restock")
local restockTimer = header:WaitForChild("RestockTimer")
local itemTemplate = script:WaitForChild("ItemTemplate")
local reusable = localPlayer:WaitForChild("PlayerGui"):WaitForChild("Reusable")
local Handler = require(reusable:WaitForChild("GameMessages"):WaitForChild("Handler"))
local cash = localPlayer:WaitForChild("SavedData"):WaitForChild("Cash")
local SFX = game.SoundService:WaitForChild("SFX")
local game2 = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Game")
local restock2 = game2:WaitForChild("Restock")
local shopStock = game2:WaitForChild("ShopStock")
local autobuy = game2:WaitForChild("Autobuy")
local buyWithCash = game2:WaitForChild("BuyWithCash")
local setOpenShop = game2:WaitForChild("SetOpenShop")
local serverData = game.ReplicatedStorage:WaitForChild("ServerData")
local v2 = {
	Common = Color3.fromRGB(150, 150, 150),
	Uncommon = Color3.fromRGB(85, 170, 0),
	Rare = Color3.fromRGB(0, 85, 255),
	Epic = Color3.fromRGB(170, 85, 255),
	Legendary = Color3.fromRGB(255, 170, 0),
	Mythic = Color3.fromRGB(255, 85, 255),
	Mythical = Color3.fromRGB(255, 85, 255),
	Divine = Color3.fromRGB(255, 255, 0),
	Ethereal = Color3.fromRGB(85, 255, 255)
}
local v3 = {
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
local color = Color3.fromRGB(85, 255, 0)
local color2 = Color3.fromRGB(0, 85, 0)
local color3 = Color3.fromRGB(73, 73, 73)
local color4 = Color3.fromRGB(121, 121, 121)
local color5 = Color3.fromRGB(255, 57, 57)
local v4 = { 1, 3, 10 }
local v5 = utf8.char(57346)
local unit = (createVector(1, 0.95, 1)).Unit

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
	local boundingBox, v6 = clone:GetBoundingBox()
	local v7 = math.max(v6.Magnitude / 2, 0.1)
	local v8 = 0.30543261909900765
	local absoluteSize = imageViewport.AbsoluteSize

	if absoluteSize.X > 0 and absoluteSize.Y > 0 and absoluteSize.X < absoluteSize.Y then
		v8 = math.atan(math.tan(v8) * (absoluteSize.X / absoluteSize.Y))
	end

	local v9 = v7 / math.sin(v8) * 1.15
	local camera = Instance.new("Camera")
	camera.FieldOfView = 35
	camera.CFrame = CFrame.lookAt(boundingBox.Position + unit * v9, boundingBox.Position)
	camera.Parent = imageViewport
	imageViewport.CurrentCamera = camera
	imageViewport.Ambient = Color3.fromRGB(200, 200, 200)
	imageViewport.LightColor = Color3.fromRGB(255, 255, 255)
	imageViewport.LightDirection = (createVector(-1, -1.5, -1)).Unit
	imageViewport.BackgroundTransparency = 1
	return true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetCategoryRestockValue(name: string)
	return serverData:FindFirstChild("LastRestockTime_" .. name)
end

local function GetOpenHolder()
	for _, guiObject in holders:GetChildren() do
		if guiObject:IsA("GuiObject") and guiObject.Visible then
			return guiObject
		end
	end

	return nil
end

RunService.RenderStepped:Connect(function()
	local openHolder = GetOpenHolder()

	if not openHolder then
		return
	end

	local categoryRestockValue = GetCategoryRestockValue(openHolder.Name) -- equivalent call inferred; original call site unknown

	if not categoryRestockValue then
		restockTimer.Text = string.format("New %s soon", string.lower(openHolder.Name))
		return
	end

	local v8 = math.max(300 - (workspace:GetServerTimeNow() - categoryRestockValue.Value), 0)
	restockTimer.Text = string.format("New %s in %s", string.lower(openHolder.Name), String:FormatTimeInInitials(v8))
end)
restock.Activated:Connect(function()
	local openHolder = GetOpenHolder()

	if not openHolder then
		return
	end

	SFX.Click:Play()
	setOpenShop:FireServer(openHolder.Name)
	local restock3 = Monetization2.Restock

	if restock3 then
		MarketplaceService:PromptProductPurchase(localPlayer, restock3)
	else
		warn("Shop: no Restock product id in GameData.Monetization")
	end
end)
local v6 = {}
local v7 = {}
local v8 = {}

local function IsAutobuyOn(p: string, p2: string)
	local v9 = v7[p]
	return v9 ~= nil and v9[p2] == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function PaintAutobuy(p, p2: string, p3: string)
	local v9 = v7[p2]
	p.Image = v9 ~= nil and v9[p3] == true and "rbxassetid://102167734790904" or "rbxassetid://77178015284172"
end

autobuy.OnClientEvent:Connect(function(options)
	v7 = options or {}

	for k, v9 in v8 do
		if k.Parent then
			PaintAutobuy(k, v9.Category, v9.Name) -- equivalent call inferred; original call site unknown
		else
			v8[k] = nil
		end
	end
end)
autobuy:FireServer()

local function BindRobuxHover(child, label, productId: number?)
	local text = label.Text
	local text2 = nil

	if productId then
		task.spawn(function()
			local productInfo = Monetization:GetProductInfo(productId)

			if not productInfo then
				return
			end

			local userBasePriceInRobux = productInfo.UserBasePriceInRobux or productInfo.PriceInRobux

			if userBasePriceInRobux then
				text2 = string.format("%s%d", v5, userBasePriceInRobux)
			end
		end)
	end

	child.MouseEnter:Connect(function()
		if text2 then
			label.Text = text2
		end
	end)
	child.MouseLeave:Connect(function()
		label.Text = text
	end)
end

local PaintTile

local function BuildTile(parent2, name: string, config)
	local clone = itemTemplate:Clone()
	clone.Name = name
	clone.Parent = parent2
	local productExpander = clone:WaitForChild("ProductExpander")
	local productName = productExpander:WaitForChild("ProductName")
	productName.Text = name
	local rarityIndicator = productExpander:WaitForChild("RarityIndicator")
	local label_2 = rarityIndicator:WaitForChild("Label")
	label_2.Text = config.Rarity or "Common"
	local backgroundColor = v2[config.Rarity]

	if backgroundColor then
		rarityIndicator.BackgroundColor3 = backgroundColor
	else
		warn(string.format("Shop: no rarity colour for %q", (tostring(config.Rarity))))
	end

	local imageShower = productExpander:WaitForChild("ImageShower")
	local imageViewport = productExpander:FindFirstChild("ImageViewport")
	local v10

	if config.ImageId == nil then
		v10 = false
	else
		v10 = config.ImageId ~= ""
	end

	if v10 then
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

	local woodColor = productExpander:FindFirstChild("WoodColor")

	if woodColor then
		woodColor.Visible = false
	end

	clone:WaitForChild("CashPayment"):WaitForChild("BuyCash").Activated:Connect(function()
		local v11 = v6[parent2.Name] and v6[parent2.Name][name]

		if (not v11 and 0 or v11.Amount or 0) <= 0 then
			SFX.Error:Play()
			Handler:AddMessage("Out Of Stock!")
		elseif cash.Value < (config.Price or 0) then
			SFX.Error:Play()
			Handler:AddMessage("Not Enough Cash!")
		else
			SFX.Click:Play()

			if v11 then
				v11.Amount -= 1
			end

			PaintTile(clone, config, v11 and v11.Amount or 0, false)
			buyWithCash:FireServer(parent2.Name, name)
		end
	end)
	local robuxPayment = clone:WaitForChild("RobuxPayment")

	for _, v11 in v4 do
		local child = robuxPayment:FindFirstChild(string.format("x%d", v11))

		if not child then
			continue
		end

		local productId = Shop.GetProductId(parent2.Name, name, v11)
		local label = child:FindFirstChild("Label")

		if label then
			BindRobuxHover(child, label, productId)
		end

		if productId then
			local v12 = productId
			child.Activated:Connect(function()
				SFX.Click:Play()
				MarketplaceService:PromptProductPurchase(localPlayer, v12)
			end)
		else
			warn(string.format("Shop: no product id for x%d %s", v11, name))
		end
	end

	local autobuy2 = productExpander:FindFirstChild("Autobuy")

	if autobuy2 and autobuy2:IsA("ImageButton") then
		v8[autobuy2] = {
			Category = parent2.Name,
			Name = name
		}
		PaintAutobuy(autobuy2, parent2.Name, name) -- equivalent call inferred; original call site unknown
		autobuy2.Activated:Connect(function()
			SFX.Click:Play()
			local name3 = parent2.Name
			local v12 = v7[name3]
			local v14 = v12 == nil or v12[name] ~= true
			local price = config.Price or 0

			if v14 and cash.Value < price then
				SFX.Error:Play()
				Handler:AddMessage(string.format("You need $%s More", v:Format(price - cash.Value)))
			else
				autobuy:FireServer(parent2.Name, name, v14)
			end
		end)
	end

	return clone
end

PaintTile = function(instance, p, amount: number, flag: boolean)
	local productExpander = instance:WaitForChild("ProductExpander")
	local stockAmount = productExpander:WaitForChild("StockAmount")
	local priceLabel = productExpander:WaitForChild("PriceLabel")
	local buyCash = instance:WaitForChild("CashPayment"):WaitForChild("BuyCash")
	local label = buyCash:FindFirstChild("Label")
	stockAmount.Text = string.format("x%d stock", amount)

	if amount > 0 then
		local text = string.format("$%s", v:Format(p.Price or 0))
		priceLabel.TextColor3 = color
		priceLabel.Text = text
		buyCash.BackgroundColor3 = color
		buyCash.ImageColor3 = Color3.fromRGB(255, 255, 255)

		if buyCash:FindFirstChild("UIStroke") then
			buyCash.UIStroke.Color = color2
		end

		if label then
			label.Text = text
		end
	else
		priceLabel.TextColor3 = color5
		priceLabel.Text = "NO STOCK"
		buyCash.BackgroundColor3 = color3
		buyCash.ImageColor3 = Color3.fromRGB(15, 15, 15)

		if buyCash:FindFirstChild("UIStroke") then
			buyCash.UIStroke.Color = color4
		end

		if label then
			label.Text = "NO STOCK"
		end
	end

	local restockEffect = productExpander:FindFirstChild("RestockEffect")

	if flag and restockEffect then
		restockEffect.BackgroundTransparency = 0.5
		TweenService:Create(restockEffect, TweenInfo.new(0.5), {
			BackgroundTransparency = 1
		}):Play()
	end
end

local function Restock(instance, p, options)
	local v9 = options or {}
	local category = Shop.Categories[instance.Name]

	if not category then
		return
	end

	local v10 = p[instance.Name] or {}
	v6[instance.Name] = v10
	local v11 = {}

	for k, config in category do
		table.insert(v11, {
			Name = k,
			Config = config
		})
	end

	table.sort(v11, function(a, b)
		local v12 = Shop.SourceOrder[a.Config.Source] or 1e999
		local v13 = Shop.SourceOrder[b.Config.Source] or 1e999

		if v12 ~= v13 then
			return v12 < v13
		end

		local v14 = v3[a.Config.Rarity] or 0
		local v15 = v3[b.Config.Rarity] or 0

		if v14 ~= v15 then
			return v14 < v15
		end

		local price = a.Config.Price or 0
		local price2 = b.Config.Price or 0

		if price == price2 then
			return a.Name < b.Name
		end

		return price < price2
	end)

	for k, v12 in v11 do
		local v13 = instance:FindFirstChild(v12.Name) or BuildTile(instance, v12.Name, v12.Config)
		v13.LayoutOrder = k
		local v14 = v10[v12.Name]
		PaintTile(v13, v12.Config, v14 and v14.Amount or 0, v9.ReduceStock ~= true)

		if v9.ReduceStock ~= true then
			task.wait(0.05)
		end
	end
end

local flag = false
restock2.OnClientEvent:Connect(function(options, p)
	local v9 = options or {}
	flag = true

	for _, scrollingFrame in holders:GetChildren() do
		if scrollingFrame:IsA("ScrollingFrame") then
			task.spawn(Restock, scrollingFrame, v9, p)
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