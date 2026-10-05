local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local CashPacks = require(ReplicatedStorage.Data.CashPacks)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
require(ReplicatedStorage.Client.Types.GUI)
local MonetizationEntitlements = require(ReplicatedStorage.Shared.Util.MonetizationEntitlements)
local PlotState = require(ReplicatedStorage.Client.PlotState)
local Products = require(ReplicatedStorage.Data.Products)
local Save = require(ReplicatedStorage.Shared.Save)
local Client = require(script.Client)
local Trove = require(ReplicatedStorage.Packages.Trove)
local color = Color3.new(0.760784, 0, 0)
local v = nil
local count = 0
return {
	Start = function()
		local function bindLocalPlot()
			count += 1
			local v2 = count

			if v ~= nil then
				v:Destroy()
				v = nil
			end

			local plot = PlotState.ResolvePlot()

			if plot == nil then
				return
			end

			local plotFolder = plot.PlotFolder
			assert(plotFolder:IsA("Model"), "Local plot folder must be a Model")
			local treadmillUpgrade = plotFolder:WaitForChild("TreadmillUpgrade")
			assert(treadmillUpgrade:IsA("Model"), "TreadmillUpgrade must be a Model")
			local sign = treadmillUpgrade.Sign
			assert(sign:IsA("BasePart"), "TreadmillUpgrade.Sign must be a BasePart")
			local canUpgrade = sign.CanUpgrade
			assert(canUpgrade:IsA("BillboardGui"), "TreadmillUpgrade.Sign.CanUpgrade must be a BillboardGui")
			local surfaceGui = sign.SurfaceGui
			assert(surfaceGui:IsA("SurfaceGui"), "TreadmillUpgrade.Sign.SurfaceGui must be a SurfaceGui")
			local level = surfaceGui.Level
			assert(level:IsA("TextLabel"), "TreadmillUpgrade.Sign.SurfaceGui.Level must be a TextLabel")
			local frame = surfaceGui.Frame
			assert(frame:IsA("GuiObject"), "TreadmillUpgrade.Sign.SurfaceGui.Frame must be a GuiObject")
			local upgrade = frame.Upgrade
			assert(upgrade:IsA("GuiButton"), "Treadmill Upgrade must be a GuiButton")
			local robuxUpgrade = frame.RobuxUpgrade
			assert(robuxUpgrade:IsA("GuiButton"), "Treadmill RobuxUpgrade must be a GuiButton")
			local cost = upgrade.Cost
			assert(cost:IsA("TextLabel"), "Treadmill Upgrade.Cost must be a TextLabel")
			local cost2 = robuxUpgrade.Cost
			assert(cost2:IsA("TextLabel"), "Treadmill RobuxUpgrade.Cost must be a TextLabel")
			local backgroundColor3 = upgrade.BackgroundColor3
			local uIGradient = upgrade:FindFirstChildOfClass("UIGradient")
			local enabled

			if uIGradient == nil then
				enabled = false
			else
				enabled = uIGradient.Enabled
			end

			local maid = Trove.new()
			v = maid
			maid:Add(function()
				upgrade.BackgroundColor3 = backgroundColor3

				if uIGradient ~= nil then
					uIGradient.Enabled = enabled
				end
			end)

			local function refresh()
				local v3 = Save.Await()
				assert(v3 ~= nil, "Treadmill upgrade UI requires loaded data")
				local nextConfig, v4 = Client.GetNextConfig(v3)
				local canAffordNext = Client.CanAffordNext(v3)
				canUpgrade.Enabled = v3.BaseUpgradeLevel > 0 and canAffordNext
				local upgrade2 = upgrade
				local backgroundColor

				if canAffordNext then
					backgroundColor = backgroundColor3
				else
					backgroundColor = color
				end

				upgrade2.BackgroundColor3 = backgroundColor

				if uIGradient ~= nil then
					uIGradient.Enabled = canAffordNext and enabled
				end

				if v4 == nil then
					level.Text = "Level MAX"
					cost.Text = "MAX"
					robuxUpgrade.Visible = false
				else
					level.Text = `Level {v3.TreadmillUpgradeLevel} > Level {nextConfig}`
					cost.Text = "$" .. Simple.FormatCompact(v4.Price, ".#")
					local productId = v4.ProductId
					robuxUpgrade.Visible = productId ~= nil and Products.FromProductId(productId) ~= nil and CashPacks.GetCanBuyProduct(
						CashPacks.GetPlayerGroup(Players.LocalPlayer),
						"Treadmill_" .. v4._id
					)
					cost2.Text = ""

					if productId ~= nil and robuxUpgrade.Visible then
						task.spawn(function()
							local productPrice = MonetizationEntitlements.ProductPrice(productId)

							if v2 == count and v == maid and productPrice > 0 then
								cost2.Text = ` {Simple.FormatCompact(productPrice, ".#")}`
							end
						end)
					end
				end
			end

			maid:Add(ButtonFX(upgrade, 1.05, Client.RequestCashUpgrade))
			maid:Add(ButtonFX(robuxUpgrade, 1.05, Client.PromptRobuxUpgrade))
			maid:Add(Save.Watch("TreadmillUpgradeLevel"):Connect(refresh))
			maid:Add(Save.Watch("BaseUpgradeLevel"):Connect(refresh))
			maid:Add(Save.Watch("Money"):Connect(refresh))
			maid:Connect(Players.LocalPlayer:GetAttributeChangedSignal(CashPacks.RevisionAttribute), refresh)
			refresh()
		end

		Save.Await()
		bindLocalPlot()
		PlotState.LocalPlotChanged:Connect(bindLocalPlot)
	end
}