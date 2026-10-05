local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CashPacks = require(ReplicatedStorage.Data.CashPacks)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local GUI = require(ReplicatedStorage.Client.GUI)
local MonetizationEntitlements = require(ReplicatedStorage.Shared.Util.MonetizationEntitlements)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local Products = require(ReplicatedStorage.Data.Products)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local Storefront = require(ReplicatedStorage.Client.Functions.Storefront)
local Trails = require(ReplicatedStorage.Data.Trails)
local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
local color = Color3.fromRGB(9, 255, 0)
return {
	Start = function()
		local scrollingFrame = GUI.TrailShop().Frame.ScrollingFrame
		local uIListLayout = scrollingFrame:FindFirstChildOfClass("UIListLayout")
		assert(uIListLayout ~= nil, "TrailShop.Frame.ScrollingFrame needs a UIListLayout")
		local frame = Instance.new("Frame")
		frame.Name = "TrailingGap"
		frame.BackgroundTransparency = 1
		frame.BorderSizePixel = 0
		frame.LayoutOrder = 1000000
		frame.Size = UDim2.new()
		frame.Parent = scrollingFrame
		local v = {}
		local v2 = {}

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshTrailingGap()
			local padding = uIListLayout.Padding
			local v3 = padding.Scale * scrollingFrame.AbsoluteSize.X + padding.Offset
			frame.Size = UDim2.fromOffset(math.ceil(v3), 0)
		end

		local function refreshEntry(p, p2: string)
			local v3 = Save.Await()
			assert(v3 ~= nil, "Expected local save data")
			local visible = v3.TrailInventory[p2] == true
			local v5 = v3.EquippedTrail == p2
			p.LockedControls.Visible = not visible
			p.OwnedControls.Visible = visible
			p.OwnedControls.Equip.Visible = visible and not v5
			p.OwnedControls.Unequip.Visible = visible and v5

			if not visible then
				p.LockedControls.BuyCash.Price.Text = `${Simple.FormatCompact(Trails.Directory[p2].Price, ".#")}`
				local productId = Trails.Directory[p2].ProductId
				local buyRbx = p.LockedControls.BuyRbx
				buyRbx.Visible = productId ~= nil and Products.FromProductId(productId) ~= nil and CashPacks.GetCanBuyProduct(
					CashPacks.GetPlayerGroup(Players.LocalPlayer),
					"Trail_" .. p2
				)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function showFailure(text: string)
			Toast.Show({
				Text = text,
				Color = Color3.fromRGB(255, 64, 64),
				Seconds = 3
			})
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function requestPurchase(p: string, p2)
			local v3, v4 = Remotes.Trailwear.AskPurchase:InvokeServer(p)

			if not v3 then
				Toast.Show({
					Text = v4 or "Trail request failed",
					Color = Color3.fromRGB(255, 64, 64),
					Seconds = 3
				})
			end

			refreshEntry(p2, p)
		end

		local function requestWear(p: string, p2, flag: boolean)
			local v3, v4

			if flag then
				v3, v4 = Remotes.Trailwear.AskChoose:InvokeServer(p)
			else
				v3, v4 = Remotes.Trailwear.AskDoff:InvokeServer()
			end

			if not v3 then
				Toast.Show({
					Text = v4 or "Trail request failed",
					Color = Color3.fromRGB(255, 64, 64),
					Seconds = 3
				})
			end

			refreshEntry(p2, p)
		end

		local function bindShopEntry(childName: string, layoutOrder: number)
			local v3 = Trails.Directory[childName]
			local image = scrollingFrame:FindFirstChild(childName)
			local v4

			if image == nil then
				v4 = false
			else
				v4 = image:IsA("ImageLabel")
			end

			assert(v4, (`TrailShop has no card for "{childName}"`))
			image.LayoutOrder = layoutOrder
			image.TrailName.Text = v3.DisplayName
			image.TrailRarity.Text = v3.Rarity.DisplayName
			image.Icon.Image = v3.Icon
			image.Multi.Value.RichText = true
			image.Multi.Value.Text = `<font color="#{color:ToHex()}">{TreadmillUtil.FormatSpeedMultiplierValue(v3.SpeedMultiplier)}</font> <font color="#FFFFFF">Speed</font>`
			v[childName] = {
				Card = image,
				RobuxPrice = nil
			}
			ButtonFX(image.LockedControls.BuyCash, 1.05, function()
				requestPurchase(childName, image) -- equivalent call inferred; original call site unknown
			end)
			ButtonFX(image.OwnedControls.Equip, 1.05, function()
				local v5 = childName
				local v7, v8 = Remotes.Trailwear.AskChoose:InvokeServer(v5)

				if not v7 then
					Toast.Show({
						Text = v8 or "Trail request failed",
						Color = Color3.fromRGB(255, 64, 64),
						Seconds = 3
					})
				end

				refreshEntry(image, v5)
			end)
			ButtonFX(image.OwnedControls.Unequip, 1.05, function()
				local v7, v8 = Remotes.Trailwear.AskDoff:InvokeServer()

				if not v7 then
					Toast.Show({
						Text = v8 or "Trail request failed",
						Color = Color3.fromRGB(255, 64, 64),
						Seconds = 3
					})
				end

				refreshEntry(image, childName)
			end)
			ButtonFX(image.LockedControls.BuyRbx, 1.05, function()
				local productId = v3.ProductId

				if productId == nil or Products.FromProductId(productId) == nil then
					showFailure("This trail Robux product is not configured yet") -- equivalent call inferred; original call site unknown
				else
					Storefront.Prompt(productId, true)
				end
			end)

			if v3.ProductId ~= nil and Products.FromProductId(v3.ProductId) ~= nil then
				image.LockedControls.BuyRbx.Price.Text = ""

				if not v2[v3.ProductId] then
					v2[v3.ProductId] = true
					task.spawn(function()
						local productPrice = MonetizationEntitlements.ProductPrice(v3.ProductId)
						local v5 = v[childName]

						if v5 ~= nil and productPrice > 0 then
							v5.RobuxPrice = productPrice
							image.LockedControls.BuyRbx.Price.Text = Simple.FormatCompact(productPrice, ".#")
						end
					end)
				end
			end

			refreshEntry(image, childName)
		end

		Save.Await()
		local v3 = {}

		for k, v5 in pairs(Trails.Directory) do
			if v5.DisplayInShop then
				v3[#v3 + 1] = k
			end
		end

		table.sort(v3, function(a: string, b: string)
			return Trails.Directory[a].Price < Trails.Directory[b].Price
		end)

		for i, v5 in ipairs(v3) do
			bindShopEntry(v5, i)
		end

		scrollingFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshTrailingGap)
		refreshTrailingGap() -- equivalent call inferred; original call site unknown
		Save.WatchFields({ "TrailInventory", "EquippedTrail" }, function()
			for _, v5 in ipairs(v3) do
				local v6 = v[v5]
				assert(v6 ~= nil, (`Missing trail shop entry "{v5}"`))
				refreshEntry(v6.Card, v5)
			end
		end)
		Players.LocalPlayer:GetAttributeChangedSignal(CashPacks.RevisionAttribute):Connect(function()
			for k, v5 in v do
				refreshEntry(v5.Card, k)
			end
		end)
		return {}
	end
}