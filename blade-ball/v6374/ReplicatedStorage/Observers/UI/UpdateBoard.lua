local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local packages = ReplicatedStorage.Packages
local shared = ReplicatedStorage.Shared
local Observers = require(packages.Observers)
local Utils = require(ReplicatedStorage.Common.Utils)
local UpdateCrate = require(shared.UpdateCrate)
require(ReplicatedStorage.Common.UpdateGiftRewards)
local Replion = require(packages.Replion)
require(shared.ReplicatedInstances.Swords)
require("@game/ReplicatedStorage/Types/Templates/Lobbies")
local MIN_TIME_TO_SHOW = Utils.Settings.MIN_TIME_TO_SHOW
local MIN_TIME_FOR_UPDATE = Utils.Settings.MIN_TIME_FOR_UPDATE
local _ = Utils.Settings.TIME_TO_UNLOCK_UPDATE_GIFT
local _ = Utils.Settings.TIME_TO_CLAIM_UPDATE_GIFT
local crate = UpdateCrate.Crates[UpdateCrate.CurrentCrate]
local rewards = crate and crate.Rewards
local v = Replion.Client:WaitReplion("LimitedStockItems")
Replion.Client:WaitReplion("Data")

local function setPartsHidden(folder, p, p2)
	for _, part in folder:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		if p then
			part.Transparency = 1
			part.CanCollide = false
		else
			local v2 = p2[part]

			if v2 then
				part.Transparency = v2.Transparency
				part.CanCollide = v2.CanCollide
			end
		end
	end
end

local function captureOriginalParts(folder)
	local result = {}

	for _, part in folder:GetDescendants() do
		if part:IsA("BasePart") then
			result[part] = {
				Transparency = part.Transparency,
				CanCollide = part.CanCollide
			}
		end
	end

	return result
end

local function applyRainbow(mainFrame)
	mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
	mainFrame.UIStroke:SetAttribute("ColorConfig", "SlowChroma")
	mainFrame.UIStroke:AddTag("TweenColor")
	mainFrame.Glow:SetAttribute("ColorConfig", "SlowChroma")
	mainFrame.Glow:AddTag("TweenColor")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatChanceText(p)
	if p < 0.1 then
		return "???%"
	end

	return tostring((math.floor(p))) .. "%"
end

local function createRewardFramesForCrate(crate2, itemFrame)
	if not rewards then
		return
	end

	local rewards2 = {}
	local total = 0

	for k, reward in rewards do
		local content = reward.Contents[1]

		if not content then
			continue
		end

		if content.Reward.Value == UpdateCrate.LimitedStockRewardId then
			if v:Get("Loaded") ~= true then
				continue
			end

			local v2 = v:Get({ "Stock", UpdateCrate.LimitedStockRewardId })

			if not v:Get({ "InitialStock", UpdateCrate.LimitedStockRewardId }) or not v2 or v2 <= 0 then
				continue
			end
		end

		rewards2[k] = reward
		total += reward.Chance
	end

	for _, v2 in rewards2 do
		local clone = itemFrame:Clone()
		clone.Name = "Item"
		clone.Visible = true
		clone.LayoutOrder = v2.Chance
		clone.MainFrame.Icon.Image = v2.Icon
		local v3 = v2.Chance / total * 100
		clone.MainFrame.Rarity.Text = formatChanceText(v3)

		if v3 < 0.5 then
			applyRainbow(clone.MainFrame)
		elseif v2.CustomTierColor then
			clone.MainFrame.BackgroundColor3 = Color3.new(
				v2.CustomTierColor.R * 0.2,
				v2.CustomTierColor.G * 0.2,
				v2.CustomTierColor.B * 0.2
			)
			clone.MainFrame.Glow.ImageColor3 = v2.CustomTierColor
		end

		clone.Parent = crate2.BillboardGui.Rewards
		local content = v2.Contents[1]

		if content and content.Reward.Value == UpdateCrate.LimitedStockRewardId then
			clone.MainFrame.Stock.Visible = true
			local v4 = clone

			local function updateStock()
				local v5 = v:Get({ "Stock", UpdateCrate.LimitedStockRewardId })
				v4.MainFrame.Stock.Text = `{Utils.ValueConvertor:AddCommas(v5 or 0)} Left`
			end

			v:OnChange({ "Stock", UpdateCrate.LimitedStockRewardId }, updateStock)
			v:OnChange({ "InitialStock", UpdateCrate.LimitedStockRewardId }, updateStock)
			updateStock()
		else
			clone.MainFrame.Stock.Visible = false
		end
	end
end

return Observers.observeTagNoAncestry("UI_UpdateBoard", function(state)
	local maid = Utils.Maid.new()
	maid.Active = true
	local parent = state.Parent
	state.Parent = localPlayer.PlayerGui
	local crate2 = parent:WaitForChild("Crate")
	local billboardGui = crate2:WaitForChild("BillboardGui")
	local itemFrame = billboardGui.Rewards.ItemFrame
	itemFrame.Parent = nil
	crate2.ProximityPrompt.Triggered:Connect(function()
		Utils.Network:Fire("ClaimUpdateGift")
	end)
	captureOriginalParts(crate2)

	for _, part in crate2:GetDescendants() do
		if not part:IsA("BasePart") then
			continue
		end

		part.Transparency = 1
		part.CanCollide = false
	end

	billboardGui.Enabled = false
	crate2.ProximityPrompt.Enabled = false

	while not Utils.Settings.UPDATE_RELEASE_TIME and maid.Active do
		task.wait(1)
	end

	if not maid.Active then
		return
	end

	Replion.Client:AwaitReplion("Data", function(object)
		if not maid.Active then
			return
		end

		local maid2 = Utils.Maid.new()
		maid.TimerUpdate = Utils.Thread.Every(0.75, function()
			local now = os.time()
			local v2 = Utils.Settings.UPDATE_RELEASE_TIME - now

			if MIN_TIME_TO_SHOW < v2 then
				state.Enabled = false
			elseif v2 > 0 then
				state.Enabled = true
				state.Content.TimerLabel.Text = "UPDATE IN \n" .. Utils.ValueConvertor:FormatTimeWithDaysFull(v2)
			else
				if -MIN_TIME_FOR_UPDATE < v2 then
					state.Content.TimerLabel.Text = "UPDATING...\nThanks for waiting <3"
					return
				end

				if maid2.Active then
				end

				maid:Destroy()
				state.Enabled = false
			end
		end)
		createRewardFramesForCrate(crate2, itemFrame)

		-- equivalent calls inferred from this helper; original call sites unknown
		local function onUpdateGiftChanged(updateGift)
			maid2.Active = updateGift
		end

		onUpdateGiftChanged(object:Get("UpdateGift")) -- equivalent call inferred; original call site unknown
		maid.OnUpdateGiftChanged = object:OnChange("UpdateGift", onUpdateGiftChanged)
	end)
	return function()
		maid:Destroy()
	end
end)