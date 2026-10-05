local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextUtil = require(ReplicatedStorage.Modules.Util.TextUtil)
local React = require(ReplicatedStorage.Packages.React)
require(ReplicatedStorage.React.Components.PlayerProfile.Types)
local CONSTANTS = require(ReplicatedStorage.React.Components.PlayerProfile.CONSTANTS)
local CONSTANTS2 = require(ReplicatedStorage.React.CONSTANTS)
local SPECIAL_STAT_FORMATTING = CONSTANTS.SPECIAL_STAT_FORMATTING
local v = {
	Image = "",
	ImageRectOffset = Vector2.zero,
	ImageRectSize = Vector2.zero
}
local createElement = React.createElement
return function(props)
	local text = React.useMemo(function()
		if props.Stat == nil then
			return ""
		end

		local stat = props.Stat
		local v3 = SPECIAL_STAT_FORMATTING[props.Name]

		if v3 ~= nil then
			return v3(stat.Progression, stat.MaxProgression)
		end

		if stat.MaxProgression == 0 then
			return (`{TextUtil.commaValue(stat.Progression)}`)
		end

		local v4 = stat.Progression / stat.MaxProgression

		if v4 >= 0.5 and v4 < 1 then
			return (`<font color="#{CONSTANTS2.COLOR.PALETTE.WHITE:Lerp(
				CONSTANTS2.COLOR.PRIMARY.BACKGROUND,
				(math.clamp((v4 - 0.5) / 0.5, 0, 1))
			):ToHex()}">{stat.Progression}</font>/{stat.MaxProgression}`)
		end

		if v4 >= 1 then
			return (`<font color="#{CONSTANTS2.COLOR.PRIMARY.BACKGROUND:ToHex()}">{stat.Progression}</font>/<font color="#{CONSTANTS2.COLOR.PRIMARY.BACKGROUND:ToHex()}">{stat.MaxProgression}</font>`)
		end

		return (`{stat.Progression}/{stat.MaxProgression}`)
	end, { props.Stat })
	local v3 = React.useMemo(function()
		if props.Stat == nil then
			return v
		end

		local v4 = CONSTANTS.STAT_SPRITE_LOOKUP[props.Name]

		if not v4 then
			return v
		end

		local v5 = CONSTANTS.STAT_SPRITES[v4]
		return v5 or v
	end, { props.Stat })
	local v6 = {
		BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(-5.51979e-8, 0.562974),
		Size = UDim2.fromScale(0.48, 0.525)
	}
	local v7 = {
		click = createElement("TextButton", {
			Text = "",
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			Size = UDim2.new(1, 0, 0.5, 0),
			Position = UDim2.new(0, 0, 0.34, 0),
			ZIndex = 90,
			[React.Event.MouseButton1Click] = function()
				if props.LoadedPlayer.IsLocalPlayer ~= true or props.LoadedPlayer.IsPreviewMode then
					return
				end

				props.SetSelectedStatSlotId(props.StatNumber)
				props.SetStatSelectionVisible(true)
			end
		}),
		defaultContent = 0,
		addContent = 0,
		emptyContent = 0,
		statName = 0
	}
	local defaultContent

	if props.Variant == "Default" then
		defaultContent = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
			BackgroundTransparency = CONSTANTS2.ALPHA.LIGHT,
			Position = UDim2.fromScale(0.5, 0.84),
			Size = UDim2.fromScale(1, 0.5)
		}, {
			uICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0.14, 0)
			}),
			uIStroke = createElement("UIStroke"),
			icon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				Image = v3.Image,
				ImageRectSize = v3.ImageRectSize,
				ImageRectOffset = v3.ImageRectOffset,
				Position = UDim2.fromScale(0.0194199, 0.494766),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.154344, 1.30565)
			}),
			statName = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.21, 0.525),
				RichText = true,
				Size = UDim2.fromScale(0.767, 0.7),
				Text = text,
				TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = CONSTANTS2.LAYER.RAISED
			}, {
				uIStroke = createElement("UIStroke")
			})
		})
	end

	v7.defaultContent = defaultContent
	local addContent

	if props.Variant == "Add" then
		addContent = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
			BackgroundTransparency = CONSTANTS2.ALPHA.LIGHT,
			Position = UDim2.fromScale(0.5, 0.84),
			Size = UDim2.fromScale(1, 0.5)
		}, {
			uICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0.14, 0)
			}),
			uIStroke = createElement("UIStroke"),
			plusTextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				FontFace = CONSTANTS2.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.125, 0.5),
				RichText = true,
				Size = UDim2.fromScale(0.779911, 0.7),
				Text = "Add",
				TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextTransparency = CONSTANTS2.ALPHA.HALF,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = CONSTANTS2.LAYER.RAISED
			}),
			plusIcon = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(0.0735889, 0.5),
				Size = UDim2.fromScale(0.107, 1),
				Text = "+",
				TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextTransparency = CONSTANTS2.ALPHA.HALF
			})
		})
	end

	v7.addContent = addContent
	local emptyContent

	if props.Variant == "Empty" then
		emptyContent = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
			BackgroundTransparency = CONSTANTS2.ALPHA.LIGHT,
			Position = UDim2.fromScale(0.5, 0.84),
			Size = UDim2.fromScale(1, 0.5)
		}, {
			uICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0.14, 0)
			}),
			uIStroke = createElement("UIStroke"),
			emptyStateTextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				FontFace = CONSTANTS2.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.035, 0.5),
				RichText = true,
				Size = UDim2.fromScale(0.874469, 0.7),
				Text = "None",
				TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextTransparency = CONSTANTS2.ALPHA.HALF,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = CONSTANTS2.LAYER.RAISED
			})
		})
	end

	v7.emptyContent = emptyContent
	v7.statName = createElement("TextLabel", {
		Active = false,
		BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
		FontFace = CONSTANTS2.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.02, -0.03),
		Size = UDim2.fromScale(0.963, 0.26),
		Text = props.Name,
		TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
		TextScaled = true,
		TextTransparency = CONSTANTS2.ALPHA.LIGHT,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = CONSTANTS2.LAYER.RAISED
	})
	return createElement("Frame", v6, v7)
end