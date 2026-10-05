local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage.packages
local legacyControllers = ReplicatedStorage.client.legacyControllers
local modules = ReplicatedStorage.shared.modules
local localPlayer = Players.LocalPlayer
local Trove = require(packages.Trove)
local Net = require(packages.Net)
local HudController = require(legacyControllers.HudController)
local ViewOddsController = require(legacyControllers.ViewOddsController)
local library = require(modules.library)
local Monetization = require(ReplicatedStorage.shared.Monetization)
local KaitosShopConfig = require(modules.KaitosShopConfig)
local remoteFunction = Net:RemoteFunction("KaitosShop/GetState")
local remoteFunction2 = Net:RemoteFunction("KaitosShop/Purchase")
local remoteEvent = Net:RemoteEvent("KaitosShop/Refresh")
local remoteEvent2 = Net:RemoteEvent("KaitosShop/Replicate")
local remoteEvent3 = Net:RemoteEvent("KaitosShop/Open")
local kaitosShop = HudController:GetSafeZone().KaitosShop
local container = kaitosShop.Container
local items = container.Items
local purchase = container.Purchase
local amount = purchase.Amount
local less = amount.Less
local more = amount.More
local max = amount.Max
local textBox = amount.TextBox
local purchase2 = purchase.Purchase
local header = kaitosShop.Header
local item = script.Item
local v = {
	ItemOrFish = { "fish", "items" },
	Bait = { "bait" },
	Lantern = { "lanterns" },
	Rod = { "rods" },
	Spear = { "spears" }
}
local color = item:FindFirstChildOfClass("UIStroke") and item:FindFirstChildOfClass("UIStroke").Color or Color3.new(
	0,
	0,
	0
)
local color2 = Color3.fromRGB(130, 197, 255)
local v2 = {
	1,
	1.05,
	1.125,
	1.05,
	1
}
local v3 = nil
local v4 = nil
local v5 = 1
local clones = {}
local v6 = {}
local v7 = false
local maid = Trove.new()
local KaitosShopController = {}

local function commaValue(p: number)
	local v8 = tostring((math.ceil(p)))

	repeat
		local v9
		v8, v9 = string.gsub(v8, "^(-?%d+)(%d%d%d)", "%1,%2")
	until v9 == 0

	return v8
end

local function formatCountdown(p: number)
	local v8 = math.max(0, (math.floor(p)))
	local v9 = math.floor(v8 / 86400)
	local v10 = math.floor(v8 % 86400 / 3600)
	local v11 = math.floor(v8 % 3600 / 60)
	local v12 = v8 % 60
	return string.format("%d:%02d:%02d:%02d", v9, v10, v11, v12)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isPaidRestricted()
	return localPlayer:GetAttribute("PolicyPaidRandomItemsRestricted") == true
end

local function resolveIcon(item2)
	for _, v8 in v[item2.rewardType] or {} do
		local v9 = library[v8] and library[v8][item2.name]

		if v9 and v9.Icon then
			return v9.Icon
		end
	end

	return ""
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSelectedEntry()
	if v3 and v4 then
		return v3.Items[v4]
	end

	return nil
end

local function updatePurchaseLabel()
	local selectedEntry = getSelectedEntry() -- equivalent call inferred; original call site unknown

	if selectedEntry then
		if selectedEntry.remaining <= 0 then
			purchase2.Header.Text = ""
			purchase2.Label.Text = "Sold Out"
		else
			purchase2.Header.Text = `Purchase <font color="#82c5ff"><b><i>x{v5}</i></b></font>`
			purchase2.Label.Text = `{commaValue(selectedEntry.price * v5)}C$`
		end
	else
		purchase2.Header.Text = "Purchase"
		purchase2.Label.Text = ""
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setSelectedAmount(p: number)
	local selectedEntry = getSelectedEntry() -- equivalent call inferred; original call site unknown
	local v8 = selectedEntry and math.max(1, selectedEntry.remaining) or 1
	v5 = math.clamp(math.floor(p), 1, v8)
	textBox.Text = `{v5}x`
	updatePurchaseLabel()
end

local function sanitizeAmountText(value: string)
	local v8 = string.match(value, "^(%d+)")

	if not v8 then
		return ""
	end

	if string.sub(value, #v8 + 1, #v8 + 1) == "x" then
		return v8 .. "x"
	end

	return v8
end

local function selectItem(p: string)
	if not (v3 and v3.Items[p]) then
		return
	end

	v4 = p

	for k, v8 in clones do
		local uIStroke = v8:FindFirstChildOfClass("UIStroke")

		if not uIStroke then
			continue
		end

		local color3

		if k == p then
			color3 = color2
		else
			color3 = color
		end

		uIStroke.Color = color3
	end

	local selectedEntry = getSelectedEntry() -- equivalent call inferred; original call site unknown
	v5 = math.clamp(1, 1, selectedEntry and math.max(1, selectedEntry.remaining) or 1)
	textBox.Text = `{v5}x`
	updatePurchaseLabel()
end

local function updateRefreshButtons()
	local rerolls = v3 and v3.Rerolls or {}

	for _, v8 in v6 do
		local source = KaitosShopConfig.ResolveSource(localPlayer, v8.Config, rerolls)
		v8.Source = source
		local rerollSource = KaitosShopConfig.RerollSources[source]
		v8.Instance.Visible = not rerollSource.RestrictedByPolicy or localPlayer:GetAttribute("PolicyPaidRandomItemsRestricted") ~= true
		v8.Instance.Rerolls.Text = rerolls[source] or 0

		if rerollSource.ProductId then
			v8.Instance.Label.Text = `{Monetization:GetRobuxPrice(rerollSource.ProductId, false)}`
		elseif rerollSource.Label then
			v8.Instance.Label.Text = `{rerollSource.Display or ""}{rerollSource.Label}`
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function refreshHeader()
	if not v3 then
		header.RefreshTime.Text = ""
		return
	end

	local v8 = v3.ExpiresAt - DateTime.now().UnixTimestamp
	local refreshTime = header.RefreshTime
	local v9 = math.max(0, (math.floor(v8)))
	local v10 = math.floor(v9 / 86400)
	local v11 = math.floor(v9 % 86400 / 3600)
	local v12 = math.floor(v9 % 3600 / 60)
	local v13 = v9 % 60
	refreshTime.Text = `Refresh: {string.format("%d:%02d:%02d:%02d", v10, v11, v12, v13)}`
end

local function rebuildItems()
	maid:Clean()
	table.clear(clones)

	if not v3 then
		return
	end

	local v8 = {}

	for k in v3.Items do
		table.insert(v8, k)
	end

	table.sort(v8, function(a, b)
		return (tonumber(a) or 0) < (tonumber(b) or 0)
	end)

	for k, name in v8 do
		local item2 = v3.Items[name]
		local clone = item:Clone()
		clone.Name = name
		clone.LayoutOrder = k
		clone.Size = UDim2.fromScale(1, v2[k] or 1)
		clone.ItemName.Text = item2.displayName or item2.name
		clone.Price.Text = `{commaValue(item2.price)}C$`
		clone.Stock.Text = `x{math.max(item2.remaining, 0)}`
		clone.ImageLabel.Image = resolveIcon(item2)
		clone.SoldOut.Visible = item2.remaining <= 0
		clone.Visible = true
		clone.Parent = items
		clones[name] = clone
		maid:Add(clone)
		local v10 = name
		maid:Add(clone.Activated:Connect(function()
			selectItem(v10)
		end))
	end

	if v4 and v3.Items[v4] then
		selectItem(v4)
		return
	end

	if v8[1] then
		selectItem(v8[1])
		return
	end

	v4 = nil
	updatePurchaseLabel()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyState(p)
	v3 = p
	rebuildItems()
	updateRefreshButtons()
	refreshHeader() -- equivalent call inferred; original call site unknown
end

local function setupRefreshButton(refreshButton)
	local child = purchase:FindFirstChild(refreshButton.Button)

	if not child then
		warn((`[KaitosShop] missing refresh button {refreshButton.Button}`))
		return
	end

	local v8 = {
		Instance = child,
		Config = refreshButton,
		Source = refreshButton.Sources[#refreshButton.Sources]
	}
	table.insert(v6, v8)
	child.MouseButton1Click:Connect(function()
		if ViewOddsController.IsLoading then
			return
		end

		local rerolls = v3 and v3.Rerolls or {}
		local source = v8.Source
		local rerollSource = KaitosShopConfig.RerollSources[source]

		if not KaitosShopConfig.IsSourceUnlocked(localPlayer, source, rerolls) then
			return
		end

		local v9

		if rerollSource.ConfirmOdds == "Always" then
			v9 = true
		elseif rerollSource.ConfirmOdds == "IfRestricted" then
			v9 = isPaidRestricted()
		else
			v9 = false
		end

		if v9 then
			local promptConfirmOdds = ViewOddsController.PromptConfirmOdds(KaitosShopConfig.OddsKey)
			kaitosShop.Visible = true

			if not promptConfirmOdds then
				return
			end
		end

		remoteEvent:FireServer(source)
	end)
end

function KaitosShopController:Toggle(visible: boolean?)
	if visible == nil then
		visible = not kaitosShop.Visible
	end

	if visible == kaitosShop.Visible then
		return
	end

	kaitosShop.Visible = visible
end

function KaitosShopController:Purchase()
	local selectedEntry = getSelectedEntry() -- equivalent call inferred; original call site unknown

	if not selectedEntry or not v4 or v7 or selectedEntry.remaining <= 0 then
		return
	end

	v7 = true
	local v8 = v4
	local v9 = v5
	task.spawn(function()
		local success, result = pcall(function()
			return remoteFunction2:InvokeServer(v8, v9)
		end)
		task.delay(0.5, function()
			v7 = false
		end)

		if success and typeof(result) == "table" then
			applyState(result) -- equivalent call inferred; original call site unknown
		end
	end)
end

function KaitosShopController.Start(_)
	item.Parent = nil

	for _, guiObject in items:GetChildren() do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	for _, refreshButton in KaitosShopConfig.RefreshButtons do
		setupRefreshButton(refreshButton)
	end

	updateRefreshButtons()
	localPlayer:GetAttributeChangedSignal("PolicyPaidRandomItemsRestricted"):Connect(updateRefreshButtons)
	less.Activated:Connect(function()
		setSelectedAmount(v5 - 1) -- equivalent call inferred; original call site unknown
	end)
	more.Activated:Connect(function()
		setSelectedAmount(v5 + 1) -- equivalent call inferred; original call site unknown
	end)
	max.Activated:Connect(function()
		local selectedEntry = getSelectedEntry() -- equivalent call inferred; original call site unknown

		if selectedEntry then
			setSelectedAmount(selectedEntry.remaining) -- equivalent call inferred; original call site unknown
		end
	end)
	textBox.FocusLost:Connect(function()
		setSelectedAmount(tonumber((string.match(textBox.Text, "%d+"))) or 1) -- equivalent call inferred; original call site unknown
	end)
	textBox:GetPropertyChangedSignal("Text"):Connect(function()
		local text = textBox.Text
		local text2 = string.match(text, "^(%d+)")

		if text2 then
			if string.sub(text, #text2 + 1, #text2 + 1) == "x" then
				text2 ..= "x"
			end
		else
			text2 = ""
		end

		if text2 ~= textBox.Text then
			textBox.Text = text2
		end
	end)
	purchase2.Activated:Connect(function()
		KaitosShopController:Purchase()
	end)
	kaitosShop.Close.Activated:Connect(function()
		KaitosShopController:Toggle(false)
	end)
	kaitosShop.viewChances.Activated:Connect(function()
		ViewOddsController.ShowOdds("kaitosShop")
	end)
	remoteEvent2.OnClientEvent:Connect(function(p)
		if typeof(p) == "table" then
			applyState(p) -- equivalent call inferred; original call site unknown
		end
	end)
	remoteEvent3.OnClientEvent:Connect(function(p)
		if not v3 then
			local success, result = pcall(function()
				return remoteFunction:InvokeServer()
			end)

			if success and typeof(result) == "table" then
				applyState(result) -- equivalent call inferred; original call site unknown
			end
		end

		KaitosShopController:Toggle(p)
	end)
	task.spawn(function()
		while true do
			refreshHeader() -- equivalent call inferred; original call site unknown
			task.wait(1)
		end
	end)
end

return KaitosShopController