local React = require(game.ReplicatedStorage.Packages.React)
local OutlinedMaterialIconsHD = require(game.ReplicatedStorage.Packages.OutlinedMaterialIconsHD)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
require(game.ReplicatedStorage.React.Components.Inventory.Main.TileGrid.FastTile)
local BuildTile = require(script.BuildTile)
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
local useSelection = require(game.ReplicatedStorage.React.Hooks.Item.useSelection)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local createElement = React.createElement
return React.forwardRef(function(props, ref)
	local badgeLock = Spritesheets.MAP["Badge Lock"] or OutlinedMaterialIconsHD.lock
	local drawContext = useDrawContext()
	local selectable

	if drawContext == "Default" then
		selectable = props.Selectable ~= false
	else
		selectable = false
	end

	local info = React.useMemo(function()
		if props.ItemId == nil then
			return nil
		end

		return {
			ItemId = props.ItemId,
			NetworkedUID = props.NetworkedUID
		}
	end, { props.ItemId, props.NetworkedUID })
	local v4, v5, v6 = useSelection()
	local isSelected

	if v4 == props.ItemId then
		isSelected = v5 == props.NetworkedUID
	else
		isSelected = false
	end

	local mergeGuiObject = RobloxTypes.mergeGuiObject({
		ref = ref,
		BackgroundTransparency = 1
	}, props)
	local uIStroke

	if not props.ItemId then
		uIStroke = createElement("UIStroke", {
			Color = Color3.fromRGB(150, 150, 150),
			Transparency = 0.8,
			Thickness = 2
		})
	end

	local uICorner

	if not props.ItemId then
		uICorner = createElement("UICorner", {
			CornerRadius = props.CornerRadius or UDim.new(0.1, 0)
		})
	end

	local v10 = {
		UIStroke = uIStroke,
		UICorner = uICorner,
		UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 1,
			DominantAxis = Enum.DominantAxis.Height,
			AspectType = Enum.AspectType.FitWithinMaxSize
		}),
		Tile = 0
	}
	local tile

	if info then
		tile = createElement(BuildTile, {
			Size = UDim2.fromScale(1, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			DrawContext = drawContext,
			SelectionBehaviorLeft = props.SelectionBehaviorLeft,
			SelectionBehaviorRight = props.SelectionBehaviorRight,
			SelectionBehaviorUp = props.SelectionBehaviorUp,
			SelectionBehaviorDown = props.SelectionBehaviorDown,
			SelectionGroup = props.SelectionGroup,
			Info = info,
			[React.Event.Activated] = function()
				if isSelected then
					v6(nil, nil)
				else
					v6(props.ItemId, props.NetworkedUID)
				end
			end,
			Selectable = selectable,
			IsSelected = isSelected,
			CornerRadius = props.CornerRadius,
			Variant = props.Variant
		})
	else
		local v16 = {
			ImageTransparency = 1,
			AutoButtonColor = props.OnEmptySelect ~= nil,
			Selectable = selectable,
			SelectionBehaviorLeft = props.SelectionBehaviorLeft,
			SelectionBehaviorRight = props.SelectionBehaviorRight,
			SelectionBehaviorUp = props.SelectionBehaviorUp,
			SelectionBehaviorDown = props.SelectionBehaviorDown,
			SelectionGroup = props.SelectionGroup,
			[React.Event.Activated] = props.OnEmptySelect and function()
				props.OnEmptySelect()
			end or nil,
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			Size = UDim2.fromScale(1, 1)
		}
		local v17 = {
			UIPadding = createElement("UIPadding", {
				PaddingTop = UDim.new(0.05, 0),
				PaddingBottom = UDim.new(0.05, 0),
				PaddingLeft = UDim.new(0.09, 0),
				PaddingRight = UDim.new(0.09, 0)
			}),
			CategoryLabel = 0,
			Icon = 0,
			UICorner = 0
		}
		local categoryLabel

		if props.CategoryLabelOnNull then
			categoryLabel = createElement("TextLabel", {
				BackgroundTransparency = 1,
				FontFace = Font.fromEnum(Enum.Font.SourceSansBold),
				Position = UDim2.fromScale(0, 0),
				Size = UDim2.fromScale(0.6, 0.3),
				Text = FormatUtil.italic(props.CategoryLabelOnNull),
				TextTransparency = 0.2,
				RichText = true,
				TextColor3 = Color3.fromRGB(150, 150, 150),
				TextScaled = true,
				TextWrap = true,
				TextStrokeTransparency = 0.6
			})
		end

		v17.CategoryLabel = categoryLabel
		local v21 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Image = 0,
			ImageRectOffset = 0,
			ImageRectSize = 0,
			ImageTransparency = 0.8,
			ImageColor3 = 0,
			Position = 0,
			ScaleType = 0,
			Size = 0
		}
		local image

		if type(badgeLock.Image) == "string" then
			image = badgeLock.Image
		end

		v21.Image = image
		v21.ImageRectOffset = badgeLock.ImageRectOffset
		v21.ImageRectSize = badgeLock.ImageRectSize
		v21.ImageColor3 = Color3.fromRGB(150, 150, 150)
		v21.Position = UDim2.fromScale(0.5, 0.5)
		v21.ScaleType = Enum.ScaleType.Fit
		v21.Size = UDim2.fromScale(0.6, 0.6)
		v17.Icon = createElement("ImageLabel", v21)
		v17.UICorner = createElement("UICorner", {
			CornerRadius = props.CornerRadius or UDim.new(0.1, 0)
		})
		tile = createElement("ImageButton", v16, v17)
	end

	v10.Tile = tile
	return createElement("Frame", mergeGuiObject, v10)
end)