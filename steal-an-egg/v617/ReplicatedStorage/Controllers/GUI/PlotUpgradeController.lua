local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local BaseUpgrade = require(ReplicatedStorage.Client.BaseUpgrade)
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
require(ReplicatedStorage.Client.Types.GUI)
local EnsureUIScale = require(ReplicatedStorage.Shared.Utils.EnsureUIScale)
local PlotState = require(ReplicatedStorage.Client.PlotState)
local PlotUpgradeVisibility = require(ReplicatedStorage.Client.PlotUpgradeVisibility)
require(ReplicatedStorage.Data.Products)
local Products = require(ReplicatedStorage.Data.Products)
local Storefront = require(ReplicatedStorage.Client.Functions.Storefront)
local Save = require(ReplicatedStorage.Shared.Save)
local Trove = require(ReplicatedStorage.Packages.Trove)
local color = Color3.new(0.760784, 0, 0)
local tweenInfo = TweenInfo.new(0.65, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
return {
	Start = function()
		local plotUpgrade = ReplicatedStorage.Assets.UI.PlotUpgrade
		local firstUpgradeInfo = plotUpgrade.FirstUpgradeInfo
		assert(firstUpgradeInfo:IsA("Frame"), "PlotUpgrade.FirstUpgradeInfo template must be a Frame")
		local firstUpgrade = plotUpgrade.FirstUpgrade
		assert(firstUpgrade:IsA("ImageButton"), "PlotUpgrade.FirstUpgrade template must be an ImageButton")
		local v = nil
		local backgroundColor3 = nil
		local enabled = nil

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getProductForLevel(nextTier: number)
			local formatted = `BaseUpgradeTier{nextTier}`

			if Products.ProductNameExists(formatted) then
				return Products.Directory[formatted]
			end

			return nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshPlotUpgradeVisibility()
			PlotUpgradeVisibility.Apply("PlotUpgrade")
		end

		local function bindLocalPlot()
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
			local plotUpgrade2 = plotFolder:WaitForChild("PlotUpgrade")
			assert(plotUpgrade2:IsA("Model"), "PlotUpgrade must be a Model")
			local sign = plotUpgrade2.Sign
			assert(sign:IsA("BasePart"), "PlotUpgrade.Sign must be a BasePart")
			local canUpgrade = sign.CanUpgrade
			assert(canUpgrade:IsA("BillboardGui"), "PlotUpgrade.Sign.CanUpgrade must be a BillboardGui")
			local surfaceGui = sign.SurfaceGui
			assert(surfaceGui:IsA("SurfaceGui"), "PlotUpgrade.Sign.SurfaceGui must be a SurfaceGui")
			local info = surfaceGui.Info
			assert(info:IsA("TextLabel"), "PlotUpgrade.Sign.SurfaceGui.Info must be a TextLabel")
			local level = surfaceGui.Level
			assert(level:IsA("TextLabel"), "PlotUpgrade.Sign.SurfaceGui.Level must be a TextLabel")
			local frame = surfaceGui.Frame
			assert(frame:IsA("GuiObject"), "PlotUpgrade.Sign.SurfaceGui.Frame must be a GuiObject")
			local upgrade = frame.Upgrade
			assert(upgrade:IsA("GuiButton"), "Plot Upgrade must be a GuiButton")
			local robuxUpgrade = frame.RobuxUpgrade
			assert(robuxUpgrade:IsA("GuiButton"), "Plot RobuxUpgrade must be a GuiButton")
			local cost = upgrade.Cost
			assert(cost:IsA("TextLabel"), "Plot Upgrade.Cost must be a TextLabel")
			local uIGradient = upgrade:FindFirstChildOfClass("UIGradient")

			if backgroundColor3 == nil then
				backgroundColor3 = upgrade.BackgroundColor3
			end

			if uIGradient ~= nil and enabled == nil then
				enabled = uIGradient.Enabled
			end

			local v2 = assert(backgroundColor3, "Plot Upgrade authored background color must be initialized")
			upgrade.AutoButtonColor = false
			local maid = Trove.new()
			local clone = firstUpgradeInfo:Clone()
			local icon = clone.Icon
			assert(icon:IsA("ImageLabel"), "Plot FirstUpgradeInfo.Icon must be an ImageLabel")
			local clone2 = firstUpgrade:Clone()
			local cost2 = clone2.Cost
			assert(cost2:IsA("TextLabel"), "Plot FirstUpgrade.Cost must be a TextLabel")
			local progressFill = clone2.ProgressFill
			assert(progressFill:IsA("Frame"), "Plot FirstUpgrade.ProgressFill must be a Frame")
			local uIGradient2 = clone2.UIGradient
			assert(uIGradient2:IsA("UIGradient"), "Plot FirstUpgrade button gradient must be a UIGradient")
			local backgroundColor32 = clone2.BackgroundColor3
			local enabled2 = uIGradient2.Enabled
			local size = progressFill.Size
			clone.Visible = false
			clone.Parent = surfaceGui
			maid:Add(clone)
			local uIScale = EnsureUIScale(icon)
			uIScale.Scale = 0.8
			local tween = TweenService:Create(uIScale, tweenInfo, {
				Scale = 1.3
			})
			maid:Add(tween)
			tween:Play()
			clone2.Visible = false
			clone2.AutoButtonColor = false
			clone2.Parent = frame
			maid:Add(clone2)
			v = maid

			local function refresh()
				local v4 = Save.Await()
				assert(v4 ~= nil, "Plot upgrade UI requires loaded data")
				local visible = v4.BaseUpgradeLevel == 0
				info.Visible = not visible
				level.Visible = not visible
				clone.Visible = visible
				upgrade.Visible = not visible
				clone2.Visible = visible
				local nextTier, v6 = BaseUpgrade.ResolveNextTier(v4)
				local isNextTierAffordable = BaseUpgrade.IsNextTierAffordable(v4)
				canUpgrade.Enabled = isNextTierAffordable
				local upgrade2 = upgrade
				local backgroundColor

				if isNextTierAffordable then
					backgroundColor = v2
				else
					backgroundColor = color
				end

				upgrade2.BackgroundColor3 = backgroundColor

				if uIGradient ~= nil then
					uIGradient.Enabled = isNextTierAffordable and enabled == true
				end

				local v9 = clone2
				local backgroundColor2

				if isNextTierAffordable then
					backgroundColor2 = backgroundColor32
				else
					backgroundColor2 = color
				end

				v9.BackgroundColor3 = backgroundColor2
				uIGradient2.Enabled = isNextTierAffordable and enabled2

				if nextTier == nil or v6 == nil then
					level.Text = "Level MAX"
					cost.Text = "MAX"
					robuxUpgrade.Visible = false
				else
					level.Text = `Level {v4.BaseUpgradeLevel} > Level {nextTier}`
					local text = "$" .. Simple.FormatCompact(v6.Cost, ".#")
					cost.Text = text
					cost2.Text = text
					assert(v6.Cost > 0, "Plot upgrade cost must be positive")
					local v12 = math.clamp(v4.Money / v6.Cost, 0, 1)
					progressFill.Size = UDim2.new(v12, size.X.Offset, size.Y.Scale, size.Y.Offset)
					robuxUpgrade.Visible = false
				end
			end

			maid:Add(ButtonFX(upgrade, 1.05, BaseUpgrade.PurchaseNextTier))
			maid:Add(ButtonFX(clone2, 1.05, BaseUpgrade.PurchaseNextTier))
			maid:Add(ButtonFX(robuxUpgrade, 1.05, function()
				local v4 = Save.Await()
				assert(v4 ~= nil, "Plot Robux upgrade requires loaded data")
				local nextTier, v5 = BaseUpgrade.ResolveNextTier(v4)

				if nextTier == nil or v5 == nil then
					return
				end

				local productForLevel = getProductForLevel(nextTier) -- equivalent call inferred; original call site unknown

				if productForLevel ~= nil then
					Storefront.Prompt(productForLevel.ProductId, true)
				end
			end))
			maid:Add(Save.Watch("BaseUpgradeLevel"):Connect(refresh))
			maid:Add(Save.Watch("Money"):Connect(refresh))
			refresh()
		end

		Save.Await()
		bindLocalPlot()
		refreshPlotUpgradeVisibility() -- equivalent call inferred; original call site unknown
		PlotState.LocalPlotChanged:Connect(function()
			bindLocalPlot()
			refreshPlotUpgradeVisibility() -- equivalent call inferred; original call site unknown
		end)
		PlotState.PlotChanged:Connect(refreshPlotUpgradeVisibility)
		PlotState.FolderChanged:Connect(refreshPlotUpgradeVisibility)
	end
}