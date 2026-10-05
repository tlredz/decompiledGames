local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local Textures = require(game.ReplicatedStorage.Textures)
local Notification

if RunService:IsRunning() then
	Notification = require(game.ReplicatedStorage.Notification)
else
	Notification = nil
end

require(game.ReplicatedStorage.Spritesheets)
local useTime = require(game.ReplicatedStorage.React.Hooks.Animation.useTime)
local useSequence = require(game.ReplicatedStorage.React.Hooks.Animation.useSequence)
local Button = require(game.ReplicatedStorage.React.Components.Button)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local defaultpng = Textures.banner.shop.dragons["Default.png"]
local dragons = Textures.banner.shop.dragons
local dragons2 = {}

for _, dragon in pairs(dragons) do
	if not (dragon ~= defaultpng and dragon ~= dragons["Yellow.png"]) then
		continue
	end

	table.insert(dragons2, dragon)

	if #dragons2 > 3 then
		break
	end
end

local createElement = React.createElement

function useGradientBand(p: number, p2: number, p3: number, p4: number, p5: number, p6: number?)
	return useSequence((p + p2) % 1, (p + p2 + p3) % 1, p4, p5, p6)
end

function dragonLayer(props)
	local texture = props.Textures[props.Index]
	local v = 1 / #props.Textures

	if not texture then
		return nil
	end

	local v4 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Active = false,
		Image = texture,
		Position = UDim2.fromScale(0.5, 0.5),
		ScaleType = Enum.ScaleType.Crop,
		Size = UDim2.fromScale(1, 1),
		ZIndex = CONSTANTS.LAYER.BASE
	}
	local v5 = {
		UIGradient = createElement("UIGradient", {
			Rotation = 20,
			Transparency = useGradientBand(props.Alpha, (props.Index - 1) * v, v, 0, 1, 0.1)
		}),
		Dragon = 0
	}
	local dragon

	if props.Index < #dragons2 then
		dragon = createElement(dragonLayer, {
			Index = props.Index + 1,
			Alpha = props.Alpha,
			Textures = props.Textures
		})
	end

	v5.Dragon = dragon
	return (createElement("ImageLabel", v4, v5))
end

function specialDragonEffect(_)
	local alpha = useTime(true) % 7 / 7
	return createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Active = false,
		Image = defaultpng,
		Position = UDim2.fromScale(0.5, 0.5),
		ScaleType = Enum.ScaleType.Crop,
		Size = UDim2.fromScale(1, 1),
		ZIndex = CONSTANTS.LAYER.BASE
	}, {
		DragonLayer = createElement(dragonLayer, {
			Index = 1,
			Alpha = alpha,
			Textures = dragons2
		})
	})
end

function descriptionLabel(props)
	local v = useTime(type(props.Description) == "function")
	local description = ""

	if type(props.Description) == "string" then
		description = props.Description
	elseif type(props.Description) == "function" then
		description = props.Description(v)
	end

	local v4 = {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = Font.new(CONSTANTS.FONT.FAMILY.HIGHWAY_GOTHIC, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
		Position = UDim2.new(UDim.new(0.5, 0), props.DescriptionYPosition or UDim.new(-0.15, 0)),
		Active = false,
		RichText = true,
		Size = UDim2.new(UDim.new(0.911789, 0), props.DescriptionHeight or UDim.new(1.5, 0)),
		Text = description,
		TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true,
		ZIndex = 4
	}
	local uIStroke

	if props.DescriptionStrokeColor3 then
		uIStroke = createElement("UIStroke", {
			Color = props.DescriptionStrokeColor3,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.HAIRLINE
		})
	end

	return createElement("TextLabel", v4, {
		UIStroke = uIStroke
	})
end

return function(props)
	local state, setState = React.useState(nil)
	React.useEffect(function()
		local saleFinishAt = props.SaleFinishAt

		if saleFinishAt then
			local renderSteppedConnection = RunService.RenderStepped:Connect(function()
				local now = DateTime.now()
				local v = math.max(0, saleFinishAt.UnixTimestamp - now.UnixTimestamp)
				local v2 = {}
				local v3 = math.floor(v / 86400)
				local v4 = v - v3 * 24 * 60 * 60

				if v3 > 0 then
					table.insert(v2, (`{string.format("%02d", v3)}d`))
				end

				local v5 = math.floor(v4 / 3600)
				local v6 = v4 - v5 * 60 * 60
				table.insert(v2, (`{string.format("%02d", v5)}h`))
				local v7 = math.floor(v6 / 60)
				local v8 = v6 - v7 * 60
				table.insert(v2, (`{string.format("%02d", v7)}m`))

				if #v2 < 3 then
					table.insert(v2, (`{string.format("%02d", v8)}s`))
				end

				local joined = table.concat(v2, " ")

				if joined ~= state then
					setState(joined)
				end
			end)
			return function()
				renderSteppedConnection:Disconnect()
			end
		end

		if state then
			setState(nil)
		end

		return function() end
	end, { props.SaleFinishAt, state })
	local v

	if props.SaleFinishAt then
		v = DateTime.now().UnixTimestampMillis >= props.SaleFinishAt.UnixTimestampMillis
	end

	local isDisabled = props.IsDisabled
	local v2 = v == true or isDisabled

	if v2 then
		state = nil
	end

	local buyButtonStyle = props.BuyButtonStyle or "Green"
	local v6 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://2882228740",
		ImageColor3 = props.BackgroundColor3 or CONSTANTS.COLOR.PALETTE.BLACK,
		Active = false,
		Position = UDim2.fromScale(0.5, 0.04),
		ScaleType = Enum.ScaleType.Slice,
		Size = UDim2.fromScale(0.19, 0.24),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		SliceCenter = Rect.new(4, 4, 16, 16)
	}
	local v10 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Active = false,
		Position = UDim2.fromScale(0, props.Title and 0.125 or 0),
		Size = UDim2.fromScale(1, 1 - (props.Title and 0.125 or 0) - (props.Price and 0.125 or 0)),
		ZIndex = CONSTANTS.LAYER.RAISED
	}
	local _ = props.ProductImage == defaultpng
	local v14 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Active = false,
		Image = props.ProductImage,
		ImageRectOffset = props.ProductImageOffset,
		ImageRectSize = props.ProductImageSize,
		AnchorPoint = props.ProductImageIconAnchorPoint or Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		ScaleType = 0,
		Size = 0,
		ZIndex = 0
	}
	local scaleType

	if props.ProductImageSize then
		scaleType = Enum.ScaleType.Fit
	else
		scaleType = Enum.ScaleType.Crop
	end

	v14.ScaleType = scaleType
	v14.Size = props.ProductImageIconSize or UDim2.fromScale(1, 1)
	v14.ZIndex = CONSTANTS.LAYER.BASE
	local v11 = {
		ProductImage = createElement("ImageLabel", v14),
		CanvasGroup = 0
	}
	local v18 = {
		AnchorPoint = Vector2.new(0.5, 1),
		Active = false,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.5, 1),
		Size = UDim2.fromScale(1, 1),
		ZIndex = -999
	}
	local fade

	if props.ProductGlow ~= nil then
		local v23 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Active = false,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ZIndex = -999
		}
		local v27 = {
			Color = props.ProductGlow,
			Rotation = -90,
			Transparency = 0
		}
		local transparency

		if props.ProductImageOffset then
			transparency = NumberSequence.new(0)
		else
			transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.43462, 0),
				NumberSequenceKeypoint.new(1, 0)
			})
		end

		v27.Transparency = transparency
		fade = createElement("Frame", v23, {
			UIGradient = createElement("UIGradient", v27)
		})
	end

	local uIGradient

	if not props.ProductImageOffset then
		uIGradient = createElement("UIGradient", {
			Rotation = -90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.5875),
				NumberSequenceKeypoint.new(0.339975, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		})
	end

	v11.CanvasGroup = createElement("CanvasGroup", v18, {
		Fade = fade,
		UIGradient = uIGradient
	})
	local v7 = {
		Middle = createElement("Frame", v10, v11),
		Bottom = 0,
		Top = 0,
		UIPadding = 0
	}
	local bottom

	if props.Price then
		local v25 = {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://2882228740",
			ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			ImageRectOffset = Vector2.new(0, 4),
			ImageRectSize = Vector2.new(20, 16),
			Active = false,
			LayoutOrder = 1,
			Position = UDim2.fromScale(0, 1),
			ScaleType = Enum.ScaleType.Slice,
			Size = UDim2.new(UDim.new(1, 0), props.BuyButtonHeight or UDim.new(0.125)),
			SliceCenter = Rect.new(4, 0, 12, 12),
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		}
		local descriptionLabel2

		if props.Description then
			descriptionLabel2 = createElement(descriptionLabel, props)
		end

		local children = {
			DescriptionLabel = descriptionLabel2,
			UISizeConstraint = createElement("UISizeConstraint", {
				MinSize = Vector2.new(0, 23)
			}),
			ImageLabel = 0,
			UIPadding = 0,
			Highlight = 0,
			TextLabel = 0,
			Button = 0
		}
		local imageLabel

		if buyButtonStyle == "Green" then
			imageLabel = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://2882228740",
				ImageColor3 = Color3.fromRGB(4, 211, 70),
				ImageRectOffset = Vector2.new(0, 4),
				Active = false,
				ImageRectSize = Vector2.new(20, 16),
				LayoutOrder = 1,
				ScaleType = Enum.ScaleType.Slice,
				Size = UDim2.fromScale(1, 1),
				SliceCenter = Rect.new(4, 0, 12, 12),
				ZIndex = CONSTANTS.LAYER.BASE
			})
		end

		children.ImageLabel = imageLabel
		children.UIPadding = createElement("UIPadding", {
			PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.XXS
		})
		children.Highlight = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PURCHASE.HIGHLIGHT,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromOffset(2, 2),
			Size = UDim2.new(1, -4, 0.4, 0),
			ZIndex = CONSTANTS.LAYER.CONTENT
		})
		local textLabel

		if buyButtonStyle == "Green" then
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				Active = false,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0, 0.55),
				RichText = true,
				Size = UDim2.fromScale(1, 0.9),
				Text = `<stroke color="#000000" joins="miter" thickness="2"><font size="12">{props.Price}</font></stroke>` .. (not props.OriginalPrice and "" or ` <font color="rgb(0,0,0)"><s><font size="10">{props.OriginalPrice}</font></s></font>`),
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			})
		end

		children.TextLabel = textLabel
		local button

		if props.BuyButtonStyle == "Yellow" then
			button = createElement(Button, {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Text = `{props.Price}`,
				YPadding = props.YellowBuyButtonYPadding,
				ElevatedBackgroundColor3 = Color3.fromRGB(255, 240, 69),
				BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
				Active = false,
				LayoutOrder = 1,
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.fromScale(1, 1),
				ZIndex = CONSTANTS.LAYER.BASE,
				OnClick = props.OnClick
			})
		end

		children.Button = button
		bottom = createElement("ImageLabel", v25, children)
	end

	v7.Bottom = bottom
	local top

	if props.Title then
		local v26 = {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://2882228740",
			Active = false,
			ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			ImageRectSize = Vector2.new(20, 16),
			LayoutOrder = 1,
			ScaleType = Enum.ScaleType.Slice,
			Size = UDim2.fromScale(1, 0.131479),
			SliceCenter = Rect.new(4, 4, 16, 16),
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		}
		local previewButton

		if props.OnPreviewClick then
			previewButton = createElement("TextButton", {
				AnchorPoint = Vector2.new(1, 0),
				BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
				BorderColor3 = CONSTANTS.COLOR.PRIMARY.BORDER,
				FontFace = CONSTANTS.FONT.FACE.BODY_LIGHT,
				Position = UDim2.new(1, -10, 1, 10),
				Size = UDim2.fromScale(2.75, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Text = "",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true,
				TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				[React.Event.Activated] = props.OnPreviewClick
			}, {
				Trans = createElement("Frame", {
					BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT,
					Active = false,
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
					Position = UDim2.fromOffset(2, 2),
					Size = UDim2.new(1, -4, 0.4, 0),
					ZIndex = CONSTANTS.LAYER.CONTENT
				}),
				TextLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Active = false,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY,
					Position = UDim2.fromScale(0.5, 0.55),
					Size = UDim2.fromScale(0.95, 0.75),
					Text = "Preview",
					TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					TextScaled = true,
					ZIndex = CONSTANTS.LAYER.RAISED
				}, {
					UIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
					}),
					TextLabel = createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						Active = false,
						FontFace = CONSTANTS.FONT.FACE.DISPLAY,
						Position = UDim2.fromScale(0.5, 0.45),
						Size = UDim2.fromScale(1, 1),
						Text = "Preview",
						TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
						TextScaled = true
					}, {
						UIStroke = createElement("UIStroke", {
							Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
						})
					})
				})
			})
		end

		local reworkLabel

		if props.IsReworked then
			reworkLabel = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://124540416344425",
				Position = UDim2.fromScale(-0.0479874, 1),
				AnchorPoint = Vector2.new(0, 0.2),
				Active = false,
				Size = UDim2.fromScale(4.5, 1.2),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				ZIndex = CONSTANTS.LAYER.OVERLAY
			}, {
				TextLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY,
					Position = UDim2.fromScale(0.5, 0.575),
					Size = UDim2.fromScale(1, 0.675),
					Text = "Reworked",
					TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					TextScaled = true,
					ZIndex = 10
				}, {
					UIStroke = createElement("UIStroke", {
						ZIndex = CONSTANTS.LAYER.BASE
					}),
					TextLabel = createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						FontFace = CONSTANTS.FONT.FACE.DISPLAY,
						Position = UDim2.fromScale(0.5, 0.45),
						Size = UDim2.fromScale(1, 1),
						Text = "Reworked",
						TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
						TextScaled = true,
						ZIndex = 10
					}, {
						UIStroke = createElement("UIStroke", {
							ZIndex = CONSTANTS.LAYER.BASE
						})
					})
				})
			})
		end

		local countdown

		if not (props.SaleFinishAt == nil or state == nil) then
			countdown = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://124540416344425",
				Position = UDim2.fromScale(-0.0479874, 1),
				AnchorPoint = Vector2.new(0, 0.2),
				Active = false,
				Size = UDim2.fromScale(4.5, 1.2),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				ZIndex = 10
			}, {
				TextLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY,
					Position = UDim2.fromScale(0.5, 0.575),
					Size = UDim2.fromScale(1, 0.675),
					Active = false,
					Text = state,
					TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					TextScaled = true,
					ZIndex = 10
				}, {
					UIStroke = createElement("UIStroke", {
						ZIndex = CONSTANTS.LAYER.BASE
					}),
					TextLabel = createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						Active = false,
						FontFace = CONSTANTS.FONT.FACE.DISPLAY,
						Position = UDim2.fromScale(0.5, 0.45),
						Size = UDim2.fromScale(1, 1),
						Text = state,
						TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
						TextScaled = true,
						ZIndex = 10
					}, {
						UIStroke = createElement("UIStroke", {
							ZIndex = CONSTANTS.LAYER.BASE
						})
					})
				})
			})
		end

		local children = {
			PreviewButton = previewButton,
			ReworkLabel = reworkLabel,
			Countdown = countdown,
			UISizeConstraint = createElement("UISizeConstraint", {
				MinSize = Vector2.new(0, 24)
			}),
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Active = false,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0, 0.5),
				RichText = true,
				Size = UDim2.fromScale(1, 0.815),
				Text = props.Title,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextYAlignment = Enum.TextYAlignment.Bottom,
				ZIndex = CONSTANTS.LAYER.OVERLAY
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
				})
			}),
			UIPadding = createElement("UIPadding", {
				PaddingBottom = CONSTANTS.SPACING.PADDING.OFFSET.XXS
			}),
			ImageLabel = 0
		}
		local v32 = {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://2882228740",
			ImageColor3 = 0,
			ImageRectSize = 0,
			Active = false,
			LayoutOrder = 1,
			ScaleType = 0,
			Size = 0,
			SliceCenter = 0,
			ZIndex = 0
		}
		local titleColor

		if typeof(props.TitleColor) == "Color3" then
			titleColor = props.TitleColor
		elseif typeof(props.TitleColor) == "ColorSequence" then
			titleColor = Color3.fromRGB(250, 250, 250)
		else
			titleColor = Color3.fromRGB(239, 193, 75)
		end

		v32.ImageColor3 = titleColor
		v32.ImageRectSize = Vector2.new(20, 16)
		v32.ScaleType = Enum.ScaleType.Slice
		v32.Size = UDim2.fromScale(1, 1)
		v32.SliceCenter = Rect.new(4, 4, 16, 16)
		v32.ZIndex = CONSTANTS.LAYER.RAISED
		local uIGradient2

		if typeof(props.TitleColor) == "ColorSequence" then
			uIGradient2 = createElement("UIGradient", {
				Color = props.TitleColor
			})
		end

		children.ImageLabel = createElement("ImageLabel", v32, {
			UIGradient = uIGradient2
		})
		top = createElement("ImageLabel", v26, children)
	end

	v7.Top = top
	v7.UIPadding = createElement("UIPadding", {
		PaddingBottom = UDim.new(0, 3),
		PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.XXS,
		PaddingRight = CONSTANTS.SPACING.PADDING.OFFSET.XXS,
		PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.XXS
	})
	local v3 = {
		Content = createElement("ImageLabel", v6, v7),
		UIGridLayout = createElement("UIGridLayout", {
			CellPadding = UDim2.fromScale(0.012, 0),
			CellSize = UDim2.fromScale(1, 1),
			HorizontalAlignment = Enum.HorizontalAlignment.Center
		})
	}
	local v24

	if props.FlexWidthRatio then
		v24 = createElement("UIFlexItem", {
			FlexMode = Enum.UIFlexMode.Custom,
			GrowRatio = props.FlexWidthRatio
		})
	end

	if not props.ErrorMessage and (v2 or props.OnClick == nil) then
		return createElement("ImageLabel", RobloxTypes.mergeGuiLabel({
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
		}, props), {
			UIFlexItem = v24,
			Group = createElement("CanvasGroup", RobloxTypes.mergeCanvasGroup({
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				GroupTransparency = 0.3,
				GroupColor3 = Color3.fromRGB(128, 128, 128),
				Size = UDim2.fromScale(1, 1),
				Active = false
			}, props), v3)
		})
	end

	local uIFlexItem

	if not props.IsDisabled then
		uIFlexItem = v24
	end

	v3.UIFlexItem = uIFlexItem
	local mergeGuiButton = RobloxTypes.mergeGuiButton
	local v28 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}
	local activated = React.Event.Activated
	local v29

	if props.OnClick and not v2 then
		v29 = props.OnClick
	else
		v29 = props.ErrorMessage and function()
			if Notification then
				Notification.new(props.ErrorMessage):Display()
			else
				warn(props.ErrorMessage)
			end
		end or nil
	end

	v28[activated] = v29
	return createElement("ImageButton", mergeGuiButton(v28, props), props.IsDisabled and {
		FlexItem = v24,
		Group = createElement("CanvasGroup", RobloxTypes.mergeCanvasGroup({
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			GroupTransparency = 0.3,
			GroupColor3 = Color3.fromRGB(128, 128, 128),
			Size = UDim2.fromScale(1, 1),
			Active = false
		}, props), v3)
	} or v3)
end