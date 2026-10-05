local React = require(game.ReplicatedStorage.Packages.React)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Skin = require(game.ReplicatedStorage.Definitions.Skin)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local Recipe = require(script.Recipe)
local useSelection = require(game.ReplicatedStorage.React.Hooks.Item.useSelection)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local v, _, _ = useSelection()
	local definition

	if v then
		definition = Skin.Definition.Recipe.match(v):asNullable()
	end

	local v3

	if v then
		v3 = ItemConfig.match(v):asNullable()
	else
		v3 = nil
	end

	local color = React.useMemo(function()
		return RarityUtil.matchRarity(v3 and v3.Quality.Rarity or "Common"):unwrap().Color
	end, { v3 and v3.Quality.Rarity })
	local fragmentsPrice = v3 and v3.Quality.FragmentsPrice
	local v7 = {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.fromScale(1, 1)
	}
	local recipe

	if definition and v3 and table.find(props.Owned, v3.Index.ItemId) == nil then
		recipe = createElement(Recipe, {
			Definition = definition,
			CraftingInventory = props.CraftingInventory
		})
	else
		local v12 = {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			LayoutOrder = 2,
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromScale(1, 0.7)
		}
		local content

		if v3 then
			local text

			if table.find(props.Owned, v3.Index.ItemId) then
				text = `[Inventory > {FormatUtil.font(not v3.Skin and "Skins" or `{v3.Skin and v3.Skin.Type} Skins`, {
					color = FormatUtil.fromRichColor("Yellow")
				})}] to equip it.`
			else
				text = table.find(props.Unlocked, v3.Index.ItemId) and "" or "This skin is not yet unlocked."
			end

			content = createElement("TextLabel", {
				Text = text,
				RichText = true,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(0.95, 0.45),
				TextScaled = true,
				Position = UDim2.fromScale(0.5, 0.5),
				FontFace = CONSTANTS.FONT.FACE.BODY_BOLD
			})
		end

		recipe = createElement("Frame", v12, {
			Content = content
		})
	end

	local v8 = {
		Recipe = recipe,
		UIListLayout = createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Bottom
		}),
		Top = 0
	}
	local top

	if v3 then
		local v13 = {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(29, 29, 29),
			BorderColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
			LayoutOrder = 1,
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(1, 0.3)
		}
		local v14 = {
			Title = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.BODY_BOLD,
				Position = UDim2.fromScale(0.28, 0.25),
				RichText = true,
				Size = UDim2.fromScale(0.7, 0.5),
				Text = not (v3 and table.find(props.Unlocked, v3.Index.ItemId)) and "???" or `{FormatUtil.clean(v3.Display.Title or v3.Display.Name or v3.Index.StorageKey)}{FormatUtil.font(` [{v3.Quality.Rarity}]`, {
					color = color
				})}`,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextStrokeTransparency = CONSTANTS.ALPHA.HALF,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Bottom,
				ZIndex = 12
			}),
			ImageLabel = 0,
			Fragments = 0
		}
		local v17 = {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = 0,
			BorderColor3 = 0,
			BorderSizePixel = 0,
			ImageColor3 = 0,
			Image = 0,
			ImageRectOffset = 0,
			ImageRectSize = 0,
			Position = 0,
			ScaleType = 0,
			Size = 0,
			ZIndex = 4
		}
		local backgroundColor

		if v3 and not table.find(props.Unlocked, v3.Index.ItemId) then
			backgroundColor = CONSTANTS.COLOR.PRIMARY.BACKGROUND
		else
			backgroundColor = Color3.fromRGB(29, 29, 29)
		end

		v17.BackgroundColor3 = backgroundColor
		v17.BorderColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND
		v17.BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		local imageColor

		if v3 and not table.find(props.Unlocked, v3.Index.ItemId) then
			imageColor = CONSTANTS.COLOR.PALETTE.BLACK
		else
			imageColor = CONSTANTS.COLOR.PALETTE.WHITE
		end

		v17.ImageColor3 = imageColor
		v17.Image = not (v3 and v3.Display.Sprite) and "rbxasset://textures/ui/PlayerList/Block@3x.png" or v3.Display.Sprite.Image or "rbxasset://textures/ui/PlayerList/Block@3x.png"
		v17.ImageRectOffset = v3 and v3.Display.Sprite and v3.Display.Sprite.ImageRectOffset
		v17.ImageRectSize = v3 and v3.Display.Sprite and v3.Display.Sprite.ImageRectSize
		v17.Position = UDim2.new(0, 0, 0.5, 1)
		v17.ScaleType = Enum.ScaleType.Fit
		v17.Size = UDim2.new(0.25, 0, 1, -2)
		v14.ImageLabel = createElement("ImageLabel", v17)
		local fragments

		if not (fragmentsPrice == nil or not v3 or table.find(props.Unlocked, v3.Index.ItemId) == nil) then
			fragments = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				AutoLocalize = false,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.BODY_BOLD,
				Position = UDim2.fromScale(0.28, 0.7),
				RichText = true,
				Size = UDim2.fromScale(0.5, 0.35),
				Text = FormatUtil.font("ƒ" .. FormatUtil.commaInteger(fragmentsPrice), {
					color = Color3.fromRGB(255, 0, 255)
				}),
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextStrokeTransparency = CONSTANTS.ALPHA.OPAQUE,
				TextXAlignment = Enum.TextXAlignment.Left
			})
		end

		v14.Fragments = fragments
		top = createElement("Frame", v13, v14)
	end

	v8.Top = top
	return createElement("Frame", v7, v8)
end