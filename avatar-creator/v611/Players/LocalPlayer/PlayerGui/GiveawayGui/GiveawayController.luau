local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local parent = script.Parent
local giveawayRemote = game.ReplicatedStorage:WaitForChild("GiveawayRemote")
local giveawayEvent = game.ReplicatedStorage:WaitForChild("GiveawayEvent")
local uGCClaimGui = playerGui:WaitForChild("UGCClaimGui")
local coinHUD = uGCClaimGui:WaitForChild("CoinHUD")
parent.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
local gamepassStoreGui = playerGui:WaitForChild("GamepassStoreGui")
local frame = playerGui:WaitForChild("ScreenGui"):WaitForChild("Frame")
local frame2 = Instance.new("Frame")
frame2.Name = "LayoutBounds"
frame2.BackgroundTransparency = 1
frame2.Size = UDim2.fromScale(1, 1)
frame2.Parent = parent
parent.DisplayOrder = math.max(parent.DisplayOrder, gamepassStoreGui.DisplayOrder + 1)
local CatalogUI = require(game.ReplicatedStorage.CatalogUI)

-- equivalent calls inferred from this helper; original call sites unknown
local function make(p, p2, p3, p4)
	return CatalogUI.make(p, p2, p3, p4)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function label(p, p2, p3, uDim, uDim2, p4)
	local label2 = CatalogUI.label(p, p2, p3, uDim, uDim2, p4)
	label2.TextColor3 = Color3.fromRGB(244, 246, 252)
	return label2
end

local button = CatalogUI.button("GiveawayButton", frame2, "", UDim2.new(), UDim2.fromOffset(230, 78))
button.BackgroundColor3 = Color3.fromRGB(30, 33, 45)
local uIScale = Instance.new("UIScale", button)
local label22 = label("Title", button, "🎁 Giveaway", UDim2.fromOffset(14, 10), UDim2.new(1, -28, 0, 28), 19) -- equivalent call inferred; original call site unknown
label22.TextColor3 = Color3.fromRGB(255, 211, 99)
local label23 = label("Countdown", button, "250 coins", UDim2.fromOffset(14, 43), UDim2.new(1, -28, 0, 24), 14) -- equivalent call inferred; original call site unknown
local v4 = make("TextButton", "Shade", parent, {
	Text = "",
	AutoButtonColor = false,
	BackgroundColor3 = Color3.new(),
	BackgroundTransparency = 1,
	Size = UDim2.fromScale(1, 1),
	Visible = false,
	Active = true,
	ZIndex = 10
}) -- equivalent call inferred; original call site unknown
local v6 = make("Frame", "Panel", v4, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(500, 450),
	BackgroundColor3 = Color3.fromRGB(25, 29, 39),
	BorderSizePixel = 0,
	Active = true
}) -- equivalent call inferred; original call site unknown
CatalogUI.round(v6, 18)
local uIScale2 = Instance.new("UIScale", v6)
local uDim5 = UDim2.fromOffset(24, 20)
local uDim6 = UDim2.new(1, -88, 0, 28)
local label_2 = CatalogUI.label("Title", v6, "HOURLY GIVEAWAY", uDim5, uDim6, 22)
label_2.TextColor3 = Color3.fromRGB(244, 246, 252)
local button2 = CatalogUI.button("Close", v6, "×", UDim2.new(1, -60, 0, 16), UDim2.fromOffset(40, 36))
local label24 = label("Prize", v6, "Win 250 Coins", UDim2.fromOffset(24, 70), UDim2.new(1, -48, 0, 46), 34) -- equivalent call inferred; original call site unknown
label24.TextColor3 = Color3.fromRGB(255, 211, 99)
local label25 = label("Timer", v6, "Next draw: --:--", UDim2.fromOffset(24, 124), UDim2.new(1, -48, 0, 32), 22) -- equivalent call inferred; original call site unknown
local label26 = label("Entrants", v6, "Loading entries...", UDim2.fromOffset(24, 164), UDim2.new(1, -48, 0, 26), 15) -- equivalent call inferred; original call site unknown
local uDim13 = UDim2.fromOffset(24, 202)
local uDim14 = UDim2.new(1, -48, 0, 52)
local label_3 = CatalogUI.label("Rules", v6, [[
Free entry • One winner across all servers
One entry per account. You can win while offline.]], uDim13, uDim14, 15)
label_3.TextColor3 = Color3.fromRGB(244, 246, 252)
local button3 = CatalogUI.button("Join", v6, "Join Free", UDim2.fromOffset(24, 274), UDim2.new(1, -48, 0, 52), true)
button3.BackgroundColor3 = Color3.fromRGB(67, 106, 204)
local label27 = label("Status", v6, "", UDim2.fromOffset(24, 332), UDim2.new(1, -48, 0, 44), 14) -- equivalent call inferred; original call site unknown
local label28 = label(
	"PreviousWinner",
	v6,
	"Previous winner: awaiting the first draw",
	UDim2.fromOffset(24, 392),
	UDim2.new(1, -48, 0, 36),
	13
) -- equivalent call inferred; original call site unknown
label28.TextColor3 = Color3.fromRGB(189, 197, 214)
local label29 = label("WinnerNotice", parent, "", UDim2.fromScale(0.5, 0.18), UDim2.fromOffset(460, 76), 18) -- equivalent call inferred; original call site unknown
label29.AnchorPoint = Vector2.new(0.5, 0)
label29.BackgroundColor3 = Color3.fromRGB(29, 37, 50)
label29.BackgroundTransparency = 0.05
label29.Visible = false
label29.ZIndex = 20
CatalogUI.round(label29, 14)
local uIScale3 = Instance.new("UIScale", label29)
local v13 = {}
local flag = false
local count = 0
local v14 = {}
local v15 = {}
local GiveawayDockLayout = require(game.ReplicatedStorage.GiveawayDockLayout)

local function at(value)
	local child = playerGui

	for childName in value:gmatch("[^.]+") do
		child = child and child:FindFirstChild(childName)
	end

	return child
end

local function layout()
	local absoluteSize = frame2.AbsoluteSize

	if absoluteSize.X < 1 or absoluteSize.Y < 1 then
		return
	end

	if not localPlayer:GetAttribute("MobileHUDActive") then
		local v16 = math.clamp(absoluteSize.X * 0.42, 156, 230)
		local v17 = 16

		for _, childName in ipairs({ "CatalogButton", "CatelogButton" }) do
			local child = frame:FindFirstChild(childName)

			if child and child.Visible then
				v17 = math.max(v17, child.AbsolutePosition.Y + child.AbsoluteSize.Y - frame2.AbsolutePosition.Y + 20)
			end
		end

		local v18 = math.min(v17, (math.max(12, absoluteSize.Y - 64 - 12)))
		uIScale.Scale = 1
		button.AnchorPoint = Vector2.new(1, 0)
		button.Size = UDim2.fromOffset(v16, 64)
		local v19 = {}

		for _, v20 in {
			"ScreenGui.Frame.CatalogButton",
			"ScreenGui.Frame.CatelogButton",
			"PreferencesGui.SettingsButton",
			"GamepassStoreGui.StoreButton",
			"ScreenGui.CommunityButton",
			"ScreenGui.WearingButton",
			"UGCClaimGui.CoinHUD",
			"LeaderboardGui.LeaderboardButton"
		} do
			local child = playerGui

			for childName in v20:gmatch("[^.]+") do
				child = child and child:FindFirstChild(childName)
			end

			if not (child and child.Visible) then
				continue
			end

			local v21 = child.AbsolutePosition - frame2.AbsolutePosition
			local absoluteSize2 = child.AbsoluteSize
			table.insert(v19, {
				x = v21.X,
				y = v21.Y,
				w = absoluteSize2.X,
				h = absoluteSize2.Y
			})
		end

		local place = GiveawayDockLayout.Place(absoluteSize.X, absoluteSize.Y, v16, 64, v18, v19)

		if place then
			button.Position = UDim2.fromOffset(place.x + v16, place.y)
		else
			button.Position = UDim2.new(1, -16, 0, v18)
		end

		label22.Position = UDim2.fromOffset(12, 6)
		label22.Size = UDim2.new(1, -24, 0, 26)
		label22.TextSize = 17
		label23.Position = UDim2.fromOffset(12, 34)
		label23.Size = UDim2.new(1, -24, 0, 22)
		label23.TextSize = 12
	end

	local MobileCatalogLayout = require(game.ReplicatedStorage.MobileCatalogLayout)

	if not MobileCatalogLayout.IsMobile() then
		uIScale2.Scale = math.min(
			localPlayer:GetAttribute("InterfaceScale") or 1,
			(absoluteSize.X - 24) / 500,
			(absoluteSize.Y - 36) / 450
		)
	end

	uIScale3.Scale = math.min(1, (absoluteSize.X - 24) / 460)
	local v16 = not uGCClaimGui.Enabled or not (coinHUD.Visible or localPlayer:GetAttribute("MobileMenuOpen")) or uGCClaimGui.Panel.Visible or uGCClaimGui.Help.Visible
	local v17 = false

	for _, v18 in { "PreferencesGui.Panel", "EditorToolsGui.Panel", "GamepassPerkControls.Frame" } do
		local child = playerGui

		for childName in v18:gmatch("[^.]+") do
			child = child and child:FindFirstChild(childName)
		end

		local screenGui = child and child:FindFirstAncestorWhichIsA("ScreenGui")

		if child and child.Visible and screenGui and screenGui.Enabled then
			v17 = true
		end
	end

	button.Visible = not (v16 or v17 or localPlayer:GetAttribute("MobileMenuOpen"))

	if v16 then
		v4.Visible = false
	end
end

local function paint()
	local v16 = math.floor(workspace:GetServerTimeNow() / 3600)
	local entered

	if v13.round == v16 then
		entered = v13.entered
	else
		entered = false
	end

	button3.Text = flag and "Please wait..." or entered and "You're entered ✓" or "Join Free"
	button3.Interactable = not flag and not entered and localPlayer:GetAttribute("CoinsReady") == true

	if v13.count ~= nil then
		label26.Text = tostring(v13.count) .. " entrants · updates periodically"
	end

	if v13.lastWinner then
		label28.Text = "Previous winner: @" .. v13.lastWinner.name .. " · 250 coins"
	end
end

local function request(p)
	if flag then
		return
	end

	flag = true
	paint()
	local success, result = pcall(function()
		return giveawayRemote:InvokeServer(p)
	end)
	flag = false

	if success and type(result) == "table" then
		if result.error then
			label27.Text = result.error
		else
			if p == "Join" and result.entered and (v13.round ~= result.round or not v13.entered) then
				v13.count = math.max(1, (v13.count or 0) + 1)
			end

			for k, v16 in pairs(result) do
				v13[k] = v16
			end

			label27.Text = result.message or result.entered and "You're in! Your entry stays valid if you leave." or "Join this hour's free draw."
		end
	else
		label27.Text = "Unable to connect. Please try again."
	end

	paint()
end

button.Activated:Connect(function()
	v4.Visible = not v4.Visible

	if v4.Visible then
		task.spawn(request, "Status")
	end
end)
button2.Activated:Connect(function()
	v4.Visible = false
end)
button3.Activated:Connect(function()
	request("Join")
end)
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.Escape then
		v4.Visible = false
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function notice(text)
	count += 1
	local v16 = count
	label29.Text = text
	label29.Visible = true
	task.delay(8, function()
		if count == v16 then
			label29.Visible = false
		end
	end)
end

giveawayEvent.OnClientEvent:Connect(function(p, lastWinner)
	if type(lastWinner) ~= "table" then
		return
	end

	if p == "Winner" and type(lastWinner.round) == "number" and type(lastWinner.name) == "string" and not v15[lastWinner.round] then
		v15[lastWinner.round] = true

		for k in pairs(v15) do
			if not (k < math.floor(workspace:GetServerTimeNow() / 3600) - 48) then
				continue
			end

			v15[k] = nil
		end

		if not v13.lastWinner or lastWinner.round > v13.lastWinner.round then
			v13.lastWinner = lastWinner
		end

		paint()
		table.insert(v14, "[GLOBAL GIVEAWAY] @" .. lastWinner.name .. " won 250 coins in the hourly giveaway!")
	elseif p == "Prize" then
		notice("🎉 You won the hourly giveaway!\n250 coins have been added to your balance.") -- equivalent call inferred; original call site unknown
	end
end)

local function escape(value)
	return value:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end

task.spawn(function()
	while parent.Parent do
		local serverTimeNow = workspace:GetServerTimeNow()
		local v16 = math.max(0, (math.floor(serverTimeNow / 3600) + 1) * 3600 - serverTimeNow)
		local v17 = string.format("%02d:%02d", math.floor(v16 / 60), (math.floor(v16 % 60)))
		label23.Text = "250 coins · " .. v17
		label25.Text = "Next draw: " .. v17
		paint()
		local textChannels = game.TextChatService:FindFirstChild("TextChannels")
		local rBXGeneral = textChannels and (textChannels:FindFirstChild("RBXGeneral") or textChannels:FindFirstChild("RBXSystem"))

		if rBXGeneral and #v14 > 0 and pcall(function()
			rBXGeneral:DisplaySystemMessage(
				"<font color=\"#FFD36B\">" .. v14[1]:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;") .. "</font>",
				"HourlyGiveaway"
			)
		end) then
			table.remove(v14, 1)
		end

		task.wait(0.5)
	end
end)
task.spawn(function()
	while parent.Parent do
		task.wait(35)

		if v4.Visible then
			request("Status")
		end
	end
end)
localPlayer:GetAttributeChangedSignal("CoinsReady"):Connect(paint)
frame2:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
local RunService = game:GetService("RunService")
RunService:BindToRenderStep("GiveawayDock", Enum.RenderPriority.Last.Value + 5, layout)
layout()
paint()