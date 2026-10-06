local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local parent = script.Parent
parent.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
local frame = Instance.new("Frame")
frame.Name = "SafeArea"
frame.BackgroundTransparency = 1
frame.Size = UDim2.fromScale(1, 1)
frame.Parent = parent
local ResponsiveLayout = require(parent:WaitForChild("ResponsiveLayout"))
local firstVisitTutorialRemote = game.ReplicatedStorage:WaitForChild("FirstVisitTutorialRemote")

local function make(className, items, parent2)
	local instance = Instance.new(className)

	for k, item in pairs(items) do
		instance[k] = item
	end

	instance.Parent = parent2
	return instance
end

local color = Color3.fromRGB(255, 208, 71)
local v = {
	Name = "TourCard",
	Visible = false,
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -16),
	Size = UDim2.fromOffset(520, 230),
	BackgroundColor3 = Color3.fromRGB(25, 29, 39),
	BorderSizePixel = 0,
	Active = true
}
local frame2 = Instance.new("Frame")

for k, v2 in pairs(v) do
	frame2[k] = v2
end

frame2.Parent = frame
local v2 = {
	CornerRadius = UDim.new(0, 18)
}
local uICorner = Instance.new("UICorner")

for k, v3 in pairs(v2) do
	uICorner[k] = v3
end

uICorner.Parent = frame2
local uIStroke = Instance.new("UIStroke")

for k, v3 in pairs({
	Color = color,
	Thickness = 2
}) do
	uIStroke[k] = v3
end

uIStroke.Parent = frame2

local function label(name, uDim, uDim2, text, p3, p4)
	local v3 = {
		Name = name,
		Position = uDim,
		Size = uDim2,
		BackgroundTransparency = 1,
		Text = text,
		Font = p3 or Enum.Font.Gotham,
		TextSize = 17,
		TextColor3 = p4 or Color3.new(1, 1, 1),
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left
	}
	local textLabel = Instance.new("TextLabel")

	for k, v5 in pairs(v3) do
		textLabel[k] = v5
	end

	textLabel.Parent = frame2
	return textLabel
end

local v3 = label("Progress", UDim2.fromOffset(20, 12), UDim2.fromOffset(460, 22), "", Enum.Font.GothamBold, color)
v3.TextSize = 14
local v4 = label("Title", UDim2.fromOffset(20, 39), UDim2.fromOffset(480, 34), "", Enum.Font.GothamBold)
v4.TextSize = 24
local v5 = label("Instructions", UDim2.fromOffset(20, 80), UDim2.fromOffset(480, 85), "")
v5.TextYAlignment = Enum.TextYAlignment.Top
local v6 = {
	Name = "InstructionsScroll",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = color,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	CanvasSize = UDim2.new(),
	Active = true
}
local scrollingFrame = Instance.new("ScrollingFrame")

for k, v7 in pairs(v6) do
	scrollingFrame[k] = v7
end

scrollingFrame.Parent = frame2
v5.Parent = scrollingFrame
v5.Position = UDim2.fromOffset(0, 0)

local function button(name, text, uDim, p3, color2)
	local v7 = {
		Name = name,
		Text = text,
		Position = uDim,
		Size = UDim2.fromOffset(p3, 42),
		BackgroundColor3 = color2,
		TextColor3 = Color3.fromRGB(20, 24, 32),
		Font = Enum.Font.GothamBold,
		TextSize = 17,
		AutoButtonColor = true,
		BorderSizePixel = 0
	}
	local textButton = Instance.new("TextButton")

	for k, v9 in pairs(v7) do
		textButton[k] = v9
	end

	textButton.Parent = frame2
	local v9 = {
		CornerRadius = UDim.new(0, 10)
	}
	local uICorner2 = Instance.new("UICorner")

	for k, v10 in pairs(v9) do
		uICorner2[k] = v10
	end

	uICorner2.Parent = textButton
	return textButton
end

local v7 = button("Skip", "Skip (no reward)", UDim2.fromOffset(20, 174), 204, Color3.fromRGB(183, 191, 205))
local v8 = button("Next", "Next", UDim2.fromOffset(316, 174), 184, color)
local frame3 = Instance.new("Frame")

for k, v9 in pairs({
	Name = "FeatureHighlight",
	Visible = false,
	BackgroundTransparency = 1,
	BorderSizePixel = 0
}) do
	frame3[k] = v9
end

frame3.Parent = frame
local v9 = {
	CornerRadius = UDim.new(0, 12)
}
local uICorner2 = Instance.new("UICorner")

for k, v10 in pairs(v9) do
	uICorner2[k] = v10
end

uICorner2.Parent = frame3
local uIStroke2 = Instance.new("UIStroke")

for k, v10 in pairs({
	Color = color,
	Thickness = 3
}) do
	uIStroke2[k] = v10
end

uIStroke2.Parent = frame3
local v10 = {
	{
		title = "Welcome to Avatar Creator!",
		body = "Discover your new look and learn how to earn free UGC. Complete this quick tour for 10 starter coins! You can skip, but this first-visit offer will not return."
	},
	{
		title = "Create your perfect avatar",
		body = "Open Catalog to browse items and try them on your avatar. Mix different looks before buying anything. Explore whenever you like, then press Next.",
		path = { "ScreenGui", "Frame", "CatalogButton" }
	},
	{
		title = "Explore Community outfits",
		body = "Open Community to discover outfits shared by other players and preview a look you love. Then return to this tour and press Next.",
		path = { "ScreenGui", "CommunityButton" }
	},
	{
		title = "Earn coins as you play",
		body = "Your coin counter grows while you play. Qualifying purchases also earn coins. You can join the free hourly giveaway for a chance to win 250 coins—one winner each hour!",
		path = { "UGCClaimGui", "CoinHUD" }
	},
	{
		title = "Turn your coins into free UGC",
		body = "Open Coin Rewards, choose an item, and save up its listed coin cost. Redeem with coins, then claim the available item. Stock is limited. Finish now to collect your 10 starter coins!",
		path = { "ScreenGui", "Frame", "CatelogButton" }
	}
}

local function relayout()
	local responsiveLayout = ResponsiveLayout(frame.AbsoluteSize, v4.Text, v5.Text)
	frame2.Position = UDim2.new(0.5, 0, 1, -12)
	frame2.Size = UDim2.fromOffset(responsiveLayout.width, responsiveLayout.height)
	v3.Position = UDim2.fromOffset(16, 12)
	v3.Size = UDim2.fromOffset(responsiveLayout.inner, 22)
	v4.Position = UDim2.fromOffset(16, 42)
	v4.Size = UDim2.fromOffset(responsiveLayout.inner, responsiveLayout.titleHeight)
	v4.TextSize = responsiveLayout.titleSize
	scrollingFrame.Position = UDim2.fromOffset(16, responsiveLayout.bodyY)
	scrollingFrame.Size = UDim2.fromOffset(responsiveLayout.inner, responsiveLayout.visibleBody)
	scrollingFrame.CanvasSize = UDim2.fromOffset(0, responsiveLayout.bodyHeight)
	v5.Size = UDim2.fromOffset(responsiveLayout.inner - 12, responsiveLayout.bodyHeight)
	local v12 = not v7.Visible
	local v13 = (responsiveLayout.inner - 12) / 2

	if v12 then
		v8.Position = UDim2.fromOffset(16, responsiveLayout.buttonY)
		v8.Size = UDim2.fromOffset(responsiveLayout.inner, 48)
	elseif responsiveLayout.stacked then
		v8.Position = UDim2.fromOffset(16, responsiveLayout.buttonY)
		v8.Size = UDim2.fromOffset(responsiveLayout.inner, 48)
		v7.Position = UDim2.fromOffset(16, responsiveLayout.buttonY + 56)
		v7.Size = UDim2.fromOffset(responsiveLayout.inner, 48)
	else
		v7.Position = UDim2.fromOffset(16, responsiveLayout.buttonY)
		v7.Size = UDim2.fromOffset(v13, 48)
		v8.Position = UDim2.fromOffset(28 + v13, responsiveLayout.buttonY)
		v8.Size = UDim2.fromOffset(v13, 48)
	end
end

frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(relayout)
v4:GetPropertyChangedSignal("Text"):Connect(relayout)
v5:GetPropertyChangedSignal("Text"):Connect(function()
	scrollingFrame.CanvasPosition = Vector2.zero
	relayout()
end)
v7:GetPropertyChangedSignal("Visible"):Connect(relayout)
local step = 1
local flag = false
local flag2 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function hide()
	flag2 = false
	frame2.Visible = false
	frame3.Visible = false
end

local function show(result)
	if result.status == "active" then
		step = result.step
		local v11 = v10[step]

		if v11 then
			flag2 = true
			frame2.Visible = true
			v3.Text = "TOUR " .. step .. " / " .. #v10 .. "   •   FINISH FOR +10 COINS"
			v4.Text = v11.title
			v5.Text = v11.body
			v8.Text = step == #v10 and "Finish • +10 coins" or "Next →"
		else
			hide() -- equivalent call inferred; original call site unknown
		end
	elseif result.status == "completed" then
		flag2 = false
		frame3.Visible = false
		frame2.Visible = true
		v3.Text = "TUTORIAL COMPLETE"
		v4.Text = "You're ready! +10 coins"
		v5.Text = "Your 10 starter coins have been added. Have fun building your next look!"
		v7.Visible = false
		v8.Text = "Let's play!"
		relayout()
	elseif result.status == "skipped" or result.status == "ineligible" then
		hide() -- equivalent call inferred; original call site unknown
	end
end

local function request(p)
	if flag then
		return
	end

	flag = true
	local success, result = pcall(function()
		return firstVisitTutorialRemote:InvokeServer(p, step)
	end)
	flag = false

	if success and type(result) == "table" then
		if result.status == "error" then
			v5.Text = "Couldn't save right now. Please try again—your reward won't be duplicated."
		elseif result.status ~= "retry" then
			show(result)
		end
	else
		v5.Text = "Connection interrupted. Please try again."
	end
end

v8.Activated:Connect(function()
	if flag2 then
		request("Next")
		return
	end

	hide() -- equivalent call inferred; original call site unknown
end)
v7.Activated:Connect(function()
	request("Skip")
end)
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
	if not workspace.CurrentCamera then
		return
	end

	frame3.Visible = false

	if not flag2 then
		return
	end

	local path = v10[step].path

	if not path then
		return
	end

	local guiObject = playerGui

	for _, childName in ipairs(path) do
		guiObject = guiObject:FindFirstChild(childName)

		if not guiObject then
			return
		end
	end

	if not guiObject:IsA("GuiObject") then
		return
	end

	local parent2 = guiObject

	while parent2 and parent2 ~= playerGui do
		if parent2:IsA("GuiObject") and not parent2.Visible then
			return
		end

		if parent2:IsA("ScreenGui") and not parent2.Enabled then
			return
		else
			parent2 = parent2.Parent
		end
	end

	local v11 = guiObject.AbsolutePosition - frame.AbsolutePosition
	frame3.Position = UDim2.fromOffset(v11.X - 4, v11.Y - 4)
	frame3.Size = UDim2.fromOffset(guiObject.AbsoluteSize.X + 8, guiObject.AbsoluteSize.Y + 8)
	frame3.Visible = true
end)

while localPlayer.Parent and not localPlayer:GetAttribute("TutorialReady") do
	task.wait(0.25)
end

if localPlayer.Parent then
	request("Status")
end