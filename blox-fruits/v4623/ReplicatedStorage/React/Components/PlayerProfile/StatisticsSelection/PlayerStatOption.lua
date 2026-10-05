local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextUtil = require(ReplicatedStorage.Modules.Util.TextUtil)
local React = require(ReplicatedStorage.Packages.React)
local CONSTANTS = require(ReplicatedStorage.React.Components.PlayerProfile.CONSTANTS)
require(ReplicatedStorage.React.Components.PlayerProfile.Types)
local CONSTANTS2 = require(ReplicatedStorage.React.CONSTANTS)
local font = Font.new(CONSTANTS2.FONT.FAMILY.SOURCE_SANS_PRO)
local SPECIAL_STAT_FORMATTING = CONSTANTS.SPECIAL_STAT_FORMATTING
local v = {
	Image = "",
	ImageRectOffset = Vector2.zero,
	ImageRectSize = Vector2.zero
}
local createElement = React.createElement
return function(props)
	local text = React.useMemo(function()
		local v3 = SPECIAL_STAT_FORMATTING[props.DisplayName]

		if v3 ~= nil then
			return v3(props.Progression, props.MaxProgression)
		end

		if props.MaxProgression == 0 then
			return (`{TextUtil.commaValue(props.Progression)}`)
		end

		local v4 = props.Progression / props.MaxProgression

		if v4 >= 0.5 and v4 < 1 then
			return (`<font color="#{CONSTANTS2.COLOR.PALETTE.WHITE:Lerp(
				CONSTANTS2.COLOR.PRIMARY.BACKGROUND,
				(math.clamp((v4 - 0.5) / 0.5, 0, 1))
			):ToHex()}">{props.Progression}</font>/{props.MaxProgression}`)
		end

		if v4 >= 1 then
			return (`<font color="#{CONSTANTS2.COLOR.PRIMARY.BACKGROUND:ToHex()}">{props.Progression}</font>/<font color="#{CONSTANTS2.COLOR.PRIMARY.BACKGROUND:ToHex()}">{props.MaxProgression}</font>`)
		end

		return (`{props.Progression}/{props.MaxProgression}`)
	end, { props.StatId })
	local v3 = React.useMemo(function()
		local v4 = CONSTANTS.STAT_SPRITE_LOOKUP[props.DisplayName]

		if not v4 then
			return v
		end

		local v5 = CONSTANTS.STAT_SPRITES[v4]
		return v5 or v
	end, { props.StatId })
	local visible = React.useMemo(function()
		for i = 1, 4 do
			local v6 = props.LoadedPlayer.ProfileData[`Stat{i}`]

			if v6 and v6.StatId == props.StatId then
				return true
			end
		end

		return false
	end, { props.StatId })
	return createElement("TextButton", {
		BackgroundColor3 = Color3.fromRGB(33, 33, 33),
		FontFace = font,
		LayoutOrder = (visible and -1000 or 0) + props.StatId,
		Size = UDim2.fromScale(0.48, 1),
		Text = "",
		TextColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
		TextScaled = true,
		[React.Event.MouseButton1Click] = function()
			local v7, v8 = ReplicatedStorage.Remotes.UpdatePlayerProfileValue:InvokeServer(
				"Stat",
				props.SelectedStatSlotId,
				props.StatId
			)
			props.SetStatSelectionVisible(false)
			print("stat set", props.SelectedStatSlotId, props.StatId, v7, v8)

			if v7 then
				local selectedStatSlotId = props.SelectedStatSlotId
				local statId = props.StatId
				local v9 = {}
				local v10 = false

				for i = 1, 4 do
					local v11 = props.LoadedPlayer.ProfileData[`Stat{i}`]

					if not (v11 ~= nil and v11.StatId == statId) then
						continue
					end

					v9[`Stat{i}`] = CONSTANTS.CLEAR

					if i == selectedStatSlotId then
						v10 = true
					end
				end

				if not v10 then
					v9[`Stat{selectedStatSlotId}`] = {
						StatId = statId,
						Progression = props.Progression,
						MaxProgression = props.MaxProgression
					}
				end

				props.PatchProfileData(v9)
			end
		end
	}, {
		uICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.MD
		}),
		ratio = createElement("UIAspectRatioConstraint", {
			AspectRatio = 4.282051282051282
		}),
		statTemplateFilled = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.5, 0.55),
			Size = UDim2.fromScale(0.95, 0.925)
		}, {
			statName = createElement("TextLabel", {
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				FontFace = CONSTANTS2.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.02, -0.03),
				Size = UDim2.fromScale(0.963, 0.27),
				Text = props.DisplayName,
				TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextTransparency = CONSTANTS2.ALPHA.LIGHT,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = CONSTANTS2.LAYER.RAISED
			}),
			content = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
				BackgroundTransparency = CONSTANTS2.ALPHA.HEAVY,
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
				}),
				plusIcon = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
					Position = UDim2.fromScale(0.0735889, 0.5),
					Size = UDim2.fromScale(0.107, 1),
					Text = "+",
					TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
					TextScaled = true,
					TextTransparency = CONSTANTS2.ALPHA.HALF,
					Visible = false
				}),
				plusTextLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
					FontFace = CONSTANTS2.FONT.FACE.TITLE,
					Position = UDim2.fromScale(0.125, 0.52),
					RichText = true,
					Size = UDim2.fromScale(0.779911, 0.7),
					Text = "Add",
					TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
					TextScaled = true,
					TextTransparency = CONSTANTS2.ALPHA.HALF,
					TextXAlignment = Enum.TextXAlignment.Left,
					Visible = false,
					ZIndex = CONSTANTS2.LAYER.RAISED
				})
			})
		}),
		uIStroke = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = visible and CONSTANTS2.COLOR.PRIMARY.MUTED or CONSTANTS2.COLOR.PALETTE.BLACK,
			Thickness = visible and 1.5 or 1
		}),
		equippedGradient = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(232, 217, 54),
			BackgroundTransparency = 0.85,
			BorderColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
			BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ZIndex = CONSTANTS2.LAYER.BASE,
			Visible = visible
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
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			Image = "rbxassetid://139971361540768",
			Position = UDim2.fromScale(1.01, -0.05),
			Size = UDim2.fromScale(0.146314, 0.616294),
			ZIndex = 10,
			Visible = visible
		}, {
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
		})
	})
end