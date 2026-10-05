local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local AdminBoosts = require(ReplicatedStorage.Shared.Util.AdminBoosts)
local AssetItems = require(ReplicatedStorage.Shared.Util.AssetItems)
local AssetRoster = require(ReplicatedStorage.Client.AssetRoster)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local Player = require(ReplicatedStorage.Shared.Player)
local PlotState = require(ReplicatedStorage.Client.PlotState)
local Save = require(ReplicatedStorage.Shared.Save)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local Trove = require(ReplicatedStorage.Packages.Trove)
local OFFLINE_ASSETS = Constants.OFFLINE_ASSETS
local localPlayer = Players.LocalPlayer
return {
	Start = function()
		local playerGui = localPlayer:WaitForChild("PlayerGui")
		assert(playerGui:IsA("PlayerGui"), "Expected PlayerGui")
		local offlineMoneyInPlot = playerGui:WaitForChild("OfflineMoneyInPlot")
		assert(offlineMoneyInPlot:IsA("ScreenGui"), "OfflineMoneyInPlot must be a ScreenGui")
		local topBar = offlineMoneyInPlot:WaitForChild("TopBar")
		assert(topBar:IsA("GuiObject"), "OfflineMoneyInPlot.TopBar must be a GuiObject")
		local inPlot = topBar:WaitForChild("InPlot")
		assert(inPlot:IsA("GuiObject"), "OfflineMoneyInPlot.TopBar.InPlot must be a GuiObject")
		local textLabel = inPlot:WaitForChild("TextLabel")
		assert(textLabel:IsA("TextLabel"), "OfflineMoneyInPlot.TopBar.InPlot.TextLabel must be a TextLabel")
		local maid = Trove.new()
		local v = 0
		local updateVisibility

		local function formatOfflineAmount(p: number)
			return Simple.FormatCompact((math.max(p, 0)))
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function getOfflinePreviewAmountFromTotalRate(p: number)
			return math.max(p, 0) * OFFLINE_ASSETS.MAX_DURATION_SECONDS * OFFLINE_ASSETS.MONEY_RATE_MULTIPLIER
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function updateText()
			textLabel.RichText = true
			textLabel.Text = string.format(
				"You earn <font color = \"#00ff00\">$%s</font>/Day offline! 😈",
				formatOfflineAmount(getOfflinePreviewAmountFromTotalRate(v))
			)
		end

		local function isWorldPositionInsideScaledPetAreaXZ(position: Vector3)
			local penArea = AssetRoster.FindPenArea(localPlayer)

			if penArea == nil then
				return false
			end

			local pointToObjectSpace = penArea.CFrame:PointToObjectSpace(position)
			local v2 = penArea.Size.X * 0.74 * 0.5
			local v3 = penArea.Size.Z * 0.74 * 0.5
			return math.abs(pointToObjectSpace.X) <= v2 and math.abs(pointToObjectSpace.Z) <= v3
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function refreshRateFromSave()
			local v2 = Save.Await()
			v = v2 == nil and 0 or AssetItems.ProfileIncomePerSecond(localPlayer, v2)
			updateText() -- equivalent call inferred; original call site unknown
			updateVisibility()
		end

		updateVisibility = function()
			local rootPart = Player.FindRootPart(localPlayer)
			local enabled = not HiddenUIHandler.IsHidden()

			if enabled then
				if v > 1000 and rootPart ~= nil then
					enabled = isWorldPositionInsideScaledPetAreaXZ(rootPart.Position)
				else
					enabled = false
				end
			end

			offlineMoneyInPlot.Enabled = enabled
		end

		textLabel.RichText = true
		offlineMoneyInPlot.Enabled = false
		local v2 = Save.Await()

		if v2 == nil then
			v = 0
		else
			v = AssetItems.ProfileIncomePerSecond(localPlayer, v2)
		end

		textLabel.RichText = true
		textLabel.Text = string.format(
			"You earn <font color = \"#00ff00\">$%s</font>/Day offline! 😈",
			formatOfflineAmount(getOfflinePreviewAmountFromTotalRate(v))
		)
		updateVisibility()
		updateVisibility()
		maid:Add(Save.WatchFields({
			"EquippedAssets",
			"Inventory",
			"Gamepasses",
			"Products"
		}, refreshRateFromSave))
		maid:Add(AdminBoosts.Observe(AdminBoosts.EARNINGS):Connect(refreshRateFromSave))
		maid:Add(Save.Loaded:Connect(function(p)
			if p == localPlayer then
				refreshRateFromSave() -- equivalent call inferred; original call site unknown
			end
		end))
		maid:Add(PlotState.LocalPlotChanged:Connect(updateVisibility))
		maid:Connect(RunService.Heartbeat, updateVisibility)
	end
}