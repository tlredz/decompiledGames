local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local CashPacks = require(ReplicatedStorage.Data.CashPacks)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local GUI = require(ReplicatedStorage.Client.GUI)
local GameFlags = require(ReplicatedStorage.Shared.Flags.GameFlags)
local GamepadBindings = require(ReplicatedStorage.Client.GamepadBindings)
local Gamepasses = require(ReplicatedStorage.Data.Gamepasses)
local GiftProductsMapping = require(ReplicatedStorage.Data.GiftProductsMapping)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local PlatformController = require(ReplicatedStorage.Client.PlatformController)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local Trove = require(ReplicatedStorage.Packages.Trove)
local localPlayer = Players.LocalPlayer
local shop = GUI.Shop()
local frame = shop:WaitForChild("Frame")
local giftingPopUp = shop:WaitForChild("GiftingPopUp")
local scrollingFrame = giftingPopUp:WaitForChild("ScrollingFrame")
local playerTemplate = scrollingFrame:WaitForChild("PlayerTemplate")
local pendingPurchase = localPlayer.PlayerGui:WaitForChild("PendingPurchase")
local PendingPurchaseHandler = require(pendingPurchase:WaitForChild("PendingPurchaseHandler"))
local MenuNavigation = require(ReplicatedStorage.Client.MenuNavigation)
local clone = giftingPopUp.Header.Title:Clone()
clone.Name = "CashPackNotice"
clone.Text = "Cash gifts use the receiver's pack value, which may differ from yours."
clone.AnchorPoint = Vector2.new(0.5, 0)
clone.Position = UDim2.fromScale(0.5, 0.16)
clone.Size = UDim2.new(0.92, 0, 0, 44)
clone.TextWrapped = true
clone.TextScaled = false
clone.TextSize = 16
clone.Visible = false
clone.Parent = giftingPopUp
local position = scrollingFrame.Position
local size = scrollingFrame.Size
local text = giftingPopUp.Header.Title.Text
giftingPopUp.Visible = false
local v = nil
local v2 = nil
local Gifting = {}
local v3 = {}

for _, guiObject in scrollingFrame:GetChildren() do
	if guiObject.Name == "PlayerTemplate" and guiObject:IsA("GuiObject") then
		guiObject.Visible = false
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function notify(text2: string)
	Toast.Show({
		Text = text2,
		Seconds = 5
	})
end

local function closePicker(flag: boolean?)
	local v4 = v
	v = nil
	MenuNavigation.SetOverride("Gifting", nil)
	giftingPopUp.Visible = false
	clone.Visible = false
	scrollingFrame.Position = position
	scrollingFrame.Size = size
	giftingPopUp.Header.Title.Text = text
	frame.Visible = true

	if v4 then
		v4.trove:Destroy()
	end

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(giftingPopUp) then
		GuiService.SelectedObject = nil
	end

	if flag ~= false and v4 and v4.sourceTab and v4.sourceTab ~= "Shop" and Tabs.IsActive("Shop") then
		Tabs.Activate(v4.sourceTab)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopOverlay(p)
	if p.cleanup then
		p.cleanup()
		p.cleanup = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function finish(p)
	stopOverlay(p) -- equivalent call inferred; original call site unknown

	if v2 == p then
		v2 = nil
	end
end

local function selectPlayer(data, player)
	if v ~= data or v2 then
		return
	end

	if player.Parent ~= Players then
		notify("That player has left the server.") -- equivalent call inferred; original call site unknown
		return
	end

	if not GameFlags.StorefrontOpen:Get() then
		notify("Purchases are temporarily disabled.") -- equivalent call inferred; original call site unknown
		return
	end

	if data.cashSlot and CashPacks.GetShownAmount(player, data.cashSlot) == nil then
		notify("That player's cash packs are still loading. Please try again.") -- equivalent call inferred; original call site unknown
		return
	end

	local v4 = {
		productId = data.productId,
		token = HttpService:GenerateGUID(false),
		cleanup = PendingPurchaseHandler.observePendingPurchase()
	}
	v2 = v4
	task.delay(60, function()
		if v2 == v4 then
			finish(v4) -- equivalent call inferred; original call site unknown
			notify("Your gift is still awaiting confirmation. Delivery may be delayed; please check before trying again.") -- equivalent call inferred; original call site unknown
		end
	end)
	local success, result, v5 = pcall(function()
		return Remotes.Gifting.AskGift:InvokeServer(player.UserId, data.kind, data.itemId, v4.token)
	end)

	if v2 ~= v4 then
		return
	end

	if success and result then
		closePicker()
		return
	end

	finish(v4) -- equivalent call inferred; original call site unknown
	notify((not success or type(v5) ~= "string") and "Could not start this gift. Please try again." or v5) -- equivalent call inferred; original call site unknown
end

function Gifting.Open(kind: string, itemId: number)
	if v2 then
		notify("Finish your current gift purchase first.") -- equivalent call inferred; original call site unknown
		return
	end

	local productId

	if kind == "Gamepass" then
		local v5 = Gamepasses.FromProductId(itemId)
		productId = not v5 and 0 or GiftProductsMapping[v5.Name] or 0
	else
		productId = itemId
	end

	if productId <= 0 then
		notify("Gifting is not available for this item yet.") -- equivalent call inferred; original call site unknown
		return
	end

	local sourceTab

	if v then
		sourceTab = v.sourceTab
	else
		sourceTab = Tabs.Active()
	end

	local v5 = v
	v = nil
	MenuNavigation.SetOverride("Gifting", nil)
	giftingPopUp.Visible = false
	clone.Visible = false
	scrollingFrame.Position = position
	scrollingFrame.Size = size
	giftingPopUp.Header.Title.Text = text
	frame.Visible = true

	if v5 then
		v5.trove:Destroy()
	end

	if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(giftingPopUp) then
		GuiService.SelectedObject = nil
	end

	Tabs.Activate("Shop")
	local v6 = {
		sourceTab = sourceTab,
		trove = Trove.new(),
		rows = {},
		kind = kind,
		itemId = itemId,
		productId = productId,
		cashSlot = 0
	}
	local cashSlot

	if kind == "Product" then
		cashSlot = CashPacks.FindSlot(productId)
	end

	v6.cashSlot = cashSlot
	v = v6

	if v6.cashSlot then
		giftingPopUp.Header.Title.Text = "Gift " .. CashPacks.Offers[v6.cashSlot].DisplayName
		clone.Visible = true
		scrollingFrame.Size = UDim2.new(size.X.Scale, size.X.Offset, 0.82, -52)
	end

	frame.Visible = false
	giftingPopUp.Visible = true
	MenuNavigation.SetOverride("Gifting", giftingPopUp, giftingPopUp.Close, function()
		closePicker()
	end, 1000, true)
	scrollingFrame.CanvasPosition = Vector2.zero

	local function sortRows()
		local v8 = {}

		for k in v6.rows do
			table.insert(v8, k)
		end

		table.sort(v8, function(a, b)
			local displayName = string.lower(a.DisplayName)
			local displayName2 = string.lower(b.DisplayName)

			if displayName == displayName2 then
				return a.UserId < b.UserId
			end

			return displayName < displayName2
		end)

		for k, v9 in v8 do
			v6.rows[v9].card.LayoutOrder = k
		end

		if PlatformController.IsConsole() and not (MenuNavigation.IsCursorActive() or GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(giftingPopUp)) then
			GuiService.GuiNavigationEnabled = true
			local v9 = GuiService
			local selectedObject

			if v8[1] then
				selectedObject = v6.rows[v8[1]].card.Select
			else
				selectedObject = giftingPopUp.Close
			end

			v9.SelectedObject = selectedObject
		end
	end

	local function addPlayer(player)
		if player == localPlayer or v6.rows[player] or v ~= v6 then
			return
		end

		local maid = Trove.new()
		local clone2 = playerTemplate:Clone()
		clone2.Name = tostring(player.UserId)
		clone2.PlayerNickName.Text = player.DisplayName
		clone2.PlayerName.Text = "@" .. player.Name
		clone2.PlayerIcon.Image = `rbxthumb://type=AvatarHeadShot&id={player.UserId}&w=150&h=150`
		local gift = clone2:FindFirstChild("Gift")

		if gift and gift:IsA("GuiObject") then
			gift.Visible = false
		end

		clone2.Visible = true
		clone2.Parent = scrollingFrame
		maid:Add(clone2)

		if v6.cashSlot then
			clone2.Size = UDim2.new(clone2.Size.X.Scale, clone2.Size.X.Offset, 0, 76)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function refreshGiftAmount()
				local shownAmount = CashPacks.GetShownAmount(player, v6.cashSlot)
				clone2.Select.Title.Text = not shownAmount and "Loading..." or "Gift $" .. Simple.FormatCompact(
					shownAmount,
					".#"
				)
			end

			maid:Connect(player:GetAttributeChangedSignal(CashPacks.RevisionAttribute), refreshGiftAmount)
			refreshGiftAmount() -- equivalent call inferred; original call site unknown
		end

		maid:Add(ButtonFX(clone2.Select, nil, function()
			selectPlayer(v6, player)
		end))
		v6.rows[player] = {
			card = clone2,
			trove = maid
		}
		sortRows()
	end

	v6.trove:Add(function()
		for _, row in v6.rows do
			row.trove:Destroy()
		end

		table.clear(v6.rows)
	end)
	v6.trove:Connect(Players.PlayerAdded, addPlayer)
	v6.trove:Connect(Players.PlayerRemoving, function(p3)
		local row = v6.rows[p3]

		if row then
			if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(row.card) then
				GuiService.SelectedObject = nil
			end

			row.trove:Destroy()
			v6.rows[p3] = nil
			sortRows()
		end
	end)

	for _, v8 in Players:GetPlayers() do
		addPlayer(v8)
	end

	sortRows()

	if next(v6.rows) == nil then
		notify("There are no other players in this server yet.") -- equivalent call inferred; original call site unknown
	end
end

function Gifting.Bind(p, p2: string, p3: number)
	return ButtonFX(p, nil, function()
		Gifting.Open(p2, p3)
	end)
end

ButtonFX(giftingPopUp.Close)
GamepadBindings.Inspect(giftingPopUp.Close)
GUI.OnActivated(giftingPopUp.Close, function()
	closePicker()
end)
Tabs.Deactivated:Connect(function(p)
	if p == "Shop" then
		local v4 = v
		v = nil
		MenuNavigation.SetOverride("Gifting", nil)
		giftingPopUp.Visible = false
		clone.Visible = false
		scrollingFrame.Position = position
		scrollingFrame.Size = size
		giftingPopUp.Header.Title.Text = text
		frame.Visible = true

		if v4 then
			v4.trove:Destroy()
		end

		if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(giftingPopUp) then
			GuiService.SelectedObject = nil
		end

		if v2 then
			stopOverlay(v2) -- equivalent call inferred; original call site unknown
		end
	end
end)
shop:GetPropertyChangedSignal("Enabled"):Connect(function()
	if not shop.Enabled then
		local v4 = v
		v = nil
		MenuNavigation.SetOverride("Gifting", nil)
		giftingPopUp.Visible = false
		clone.Visible = false
		scrollingFrame.Position = position
		scrollingFrame.Size = size
		giftingPopUp.Header.Title.Text = text
		frame.Visible = true

		if v4 then
			v4.trove:Destroy()
		end

		if GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(giftingPopUp) then
			GuiService.SelectedObject = nil
		end

		if v2 then
			stopOverlay(v2) -- equivalent call inferred; original call site unknown
		end
	end
end)
Remotes.Gifting.PromptFinished.OnClientEvent:Connect(function(p: number, p2: string)
	local v4 = v2

	if not v4 or v4.productId ~= p or v4.token ~= p2 then
		return
	end

	finish(v4) -- equivalent call inferred; original call site unknown
	closePicker()
end)
Remotes.Gifting.Completed.OnClientEvent:Connect(function(p, _, p2, p3)
	if v3[p2] then
		return
	end

	v3[p2] = true
	local v4 = v2

	if v4 and v4.productId == p and v4.token == p3 then
		finish(v4) -- equivalent call inferred; original call site unknown
		closePicker()
	end
end)
return Gifting