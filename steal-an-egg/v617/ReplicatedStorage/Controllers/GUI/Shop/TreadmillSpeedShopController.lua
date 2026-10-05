local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CashPacks = require(ReplicatedStorage.Data.CashPacks)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local GUI = require(ReplicatedStorage.Client.GUI)
require(ReplicatedStorage.Client.Types.GUI)
require(ReplicatedStorage.Shared.Modules.ProfileDefaults.Types.Interface)
local Marketplace = require(ReplicatedStorage.Shared.Utils.Marketplace)
local price = Marketplace.Price
local Products = require(ReplicatedStorage.Data.Products)
local Save = require(ReplicatedStorage.Shared.Save)
local Tabs = require(ReplicatedStorage.Client.Tabs)
local Client = require(script.Parent.Parent.TreadmillUpgradeController.Client)
local Treadmills = require(ReplicatedStorage.Data.Treadmills)
local colorSequence = ColorSequence.new(Color3.fromRGB(214, 17, 17), Color3.fromRGB(253, 20, 20))
local color = Color3.fromRGB(72, 0, 0)
local color2 = Color3.fromRGB(255, 103, 103)
return {
	Start = function()
		local upgradeTreadmil = GUI.Shop().Frame.ScrollingFrame.UpgradeTreadmil
		local spacer = upgradeTreadmil.Spacer
		local btns = spacer.Btns
		local cash = btns.Cash
		local robux = btns.Robux
		local uIGradient = cash:FindFirstChildOfClass("UIGradient")
		local uIStroke = cash:FindFirstChild("UIStroke")
		local uIStrokeClr = cash:FindFirstChild("UIStrokeClr")
		local color3

		if uIGradient == nil then
			color3 = nil
		else
			color3 = uIGradient.Color
		end

		local color4

		if uIStroke == nil then
			color4 = nil
		else
			color4 = uIStroke.Color
		end

		local color5

		if uIStrokeClr == nil then
			color5 = nil
		else
			color5 = uIStrokeClr.Color
		end

		local count = 0

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getLoadedData()
			local v = Save.Await()
			assert(v ~= nil, "Treadmill speed shop requires loaded player data")
			return v
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateRobuxUpgradePrice(productId: number, p: number)
			robux.Price.Text = Constants.ROBUX_ICON_STR
			task.spawn(function()
				local v = price(productId, Enum.InfoType.Product)

				if p ~= count then
					return
				end

				robux.Price.Text = `{Constants.ROBUX_ICON_STR} {v == nil and "???" or Simple.FormatCompact(v, ".#")}`
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function applyMoneyAffordability(canAffordNext: boolean)
			if uIGradient ~= nil then
				local v = uIGradient
				local color6

				if canAffordNext then
					color6 = color3
				else
					color6 = colorSequence
				end

				v.Color = color6
			end

			if uIStroke ~= nil then
				local v = uIStroke
				local color6

				if canAffordNext then
					color6 = color4
				else
					color6 = color
				end

				v.Color = color6
			end

			if uIStrokeClr ~= nil then
				local v = uIStrokeClr
				local color6

				if canAffordNext then
					color6 = color5
				else
					color6 = color2
				end

				v.Color = color6
			end
		end

		local function refreshUpgrade(p, p2: number)
			local v = Treadmills.GetByUpgradeLevel(p.TreadmillUpgradeLevel)
			assert(v ~= nil, (`Invalid current treadmill level {p.TreadmillUpgradeLevel}`))
			spacer.CurrentTreadmill.Image = v.Icon
			local _, v2 = Client.GetNextConfig(p)

			if v2 == nil then
				upgradeTreadmil.Visible = false
				return
			end

			upgradeTreadmil.Visible = true
			spacer.NextTreadmill.Image = v2.Icon
			cash.Price.Text = "$" .. Simple.FormatCompact(v2.Price, ".#")
			applyMoneyAffordability(Client.CanAffordNext(p)) -- equivalent call inferred; original call site unknown
			local productId = v2.ProductId
			robux.Visible = productId ~= nil and Products.FromProductId(productId) ~= nil and CashPacks.GetCanBuyProduct(
				CashPacks.GetPlayerGroup(Players.LocalPlayer),
				"Treadmill_" .. v2._id
			)

			if productId ~= nil and robux.Visible then
				updateRobuxUpgradePrice(productId, p2) -- equivalent call inferred; original call site unknown
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshShop()
			count += 1
			local v = count
			refreshUpgrade(getLoadedData(), v)
		end

		Save.Await()
		ButtonFX(cash, nil, Client.RequestCashUpgrade)
		ButtonFX(robux, nil, Client.PromptRobuxUpgrade)
		Tabs.Activated:Connect(function(p: string)
			if p == "Shop" then
				refreshShop() -- equivalent call inferred; original call site unknown
			end
		end)
		Save.Watch("TreadmillUpgradeLevel"):Connect(function()
			if Tabs.IsActive("Shop") then
				refreshShop() -- equivalent call inferred; original call site unknown
			end
		end)
		Save.Watch("Money"):Connect(function()
			if Tabs.IsActive("Shop") then
				refreshShop() -- equivalent call inferred; original call site unknown
			end
		end)
		Players.LocalPlayer:GetAttributeChangedSignal(CashPacks.RevisionAttribute):Connect(refreshShop)
		refreshShop() -- equivalent call inferred; original call site unknown
	end
}