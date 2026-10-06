local MenuFade = require(game.ReplicatedStorage:WaitForChild("MenuFade"))
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local CatalogUI = require(game.ReplicatedStorage.CatalogUI)
local colors = CatalogUI.colors
local leaderboardRemote = game.ReplicatedStorage:WaitForChild("LeaderboardRemote")
local leaderboardRewardRemote = game.ReplicatedStorage:WaitForChild("LeaderboardRewardRemote")
local leaderboardPurchaseFinished = game.ReplicatedStorage:WaitForChild("LeaderboardPurchaseFinished")
local MarketplaceService = game:GetService("MarketplaceService")
MarketplaceService.PromptBulkPurchaseFinished:Connect(function(p, p2)
	if p == localPlayer then
		leaderboardPurchaseFinished:FireServer("Bulk", 0, p2 == Enum.MarketplaceBulkPurchasePromptStatus.Completed)
	end
end)
MarketplaceService.PromptPurchaseFinished:Connect(function(p, p2, p3)
	if p == localPlayer then
		leaderboardPurchaseFinished:FireServer("Asset", p2, p3)
	end
end)
MarketplaceService.PromptBundlePurchaseFinished:Connect(function(p, p2, p3)
	if p == localPlayer then
		leaderboardPurchaseFinished:FireServer("Bundle", p2, p3)
	end
end)
local parent = script.Parent
local leaderboardButton = parent:WaitForChild("LeaderboardButton")
parent.DisplayOrder = 220
leaderboardButton.AnchorPoint = Vector2.new(0, 1)
leaderboardButton.BackgroundColor3 = Color3.fromRGB(38, 139, 82)

-- equivalent calls inferred from this helper; original call sites unknown
local function frame(p, p2)
	return CatalogUI.make("Frame", p, p2, {
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
end

local v = frame("Root", parent) -- equivalent call inferred; original call site unknown
v.Size = UDim2.fromScale(1, 1)
v.Visible = false
v.Active = true
local v2 = frame("Panel", v) -- equivalent call inferred; original call site unknown
v2.AnchorPoint = Vector2.new(0.5, 0.5)
v2.Position = UDim2.fromScale(0.5, 0.5)
v2.BackgroundTransparency = 0
v2.BackgroundColor3 = colors.bg
v2.Active = true
CatalogUI.round(v2, 16)
local label = CatalogUI.label("Title", v2, "Leaderboards", UDim2.fromOffset(16, 12), UDim2.new(1, -100, 0, 32), 24)
local button = CatalogUI.button("Close", v2, "Close", UDim2.new(1, -84, 0, 8), UDim2.fromOffset(72, 44))
local v3 = frame("Rankings", v2) -- equivalent call inferred; original call site unknown
local button2 = CatalogUI.button("Time", v3, "Time", UDim2.new(), UDim2.new(), true)
local button3 = CatalogUI.button("Spent", v3, "Robux spent", UDim2.new(), UDim2.new())
local button4 = CatalogUI.button("Coins", v3, "Coins", UDim2.new(), UDim2.new())
local label2 = CatalogUI.label("PersonalTotal", v3, "Loading...", UDim2.new(), UDim2.new(), 13)
label2.TextWrapped = true
local v4 = CatalogUI.make("ScrollingFrame", "Rows", v3, {
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = colors.accent
})
CatalogUI.make("UIListLayout", "Layout", v4, {
	Padding = UDim.new(0, 6),
	SortOrder = Enum.SortOrder.LayoutOrder
})
local label3 = CatalogUI.label("Note", v3, "Global rankings · refresh every 60 seconds", UDim2.new(), UDim2.new(), 11)
label3.TextWrapped = true
label3.TextColor3 = colors.muted
local v5 = frame("ChampionReward", v2) -- equivalent call inferred; original call site unknown
v5.BackgroundTransparency = 0
v5.BackgroundColor3 = colors.surface
CatalogUI.round(v5, 12)
local color = Color3.fromRGB(245, 201, 101)
local uIStroke = Instance.new("UIStroke", v5)
uIStroke.Color = color
uIStroke.Transparency = 0.45
local label4 = CatalogUI.label("Heading", v5, "TOP 10 REWARD", UDim2.new(), UDim2.new(), 13)
label4.TextColor3 = color
local v6 = CatalogUI.make("ImageLabel", "Item", v5, {
	BackgroundTransparency = 1,
	ScaleType = Enum.ScaleType.Fit,
	Image = "rbxthumb://type=Asset&id=90905627053179&w=420&h=420"
})
local label5 = CatalogUI.label("ItemName", v5, "Deluxe Champion Helmet", UDim2.new(), UDim2.new(), 18)
label5.TextWrapped = true
local label6 = CatalogUI.label(
	"Requirement",
	v5,
	"Reach the top 10 in Robux spent at any time. Once unlocked, you can claim even if your rank drops.",
	UDim2.new(),
	UDim2.new(),
	14
)
label6.TextWrapped = true
label6.TextColor3 = colors.muted
local label7 = CatalogUI.label("YourRank", v5, "Your rank: checking...", UDim2.new(), UDim2.new(), 17)
label7.TextWrapped = true
label7.TextColor3 = color
local label8 = CatalogUI.label("Eligibility", v5, "Checking eligibility...", UDim2.new(), UDim2.new(), 13)
label8.TextWrapped = true
local label9 = CatalogUI.label("Stock", v5, "", UDim2.new(), UDim2.new(), 12)
label9.TextColor3 = colors.muted
label9.TextWrapped = true
local button5 = CatalogUI.button("Claim", v5, "Checking...", UDim2.new(), UDim2.new(), true)
local label10 = CatalogUI.label("RewardMessage", v5, "", UDim2.new(), UDim2.new(), 12)
label10.TextWrapped = true
label10.TextColor3 = color
local uIScale = Instance.new("UIScale", v2)
local uIScale2 = Instance.new("UIScale", leaderboardButton)
local v7 = "time"
local flag = false
local now = 0
local now2 = 0
local flag2 = false
local v8 = nil
local v9 = nil
local v10 = false
local v11 = false
local v12 = os.clock() + 15

local function number(value)
	return tostring((math.floor(value or 0))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
end

local function duration(value)
	return string.format("%dh %02dm", math.floor((value or 0) / 3600), math.floor((value or 0) / 60) % 60)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function rect(p, p2, p3, p4, p5)
	p.Position = UDim2.fromOffset(p2, p3)
	p.Size = UDim2.fromOffset(p4, p5)
end

local function showReward(data)
	v9 = data
	label7.Text = not data.rankKnown and "Your rank: unavailable" or not data.rank and "Your rank: unranked" or "Your rank: #" .. tostring((math.floor(data.rank or 0))):reverse():gsub(
		"(%d%d%d)",
		"%1,"
	):reverse():gsub(
		"^,",
		""
	) or "Your rank: unranked"
	label5.Text = data.name or "Deluxe Champion Helmet"
	label8.Text = data.owned and "Already owned" or data.eligible and "Permanently unlocked" or "Reach top 10 to unlock"

	if not data.accessKnown then
		label8.Text = "Eligibility unavailable"
	end

	label9.Text = not data.remaining and "Stock unavailable" or tostring((math.floor(data.remaining or 0))):reverse():gsub(
		"(%d%d%d)",
		"%1,"
	):reverse():gsub(
		"^,",
		""
	) .. " copies left" or "Stock unavailable"
	local v13 = button5
	local text

	if data.owned then
		text = "Owned"
	elseif data.available then
		text = data.canClaim and "Claim free" or "Locked"
	else
		text = data.reason == "Sold out" and "Sold out" or "Unavailable"
	end

	v13.Text = text
	button5.Active = data.canClaim == true
	button5.AutoButtonColor = button5.Active
	button5.BackgroundColor3 = button5.Active and colors.accent or colors.raised

	if v11 then
		label9.Text = (data.remaining and tostring((math.floor(data.remaining or 0))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
			"^,",
			""
		) .. " left · " or "") .. label8.Text
	end
end

local function updatePersonal()
	local v13

	if v7 == "coins" and localPlayer:GetAttribute("CoinsReady") == true then
		v13 = true
	elseif v7 == "coins" then
		v13 = false
	else
		v13 = localPlayer:GetAttribute("LeaderboardTotalsReady") == true
	end

	if not v13 then
		label2.Text = "Your total is loading…"
		return
	end

	local v14 = label2
	local text = v7 == "coins" and "You: " .. tostring((math.floor(localPlayer:GetAttribute("Coins") or 0))):reverse():gsub(
		"(%d%d%d)",
		"%1,"
	):reverse():gsub(
		"^,",
		""
	) .. " coins" or v7 == "spent" and "You: R$ " .. tostring((math.floor(localPlayer:GetAttribute("TotalSpendEstimate") or 0))):reverse():gsub(
		"(%d%d%d)",
		"%1,"
	):reverse():gsub(
		"^,",
		""
	) .. " (estimate)"

	if not text then
		local totalPlaySeconds = localPlayer:GetAttribute("TotalPlaySeconds") or 0
		text = "You: " .. string.format(
			"%dh %02dm",
			math.floor((totalPlaySeconds or 0) / 3600),
			math.floor((totalPlaySeconds or 0) / 60) % 60
		)
	end

	v14.Text = text
end

local v13 = 0
local v14 = {}
local v15 = true

for _, v16 in {
	"CoinsReady",
	"LeaderboardTotalsReady",
	"Coins",
	"TotalSpendEstimate",
	"TotalPlaySeconds"
} do
	localPlayer:GetAttributeChangedSignal(v16):Connect(updatePersonal)
end

local function draw()
	if not v8 then
		return
	end

	label.Text = v8.studio and "Leaderboards · Studio test" or "Leaderboards"

	for _, guiObject in v4:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	for i, v16 in ipairs(v8.rows or {}) do
		local v19 = frame("Rank_" .. i, v4) -- equivalent call inferred; original call site unknown
		v19.Size = UDim2.new(1, -6, 0, v10 and 62 or 52)
		v19.BackgroundTransparency = 0
		v19.BackgroundColor3 = v16.userId == localPlayer.UserId and colors.accent or colors.surface
		v19.LayoutOrder = i
		CatalogUI.round(v19, 8)
		CatalogUI.label(
			"Rank",
			v19,
			tostring(i),
			UDim2.fromOffset(6, 0),
			UDim2.fromOffset(v10 and 24 or 36, v10 and 32 or 52),
			v10 and 13 or 17
		)
		local v20

		if v7 == "time" then
			local value = v16.value
			v20 = string.format("%dh %02dm", math.floor((value or 0) / 3600), math.floor((value or 0) / 60) % 60)

			if not v20 then
				v20 = v7 == "coins" and tostring((math.floor(v16.value or 0))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
					"^,",
					""
				) .. " coins" or "R$ " .. tostring((math.floor(v16.value or 0))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
					"^,",
					""
				)
			end
		else
			v20 = v7 == "coins" and tostring((math.floor(v16.value or 0))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
				"^,",
				""
			) .. " coins" or "R$ " .. tostring((math.floor(v16.value or 0))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
				"^,",
				""
			)
		end

		if v10 then
			local label_2 = CatalogUI.label(
				"Username",
				v19,
				v16.name or "User " .. v16.userId,
				UDim2.fromOffset(32, 0),
				UDim2.new(1, -38, 0, 32),
				12
			)
			label_2.TextTruncate = Enum.TextTruncate.AtEnd
			CatalogUI.label("Value", v19, v20, UDim2.fromOffset(32, 32), UDim2.new(1, -38, 0, 24), 13)
		else
			CatalogUI.make("ImageLabel", "Avatar", v19, {
				Position = UDim2.fromOffset(44, 6),
				Size = UDim2.fromOffset(40, 40),
				BackgroundTransparency = 1,
				ScaleType = Enum.ScaleType.Fit,
				Image = "rbxthumb://type=AvatarHeadShot&id=" .. v16.userId .. "&w=150&h=150"
			})
			local label_3 = CatalogUI.label(
				"Username",
				v19,
				(v16.name or "User " .. v16.userId) .. (v16.userId == localPlayer.UserId and " (you)" or ""),
				UDim2.fromOffset(94, 0),
				UDim2.new(1, -240, 1, 0),
				14
			)
			label_3.TextTruncate = Enum.TextTruncate.AtEnd
			local label_4 = CatalogUI.label("Value", v19, v20, UDim2.new(1, -142, 0, 0), UDim2.fromOffset(132, 52), 15)
			label_4.TextXAlignment = Enum.TextXAlignment.Right
		end
	end

	if #(v8.rows or {}) == 0 then
		local label_5 = CatalogUI.label(
			"Empty",
			v4,
			v8.studio and "No entries in this Studio test. Live rankings appear in the published game." or (v8.loaded == false or v8.partial) and "Checking rankings…" or "No entries yet.",
			UDim2.new(),
			UDim2.new(1, -8, 0, 86),
			13
		)
		label_5.TextWrapped = true
	end

	updatePersonal()
	label3.Text = v8.studio and "Studio preview · progress is not saved" or v8.cached and "Saved rankings · updating in the background" or v8.loaded == false and "Loading global rankings…" or v8.partial and "Verified ranks shown · checking remaining players…" or v7 == "spent" and "Saved spending estimates · top 50" or "Global top 50"
	v13 = math.min(v13, os.clock() + ((v8.loaded == false or v8.partial or v8.namesPending) and 1 or 60))
end

local function fit()
	local absoluteSize = v.AbsoluteSize
	local scale = math.min(
		math.clamp(localPlayer:GetAttribute("InterfaceScale") or 1, 0.85, 1.15),
		(absoluteSize.Y - 20) / 280
	)
	uIScale.Scale = scale
	local v17 = math.min(1040, (absoluteSize.X - 20) / scale)
	local v18 = math.min(600, (absoluteSize.Y - 20) / scale)
	v2.Size = UDim2.fromOffset(v17, v18)
	v11 = v18 < 520
	local v19 = v18 - 60 - 12

	if v17 < 520 and v18 >= 520 then
		v11 = true
		v10 = true
		local v20 = v17 - 24
		rect(v5, 12, 60, v20, 232) -- equivalent call inferred; original call site unknown
		rect(v3, 12, 304, v20, v18 - 316) -- equivalent call inferred; original call site unknown
		local v24 = (v20 - 8) / 3

		for k, v25 in { button2, button3, button4 } do
			rect(v25, (k - 1) * (v24 + 4), 0, v24, 44) -- equivalent call inferred; original call site unknown
			v25.TextSize = 13
			v25.TextWrapped = true
		end

		rect(label2, 0, 48, v20, 28) -- equivalent call inferred; original call site unknown
		rect(v4, 0, 80, v20, math.max(40, v18 - 420)) -- equivalent call inferred; original call site unknown
		rect(label3, 0, v18 - 340, v20, 24) -- equivalent call inferred; original call site unknown
		rect(label4, 104, 8, v20 - 116, 20) -- equivalent call inferred; original call site unknown
		label4.TextSize = 12
		rect(v6, 10, 12, 84, 84) -- equivalent call inferred; original call site unknown
		rect(label5, 104, 30, v20 - 116, 44) -- equivalent call inferred; original call site unknown
		label5.TextSize = 16
		label6.Text = "Reach top 10 in Robux spent once. Your claim stays unlocked."
		rect(label6, 104, 78, v20 - 116, 54) -- equivalent call inferred; original call site unknown
		label6.TextSize = 12
		rect(label7, 12, 134, v20 - 24, 26) -- equivalent call inferred; original call site unknown
		label7.TextSize = 16
		label8.Visible = false
		rect(label9, 12, 160, v20 - 24, 20) -- equivalent call inferred; original call site unknown
		label9.TextSize = 12
		label9.Visible = true
		rect(button5, 12, 184, v20 - 24, 44) -- equivalent call inferred; original call site unknown
		rect(label10, 104, 78, v20 - 116, 54) -- equivalent call inferred; original call site unknown
		label10.TextSize = 12
		label10.Visible = label10.Text ~= ""
		label6.Visible = not label10.Visible
		uIScale2.Scale = math.min(scale, absoluteSize.X / 900, absoluteSize.Y / 600)
		draw()

		if v9 then
			showReward(v9)
		end
	else
		local v20 = v11 and math.clamp(v17 * 0.37, 210, 280) or math.clamp(v17 * 0.38, 132, 280)
		local v21 = v17 - 24 - 12 - v20
		v10 = v21 < 430
		rect(v3, 12, 60, v21, v19) -- equivalent call inferred; original call site unknown
		rect(v5, 12 + v21 + 12, 60, v20, v19) -- equivalent call inferred; original call site unknown
		local v25 = (v21 - 8) / 3

		for k, v26 in { button2, button3, button4 } do
			rect(v26, (k - 1) * (v25 + 4), 0, v25, 44) -- equivalent call inferred; original call site unknown
			v26.TextSize = v10 and 11 or 14
			v26.TextWrapped = true
		end

		rect(label2, 0, 48, v21, v10 and 40 or 30) -- equivalent call inferred; original call site unknown
		local v28 = v10 and 92 or 82
		local v29 = v11 and 24 or 38
		rect(v4, 0, v28, v21, math.max(30, v19 - v28 - v29 - 4)) -- equivalent call inferred; original call site unknown
		rect(label3, 0, v19 - v29, v21, v29) -- equivalent call inferred; original call site unknown

		if v11 then
			rect(label4, 10, 6, v20 - 88, 18) -- equivalent call inferred; original call site unknown
			label4.TextSize = 12
			rect(v6, v20 - 76, 4, 68, 68) -- equivalent call inferred; original call site unknown
			rect(label5, 10, 26, v20 - 88, 38) -- equivalent call inferred; original call site unknown
			label5.TextSize = 14
			label6.Text = "Reach top 10 in Robux spent once. Your claim stays unlocked."
			rect(label6, 10, 68, v20 - 20, 40) -- equivalent call inferred; original call site unknown
			label6.TextSize = 12
			rect(label7, 10, 110, v20 - 20, 22) -- equivalent call inferred; original call site unknown
			label7.TextSize = 15
			label8.Visible = false
			rect(label9, 10, 134, v20 - 20, 18) -- equivalent call inferred; original call site unknown
			label9.TextSize = 11
			rect(button5, 10, v19 - 52, v20 - 20, 44) -- equivalent call inferred; original call site unknown
			label10.Visible = label10.Text ~= ""
			label6.Visible = not label10.Visible
			label9.Visible = true
			rect(label10, 10, 68, v20 - 20, 40) -- equivalent call inferred; original call site unknown
			label10.TextSize = 11
		else
			label6.Visible = true
			rect(label4, 12, 10, v20 - 24, 22) -- equivalent call inferred; original call site unknown
			label4.TextSize = v20 < 180 and 11 or 13
			local v36 = math.min(174, v20 - 24)
			rect(v6, (v20 - v36) / 2, 34, v36, v36) -- equivalent call inferred; original call site unknown
			local v39 = v36 + 40
			rect(label5, 12, v39, v20 - 24, 48) -- equivalent call inferred; original call site unknown
			label5.TextSize = v20 < 180 and 15 or 18
			local v42 = v39 + 52
			label6.Text = "Reach the top 10 in Robux spent at any time. Once unlocked, you can claim even if your rank drops."
			local v43 = v20 < 180 and 108 or 72
			rect(label6, 12, v42, v20 - 24, v43) -- equivalent call inferred; original call site unknown
			label6.TextSize = v20 < 180 and 12 or 14
			local v46 = v42 + (v43 + 8)
			rect(label7, 12, v46, v20 - 24, 42) -- equivalent call inferred; original call site unknown
			label7.TextSize = v20 < 180 and 15 or 17
			local v49 = v46 + 44
			rect(label8, 12, v49, v20 - 24, 36) -- equivalent call inferred; original call site unknown
			label8.Visible = true
			local v52 = v49 + 36
			rect(label9, 12, v52, v20 - 24, 24) -- equivalent call inferred; original call site unknown
			label9.Visible = label10.Text == ""
			label9.TextSize = 12
			rect(label10, 12, v52, v20 - 24, math.max(24, v19 - v52 - 60)) -- equivalent call inferred; original call site unknown
			label10.Visible = label10.Text ~= ""
			label10.TextSize = 12
			rect(button5, 12, v19 - 56, v20 - 24, 44) -- equivalent call inferred; original call site unknown
		end

		uIScale2.Scale = math.min(scale, absoluteSize.X / 900, absoluteSize.Y / 600)
		local IconNavigation = require(game.ReplicatedStorage.IconNavigation)
		IconNavigation.Apply(playerGui, nil, localPlayer:GetAttribute("InterfaceScale") or 1)
		draw()

		if v9 then
			showReward(v9)
		end
	end
end

local function refreshReward(value)
	if flag2 then
		return
	end

	flag2 = true
	button5.Active = false
	local success, result = pcall(function()
		return leaderboardRewardRemote:InvokeServer(value or "Status")
	end)
	flag2 = false
	now2 = os.clock()

	if success and result then
		if result.status then
			showReward(result.status)
		end

		label10.Text = result.error or result.message or ""
	else
		label10.Text = "Could not check reward. Retrying shortly."
	end

	fit()
end

local refresh

refresh = function()
	if flag then
		return
	end

	flag = true
	local v16 = v7
	local success, result = pcall(function()
		return leaderboardRemote:InvokeServer(v16)
	end)
	flag = false

	if v7 ~= v16 then
		task.defer(refresh)
	elseif success and result and not result.error then
		local v17 = v14[v16]

		if v17 and v17.loaded ~= false and not v17.partial and #v17.rows > 0 and (result.loaded == false or result.partial) then
			local clone = table.clone(v17)
			clone.seconds = result.seconds
			clone.spent = result.spent
			clone.coins = result.coins
			result = clone
		end

		v8 = result
		v14[v16] = result
		now = os.clock()
		v13 = os.clock() + (result.cached and 5 or (result.loaded == false or result.partial or result.namesPending) and 1 or 60)
		local canvasPosition = v4.CanvasPosition
		draw()
		v4.CanvasPosition = canvasPosition
	else
		label3.Text = "Rankings unavailable. Retrying shortly."
		v13 = os.clock() + 3
	end
end

local function selectTab(p)
	v7 = p
	v8 = v14[p]

	for _, guiObject in v4:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	label2.Text = "Loading..."
	label3.Text = "Loading rankings..."

	if v8 then
		draw()
	end

	for _, v16 in {
		{ button2, "time" },
		{ button3, "spent" },
		{ button4, "coins" }
	} do
		v16[1].BackgroundColor3 = v7 == v16[2] and colors.accent or colors.raised
	end

	v4.CanvasPosition = Vector2.zero
	refresh()
end

leaderboardButton.Activated:Connect(function()
	v15 = false
	MenuFade.Set(v, "Visible", true)
	MenuFade.Set(leaderboardButton, "Visible", false)

	if v14[v7] then
		v8 = v14[v7]
		draw()
	end

	task.spawn(refresh)
	task.spawn(refreshReward, "Status")
end)
button.Activated:Connect(function()
	MenuFade.Set(v, "Visible", false)
end)
button2.Activated:Connect(function()
	selectTab("time")
end)
button3.Activated:Connect(function()
	selectTab("spent")
end)
button4.Activated:Connect(function()
	selectTab("coins")
end)
button5.Activated:Connect(function()
	if v9 and v9.canClaim and not flag2 then
		refreshReward("Claim")
	end
end)
game.ReplicatedStorage:WaitForChild("LeaderboardRewardChanged").OnClientEvent:Connect(function()
	task.delay(2, function()
		if v.Visible then
			refreshReward("Status")
		end
	end)
end)

local function nav()
	local visible = v.Visible

	for _, childName in { "CatalogGui", "CommunityGui", "WearingGui" } do
		local child = playerGui:FindFirstChild(childName)

		if child and child.Enabled then
			visible = true
		end
	end

	playerGui:FindFirstChild("ScreenGui")
	leaderboardButton.Visible = not visible
end

v:GetPropertyChangedSignal("Visible"):Connect(nav)

for _, childName in { "CatalogGui", "CommunityGui", "WearingGui" } do
	playerGui:WaitForChild(childName):GetPropertyChangedSignal("Enabled"):Connect(nav)
end

v:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
localPlayer:GetAttributeChangedSignal("InterfaceScale"):Connect(fit)
fit()
nav()

local function watchSnapshots(instance)
	local v16 = {}

	local function watch(stringValue)
		if not stringValue:IsA("StringValue") or v16[stringValue] or stringValue.Name ~= "time" and stringValue.Name ~= "spent" and stringValue.Name ~= "coins" then
			return
		end

		v16[stringValue] = true

		local function receive()
			if stringValue.Value == "" then
				return
			end

			local success, result = pcall(function()
				local HttpService = game:GetService("HttpService")
				return HttpService:JSONDecode(stringValue.Value)
			end)

			if not success or type(result) ~= "table" or type(result.rows) ~= "table" then
				return
			end

			result.seconds = localPlayer:GetAttribute("TotalPlaySeconds") or 0
			result.spent = localPlayer:GetAttribute("TotalSpendEstimate") or 0
			result.coins = localPlayer:GetAttribute("Coins") or 0
			result.studio = false
			v14[stringValue.Name] = result

			if stringValue.Name == v7 then
				v8 = result
				local canvasPosition = v4.CanvasPosition
				draw()
				v4.CanvasPosition = canvasPosition
			end
		end

		stringValue.Changed:Connect(receive)
		receive()
	end

	for _, child in instance:GetChildren() do
		watch(child)
	end

	instance.ChildAdded:Connect(watch)
end

local leaderboardDisplaySnapshots = game.ReplicatedStorage:FindFirstChild("LeaderboardDisplaySnapshots")

if leaderboardDisplaySnapshots then
	watchSnapshots(leaderboardDisplaySnapshots)
else
	local childAddedConnection = nil
	childAddedConnection = game.ReplicatedStorage.ChildAdded:Connect(function(child)
		if child.Name == "LeaderboardDisplaySnapshots" then
			childAddedConnection:Disconnect()
			watchSnapshots(child)
		end
	end)
end

task.defer(refresh)
task.spawn(function()
	while task.wait(1) do
		if not (v.Visible or v15 and os.clock() < v12) then
			continue
		end

		local now3 = os.clock()

		if v13 <= now3 then
			task.spawn(refresh)
		end

		if not (v.Visible and os.clock() - now2 >= (v9 and v9.rankKnown and 30 or 3)) then
			continue
		end

		task.spawn(refreshReward, "Status")
	end
end)