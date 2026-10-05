local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
require(ReplicatedStorage.React.Components.Inventory.Types)
local useMatch = require(ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local Tile = require(ReplicatedStorage.React.Components.Tile)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)

local function fn() end

local createElement = React.createElement
return function(props)
	local v2

	if props.Tile then
		v2 = props.Tile.ItemId or nil
	end

	local v3 = useMatch(v2)
	local v6 = {
		Active = props.OnClick ~= nil,
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BackgroundTransparency = CONSTANTS.ALPHA.HALF,
		Image = "",
		ImageTransparency = CONSTANTS.ALPHA.INVISIBLE,
		LayoutOrder = -1,
		Position = UDim2.fromScale(0.204002, 0),
		Selectable = props.OnClick ~= nil,
		Size = UDim2.fromScale(1, 1),
		AutoButtonColor = props.OnClick ~= nil
	}
	local activated = React.Event.Activated
	local v7

	if props.OnClick and props.Tile == nil then
		v7 = props.OnClick
	end

	v6[activated] = v7
	local children = {
		uIAspectRatioConstraint = createElement("UIAspectRatioConstraint"),
		assetTile = 0,
		uICorner = 0,
		uIStroke = 0,
		close = 0,
		plusIcon = 0,
		emptyStateIcon = 0
	}
	local assetTile

	if props.Tile ~= nil then
		local onClicksByActivated = {
			Size = UDim2.fromScale(1, 1),
			Active = false,
			IsSelected = false,
			Variant = "Display",
			DrawContext = "Default",
			[React.Event.Activated] = props.OnClick,
			Quantity = props.Quantity
		}
		local rarity

		if v3 then
			rarity = v3.Quality.Rarity or nil
		end

		onClicksByActivated.Rarity = rarity
		onClicksByActivated.Title = not v3 and "" or v3.Display.Name or v3.Index.StorageKey or ""
		onClicksByActivated.Icon = v3 and v3.Display.Sprite or nil
		assetTile = createElement(Tile, onClicksByActivated)
	end

	children.assetTile = assetTile
	children.uICorner = createElement("UICorner", {
		CornerRadius = UDim.new(0.08, 0)
	})
	children.uIStroke = createElement("UIStroke", {
		Color = CONSTANTS.COLOR.DIVIDER.BORDER,
		Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
	})
	children.close = createElement("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = CONSTANTS.COLOR.DANGER.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.LIGHT,
		FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
		LayoutOrder = -999,
		Position = UDim2.fromScale(1.05, -0.05),
		Size = UDim2.fromScale(0.4, 0.4),
		Text = "",
		TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		TextScaled = true,
		TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		ZIndex = 50,
		Visible = props.Tile ~= nil and props.OnCloseClick ~= nil,
		[React.Event.MouseButton1Click] = props.OnCloseClick or fn
	}, {
		uICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
		}),
		uIStroke = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = CONSTANTS.COLOR.DANGER.BORDER
		}),
		uIAspectRatioConstraint = createElement("UIAspectRatioConstraint"),
		icon = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://127503254560275",
			ImageRectSize = Vector2.new(100, 100),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ZIndex = 51
		}),
		uISizeConstraint = createElement("UISizeConstraint", {
			MaxSize = Vector2.new(30, 30)
		})
	})
	local plusIcon

	if props.Variant == "Add" then
		plusIcon = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.7, 0.7),
			Text = "+",
			TextColor3 = CONSTANTS.COLOR.DIVIDER.BORDER,
			TextScaled = true
		})
	end

	children.plusIcon = plusIcon
	local emptyStateIcon

	if props.Variant == "Empty" then
		emptyStateIcon = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://77080808671324",
			ImageColor3 = CONSTANTS.COLOR.DIVIDER.BORDER,
			Position = UDim2.fromScale(0.5, 0.509),
			Size = UDim2.fromScale(0.336, 0.35)
		}, {
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
				AspectRatio = 0.96
			})
		})
	end

	children.emptyStateIcon = emptyStateIcon
	return createElement("ImageButton", v6, children)
end