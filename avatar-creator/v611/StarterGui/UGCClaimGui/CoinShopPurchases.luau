local MarketplaceService = game:GetService("MarketplaceService")
local localPlayer = game.Players.LocalPlayer
local CoinProducts = require(game.ReplicatedStorage.CoinProducts)
local coinShopPanel = script.Parent.Panel.CoinShopPanel
local coins = localPlayer:WaitForChild("PlayerGui"):WaitForChild("GamepassStoreGui"):WaitForChild("Root"):WaitForChild("Panel"):WaitForChild("Coins")

-- equivalent calls inferred from this helper; original call sites unknown
local function syncStoreStatus()
	coins.Status.Text = coinShopPanel.Status.Text
end

coinShopPanel.Status:GetPropertyChangedSignal("Text"):Connect(syncStoreStatus)
coinShopPanel.Status.Text = "Choose a pack. Coins are added after Roblox confirms your purchase."
syncStoreStatus() -- equivalent call inferred; original call site unknown
local v = { coinShopPanel, coins }
local v2 = nil

for k, coinProduct in pairs(CoinProducts) do
	local buys = {}

	for _, v3 in v do
		local child = v3.Packs:WaitForChild("Pack" .. coinProduct)
		child:SetAttribute("ProductId", k)
		local buy = child.Buy
		table.insert(buys, buy)
		buy.Text = "Loading…"
		buy.Interactable = false
		local v5 = k
		buy.Activated:Connect(function()
			if v2 or not buy.Interactable then
				return
			end

			v2 = v5
			coinShopPanel.Status.Text = "Complete or cancel your purchase in the Roblox prompt."

			if not pcall(function()
				MarketplaceService:PromptProductPurchase(localPlayer, v5)
			end) then
				v2 = nil
				coinShopPanel.Status.Text = "Could not open the purchase prompt. Please try again."
			end
		end)
	end

	local v3 = k
	task.spawn(function()
		local success, result = pcall(function()
			return MarketplaceService:GetProductInfoAsync(v3, Enum.InfoType.Product)
		end)

		if success then
			if type(result) == "table" then
				success = type(result.PriceInRobux) == "number"
			else
				success = false
			end
		end

		for k2, v5 in buys do
			v5.Text = not success and "Unavailable" or "R$ " .. tostring(result.PriceInRobux) or "Unavailable"
			v5.Interactable = success
		end
	end)
end

MarketplaceService.PromptProductPurchaseFinished:Connect(function(p, p2, p3)
	if p ~= localPlayer.UserId or p2 ~= v2 then
		return
	end

	v2 = nil
	coinShopPanel.Status.Text = p3 and "Roblox is processing your purchase. Your balance updates after confirmation." or "Purchase cancelled."
end)
localPlayer:GetAttributeChangedSignal("Coins"):Connect(function()
	coinShopPanel.Status.Text = "Balance: " .. tostring(localPlayer:GetAttribute("Coins") or 0) .. " coins"
end)
local CoinGiftProducts = require(game.ReplicatedStorage:WaitForChild("CoinGiftProducts"))
local coinGiftRemote = game.ReplicatedStorage:WaitForChild("CoinGiftRemote")
local coinGiftEvent = game.ReplicatedStorage:WaitForChild("CoinGiftEvent")
local playerGui = localPlayer:WaitForChild("PlayerGui")
local CatalogUI = require(game.ReplicatedStorage.CatalogUI)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CoinGiftDialogGui"
screenGui.DisplayOrder = 250
screenGui.ResetOnSpawn = false
screenGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
screenGui.Parent = playerGui
local v3 = CatalogUI.make("TextButton", "Shield", screenGui, {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Text = "",
	AutoButtonColor = false,
	Visible = false,
	Active = true
})
local parent = CatalogUI.make("Frame", "Card", v3, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(430, 470),
	BackgroundColor3 = Color3.fromRGB(25, 29, 39),
	BorderSizePixel = 0,
	Active = true
})
CatalogUI.round(parent, 16)
local uIStroke = Instance.new("UIStroke")
uIStroke.Color = Color3.fromRGB(111, 119, 143)
uIStroke.Thickness = 1
uIStroke.Parent = parent

-- equivalent calls inferred from this helper; original call sites unknown
local function label(p, p2, p3, uDim, uDim2, p4)
	local label2 = CatalogUI.label(p, p2, p3, uDim, uDim2, p4)
	label2.TextColor3 = Color3.fromRGB(242, 245, 252)
	label2.TextWrapped = true
	return label2
end

local label22 = label("Title", parent, "Gift coins", UDim2.fromOffset(18, 12), UDim2.new(1, -86, 0, 36), 23) -- equivalent call inferred; original call site unknown
local button = CatalogUI.button("Close", parent, "×", UDim2.new(1, -60, 0, 10), UDim2.fromOffset(44, 44))
local v6 = CatalogUI.make("ScrollingFrame", "Content", parent, {
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(18, 60),
	Size = UDim2.new(1, -36, 1, -136),
	CanvasSize = UDim2.fromOffset(0, 332),
	ScrollBarThickness = 4,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	Active = true
})
label(
	"HowItWorks",
	v6,
	"Choose a player, pay, and we send it.\nWorks while they're offline, too.",
	UDim2.new(),
	UDim2.new(1, -8, 0, 48),
	15
) -- equivalent call inferred; original call site unknown
local v7 = CatalogUI.make("TextBox", "Username", v6, {
	Position = UDim2.fromOffset(0, 62),
	Size = UDim2.new(1, -104, 0, 46),
	BackgroundColor3 = Color3.fromRGB(43, 49, 63),
	Text = "",
	PlaceholderText = "Roblox username",
	ClearTextOnFocus = false,
	Font = Enum.Font.Gotham,
	TextSize = 16,
	TextColor3 = Color3.new(1, 1, 1)
})
CatalogUI.round(v7, 8)
local button2 = CatalogUI.button("Find", v6, "Find", UDim2.new(1, -94, 0, 62), UDim2.fromOffset(86, 46))
local v8 = CatalogUI.make("ImageLabel", "Avatar", v6, {
	Position = UDim2.fromOffset(0, 126),
	Size = UDim2.fromOffset(64, 64),
	BackgroundColor3 = Color3.fromRGB(41, 47, 62),
	Image = "",
	ScaleType = Enum.ScaleType.Fit
})
CatalogUI.round(v8, 12)
local label23 = label("Recipient", v6, "No recipient selected", UDim2.fromOffset(76, 126), UDim2.new(1, -84, 0, 64), 16) -- equivalent call inferred; original call site unknown
local label24 = label("SavedGifts", v6, "", UDim2.fromOffset(0, 202), UDim2.new(1, -8, 0, 48), 15) -- equivalent call inferred; original call site unknown
label24.TextColor3 = Color3.fromRGB(255, 211, 99)
local label25 = label(
	"Message",
	v6,
	"Enter their exact username, not their display name.",
	UDim2.fromOffset(0, 256),
	UDim2.new(1, -8, 0, 68),
	15
) -- equivalent call inferred; original call site unknown
local button3 = CatalogUI.button(
	"Confirm",
	parent,
	"Find a recipient first",
	UDim2.new(0, 18, 1, -64),
	UDim2.new(1, -36, 0, 48),
	true
)
button3.BackgroundColor3 = Color3.fromRGB(255, 208, 71)
button3.TextColor3 = Color3.fromRGB(24, 28, 38)
button3.TextSize = 16
local label26 = label("GiftNotification", screenGui, "", UDim2.new(0.5, 0, 0, 16), UDim2.fromOffset(420, 90), 16) -- equivalent call inferred; original call site unknown
label26.AnchorPoint = Vector2.new(0.5, 0)
label26.BackgroundTransparency = 0.05
label26.BackgroundColor3 = Color3.fromRGB(29, 37, 50)
label26.Visible = false
CatalogUI.round(label26, 12)
local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function toast(text)
	count += 1
	local v13 = count
	label26.Text = text
	label26.Visible = true
	task.delay(9, function()
		if count == v13 then
			label26.Visible = false
		end
	end)
end

local function layoutGift()
	local absoluteSize = v3.AbsoluteSize
	parent.Size = UDim2.fromOffset(
		math.min(430, (math.max(280, absoluteSize.X - 24))),
		(math.min(470, (math.max(230, absoluteSize.Y - 24))))
	)
	label26.Size = UDim2.fromOffset(math.min(420, (math.max(260, absoluteSize.X - 24))), 90)
end

v3:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutGift)
local ViewportLayoutWatch = require(game.ReplicatedStorage.ViewportLayoutWatch)
ViewportLayoutWatch.Bind(layoutGift)
local productId = nil
local amount = nil
local v15 = nil
local v16 = nil
local checkout = nil
local v17 = {}
local v18 = {}
local flag = false
local count2 = 0
local priceInRobuxes = {}
local v19 = false

local function requestGift(p, options)
	local success, result = pcall(function()
		return coinGiftRemote:InvokeServer(p, options or {})
	end)

	if success and type(result) == "table" then
		return result
	end

	return {
		error = "Connection interrupted. Paid gifts remain saved. Please try again."
	}
end

local function paintGift()
	local v20 = productId and priceInRobuxes[productId]
	button3.Interactable = v15 ~= nil and not (flag or v2) and not checkout and (v16 ~= nil or type(v20) == "number")
	button3.AutoButtonColor = button3.Interactable
	v7.TextEditable = not (flag or checkout)
	button2.Interactable = not (flag or checkout)

	if flag then
		button3.Text = "Please wait..."
	elseif checkout then
		button3.Text = "Waiting for payment confirmation..."
	elseif v15 then
		if v16 then
			button3.Text = "Send saved gift to @" .. v15.username .. "\n" .. amount .. " coins • already paid"
		elseif v20 then
			button3.Text = "Gift to @" .. v15.username .. "\n" .. amount .. " coins • R$ " .. v20
		else
			button3.Text = "Gift price unavailable"
		end
	else
		button3.Text = "Find a recipient first"
	end

	button3.TextScaled = true
	button3.TextWrapped = true
	local uITextSizeConstraint = button3:FindFirstChildOfClass("UITextSizeConstraint") or Instance.new(
		"UITextSizeConstraint",
		button3
	)
	uITextSizeConstraint.MinTextSize = 12
	uITextSizeConstraint.MaxTextSize = 16
end

local now = -1e999
local v20 = false

local function loadSaved()
	if not amount or flag or v20 or os.clock() - now < 2.2 then
		return
	end

	v20 = true
	now = os.clock()
	local v21 = count2
	local v22 = requestGift("Status", {
		amount = amount
	})
	v20 = false

	if v21 ~= count2 then
		return
	end

	if v22.error then
		label25.Text = v22.error
		return
	end

	checkout = nil

	for _, v23 in ipairs(v22.pending or {}) do
		if v23.product ~= productId or v17[v23.id] then
			continue
		end

		checkout = v23
		break
	end

	v16 = nil
	local count3 = 0
	local count4 = 0

	for _, v23 in ipairs(v22.gifts or {}) do
		if v23.state == "ready" then
			count4 += 1
			v16 = v16 or v23
		elseif v23.state == "sending" then
			count3 += 1
		end
	end

	if checkout then
		label24.Text = "Payment pending for @" .. checkout.username .. ". Please do not pay again."
		label25.Text = "The recipient is saved. Coins will send automatically once Roblox confirms payment."
		label23.Text = "@" .. checkout.username .. "\nRecipient locked for payment"

		if checkout.userId then
			v8.Image = "rbxthumb://type=AvatarHeadShot&id=" .. checkout.userId .. "&w=150&h=150"
		end
	else
		label24.Text = count4 > 0 and count4 .. " older paid gift(s) saved. No extra Robux to send." or count3 > 0 and "Your gift is being delivered automatically." or "Your gift sends automatically after verified payment."

		if count4 > 0 then
			label25.Text = "This saved gift has no recipient yet. Choose who should receive it."
		end
	end

	paintGift()
end

local function openGift(p, p2)
	if v2 then
		coinShopPanel.Status.Text = "Finish the current purchase prompt first."
		return
	end

	count2 += 1
	productId = p
	amount = p2
	v15 = nil
	v16 = nil
	checkout = nil
	now = -1e999
	v7.Text = ""
	v8.Image = ""
	label23.Text = "No recipient selected"
	label22.Text = "🎁 Gift " .. p2 .. " coins"
	label25.Text = "Enter their exact username, not their display name."
	v3.Visible = true
	v6.CanvasPosition = Vector2.zero
	layoutGift()
	paintGift()
	task.spawn(loadSaved)
end

button.Activated:Connect(function()
	v3.Visible = false
end)
v7:GetPropertyChangedSignal("Text"):Connect(function()
	v15 = nil
	v8.Image = ""
	label23.Text = "No recipient selected"
	paintGift()
end)
button2.Activated:Connect(function()
	if v19 or flag or checkout then
		return
	end

	v19 = true
	local v21 = count2
	local text = v7.Text
	label25.Text = "Finding Roblox account..."
	local v22 = requestGift("Lookup", {
		username = text
	})
	v19 = false

	if v21 ~= count2 or v7.Text ~= text then
		return
	end

	if v22.error then
		label25.Text = v22.error
		return
	end

	v15 = v22
	v8.Image = "rbxthumb://type=AvatarHeadShot&id=" .. v22.userId .. "&w=150&h=150"
	label23.Text = "@" .. v22.username .. "\nRecipient verified"
	label25.Text = "Check the username above. After payment, coins send automatically to this account."
	paintGift()
end)
button3.Activated:Connect(function()
	if not v15 or flag or v2 or checkout then
		return
	end

	flag = true
	paintGift()
	local v21 = count2
	local v22

	if v16 then
		v22 = requestGift("Send", {
			id = v16.id,
			token = v15.token
		})

		if not v22.error and v22.locked then
			v16 = nil
			label25.Text = v22.message
			v3.Visible = false
			toast(v22.message) -- equivalent call inferred; original call site unknown
		end
	else
		v2 = productId
		v22 = requestGift("Checkout", {
			productId = productId,
			token = v15.token
		})

		if v22.error then
			v2 = nil
		end

		if v21 == count2 and v22.checkout and not v17[v22.checkout.id] then
			checkout = v22.checkout
		end
	end

	flag = false

	if v22.error then
		label25.Text = v22.error
	else
		label25.Text = v22.message or "Gift saved."
	end

	paintGift()
end)

for k, coinGiftProduct in pairs(CoinGiftProducts) do
	for _, v21 in v do
		local child = v21.Packs:WaitForChild("Pack" .. coinGiftProduct)
		child.Buy.Position = UDim2.new(1, -202, 0, 13)
		child.Coins.Size = UDim2.new(1, -292, 0, 26)
		child.Value.Size = UDim2.new(1, -292, 0, 22)
		local button4 = CatalogUI.button("Gift", child, "🎁", UDim2.new(1, -64, 0, 10), UDim2.fromOffset(48, 48), true)
		button4.ZIndex = child.Buy.ZIndex
		button4.TextSize = 26
		button4.BackgroundColor3 = Color3.fromRGB(72, 58, 91)
		button4:SetAttribute("GiftProductId", k)
		local v22 = k
		local v23 = coinGiftProduct
		button4.Activated:Connect(function()
			openGift(v22, v23)
		end)
	end

	local v21 = k
	task.spawn(function()
		local success, result = pcall(function()
			return MarketplaceService:GetProductInfoAsync(v21, Enum.InfoType.Product)
		end)

		if success and type(result.PriceInRobux) == "number" then
			priceInRobuxes[v21] = result.PriceInRobux
		end

		paintGift()
	end)
end

MarketplaceService.PromptProductPurchaseFinished:Connect(function(p, p2, p3)
	if p ~= localPlayer.UserId or not CoinGiftProducts[p2] then
		return
	end

	v2 = nil
	label25.Text = p3 and "Confirming payment. Your gift will send automatically." or "Purchase cancelled. Existing paid gifts stay saved."
	paintGift()
	task.delay(3, loadSaved)
end)
coinGiftEvent.OnClientEvent:Connect(function(p, data)
	if type(data) ~= "table" then
		return
	end

	if p == "Ready" then
		v2 = nil
		coinShopPanel.Status.Text = "An unassigned paid gift is saved. Press 🎁 on that pack to choose its recipient."

		if v3.Visible then
			task.delay(0.4, loadSaved)
			return
		end

		toast("Your " .. data.amount .. "-coin gift is saved. Open Coin Shop → 🎁 to send it.") -- equivalent call inferred; original call site unknown
	elseif p == "Received" then
		toast("🎁 @" .. tostring(data.sender) .. " gifted you " .. tostring(data.amount) .. " coins!") -- equivalent call inferred; original call site unknown
	elseif p == "Processing" then
		if data.checkoutId and v17[data.checkoutId] then
			return
		end

		v2 = nil
		coinShopPanel.Status.Text = "Payment confirmed. Sending " .. data.amount .. " coins to @" .. data.username .. "..."

		if productId == data.product and not (data.checkoutId and v17[data.checkoutId]) then
			label25.Text = coinShopPanel.Status.Text
		end

		if v3.Visible then
			task.delay(0.4, loadSaved)
		end
	elseif p == "Cancelled" then
		if checkout and checkout.id == data.checkoutId then
			checkout = nil
		end

		if productId == data.product then
			v2 = nil
			label25.Text = "Purchase cancelled. No gift was sent."
			paintGift()
			task.delay(3, loadSaved)
		end
	elseif p == "Sent" then
		if v18[data.id] then
			return
		end

		v18[data.id] = true

		if data.checkoutId then
			v17[data.checkoutId] = true
		end

		coinShopPanel.Status.Text = "Gift sent: " .. data.amount .. " coins to @" .. data.username

		if data.checkoutId then
			if v2 == data.product then
				v2 = nil
			end

			if productId == data.product and (not checkout or checkout.id == data.checkoutId) then
				checkout = nil
				v3.Visible = false
			end

			toast("🎁 Sent " .. data.amount .. " coins to @" .. data.username .. "!") -- equivalent call inferred; original call site unknown
			paintGift()
		end
	elseif p == "Saved" then
		coinShopPanel.Status.Text = "You have saved gifts! Press 🎁 beside a coin pack to send them."
		toast("You have saved coin gifts. Open Coin Shop → 🎁 to send them.") -- equivalent call inferred; original call site unknown
	end
end)
task.spawn(function()
	while script.Parent do
		task.wait(5)

		if not v3.Visible or flag then
			continue
		end

		loadSaved()
	end
end)
paintGift()
layoutGift()