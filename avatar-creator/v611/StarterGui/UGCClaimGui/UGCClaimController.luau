local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local parent = script.Parent
local panel = parent.Panel
local help = parent.Help
local coinHUD = parent.CoinHUD
local MenuFade = require(game.ReplicatedStorage.MenuFade)
local uGCClaimRemote = game.ReplicatedStorage:WaitForChild("UGCClaimRemote")
local catelogButton = playerGui:WaitForChild("ScreenGui").Frame.CatelogButton
local uIScale = Instance.new("UIScale", panel)
local uIScale2 = Instance.new("UIScale", help)
local uIScale3 = Instance.new("UIScale", coinHUD)
local details = panel.Details
local v = nil
local flag = false
local name = "Coins"
local RewardGiftUI = require(parent:WaitForChild("RewardGiftUI"))
local v2 = RewardGiftUI.Mount(parent)
local displayOrder = parent.DisplayOrder
local text = panel.Subtitle.Text
local position = panel.Subtitle.Position
local size = panel.Subtitle.Size
local textSize = panel.Subtitle.TextSize
local textWrapped = panel.Subtitle.TextWrapped

local function updateStreamNotice()
	local v3 = name == "Stream"
	panel.Subtitle.Text = v3 and [[
Approvals refresh automatically while this menu is open.
Once approved, select your item and press Claim.]] or text
	panel.Subtitle.Position = v3 and UDim2.fromOffset(24, 54) or position
	panel.Subtitle.Size = v3 and UDim2.new(1, -48, 0, 36) or size
	panel.Subtitle.TextSize = v3 and 14 or textSize
	panel.Subtitle.TextWrapped = v3 or textWrapped
end

local items = {}
local setKey = nil

for _, v3 in ipairs(require(game.ReplicatedStorage:WaitForChild("UGCRewardPreview"))) do
	table.insert(items, table.clone(v3))
end

local function setProgress(list)
	local count = 0
	local v3 = true

	for _, v4 in ipairs(list) do
		if v4.owned then
			count += 1
		end

		if not v4.ownershipKnown then
			v3 = false
		end
	end

	return tostring(count) .. " of " .. tostring(#list) .. " claimed" .. (v3 and "" or " · checking ownership")
end

local function format(value)
	return (tostring((math.floor(value or 0))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", ""))
end

local function balance()
	local coins = localPlayer:GetAttribute("Coins") or 0
	coinHUD.Balance.Text = tostring((math.floor(coins or 0))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") .. " coins"
	details.Balance.Text = "Your balance: " .. tostring((math.floor(coins or 0))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
		"^,",
		""
	) .. " coins"
	local v3 = v and v.category == "Stream"
	local v4 = v and v.stock == 0
	local redeem = details.Redeem
	local text2

	if flag then
		text2 = "Please wait…"
	elseif v and v.owned then
		text2 = "Claimed"
	elseif v4 then
		text2 = "Sold out"
	elseif v3 then
		text2 = v.unlocked and "Claim" or v.accessKnown == true and "Awaiting approval" or "Checking approval…"
	else
		text2 = v and v.unlocked and "Claim" or "Redeem · " .. tostring((math.floor(v and v.cost or 1750 or 0))):reverse():gsub(
			"(%d%d%d)",
			"%1,"
		):reverse():gsub(
			"^,",
			""
		) .. " coins"
	end

	redeem.Text = text2
	local redeem2 = details.Redeem
	local unlocked = not flag

	if unlocked then
		if v == nil or v.ownershipKnown ~= true then
			unlocked = false
		else
			unlocked = not v.owned

			if unlocked then
				if v.available == true and localPlayer:GetAttribute("CoinsReady") == true then
					unlocked = v.unlocked or not v3 and v.cost <= coins
				else
					unlocked = false
				end
			end
		end
	end

	redeem2.Interactable = unlocked
	v2.Update(v, flag)
end

local function render(data)
	updateStreamNotice()

	for i, v3 in ipairs(items) do
		if v3.id ~= data.id then
			continue
		end

		items[i] = data
		break
	end

	v = data
	details.ItemName.Text = data.name
	details.Stock.Text = type(data.stock) ~= "number" and "Stock unavailable" or type(data.totalStock) == "number" and tostring((math.floor(data.stock or 0))):reverse():gsub(
		"(%d%d%d)",
		"%1,"
	):reverse():gsub(
		"^,",
		""
	) .. "/" .. tostring((math.floor(data.totalStock or 0))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") .. " available" or tostring((math.floor(data.stock or 0))):reverse():gsub(
		"(%d%d%d)",
		"%1,"
	):reverse():gsub(
		"^,",
		""
	) .. " available · total unknown" or "Stock unavailable"
	details.Price.Text = data.category == "Stream" and "Redeemable from the stream" or tostring((math.floor(data.cost or 0))):reverse():gsub(
		"(%d%d%d)",
		"%1,"
	):reverse():gsub(
		"^,",
		""
	) .. " coins"
	details.ItemImage.Image = "rbxthumb://type=Asset&id=" .. data.id .. "&w=420&h=420"
	panel.Status.Text = data.owned and "You already own this item." or data.reason or data.unlocked and "Unlocked. Claim anytime while stock remains." or data.category == "Stream" and "Redeem on stream, then send your Roblox user ID for approval. Game coins are not used." or "Redeem once to permanently unlock Claim."
	balance()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function call(p, p2)
	local success, result = pcall(function()
		return uGCClaimRemote:InvokeServer(p, p2)
	end)
	return success and result or {
		error = "Unable to connect. Please try again."
	}
end

local function showItem(p)
	render(p)
	panel.RewardTabs.Visible = false
	panel.Rewards.Visible = false
	panel.Back.Visible = true
	MenuFade.Set(details, "Visible", true)
	local v4 = call("Listing", p.id) -- equivalent call inferred; original call site unknown

	if v and v.id == p.id and not v4.error then
		render(v4)
	end
end

local flag2 = false
local now = -1e999

local function filterRewards()
	updateStreamNotice()

	for _, button in panel.Rewards:GetChildren() do
		if button:IsA("GuiButton") then
			button.Visible = button:GetAttribute("RewardCategory") == name
		end
	end

	panel.Status.Text = name == "Stream" and "Redeem stream points on stream, then submit your Roblox user ID for approval." or "Earn game coins and redeem them for free UGC."
end

local fn

fn = function()
	updateStreamNotice()

	for _, button in ipairs(panel.Rewards:GetChildren()) do
		if button:IsA("GuiButton") then
			button:Destroy()
		end
	end

	local v3 = {}
	local v4 = {}

	for _, v5 in ipairs(items) do
		if setKey then
			if v5.setKey == setKey then
				table.insert(v3, v5)
			end
		elseif v5.setKey then
			local v6 = v4[v5.setKey]

			if not v6 then
				v6 = {
					id = v5.id,
					name = v5.setName,
					category = "Stream",
					isSet = true,
					setKey = v5.setKey,
					items = {}
				}
				v4[v5.setKey] = v6
				table.insert(v3, v6)
			end

			table.insert(v6.items, v5)
		else
			table.insert(v3, v5)
		end
	end

	local CatalogUI = require(game.ReplicatedStorage.CatalogUI)

	for i, v5 in ipairs(v3) do
		local folder = CatalogUI.button("Reward_" .. v5.id, panel.Rewards, "", UDim2.new(), UDim2.fromOffset(200, 258))
		folder.ZIndex = panel.Rewards.ZIndex + 1
		folder.Active = true
		folder.Interactable = true
		folder:SetAttribute("RewardCategory", v5.category or "Coins")
		folder.Visible = (v5.category or "Coins") == name
		folder.LayoutOrder = i
		local v6 = v5.isSet and tostring(#v5.items) .. "-item set" or v5.owned and "Claimed" or v5.stock == 0 and "Sold out" or type(v5.stock) ~= "number" and "Stock unknown" or tostring((math.floor(v5.stock or 0))):reverse():gsub(
			"(%d%d%d)",
			"%1,"
		):reverse():gsub(
			"^,",
			""
		) .. " available" or "Stock unknown"
		local label = CatalogUI.label("StockBadge", folder, v6, UDim2.fromOffset(8, 8), UDim2.fromOffset(130, 26), 14)
		label.BackgroundColor3 = Color3.fromRGB(18, 23, 30)
		label.BackgroundTransparency = 0.12
		label.TextColor3 = Color3.fromRGB(242, 246, 251)
		label.Font = Enum.Font.GothamBold
		label.TextXAlignment = Enum.TextXAlignment.Center
		local uICorner = Instance.new("UICorner", label)
		uICorner.CornerRadius = UDim.new(0, 7)
		CatalogUI.make("ImageLabel", "Thumbnail", folder, {
			Position = UDim2.fromOffset(8, 8),
			Size = UDim2.new(1, -16, 0, 174),
			BackgroundTransparency = 1,
			ScaleType = Enum.ScaleType.Fit,
			Image = "rbxthumb://type=Asset&id=" .. v5.id .. "&w=420&h=420"
		})
		CatalogUI.label("Name", folder, v5.name, UDim2.fromOffset(12, 186), UDim2.new(1, -24, 0, 26), 17)
		local v7 = v5.isSet and setProgress(v5.items)

		if not v7 then
			if v5.owned then
				v7 = "Claimed"
			elseif v5.category == "Stream" then
				v7 = v5.unlocked and "Claim" or v5.accessKnown == true and "Awaiting approval" or "Checking approval…"
			else
				v7 = tostring((math.floor(v5.cost or 0))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") .. " coins"
			end
		end

		local label_2 = CatalogUI.label("Cost", folder, v7, UDim2.fromOffset(12, 218), UDim2.new(1, -24, 0, 26), 15)
		label_2.TextColor3 = Color3.fromRGB(255, 211, 99)

		for _, guiObject in folder:GetDescendants() do
			if not guiObject:IsA("GuiObject") then
				continue
			end

			guiObject.ZIndex = folder.ZIndex + 1
			guiObject.Active = false
		end

		label.ZIndex = folder.ZIndex + 2
		local v8 = v5
		folder.Activated:Connect(function()
			if not v8.isSet then
				showItem(v8)
				return
			end

			setKey = v8.setKey
			panel.RewardTabs.Visible = false
			panel.Back.Visible = true
			panel.Rewards.CanvasPosition = Vector2.zero
			fn()
		end)
	end

	if setKey then
		panel.Status.Text = (not v3[1] and "Stream set" or v3[1].setName or "Stream set") .. " · " .. setProgress(v3) .. " · Select an item to claim."
	else
		filterRewards()
	end
end

fn()

local function refresh()
	if details.Visible and v then
		local id = v.id
		local v4 = call("Listing", id) -- equivalent call inferred; original call site unknown

		if not v4.error and v and v.id == id then
			render(v4)
		end
	else
		if flag2 then
			return
		end

		flag2 = true
		local v5 = call("Catalog", nil) -- equivalent call inferred; original call site unknown
		flag2 = false

		if v5.error then
			panel.Status.Text = v5.error
			return
		end

		now = os.clock()
		items = v5.items or {}
		fn()

		if not setKey then
			filterRewards()
		end
	end
end

local function showGrid()
	MenuFade.Set(details, "Visible", false)
	v = nil
	panel.RewardTabs.Visible = true
	panel.Rewards.Visible = true
	panel.Back.Visible = false
	panel.RewardTabs.Visible = setKey == nil
	panel.Back.Visible = setKey ~= nil
	fn()
	panel.Rewards.CanvasPosition = Vector2.zero

	if os.clock() - now >= 15 then
		task.spawn(refresh)
	end
end

for _, button in panel.RewardTabs:GetChildren() do
	if not button:IsA("TextButton") then
		continue
	end

	local v3 = button
	button.Activated:Connect(function()
		if flag then
			return
		end

		setKey = nil
		name = v3.Name

		for i, button2 in panel.RewardTabs:GetChildren() do
			if button2:IsA("TextButton") then
				button2.BackgroundColor3 = button2 == v3 and Color3.fromRGB(73, 97, 131) or Color3.fromRGB(46, 51, 60)
			end
		end

		showGrid()
	end)
end

panel.RewardTabs.Coins.BackgroundColor3 = Color3.fromRGB(73, 97, 131)
catelogButton.Activated:Connect(function()
	local v3 = not MenuFade.IsOpen(panel)
	MenuFade.Set(panel, "Visible", v3)

	if v3 then
		MenuFade.Set(help, "Visible", false)
		showGrid()
	end
end)
panel.Back.Activated:Connect(function()
	if not details.Visible then
		setKey = nil
	end

	showGrid()
end)
panel.Close.Activated:Connect(function()
	MenuFade.Set(panel, "Visible", false)
end)
panel.CoinHelp.Activated:Connect(function()
	MenuFade.Set(help, "Visible", not MenuFade.IsOpen(help))
end)
help.Close.Activated:Connect(function()
	MenuFade.Set(help, "Visible", false)
end)
details.Redeem.Activated:Connect(function()
	if flag or not (v and details.Redeem.Interactable) then
		return
	end

	flag = true
	local id = v.id
	local v3 = v.unlocked and "Claim" or "Redeem"
	balance()
	local v4 = call(v3, id) -- equivalent call inferred; original call site unknown
	flag = false

	if v and v.id == id then
		if v4.item then
			render(v4.item)
		end

		panel.Status.Text = v4.error or v4.message or ""
	end

	balance()
end)
localPlayer:GetAttributeChangedSignal("Coins"):Connect(balance)
localPlayer:GetAttributeChangedSignal("CoinsReady"):Connect(balance)
localPlayer:GetAttributeChangedSignal("ClaimMessage"):Connect(function()
	panel.Status.Text = localPlayer:GetAttribute("ClaimMessage") or ""
	task.delay(1.1, refresh)
end)

local function layout()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return
	end

	local viewportSize = currentCamera.ViewportSize
	local interfaceScale = localPlayer:GetAttribute("InterfaceScale") or 1
	local MobileCatalogLayout = require(game.ReplicatedStorage.MobileCatalogLayout)

	if not MobileCatalogLayout.IsMobile() then
		parent.DisplayOrder = panel.Visible and math.max(240, displayOrder) or displayOrder
		local absoluteSize = parent.AbsoluteSize
		local scale = math.min(interfaceScale, (absoluteSize.X - 24) / 720, (absoluteSize.Y - 16) / 500)
		uIScale.Scale = scale
		local v4 = math.clamp((absoluteSize.X - 32) / scale, 720, 1320)
		local v5 = math.clamp((absoluteSize.Y - 16) / scale, 500, 860)
		panel.Size = UDim2.fromOffset(v4, v5)
		panel.Rewards.Size = UDim2.new(1, -48, 1, -180)
		panel.Status.Position = UDim2.new(0, 24, 1, -36)
		panel.Status.Size = UDim2.new(1, -48, 0, 28)
		panel.CoinShop.Position = UDim2.new(1, -280, 0, 66)
		local v6 = math.max(3, (math.floor((v4 - 30) / 218)))
		panel.Rewards.Layout.CellSize = UDim2.fromOffset(math.floor((v4 - 56 - (v6 - 1) * 18) / v6), 250)
	end

	uIScale2.Scale = math.min(interfaceScale, (viewportSize.X - 32) / 500, (viewportSize.Y - 40) / 530)
	uIScale3.Scale = math.min(interfaceScale, viewportSize.X / 900, viewportSize.Y / 600)
	local IconNavigation = require(game.ReplicatedStorage.IconNavigation)
	IconNavigation.Apply(playerGui, nil, game.Players.LocalPlayer:GetAttribute("InterfaceScale") or 1)
	local _ = catelogButton.AbsolutePosition
	local _ = catelogButton.AbsoluteSize
	panel.CoinHelp.Position = UDim2.fromOffset(160, 23)
end

local function visibility()
	local v3 = false

	for _, childName in ipairs({
		"CatalogGui",
		"CommunityGui",
		"WearingGui",
		"RobloxSaveOutfitGui"
	}) do
		local child = playerGui:FindFirstChild(childName)

		if child and child.Enabled then
			v3 = true
		end
	end

	local backgroundPreviewGui = playerGui:FindFirstChild("BackgroundPreviewGui")
	local stage = backgroundPreviewGui and backgroundPreviewGui:FindFirstChild("Stage")
	local v4 = stage and stage.Visible and true or v3
	coinHUD.Visible = not v4
	local v5 = false

	for _, childName in ipairs({ "CatalogGui", "CommunityGui", "WearingGui" }) do
		local child = playerGui:FindFirstChild(childName)

		if child and child.Enabled then
			v5 = true
		end
	end

	local v6 = stage and stage.Visible and true or v5
	panel.CoinHelp.Visible = not v6

	if v6 then
		MenuFade.Set(help, "Visible", false)
	end

	if v4 then
		MenuFade.Set(panel, "Visible", false)
		MenuFade.Set(help, "Visible", false)
	end
end

for _, childName in ipairs({
	"CatalogGui",
	"CommunityGui",
	"WearingGui",
	"RobloxSaveOutfitGui"
}) do
	playerGui:WaitForChild(childName):GetPropertyChangedSignal("Enabled"):Connect(visibility)
end

task.spawn(function()
	playerGui:WaitForChild("BackgroundPreviewGui"):WaitForChild("Stage"):GetPropertyChangedSignal("Visible"):Connect(visibility)
end)
local ViewportLayoutWatch = require(game.ReplicatedStorage:WaitForChild("ViewportLayoutWatch"))
ViewportLayoutWatch.Bind(layout)
panel:GetPropertyChangedSignal("Visible"):Connect(layout)
catelogButton:GetPropertyChangedSignal("AbsolutePosition"):Connect(layout)
catelogButton:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
localPlayer:GetAttributeChangedSignal("InterfaceScale"):Connect(layout)
task.spawn(function()
	local total = 0

	while parent.Parent do
		local nextCoinAt = localPlayer:GetAttribute("NextCoinAt")
		local v3 = nextCoinAt and math.max(0, (math.ceil(nextCoinAt - workspace:GetServerTimeNow()))) or 60
		coinHUD.Timer.Text = localPlayer:GetAttribute("CoinsReady") and string.format(
			"Next coin in %02d:%02d",
			math.floor(v3 / 60),
			v3 % 60
		) or "Loading coins…"
		task.wait(0.25)
		total += 0.25

		if not (total >= 30) then
			continue
		end

		total = 0

		if panel.Visible then
			task.spawn(refresh)
		end
	end
end)
balance()
layout()
visibility()
local coins = localPlayer:GetAttribute("Coins") or 0
local textLabel = Instance.new("TextLabel")
textLabel.Name = "EarnedCoins"
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.fromRGB(255, 211, 99)
textLabel.Font = Enum.Font.GothamBold
textLabel.TextSize = 15
textLabel.Position = UDim2.new(0, 0, 0, -26)
textLabel.Size = UDim2.new(1, 0, 0, 24)
textLabel.Text = ""
textLabel.Parent = coinHUD
local count = 0
localPlayer:GetAttributeChangedSignal("Coins"):Connect(function()
	local coins2 = localPlayer:GetAttribute("Coins") or 0

	if coins < coins2 then
		count += 1
		local v3 = count
		textLabel.Text = "+" .. tostring((math.floor(coins2 - coins or 0))):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub(
			"^,",
			""
		) .. " coins"
		task.delay(3, function()
			if v3 == count then
				textLabel.Text = ""
			end
		end)
	end

	coins = coins2
end)
localPlayer:GetAttributeChangedSignal("ClaimPending"):Connect(balance)
panel.CoinShop.Activated:Connect(function()
	MenuFade.Set(help, "Visible", false)
	MenuFade.Set(panel.CoinShopPanel, "Visible", true)
end)
panel.CoinShopPanel.Back.Activated:Connect(function()
	MenuFade.Set(panel.CoinShopPanel, "Visible", false)
end)
panel:GetPropertyChangedSignal("Visible"):Connect(function()
	if not panel.Visible then
		panel.CoinShopPanel.Visible = false
	end
end)
task.spawn(refresh)
catelogButton:WaitForChild("CoinFAQ").Activated:Connect(function()
	MenuFade.Set(help, "Visible", not MenuFade.IsOpen(help))
end)
local v3 = false

local function refreshApprovals()
	if v3 or not panel.Visible then
		return
	end

	v3 = true
	local v6 = call("ApprovalStatus", nil) -- equivalent call inferred; original call site unknown
	v3 = false

	if v6.error or type(v6.items) ~= "table" then
		return
	end

	local v7 = false

	for _, item in ipairs(items) do
		local item2 = v6.items[tostring(item.id)]

		if not (item2 and (item.unlocked ~= item2.unlocked or item.accessKnown ~= item2.accessKnown)) then
			continue
		end

		item.unlocked = item2.unlocked
		item.accessKnown = item2.accessKnown
		v7 = true
	end

	local v8 = v and v6.items[tostring(v.id)]

	if v8 then
		local unlocked = v.unlocked
		v.unlocked = v8.unlocked
		v.accessKnown = v8.accessKnown
		balance()

		if unlocked ~= v.unlocked and not flag then
			panel.Status.Text = v.unlocked and "Approved! Press Claim when the item is available." or "Awaiting stream approval."
		end
	end

	if v7 and not details.Visible then
		fn()
	end
end

panel:GetPropertyChangedSignal("Visible"):Connect(function()
	if panel.Visible then
		task.spawn(refreshApprovals)
	end
end)
task.spawn(function()
	while parent.Parent do
		refreshApprovals()
		task.wait(3)
	end
end)