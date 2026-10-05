local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local BossMastery = require(ReplicatedStorage.Data.BossMastery)
local BossMasteryFlags = require(ReplicatedStorage.Shared.Flags.BossMasteryFlags)
local BossShopProductCard = require(script.BossShopProductCard)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local GUI = require(ReplicatedStorage.Client.GUI)
local GamepadBindings = require(ReplicatedStorage.Client.GamepadBindings)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local Numbers = require(ReplicatedStorage.Shared.Utils.Numbers)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local Trove = require(ReplicatedStorage.Packages.Trove)
local tweenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local color = Color3.fromRGB(255, 64, 64)
local color2 = Color3.fromRGB(80, 255, 120)
return {
	Start = function()
		local main = GUI.BossShop().Main
		local main2 = main.Main
		local scrollingFrame = main2.ScrollingFrame
		local bossShopItemTemplate = scrollingFrame.BossShopItemTemplate
		local amount = main2.Header.CurrencyHolder.Amount
		local close = main2.Close
		local bossMasteryButton = main.BossMasteryButton
		local gamepadGlyph = bossMasteryButton.GamepadGlyph
		local maid = Trove.new()
		local v = Trove.new()
		local v2 = Trove.new()
		local v3 = {}
		local v4 = nil
		local v5 = nil
		local v6 = false
		maid:Add(v)
		maid:Add(v2)
		maid:Add(ButtonFX(close, 1.08, function()
			Tabs.Deactivate()
		end))
		gamepadGlyph:SetAttribute("GamepadKey", "ButtonX")
		GamepadBindings.Inspect(gamepadGlyph)
		maid:Add(ButtonFX(bossMasteryButton, 1.08, function()
			Tabs.Activate("BossMastery")
		end))

		-- equivalent calls inferred from this helper; original call sites unknown
		local function formatTokens(p: number)
			if math.abs(p) > 99999 then
				return Simple.FormatCompact(math.round(p), ".#")
			end

			return Numbers.AddCommas((math.round(p)))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setTokenText(p: number)
			local amount2 = amount
			local text = formatTokens(p) -- equivalent call inferred; original call site unknown
			amount2.Text = text
		end

		local function refreshTokenBalance(flag: boolean?)
			local v7 = Save.Await()

			if v7 == nil then
				return
			end

			local bossTokens = v7.BossTokens
			local value

			if v5 then
				value = v5.Value
			else
				value = v4
			end

			v4 = bossTokens
			v:Clean()
			v5 = nil

			if flag or value == nil or value == bossTokens then
				setTokenText(bossTokens) -- equivalent call inferred; original call site unknown
			else
				local numberValue = Instance.new("NumberValue")
				numberValue.Value = value
				v5 = numberValue
				v:Add(numberValue)
				v:Connect(numberValue.Changed, setTokenText)
				setTokenText(value) -- equivalent call inferred; original call site unknown
				local tween = TweenService:Create(numberValue, tweenInfo, {
					Value = bossTokens
				})
				v:Add(tween)
				tween:Play()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshCards()
			for _, v7 in v3 do
				v7.Refresh()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function setCardsPending(flag: boolean)
			v6 = flag

			for _, v7 in v3 do
				v7.SetPending(flag)
			end
		end

		local function showResult(p, result: boolean, value: string?)
			local show = Toast.Show
			local v7 = {
				Text = not result and (value or "Purchase failed") or `Purchased {BossMastery.GetShopDisplayName(p)}!`,
				Seconds = 2.5,
				Color = 0,
				Image = 0,
				SingleLine = true
			}
			local color3

			if result then
				color3 = color2
			else
				color3 = color
			end

			v7.Color = color3
			v7.Image = p.Icon
			show(v7)
		end

		local function requestPurchase(p, _)
			if v6 then
				return
			end

			setCardsPending(true) -- equivalent call inferred; original call site unknown
			local success, result, v7 = pcall(function()
				return Remotes.BossMastery.AskBuyShopItem:InvokeServer(p.Id)
			end)
			setCardsPending(false) -- equivalent call inferred; original call site unknown

			if success then
				showResult(p, result, v7)
			else
				Toast.Show({
					Text = "Something went wrong, please try again.",
					Seconds = 2.5,
					Color = color,
					Image = p.Icon,
					SingleLine = true
				})
			end
		end

		local function rebuildCards()
			v2:Clean()
			table.clear(v3)

			for k, v7 in BossMastery.GetShopProducts() do
				local v8 = BossShopProductCard.New(bossShopItemTemplate, scrollingFrame, v7, k, requestPurchase)
				v3[v7.Id] = v8
				v2:Add(v8.Destroy)
				v8.SetPending(v6)
			end
		end

		bossShopItemTemplate.Visible = false
		rebuildCards()
		Save.Await()
		local v7 = Save.Await()

		if v7 ~= nil then
			local bossTokens = v7.BossTokens

			if v5 then
				local _ = v5.Value
			end

			v4 = bossTokens
			v:Clean()
			v5 = nil
			local text = formatTokens(bossTokens) -- equivalent call inferred; original call site unknown
			amount.Text = text
		end

		maid:Add(Save.WatchFields("BossTokens", function()
			refreshTokenBalance()
		end))
		maid:Add(BossMasteryFlags.ShopPriceOverrides.Changed:Connect(refreshCards))
		maid:Add(BossMasteryFlags.ShopProductIds.Changed:Connect(rebuildCards))
		maid:Add(BossMasteryFlags.CashBoosterDurationSeconds.Changed:Connect(refreshCards))
		maid:Add(BossMasteryFlags.SpeedBoostDurationSeconds.Changed:Connect(refreshCards))
		maid:Add(BossMasteryFlags.TreadmillBoostDurationSeconds.Changed:Connect(refreshCards))
		maid:Add(BossMasteryFlags.MutationConsumableSuccessPercent.Changed:Connect(refreshCards))
		maid:Add(BossMasteryFlags.CashBoosterMultiplier.Changed:Connect(refreshCards))
		maid:Add(BossMasteryFlags.TreadmillBoostMultiplier.Changed:Connect(refreshCards))
		maid:Add(BossMasteryFlags.SpeedBoostMultiplier.Changed:Connect(refreshCards))
		maid:Add(Tabs.Activated:Connect(function(p: string)
			if p == "BossShop" then
				local v8 = Save.Await()

				if v8 ~= nil then
					local bossTokens = v8.BossTokens

					if v5 then
						local _ = v5.Value
					end

					v4 = bossTokens
					v:Clean()
					v5 = nil
					setTokenText(bossTokens) -- equivalent call inferred; original call site unknown
				end

				refreshCards() -- equivalent call inferred; original call site unknown
			end
		end))
		return maid
	end
}