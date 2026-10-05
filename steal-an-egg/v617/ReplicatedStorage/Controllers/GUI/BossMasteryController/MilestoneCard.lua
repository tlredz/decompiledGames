local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local HoverCard = require(ReplicatedStorage.Client.HoverCard)
local Numbers = require(ReplicatedStorage.Shared.Utils.Numbers)
local Rarity = require(ReplicatedStorage.Data.Rarity)
local SwapGradient = require(ReplicatedStorage.Shared.Utils.SwapGradient)
local Timer = require(ReplicatedStorage.Packages.Timer)
local Trove = require(ReplicatedStorage.Packages.Trove)

-- equivalent calls inferred from this helper; original call sites unknown
local function colorAttribute(instance, attributeName: string)
	local attribute = instance:GetAttribute(attributeName)
	assert(typeof(attribute) == "Color3", (`{instance:GetFullName()} is missing {attributeName}`))
	return attribute
end

-- equivalent calls inferred from this helper; original call sites unknown
local function numberAttribute(instance, attributeName: string)
	local attribute = instance:GetAttribute(attributeName)
	assert(typeof(attribute) == "number", (`{instance:GetFullName()} is missing {attributeName}`))
	return attribute
end

local function stringAttribute(instance, attributeName: string)
	local attribute = instance:GetAttribute(attributeName)
	assert(typeof(attribute) == "string", (`{instance:GetFullName()} is missing {attributeName}`))
	return attribute
end

return table.freeze({
	New = function(instance, parent, name: string, callback, flag: boolean?)
		local clone = instance:Clone()
		clone.Name = name
		clone.Visible = true
		clone.Parent = parent
		local masteryLabel = clone.MasteryLabel
		local fill = clone.Fill
		local bGDecor = clone.BGDecor
		local accentStroke = clone:FindFirstChild("AccentStroke") or clone.StrokeHolder.AccentStroke
		local uIShadow = clone:FindFirstChildOfClass("UIShadow")
		local claim = clone.Claim
		claim.Active = true
		claim.Selectable = true
		claim.Interactable = true
		local uIGradient = claim:FindFirstChildOfClass("UIGradient")
		local uIStroke = claim.UIStroke
		local uIStrokeClr = claim.UIStrokeClr
		local price = claim.Price
		local rewardTitle = clone.RewardTitle
		local rewardHolder = clone.RewardHolder
		local template = rewardHolder:FindFirstChild("Template") or rewardHolder.Chip
		local clone2 = template:Clone()
		local icon = clone2.Icon
		local amount = clone2.Amount
		local itemName = clone2:FindFirstChild("ItemName")
		local completedCheckmark = clone2.CompletedCheckmark
		local v2 = "Locked"
		local v3 = false
		local hoverTitle = nil
		local hoverDescription = nil
		local maid = Trove.new()
		assert(uIShadow ~= nil, (`{clone:GetFullName()} is missing UIShadow`))
		assert(uIGradient ~= nil, (`{claim:GetFullName()} is missing UIGradient`))
		template.Visible = false
		clone2.Name = "Reward"
		clone2.Visible = true
		clone2.Parent = rewardHolder

		local function refreshIcon(data)
			maid:Clean()
			icon.Image = data.Icon
			icon.ImageTransparency = 0
			local cycleIcons = data.CycleIcons

			if cycleIcons == nil or #cycleIcons <= 1 then
				return
			end

			local clone3 = icon:Clone()
			clone3.Name = "IncomingIcon"
			clone3.Active = false
			clone3.Selectable = false
			clone3.ImageTransparency = 1
			clone3.Parent = icon.Parent
			maid:Add(clone3)
			local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
			local v4 = {
				[icon] = maid:Add(TweenService:Create(icon, tweenInfo, {
					ImageTransparency = 0
				})),
				[clone3] = maid:Add(TweenService:Create(clone3, tweenInfo, {
					ImageTransparency = 0
				}))
			}
			local v5 = {
				[icon] = maid:Add(TweenService:Create(icon, tweenInfo, {
					ImageTransparency = 1
				})),
				[clone3] = maid:Add(TweenService:Create(clone3, tweenInfo, {
					ImageTransparency = 1
				}))
			}
			local v6 = icon
			local v7 = clone3
			local v8 = 1
			local v9 = maid:Add(Timer.new(1.35))
			maid:Connect(v9.Tick, function()
				v8 = v8 % #cycleIcons + 1
				v7.Image = cycleIcons[v8]
				v5[v6]:Play()
				v4[v7]:Play()
				v6, v7 = v7, v6
			end)
			v9:Start()
		end

		local function applyState(p: string)
			v2 = p
			local v4 = p == "Claimable" and "Claimable" or "Locked"

			if not flag then
				fill.BackgroundColor3 = colorAttribute(clone, v4 .. "FillColor")
				uIShadow.Color = colorAttribute(clone, v4 .. "ShadowColor")
				accentStroke.Color = colorAttribute(clone, v4 .. "AccentColor")
				bGDecor.ImageColor3 = colorAttribute(clone, v4 .. "DecorColor")
				bGDecor.ImageTransparency = numberAttribute(clone, v4 .. "DecorTransparency")
			end

			local v5 = uIGradient
			local attribute = colorAttribute(claim, v4 .. "ColorStart") -- equivalent call inferred; original call site unknown
			v5.Color = ColorSequence.new(attribute, colorAttribute(claim, v4 .. "ColorEnd"))
			uIStroke.Color = colorAttribute(claim, v4 .. "BorderColor")
			uIStrokeClr.Color = colorAttribute(claim, v4 .. "HighlightColor")
			local price2 = price
			local claimedText

			if v3 then
				claimedText = "Claiming..."
			elseif p == "Claimed" then
				local v18 = claim
				claimedText = v18:GetAttribute("ClaimedText")
				assert(typeof(claimedText) == "string", (`{v18:GetFullName()} is missing ClaimedText`))
			elseif p == "Locked" then
				claimedText = "Locked"
			else
				local v18 = claim
				local v19 = v4 .. "Text"
				claimedText = v18:GetAttribute(v19)
				assert(typeof(claimedText) == "string", (`{v18:GetFullName()} is missing {v19}`))
			end

			price2.Text = claimedText
			completedCheckmark.Visible = p == "Claimed"
			claim.AutoButtonColor = p == "Claimable" and not v3
		end

		local v4 = nil
		local buttonFX = ButtonFX(claim, 1.05, function()
			if v2 == "Claimable" and not v3 then
				callback(name, v4)
			end
		end)
		icon.Active = true
		local v6 = HoverCard.Attach(icon, function()
			if hoverTitle == nil or hoverDescription == nil then
				return nil
			end

			return {
				{
					kind = "heading",
					text = hoverTitle
				},
				{
					kind = "rule"
				},
				{
					kind = "heading",
					text = hoverDescription
				}
			}
		end)
		v4 = {
			Button = claim,
			Refresh = function(p: number, data, p2: string, layoutOrder: number)
				clone.LayoutOrder = layoutOrder
				masteryLabel.Text = Numbers.AddCommas(p)
				rewardTitle.Text = data.Title

				if itemName then
					itemName.Text = data.Rarity or data.Title
					local v7

					if data.Rarity then
						v7 = Rarity.Get(data.Rarity)
					end

					local v10

					if v7 then
						v10 = v7.RarityGradient
					end

					SwapGradient(itemName, v10)
				end

				refreshIcon(data)
				amount.Text = data.Amount
				hoverTitle = data.HoverTitle
				hoverDescription = data.HoverDescription
				applyState(p2)
			end,
			SetVisible = function(visible: boolean)
				clone.Visible = visible
			end,
			SetPending = function(flag2: boolean)
				v3 = flag2
				applyState(v2)
			end,
			Destroy = function()
				buttonFX()
				v6()
				maid:Destroy()
				clone:Destroy()
			end
		}
		return v4
	end
})