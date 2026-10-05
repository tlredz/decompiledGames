local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local Option = require(game.ReplicatedStorage.Packages.Option)
local OutlinedMaterialIconsHD = require(game.ReplicatedStorage.Packages.OutlinedMaterialIconsHD)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)
require(game.ReplicatedStorage.React.Components.Inventory.Types)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
require(game.ReplicatedStorage.Spritesheets)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local use = require(game.ReplicatedStorage.React.Hooks.Item.Quantity.use)
local useMastery = require(game.ReplicatedStorage.React.Hooks.Item.useMastery)
local useSelection = require(game.ReplicatedStorage.React.Hooks.Item.useSelection)
local GlowGradient = require(script.GlowGradient)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	local v, v2, _ = useSelection()
	local v3 = use(v, v2)
	local v4 = useMatch(v)
	local v5 = useMastery(v, v2)
	local v6 = useMatch(v)
	local color = React.useMemo(function()
		if v6 then
			return Option.map(RarityUtil.matchRarity(v6.Quality.Rarity or "Common"), function(p2)
				return p2.Color
			end):asNullable()
		end

		return CONSTANTS.COLOR.PALETTE.WHITE
	end, { v6 })

	if v6 and not table.find(v6.Inventory.Groups, PseudoEnum.InventoryItemGroup.Stash) and v6.State.StorageMethod ~= PseudoEnum.ItemStorageMethod.StoredFruits and v3 and v3 <= 1 then
		v3 = nil
	end

	if RunService:IsRunning() == false then
		color = Color3.new(1, 0, 1)
	end

	local v7 = React.useMemo(function()
		if not v6 then
			return OutlinedMaterialIconsHD.broken_image
		end

		local sprite = v6.Display.Sprite
		local spriteBorderThickness = v6.Display.SpriteBorderThickness

		if not sprite then
			return OutlinedMaterialIconsHD.broken_image
		end

		if spriteBorderThickness then
			return {
				Image = sprite.Image,
				ImageRectOffset = (sprite.ImageRectOffset or Vector2.zero) + Vector2.one * spriteBorderThickness,
				ImageRectSize = (sprite.ImageRectSize or Vector2.zero) - Vector2.one * 2 * spriteBorderThickness
			}
		end

		return sprite
	end, { v6 })
	local outlineSprite

	if v6 then
		outlineSprite = v6.Display.OutlineSprite
	end

	local backgroundColor3 = p.BackgroundColor3 or CONSTANTS.COLOR.PANEL.BACKGROUND
	local mergeImageLabel = RobloxTypes.mergeImageLabel({
		BackgroundColor3 = backgroundColor3,
		Image = "http://www.roblox.com/asset/?id=14514122503",
		ImageColor3 = color,
		ImageRectOffset = Vector2.zero,
		ImageRectSize = Vector2.zero,
		ScaleType = Enum.ScaleType.Stretch
	}, p)
	local v10 = {
		UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 1),
			PaddingLeft = CONSTANTS.SPACING.PADDING.NONE,
			PaddingRight = CONSTANTS.SPACING.PADDING.NONE,
			PaddingTop = UDim.new(0.01, 5)
		}),
		UIGradient = createElement(GlowGradient, {}),
		Header = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(1, 0.175),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			UIPadding = createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 4),
				PaddingTop = UDim.new(0, 1)
			}),
			Category = createElement("TextLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY_LIGHT,
				RichText = true,
				Size = UDim2.fromScale(1, 1),
				Text = FormatUtil.italic(not (v6 and v6.Display.Category) and "..." or v6.Display.Category),
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			})
		}),
		IconAnchor = 0,
		Footer = 0
	}
	local v13 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.5, 0.4875),
		Size = UDim2.fromScale(1, 0.625),
		ZIndex = CONSTANTS.LAYER.BASE
	}
	local v17 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = 0,
		ImageContent = 0,
		ImageRectOffset = 0,
		ImageRectSize = 0,
		LayoutOrder = 2,
		Position = 0,
		ScaleType = 0,
		Size = 0,
		SizeConstraint = 0,
		ZIndex = 0
	}
	local image

	if typeof(v7.Image) == "string" then
		image = v7.Image
	end

	v17.Image = image
	local imageContent

	if typeof(v7.Image) ~= "string" then
		imageContent = v7.Image
	end

	v17.ImageContent = imageContent
	v17.ImageRectOffset = v7.ImageRectOffset
	v17.ImageRectSize = v7.ImageRectSize
	v17.Position = UDim2.fromScale(0.5, 0.6)
	v17.ScaleType = Enum.ScaleType.Fit
	v17.Size = UDim2.fromScale(1.25, 1.25)
	v17.SizeConstraint = Enum.SizeConstraint.RelativeYY
	v17.ZIndex = CONSTANTS.LAYER.RAISED
	local v14 = {
		Icon = createElement("ImageLabel", v17),
		OutlineIcon = 0
	}
	local outlineIcon

	if outlineSprite then
		local v23 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = 0,
			ImageColor3 = 0,
			ImageContent = 0,
			ImageRectOffset = 0,
			ImageRectSize = 0,
			LayoutOrder = 2,
			Position = 0,
			ScaleType = 0,
			Size = 0,
			SizeConstraint = 0
		}
		local image2

		if typeof(outlineSprite.Image) == "string" then
			image2 = outlineSprite.Image
		end

		v23.Image = image2
		v23.ImageColor3 = v4 and v4.Display.OutlineColor or CONSTANTS.COLOR.PALETTE.BLACK
		local imageContent2

		if typeof(outlineSprite.Image) ~= "string" then
			imageContent2 = outlineSprite.Image
		end

		v23.ImageContent = imageContent2
		v23.ImageRectOffset = outlineSprite.ImageRectOffset
		v23.ImageRectSize = outlineSprite.ImageRectSize
		v23.Position = UDim2.fromScale(0.5, 0.6)
		v23.ScaleType = Enum.ScaleType.Fit
		v23.Size = UDim2.fromScale(1.25, 1.25)
		v23.SizeConstraint = Enum.SizeConstraint.RelativeYY
		outlineIcon = createElement("ImageLabel", v23)
	end

	v14.OutlineIcon = outlineIcon
	v10.IconAnchor = createElement("Frame", v13, v14)
	local v23 = {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.5, 1),
		Size = UDim2.fromScale(1, 0.2),
		ZIndex = CONSTANTS.LAYER.RAISED
	}
	local v24 = {
		UIPadding = createElement("UIPadding", {
			PaddingBottom = CONSTANTS.SPACING.PADDING.OFFSET.XS
		}),
		CountRibbon = 0,
		Mastery = 0
	}
	local countRibbon

	if v3 then
		countRibbon = createElement("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = backgroundColor3,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(0.5, 1)
		}, {
			UISizeConstraint = createElement("UISizeConstraint", {
				MaxSize = Vector2.new(70, 1e999)
			}),
			UIGradient = createElement("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.2, 0.5),
					NumberSequenceKeypoint.new(0.5, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			UIPadding = createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 1),
				PaddingLeft = UDim.new(0, 4)
			}),
			Count = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY_LIGHT,
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(1, 1),
				Text = `{v3}`,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextWrapped = false,
				TextXAlignment = Enum.TextXAlignment.Left
			})
		})
	end

	v24.CountRibbon = countRibbon
	local mastery

	if v5 then
		mastery = createElement("TextLabel", {
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY_LIGHT,
			Position = UDim2.fromScale(1, 1),
			Size = UDim2.fromScale(0.5, 1),
			Text = `{v5} Mastery`,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextTruncate = Enum.TextTruncate.None,
			TextWrapped = false,
			TextXAlignment = Enum.TextXAlignment.Right
		}, {
			UIStroke = createElement("UIStroke", {
				Color = CONSTANTS.COLOR.PANEL.BACKGROUND,
				Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN,
				Transparency = 0.45
			}),
			UIPadding = createElement("UIPadding", {
				PaddingBottom = UDim.new(0, 1),
				PaddingRight = UDim.new(0, 4)
			})
		})
	end

	v24.Mastery = mastery
	v10.Footer = createElement("Frame", v23, v24)
	return createElement("ImageLabel", mergeImageLabel, v10)
end