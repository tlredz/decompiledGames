local BeekeeperShopClient = {}
local localPlayer = game.Players.LocalPlayer
local Client = require(localPlayer.PlayerScripts.Client)
local beekeeper = game.ReplicatedStorage.Shops.Beekeeper
local color = Color3.fromRGB(145, 145, 145)
local color2 = Color3.fromRGB(92, 92, 92)
local color3 = Color3.fromRGB(60, 60, 60)
local color4 = Color3.fromRGB(190, 190, 190)
local color5 = Color3.fromRGB(255, 0, 0)
local v = {
	Spear = "rbxassetid://84118943612724",
	["Rifle Ammo"] = "rbxassetid://72751587263872",
	["Revolver Ammo"] = "rbxassetid://86712479881575",
	["Jar o' Honey"] = "rbxassetid://127069999043804",
	Honeycomb = "rbxassetid://100372952684422",
	["Bee Box Recipe Tablet"] = "rbxassetid://84578183521231",
	["Bee Stinger Spear"] = "rbxassetid://122222219965232",
	["Honey Beenade"] = "rbxassetid://113040547498736"
}
local beekeeper2 = nil
local itemsContent = nil
local template = nil
local textLabel = nil
local textLabel2 = nil
local textLabel3 = nil
local backgroundColor3 = nil
local backgroundColor32 = nil
local color6 = nil
local textColor3 = nil
local textColor32 = nil
local textColor33 = nil
local image = nil
local clonesByInstance = {}
local count = 0

function GetTotalHoney()
	return workspace:GetAttribute("TotalHoney") or 0
end

function UpdateButtonAffordability(p, instance)
	local price = instance:GetAttribute("Price") or 0
	local v2

	if (instance:GetAttribute("Stock") or 0) > 0 then
		v2 = price <= GetTotalHoney()
	else
		v2 = false
	end

	local buyButton_Lower = p.BuyButton_Lower

	if v2 then
		buyButton_Lower.BackgroundColor3 = backgroundColor32
		buyButton_Lower.Upper.BackgroundColor3 = backgroundColor3
		buyButton_Lower.Upper.UIStroke.Color = color6
		buyButton_Lower.Upper.CurrencyCounter.TextLabel.TextColor3 = textColor3
	else
		buyButton_Lower.BackgroundColor3 = color2
		buyButton_Lower.Upper.BackgroundColor3 = color
		buyButton_Lower.Upper.UIStroke.Color = color3
		buyButton_Lower.Upper.CurrencyCounter.TextLabel.TextColor3 = color4
	end
end

function UpdateAllAffordability()
	for k, v2 in pairs(clonesByInstance) do
		UpdateButtonAffordability(v2, k)
	end
end

function UpdateHoneyLabels()
	textLabel.Text = math.floor((GetTotalHoney())) .. " Honey"
	textLabel2.Text = "+" .. (workspace:GetAttribute("TotalHoneyPerMinute") or 0) .. " per minute"
	UpdateAllAffordability()
end

function UpdateTimer()
	local v2 = 2 - ((workspace:GetAttribute("RealDayCounter") or 0) - 1) % 2

	if v2 == 1 then
		textLabel3.Text = "Refreshes in 1 day"
	else
		textLabel3.Text = "Refreshes in " .. v2 .. " days"
	end
end

function FlashHoneyLabel()
	count += 1
	local v2 = count
	task.spawn(function()
		for _ = 1, 3 do
			textLabel.TextColor3 = color5
			task.wait(0.15)

			if count ~= v2 then
				break
			end

			textLabel.TextColor3 = textColor32
			task.wait(0.15)

			if count ~= v2 then
				break
			end
		end
	end)
end

function AttemptBuy(instance)
	if Client.PingClient.PingActive then
		return
	end

	if (instance:GetAttribute("Stock") or 0) <= 0 then
		Client.PopUpUI.AddPopUp("no stock left", "warning")
	elseif (instance:GetAttribute("Price") or 0) > GetTotalHoney() then
		Client.PopUpUI.AddPopUp("not enough Honey", "warning")
		FlashHoneyLabel()
	else
		Client.Events.RequestBuyFromBeekeeper:FireServer(instance)
		Client.Sound.Play("HoneyPurchase", {
			Volume = 0.5,
			Duplicate = true
		})
		Client.PopUpUI.AddPopUp(instance:GetAttribute("Name") .. " purchased!")
	end
end

function UpdateItemButton(instance)
	local name = instance:GetAttribute("Name")

	if name == nil then
		return
	end

	local clone = clonesByInstance[instance]

	if clone == nil then
		clone = template:Clone()
		clone.Name = instance.Name
		local layoutOrder = tonumber(string.match(instance.Name, "%d+$")) or 1

		if instance:GetAttribute("Permanent") then
			clone.LayoutOrder = layoutOrder
		else
			clone.LayoutOrder = 10 + layoutOrder
		end

		clone.BuyButton_Lower.Upper.Activated:Connect(function()
			AttemptBuy(instance)
		end)
		clonesByInstance[instance] = clone
		clone.Parent = itemsContent
	end

	local stock = instance:GetAttribute("Stock") or 0
	clone.ItemName.Text = name
	clone.ItemIconFrame.Icon.Image = v[name] or image
	clone.BuyButton_Lower.Upper.CurrencyCounter.TextLabel.Text = instance:GetAttribute("Price") or 0
	clone.StockCounter.TextLabel.Text = stock .. " Left"

	if stock <= 0 then
		clone.StockCounter.TextLabel.TextColor3 = color5
	else
		clone.StockCounter.TextLabel.TextColor3 = textColor33
	end

	UpdateButtonAffordability(clone, instance)
end

function WatchItemFolder(p)
	UpdateItemButton(p)
	p.AttributeChanged:Connect(function()
		UpdateItemButton(p)
	end)
end

function BeekeeperShopClient.OpenShop()
	beekeeper2.Visible = true
	Client.CompassClient.ShopFound("Beekeeper")
	Client.Sound.Play("BeekeeperShop")
end

function CloseShop()
	beekeeper2.Visible = false
	Client.Sound.Play("CloseButton")
end

function BeekeeperShopClient.Init()
	task.spawn(function()
		beekeeper2 = Client.Interface.Beekeeper
		itemsContent = beekeeper2:WaitForChild("ItemsContent")
		textLabel = beekeeper2.CurrencyCounter.Text.TextLabel
		textLabel2 = beekeeper2.CurrencyCounter.Text.Folder.TextLabel
		textLabel3 = beekeeper2.Timer.Text.TextLabel
		template = itemsContent:FindFirstChild("Template")
		template.Parent = nil

		for _, child in pairs(itemsContent:GetChildren()) do
			if child.Name == "Template" then
				child:Destroy()
			end
		end

		backgroundColor3 = template.BuyButton_Lower.Upper.BackgroundColor3
		backgroundColor32 = template.BuyButton_Lower.BackgroundColor3
		color6 = template.BuyButton_Lower.Upper.UIStroke.Color
		textColor3 = template.BuyButton_Lower.Upper.CurrencyCounter.TextLabel.TextColor3
		textColor32 = textLabel.TextColor3
		textColor33 = template.StockCounter.TextLabel.TextColor3
		image = template.ItemIconFrame.Icon.Image
		beekeeper2.CloseButton.Activated:Connect(CloseShop)

		for _, child in pairs(beekeeper:GetChildren()) do
			WatchItemFolder(child)
		end

		beekeeper.ChildAdded:Connect(WatchItemFolder)
		workspace:GetAttributeChangedSignal("TotalHoney"):Connect(UpdateHoneyLabels)
		workspace:GetAttributeChangedSignal("TotalHoneyPerMinute"):Connect(UpdateHoneyLabels)
		workspace:GetAttributeChangedSignal("RealDayCounter"):Connect(UpdateTimer)
		UpdateHoneyLabels()
		UpdateTimer()
		Client.InteractionHandler.RegisterInteraction("BeekeeperShop", function()
			BeekeeperShopClient.OpenShop()
		end)
	end)
end

return BeekeeperShopClient