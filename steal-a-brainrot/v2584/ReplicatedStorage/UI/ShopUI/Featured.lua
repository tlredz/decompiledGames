local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ABTests = require(ReplicatedStorage.UserGenerated.ABTests)
local TimeUtils = require(ReplicatedStorage.Utils.TimeUtils)
local BaseSkins = require(ReplicatedStorage.Shared.BaseSkins)
local BeeShopFlags = require(ReplicatedStorage.Shared.Flags.BeeShopFlags)
require(ReplicatedStorage.Shared.Updates)
local Layout = require(script.Parent.Layout)
local LuckyBlocks = require(script.Parent.LuckyBlocks)
local Prices = require(script.Parent.Prices)
local Reactive = require(script.Parent.Reactive)
local State = require(script.Parent.State)
local localPlayer = Players.LocalPlayer
local v = {
	{
		Frame = "ItemsListPromo1",
		Test = "Shop.FlyingCarpetPromo",
		Cards = {
			{
				Name = "Secret Lucky Block"
			}
		}
	},
	{
		Frame = "ItemsListPromo2",
		Test = "Shop.AdminPanelPromo",
		Cards = {
			{
				Name = "Secret Lucky Block"
			}
		}
	},
	{
		Frame = "ItemsListPromo3",
		Test = "Shop.SecretLuckyBlockX3Promo",
		Cards = {
			{
				Name = "Secret Lucky Block"
			},
			{
				Name = "Secret Lucky Block x3",
				Id = "Secret Lucky Block",
				ProductId = 3437062543
			}
		}
	},
	{
		Frame = "ItemsListPromo4",
		Test = "Shop.SecretLuckyBlockX8Promo",
		Cards = {
			{
				Name = "Secret Lucky Block x3",
				Id = "Secret Lucky Block",
				ProductId = 3437062543
			},
			{
				Name = "Secret Lucky Block x8",
				Id = "Secret Lucky Block",
				ProductId = 3437979356
			}
		}
	},
	{
		Frame = "ItemsListPromo5",
		Test = "Shop.AllLuckyBlockPromo",
		Cards = {
			{
				Name = "All Lucky Blocks",
				Id = "Secret Lucky Block",
				ProductId = 3437989614
			},
			{
				Name = "Secret Lucky Block"
			}
		}
	},
	{
		Frame = "ItemsListPromo6",
		Test = "Shop.LaserGunPromo",
		Cards = {
			{
				Name = "Secret Lucky Block"
			}
		}
	},
	{
		Frame = "ItemsListPromo7",
		Test = "Shop.BlackholeSlapPromo",
		Cards = {
			{
				Name = "Secret Lucky Block"
			}
		}
	},
	{
		Frame = "ItemsListPromo8",
		Test = "Shop.BanHammerPromo",
		Cards = {
			{
				Name = "Secret Lucky Block"
			}
		}
	}
}

-- equivalent calls inferred from this helper; original call sites unknown
local function fromABTest(test: string, p)
	return Reactive.FromSubscription(function(onLoaded)
		return ABTests.Loaded:Connect(onLoaded)
	end, function()
		return ABTests.GetAttribute(localPlayer, test, p)
	end)
end

local function mountBeeLuckyBlock(guiObject, object, preserveViewportModel: boolean?)
	LuckyBlocks.MountCard(guiObject, object, {
		Id = "Premium Bee Lucky Block",
		MultiBuy = {
			Buy = 3709239077,
			Buy3 = 3709239080,
			Buy10 = 3709239082
		},
		CountedProductId = 3709239080,
		PreserveViewportModel = preserveViewportModel
	})
end

local function mountProductButton(instance, fn, object, callback)
	local buy = instance:FindFirstChild("Buy", true)

	if not (buy and buy:IsA("GuiButton")) then
		return
	end

	local price = buy:FindFirstChild("Price")

	if price and price:IsA("TextLabel") then
		local text = Prices.Text(function()
			return object:ResolveProductId(fn)
		end, "Product", 100)
		Reactive.Hydrate(price, {
			Text = function()
				if callback and callback() and object.GiftTarget() == nil then
					return "Owned"
				end

				return text()
			end
		})
	end

	Reactive.Button(buy, function()
		object:Buy(fn)
	end)
end

local function hydrateTimer(instance, object, callback, callback2)
	local timer = instance:FindFirstChild("Timer", true)

	if not timer then
		return
	end

	local timer2

	if timer:IsA("TextLabel") then
		timer2 = timer
	else
		timer2 = timer:FindFirstChild("Timer")
	end

	if timer2 and timer2:IsA("TextLabel") then
		local v3 = timer ~= timer2
		Reactive.Hydrate(timer2, {
			Text = function()
				local v4 = math.max(0, callback() - object.Clock())

				if v3 then
					return (`Only {TimeUtils:E(v4)} Left!`)
				end

				return (`{TimeUtils:E(v4)} left`)
			end
		})
	end

	if timer:IsA("GuiObject") then
		Reactive.Hydrate(timer, {
			Visible = callback2
		})
	end
end

local function hydrateRandomContents(instance, paidRandomAllowed)
	for _, childName in { "LuckyBlock", "Extra" } do
		local guiObject = instance:FindFirstChild(childName, true)

		if guiObject and guiObject:IsA("GuiObject") then
			Reactive.Hydrate(guiObject, {
				Visible = paidRandomAllowed
			})
		end
	end
end

return table.freeze({
	FromABTest = fromABTest,
	Mount = function(p, p2, object)
		local resolved = Layout.Resolve(p, p2.List)

		if not resolved then
			return
		end

		local fFlag = Reactive.FFlag(BeeShopFlags.Enabled)
		local fFlag2 = Reactive.FFlag(BeeShopFlags.LuckyBlockEndTimer)
		local fFlag3 = Reactive.FFlag(BeeShopFlags.BaseEndTimer)
		local fFlag4 = Reactive.FFlag(BeeShopFlags.GearEndTimer)

		local function updateEnabled()
			object.UpdatesRevision()
			return true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function luckyBlockActive()
			object.UpdatesRevision()
			return fFlag() and object.Clock() < fFlag2()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function baseActive()
			object.UpdatesRevision()
			return fFlag() and object.Clock() < fFlag3()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function gearActive()
			object.UpdatesRevision()
			return fFlag() and object.Clock() < fFlag4()
		end

		local function paidRandomAllowed()
			return not State.PaidRandomRestricted(object)
		end

		local v3 = Reactive.FromChannel(function(object2)
			return BaseSkins.Owns(object2, "Bee Emperor") or object2:Get({ "PurchasedBaseSkins", "Bee Emperor" }) == true
		end, false, {
			{
				Method = "OnDictionaryInserted",
				Path = "BaseSkinInventory"
			},
			{
				Method = "OnDictionaryRemoved",
				Path = "BaseSkinInventory"
			},
			{
				Method = "OnDictionaryInserted",
				Path = "UnlockedBaseSkins"
			},
			{
				Method = "OnDictionaryInserted",
				Path = "PurchasedBaseSkins"
			}
		})
		local owns = object:Owns(3709239100)
		local featured = resolved:FindFirstChild("Featured")
		local beeLuckyBlock = featured and featured:FindFirstChild("Bee Lucky Block")

		for _, guiObject in { resolved:FindFirstChild("Bee Lucky Block"), beeLuckyBlock } do
			if not (guiObject and guiObject:IsA("GuiObject")) then
				continue
			end

			mountBeeLuckyBlock(guiObject, object, guiObject == beeLuckyBlock)
			hydrateTimer(guiObject, object, fFlag2, luckyBlockActive)
			Reactive.Hydrate(guiObject, {
				Visible = function()
					object.UpdatesRevision()
					return fFlag() and object.Clock() < fFlag2() and not State.PaidRandomRestricted(object)
				end
			})
		end

		local beeEmperorBasePack = featured and featured:FindFirstChild("Bee Emperor Base Pack")

		if beeEmperorBasePack then
			LuckyBlocks.MountCard(beeEmperorBasePack, object, {
				Id = "Premium Bee Lucky Block",
				PreserveViewportModel = true
			})
			mountProductButton(beeEmperorBasePack, function()
				if State.PaidRandomRestricted(object) then
					return 3709239084
				end

				return 3709239086
			end, object, v3)
			hydrateRandomContents(beeEmperorBasePack, paidRandomAllowed)
			hydrateTimer(beeEmperorBasePack, object, fFlag3, baseActive)

			if beeEmperorBasePack:IsA("GuiObject") then
				Reactive.Hydrate(beeEmperorBasePack, {
					Visible = baseActive
				})
			end

			local title = beeEmperorBasePack:FindFirstChild("Title", true)

			if title and title:IsA("TextLabel") then
				Reactive.Hydrate(title, {
					Text = function()
						if State.PaidRandomRestricted(object) then
							return "Bee Emperor Base"
						end

						return "Bee Emperor Base Pack"
					end
				})
			end
		end

		local beeGear = featured and featured:FindFirstChild("Bee Gear")

		if beeGear then
			LuckyBlocks.MountCard(beeGear, object, {
				Id = "Premium Bee Lucky Block",
				PreserveViewportModel = true
			})
			mountProductButton(beeGear, function()
				if State.PaidRandomRestricted(object) then
					return 3709239100
				end

				return 3709239112
			end, object, owns)
			hydrateRandomContents(beeGear, paidRandomAllowed)
			hydrateTimer(beeGear, object, fFlag4, gearActive)

			if beeGear:IsA("GuiObject") then
				Reactive.Hydrate(beeGear, {
					Visible = gearActive
				})
			end
		end

		local beeBase = resolved:FindFirstChild("BeeBase")

		if beeBase then
			mountProductButton(beeBase, function()
				if State.PaidRandomRestricted(object) then
					return 3709239084
				end

				return 3709239086
			end, object, v3)
			hydrateRandomContents(beeBase, paidRandomAllowed)
			hydrateTimer(beeBase, object, fFlag3, baseActive)

			if beeBase:IsA("GuiObject") then
				Reactive.Hydrate(beeBase, {
					Visible = baseActive
				})
			end
		end

		local flyingBee = resolved:FindFirstChild("FlyingBee")

		if flyingBee then
			mountProductButton(flyingBee, function()
				if State.PaidRandomRestricted(object) then
					return 3709239100
				end

				return 3709239112
			end, object, owns)
			hydrateRandomContents(flyingBee, paidRandomAllowed)
			hydrateTimer(flyingBee, object, fFlag4, gearActive)

			if flyingBee:IsA("GuiObject") then
				Reactive.Hydrate(flyingBee, {
					Visible = gearActive
				})
			end
		end

		local beeBaseSpacer = resolved:FindFirstChild("BeeBaseSpacer")

		if beeBaseSpacer and beeBaseSpacer:IsA("GuiObject") then
			Reactive.Hydrate(beeBaseSpacer, {
				Visible = baseActive
			})
		end

		local flyingBeeSpacer = resolved:FindFirstChild("FlyingBeeSpacer")

		if flyingBeeSpacer and flyingBeeSpacer:IsA("GuiObject") then
			Reactive.Hydrate(flyingBeeSpacer, {
				Visible = gearActive
			})
		end

		local beeTitle = resolved:FindFirstChild("BeeTitle")

		if beeTitle and beeTitle:IsA("GuiObject") then
			Reactive.Hydrate(beeTitle, {
				Visible = function()
					local v4 = luckyBlockActive() -- equivalent call inferred; original call site unknown

					if not v4 then
						v4 = baseActive()

						if not v4 then
							return (gearActive())
						end
					end

					return v4
				end
			})
		end

		if featured and featured:IsA("GuiObject") then
			Reactive.Hydrate(featured, {
				Visible = function()
					local v4 = luckyBlockActive() -- equivalent call inferred; original call site unknown

					if not v4 then
						v4 = baseActive()

						if not v4 then
							return (gearActive())
						end
					end

					return v4
				end
			})
		end
	end,
	MountLegacy = function(p, p2, p3)
		local resolved = Layout.Resolve(p, p2.List)

		if not resolved then
			return
		end

		for _, v3 in v do
			local guiObject = resolved:FindFirstChild(v3.Frame)

			if not (guiObject and guiObject:IsA("GuiObject")) then
				continue
			end

			for _, card in v3.Cards do
				local child = guiObject:FindFirstChild(card.Name)

				if child then
					LuckyBlocks.MountCard(child, p3, {
						Id = card.Id,
						ProductId = card.ProductId
					})
				end
			end

			local v5 = fromABTest(v3.Test, false) -- equivalent call inferred; original call site unknown
			Reactive.Hydrate(guiObject, {
				Visible = function()
					return not State.PaidRandomRestricted(p3) and v5()
				end
			})
		end
	end
})