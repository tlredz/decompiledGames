local createVector = vector.create
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local localPlayer = Players.LocalPlayer
local chickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local JourneyConfig = require(chickenOrHero.Progression:WaitForChild("JourneyConfig"))
local JourneyMath = require(chickenOrHero.Progression:WaitForChild("JourneyMath"))
local SkinCatalog = require(chickenOrHero.Weapons:WaitForChild("SkinCatalog"))
local ValleyPanels = require(chickenOrHero.Presentation:WaitForChild("ValleyPanels"))
local ValleyTheme = require(chickenOrHero.Presentation:WaitForChild("ValleyTheme"))
local HudNavigation = require(chickenOrHero.Presentation:WaitForChild("HudNavigation"))
local journeyEvent = chickenOrHero.Progression:WaitForChild("JourneyEvent")
local screen = ValleyPanels.screen(localPlayer, "ValleyJourney", 67)
screen.IgnoreGuiInset = true
screen.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
local v = ValleyPanels.make("Frame", screen, "Shade", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = ValleyPanels.Ink,
	BackgroundTransparency = 0.38,
	BorderSizePixel = 0,
	Visible = false,
	Active = false
})
ValleyPanels.fullscreenShade(screen, v)
local v2 = ValleyPanels.make("Frame", v, "Journal", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	BackgroundColor3 = ValleyPanels.Ink,
	BackgroundTransparency = 0.08,
	BorderSizePixel = 0
})
ValleyTheme.surface(v2, ValleyPanels.Ink, ValleyPanels.Gold, 10, 0.62)

-- equivalent calls inferred from this helper; original call sites unknown
local function label(p, p2, p3, p4, p5)
	local text = ValleyPanels.text(p, p2, p3, 0, 0, 100, 20, p4, p5)
	text.TextWrapped = false
	text.TextTruncate = Enum.TextTruncate.AtEnd
	return text
end

local text2 = label(
	v2,
	"Edition",
	"SEASON " .. JourneyConfig.SeasonNumber .. "  /  " .. JourneyConfig.SeasonName,
	12,
	ValleyPanels.Gold
) -- equivalent call inferred; original call site unknown
local text3 = label(v2, "Heading", "VALLEY JOURNEY", 28, nil) -- equivalent call inferred; original call site unknown
text3.Font = Enum.Font.GothamBold
local button = ValleyPanels.button(v2, "Close", "×", 0, 0, 40, 40)
button.Modal = true
button.TextSize = 24
local text4 = label(v2, "Tier", "TIER 1 / " .. JourneyConfig.MaxTier, 14, ValleyPanels.Gold) -- equivalent call inferred; original call site unknown
text4.Font = Enum.Font.GothamBold
local text5 = label(v2, "XP", "Earn XP by playing matches", 12, ValleyPanels.Muted) -- equivalent call inferred; original call site unknown
local v9 = ValleyPanels.make("Frame", v2, "Progress", {
	BackgroundColor3 = Color3.fromRGB(39, 57, 68),
	BorderSizePixel = 0
})
ValleyPanels.corner(v9, 3)
local v10 = ValleyPanels.make("Frame", v9, "Fill", {
	Size = UDim2.fromScale(0, 1),
	BackgroundColor3 = ValleyPanels.Gold,
	BorderSizePixel = 0
})
ValleyPanels.corner(v10, 3)
local button2 = ValleyPanels.button(v2, "TrackTab", "REWARDS", 0, 0, 110, 32)
local button3 = ValleyPanels.button(v2, "BadgesTab", "MY TITLES", 0, 0, 110, 32)
local button4 = ValleyPanels.button(v2, "Lane", "FREE  ⇄", 0, 0, 116, 32, Color3.fromRGB(43, 53, 70))
local v11 = ValleyPanels.make("ScrollingFrame", v2, "Track", {
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Active = true,
	CanvasSize = UDim2.new(),
	ScrollingDirection = Enum.ScrollingDirection.X,
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = ValleyPanels.Gold,
	ClipsDescendants = true
})
local v12 = ValleyPanels.make("ScrollingFrame", v2, "Badges", {
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Active = true,
	Visible = false,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollingDirection = Enum.ScrollingDirection.Y,
	ScrollBarThickness = 4,
	ClipsDescendants = true
})
local v13 = ValleyPanels.make("UIGridLayout", v12, "Grid", {
	CellSize = UDim2.fromOffset(190, 112),
	CellPadding = UDim2.fromOffset(10, 10),
	SortOrder = Enum.SortOrder.LayoutOrder
})
local button5 = ValleyPanels.button(v2, "ClaimAll", "CLAIM ALL", 0, 0, 220, 42, Color3.fromRGB(61, 99, 88))
local button6 = ValleyPanels.button(v2, "Premium", "CHECKING PREMIUM…", 0, 0, 280, 42, Color3.fromRGB(69, 51, 93))
local text6 = label(
	v2,
	"Policy",
	"Season progress restarts next season. Player level and earned items stay.",
	11,
	ValleyPanels.Muted
) -- equivalent call inferred; original call site unknown
local text7 = label(v2, "Notice", "One claim collects every unlocked reward. Swipe the track →", 12, ValleyPanels.Muted) -- equivalent call inferred; original call site unknown
local v16 = {
	loaded = false,
	tier = 1,
	xp = 0,
	claims = 0,
	badges = 0,
	premium = false
}
v16.claims = {}
v16.badges = {}
local v17 = {}
local buttons = {}
local v18 = false
local selectedObject = nil
local v19 = nil
local v20 = false
local v21 = "Free"
local flag = false
local v22 = nil

local function complete(data)
	return v16.claims[JourneyConfig.TrackId .. ":" .. data.Key] == true and (not data.EmoteId or (v16.emotes or {})[data.EmoteId] == true) and (not data.SkinId or (v16.skins or {})[data.SkinId] == true)
end

local function rewardText(data)
	local v23 = {}

	if data.SkinId then
		local v24 = SkinCatalog.get(data.SkinId)
		table.insert(v23, v24 and v24.Name or "EXCLUSIVE DAGGER")
	elseif data.KnifeSlot then
		table.insert(v23, "DAGGER SLOT · COMING LATER")
	end

	if data.Badge and JourneyConfig.Badges[data.Badge] then
		table.insert(v23, JourneyConfig.Badges[data.Badge].Name)
	end

	local v24 = {}

	if (data.Gems or 0) > 0 then
		table.insert(v24, "◆ " .. data.Gems .. " GEMS")
	end

	if (data.Coins or 0) > 0 then
		table.insert(v24, "◉ " .. data.Coins .. " COINS")
	end

	if #v24 > 0 then
		table.insert(v23, table.concat(v24, "  ·  "))
	end

	return table.concat(v23, "\n")
end

local fn

local function claim(p, p2)
	if flag or not v16.loaded then
		return
	end

	flag = true
	text7.Text = "Saving your rewards…"
	fn()
	journeyEvent:FireServer(p, p2, JourneyConfig.SeasonId)
	task.delay(10, function()
		if flag then
			flag = false
			text7.Text = "Still waiting for confirmation. You can retry safely."
			fn()
		end
	end)
end

for k, reward in JourneyConfig.Rewards do
	local column = ValleyPanels.make("Frame", v11, "Tier" .. k, {
		BackgroundTransparency = 1
	})
	local number = label(column, "Tier", "TIER " .. k, 12, ValleyPanels.Gold) -- equivalent call inferred; original call site unknown
	number.Font = Enum.Font.GothamBold

	for _, lane in { "Free", "Premium" } do
		local reward2 = reward[lane]

		if not reward2 then
			continue
		end

		local card = ValleyPanels.make("Frame", column, lane, {
			BackgroundTransparency = 0.22,
			BorderSizePixel = 0
		})
		local blue = lane == "Free" and ValleyPanels.Blue or ValleyPanels.Purple
		ValleyTheme.surface(card, ValleyPanels.Ink:Lerp(blue, 0.1), blue, 7, 0.72)
		local route = label(card, "Route", lane:upper(), 10, blue) -- equivalent call inferred; original call site unknown
		local text = ValleyPanels.text(card, "Reward", rewardText(reward2), 12, 29, 172, 52, 12)
		text.Font = Enum.Font.GothamBold
		local v30

		if reward2.SkinId then
			v30 = ValleyPanels.make("ViewportFrame", card, "RewardArt", {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Ambient = Color3.fromRGB(210, 210, 218),
				LightColor = Color3.fromRGB(255, 245, 227),
				LightDirection = createVector(-1, -1, -1)
			})
			local models = chickenOrHero.Weapons:FindFirstChild("Models")
			local model = models and models:FindFirstChild(reward2.SkinId)

			if model and model:IsA("Model") then
				local clone = model:Clone()

				for _, descendant in clone:GetDescendants() do
					if descendant:IsA("LuaSourceContainer") or descendant:IsA("Sound") or descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") or descendant:IsA("Light") then
						descendant:Destroy()
					elseif descendant:IsA("BasePart") then
						if descendant.Transparency >= 0.99 or descendant.Name:find("Stowed", 1, true) then
							descendant:Destroy()
						else
							descendant.Anchored = true
						end
					end
				end

				clone.Parent = v30
				local boundingBox, v31 = clone:GetBoundingBox()
				local camera = Instance.new("Camera")
				camera.FieldOfView = 35
				camera.CFrame = CFrame.lookAt(
					boundingBox.Position + (createVector(0.5, 0.25, 1)).Unit * math.max(1, v31.Magnitude) * 1.35,
					boundingBox.Position
				)
				camera.Parent = v30
				v30.CurrentCamera = camera
			end
		else
			local v31 = reward2.Badge and "✦" or reward2.KnifeSlot and "?" or "◆"
			v30 = ValleyPanels.text(card, "RewardArt", v31, 0, 0, 100, 20, 34, blue)
			v30.TextWrapped = false
			v30.TextTruncate = Enum.TextTruncate.AtEnd
			v30.Font = Enum.Font.GothamBold
			v30.TextXAlignment = Enum.TextXAlignment.Center
		end

		local button7 = ValleyPanels.button(card, "Claim", "LOCKED", 10, 88, 180, 32)
		button7.TextSize = 11
		v17[reward2.Key] = {
			button = button7,
			reward = reward2,
			tier = k,
			lane = lane,
			column = column,
			card = card,
			number = number,
			label = text,
			route = route,
			art = v30
		}
		button7.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
				v22 = {
					input = input,
					button = button7,
					position = Vector2.new(input.Position.X, input.Position.Y),
					canvas = v11.CanvasPosition
				}
			end
		end)
		local button8 = button7
		local reward3 = reward2
		button7.Activated:Connect(function(p)
			if not button8.Active then
				return
			end

			if p and (p.UserInputType == Enum.UserInputType.Touch or p.UserInputType == Enum.UserInputType.MouseButton1) and v22 and v22.button == button8 and (v22.dragged or (v11.CanvasPosition - v22.canvas).Magnitude > 6) then
				return
			end

			claim("Claim", reward3.Key)
		end)
	end
end

UserInputService.InputChanged:Connect(function(input)
	if v22 and (input == v22.input or input.UserInputType == Enum.UserInputType.MouseMovement) and (Vector2.new(
		input.Position.X,
		input.Position.Y
	) - v22.position).Magnitude > 10 then
		v22.dragged = true
	end
end)
local v23 = {}

for k in JourneyConfig.Badges do
	table.insert(v23, k)
end

table.sort(v23)

for k, v24 in v23 do
	local badge = JourneyConfig.Badges[v24]
	local v25 = ValleyPanels.make("Frame", v12, v24, {
		BackgroundColor3 = ValleyPanels.Ink:Lerp(badge.Color, 0.1),
		BorderSizePixel = 0,
		LayoutOrder = k
	})
	ValleyPanels.corner(v25, 7)
	local text = ValleyPanels.text(v25, "Title", badge.Icon .. "  " .. badge.Name, 12, 10, 160, 40, 13, badge.Color)
	text.Font = Enum.Font.GothamBold
	text.Size = UDim2.new(1, -24, 0, 40)
	local button7 = ValleyPanels.button(v25, "Equip", "LOCKED", 12, 64, 160, 34)
	button7.Size = UDim2.new(1, -24, 0, 34)
	button7.TextSize = 11
	buttons[v24] = button7
	local v27 = v24
	button7.Activated:Connect(function()
		if button7.Active then
			journeyEvent:FireServer("EquipBadge", v16.badge == v27 and "" or v27)
		end
	end)
end

fn = function()
	local state = JourneyMath.state(v16.xp, JourneyConfig)
	text4.Text = "TIER " .. state.tier .. " / " .. JourneyConfig.MaxTier
	v10.Size = UDim2.fromScale(state.ratio, 1)
	text5.Text = state.complete and "SEASON TRACK COMPLETE" or string.format(
		"%d / %d SEASON XP · NEXT TIER",
		state.earned,
		state.needed
	)
	local count = 0

	for _, v24 in v17 do
		local v25 = complete(v24.reward)
		local loaded = v16.loaded

		if loaded then
			if (v16.tier or 1) >= v24.tier then
				loaded = v24.lane == "Free" or v16.premium
			else
				loaded = false
			end
		end

		if loaded and not v25 then
			count += 1
		end

		v24.button.Text = v25 and "COLLECTED ✓" or not v16.loaded and "LOADING…" or (v16.tier or 1) < v24.tier and "TIER " .. v24.tier or v24.lane == "Premium" and not v16.premium and "SEASON PREMIUM" or "CLAIM THROUGH HERE"
		v24.button.Active = loaded and not (v25 or flag)
		v24.button.AutoButtonColor = v24.button.Active
		v24.button.BackgroundColor3 = v25 and Color3.fromRGB(29, 58, 52) or loaded and Color3.fromRGB(48, 83, 91) or Color3.fromRGB(
			37,
			45,
			57
		)
	end

	button5.Text = flag and "SAVING…" or not (count > 0) and "ALL COLLECTED ✓" or "CLAIM ALL  ·  " .. count or "ALL COLLECTED ✓"

	if not v16.loaded then
		button5.Text = "LOADING…"
	end

	local v24 = button5
	local loaded = v16.loaded

	if loaded then
		if count > 0 then
			loaded = not flag
		else
			loaded = false
		end
	end

	v24.Active = loaded
	button5.AutoButtonColor = button5.Active

	for k, v25 in buttons do
		v25.Text = v16.badge == k and "EQUIPPED · REMOVE" or v16.badges[k] and "EQUIP" or "LOCKED"
		v25.Active = v16.badges[k] == true
		v25.AutoButtonColor = v25.Active
	end

	local v25

	if JourneyConfig.PremiumPassId > 0 then
		v25 = JourneyConfig.PurchasesEnabledUniverses[game.GameId] == true
	else
		v25 = false
	end

	local v26

	if type(v20) == "table" and v20.IsForSale == true then
		v26 = type(v20.PriceInRobux) == "number"
	else
		v26 = false
	end

	button6.Text = v16.premium and "SEASON " .. JourneyConfig.SeasonNumber .. " PREMIUM ✓" or not v25 and "SEASON PREMIUM · PREVIEW" or v26 and "SEASON PREMIUM ·  " .. v20.PriceInRobux or "PREMIUM UNAVAILABLE"
	button6.Active = not v16.premium and v25 and v26
	button6.AutoButtonColor = button6.Active
end

local function layout()
	local absoluteSize = screen.AbsoluteSize

	if absoluteSize.X <= 0 or absoluteSize.Y <= 0 then
		return
	end

	local v24 = math.min(1040, absoluteSize.X * 0.94)
	local v25 = math.min(640, absoluteSize.Y * 0.92)
	local v26 = v24 < 520
	local v27 = v25 < 440
	v2.Size = UDim2.fromOffset(v24, v25)
	local v28 = v26 and 14 or 22
	local v29 = v24 - v28 * 2
	text2.Position = UDim2.fromOffset(v28, 12)
	text2.Size = UDim2.fromOffset(v29 - 48, 18)
	text2.TextSize = v27 and 10 or 12
	text3.Position = UDim2.fromOffset(v28, 31)
	text3.Size = UDim2.fromOffset(v29 - 48, 33)
	text3.TextSize = v26 and 23 or v27 and 24 or 28
	button.Position = UDim2.fromOffset(v24 - v28 - 40, 12)
	text4.Position = UDim2.fromOffset(v28, v27 and 64 or 73)
	text4.Size = UDim2.fromOffset(126, 20)
	text4.TextSize = v27 and 12 or 14
	text5.Position = UDim2.fromOffset(v28 + 132, v27 and 64 or 73)
	text5.Size = UDim2.fromOffset(v29 - 132, 20)
	text5.TextSize = v26 and 10 or 12
	v9.Position = UDim2.fromOffset(v28, v27 and 89 or 101)
	v9.Size = UDim2.fromOffset(v29, 4)
	local v30 = v27 and 100 or 115
	button2.Position = UDim2.fromOffset(v28, v30)
	button3.Position = UDim2.fromOffset(v28 + 100, v30)
	button2.Size = UDim2.fromOffset(92, 30)
	button3.Size = UDim2.fromOffset(92, 30)
	button4.Position = UDim2.fromOffset(v24 - v28 - 116, v30)
	button4.Visible = v27 and v11.Visible
	local v31 = v30 + 42
	local v32 = v25 - v31 - (v27 and 74 or 102)
	v11.Position = UDim2.fromOffset(v28, v31)
	v11.Size = UDim2.fromOffset(v29, v32)
	v12.Position = v11.Position
	v12.Size = v11.Size
	local v33 = v27 and v32 - 8 or (v32 - 34) / 2
	local v34 = v27 and 210 or v26 and 200 or 218

	for _, v35 in v17 do
		v35.column.Position = UDim2.fromOffset((v35.tier - 1) * (v34 + 12), 0)
		v35.column.Size = UDim2.fromOffset(v34, v32 - 6)
		v35.number.Visible = not v27
		v35.number.Size = UDim2.fromOffset(v34, 20)
		v35.card.Visible = not v27 or v35.lane == v21
		v35.card.Size = UDim2.fromOffset(v34, v33)
		v35.card.Position = UDim2.fromOffset(0, v27 and 0 or v35.lane == "Free" and 24 or v33 + 32)
		v35.route.Text = v27 and "TIER " .. v35.tier .. "  /  " .. v35.lane:upper() or v35.lane:upper()
		v35.route.Position = UDim2.fromOffset(12, 7)
		v35.route.Size = UDim2.fromOffset(v34 - 24, 15)
		local visible = v33 >= 145
		v35.art.Visible = visible
		v35.art.Position = UDim2.fromOffset(12, 27)
		v35.art.Size = UDim2.fromOffset(v34 - 24, (math.max(35, v33 - 125)))
		v35.label.Position = UDim2.fromOffset(12, not visible and 25 or v33 - 91 or 25)
		v35.label.Size = UDim2.fromOffset(v34 - 24, visible and 48 or math.max(26, v33 - 69))
		v35.label.TextSize = v27 and 11 or 13
		v35.label.TextXAlignment = visible and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left
		v35.button.Position = UDim2.fromOffset(10, v33 - 38)
		v35.button.Size = UDim2.fromOffset(v34 - 20, 32)
	end

	v11.CanvasSize = UDim2.fromOffset(JourneyConfig.MaxTier * (v34 + 12) - 12, 0)
	local v35 = math.max(1, (math.floor((v29 + 10) / 190)))
	v13.CellSize = UDim2.fromOffset((v29 - (v35 - 1) * 10) / v35, 108)
	local v36 = v25 - (v27 and 68 or 93)
	local v37 = (v29 - 10) / 2
	button5.Position = UDim2.fromOffset(v28, v36)
	button5.Size = UDim2.fromOffset(v37, 38)
	button5.TextSize = v26 and 11 or 13
	button6.Position = UDim2.fromOffset(v28 + v37 + 10, v36)
	button6.Size = UDim2.fromOffset(v37, 38)
	button6.TextSize = v26 and 10 or 12
	text7.Position = UDim2.fromOffset(v28, v36 + 43)
	text7.Size = UDim2.fromOffset(v29, 18)
	text7.TextSize = v27 and 10 or 11
	text6.Visible = not v27
	text6.Position = UDim2.fromOffset(v28, v25 - 25)
	text6.Size = UDim2.fromOffset(v29, 20)
	text6.TextSize = v26 and 9 or 11
end

local v24 = {
	"CreatorPanelOpen",
	"CreatorUIHidden",
	"CreatorCameraActive",
	"TutorialSession",
	"ScreenPresentationActive",
	"GlobalWheelOpen",
	"BalloonOfferOpen",
	"ArmoryOpen",
	"ServerBrowserOpen",
	"AdminConsoleActive",
	"MapVoteOpen",
	"MatchSummaryVisible"
}

local function allowed()
	if not JourneyConfig.Enabled or not JourneyConfig.Visible or workspace:GetAttribute("JourneyVisible") == false or localPlayer:GetAttribute("ClientReady") ~= true or localPlayer:GetAttribute("InMatch") == true then
		return false
	end

	for _, attributeName in v24 do
		if localPlayer:GetAttribute(attributeName) then
			return false
		end
	end

	return true
end

local function setOpen(visible)
	if visible then
		HudNavigation.opening("Journey")
	end

	if visible and not allowed() then
		return
	end

	if visible and not v18 then
		local success, result = pcall(function()
			return game.StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.PlayerList)
		end)
		v19 = success and result or nil
		pcall(function()
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
		end)
	elseif not visible and v18 and v19 ~= nil then
		pcall(function()
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, v19)
		end)
	end

	v18 = visible
	v.Visible = visible
	localPlayer:SetAttribute("JourneyOpen", visible or nil)

	if visible then
		localPlayer:SetAttribute("SpectateRequestedExit", os.clock())
		selectedObject = GuiService.SelectedObject
		journeyEvent:FireServer("Get")
		layout()

		if UserInputService.GamepadEnabled then
			GuiService.SelectedObject = button
		end

		local v25 = math.max(1, (v16.tier or 1) - 1)

		for i = 1, v16.tier or 1 do
			local reward = JourneyConfig.Rewards[i]

			if not (reward and (not complete(reward.Free) or v16.premium and not complete(reward.Premium))) then
				continue
			end

			v25 = i
			break
		end

		local child = v11:FindFirstChild("Tier" .. v25)

		if child then
			v11.CanvasPosition = Vector2.new(math.max(0, child.Position.X.Offset), 0)
		end
	elseif GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(screen) then
		GuiService.SelectedObject = selectedObject
	end
end

HudNavigation.register("Journey", function()
	setOpen(not v18)
end)
HudNavigation.Opening.Event:Connect(function(p)
	if p ~= "Journey" then
		if v18 and v19 ~= nil then
			pcall(function()
				game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, v19)
			end)
		end

		v18 = false
		v.Visible = false
		localPlayer:SetAttribute("JourneyOpen", nil)

		if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(screen) then
			GuiService.SelectedObject = selectedObject
		end
	end
end)
button.Activated:Connect(function()
	if v18 and v19 ~= nil then
		pcall(function()
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, v19)
		end)
	end

	v18 = false
	v.Visible = false
	localPlayer:SetAttribute("JourneyOpen", nil)

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(screen) then
		GuiService.SelectedObject = selectedObject
	end
end)
button5.Activated:Connect(function()
	if button5.Active then
		claim("ClaimAll")
	end
end)
button2.Activated:Connect(function()
	v11.Visible = true
	v12.Visible = false
	layout()
end)
button3.Activated:Connect(function()
	v11.Visible = false
	v12.Visible = true
	layout()
end)
button4.Activated:Connect(function()
	v21 = v21 == "Free" and "Premium" or "Free"
	button4.Text = v21:upper() .. "  ⇄"
	layout()
end)
button6.Activated:Connect(function()
	if button6.Active then
		MarketplaceService:PromptGamePassPurchase(localPlayer, JourneyConfig.PremiumPassId)
	end
end)
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p, p2, p3)
	if p == localPlayer and p2 == JourneyConfig.PremiumPassId and p3 then
		task.delay(1, function()
			journeyEvent:FireServer("Refresh")
		end)
	end
end)
journeyEvent.OnClientEvent:Connect(function(p, p2)
	if p == "State" and type(p2) == "table" and p2.seasonId == JourneyConfig.SeasonId then
		v16 = p2

		if p2.message then
			flag = false
			text7.Text = p2.message
		end

		fn()
	end
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and v18 and (input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.ButtonB) then
		if v18 and v19 ~= nil then
			pcall(function()
				game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, v19)
			end)
		end

		v18 = false
		v.Visible = false
		localPlayer:SetAttribute("JourneyOpen", nil)

		if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(screen) then
			GuiService.SelectedObject = selectedObject
		end
	end
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function visibility()
	HudNavigation.setAvailable("Journey", (allowed()))

	if v18 and not allowed() then
		if v18 and v19 ~= nil then
			pcall(function()
				game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, v19)
			end)
		end

		v18 = false
		v.Visible = false
		localPlayer:SetAttribute("JourneyOpen", nil)

		if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(screen) then
			GuiService.SelectedObject = selectedObject
		end
	end
end

for _, v25 in v24 do
	localPlayer:GetAttributeChangedSignal(v25):Connect(visibility)
end

for _, v25 in { "ClientReady", "InMatch" } do
	localPlayer:GetAttributeChangedSignal(v25):Connect(visibility)
end

workspace:GetAttributeChangedSignal("JourneyVisible"):Connect(visibility)
screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
task.spawn(function()
	if JourneyConfig.PremiumPassId > 0 then
		local success, result = pcall(function()
			return MarketplaceService:GetProductInfoAsync(JourneyConfig.PremiumPassId, Enum.InfoType.GamePass)
		end)
		v20 = success and result or false
	end

	fn()
end)
visibility() -- equivalent call inferred; original call site unknown
fn()
layout()
journeyEvent:FireServer("Get")
script.Destroying:Connect(function()
	if v18 and v19 ~= nil then
		pcall(function()
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, v19)
		end)
	end

	v18 = false
	v.Visible = false
	localPlayer:SetAttribute("JourneyOpen", nil)

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(screen) then
		GuiService.SelectedObject = selectedObject
	end

	screen:Destroy()
end)