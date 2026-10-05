local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemConfig = require(ReplicatedStorage.ItemConfig)
local ProfileBackgrounds = require(ReplicatedStorage.Modules.ProfileBackgrounds)
local React = require(ReplicatedStorage.Packages.React)
local NewBadge = require(ReplicatedStorage.React.Components.NewBadge)
require(ReplicatedStorage.React.Components.PlayerProfile.Types)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local text = React.useMemo(function()
		local v2 = ProfileBackgrounds.List[props.Name]

		if v2 == nil then
			return "N/A"
		end

		local itemConfigNameOverride = v2.ItemConfigNameOverride or props.Name
		local nullable = ItemConfig.match(itemConfigNameOverride, v2.Type):asNullable()

		if nullable == nil then
			return props.Name
		end

		return nullable.Display.Name or props.Name
	end, { props.Name })
	local v2 = React.useMemo(function()
		return props.LoadedPlayer.NewBackgrounds[props.Name] == true
	end, { props.Name, props.LoadedPlayer })
	local v5 = {
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
		Position = UDim2.fromScale(-1.05848e-8, -3.86164e-8),
		Size = UDim2.fromScale(0.18, 0.234),
		Text = "",
		TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		TextScaled = true,
		[React.Event.MouseButton1Click] = function()
			props.SetSelectedBackground(props.Id)

			if v2 then
				props.ClearNewBackground(props.Name)
			end
		end
	}
	local newBadge

	if v2 then
		newBadge = createElement(NewBadge, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.06, 0.06),
			Size = UDim2.fromScale(0.22, 0.22),
			ZIndex = 12
		})
	end

	return createElement("TextButton", v5, {
		newBadge = newBadge,
		uICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0.04, 0)
		}),
		uIStroke = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = props.Equipped and CONSTANTS.COLOR.PRIMARY.MUTED or CONSTANTS.COLOR.PALETTE.BLACK,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
		}),
		backgroundName = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			Position = UDim2.fromScale(0.5, 0.98),
			Size = UDim2.fromScale(0.925, 0.125715),
			Text = text,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			uIStroke = createElement("UIStroke")
		}),
		colorFade = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(232, 217, 54),
			BackgroundTransparency = 0.85,
			BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			Visible = props.Equipped,
			ZIndex = CONSTANTS.LAYER.BASE
		}, {
			uIGradient = createElement("UIGradient", {
				Rotation = -90,
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.466999, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		}),
		equippedTag = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://139971361540768",
			Position = UDim2.fromScale(1.025, -0.012),
			Size = UDim2.fromScale(0.250137, 0.183677),
			Visible = props.Equipped,
			ZIndex = 10
		}, {
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
		}),
		profileBG = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = ProfileBackgrounds.List[props.Name].Image,
			Position = UDim2.fromScale(0.5, 0.475),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.85, 0.85)
		})
	})
end