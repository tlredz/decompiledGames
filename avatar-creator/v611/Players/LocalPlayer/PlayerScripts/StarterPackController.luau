local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")
local coinHUD = playerGui:WaitForChild("UGCClaimGui"):WaitForChild("CoinHUD")

local function make(className, name, parent, items)
	local instance = Instance.new(className)
	instance.Name = name

	for k, item in items do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

-- equivalent calls inferred from this helper; original call sites unknown
local function round(parent)
	local v = {
		CornerRadius = UDim.new(0, 10)
	}
	local uICorner = Instance.new("UICorner")
	uICorner.Name = "Corner"

	for k, v2 in v do
		uICorner[k] = v2
	end

	uICorner.Parent = parent
end

local function label(frame, name, text, p2, p3, textSize)
	local v = {
		Text = text,
		Position = UDim2.new(0, 16, 0, p2),
		Size = UDim2.new(1, -32, 0, p3),
		BackgroundTransparency = 1,
		TextColor3 = Color3.fromRGB(245, 245, 250),
		TextSize = textSize,
		Font = Enum.Font.GothamMedium,
		TextWrapped = true
	}
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = name

	for k, v2 in v do
		textLabel[k] = v2
	end

	textLabel.Parent = frame
	return textLabel
end

local v = {
	Text = "🎁",
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -2, 0.5, 0),
	Size = UDim2.fromOffset(44, 44),
	BackgroundColor3 = Color3.fromRGB(105, 67, 157),
	TextSize = 25,
	ZIndex = 10,
	Visible = false
}
local textButton = Instance.new("TextButton")
textButton.Name = "StarterPack"

for k, v2 in v do
	textButton[k] = v2
end

textButton.Parent = coinHUD
round(textButton) -- equivalent call inferred; original call site unknown
local v2 = {
	ResetOnSpawn = false,
	DisplayOrder = 260,
	ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "StarterPackGui"

for k, v3 in v2 do
	screenGui[k] = v3
end

screenGui.Parent = playerGui
local v3 = {
	Text = "",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(10, 14, 23),
	BackgroundTransparency = 0.2,
	AutoButtonColor = false,
	Visible = false
}
local textButton2 = Instance.new("TextButton")
textButton2.Name = "Shield"

for k, v4 in v3 do
	textButton2[k] = v4
end

textButton2.Parent = screenGui
local v4 = {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(360, 280),
	BackgroundColor3 = Color3.fromRGB(27, 31, 43),
	BorderSizePixel = 0
}
local frame = Instance.new("Frame")
frame.Name = "Card"

for k, v5 in v4 do
	frame[k] = v5
end

frame.Parent = textButton2
round(frame) -- equivalent call inferred; original call site unknown
label(frame, "Title", "Starter Pack", 12, 36, 24)
local v5 = {
	Text = "×",
	Position = UDim2.new(1, -48, 0, 6),
	Size = UDim2.fromOffset(44, 44),
	BackgroundTransparency = 1,
	TextColor3 = Color3.new(1, 1, 1),
	TextSize = 26
}
local textButton3 = Instance.new("TextButton")
textButton3.Name = "Close"

for k, v6 in v5 do
	textButton3[k] = v6
end

textButton3.Parent = frame
label(frame, "Coins", "150 coins", 60, 44, 30)
label(frame, "Description", "One-time purchase per account.\n150 coins added to your balance.", 110, 48, 15)
local v6 = label(frame, "Status", "", 162, 44, 13)
local v7 = {
	Text = "Loading price…",
	Position = UDim2.new(0, 16, 1, -60),
	Size = UDim2.new(1, -32, 0, 44),
	BackgroundColor3 = Color3.fromRGB(231, 184, 70),
	TextColor3 = Color3.fromRGB(25, 24, 22),
	TextSize = 18,
	Font = Enum.Font.GothamBold
}
local textButton4 = Instance.new("TextButton")
textButton4.Name = "Buy"

for k, v8 in v7 do
	textButton4[k] = v8
end

textButton4.Parent = frame
round(textButton4) -- equivalent call inferred; original call site unknown
local priceInRobux = nil
local flag = false
local v8 = false

local function paint()
	if localPlayer:GetAttribute("StarterPackGranted") then
		textButton4.Text = "Purchased"
		v6.Text = "Your 150 starter coins have been added."
	elseif localPlayer:GetAttribute("StarterPackOwned") then
		textButton4.Text = "Adding coins…"
		v6.Text = "Your purchase is saved. Delivery will retry automatically."
	elseif flag then
		textButton4.Text = "Waiting for Roblox…"
	elseif localPlayer:GetAttribute("StarterPackKnown") then
		if priceInRobux then
			textButton4.Text = "Buy • R$ " .. priceInRobux
		else
			textButton4.Text = v8 and "Loading price…" or "Price unavailable"
		end
	else
		textButton4.Text = "Checking ownership…"
	end

	textButton4.Interactable = priceInRobux ~= nil and localPlayer:GetAttribute("StarterPackKnown") == true and not (localPlayer:GetAttribute("StarterPackOwned") or flag)
end

local function fetch()
	v8 = true
	paint()
	local success, productInfoAsync = pcall(
		MarketplaceService.GetProductInfoAsync,
		MarketplaceService,
		1979900557,
		Enum.InfoType.GamePass
	)
	priceInRobux = success and productInfoAsync.IsForSale and productInfoAsync.PriceInRobux or nil
	v8 = false
	paint()
end

textButton.Activated:Connect(function()
	textButton2.Visible = true
	v6.Text = ""
	task.spawn(fetch)
	paint()
end)
textButton3.Activated:Connect(function()
	textButton2.Visible = false
end)
textButton4.Activated:Connect(function()
	if not textButton4.Interactable then
		return
	end

	flag = true
	paint()

	if not pcall(MarketplaceService.PromptGamePassPurchase, MarketplaceService, localPlayer, 1979900557) then
		flag = false
		v6.Text = "Unable to open Roblox. Please try again."
		paint()
	end
end)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, p2)
	if p == localPlayer and p2 == 1979900557 then
		flag = false
		paint()
	end
end)

for _, v9 in { "StarterPackKnown", "StarterPackOwned", "StarterPackGranted" } do
	localPlayer:GetAttributeChangedSignal(v9):Connect(paint)
end

local v9 = {}
RunService:BindToRenderStep("StarterPackLayout", Enum.RenderPriority.Last.Value + 20, function()
	local visible

	if localPlayer:GetAttribute("StarterPackKnown") == true then
		visible = not localPlayer:GetAttribute("StarterPackGranted")
	else
		visible = false
	end

	textButton.Visible = visible
	local mobileHUDActive = localPlayer:GetAttribute("MobileHUDActive")

	for _, childName in { "Balance", "Timer" } do
		local child = coinHUD:FindFirstChild(childName)

		if not child then
			continue
		end

		if not v9[child] then
			v9[child] = {
				size = child.Size,
				visible = child.Visible
			}
		end

		if visible then
			if childName == "Timer" and mobileHUDActive then
				child.Visible = false
			else
				child.Visible = v9[child].visible
				child.Size = UDim2.new(
					1,
					-(childName == "Balance" and 84 or 54),
					child.Size.Y.Scale,
					child.Size.Y.Offset
				)
			end
		else
			if not mobileHUDActive then
				child.Size = v9[child].size
			end

			child.Visible = v9[child].visible
		end
	end

	local absoluteSize = screenGui.AbsoluteSize
	frame.Size = UDim2.fromOffset(math.min(360, absoluteSize.X - 24), (math.min(280, absoluteSize.Y - 16)))
end)
paint()