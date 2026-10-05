local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.Util)
local Option = require(game.ReplicatedStorage.Packages.Option)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)
require(game.ReplicatedStorage.React.RobloxTypes)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
require(game.ReplicatedStorage.AccessoriesShared)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local MaterialIconsHD = require(game.ReplicatedStorage.Packages.MaterialIconsHD)
require(game.ReplicatedStorage.React.Hooks.useDrawContext)
local usePeriod = require(game.ReplicatedStorage.React.Hooks.Animation.usePeriod)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local goldBadgeFavorited = SpriteMap.UI["Gold Badge Favorited"]
local silverBadgeFavorited = SpriteMap.UI["Silver Badge Favorited"]
local sourceSans = Font.new("SourceSans", Enum.FontWeight.Bold, Enum.FontStyle.Italic)
local broken_image = MaterialIconsHD.broken_image
local v = {
	Corrupted = SpriteMap.UI["Overlay Corrupted"],
	Celestial = SpriteMap.UI["Overlay Celestial"]
}
local v2 = {
	Color3.fromHSV(0, 1, 1),
	Color3.fromHSV(0.075, 1, 1),
	Color3.fromHSV(0.145, 1, 1),
	Color3.fromHSV(0.25, 1, 1),
	Color3.fromHSV(0.5, 1, 1),
	Color3.fromHSV(0.65, 1, 1),
	Color3.fromHSV(0.85, 1, 1)
}
local tiles = SpriteMap.Tiles
local badgeNew = SpriteMap.UI["Badge New"]
local badgeEquipped = SpriteMap.UI["Badge Equipped"]
local plus = SpriteMap.UI.Plus
local redBanner = SpriteMap.UI["Red Banner"]
local v3 = {}
local elevated = PseudoEnum.InventoryTileAppearance.Elevated
local v4 = {
	[PseudoEnum.Rarity.Common] = {
		[Enum.GuiState.Idle] = tiles["Tile Common Default"],
		[Enum.GuiState.NonInteractable] = tiles["Tile Common Default"],
		[Enum.GuiState.Hover] = tiles["Tile Common Active"],
		[Enum.GuiState.Press] = tiles["Tile Common Active"]
	}
}
local uncommon = PseudoEnum.Rarity.Uncommon
v4[uncommon] = {
	[Enum.GuiState.Idle] = tiles["Tile Uncommon Default"],
	[Enum.GuiState.NonInteractable] = tiles["Tile Uncommon Default"],
	[Enum.GuiState.Hover] = tiles["Tile Uncommon Active"],
	[Enum.GuiState.Press] = tiles["Tile Uncommon Active"]
}
local legendary = PseudoEnum.Rarity.Legendary
v4[legendary] = {
	[Enum.GuiState.Idle] = tiles["Tile Legendary Default"],
	[Enum.GuiState.NonInteractable] = tiles["Tile Legendary Default"],
	[Enum.GuiState.Hover] = tiles["Tile Legendary Active"],
	[Enum.GuiState.Press] = tiles["Tile Legendary Active"]
}
local rare = PseudoEnum.Rarity.Rare
v4[rare] = {
	[Enum.GuiState.Idle] = tiles["Tile Rare Default"],
	[Enum.GuiState.NonInteractable] = tiles["Tile Rare Default"],
	[Enum.GuiState.Hover] = tiles["Tile Rare Active"],
	[Enum.GuiState.Press] = tiles["Tile Rare Active"]
}
local mythical = PseudoEnum.Rarity.Mythical
v4[mythical] = {
	[Enum.GuiState.Idle] = tiles["Tile Mythical Default"],
	[Enum.GuiState.NonInteractable] = tiles["Tile Mythical Default"],
	[Enum.GuiState.Hover] = tiles["Tile Mythical Active"],
	[Enum.GuiState.Press] = tiles["Tile Mythical Active"]
}
local premium = PseudoEnum.Rarity.Premium
v4[premium] = {
	[Enum.GuiState.Idle] = tiles["Tile Premium Default"],
	[Enum.GuiState.NonInteractable] = tiles["Tile Premium Default"],
	[Enum.GuiState.Hover] = tiles["Tile Premium Active"],
	[Enum.GuiState.Press] = tiles["Tile Premium Active"]
}
v3[elevated] = v4
local clawed = PseudoEnum.InventoryTileAppearance.Clawed
local v11 = {
	[PseudoEnum.Rarity.Common] = {
		[Enum.GuiState.Idle] = tiles["Clawed Tile Common Default"],
		[Enum.GuiState.NonInteractable] = tiles["Clawed Tile Common Default"],
		[Enum.GuiState.Hover] = tiles["Clawed Tile Common Active"],
		[Enum.GuiState.Press] = tiles["Clawed Tile Common Active"]
	}
}
local uncommon2 = PseudoEnum.Rarity.Uncommon
v11[uncommon2] = {
	[Enum.GuiState.Idle] = tiles["Clawed Tile Uncommon Default"],
	[Enum.GuiState.NonInteractable] = tiles["Clawed Tile Uncommon Default"],
	[Enum.GuiState.Hover] = tiles["Clawed Tile Uncommon Active"],
	[Enum.GuiState.Press] = tiles["Clawed Tile Uncommon Active"]
}
local legendary2 = PseudoEnum.Rarity.Legendary
v11[legendary2] = {
	[Enum.GuiState.Idle] = tiles["Clawed Tile Legendary Default"],
	[Enum.GuiState.NonInteractable] = tiles["Clawed Tile Legendary Default"],
	[Enum.GuiState.Hover] = tiles["Clawed Tile Legendary Active"],
	[Enum.GuiState.Press] = tiles["Clawed Tile Legendary Active"]
}
local rare2 = PseudoEnum.Rarity.Rare
v11[rare2] = {
	[Enum.GuiState.Idle] = tiles["Clawed Tile Rare Default"],
	[Enum.GuiState.NonInteractable] = tiles["Clawed Tile Rare Default"],
	[Enum.GuiState.Hover] = tiles["Clawed Tile Rare Active"],
	[Enum.GuiState.Press] = tiles["Clawed Tile Rare Active"]
}
local mythical2 = PseudoEnum.Rarity.Mythical
v11[mythical2] = {
	[Enum.GuiState.Idle] = tiles["Clawed Tile Mythical Default"],
	[Enum.GuiState.NonInteractable] = tiles["Clawed Tile Mythical Default"],
	[Enum.GuiState.Hover] = tiles["Clawed Tile Mythical Active"],
	[Enum.GuiState.Press] = tiles["Clawed Tile Mythical Active"]
}
local premium2 = PseudoEnum.Rarity.Premium
v11[premium2] = {
	[Enum.GuiState.Idle] = tiles["Clawed Tile Premium Default"],
	[Enum.GuiState.NonInteractable] = tiles["Clawed Tile Premium Default"],
	[Enum.GuiState.Hover] = tiles["Clawed Tile Premium Active"],
	[Enum.GuiState.Press] = tiles["Clawed Tile Premium Active"]
}
v3[clawed] = v11
local createElement = React.createElement

function coloredOutlineAnimation(p)
	local color = p.Color or CONSTANTS.COLOR.PALETTE.WHITE
	local v18 = 1 - usePeriod(p.OutlineAppearance == PseudoEnum.InventoryOutlineAppearance.Rainbow, 4)
	local count = #v2
	local colorSequenceKeypoints = {}

	for i = 0, count do
		local v19 = (i + count * v18) % count
		local v20 = math.floor(v19) % count + 1
		local v21 = v20 + 1
		local v22 = count < v21 and 1 or v21
		local v23 = v19 - math.floor(v19)
		table.insert(colorSequenceKeypoints, ColorSequenceKeypoint.new(i / count, v2[v20]:Lerp(v2[v22], v23)))
	end

	local color2

	if p.OutlineAppearance == PseudoEnum.InventoryOutlineAppearance.Solid then
		color2 = ColorSequence.new(color)
	else
		color2 = ColorSequence.new(colorSequenceKeypoints)
	end

	return createElement("UIGradient", {
		Color = color2,
		Transparency = nil,
		Rotation = -45
	})
end

return React.forwardRef(function(data, ref)
	local quantity = data.Quantity
	local upgrades = data.Upgrades
	local state, setState = React.useState(Enum.GuiState.Idle)
	local ribbonText

	if data.Variant == "Elevated" and (data.IsPermanent or data.RibbonText) then
		ribbonText = data.RibbonText or "Permanent"
	end

	local tileRarity = data.TileRarity or data.Rarity
	local v18 = React.useMemo(function()
		if tileRarity then
			return Option.map(RarityUtil.matchRarity(tileRarity), function(p2)
				return p2.Color
			end):unwrapOr(CONSTANTS.COLOR.PALETTE.BLACK)
		end

		return CONSTANTS.COLOR.PALETTE.BLACK
	end, { tileRarity })
	local v19 = React.useMemo(function()
		local result = {}

		if not data.Overlays then
			return result
		end

		for _, overlay in data.Overlays do
			local v20 = v[overlay]

			if v20 then
				table.insert(result, v20)
			end
		end

		return result
	end, { data.Overlays })
	local title = data.Title
	local category = data.Category
	local modifiers = data.Modifiers
	local _ = data.DrawContext
	local v20 = "Default"
	local v21 = React.useMemo(function()
		if data.Variant ~= "Elevated" and data.Variant ~= "Display" or v20 ~= "Default" then
			return nil
		end

		if modifiers then
			return { table.concat(modifiers, " "), title }
		end

		local parts = title:split(" ")
		local trySolve

		trySolve = function(p2: number)
			local v22 = true

			for _, part in parts do
				if not (p2 < #part) then
					continue
				end

				v22 = false
				break
			end

			if not v22 then
				return trySolve(p2 + 1)
			end

			local result = {}

			for _, part in parts do
				local v24 = result[#result]

				if v24 == nil or p2 < #v24 + #part + 1 then
					table.insert(result, part)
				else
					result[#result] = v24 .. " " .. part
				end
			end

			return result
		end

		if data.IsTrinket then
			return { title }
		end

		return trySolve(12)
	end, {
		title,
		data.Visible,
		v20,
		modifiers,
		data.IsTrinket
	})
	local v22 = v21 and #v21 or 1
	local isTrinket = data.IsTrinket or modifiers ~= nil
	local children = nil
	local v23 = React.useMemo(function()
		local v24 = isTrinket and 1.4285714285714286 or 1

		if not v21 or #v21 == 1 then
			return v24 * 1
		end

		local v25 = 0

		for i = 1, v22 do
			local v26 = v21[i]

			if v26 and v25 < #v26 then
				v25 = #v26
			end
		end

		return (math.clamp(v24 * (12 / math.max(v25, 1)), 0.3, 1))
	end, { v21, isTrinket }) * ((v22 > 1 and 1.3 or 1) * 0.3) / v22

	if v21 then
		children = children or {}
		assert(children, "lines should be defined here")

		for k, text in v21 do
			children[`Line-{k}`] = createElement("TextLabel", {
				Size = UDim2.fromScale(isTrinket and 1 or 0.7, v23),
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.fromScale(1, 1 - (v22 - k) * v23),
				Text = text,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextStrokeTransparency = CONSTANTS.ALPHA.OPAQUE,
				LineHeight = 5,
				FontFace = sourceSans,
				TextScaled = true,
				TextWrapped = false,
				TextTruncate = Enum.TextTruncate.None,
				TextXAlignment = Enum.TextXAlignment.Right,
				TextYAlignment = Enum.TextYAlignment.Bottom
			}, {
				UITextSizeConstraint = createElement("UITextSizeConstraint", {
					MinTextSize = 2,
					MaxTextSize = 32
				})
			})
		end
	end

	if quantity and quantity <= 1 then
		quantity = nil
	end

	local v24 = React.useMemo(function()
		local v25 = tileRarity or "Common"
		local press

		if data.IsSelected then
			press = Enum.GuiState.Press
		else
			press = state
		end

		local tileAppearance = data.TileAppearance or PseudoEnum.InventoryTileAppearance.Elevated
		local v26 = v3[tileAppearance] or v3[PseudoEnum.InventoryTileAppearance.Elevated]
		local v27 = v26[v25] or v26[PseudoEnum.Rarity.Common]
		local selected = v27[press] or v27[Enum.GuiState.Idle]
		assert(selected, (`bad state-sprite: {press}, {tileAppearance}, {v25}`))
		return selected
	end, {
		tileRarity,
		data.TileAppearance,
		state,
		data.IsSelected
	})
	local v25 = ribbonText and 0.115 or 0
	local v26 = React.useMemo(function()
		local icon = data.Icon
		local iconBorderThickness = data.IconBorderThickness

		if not icon then
			return broken_image
		end

		if iconBorderThickness then
			return {
				Image = icon.Image,
				ImageRectOffset = (icon.ImageRectOffset or Vector2.zero) + Vector2.one * iconBorderThickness,
				ImageRectSize = (icon.ImageRectSize or Vector2.zero) - Vector2.one * 2 * iconBorderThickness
			}
		end

		return icon
	end, { data.Icon, data.IconBorderThickness })
	local outlineIcon = data.OutlineIcon
	local cornerIcon = data.CornerIcon
	local categoryIcon = data.CategoryIcon
	local uDim

	if data.Variant == "Elevated" or not data.CornerRadius then
		uDim = UDim.new(0.08, 0)
	else
		uDim = data.CornerRadius
	end

	local v27 = {}

	for k, v28 in v19 do
		local formatted = `OverlayEffect-{k}`
		local image

		if typeof(v28.Image) == "string" then
			image = v28.Image
		end

		local v31 = {
			Active = false,
			Image = image,
			ImageRectOffset = v28.ImageRectOffset,
			ImageRectSize = v28.ImageRectSize,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ZIndex = 3 + k / (#v19 + 1),
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5)
		}
		local cornerRadius

		if uDim.Offset > 0 or uDim.Scale > 0 then
			cornerRadius = createElement("UICorner", {
				CornerRadius = uDim
			})
		end

		v27[formatted] = createElement("ImageLabel", v31, {
			CornerRadius = cornerRadius
		})
	end

	local v28

	if data.IsEquipped then
		v28 = badgeEquipped
	elseif data.IsFavorited then
		if tileRarity == "Premium" then
			v28 = silverBadgeFavorited
		else
			v28 = goldBadgeFavorited
		end
	elseif data.WasRecentlyReceived then
		v28 = badgeNew
	end

	local v30 = data.ForceAsLabel and "ImageLabel" or "ImageButton"
	local v31 = {
		Size = data.Size,
		Position = data.Position,
		AnchorPoint = data.AnchorPoint,
		SelectionBehaviorLeft = data.SelectionBehaviorLeft,
		SelectionBehaviorRight = data.SelectionBehaviorRight,
		SelectionBehaviorUp = data.SelectionBehaviorUp,
		SelectionBehaviorDown = data.SelectionBehaviorDown,
		SelectionGroup = data.SelectionGroup,
		SizeConstraint = data.SizeConstraint,
		Selectable = data.Selectable,
		AutomaticSize = data.AutomaticSize,
		LayoutOrder = data.LayoutOrder,
		ZIndex = data.ZIndex,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		ref = ref,
		[data.ForceAsLabel and React.Event.DragBegin or React.Event.Activated] = function(...)
			if data[React.Event.Activated] then
				data[React.Event.Activated](...)
			end
		end
	}
	local selectionGained = React.Event.SelectionGained
	local v32

	if not data.ForceAsLabel then
		v32 = data[React.Event.SelectionGained]
	end

	v31[selectionGained] = v32
	local selectionLost = React.Event.SelectionLost
	local v33

	if not data.ForceAsLabel then
		v33 = data[React.Event.SelectionLost]
	end

	v31[selectionLost] = v33

	v31[React.Change.GuiState] = function(p2)
		if p2.GuiState ~= state then
			setState(p2.GuiState)
		end
	end

	local v37 = {
		Active = false,
		ZIndex = CONSTANTS.LAYER.BEHIND,
		BackgroundTransparency = data.Variant == "Elevated" and 1 or 0,
		Image = v24.Image,
		ImageRectOffset = v24.ImageRectOffset,
		ImageRectSize = v24.ImageRectSize,
		ImageTransparency = data.Variant == "Elevated" and 0 or 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = 0,
		Position = 0
	}
	local size

	if data.Variant == "Elevated" then
		size = UDim2.fromScale(1.125, 1.075)
	else
		size = UDim2.fromScale(1, 1)
	end

	v37.Size = size
	v37.Position = UDim2.fromScale(0.5, 0.51)
	local gradient

	if data.Variant ~= "Elevated" then
		gradient = createElement("UIGradient", {
			Rotation = -90,
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, v18),
				ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 0, 0.1))
			})
		})
	end

	local uIStroke

	if data.Variant ~= "Elevated" then
		local color

		if data.IsSelected then
			color = CONSTANTS.COLOR.PALETTE.WHITE
		else
			color = CONSTANTS.COLOR.PALETTE.BLACK
		end

		uIStroke = createElement("UIStroke", {
			Color = color,
			Thickness = data.IsSelected and 2 or 0,
			Transparency = state == Enum.GuiState.Idle and 0 or 0.1
		})
	end

	local v34 = {
		Tile = createElement("ImageLabel", v37, {
			Gradient = gradient,
			UIStroke = uIStroke,
			UICorner = createElement("UICorner", {
				CornerRadius = uDim
			})
		}),
		UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = data.Variant == "Elevated" and 0.975 or 1,
			DominantAxis = Enum.DominantAxis.Height,
			AspectType = Enum.AspectType.FitWithinMaxSize
		}),
		OverlayEffect = 0,
		AboveText = 0,
		SelectionOutline = 0,
		RedBanner = 0,
		PurchaseOverlay = 0,
		Details = 0,
		Icon = 0,
		OutlineIcon = 0,
		CornerIcon = 0,
		Count = 0
	}
	local overlayEffect

	if not (data.Variant == "Elevated" or not (#v19 > 0)) then
		overlayEffect = createElement(React.Fragment, {}, v27)
	end

	v34.OverlayEffect = overlayEffect
	local v45 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		ZIndex = 12,
		Size = UDim2.fromScale(1, 1)
	}
	local upperRightCornerBadge

	if v28 ~= nil then
		local v50 = {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Active = false,
			ZIndex = 12,
			ImageTransparency = CONSTANTS.ALPHA.OPAQUE,
			Image = 0,
			ImageRectOffset = 0,
			ImageRectSize = 0,
			Position = 0,
			Size = 0,
			Visible = true
		}
		local image

		if typeof(v28.Image) == "string" then
			image = v28.Image
		end

		v50.Image = image
		v50.ImageRectOffset = v28.ImageRectOffset
		v50.ImageRectSize = v28.ImageRectSize
		v50.Position = UDim2.fromScale(1, 0)
		v50.Size = UDim2.fromScale(0.27, 0.27)
		upperRightCornerBadge = createElement("ImageLabel", v50, {
			UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
				AspectRatio = 1,
				DominantAxis = Enum.DominantAxis.Width,
				AspectType = Enum.AspectType.ScaleWithParentSize
			})
		})
	end

	v34.AboveText = createElement("Frame", v45, {
		UpperRightCornerBadge = upperRightCornerBadge
	})
	local selectionOutline

	if v20 == "Default" and data.Variant == "Elevated" then
		local v51 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.49),
			Size = UDim2.fromScale(0.95, 0.92),
			Active = false,
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			ZIndex = CONSTANTS.LAYER.RAISED,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
		}
		local overlayEffect2

		if #v19 > 0 then
			overlayEffect2 = createElement(React.Fragment, {}, v27)
		end

		local v52 = {
			OverlayEffect = overlayEffect2,
			UICorner = createElement("UICorner", {
				CornerRadius = uDim
			}),
			UIStroke = 0
		}
		local uIStroke2

		if data.IsSelected then
			local color

			if data.IsSelected then
				color = data.SelectionBorderColor or CONSTANTS.COLOR.PALETTE.WHITE
			else
				color = CONSTANTS.COLOR.PALETTE.BLACK
			end

			uIStroke2 = createElement("UIStroke", {
				Color = color,
				Thickness = not data.IsSelected and 0 or math.max(
					2,
					not data.Size and 0 or math.ceil(data.Size.X.Offset * 0.025)
				),
				Transparency = state == Enum.GuiState.Idle and 0 or 0.1
			})
		end

		v52.UIStroke = uIStroke2
		selectionOutline = createElement("Frame", v51, v52)
	end

	v34.SelectionOutline = selectionOutline
	local redBanner2

	if ribbonText then
		local v52 = {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			ZIndex = 12,
			Image = 0,
			ImageRectOffset = 0,
			ImageRectSize = 0,
			Position = 0,
			Size = 0,
			SizeConstraint = 0,
			Visible = true
		}
		local image

		if typeof(redBanner.Image) == "string" then
			image = redBanner.Image
		end

		v52.Image = image
		v52.ImageRectOffset = redBanner.ImageRectOffset
		v52.ImageRectSize = redBanner.ImageRectSize
		v52.Position = UDim2.fromScale(-0.025, 0.033)
		v52.Size = UDim2.fromScale(0.593, 0.147)
		v52.SizeConstraint = Enum.SizeConstraint.RelativeYY
		redBanner2 = createElement("ImageLabel", v52, {
			BannerText = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = sourceSans,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.9, 0.825),
				Text = ribbonText,
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true,
				TextSize = 14,
				TextStrokeTransparency = CONSTANTS.ALPHA.MID,
				TextWrapped = true
			}, {
				TextLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(1, 1),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = sourceSans,
					Position = UDim2.fromScale(0.995, 0.925),
					Size = UDim2.fromScale(1, 1),
					Text = ribbonText,
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					TextSize = 14,
					TextStrokeTransparency = CONSTANTS.ALPHA.MID,
					TextWrapped = true,
					ZIndex = CONSTANTS.LAYER.OVERLAY
				})
			})
		})
	end

	v34.RedBanner = redBanner2
	local purchaseOverlay

	if data.IsPurchase == true then
		purchaseOverlay = createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			BackgroundTransparency = 0.2,
			ZIndex = CONSTANTS.LAYER.OVERLAY
		}, {
			UIGradient = createElement("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.7, 1),
					NumberSequenceKeypoint.new(0.9, 0.2),
					NumberSequenceKeypoint.new(1, 0)
				}),
				Rotation = 45
			}),
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
			})
		})
	end

	v34.PurchaseOverlay = purchaseOverlay
	local v53 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.85, 0.85),
		Active = false,
		ZIndex = 10
	}
	local categoryIcon2

	if categoryIcon ~= nil then
		local v58 = {
			ZIndex = 8,
			Size = UDim2.fromScale(0.1295, 0.1295),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0, v25 + 0.0925),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
		}
		local v62 = {
			ZIndex = 8,
			Size = UDim2.fromScale(1.5, 1.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ScaleType = Enum.ScaleType.Fit,
			Image = 0,
			ImageRectOffset = 0,
			ImageRectSize = 0
		}
		local image

		if typeof(categoryIcon.Image) == "string" then
			image = categoryIcon.Image
		end

		v62.Image = image
		v62.ImageRectOffset = categoryIcon.ImageRectOffset
		v62.ImageRectSize = categoryIcon.ImageRectSize
		categoryIcon2 = createElement("Frame", v58, {
			Icon = createElement("ImageLabel", v62, {})
		})
	end

	local category2

	if data.Variant == "Elevated" and (category ~= nil or quantity) and v20 == "Default" and category ~= nil then
		category2 = createElement("TextLabel", {
			Size = UDim2.fromScale(1 - (categoryIcon and 0.1895 or 0), 0.185),
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.fromScale(categoryIcon and 0.1895 or 0, v25),
			Text = category,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextStrokeTransparency = CONSTANTS.ALPHA.OPAQUE,
			FontFace = sourceSans,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Center
		})
	end

	local upgradeLabel

	if data.Variant == "Elevated" and upgrades ~= nil and not (upgrades <= 0) then
		upgradeLabel = createElement("TextLabel", {
			Size = UDim2.fromScale(1, 0.185),
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.fromScale(0, v25 + 0.185),
			Text = string.rep("★", upgrades),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextStrokeTransparency = CONSTANTS.ALPHA.OPAQUE,
			LineHeight = 0,
			FontFace = sourceSans,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top
		})
	end

	local displayName

	if children then
		displayName = createElement(React.Fragment, {}, children)
	end

	v34.Details = createElement("Frame", v53, {
		CategoryIcon = categoryIcon2,
		Category = category2,
		UpgradeLabel = upgradeLabel,
		DisplayName = displayName
	})
	local v61 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.85, 0.85),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		ZIndex = CONSTANTS.LAYER.BASE,
		Active = false,
		ImageTransparency = CONSTANTS.ALPHA.OPAQUE,
		ScaleType = Enum.ScaleType.Fit,
		Image = 0,
		ImageColor3 = 0,
		ImageRectOffset = 0,
		ImageRectSize = 0
	}
	local image2

	if typeof(v26.Image) == "string" then
		image2 = v26.Image
	end

	v61.Image = image2
	v61.ImageColor3 = data.IconColor or CONSTANTS.COLOR.PALETTE.WHITE
	v61.ImageRectOffset = v26.ImageRectOffset
	v61.ImageRectSize = v26.ImageRectSize
	local uIGradient

	if data.IsPurchase == true then
		uIGradient = createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.PALETTE.BLACK),
				ColorSequenceKeypoint.new(0.3, CONSTANTS.COLOR.PALETTE.BLACK),
				ColorSequenceKeypoint.new(0.5, CONSTANTS.COLOR.PALETTE.BLACK:Lerp(CONSTANTS.COLOR.PALETTE.WHITE, 0.2)),
				ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.PALETTE.WHITE)
			}),
			Rotation = 45
		})
	end

	local purchaseIcon

	if data.IsPurchase == true then
		purchaseIcon = createElement("ImageLabel", {
			Size = UDim2.fromScale(0.4, 0.4),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ImageColor3 = Color3.fromHex("E9CF10"):Lerp(CONSTANTS.COLOR.PALETTE.WHITE, 0.9),
			ImageTransparency = 0.2,
			Image = plus.Image,
			ImageRectOffset = plus.ImageRectOffset,
			ImageRectSize = plus.ImageRectSize,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
		})
	end

	v34.Icon = createElement("ImageLabel", v61, {
		UIGradient = uIGradient,
		PurchaseIcon = purchaseIcon
	})
	local outlineIcon2

	if outlineIcon then
		local v69 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.85, 0.85),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ZIndex = CONSTANTS.LAYER.BEHIND,
			Active = false,
			ImageTransparency = CONSTANTS.ALPHA.OPAQUE,
			ScaleType = Enum.ScaleType.Fit,
			ImageColor3 = 0,
			Image = 0,
			ImageRectOffset = 0,
			ImageRectSize = 0
		}
		local imageColor

		if data.OutlineIconColor or data.OutlineAppearance == PseudoEnum.InventoryOutlineAppearance.Rainbow then
			imageColor = data.OutlineIconColor or CONSTANTS.COLOR.PALETTE.WHITE
		else
			imageColor = CONSTANTS.COLOR.PALETTE.BLACK
		end

		v69.ImageColor3 = imageColor
		local image

		if typeof(outlineIcon.Image) == "string" then
			image = outlineIcon.Image
		end

		v69.Image = image
		v69.ImageRectOffset = outlineIcon.ImageRectOffset
		v69.ImageRectSize = outlineIcon.ImageRectSize
		local uIGradient2

		if not (data.OutlineAppearance == nil or data.OutlineAppearance == PseudoEnum.InventoryOutlineAppearance.Solid) then
			uIGradient2 = createElement(coloredOutlineAnimation, {
				Color = data.OutlineIconColor,
				OutlineAppearance = data.OutlineAppearance or PseudoEnum.InventoryOutlineAppearance.Solid
			})
		end

		outlineIcon2 = createElement("ImageLabel", v69, {
			UIGradient = uIGradient2
		})
	end

	v34.OutlineIcon = outlineIcon2
	local cornerIcon2

	if cornerIcon ~= nil then
		local v70 = {
			ZIndex = 8,
			AnchorPoint = Vector2.new(0, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.fromScale(0.33, 0.33),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.075, 0.925),
			ScaleType = Enum.ScaleType.Fit,
			Image = 0,
			ImageRectOffset = 0,
			ImageRectSize = 0
		}
		local image

		if typeof(cornerIcon.Image) == "string" then
			image = cornerIcon.Image
		end

		v70.Image = image
		v70.ImageRectOffset = cornerIcon.ImageRectOffset
		v70.ImageRectSize = cornerIcon.ImageRectSize
		cornerIcon2 = createElement("ImageLabel", v70)
	end

	v34.CornerIcon = cornerIcon2
	local count

	if quantity then
		local v71 = {
			AnchorPoint = Vector2.new(0, 1),
			ZIndex = 6,
			Active = false,
			Position = UDim2.fromScale(0, 0.95),
			Size = UDim2.fromScale(1, data.Variant == "Elevated" and 0.2 or 0.25),
			BackgroundTransparency = CONSTANTS.ALPHA.OPAQUE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK
		}
		local cornerRadius

		if uDim.Offset > 0 or uDim.Scale > 0 then
			cornerRadius = createElement("UICorner", {
				CornerRadius = uDim
			})
		end

		count = createElement("Frame", v71, {
			CornerRadius = cornerRadius,
			Gradient = createElement("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0.1),
					NumberSequenceKeypoint.new((data.Variant == "Elevated" and 0 or 0.1) + 0.2, 0.5),
					NumberSequenceKeypoint.new((data.Variant == "Elevated" and 0 or 0.1) + 0.3, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			Label = createElement("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0.05, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Text = FormatUtil.commaInteger(quantity),
				TextXAlignment = Enum.TextXAlignment.Left,
				FontFace = sourceSans,
				TextScaled = true,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextYAlignment = Enum.TextYAlignment.Center
			})
		})
	end

	v34.Count = count
	return createElement(v30, v31, v34)
end)