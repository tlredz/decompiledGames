local MobileCatalogLayout = require(script.Parent.MobileCatalogLayout)
local v = {}

local function set(p, p2, p3)
	if not p or p[p2] == p3 then
		return
	end

	v[p] = v[p] or {}

	if v[p][p2] == nil then
		v[p][p2] = { p[p2] }
	end

	p[p2] = p3
end

local function box(p, p2, p3, p4, p5)
	if not p then
		return
	end

	set(p, "AnchorPoint", Vector2.zero)
	set(p, "Position", UDim2.fromOffset(p2, p3))
	set(p, "Size", UDim2.fromOffset(p4, p5))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function font(p, p2)
	if p then
		set(p, "TextSize", p2)
		set(p, "TextScaled", false)
	end
end

local function at(child, value)
	for childName in value:gmatch("[^.]+") do
		child = child:FindFirstChild(childName)

		if not child then
			return
		end
	end

	return child
end

local function unscale(instance)
	for _, child in instance:GetChildren() do
		if child:IsA("UIScale") then
			set(child, "Scale", 1)
		elseif child:IsA("UISizeConstraint") then
			set(child, "MinSize", Vector2.zero)
			set(child, "MaxSize", Vector2.new(4096, 4096))
		end
	end
end

local function fill(instance)
	local absoluteSize = instance:FindFirstAncestorWhichIsA("ScreenGui").AbsoluteSize
	local v2 = math.min(900, absoluteSize.X - 20)
	local v3 = math.min(680, absoluteSize.Y - 20)
	unscale(instance)
	set(instance, "AnchorPoint", Vector2.new(0.5, 0.5))
	set(instance, "Position", UDim2.fromScale(0.5, 0.5))
	set(instance, "Size", UDim2.fromOffset(v2, v3))
	return v2, v3
end

local function fit(parent)
	if not parent then
		return
	end

	local absoluteSize = parent:FindFirstAncestorWhichIsA("ScreenGui").AbsoluteSize
	local size = parent.Size
	local offset = size.X.Offset
	local offset2 = size.Y.Offset

	if offset < 1 or offset2 < 1 then
		return
	end

	local v2 = parent:FindFirstChildOfClass("UIScale")

	if not v2 then
		v2 = Instance.new("UIScale")
		v2.Name = "MobileFitScale"
		v2.Parent = parent
	end

	set(v2, "Scale", math.min(1, (absoluteSize.X - 20) / offset, (absoluteSize.Y - 20) / offset2))
	set(parent, "AnchorPoint", Vector2.new(0.5, 0.5))
	set(parent, "Position", UDim2.fromScale(0.5, 0.5))
end

return {
	Apply = function(p)
		if MobileCatalogLayout.IsMobile() then
			for _, v2 in {
				"EditorToolsGui.Panel",
				"GamepassPerkControls.Frame",
				"UGCClaimGui.Help",
				"GiveawayGui.Shade.Panel",
				"SaveOutfitShortcutGui.ResetConfirmation.Dialog",
				"CoinGiftDialogGui.Shield.Panel",
				"UGCVIPBenefitsGui.Shield.Panel"
			} do
				fit(at(p, v2))
			end

			local v2 = at(p, "CommunityGui.Root.Panel")

			if v2 then
				local v3, v4 = fill(v2)
				box(v2.Title, 12, 6, v3 - 104, 44)
				font(v2.Title, 22) -- equivalent call inferred; original call site unknown
				box(v2.Close, v3 - 80, 6, 68, 44)
				set(v2.Subtitle, "Visible", false)
				box(v2.SearchInput, 12, 58, v3 - 172, 44)
				box(v2.Search, v3 - 152, 58, 64, 44)
				box(v2.Filters, v3 - 80, 58, 68, 44)
				box(v2.Tabs, 12, 110, v3 - 24, 46)
				box(v2.Status, 12, 160, v3 - 24, 32)
				font(v2.Status, 12) -- equivalent call inferred; original call site unknown
				box(v2.Results, 12, 198, v3 - 24, v4 - 208)

				for _, button in v2.Tabs:GetChildren() do
					if not button:IsA("GuiButton") then
						continue
					end

					set(button, "Size", UDim2.fromOffset(math.max(90, #button.Text * 7 + 20), 44))
					font(button, 13) -- equivalent call inferred; original call site unknown
				end

				local publishPanel = v2.PublishPanel
				box(publishPanel.Title, 12, 8, v3 - 24, 40)
				font(publishPanel.Title, 21) -- equivalent call inferred; original call site unknown
				box(publishPanel.Explanation, 12, 54, v3 - 24, 54)
				font(publishPanel.Explanation, 13) -- equivalent call inferred; original call site unknown
				box(publishPanel.OutfitName, 12, 116, v3 - 24, 44)
				box(publishPanel.Status, 12, 166, v3 - 24, math.max(30, v4 - 228))
				font(publishPanel.Status, 12) -- equivalent call inferred; original call site unknown
				box(publishPanel.Cancel, 12, v4 - 56, (v3 - 32) / 2, 44)
				box(publishPanel.Confirm, v3 / 2 + 4, v4 - 56, (v3 - 32) / 2, 44)
			end

			local v3 = at(p, "WearingGui")

			if v3 then
				local OutfitHubLayout = require(game.ReplicatedStorage.OutfitHubLayout)
				OutfitHubLayout.Apply(v3)
			end

			local v4 = at(p, "GamepassStoreGui.Root.Panel")

			if v4 then
				local v5, v6 = fill(v4)
				box(v4.Title, 12, 6, v5 - 112, 44)
				font(v4.Title, 22) -- equivalent call inferred; original call site unknown
				box(v4.Close, v5 - 88, 6, 76, 44)
				box(v4.Subtitle, 12, 54, v5 - 24, 28)
				font(v4.Subtitle, 12) -- equivalent call inferred; original call site unknown
				box(v4.Categories, 12, 88, v5 - 24, 44)

				for _, button in v4.Categories:GetChildren() do
					if not (button:IsA("GuiButton") and button) then
						continue
					end

					set(button, "TextSize", 15)
					set(button, "TextScaled", false)
				end

				box(v4.Packs, 12, 140, v5 - 24, v6 - 192)
				box(v4.Status, 12, v6 - 44, v5 - 24, 36)
				font(v4.Status, 12) -- equivalent call inferred; original call site unknown
				local coins = v4.Coins
				box(coins.Packs, 12, 140, v5 - 24, v6 - 192)
				box(coins.Status, 12, v6 - 44, v5 - 24, 36)
				font(coins.Status, 12) -- equivalent call inferred; original call site unknown

				for _, frame in coins.Packs:GetChildren() do
					if not frame:IsA("Frame") then
						continue
					end

					local v7 = v5 - 32

					if v5 < 520 then
						set(frame, "Size", UDim2.new(1, -8, 0, 116))
						box(frame:FindFirstChild("CoinIcon"), 8, 8, 44, 44)
						box(frame:FindFirstChild("Coins"), 60, 8, v7 - 68, 26)
						box(frame:FindFirstChild("Value"), 60, 36, v7 - 68, 22)
						box(frame:FindFirstChild("Buy"), 8, 64, v7 - 68, 44)
						box(frame:FindFirstChild("Gift"), v7 - 52, 64, 44, 44)
					else
						set(frame, "Size", UDim2.new(1, -8, 0, 68))
						box(frame:FindFirstChild("CoinIcon"), 12, 10, 48, 48)
						box(frame:FindFirstChild("Coins"), 74, 8, v7 - 292, 26)
						box(frame:FindFirstChild("Value"), 74, 36, v7 - 292, 22)
						box(frame:FindFirstChild("Buy"), v7 - 202, 12, 128, 44)
						box(frame:FindFirstChild("Gift"), v7 - 64, 10, 48, 48)
					end

					font(frame:FindFirstChild("Coins"), 16) -- equivalent call inferred; original call site unknown
					font(frame:FindFirstChild("Value"), 11) -- equivalent call inferred; original call site unknown
				end

				for _, frame in v4.Packs:GetChildren() do
					if not frame:IsA("Frame") then
						continue
					end

					if v5 < 520 then
						set(frame, "Size", UDim2.new(1, -8, 0, 178))
						local v7 = v5 - 32
						box(frame:FindFirstChild("PassIcon"), 8, 8, 64, 64)
						box(frame:FindFirstChild("Name"), 82, 8, v7 - 90, 30)
						font(frame:FindFirstChild("Name"), 17) -- equivalent call inferred; original call site unknown
						box(frame:FindFirstChild("Description"), 82, 44, v7 - 90, 62)
						font(frame:FindFirstChild("Description"), 12) -- equivalent call inferred; original call site unknown
						box(frame:FindFirstChild("Buy"), 8, 112, v7 - 16, 44)
						box(frame:FindFirstChild("Availability"), 8, 156, v7 - 16, 20)
						font(frame:FindFirstChild("Availability"), 11) -- equivalent call inferred; original call site unknown
					else
						local v7 = v5 - 32
						set(frame, "Size", UDim2.new(1, -8, 0, 104))
						box(frame:FindFirstChild("PassIcon"), 12, 12, 80, 80)
						box(frame:FindFirstChild("Name"), 108, 12, v7 - 280, 26)
						font(frame:FindFirstChild("Name"), 17) -- equivalent call inferred; original call site unknown
						box(frame:FindFirstChild("Description"), 108, 42, v7 - 280, 52)
						font(frame:FindFirstChild("Description"), 12) -- equivalent call inferred; original call site unknown
						box(frame:FindFirstChild("Buy"), v7 - 154, 18, 138, 44)
						box(frame:FindFirstChild("Availability"), v7 - 154, 67, 138, 22)
					end

					local giftVIP = frame:FindFirstChild("GiftVIP")

					if not giftVIP then
						continue
					end

					local v7 = v5 - 32
					set(frame:FindFirstChild("Availability"), "Visible", false)

					if v5 < 520 then
						local v8 = (v7 - 24) / 2
						box(frame.Buy, 8, 112, v8, 44)
						box(giftVIP, 16 + v8, 112, v8, 44)
					else
						set(frame, "Size", UDim2.new(1, -8, 0, 116))
						box(frame.Buy, v7 - 154, 10, 138, 44)
						box(giftVIP, v7 - 154, 62, 138, 44)
					end

					font(giftVIP, 14) -- equivalent call inferred; original call site unknown
				end
			end

			local v5 = at(p, "UGCClaimGui.Panel")

			if v5 then
				local v6, v7 = fill(v5)
				local v8 = v7 < 400
				local details = v5.Details
				box(v5.Title, 12, 6, v6 - (v8 and 280 or 232), 44)
				font(v5.Title, 20) -- equivalent call inferred; original call site unknown
				box(v5:FindFirstChild("VIP"), v6 - (v8 and 252 or 204), 6, 88, 44)
				font(v5:FindFirstChild("VIP"), 14) -- equivalent call inferred; original call site unknown
				box(v5.Close, v6 - 56, 6, 44, 44)
				font(v5.Close, 12) -- equivalent call inferred; original call site unknown
				box(v5.CoinHelp, v6 - 108, 6, 44, 44)
				box(v5.Back, 12, 6, 110, 44)
				set(v5.Title, "Visible", not v5.Back.Visible)
				box(v5.Subtitle, 12, v8 and 52 or 56, v6 - 24, v8 and 32 or 46)
				font(v5.Subtitle, 12) -- equivalent call inferred; original call site unknown

				if v8 then
					box(v5.CoinShop, v6 - 164, 6, 48, 44)
				else
					box(v5.CoinShop, v6 - 64, v7 - 60, 52, 52)
				end

				box(v5.RewardTabs, 12, v8 and 88 or 110, v6 - 24, 44)

				for _, button in v5.RewardTabs:GetChildren() do
					if not button:IsA("GuiButton") then
						continue
					end

					set(button, "Size", UDim2.new(button.Size.X.Scale, button.Size.X.Offset, 0, 44))
					font(button, 13) -- equivalent call inferred; original call site unknown
				end

				local v9 = v8 and 140 or 162
				box(v5.Rewards, 12, v9, v6 - 24, v7 - v9 - (v8 and 38 or 70))
				box(v5.Status, 12, v7 - (v8 and 34 or 62), v6 - (v8 and 24 or 88), v8 and 28 or 54)
				font(v5.Status, 12) -- equivalent call inferred; original call site unknown
				local uIGridLayout = v5.Rewards:FindFirstChildOfClass("UIGridLayout")

				if uIGridLayout then
					local v10 = math.max(1, v6 - 24 - v5.Rewards.ScrollBarThickness)
					local v11 = math.max(2, (math.floor((v10 + 12) / 192)))
					set(uIGridLayout, "CellPadding", UDim2.fromOffset(12, 12))
					set(uIGridLayout, "CellSize", UDim2.fromOffset(math.floor((v10 - (v11 - 1) * 12) / v11), 250))
				end

				local v10 = v8 and 88 or 108
				box(details, 0, v10, v6, v7 - v10 - (v8 and 38 or 70))
				local v11 = v8 and 144 or 132
				local v12 = v11 + 24
				local v13 = v6 - v12 - 12
				box(details.ItemImage, 12, 4, v11, v11)
				box(details.ItemName, v12, 4, v13, v8 and 38 or 66)
				font(details.ItemName, v8 and 18 or 17) -- equivalent call inferred; original call site unknown
				box(details.Stock, v12, v8 and 44 or 74, v13, 24)
				font(details.Stock, 12) -- equivalent call inferred; original call site unknown
				box(details.Price, v12, v8 and 70 or 108, v13, 24)
				font(details.Price, 16) -- equivalent call inferred; original call site unknown
				box(details.Balance, v12, v8 and 96 or 142, v13, 24)
				font(details.Balance, 12) -- equivalent call inferred; original call site unknown

				if v8 then
					box(details.Redeem, v12, 124, (v13 - 8) / 2, 44)
					font(details.Redeem, 13) -- equivalent call inferred; original call site unknown
					box(details:FindFirstChild("Gift"), v12 + (v13 + 8) / 2, 124, (v13 - 8) / 2, 44)
					font(details:FindFirstChild("Gift"), 13) -- equivalent call inferred; original call site unknown
				else
					box(details.Redeem, 12, 190, v6 - 24, 44)
					box(details:FindFirstChild("Gift"), 12, 242, v6 - 24, 44)
				end

				local coinShopPanel = v5.CoinShopPanel
				box(coinShopPanel.Title, 12, 6, v6 - 134, 44)
				font(coinShopPanel.Title, 21) -- equivalent call inferred; original call site unknown
				box(coinShopPanel.Back, v6 - 114, 6, 102, 44)
				box(coinShopPanel.Subtitle, 12, 56, v6 - 24, 40)
				font(coinShopPanel.Subtitle, 12) -- equivalent call inferred; original call site unknown
				box(coinShopPanel.Packs, 12, 104, v6 - 24, v7 - 158)
				box(coinShopPanel.Status, 12, v7 - 44, v6 - 24, 36)
				font(coinShopPanel.Status, 12) -- equivalent call inferred; original call site unknown

				for _, frame in coinShopPanel.Packs:GetChildren() do
					if not frame:IsA("Frame") then
						continue
					end

					local v15 = v6 - 32

					if v6 < 520 then
						set(frame, "Size", UDim2.new(1, -8, 0, 116))
						box(frame:FindFirstChild("CoinIcon"), 8, 8, 44, 44)
						box(frame:FindFirstChild("Coins"), 60, 8, v15 - 68, 26)
						box(frame:FindFirstChild("Value"), 60, 36, v15 - 68, 22)
						box(frame:FindFirstChild("Buy"), 8, 64, v15 - 68, 44)
						box(frame:FindFirstChild("Gift"), v15 - 52, 64, 44, 44)
					else
						set(frame, "Size", UDim2.new(1, -8, 0, 68))
						box(frame:FindFirstChild("CoinIcon"), 12, 10, 48, 48)
						box(frame:FindFirstChild("Coins"), 74, 8, v15 - 292, 26)
						box(frame:FindFirstChild("Value"), 74, 36, v15 - 292, 22)
						box(frame:FindFirstChild("Buy"), v15 - 202, 12, 128, 44)
						box(frame:FindFirstChild("Gift"), v15 - 64, 10, 48, 48)
					end

					font(frame:FindFirstChild("Coins"), 16) -- equivalent call inferred; original call site unknown
					font(frame:FindFirstChild("Value"), 11) -- equivalent call inferred; original call site unknown
				end
			end

			local v6 = at(p, "GiveawayGui.Shade.Panel")

			if v6 then
				local v7, v8 = fill(v6)
				local v9 = math.min(600, v7)
				local v10 = math.min(450, v8)
				set(v6, "Size", UDim2.fromOffset(v9, v10))
				box(v6.Title, 12, 6, v9 - 84, 44)
				font(v6.Title, 16) -- equivalent call inferred; original call site unknown
				box(v6.Close, v9 - 56, 6, 44, 44)

				if v10 < 400 then
					local v11 = math.floor(v9 * 0.52)
					local v12 = v11 + 24
					local v13 = v9 - v12 - 12
					box(v6.Prize, 12, 58, v11, 44)
					font(v6.Prize, 24) -- equivalent call inferred; original call site unknown
					box(v6.Timer, 12, 108, v11, 28)
					box(v6.Entrants, 12, 142, v11, 28)
					box(v6.Rules, 12, 178, v11, 78)
					font(v6.Rules, 13) -- equivalent call inferred; original call site unknown
					box(v6.Join, v12, 62, v13, 44)
					box(v6.Status, v12, 118, v13, 64)
					box(v6.PreviousWinner, v12, 190, v13, 68)
				else
					box(v6.Prize, 12, 60, v9 - 24, 44)
					font(v6.Prize, 24) -- equivalent call inferred; original call site unknown
					box(v6.Timer, 12, 112, v9 - 24, 28)
					box(v6.Entrants, 12, 146, v9 - 24, 28)
					box(v6.Rules, 12, 182, v9 - 24, 64)
					font(v6.Rules, 13) -- equivalent call inferred; original call site unknown
					box(v6.Join, 12, 256, v9 - 24, 44)
					box(v6.Status, 12, 310, v9 - 24, 56)
					box(v6.PreviousWinner, 12, 374, v9 - 24, 58)
				end
			end

			local v7 = at(p, "BackgroundPreviewGui.Stage")

			if v7 then
				local absoluteSize = v7.AbsoluteSize
				local X = absoluteSize.X
				local Y = absoluteSize.Y
				local controls = v7.Controls
				unscale(controls)
				box(controls, 12, Y - 108, X - 24, 100)
				local v8 = (X - 42) / 4

				for k, childName in {
					"Exit",
					"Change",
					"Rotate",
					"Front",
					"Hide",
					"Details",
					"Buy"
				} do
					box(
						controls:FindFirstChild(childName),
						(k - 1) % 4 * (v8 + 6),
						math.floor((k - 1) / 4) * 52,
						v8,
						44
					)
					font(controls:FindFirstChild(childName), 12) -- equivalent call inferred; original call site unknown
				end

				box(v7.ShowControls, X - 162, Y - 56, 150, 44)
				box(v7.Status, 12, 4, X - 24, 36)
				font(v7.Status, 12) -- equivalent call inferred; original call site unknown
				box(v7.Avatar, 0, 0, X, Y - 116)

				for _, v9 in { v7.Picker, v7.ItemDetails } do
					box(v9, 12, 8, X - 24, Y - 128)
					box(v9.Title, 12, 6, X - 116, 44)
					font(v9.Title, 19) -- equivalent call inferred; original call site unknown
					box(v9.Close, X - 80, 6, 44, 44)
				end

				box(v7.Picker.Items, 12, 58, X - 48, Y - 198)
				box(v7.ItemDetails.Content, 12, 58, X - 48, math.max(24, Y - 252))
				box(v7.ItemDetails.Buy, 12, Y - 188, X - 48, 44)
			end
		else
			for k, v2 in v do
				if not k.Parent then
					continue
				end

				for k2, v3 in v2 do
					k[k2] = v3[1]
				end
			end

			v = {}
		end
	end
}