local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local GUI = require(ReplicatedStorage.Client.GUI)
require(ReplicatedStorage.Client.Types.GUI)
local Hud = require(ReplicatedStorage.Client.Hud)
local Marketplace = require(ReplicatedStorage.Shared.Utils.Marketplace)
local price = Marketplace.Price
require(ReplicatedStorage.Data.Products)
local Products = require(ReplicatedStorage.Data.Products)
local Save = require(ReplicatedStorage.Shared.Save)
local Storefront = require(ReplicatedStorage.Client.Functions.Storefront)
local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
local t = require(ReplicatedStorage.Packages.t)
local v = {
	Products.Directory.SpeedBoostTier1,
	Products.Directory.SpeedBoostTier2,
	Products.Directory.SpeedBoostTier3,
	Products.Directory.SpeedBoostTier4,
	Products.Directory.SpeedBoostTier5,
	Products.Directory.SpeedBoostTier6,
	Products.Directory.SpeedBoostTier7,
	Products.Directory.SpeedBoostTier8,
	Products.Directory.SpeedBoostTier9,
	Products.Directory.SpeedBoostTier10,
	Products.Directory.SpeedBoostTier11,
	Products.Directory.SpeedBoostTier12
}
local formatted = `ONLY ?{Constants.ROBUX_ICON_STR}`
return {
	Start = function()
		local spacer = GUI.Shop().Frame.ScrollingFrame.DoubleSpeed.Spacer
		local v2 = Hud.Get("SpeedMultiButton", "Treadmill")
		local labels = {}

		for _, label in v2:GetChildren() do
			if label:IsA("TextLabel") then
				table.insert(labels, label)
			end
		end

		assert(#labels >= 2, "TradmilHud SpeedMulti needs a multiplier label and a price label")
		local v3 = labels[1]
		local v4 = labels[2]
		local v5 = {
			{
				Buy = spacer.Buy,
				End = spacer.NextAm,
				Start = spacer.CurAm
			}
		}
		local count = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function resolveOwnedSpeedBoostTierIndex()
			return TreadmillUtil.ResolveSpeedBoostTierIndex(Save.Await())
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function resolveNextSpeedBoostProduct()
			return v[TreadmillUtil.ResolveSpeedBoostTierIndex(Save.Await()) + 1]
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function resolveSpeedBoostMultiplierForTierIndex(ownedSpeedBoostTierIndex: number)
			local v6 = v[ownedSpeedBoostTierIndex]

			if v6 == nil then
				return 1
			end

			return v6.SpeedBoostMultiplier
		end

		local function resolveCurrentAndNextSpeedBoostMultipliers()
			local ownedSpeedBoostTierIndex = resolveOwnedSpeedBoostTierIndex() -- equivalent call inferred; original call site unknown
			local speedBoostMultiplierForTierIndex = resolveSpeedBoostMultiplierForTierIndex(ownedSpeedBoostTierIndex) -- equivalent call inferred; original call site unknown
			local v6 = v[ownedSpeedBoostTierIndex + 1]
			local v7

			if v6 == nil then
				v7 = speedBoostMultiplierForTierIndex
			else
				v7 = v6.SpeedBoostMultiplier
			end

			return speedBoostMultiplierForTierIndex, v7, v6 == nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function formatSpeedBoostMultiplier(p: number)
			t.strict(t.number)(p)
			return (`x{Simple.FormatCompact(p, ".#")}`)
		end

		local function hasProductCredit(p: number)
			if not Save.IsLoaded() then
				return false
			end

			local v6 = Save.Await()
			local productCredits

			if v6 ~= nil then
				productCredits = v6.ProductCredits
			end

			if typeof(productCredits) ~= "table" then
				return false
			end

			local productCredit = productCredits[tostring(p)]
			return typeof(productCredit) == "number" and productCredit > 0
		end

		local function updateProductPrice(price2, p)
			price2.Visible = true

			if p == nil then
				price2.Text = "MAX"
				price2.Visible = false
			else
				local productId = p.ProductId

				if productId <= 0 then
					price2.Text = "???"
					price2.Visible = false
				else
					local v6

					if Save.IsLoaded() then
						local v7 = Save.Await()
						local productCredits

						if v7 ~= nil then
							productCredits = v7.ProductCredits
						end

						if typeof(productCredits) == "table" then
							local productCredit = productCredits[tostring(productId)]

							if typeof(productCredit) == "number" then
								v6 = productCredit > 0
							else
								v6 = false
							end
						else
							v6 = false
						end
					else
						v6 = false
					end

					if v6 then
						price2.Text = "FREE!"
					else
						task.spawn(function()
							local v7 = price(productId, Enum.InfoType.Product)
							price2.Text = `{Constants.ROBUX_ICON_STR}{v7 == nil and "???" or tostring(v7)}`
						end)
					end
				end
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateSideButtonPrice(nextSpeedBoostProduct)
			count += 1
			local v6 = count

			if nextSpeedBoostProduct == nil then
				v4.Text = "MAX"
				return
			end

			local productId = nextSpeedBoostProduct.ProductId
			local v7

			if Save.IsLoaded() then
				local v8 = Save.Await()
				local productCredits

				if v8 ~= nil then
					productCredits = v8.ProductCredits
				end

				if typeof(productCredits) == "table" then
					local productCredit = productCredits[tostring(productId)]

					if typeof(productCredit) == "number" then
						v7 = productCredit > 0
					else
						v7 = false
					end
				else
					v7 = false
				end
			else
				v7 = false
			end

			if v7 then
				v4.Text = "FREE!"
				return
			end

			v4.Text = formatted
			task.spawn(function()
				local v8 = price(productId, Enum.InfoType.Product)

				if v6 ~= count then
					return
				end

				local v9 = v4
				local text

				if v8 == nil then
					text = formatted
				else
					text = `ONLY {v8}{Constants.ROBUX_ICON_STR}`
				end

				v9.Text = text
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateDoubleYourSpeedTool()
			local nextSpeedBoostProduct = resolveNextSpeedBoostProduct() -- equivalent call inferred; original call site unknown
			local v6 = nextSpeedBoostProduct ~= nil
			v2.Interactable = v6
			v4.Visible = v6

			if nextSpeedBoostProduct == nil then
				v3.Text = "MAX"
				count += 1
				v4.Text = "MAX"
			else
				v3.Text = TreadmillUtil.FormatSpeedMultiplier(nextSpeedBoostProduct.SpeedBoostMultiplier)
				updateSideButtonPrice(nextSpeedBoostProduct) -- equivalent call inferred; original call site unknown
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateDoubleYourSpeedText(p, speedBoostMultiplierForTierIndex: number, speedBoostMultiplier: number, flag: boolean?)
			local start = p.Start
			start.Text = formatSpeedBoostMultiplier(speedBoostMultiplierForTierIndex)
			local v6 = p.End
			local text

			if flag then
				text = "MAX"
			else
				text = formatSpeedBoostMultiplier(speedBoostMultiplier)
			end

			v6.Text = text
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateDoubleYourSpeedVisibility(p, flag: boolean)
			p.Buy.Visible = not flag
			p.Buy.Interactable = not flag
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateDoubleYourSpeedPack(p)
			local ownedSpeedBoostTierIndex = resolveOwnedSpeedBoostTierIndex() -- equivalent call inferred; original call site unknown
			local speedBoostMultiplierForTierIndex = resolveSpeedBoostMultiplierForTierIndex(ownedSpeedBoostTierIndex) -- equivalent call inferred; original call site unknown
			local v6 = v[ownedSpeedBoostTierIndex + 1]
			local speedBoostMultiplier

			if v6 == nil then
				speedBoostMultiplier = speedBoostMultiplierForTierIndex
			else
				speedBoostMultiplier = v6.SpeedBoostMultiplier
			end

			local v7 = v6 == nil
			updateDoubleYourSpeedVisibility(p, v7) -- equivalent call inferred; original call site unknown
			updateProductPrice(p.Buy.Price, resolveNextSpeedBoostProduct())
			updateDoubleYourSpeedText(p, speedBoostMultiplierForTierIndex, speedBoostMultiplier, v7) -- equivalent call inferred; original call site unknown
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function bindDoubleYourSpeedButton(p)
			ButtonFX(p.Buy, nil, function()
				local nextSpeedBoostProduct = resolveNextSpeedBoostProduct() -- equivalent call inferred; original call site unknown

				if nextSpeedBoostProduct == nil then
					return
				end

				Storefront.Prompt(nextSpeedBoostProduct.ProductId, true)
			end)
		end

		local function updateSpeedBoostProducts()
			for _, v6 in ipairs(v5) do
				updateDoubleYourSpeedPack(v6) -- equivalent call inferred; original call site unknown
			end

			updateDoubleYourSpeedTool() -- equivalent call inferred; original call site unknown
		end

		Save.Await()

		for _, v6 in ipairs(v5) do
			bindDoubleYourSpeedButton(v6) -- equivalent call inferred; original call site unknown
			updateDoubleYourSpeedPack(v6) -- equivalent call inferred; original call site unknown
		end

		ButtonFX(v2, 1.08, function()
			local nextSpeedBoostProduct = resolveNextSpeedBoostProduct() -- equivalent call inferred; original call site unknown

			if nextSpeedBoostProduct == nil then
				return
			end

			Storefront.Prompt(nextSpeedBoostProduct.ProductId, true)
		end)
		local nextSpeedBoostProduct = resolveNextSpeedBoostProduct() -- equivalent call inferred; original call site unknown
		local v6 = nextSpeedBoostProduct ~= nil
		v2.Interactable = v6
		v4.Visible = v6

		if nextSpeedBoostProduct == nil then
			v3.Text = "MAX"
			count += 1
			v4.Text = "MAX"
		else
			v3.Text = TreadmillUtil.FormatSpeedMultiplier(nextSpeedBoostProduct.SpeedBoostMultiplier)
			count += 1
			local v7 = count

			if nextSpeedBoostProduct == nil then
				v4.Text = "MAX"
			else
				local productId = nextSpeedBoostProduct.ProductId
				local v8

				if Save.IsLoaded() then
					local v9 = Save.Await()
					local productCredits

					if v9 ~= nil then
						productCredits = v9.ProductCredits
					end

					if typeof(productCredits) == "table" then
						local productCredit = productCredits[tostring(productId)]

						if typeof(productCredit) == "number" then
							v8 = productCredit > 0
						else
							v8 = false
						end
					else
						v8 = false
					end
				else
					v8 = false
				end

				if v8 then
					v4.Text = "FREE!"
				else
					v4.Text = formatted
					task.spawn(function()
						local v9 = price(productId, Enum.InfoType.Product)

						if v7 ~= count then
							return
						end

						local v10 = v4
						local text

						if v9 == nil then
							text = formatted
						else
							text = `ONLY {v9}{Constants.ROBUX_ICON_STR}`
						end

						v10.Text = text
					end)
				end
			end
		end

		Save.WatchFields({ "SpeedBoostTierIndex", "ProductCredits" }, updateSpeedBoostProducts)
	end
}