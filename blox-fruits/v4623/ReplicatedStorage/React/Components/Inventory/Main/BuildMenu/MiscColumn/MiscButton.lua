local React = require(game.ReplicatedStorage.Packages.React)
local OutlinedMaterialIconsHD = require(game.ReplicatedStorage.Packages.OutlinedMaterialIconsHD)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local useDrawContext = require(game.ReplicatedStorage.React.Hooks.useDrawContext)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.React.Components.Inventory.Main.BuildMenu.Types)
local createElement = React.createElement
return function(props)
	local state, setState = React.useState(Enum.GuiState.Idle)
	local v = useDrawContext()
	local badgeLock = Spritesheets.MAP["Badge Lock"] or OutlinedMaterialIconsHD.lock
	local icon = props.Icon

	if props.Icon == badgeLock and (state == Enum.GuiState.Hover or state == Enum.GuiState.Press) then
		icon = Spritesheets.MAP["Badge Unlock"] or OutlinedMaterialIconsHD.lock_open
	end

	local imageTransparency = state == Enum.GuiState.Hover and 0.4 or state == Enum.GuiState.Press and 0.2 or 0
	local v3 = React.useMemo(function()
		if props.Level then
			return (` - {FormatUtil.romanNumeral(props.Level)}`)
		end

		return ""
	end, { props.Level })
	local color

	if props.IsUnlocked then
		color = Color3.new(1, 1, 1)
	else
		color = Color3.fromRGB(150, 150, 150)
	end

	local mergeGuiButton = RobloxTypes.mergeGuiButton
	local backgroundColor

	if props.IsUnlocked then
		backgroundColor = props.BackgroundColor3
	else
		backgroundColor = Color3.fromRGB(15, 15, 15)
	end

	local v9 = mergeGuiButton({
		Image = "",
		BackgroundColor3 = backgroundColor,
		BorderTransparency = 1,
		AutoButtonColor = false,
		Selectable = props.OnClick ~= nil and props.Selectable ~= false and v == "Default",
		[React.Change.GuiState] = function(p)
			if p.GuiState ~= state then
				setState(p.GuiState)
			end
		end,
		[React.Event.Activated] = props.OnClick and function()
			props.OnClick()
		end or nil
	}, props)
	local color2

	if props.IsUnlocked and props.BorderColor3 then
		color2 = props.BorderColor3:Lerp(Color3.new(1, 1, 1), imageTransparency)
	else
		color2 = Color3.fromRGB(45, 45, 45)
	end

	local children = {
		UIStroke = createElement("UIStroke", {
			Color = color2,
			Thickness = 1
		}),
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0.5, 0)
		}),
		IconMask = 0,
		TextLabel = 0
	}
	local v16 = {
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(
			0.7 + imageTransparency * 0.1 * (props.IsUnlocked and 1 or 0),
			0.7 + imageTransparency * 0.1 * (props.IsUnlocked and 1 or 0)
		),
		ClipsDescendants = true
	}
	local v20 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Image = 0,
		ImageRectOffset = 0,
		ImageRectSize = 0,
		ImageTransparency = 0,
		ImageColor3 = 0,
		Position = 0,
		Size = 0,
		ZIndex = 2
	}
	local image

	if type(icon.Image) == "string" then
		image = icon.Image
	end

	v20.Image = image
	v20.ImageRectOffset = icon.ImageRectOffset
	v20.ImageRectSize = icon.ImageRectSize
	v20.ImageTransparency = imageTransparency
	v20.ImageColor3 = color
	v20.Position = UDim2.fromScale(0.5, 0.5)
	local size

	if props.CropPadding then
		size = UDim2.fromScale(
			1 + props.CropPadding.Scale * 2 + props.CropPadding.Offset * 2 / (props.Icon.ImageRectSize or Vector2.zero).X,
			1 + props.CropPadding.Scale * 2 + props.CropPadding.Offset * 2 / (props.Icon.ImageRectSize or Vector2.zero).Y
		)
	else
		size = UDim2.fromScale(1, 1)
	end

	v20.Size = size
	children.IconMask = createElement("Frame", v16, {
		Icon = createElement("ImageLabel", v20, {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0.5, 0)
			})
		})
	})
	children.TextLabel = createElement("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = 1,
		FontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json"),
		Position = UDim2.fromScale(0.5, 0.95),
		Size = UDim2.fromScale(1, 0.35 + 0 * imageTransparency * 0.05),
		Text = props.Text .. v3,
		TextColor3 = color,
		TextScaled = true,
		TextStrokeTransparency = 0.3,
		ZIndex = 4
	})
	return createElement("ImageButton", v9, children)
end