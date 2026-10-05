local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local packages = ReplicatedStorage:WaitForChild("Packages")
require(packages.Synchronizer)
local Observers = require(packages.Observers)
local vide = require(packages.vide)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)
local Shop = require(ReplicatedStorage.Datas.Shop)
local BeeShopFlags = require(ReplicatedStorage.Shared.Flags.BeeShopFlags)
require(ReplicatedStorage.Shared.Updates)
local Reactive = require(script.Parent.Reactive)
local Prices = require(script.Parent.Prices)
require(script.Parent.State)
local root = vide.root
local source = vide.source
local derive = vide.derive
local effect = vide.effect
local v = {}

for k, v2 in Shop do
	if not (type(k) == "number" and type(v2) == "table" and v2.Type == "GamepassProduct" and v2.Display) then
		continue
	end

	v[v2.Display] = k
end

-- equivalent calls inferred from this helper; original call sites unknown
local function productIdOf(p)
	return (tonumber(p.Name))
end

local function giftBaseOf(instance, p: number)
	local forceProductId = instance:GetAttribute("ForceProductId") or instance:GetAttribute("ProductId")

	if type(forceProductId) == "number" then
		return forceProductId
	end

	local v3 = Shop[p]
	local v4 = v3 and v3.Type == "Gamepass" and not v3.GiftProduct and v[v3.Display]
	return v4 or p
end

local function priceLabelOf(instance)
	local price = instance:FindFirstChild("Price") or instance:FindFirstChild("Txt")

	if price and price:IsA("TextLabel") then
		return price
	end

	return nil
end

local function hydratePurchase(instance, p: number, p2: string, p3, callback)
	local buy = instance:FindFirstChild("Buy")

	if not (buy and buy:IsA("GuiButton")) then
		warn((`ShopUI.Cards: {instance:GetFullName()} has no Buy button`))
		return
	end

	local forceProductId = instance:GetAttribute("ForceProductId") or instance:GetAttribute("ProductId")

	if type(forceProductId) ~= "number" then
		local v3 = Shop[p]

		if v3 and v3.Type == "Gamepass" and not v3.GiftProduct then
			forceProductId = v[v3.Display] or p
		else
			forceProductId = p
		end
	end

	local v3 = derive(function()
		return p3.GiftTarget() ~= nil
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function purchaseBase()
		if p3.GiftTarget() then
			return forceProductId
		end

		return p
	end

	local v4 = derive(function()
		local v6 = purchaseBase() -- equivalent call inferred; original call site unknown
		return p3:ResolveProductId(v6)
	end)
	local v5 = derive(function()
		if v3() then
			return "Product"
		end

		return p2
	end)
	local text = Prices.Text(v4, v5)
	local price = buy:FindFirstChild("Price") or buy:FindFirstChild("Txt")

	if not (price and price:IsA("TextLabel")) then
		price = nil
	end

	if price then
		Reactive.Hydrate(price, {
			Text = function()
				if callback() and not v3() then
					return "Owned"
				end

				return text()
			end
		})
	end

	instance:AddTag("ProductFrame")
	Reactive.Button(buy, function()
		local v7 = purchaseBase() -- equivalent call inferred; original call site unknown
		p3:Buy(v7)
	end)
end

local function hydrateIcon(icon, p: number, p2: string)
	if not icon then
		return
	end

	local v3 = Shop[p]
	local icon2 = v3 and v3.Icon

	if icon2 then
		icon.ScaleType = Enum.ScaleType.Fit
		icon.Image = icon2
	else
		local productInfo = Reactive.ProductInfo(p, p2)
		effect(function()
			local v4 = productInfo()

			if v4 and v4.Icon then
				icon.ScaleType = Enum.ScaleType.Fit
				icon.Image = v4.Icon
			end
		end)
	end
end

local function hydrateCashProduct(instance, p)
	local v3 = productIdOf(instance) -- equivalent call inferred; original call site unknown
	local v4 = v3 and Shop[v3]

	if not (v3 and v4) then
		return
	end

	hydrateIcon(instance:FindFirstChild("Icon"), v3, "Product")
	hydratePurchase(instance, v3, "Product", p, source(false))
	local amount = instance:FindFirstChild("Amount")

	if amount and amount:IsA("TextLabel") then
		local v5 = Reactive.FromChannelPath({ "Rebirth" }, 0)
		Reactive.Hydrate(amount, {
			Text = function()
				local value = v4.Value or 0
				local v6 = v5()

				if v6 > 0 then
					value *= v6 <= 1 and 1.5 or v6
				end

				return (`${NumberUtils:Comma(value)}`)
			end
		})
	end
end

local function hydrateCarpetSwap(guiObject, object)
	local guiObject2 = guiObject.Parent and guiObject.Parent:FindFirstChild((tostring(3709239100)))

	if not (guiObject:IsA("GuiObject") and guiObject2 and guiObject2:IsA("GuiObject")) then
		return
	end

	local v3 = derive(function()
		local giftTarget = object.GiftTarget()

		if giftTarget then
			return (Players:GetPlayerByUserId(giftTarget))
		end

		return Players.LocalPlayer
	end)
	local v4 = source(false)
	local fFlag = Reactive.FFlag(BeeShopFlags.Enabled)
	local fFlag2 = Reactive.FFlag(BeeShopFlags.GearEndTimer)
	effect(function()
		local v5 = v3()

		if not v5 then
			v4(false)
			return
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			v4(v5:GetAttribute("HasFlyingCarpet") == true)
		end

		Reactive.Trove():Add(v5:GetAttributeChangedSignal("HasFlyingCarpet"):Connect(update))
		update() -- equivalent call inferred; original call site unknown
	end)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function updateLayoutOrder()
		guiObject2.LayoutOrder = guiObject.LayoutOrder
	end

	Reactive.Trove():Add(guiObject:GetPropertyChangedSignal("LayoutOrder"):Connect(updateLayoutOrder))
	updateLayoutOrder() -- equivalent call inferred; original call site unknown
	effect(function()
		object.UpdatesRevision()
		local visible = v4() and fFlag() and object.Clock() < fFlag2()
		guiObject.Visible = not visible
		guiObject2.Visible = visible
	end)
end

local function hydrateItemProduct(instance, object)
	local v3 = productIdOf(instance) -- equivalent call inferred; original call site unknown

	if not (v3 and Shop[v3]) then
		return
	end

	hydrateIcon(instance:FindFirstChild("Icon", true), v3, "Product")
	hydratePurchase(instance, v3, "Product", object, object:Owns(v3))

	if v3 == 3290152513 then
		hydrateCarpetSwap(instance, object)
	end
end

local function hydrateGamepassProduct(p, object)
	local v3 = productIdOf(p) -- equivalent call inferred; original call site unknown

	if v3 and Shop[v3] then
		hydratePurchase(p, v3, "Gamepass", object, object:Owns(v3))
	end
end

local function hydrateStarterPack(guiObject, p)
	local v3 = Shop[3290334159]

	if not v3 then
		return
	end

	guiObject:SetAttribute("ProductId", 3290334159)
	hydratePurchase(guiObject, 3290334159, "Product", p, source(false))
	local v4 = Reactive.FromChannel(function(object)
		for _, item in v3.Rewards.Items do
			if object:Get((`Items.{item}`)) == true then
				return true
			end
		end

		return false
	end, false, {
		{
			Method = "OnDictionaryInserted",
			Path = "Items"
		},
		{
			Method = "OnChanged",
			Path = "Items"
		}
	})
	local visible = derive(function()
		return not v4() or p.GiftTarget() ~= nil
	end)

	if guiObject:IsA("GuiObject") then
		Reactive.Hydrate(guiObject, {
			Visible = visible
		})
	end

	local starterPack = guiObject:FindFirstAncestor("StarterPack")

	if starterPack and starterPack:IsA("GuiObject") then
		Reactive.Hydrate(starterPack, {
			Visible = visible
		})
	end

	local title = guiObject.Parent and guiObject.Parent:FindFirstChild("Title")

	if title and title:IsA("GuiObject") then
		Reactive.Hydrate(title, {
			Visible = visible
		})
	end
end

return table.freeze({
	Mount = function(p, p2)
		local v3 = {}

		for k, v4 in {
			CashProduct = hydrateCashProduct,
			ItemProduct = hydrateItemProduct,
			GamepassProduct = hydrateGamepassProduct,
			StarterPack = hydrateStarterPack
		} do
			local v5 = v4
			table.insert(v3, Observers.observeTag(k, function(p3)
				return root(function()
					v5(p3, p)
				end)
			end, { p2 }))
		end

		return function()
			for _, v4 in v3 do
				v4()
			end
		end
	end
})