local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local parent = script.Parent
local panel = parent:WaitForChild("Panel")
local Gamepasses = require(game.ReplicatedStorage.Gamepasses)
local VIP = Gamepasses.VIP
local CatalogUI = require(game.ReplicatedStorage.CatalogUI)
local color = Color3.fromRGB(255, 208, 71)
local button = CatalogUI.button("VIP", panel, "👑 VIP", UDim2.fromOffset(210, 17), UDim2.fromOffset(108, 44), true)
button.ZIndex = 6
button.BackgroundColor3 = color
button.TextColor3 = Color3.fromRGB(30, 27, 22)
button.TextSize = 18
button.Font = Enum.Font.GothamBold
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UGCVIPBenefitsGui"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 251
screenGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
screenGui.Parent = playerGui
local v = CatalogUI.make("TextButton", "Shield", screenGui, {
	Text = "",
	AutoButtonColor = false,
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Visible = false,
	Active = true
})
local parent2 = CatalogUI.make("Frame", "Card", v, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(430, 490),
	BackgroundColor3 = Color3.fromRGB(25, 29, 39),
	BorderSizePixel = 0,
	Active = true
})
CatalogUI.round(parent2, 18)
local uIStroke = Instance.new("UIStroke")
uIStroke.Color = color
uIStroke.Thickness = 1.5
uIStroke.Parent = parent2

-- equivalent calls inferred from this helper; original call sites unknown
local function label(p, p2, p3, uDim, uDim2, p4)
	local label2 = CatalogUI.label(p, p2, p3, uDim, uDim2, p4)
	label2.TextColor3 = Color3.fromRGB(242, 245, 252)
	label2.TextWrapped = true
	return label2
end

local label22 = label("Title", parent2, "👑 VIP BENEFITS", UDim2.fromOffset(18, 12), UDim2.new(1, -82, 0, 36), 23) -- equivalent call inferred; original call site unknown
label22.TextColor3 = color
label22.Font = Enum.Font.GothamBold
local button2 = CatalogUI.button("Close", parent2, "×", UDim2.new(1, -60, 0, 10), UDim2.fromOffset(44, 44))
local v4 = CatalogUI.make("ScrollingFrame", "Benefits", parent2, {
	Position = UDim2.fromOffset(18, 62),
	Size = UDim2.new(1, -36, 1, -140),
	CanvasSize = UDim2.fromOffset(0, 340),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 4,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	Active = true
})
local label23 = label("Multiplier", v4, "1.5× earned coins", UDim2.new(), UDim2.new(1, -8, 0, 32), 22) -- equivalent call inferred; original call site unknown
label23.Font = Enum.Font.GothamBold
label23.TextColor3 = color
label(
	"EarningDetails",
	v4,
	"Earn 50% more coins from playtime and catalog purchases.",
	UDim2.fromOffset(0, 38),
	UDim2.new(1, -8, 0, 54),
	16
) -- equivalent call inferred; original call site unknown
label("ChatTag", v4, "✓ VIP tag in chat", UDim2.fromOffset(0, 104), UDim2.new(1, -8, 0, 34), 18) -- equivalent call inferred; original call site unknown
label("OverheadTag", v4, "✓ VIP badge above your avatar", UDim2.fromOffset(0, 148), UDim2.new(1, -8, 0, 52), 18) -- equivalent call inferred; original call site unknown
label("Permanent", v4, "✓ Permanent, one-time purchase", UDim2.fromOffset(0, 206), UDim2.new(1, -8, 0, 52), 17) -- equivalent call inferred; original call site unknown
local label24 = label(
	"Conditions",
	v4,
	"Coin packs, gifts and fixed bonuses aren't multiplied. UGC still requires coin redemption and available stock.",
	UDim2.fromOffset(0, 268),
	UDim2.new(1, -8, 0, 72),
	14
) -- equivalent call inferred; original call site unknown
label24.TextColor3 = Color3.fromRGB(182, 191, 209)
local button3 = CatalogUI.button(
	"Buy",
	parent2,
	"Loading VIP…",
	UDim2.new(0, 18, 1, -66),
	UDim2.new(1, -36, 0, 48),
	true
)
button3.TextSize = 18
button3.Font = Enum.Font.GothamBold
button3.BackgroundColor3 = color
button3.TextColor3 = Color3.fromRGB(30, 27, 22)
local priceInRobux = nil
local flag = false
local flag2 = false
local v7 = nil

local function paint()
	if localPlayer:GetAttribute("Pass_VIP") == true then
		button3.Text = "✓ VIP Owned"
		button3.Interactable = false
	elseif flag then
		button3.Text = "Waiting for Roblox…"
		button3.Interactable = false
	elseif localPlayer:GetAttribute("PassesReady") and localPlayer:GetAttribute("VIPGiftsReady") and not flag2 then
		if priceInRobux then
			button3.Text = "Buy VIP • R$ " .. priceInRobux
			button3.Interactable = true
		else
			button3.Text = v7 or "VIP unavailable"
			button3.Interactable = false
		end
	else
		button3.Text = "Loading VIP…"
		button3.Interactable = false
	end

	button3.AutoButtonColor = button3.Interactable
end

local function fetch()
	if flag2 then
		return
	end

	flag2 = true
	v7 = nil
	paint()
	local success, result = pcall(function()
		return MarketplaceService:GetProductInfoAsync(VIP.id, Enum.InfoType.GamePass)
	end)

	if success and result.IsForSale and type(result.PriceInRobux) == "number" then
		priceInRobux = result.PriceInRobux
	else
		priceInRobux = nil
		v7 = success and "VIP not for sale" or "Price unavailable — reopen to retry"
	end

	flag2 = false
	paint()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function layout()
	local absoluteSize = v.AbsoluteSize
	parent2.Size = UDim2.fromOffset(
		math.min(430, (math.max(280, absoluteSize.X - 24))),
		(math.min(490, (math.max(230, absoluteSize.Y - 24))))
	)
end

button.Activated:Connect(function()
	v.Visible = true
	v4.CanvasPosition = Vector2.zero
	layout() -- equivalent call inferred; original call site unknown
	paint()

	if not priceInRobux then
		task.spawn(fetch)
	end
end)
button2.Activated:Connect(function()
	v.Visible = false
end)
button3.Activated:Connect(function()
	if flag or localPlayer:GetAttribute("Pass_VIP") or not (priceInRobux and localPlayer:GetAttribute("PassesReady") and localPlayer:GetAttribute("VIPGiftsReady")) then
		return
	end

	flag = true
	paint()

	if not pcall(function()
		MarketplaceService:PromptGamePassPurchase(localPlayer, VIP.id)
	end) then
		flag = false
		priceInRobux = nil
		v7 = "Unable to open — reopen to retry"
		paint()
	end
end)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, p2)
	if p == localPlayer and p2 == VIP.id then
		flag = false
		paint()
	end
end)
localPlayer:GetAttributeChangedSignal("Pass_VIP"):Connect(paint)
localPlayer:GetAttributeChangedSignal("PassesReady"):Connect(paint)
localPlayer:GetAttributeChangedSignal("VIPGiftsReady"):Connect(paint)
v:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
local ViewportLayoutWatch = require(game.ReplicatedStorage.ViewportLayoutWatch)
ViewportLayoutWatch.Bind(layout)

-- equivalent calls inferred from this helper; original call sites unknown
local function visibility()
	button.Visible = panel.Visible and not panel.CoinShopPanel.Visible

	if not (parent.Enabled and panel.Visible) then
		v.Visible = false
	end
end

panel:GetPropertyChangedSignal("Visible"):Connect(visibility)
panel.CoinShopPanel:GetPropertyChangedSignal("Visible"):Connect(visibility)
parent:GetPropertyChangedSignal("Enabled"):Connect(visibility)
visibility() -- equivalent call inferred; original call site unknown
layout() -- equivalent call inferred; original call site unknown
paint()