local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

if not RunService:IsClient() then
	return {}
end

local AsyncUtils = require(ReplicatedStorage._FRAMEWORK.Libraries.Basics.AsyncUtils)
local Items = require(ReplicatedStorage.FeatureConfigs.Items)
local ItemRarityGradient = require(ReplicatedStorage.Utilities.ItemRarityGradient)
local LimitedSerialLabel = require(ReplicatedStorage._FRAMEWORK.Libraries.uiComponents.LimitedSerialLabel)
local ItemSignatures = require(ReplicatedStorage._FRAMEWORK.Features.ItemSignatures)
local Config = require(script.Parent.Parent.Config)
require(script.Parent.Parent.Types)
local UiHelpers = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function getTemplates()
	return ReplicatedStorage:FindFirstChild("Templates")
end

local function applyThumbnail(avatarImage, p: number?)
	if p then
		AsyncUtils.getUserThumbnail(p, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150):andThen(function(image)
			if avatarImage.Parent then
				avatarImage.Image = image
			end
		end):catch(function()
			if avatarImage.Parent then
				avatarImage.Image = Config.PlaceholderAvatarImage
			end
		end)
	else
		avatarImage.Image = Config.PlaceholderAvatarImage
	end
end

local function fillStars(tierFrame, emphasizedStar, tier)
	local layoutContainer = tierFrame.LayoutContainer

	for _, guiObject in ipairs(layoutContainer:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	for _ = 1, tier do
		local clone = emphasizedStar:Clone()
		clone.Visible = true
		clone.Parent = layoutContainer
	end
end

function UiHelpers.truncatePlayerName(value: string, p: number)
	if not (p < (utf8.len(value) or #value)) then
		return value
	end

	local v = utf8.offset(value, p)
	local v3

	if v then
		v3 = v - 1
	else
		v3 = p - 1
	end

	return string.sub(value, 1, v3) .. "-"
end

function UiHelpers.fillAvatarCircle(p, p2: number?)
	applyThumbnail(p.AvatarImage, p2)
end

function UiHelpers.fillAvatarFrame(instance, p: number?, value: string?)
	UiHelpers.fillAvatarCircle(instance.AvatarCircle, p)
	local playerNameBg = instance:FindFirstChild("PlayerNameBg")
	local playerNameLabel = playerNameBg and playerNameBg:FindFirstChild("PlayerNameLabel")

	if playerNameLabel then
		playerNameLabel.Text = p and (value or "") or ""
	end
end

function UiHelpers.fillAvatarCircleButton(p, p2: number, p3: string)
	UiHelpers.fillAvatarCircle(p, p2)
	p.PlayerNameBg.PlayerNameLabel.Text = UiHelpers.truncatePlayerName(p3, 8)
end

function UiHelpers.cloneAvatarCircleButton()
	local clone = ReplicatedStorage:FindFirstChild("Templates").AvatarCircleButton:Clone()
	clone.Visible = true
	return clone
end

function UiHelpers.createModalButton(childName: string, text: string, parent)
	local templates = getTemplates() -- equivalent call inferred; original call site unknown
	local child = templates and templates:FindFirstChild(childName)

	if not child then
		warn("[Trading.UiHelpers] Missing template", childName)
		return nil
	end

	local clone = child:Clone()
	clone.Visible = true
	clone.TextLabel.Text = text
	clone.Parent = parent
	return clone
end

function UiHelpers.fillItemButton(p, parent, options)
	local v = options or {}
	local templates = getTemplates() -- equivalent call inferred; original call site unknown
	local templateName = v.templateName or "TemplateItemButton"
	local child = templates and templates:FindFirstChild(templateName)
	local emphasizedStar = templates and templates:FindFirstChild("EmphasizedStar")
	local key = Items.KeyOf(p)
	local v2 = Items.ITEMS[key]

	if not (child and emphasizedStar and v2) then
		return nil
	end

	local tier = Items.TierOf(p)
	local limitedNumber = Items.LimitedNumberOf(p)
	local maxLimited = Items.MaxLimitedOf(p)
	local clone = child:Clone()
	clone.Name = "Item_" .. key .. "_" .. tier
	clone.SpotFrame.Icon.Image = v2.icon
	clone.NameLabel.Text = v2.shortName or v2.name

	if limitedNumber and maxLimited then
		local limitedSerialLabel = LimitedSerialLabel({
			serial = limitedNumber,
			maxSerial = maxLimited
		})
		limitedSerialLabel.Parent = clone.NameLabel
	end

	local label = ItemSignatures.createLabel(p)

	if label then
		label.Parent = clone
	end

	clone.Multiplier.Text = "+" .. Items.EntryBonusPercent(p) .. "%"
	fillStars(clone.TierFrame, emphasizedStar, tier)
	clone.LayoutOrder = v.layoutOrder or (Items.RARITY_PRIORITY[v2.rarity] or 8) * 10 - tier
	ItemRarityGradient.apply(clone.SpotFrame, v2.rarity)

	if clone:IsA("GuiButton") then
		local selectable = v.active == nil or v.active
		clone.Active = selectable

		if v.selectable ~= nil then
			selectable = v.selectable
		end

		clone.Selectable = selectable
	end

	clone.Visible = true
	clone.Parent = parent
	return clone
end

function UiHelpers.clearItemButtons(instance)
	for _, button in ipairs(instance:GetChildren()) do
		if not (button:IsA("GuiButton") or string.sub(button.Name, 1, 5) == "Item_") then
			continue
		end

		button:Destroy()
	end
end

function UiHelpers.sumOfferBonusPercent(list)
	local total = 0

	for _, v in ipairs(list) do
		total += Items.EntryBonusPercent(v)
	end

	return total
end

function UiHelpers.findTaggedInPlayerGui(tag: string)
	local localPlayer = Players.LocalPlayer
	local playerGui = localPlayer and localPlayer:FindFirstChild("PlayerGui")

	if not playerGui then
		return nil
	end

	for _, guiObject in ipairs(CollectionService:GetTagged(tag)) do
		if guiObject:IsA("GuiObject") and guiObject:IsDescendantOf(playerGui) then
			return guiObject
		end
	end

	return nil
end

function UiHelpers.styleToTemplate(p)
	if p == "Negative" then
		return "NegativeButton"
	elseif p == "Positive" then
		return "PositiveButton"
	end

	return "NeutralButton"
end

return UiHelpers