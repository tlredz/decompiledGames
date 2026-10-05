local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.RobloxTypes)
local Textures = require(game.ReplicatedStorage.Textures)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local useAbsoluteArea = require(game.ReplicatedStorage.React.Hooks.useAbsoluteArea)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local Banner = require(game.ReplicatedStorage.React.Components.BundleShop.Banner)
local Tile = require(game.ReplicatedStorage.React.Components.BundleShop.Tile)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	Image = Textures.misc["snowflake.png"],
	ImageRectOffset = Vector2.new(0, 0),
	ImageRectSize = Vector2.new(519, 528)
}
local v2 = {
	Image = Textures.misc["heart.png"],
	ImageRectOffset = Vector2.new(0, 0),
	ImageRectSize = Vector2.new(128, 119)
}
local unwrapped = Spritesheets.match("Pumpkin Mask1"):unwrap()

function getIconFromItemId(p: number)
	local unwrapped2 = ItemConfig.match(p):unwrap()
	local sprite = unwrapped2.Display.Sprite
	assert(sprite, (`bad sprite for {unwrapped2.Index.DebugLabel}`))
	return sprite
end

local createElement = React.createElement
return function(props)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local ref3 = React.useRef(nil)
	local v3 = useAbsoluteArea(ref3.current)
	local v4 = not v3 and 0 or v3.Max.X
	local anchorPoint = props.AnchorPoint or Vector2.new(0, 0.5)
	local position = props.Position or UDim2.fromScale(0.5, 0.475)
	local size = props.Size or UDim2.fromScale(0.5, 0.5)
	local v5 = {}
	local state, setState = React.useState(nil)
	local v6 = React.useMemo(function()
		local v7 = {}

		if props.SaleType == "HalloweenBundle2025" then
			table.insert(v7, {
				Focus = "Werewolf",
				Icon = getIconFromItemId(IdMap.PhysicalMoveset["Werewolf (Tiger)-Werewolf (Tiger)"])
			})
			table.insert(v7, {
				Focus = "Tiger",
				Icon = getIconFromItemId(IdMap.PhysicalMoveset["Tiger-Tiger"])
			})
		elseif props.SaleType == "FoxSpiritBundle2025" then
			table.insert(v7, {
				Focus = "Empyrean",
				Icon = getIconFromItemId(IdMap.PhysicalMoveset["Empyrean (Kitsune)-Empyrean (Kitsune)"])
			})
			table.insert(v7, {
				Focus = "Kitsune",
				Icon = getIconFromItemId(IdMap.PhysicalMoveset["Kitsune-Kitsune"])
			})
		elseif props.SaleType == "Valentines2026Bundle" then
			table.insert(v7, {
				Focus = "Fiend",
				Icon = getIconFromItemId(IdMap.PhysicalMoveset["Fiend (Yeti)-Fiend (Yeti)"])
			})
			table.insert(v7, {
				Focus = "Yeti",
				Icon = getIconFromItemId(IdMap.PhysicalMoveset["Yeti-Yeti"])
			})
		end

		table.freeze(v7)
		return v7
	end, { props.SaleType })

	if state == nil or #v6 < state and #v6 > 0 then
		setState(1)
		state = 1
	end

	local v7

	if state then
		v7 = v6[state]
	else
		v7 = nil
	end

	React.useEffect(function()
		if ref.current and ref2.current and props.IsOpen and v7 then
			ref.current.CurrentCamera = ref2.current
			return props.PreviewFrameEffect(v7.Focus, ref.current)
		else
			return function() end
		end
	end, {
		ref.current,
		ref2.current,
		v7,
		props.IsOpen
	})

	if #v6 > 1 then
		for k, v8 in v6 do
			local formatted = `Selected{v8}Background`
			local v9

			if state == k then
				v9 = createElement("Frame", {
					Active = false,
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
					Position = UDim2.fromScale(0.5, (k - 1) * 0.5 + 0.5),
					Selectable = true,
					Size = UDim2.fromScale(0.988, 0.5),
					ZIndex = k * 2 - 1
				}, {
					Trans = createElement("Frame", {
						Active = false,
						BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT,
						Position = UDim2.fromOffset(2, 2),
						Size = UDim2.new(1, -4, 0.5, 0)
					}, {
						UICorner = createElement("UICorner", {
							CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
						})
					}),
					UICorner = createElement("UICorner", {
						CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
					}),
					UIStroke = createElement("UIStroke")
				})
			else
				v9 = createElement("Frame", {
					Active = false,
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundColor3 = Color3.fromRGB(87, 86, 83),
					Position = UDim2.fromScale(0.5, (k - 1) * 0.5 + 0.5),
					Selectable = true,
					Size = UDim2.fromScale(0.988, 0.5),
					ZIndex = k * 2 - 1
				}, {
					Trans = createElement("Frame", {
						Active = false,
						BackgroundColor3 = Color3.fromRGB(107, 107, 106),
						Position = UDim2.fromOffset(2, 2),
						Size = UDim2.new(1, -4, 0.5, 0)
					}, {
						UICorner = createElement("UICorner", {
							CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
						})
					}),
					UICorner = createElement("UICorner", {
						CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
					}),
					UIStroke = createElement("UIStroke")
				})
			end

			v5[formatted] = v9
			local formatted2 = `{v8}Tab`
			local v12 = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				ImageColor3 = CONSTANTS.COLOR.PALETTE.GREY_500,
				Position = UDim2.fromScale(0.5, (k - 1) * 0.45 + 0.25),
				ScaleType = Enum.ScaleType.Fit,
				Selectable = false,
				ZIndex = k * 2
			}
			local v13 = k
			local v14 = v8
			v12[React.Event.Activated] = props.OnFocusClick and function()
				setState(v13)
				props.OnFocusClick(v14.Focus)
			end or nil
			v12.Size = UDim2.fromScale(0.945, 0.388)
			local v18 = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = v8.Icon.Image,
				ImageRectOffset = v8.Icon.ImageRectOffset,
				ImageRectSize = v8.Icon.ImageRectSize,
				ImageColor3 = 0,
				Position = 0,
				ScaleType = 0,
				Size = 0
			}
			local imageColor

			if state == k then
				imageColor = CONSTANTS.COLOR.PALETTE.WHITE
			else
				imageColor = CONSTANTS.COLOR.PALETTE.GREY_500
			end

			v18.ImageColor3 = imageColor
			v18.Position = UDim2.fromScale(0.5, 0.5)
			v18.ScaleType = Enum.ScaleType.Fit
			v18.Size = UDim2.fromScale(1, 1)
			local v15 = {
				Icon = createElement("ImageLabel", v18),
				TextLabel = 0
			}
			local v22 = {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.499999, 1.01042),
				Size = UDim2.fromScale(1.3, 0.32),
				Text = v8.Focus,
				TextColor3 = 0,
				TextScaled = true,
				ZIndex = 0
			}
			local textColor

			if state == k then
				textColor = CONSTANTS.COLOR.PALETTE.WHITE
			else
				textColor = CONSTANTS.COLOR.PALETTE.GREY_500
			end

			v22.TextColor3 = textColor
			v22.ZIndex = CONSTANTS.LAYER.RAISED
			v15.TextLabel = createElement("TextLabel", v22, {
				UIStroke = createElement("UIStroke", {
					Thickness = 1.75
				})
			})
			v5[formatted2] = createElement("ImageButton", v12, v15)
		end
	end

	local children = {}
	local v8 = React.useMemo(function()
		if props.SaleType == "HalloweenBundle2025" then
			return { "Werewolf", "Tiger" }
		end

		if props.SaleType == "FoxSpiritBundle2025" then
			return { "Empyrean", "Kitsune" }
		end

		if props.SaleType == "Valentines2026Bundle" then
			return { "Yeti", "Fiend" }
		end

		return {}
	end, { props.SaleType })
	local v9

	if props.SaleType == "HalloweenBundle2025" then
		v9 = unwrapped
	elseif props.SaleType == "FoxSpiritBundle2025" then
		v9 = v
	elseif props.SaleType == "Valentines2026Bundle" then
		v9 = v2
	end

	local text

	if props.SaleType == "FoxSpiritBundle2025" then
		text = "Kitsune + Empyrean Shop"
	elseif props.SaleType == "HalloweenBundle2025" then
		text = "Tiger + Werewolf Shop"
	elseif props.SaleType == "Valentines2026Bundle" then
		text = "Yeti + Fiend Shop"
	else
		text = ""
	end

	for k, v11 in v8 do
		children[`Tile{k}`] = createElement(Tile, {
			LayoutOrder = k,
			Type = v11,
			OnClick = function(p)
				if props.OnProductClick then
					props.OnProductClick(p)
				end
			end
		})
	end

	local v11 = props.IsOpen and not props.IsUIHidden
	local v13 = RunService:IsRunning() and "ScreenGui" or "Frame"
	local v14

	if RunService:IsRunning() then
		v14 = {
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			ResetOnSpawn = false,
			Enabled = v11
		}
	else
		v14 = {
			Visible = v11,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
		}
	end

	local menu

	if props.Position and props.Size then
		local v18 = {
			ref = ref3,
			BackgroundColor3 = Color3.fromRGB(21, 21, 21),
			BackgroundTransparency = 0.04,
			Position = position,
			AnchorPoint = anchorPoint,
			Size = size,
			ZIndex = CONSTANTS.LAYER.RAISED
		}
		local children3 = {
			Main = createElement("Frame", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(0, 0.0960163),
				Size = UDim2.fromScale(1, 0.903984),
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				Content = createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Position = UDim2.fromScale(0.5, 0.02),
					Size = UDim2.fromScale(0.966, 0.95756),
					ZIndex = CONSTANTS.LAYER.RAISED
				}, {
					Banner = createElement(Banner, {
						Type = props.SaleType == "FoxSpiritBundle2025" and "FoxSpirit2025" or props.SaleType == "HalloweenBundle2025" and "Halloween2025" or "Bloodfrost2026",
						LayoutOrder = -995,
						Position = UDim2.fromScale(0, -1.12213e-7),
						Size = UDim2.fromScale(1, 0.602984),
						ZIndex = CONSTANTS.LAYER.RAISED,
						OnClick = props.OnProductClick,
						OnPreviewClick = nil
					}),
					Fruits = createElement("Frame", {
						AnchorPoint = Vector2.new(0, 1),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						LayoutOrder = -2,
						Position = UDim2.fromScale(0, 1),
						Size = UDim2.fromScale(0.999, 0.374063),
						ZIndex = CONSTANTS.LAYER.RAISED
					}, {
						UIListLayout = createElement("UIListLayout", {
							FillDirection = Enum.FillDirection.Horizontal,
							HorizontalFlex = Enum.UIFlexAlignment.Fill,
							VerticalFlex = Enum.UIFlexAlignment.Fill,
							Padding = UDim.new(0.016, 0),
							SortOrder = Enum.SortOrder.LayoutOrder
						}),
						Tiles = createElement(React.Fragment, {}, children)
					})
				})
			}),
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0.02, 0)
			}),
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
				ZIndex = CONSTANTS.LAYER.BASE
			}),
			Title = 0,
			UIAspectRatioConstraint = 0,
			UISizeConstraint = 0
		}
		local v21 = {
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
			Size = UDim2.fromScale(1, 0.0960163)
		}
		local v22 = {
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
			}),
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
				ZIndex = CONSTANTS.LAYER.BASE
			}),
			UIGradient = 0,
			TextLabel = 0,
			Dec1 = 0,
			Dec2 = 0,
			Dec3 = 0,
			Dec4 = 0
		}
		local colorSequence

		if props.SaleType == "FoxSpiritBundle2025" then
			colorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 144, 238)),
				ColorSequenceKeypoint.new(0.355786, Color3.fromRGB(0, 194, 237)),
				ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(0, 194, 237)),
				ColorSequenceKeypoint.new(0.699482, Color3.fromRGB(0, 194, 237)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 144, 238))
			})
		elseif props.SaleType == "HalloweenBundle2025" then
			colorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 140, 0)),
				ColorSequenceKeypoint.new(0.355786, Color3.fromRGB(255, 94, 0)),
				ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(255, 94, 0)),
				ColorSequenceKeypoint.new(0.699482, Color3.fromRGB(255, 94, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 140, 0))
			})
		elseif props.SaleType == "Valentines2026Bundle" then
			colorSequence = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 94, 161)),
				ColorSequenceKeypoint.new(0.355786, Color3.fromRGB(255, 181, 212)),
				ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(255, 181, 212)),
				ColorSequenceKeypoint.new(0.699482, Color3.fromRGB(255, 181, 212)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 94, 161))
			})
		end

		v22.UIGradient = createElement("UIGradient", {
			Color = colorSequence
		})
		v22.TextLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			Position = UDim2.fromScale(0.5, 0.55),
			Size = UDim2.fromScale(0.8, 0.8),
			Text = text,
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true
		}, {
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN,
				ZIndex = CONSTANTS.LAYER.BASE
			}),
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.45),
				Size = UDim2.fromScale(1, 1),
				Text = text,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN,
					ZIndex = CONSTANTS.LAYER.BASE
				})
			})
		})
		local dec

		if v9 then
			dec = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = v9.Image,
				ImageRectOffset = v9.ImageRectOffset,
				ImageRectSize = v9.ImageRectSize,
				Position = UDim2.fromScale(0.015, 0.289),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.091, 0.91)
			})
		end

		v22.Dec1 = dec
		local dec2

		if v9 then
			dec2 = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = v9.Image,
				ImageRectOffset = v9.ImageRectOffset,
				ImageRectSize = v9.ImageRectSize,
				Position = UDim2.fromScale(0.0978171, 0.719136),
				Rotation = -55,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.074409, 0.715242)
			})
		end

		v22.Dec2 = dec2
		local dec3

		if v9 then
			dec3 = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = v9.Image,
				ImageRectOffset = v9.ImageRectOffset,
				ImageRectSize = v9.ImageRectSize,
				Position = UDim2.fromScale(0.904216, 0.723689),
				Rotation = -51,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.091, 0.91)
			})
		end

		v22.Dec3 = dec3
		local dec4

		if v9 then
			dec4 = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = v9.Image,
				ImageRectOffset = v9.ImageRectOffset,
				ImageRectSize = v9.ImageRectSize,
				Position = UDim2.fromScale(0.975, 0.3),
				Rotation = -21,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.091, 0.724711)
			})
		end

		v22.Dec4 = dec4
		children3.Title = createElement("Frame", v21, v22)
		children3.UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 1.2
		})
		children3.UISizeConstraint = createElement("UISizeConstraint", {
			MaxSize = Vector2.new(1e999, 575)
		})
		menu = createElement("Frame", v18, children3)
	end

	return createElement(v13, v14, {
		Menu = menu,
		Preview = createElement("ViewportFrame", {
			ref = ref,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			CurrentCamera = ref2.current,
			Size = UDim2.new(0.875, -v4, 1, 0),
			Position = UDim2.new(0, v4, 0, 0)
		}, {
			Camera = createElement("Camera", {
				ref = ref2
			})
		}),
		Close = createElement("ImageButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = CONSTANTS.COLOR.DANGER.BACKGROUND,
			LayoutOrder = 2,
			Position = UDim2.fromScale(0.978535, 0.15294),
			Size = UDim2.fromScale(0.0874503, 0.0566194),
			ZIndex = CONSTANTS.LAYER.RAISED,
			[React.Event.Activated] = props.OnCloseClick
		}, {
			Trans = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = CONSTANTS.COLOR.DANGER.HIGHLIGHT,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.98, 0.45)
			}),
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.5, 0.55),
				Size = UDim2.fromScale(0.95, 0.8),
				Text = "Close",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN,
					ZIndex = CONSTANTS.LAYER.BASE
				}),
				TextLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					Position = UDim2.fromScale(0.5, 0.425),
					Size = UDim2.fromScale(1, 1),
					Text = "Close",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true
				}, {
					UIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN,
						ZIndex = CONSTANTS.LAYER.BASE
					})
				})
			}),
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new()
			}),
			UIStroke = createElement("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = CONSTANTS.COLOR.DANGER.BORDER,
				Thickness = 1.2,
				ZIndex = CONSTANTS.LAYER.BASE
			})
		}),
		InvalidTextShadow = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			Position = UDim2.fromScale(0.5, 0.98),
			Size = UDim2.fromScale(0.6, 0.063),
			Text = "System still loading. Try again later.",
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true,
			TextTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			UIStroke = createElement("UIStroke", {
				Thickness = 2.204,
				Transparency = CONSTANTS.ALPHA.INVISIBLE,
				ZIndex = CONSTANTS.LAYER.BASE
			}),
			RealText = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.95),
				Size = UDim2.fromScale(1, 1),
				Text = "System still loading. Try again later.",
				TextColor3 = Color3.fromRGB(255, 86, 92),
				TextScaled = true,
				TextTransparency = CONSTANTS.ALPHA.INVISIBLE
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = 2.204,
					Transparency = CONSTANTS.ALPHA.INVISIBLE,
					ZIndex = CONSTANTS.LAYER.BASE
				})
			})
		}),
		PreviewSwitcher = createElement("Frame", {
			AnchorPoint = Vector2.new(1, 1),
			BackgroundColor3 = Color3.fromRGB(64, 64, 64),
			BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
			Position = UDim2.fromScale(0.975824, 0.873783),
			Size = UDim2.fromScale(0.0708024, 0.273697)
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
			}),
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			}),
			Buttons = createElement(React.Fragment, nil, v5)
		})
	})
end