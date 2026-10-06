local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local CatalogUI = require(ReplicatedStorage.CatalogUI)
local vIPGiftRemote = ReplicatedStorage:WaitForChild("VIPGiftRemote")
local vIPGiftEvent = ReplicatedStorage:WaitForChild("VIPGiftEvent")
local giftVIP = script.Parent.Root.Panel.Packs.VIP:WaitForChild("GiftVIP")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VIPGiftDialogGui"
screenGui.DisplayOrder = 252
screenGui.ResetOnSpawn = false
screenGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
screenGui.Parent = playerGui
local v = CatalogUI.make("TextButton", "Shield", screenGui, {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Text = "",
	AutoButtonColor = false,
	Visible = false,
	Active = true
})
local v2 = CatalogUI.make("Frame", "Card", v, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(430, 470),
	BackgroundColor3 = CatalogUI.colors.bg,
	BorderSizePixel = 0,
	Active = true
})
CatalogUI.round(v2, 16)
local uIStroke = Instance.new("UIStroke", v2)
uIStroke.Color = Color3.fromRGB(111, 119, 143)
uIStroke.Thickness = 1
local label_2 = CatalogUI.label("Title", v2, "Gift VIP", UDim2.fromOffset(18, 12), UDim2.new(1, -86, 0, 36), 23)
label_2.TextColor3 = Color3.fromRGB(255, 211, 99)
local button = CatalogUI.button("Close", v2, "×", UDim2.new(1, -60, 0, 10), UDim2.fromOffset(44, 44))
local v3 = CatalogUI.make("ScrollingFrame", "Content", v2, {
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Position = UDim2.fromOffset(18, 60),
	Size = UDim2.new(1, -36, 1, -136),
	CanvasSize = UDim2.fromOffset(0, 348),
	ScrollBarThickness = 4,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	Active = true
})
CatalogUI.label(
	"HowItWorks",
	v3,
	"Give permanent VIP: chat tag, VIP badge, and 1.5× earned coins. Works while they're offline, too.",
	UDim2.new(),
	UDim2.new(1, -8, 0, 62),
	15
)
local input = CatalogUI.input("Username", v3, "Roblox username", UDim2.fromOffset(0, 76), UDim2.new(1, -104, 0, 46))
local button2 = CatalogUI.button("Find", v3, "Find", UDim2.new(1, -94, 0, 76), UDim2.fromOffset(86, 46))
local v4 = CatalogUI.make("ImageLabel", "Avatar", v3, {
	Position = UDim2.fromOffset(0, 140),
	Size = UDim2.fromOffset(64, 64),
	BackgroundColor3 = CatalogUI.colors.raised,
	Image = "",
	ScaleType = Enum.ScaleType.Fit
})
CatalogUI.round(v4, 12)
local label = CatalogUI.label(
	"Recipient",
	v3,
	"No recipient selected",
	UDim2.fromOffset(76, 140),
	UDim2.new(1, -84, 0, 64),
	16
)
local label2 = CatalogUI.label("SavedGifts", v3, "", UDim2.fromOffset(0, 216), UDim2.new(1, -8, 0, 48), 14)
label2.TextColor3 = Color3.fromRGB(255, 211, 99)
local label3 = CatalogUI.label(
	"Message",
	v3,
	"Enter their exact username, not their display name.",
	UDim2.fromOffset(0, 270),
	UDim2.new(1, -8, 0, 72),
	14
)
local button3 = CatalogUI.button(
	"Confirm",
	v2,
	"Find a recipient first",
	UDim2.new(0, 18, 1, -64),
	UDim2.new(1, -36, 0, 48),
	true
)
button3.BackgroundColor3 = Color3.fromRGB(255, 208, 71)
button3.TextColor3 = Color3.fromRGB(24, 28, 38)
button3.TextScaled = true
button3.TextWrapped = true
local uITextSizeConstraint = Instance.new("UITextSizeConstraint", button3)
uITextSizeConstraint.MinTextSize = 12
uITextSizeConstraint.MaxTextSize = 16
local label4 = CatalogUI.label("Notification", screenGui, "", UDim2.new(0.5, 0, 0, 16), UDim2.fromOffset(420, 90), 16)
label4.AnchorPoint = Vector2.new(0.5, 0)
label4.BackgroundTransparency = 0.05
label4.BackgroundColor3 = CatalogUI.colors.bg
label4.Visible = false
CatalogUI.round(label4, 12)
local count = 0

-- equivalent calls inferred from this helper; original call sites unknown
local function toast(text)
	count += 1
	local v5 = count
	label4.Text = text
	label4.Visible = true
	task.delay(9, function()
		if v5 == count then
			label4.Visible = false
		end
	end)
end

local function layout()
	local absoluteSize = v.AbsoluteSize
	v2.Size = UDim2.fromOffset(
		math.min(430, (math.max(280, absoluteSize.X - 24))),
		(math.min(470, (math.max(230, absoluteSize.Y - 24))))
	)
	label4.Size = UDim2.fromOffset(math.min(420, (math.max(260, absoluteSize.X - 24))), 90)
end

v:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
local ViewportLayoutWatch = require(ReplicatedStorage.ViewportLayoutWatch)
ViewportLayoutWatch.Bind(layout)
local v5 = nil
local v6 = nil
local checkout = nil
local priceInRobux = nil
local flag = false
local v7 = false
local v8 = false
local flag2 = false
local count2 = 0
local now = -1e999
local v9 = {}
local v10 = {}

local function request(p, options)
	local success, result = pcall(function()
		return vIPGiftRemote:InvokeServer(p, options or {})
	end)
	return (not success or type(result) ~= "table" or not result) and {
		error = "Connection interrupted. Paid gifts stay saved. Please try again."
	} or result
end

local function paint()
	button3.Interactable = v5 ~= nil and flag2 and not flag and not checkout and (v6 ~= nil or priceInRobux ~= nil)
	input.TextEditable = not (flag or checkout)
	button2.Interactable = not (flag or checkout or v7)

	if flag then
		button3.Text = "Please wait..."
	elseif checkout then
		button3.Text = checkout.delivering and "Delivering VIP..." or "Waiting for payment confirmation..."
	elseif flag2 then
		if v5 then
			if v6 then
				button3.Text = "Send saved VIP to @" .. v5.username .. "\nAlready paid"
			elseif priceInRobux then
				button3.Text = "Gift VIP to @" .. v5.username .. "\nR$ " .. priceInRobux
			else
				button3.Text = "VIP gift price unavailable"
			end
		else
			button3.Text = "Find a recipient first"
		end
	else
		button3.Text = "Checking saved gifts..."
	end

	button3.AutoButtonColor = button3.Interactable
end

local function status()
	if v8 or flag or os.clock() - now < 2.2 then
		return
	end

	v8 = true
	now = os.clock()
	local v11 = count2
	local v12 = request("Status", {})
	v8 = false

	if v11 ~= count2 then
		return
	end

	if v12.error then
		flag2 = false
		label3.Text = v12.error
	else
		checkout = nil
		v6 = nil

		for _, v13 in ipairs(v12.pending or {}) do
			if v9[v13.id] then
				continue
			end

			checkout = v13
			break
		end

		for _, v13 in ipairs(v12.gifts or {}) do
			if v13.state == "ready" then
				v6 = v6 or v13
			elseif v13.state == "sending" and not checkout then
				checkout = {
					username = v13.username,
					delivering = true
				}
			end
		end

		flag2 = true

		if checkout then
			label2.Text = checkout.delivering and "Delivering VIP to @" .. checkout.username .. "." or "Payment pending for @" .. checkout.username .. "."
			label.Text = "@" .. checkout.username .. "\nRecipient saved"

			if checkout.userId then
				v4.Image = "rbxthumb://type=AvatarHeadShot&id=" .. checkout.userId .. "&w=150&h=150"
			end
		elseif v6 then
			label2.Text = "You have a paid VIP gift ready to send."
			label3.Text = v6.previousTarget and "The previous recipient already has VIP. Find another player to send this paid gift." or "Find the player who should receive your saved VIP gift."
		else
			label2.Text = "VIP is delivered automatically after confirmed payment."
		end
	end

	paint()
end

local function open()
	if flag then
		return
	end

	count2 += 1
	v5 = nil
	v6 = nil
	checkout = nil
	flag2 = false
	now = -1e999
	input.Text = ""
	v4.Image = ""
	label.Text = "No recipient selected"
	label2.Text = "Checking saved gifts..."
	label3.Text = "Enter their exact username, not their display name."
	v.Visible = true
	v3.CanvasPosition = Vector2.zero
	layout()
	paint()
	task.spawn(status)
end

giftVIP.Activated:Connect(open)
button.Activated:Connect(function()
	v.Visible = false
end)
input:GetPropertyChangedSignal("Text"):Connect(function()
	v5 = nil
	v4.Image = ""
	label.Text = "No recipient selected"
	paint()
end)
button2.Activated:Connect(function()
	if flag or checkout or v7 then
		return
	end

	v7 = true
	paint()
	local v11 = count2
	local text = input.Text
	label3.Text = "Checking the player and their VIP status..."
	local v12 = request("Lookup", {
		username = text
	})
	v7 = false

	if v11 ~= count2 or text ~= input.Text then
		paint()
		return
	end

	if v12.error then
		label3.Text = v12.error
	else
		v5 = v12
		v4.Image = "rbxthumb://type=AvatarHeadShot&id=" .. v12.userId .. "&w=150&h=150"
		label.Text = "@" .. v12.username .. "\nReady to receive VIP"
		label3.Text = "Check the username above. This player receives permanent VIP after payment."
	end

	paint()
end)
button3.Activated:Connect(function()
	if not button3.Interactable or not v5 or flag or checkout then
		return
	end

	flag = true
	paint()
	local v11 = count2
	local v12

	if v6 then
		v12 = request("Send", {
			id = v6.id,
			token = v5.token
		})

		if not v12.error and v12.locked then
			v6 = nil
			v.Visible = false
			toast(v12.message) -- equivalent call inferred; original call site unknown
		end
	else
		v12 = request("Checkout", {
			productId = 3712812482,
			token = v5.token
		})

		if v11 == count2 and v12.checkout and not v9[v12.checkout.id] then
			checkout = v12.checkout
		end
	end

	flag = false

	if v11 == count2 then
		label3.Text = v12.error or v12.message or "Gift saved."

		if v12.error then
			flag2 = false
		end

		paint()
		task.delay(2.3, status)
	end
end)
MarketplaceService.PromptProductPurchaseFinished:Connect(function(p, p2, p3)
	if p ~= localPlayer.UserId or p2 ~= 3712812482 then
		return
	end

	flag2 = false
	label3.Text = p3 and "Confirming payment. VIP will be delivered automatically." or "Purchase cancelled. Existing paid gifts stay saved."
	paint()
	task.delay(3, status)
end)
vIPGiftEvent.OnClientEvent:Connect(function(p, data)
	if type(data) ~= "table" then
		return
	end

	if p == "Received" then
		if v10[data.id] then
			return
		end

		v10[data.id] = true
		toast("@" .. tostring(data.sender) .. " gifted you permanent VIP!") -- equivalent call inferred; original call site unknown
	elseif p == "Sent" then
		if v10[data.id] then
			return
		end

		v10[data.id] = true

		if data.checkoutId then
			v9[data.checkoutId] = true
		end

		checkout = nil
		flag2 = false
		v.Visible = false
		toast("VIP sent to @" .. tostring(data.username) .. "!") -- equivalent call inferred; original call site unknown
	elseif p == "Ready" then
		if data.checkoutId then
			v9[data.checkoutId] = true
		end

		checkout = nil
		v5 = nil
		flag2 = false
		label3.Text = data.reason or "Your paid VIP gift is saved. Find a recipient to send it."

		if not v.Visible then
			toast(label3.Text) -- equivalent call inferred; original call site unknown
		end

		task.delay(0.4, status)
	elseif p == "Processing" then
		if data.checkoutId and v9[data.checkoutId] then
			return
		end

		checkout = {
			id = data.checkoutId,
			username = data.username,
			delivering = true
		}
		label3.Text = "Payment confirmed. Delivering VIP to @" .. tostring(data.username) .. "..."
	elseif p == "Cancelled" then
		if checkout and checkout.id == data.checkoutId then
			checkout = nil
		end

		flag2 = false
		label3.Text = "Purchase cancelled. No VIP gift was sent."
		task.delay(3, status)
	elseif p == "Saved" then
		toast("You have a paid VIP gift saved. Open Store → Gamepasses → Gift VIP.") -- equivalent call inferred; original call site unknown
	end

	paint()
end)
task.spawn(function()
	local success, result = pcall(function()
		return MarketplaceService:GetProductInfoAsync(3712812482, Enum.InfoType.Product)
	end)

	if success and type(result) == "table" and type(result.PriceInRobux) == "number" and result.IsForSale ~= false then
		priceInRobux = result.PriceInRobux
	end

	paint()
end)
task.spawn(function()
	while script.Parent do
		task.wait(5)

		if v.Visible then
			status()
		end
	end
end)
paint()
layout()