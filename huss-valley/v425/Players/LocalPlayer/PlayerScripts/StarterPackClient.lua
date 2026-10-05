local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local GuiService = game:GetService("GuiService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local StarterPackConfig = require(chickenOrHero.Gear.StarterPackConfig)
local ValleyPanels = require(chickenOrHero.Presentation.ValleyPanels)
local HudNavigation = require(chickenOrHero.Presentation.HudNavigation)
local starterPackEvent = chickenOrHero.Gear:WaitForChild("StarterPackEvent")
local screen = ValleyPanels.screen(localPlayer, "StarterPack", 67)
local connections = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function connect(object, p)
	table.insert(connections, object:Connect(p))
end

local button = ValleyPanels.button(screen, "Open", "", 0, 0, 86, 96, ValleyPanels.Ink)
button.Visible = false
button.AnchorPoint = Vector2.new(1, 0.5)
button.Position = UDim2.new(1, -20, 0.31, 0)
button.BackgroundTransparency = 1
local v = ValleyPanels.make("UIScale", button, "Scale", {})
local v2 = ValleyPanels.make("Frame", button, "SunRays", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(43, 36),
	Size = UDim2.fromOffset(72, 72),
	AnchorPoint = Vector2.new(0.5, 0.5)
})
local flag = true

for i = 1, 12 do
	local v3 = ValleyPanels.make("Frame", v2, "Ray" .. i, {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Rotation = i * 30
	})
	ValleyPanels.make("Frame", v3, "Glow", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0),
		Size = UDim2.fromOffset(10, 28),
		BackgroundColor3 = ValleyPanels.Gold,
		BackgroundTransparency = 0.55,
		BorderSizePixel = 0
	})
	local make = ValleyPanels.make("UIGradient", v3.Glow, "Fade", {
		Rotation = 90
	})
	make.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0.05) })
end

ValleyPanels.make("ImageLabel", button, "PackIcon", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(8, 0),
	Size = UDim2.fromOffset(70, 70),
	Image = "rbxassetid://101428238692962",
	ScaleType = Enum.ScaleType.Fit,
	ZIndex = 3
})
local text = ValleyPanels.text(button, "Timer", "10:00", -13, 74, 112, 22, 15.6, ValleyPanels.Gold)
text.TextXAlignment = Enum.TextXAlignment.Center
text.Font = Enum.Font.GothamBold
ValleyPanels.make("UIStroke", text, "TimerStroke", {
	Color = Color3.fromRGB(10, 18, 26),
	Thickness = 1.5,
	Transparency = 0,
	ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
})
local panel, v3, v4 = ValleyPanels.panel(screen, "Offer", 380, 274)
v4.Position = UDim2.fromOffset(334, 12)
v4.Size = UDim2.fromOffset(32, 30)
v4.TextSize = 22

-- equivalent calls inferred from this helper; original call sites unknown
local function fitOffer()
	local absoluteSize = screen.AbsoluteSize
	v3.Scale.Scale = math.min(1, absoluteSize.X * 0.92 / 380, absoluteSize.Y * 0.88 / 274)
end

connect(screen:GetPropertyChangedSignal("AbsoluteSize"), fitOffer) -- equivalent call inferred; original call site unknown
fitOffer() -- equivalent call inferred; original call site unknown
ValleyPanels.text(v3, "Eyebrow", "YOUR FIRST VALLEY ADVENTURE", 20, 15, 290, 16, 9, ValleyPanels.Gold)
local text_2 = ValleyPanels.text(v3, "Heading", "STARTER PACK", 20, 39, 320, 30, 25, ValleyPanels.Paper)
text_2.Font = Enum.Font.GothamBold
ValleyPanels.text(
	v3,
	"Description",
	"A little help for your first few chases.",
	20,
	74,
	340,
	22,
	13,
	ValleyPanels.Muted
)
local text2 = ValleyPanels.text(v3, "Contents", [[
2 BANANA PEELS
2 RESCUE KITS
2 ADRENALINE CHARGES
+100 COINS]], 20, 105, 340, 88, 17, ValleyPanels.Gold)
text2.Font = Enum.Font.GothamBold
text2.TextXAlignment = Enum.TextXAlignment.Center
local text3 = ValleyPanels.text(v3, "Status", "", 20, 197, 340, 23, 12, ValleyPanels.Muted)
text3.TextXAlignment = Enum.TextXAlignment.Center
local button2 = ValleyPanels.button(v3, "Buy", "CHECKING PRICE", 105, 228, 170, 32, Color3.fromRGB(81, 67, 39))
local v5 = {}
local v6 = nil
local selectedObject = nil
local v7 = false
local v8 = {
	"ArmoryOpen",
	"JourneyOpen",
	"EmoteWheelOpen",
	"SettingsOpen",
	"UpdateLogOpen",
	"ServerBrowserOpen",
	"LikeRewardOpen",
	"MapVoteOpen",
	"MatchSummaryVisible",
	"AdminConsoleActive",
	"ScreenPresentationActive",
	"TutorialRouting",
	"TutorialSession",
	"EventRsvpOpen"
}

local function lobby()
	return localPlayer:GetAttribute("ClientReady") == true and localPlayer:GetAttribute("InMatch") ~= true
end

local v9 = false

-- equivalent calls inferred from this helper; original call sites unknown
local function remaining()
	return (math.max(0, (math.ceil((v5.starterOfferEndsAt or 0) - workspace:GetServerTimeNow()))))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hide()
	panel.Visible = false
	localPlayer:SetAttribute("StarterPackOpen", nil)

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(screen) then
		GuiService.SelectedObject = selectedObject and selectedObject.Parent and selectedObject or nil
	end
end

local function render()
	if not flag then
		return
	end

	local v10 = remaining() -- equivalent call inferred; original call site unknown
	local formatted = ("%d:%02d"):format(math.floor(v10 / 60), v10 % 60)
	text.Text = formatted
	local priceInRobux

	if type(v6) == "table" then
		priceInRobux = v6.PriceInRobux
	else
		priceInRobux = false
	end

	local active

	if type(priceInRobux) == "number" then
		active = priceInRobux >= 0
	else
		active = false
	end

	button2.Text = v5.starterPurchased and "CLAIMED  ✓" or v10 <= 0 and "OFFER ENDED" or v7 and "OPENING…" or active and " " .. priceInRobux or v6 == false and "PRICE UNAVAILABLE" or type(v6) == "table" and "NOT ON SALE" or "CHECKING PRICE"
	local v12 = button2

	if localPlayer:GetAttribute("ClientReady") == true then
		active = localPlayer:GetAttribute("InMatch") ~= true
	else
		active = false
	end

	if active then
		if v5.loaded == true then
			active = not v5.starterPurchased

			if active then
				if v10 > 0 then
					if active then
						if v6.IsForSale == true then
							active = not v7
						else
							active = false
						end
					end
				else
					active = false
				end
			end
		else
			active = false
		end
	end

	v12.Active = active
	button2.AutoButtonColor = button2.Active
	button2.TextTransparency = button2.Active and 0 or 0.35
	text3.Text = v5.starterPurchased and "Your starter pack is in your inventory." or v10 > 0 and "OFFER ENDS IN " .. formatted or "This starter offer has ended."
end

local function show()
	if v5.starterFirstMatch then
		local v10

		if localPlayer:GetAttribute("ClientReady") == true then
			v10 = localPlayer:GetAttribute("InMatch") ~= true
		else
			v10 = false
		end

		if v10 and not (math.max(0, (math.ceil((v5.starterOfferEndsAt or 0) - workspace:GetServerTimeNow()))) <= 0 or v5.starterPurchased) then
			HudNavigation.opening("StarterPack")
			selectedObject = GuiService.SelectedObject
			panel.Visible = true
			localPlayer:SetAttribute("StarterPackOpen", true)
			v9 = true
			starterPackEvent:FireServer("Presented")
			render()
			starterPackEvent:FireServer("Get")

			if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
				GuiService.SelectedObject = button2.Active and button2 or v4
			end

			task.spawn(function()
				local success, productInfoAsync = pcall(
					MarketplaceService.GetProductInfoAsync,
					MarketplaceService,
					StarterPackConfig.ProductId,
					Enum.InfoType.Product
				)

				if flag then
					v6 = success and productInfoAsync or false
					render()
				end
			end)
		end
	end
end

connect(button.Activated, show) -- equivalent call inferred; original call site unknown
connect(v4.Activated, hide) -- equivalent call inferred; original call site unknown
table.insert(connections, button2.Activated:Connect(function()
	if button2.Active then
		v7 = true
		render()
		starterPackEvent:FireServer("Prompt")
	end
end))
table.insert(connections, starterPackEvent.OnClientEvent:Connect(function(p, text4)
	if p == "Notice" then
		v7 = false
		render()
		text3.Text = text4
	end
end))
table.insert(connections, MarketplaceService.PromptProductPurchaseFinished:Connect(function(p, p2)
	if p == localPlayer.UserId and p2 == StarterPackConfig.ProductId then
		v7 = false
		render()
		chickenOrHero.Weapons.ArmoryEvent:FireServer("Get")
	end
end))
table.insert(connections, chickenOrHero.Weapons.ArmoryEvent.OnClientEvent:Connect(function(p, p2)
	if p == "State" then
		v5 = p2
		render()
	end
end))
table.insert(connections, HudNavigation.Opening.Event:Connect(function(p)
	if p ~= "StarterPack" then
		hide() -- equivalent call inferred; original call site unknown
	end
end))
table.insert(connections, UserInputService.InputBegan:Connect(function(input)
	if panel.Visible and (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB) then
		hide() -- equivalent call inferred; original call site unknown
	end
end))
local total = 0
table.insert(connections, RunService.Heartbeat:Connect(function(dt)
	total += dt
	v2.Rotation = (v2.Rotation + dt * 12) % 360

	if total < 0.1 then
		return
	end

	total = 0
	local v10 = false

	for _, attributeName in v8 do
		if not localPlayer:GetAttribute(attributeName) then
			continue
		end

		v10 = true
		break
	end

	if panel.Visible then
		local v12

		if localPlayer:GetAttribute("ClientReady") == true then
			v12 = localPlayer:GetAttribute("InMatch") ~= true
		else
			v12 = false
		end

		if not v12 or v10 then
			hide() -- equivalent call inferred; original call site unknown
		end
	end

	local enabled = StarterPackConfig.Enabled

	if enabled then
		if game.GameId == StarterPackConfig.UniverseId then
			if localPlayer:GetAttribute("ClientReady") == true then
				enabled = localPlayer:GetAttribute("InMatch") ~= true
			else
				enabled = false
			end

			if enabled then
				if v5.loaded == true and v5.starterFirstMatch == true then
					enabled = not v10 and not (panel.Visible or v5.starterPurchased) and math.max(
						0,
						(math.ceil((v5.starterOfferEndsAt or 0) - workspace:GetServerTimeNow()))
					) > 0
				else
					enabled = false
				end
			end
		else
			enabled = false
		end
	end

	button.Visible = enabled and (v9 or v5.starterPresented == true)

	if v5.starterFirstMatch and not v5.starterPresented and not v9 and enabled then
		show()
	end

	fitOffer() -- equivalent call inferred; original call site unknown
	local absoluteSize = screen.AbsoluteSize
	v.Scale = math.clamp(math.min(absoluteSize.X / 1000, absoluteSize.Y / 650), 0.72, 1) * 1.3
	render()
end))
script.Destroying:Connect(function()
	flag = false

	for _, connection in connections do
		connection:Disconnect()
	end

	hide() -- equivalent call inferred; original call site unknown
	screen:Destroy()
end)
starterPackEvent:FireServer("Get")