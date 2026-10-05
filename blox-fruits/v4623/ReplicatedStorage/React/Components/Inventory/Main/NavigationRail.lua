local React = require(game.ReplicatedStorage.Packages.React)
local PseudoEnum = require(game.ReplicatedStorage.PseudoEnum)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.ItemConfig)
local Badge = require(game.ReplicatedStorage.React.Components.Badge)
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
local useCumulativeNewCount = require(game.ReplicatedStorage.React.Hooks.Item.useCumulativeNewCount)
local useCurrentGroup = require(game.ReplicatedStorage.React.Hooks.Inventory.useCurrentGroup)
local useConfig = require(game.ReplicatedStorage.React.Hooks.Inventory.useConfig)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	{
		TEXT = "Backpack",
		GROUP = PseudoEnum.InventoryItemGroup.Backpack,
		ICON = {
			Image = "rbxassetid://106859797566502",
			ImageRectOffset = Vector2.new(0, 0),
			ImageRectSize = Vector2.new(0, 0)
		}
	},
	{
		TEXT = "Treasure",
		GROUP = PseudoEnum.InventoryItemGroup.Treasure,
		ICON = Spritesheets.MAP["Dragon-Dragon1"]
	},
	{
		TEXT = "Wardrobe",
		GROUP = PseudoEnum.InventoryItemGroup.Wardrobe,
		ICON = {
			Image = "rbxassetid://107828746772425",
			ImageRectOffset = Vector2.new(0, 0),
			ImageRectSize = Vector2.new(0, 0)
		}
	},
	{
		TEXT = "Stash",
		GROUP = PseudoEnum.InventoryItemGroup.Stash,
		ICON = {
			Image = "rbxassetid://103345486604345",
			ImageRectOffset = Vector2.new(0, 0),
			ImageRectSize = Vector2.new(0, 0)
		}
	},
	{
		TEXT = "Build",
		GROUP = PseudoEnum.InventoryItemGroup.Build,
		ICON = {
			Image = "rbxassetid://130577658545009",
			ImageRectOffset = Vector2.new(0, 0),
			ImageRectSize = Vector2.new(0, 0)
		}
	}
}
local createElement = React.createElement

function tab(props)
	local state, setState = React.useState(Enum.GuiState.Idle)
	local v2 = state == Enum.GuiState.Hover or state == Enum.GuiState.Press
	local v3 = useConfig()
	local color

	if v2 then
		color = Color3.fromHex("#FFDF5E")
	else
		color = CONSTANTS.COLOR.PRIMARY.BACKGROUND
	end

	local color2

	if v2 then
		color2 = Color3.fromHex("#FFF696")
	else
		color2 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT
	end

	local OPAQUE

	if props.IsSelected then
		OPAQUE = CONSTANTS.ALPHA.OPAQUE
	else
		OPAQUE = CONSTANTS.ALPHA.INVISIBLE
	end

	local v4 = useCumulativeNewCount(props.StaticNewCountFilter)
	local v7 = {
		[React.Tag] = props.Tag,
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutoButtonColor = false,
		BackgroundColor3 = color,
		BackgroundTransparency = OPAQUE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = props.Position,
		Selectable = props.Selectable,
		ZIndex = props.ZIndex,
		Size = props.Size,
		[React.Event.Activated] = function()
			props.OnClick()
		end,
		[React.Change.GuiState] = function(p)
			if p.GuiState ~= state then
				setState(p.GuiState)
			end
		end
	}
	local v8 = {
		Corner = createElement("UICorner", {
			CornerRadius = UDim.new(0.1, 0)
		}),
		Highlight = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = color2,
			BackgroundTransparency = OPAQUE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(1, 0.5)
		}, {
			Corner = createElement("UICorner", {
				CornerRadius = UDim.new(0.2, 0)
			}),
			Highlight = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = color2,
				BackgroundTransparency = OPAQUE,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.5, 1),
				Size = UDim2.fromScale(1, 0.5)
			})
		}),
		Badge = v4 > 0 and v3.NewCountEnabled and createElement(Badge, {
			Text = `{v4 > 99 and "99" or v4}x`,
			Variant = "Red",
			Position = UDim2.fromScale(1, 0),
			AnchorPoint = Vector2.new(0.65, 0.35),
			Size = UDim2.fromScale(0.35, 0.35),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			ZIndex = 10
		}),
		Icon = 0,
		Text = 0
	}
	local v12 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		AutomaticSize = Enum.AutomaticSize.XY,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Image = 0,
		ImageContent = 0,
		ImageRectOffset = 0,
		ImageRectSize = 0,
		Position = 0,
		ScaleType = 0,
		Size = 0,
		ZIndex = 0
	}
	local image

	if typeof(props.Icon.Image) == "string" then
		image = props.Icon.Image
	end

	v12.Image = image
	local imageContent

	if typeof(props.Icon.Image) ~= "string" then
		imageContent = props.Icon.Image
	end

	v12.ImageContent = imageContent
	v12.ImageRectOffset = props.Icon.ImageRectOffset
	v12.ImageRectSize = props.Icon.ImageRectSize
	v12.Position = UDim2.fromScale(0.5, 0.4)
	v12.ScaleType = Enum.ScaleType.Fit
	v12.Size = UDim2.fromScale(0.8, 0.8)
	v12.ZIndex = CONSTANTS.LAYER.RAISED
	v8.Icon = createElement("ImageLabel", v12)
	v8.Text = createElement("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.9),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.DISPLAY,
		Position = UDim2.fromScale(0.5, 1),
		Size = UDim2.fromScale(1, 0.3),
		Text = props.Text,
		TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true,
		ZIndex = CONSTANTS.LAYER.RAISED_HIGH
	}, {
		Padding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0.2, 2)
		}),
		TextStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		})
	})
	return createElement("ImageButton", v7, v8)
end

return function(p)
	local v2 = useConfig()
	local selectable

	if useDrawContext() == "Default" then
		selectable = p.Selectable ~= false
	else
		selectable = false
	end

	local v4, v5 = useCurrentGroup()
	local count = 0

	for _, v6 in v do
		if v2.Layout[v6.GROUP] ~= nil then
			count += 1
		end
	end

	local count2 = 0
	local v6 = {}

	for k, v7 in v do
		if v2.Layout[v7.GROUP] == nil then
			continue
		end

		count2 += 1
		local formatted = `Category{k}`
		local tab2 = tab
		local v9 = v7
		local v10 = {
			Icon = v7.ICON,
			IsSelected = v4 == v7.GROUP,
			OnClick = function()
				v5(v9.GROUP)
			end,
			ZIndex = k,
			StaticNewCountFilter = {
				Inventory = {
					Groups = v7.GROUP,
					Tags = {
						Operation = "NEQ",
						Value = PseudoEnum.InventoryItemTag.HasInvisibleTile
					}
				}
			},
			Position = UDim2.fromScale(0.5, (count2 - 0.5) / count),
			Selectable = selectable,
			Size = UDim2.fromScale(1, 0.94 / count),
			Tag = 0,
			Text = 0
		}
		local tag

		if v4 == v7.GROUP then
			tag = p.SelectedTabTag
		end

		v10.Tag = tag
		v10.Text = v7.TEXT
		v6[formatted] = createElement(tab2, v10)
	end

	return createElement("Frame", RobloxTypes.mergeFrame({
		BackgroundColor3 = Color3.fromHex("#404040"),
		BackgroundTransparency = 0.06,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE
	}, p), {
		Outline = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.HAIRLINE
		}),
		Corner = createElement("UICorner", {
			CornerRadius = UDim.new(0.1, 0)
		}),
		Padding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 1),
			PaddingLeft = UDim.new(0, 1),
			PaddingRight = UDim.new(0, 1),
			PaddingTop = UDim.new(0, 1)
		}),
		Tabs = createElement(React.Fragment, {}, v6)
	})
end