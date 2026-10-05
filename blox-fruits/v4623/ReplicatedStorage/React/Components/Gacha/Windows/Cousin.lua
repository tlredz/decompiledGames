local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local React = require(game.ReplicatedStorage.Packages.React)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local TimeUtil = require(game.ReplicatedStorage.Modules.Util.TimeUtil)
local BackgroundSound = require(game.ReplicatedStorage.React.Components.Gacha.BackgroundSound)
local AnimatedTile = require(game.ReplicatedStorage.React.Components.Gacha.AnimatedTile)
local FruitIcon = require(game.ReplicatedStorage.React.Components.Gacha.FruitIcon)
local SimpleButton = require(game.ReplicatedStorage.React.Components.Gacha.Buttons.SimpleButton)
local Notification = require(game.ReplicatedStorage.React.Components.Gacha.Notification)
local useTime = require(game.ReplicatedStorage.React.Hooks.Animation.useTime)
local useAction = require(game.ReplicatedStorage.React.Hooks.useAction)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.Modules.Gacha.SharedGachaTypes)
require(game.ReplicatedStorage.Modules.Gacha.ClientBannerTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local uDim = UDim2.new(0.5, 0, 0.5, 0)
local uDim2 = UDim2.fromScale(0.5, 1.5)
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local v = {
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 234, 0)),
	ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 227, 0)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 128, 0)),
	ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 230, 0)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 234, 0))
}
local v2 = {
	["Dragon-Dragon1"] = 1.1
}
local uDim3 = UDim2.fromScale(0.653238, 0.81927)
local color = Color3.fromRGB(112, 255, 23)
local color2 = Color3.fromRGB(0, 255, 8)
local color3 = Color3.fromRGB(21, 21, 21)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.HEADER.BACKGROUND),
	ColorSequenceKeypoint.new(0.509499, CONSTANTS.COLOR.PALETTE.GOLD_450),
	ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.HEADER.BACKGROUND)
})
local createElement = React.createElement

function bannerItemTimer(p)
	local unixTimestamp = DateTime.now().UnixTimestamp
	local diffTime = TimeUtil.diffTime(p.EndsAt, unixTimestamp)
	local v3 = { (useTime(diffTime > 0)) }
	local text = React.useMemo(function()
		if diffTime <= 0 then
			return "..."
		end

		return (`Ends in {TimeUtil.format(diffTime, "short")}`)
	end, v3)
	return createElement("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.496, 1.07),
		RichText = true,
		Size = UDim2.fromScale(0.782613, 0.33141),
		Text = text,
		TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true
	}, {
		UIStroke = createElement("UIStroke", {
			Thickness = 0.06,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
		})
	})
end

function glowBannerText()
	local ref = React.useRef(nil)
	local ref2 = React.useRef(0)
	React.useEffect(function()
		local heartbeatConnection

		if ref.current then
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
				ref2.current += dt
				ref.current.Rotation = math.sin(ref2.current * 2) * 5
			end)
		else
			heartbeatConnection = nil
		end

		return function()
			if heartbeatConnection then
				heartbeatConnection:Disconnect()
			end
		end
	end, { ref.current })
	return createElement("ImageLabel", {
		ref = ref,
		AnchorPoint = Vector2.new(0.5, 1),
		Size = uDim3,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://111285502935012",
		ImageColor3 = color,
		ImageTransparency = 0.19,
		Position = UDim2.fromScale(1.51953, 0.79897),
		Rotation = -5
	}, {
		TextLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			Position = UDim2.fromScale(0.496, 0.525),
			Size = UDim2.fromScale(0.996607, 0.56564),
			Text = "⬆RATE UP⬆",
			TextColor3 = color2,
			TextScaled = true
		}, {
			UIStroke = createElement("UIStroke", {
				Thickness = 0.07,
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
			})
		})
	})
end

function bannerItem(p)
	local ref = React.useRef(nil)
	local element2 = createElement("Folder", {}, {
		AnimatedFlameBackground = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://93734379412372",
			Position = UDim2.fromScale(0.768858, -0.437474),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.673415, 1.87395),
			ZIndex = CONSTANTS.LAYER.BEHIND
		}, {
			UIGradient = createElement("UIGradient", {
				ref = ref,
				Color = ColorSequence.new(v),
				Rotation = 0
			})
		})
	})
	local ref2 = React.useRef(0)
	React.useEffect(function()
		local heartbeatConnection

		if ref.current then
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
				ref2.current += dt
				local v4 = (math.sin(ref2.current * 2) + 1) * 0.5
				local v5 = math.sin(ref2.current * 4) * 0.15 + 0.85
				ref.current.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromHSV(v4 * 0.02 + 0.1, 1, 1)),
					ColorSequenceKeypoint.new(0.5, Color3.fromHSV(v4 * 0.02 + 0.07, 1, (math.min(v5 + 0.2, 1)))),
					ColorSequenceKeypoint.new(1, Color3.fromHSV(v4 * 0.02 + 0.04, 1, 1))
				})
			end)
		else
			heartbeatConnection = nil
		end

		return function()
			if heartbeatConnection then
				heartbeatConnection:Disconnect()
			end
		end
	end, { ref.current })
	local v4 = v2[Spritesheets.getKeys(p.BannerItem.Sprite)[1]] or 1.113
	local v5 = React.useMemo(function()
		return {
			Shake = {
				Enabled = true
			},
			Sparkle = {
				Enabled = true
			},
			Image = p.BannerItem.Sprite.Image,
			ImageRectSize = p.BannerItem.Sprite.ImageRectSize,
			ImageRectOffset = p.BannerItem.Sprite.ImageRectOffset,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = CONSTANTS.LAYER.RAISED,
			Size = UDim2.fromScale(0.360774, 1.42424),
			Position = UDim2.fromScale(v4, 0.475),
			AnchorPoint = Vector2.new(0.5, 0.5)
		}
	end, { p.BannerItem.UID, v4 })
	return createElement("Folder", {}, {
		BrushStroke = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://75123115585160",
			ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			Position = UDim2.fromScale(-0.051, 0.023),
			Size = UDim2.fromScale(0.47519, 0.300128),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			Glow = createElement(glowBannerText),
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.528833, 0.502672),
				RichText = true,
				Size = UDim2.fromScale(0.782613, 0.618559),
				Text = "Featured Banner:",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = 0.06,
					StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
				})
			}),
			Icon = createElement(AnimatedTile, v5),
			BrushStrokeBackground = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://75123115585160",
				Position = UDim2.fromScale(-0.00208472, 0.0757617),
				Size = UDim2.fromScale(1.00208, 0.759104),
				ZIndex = -9999
			}, {
				UIGradient = createElement("UIGradient", {
					Color = colorSequence
				})
			}),
			BannerItemTimer = createElement(bannerItemTimer, {
				EndsAt = p.BannerItem.Ends
			}),
			AnimatedFlame = element2
		})
	})
end

function closeButton(p)
	local ref = React.useRef(nil)
	local v3 = useAction({
		ActionName = "GachaWindowClose",
		InputType = "Gamepad",
		Triggers = { Enum.KeyCode.ButtonB },
		Priority = 4
	})
	React.useEffect(function()
		if ref.current and v3 then
			GuiService.SelectedObject = ref.current
		end
	end, { v3, ref.current })
	return createElement("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.DANGER.BACKGROUND,
		BorderColor3 = CONSTANTS.COLOR.DANGER.BORDER,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
		LayoutOrder = -999,
		Position = UDim2.fromScale(0.985, 0.5),
		Size = UDim2.fromScale(0.0617855, 0.658796),
		Text = "",
		TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		TextScaled = true,
		TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		ZIndex = CONSTANTS.LAYER.RAISED,
		[React.Event.Activated] = p.OnClose
	}, {
		Trans = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = CONSTANTS.COLOR.DANGER.HIGHLIGHT,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.94, 0.47)
		}),
		Icon = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://127503254560275",
			ImageRectSize = Vector2.new(100, 100),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ZIndex = CONSTANTS.LAYER.RAISED
		}),
		UIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
	})
end

function purchaseButton(data)
	local v3 = data.CooldownTimeEnds - os.time()
	local formatted = data.Cost.Formatted
	local v4 = data.Cost.Name == "Money"
	local v5 = data.Cost.Name == "Silver Key"
	local v6 = v3 > 0
	local v7 = useTime(v3 > 0)
	local tryPurchasesByActivated = {
		Text = React.useMemo(function()
			if v3 <= 0 then
				return nil
			end

			return (`{TimeUtil.format(v3, "short")}`)
		end, { v7, data.CooldownTimeEnds }) or formatted
	}
	local textLabelSize

	if v6 then
		textLabelSize = UDim2.fromScale(0.8, 0.7)
	end

	tryPurchasesByActivated.TextLabelSize = textLabelSize
	local anchorPoint

	if data.BannerItem then
		anchorPoint = Vector2.new(1, 0.5)
	else
		anchorPoint = Vector2.new(0.5, 0.5)
	end

	tryPurchasesByActivated.AnchorPoint = anchorPoint
	local position

	if data.BannerItem then
		position = UDim2.fromScale(0.985, 0.5)
	else
		position = UDim2.fromScale(0.5, 0.5)
	end

	tryPurchasesByActivated.Position = position
	tryPurchasesByActivated.Size = UDim2.fromScale(0.25924, 0.7)
	tryPurchasesByActivated.ZIndex = 10
	tryPurchasesByActivated.Sprite = React.useMemo(function()
		local v14 = not v6 and v5 and ItemConfig.tryGet(data.Cost.Name, "Material")

		if v14 then
			return v14.Display.Sprite
		end

		return nil
	end, { data.Cost })
	tryPurchasesByActivated.Variant = v6 and "Red" or data.CanPurchase == false and "Grey" or v4 and "Green" or "Yellow"
	tryPurchasesByActivated[React.Event.Activated] = data.TryPurchase
	return createElement(SimpleButton, tryPurchasesByActivated)
end

return function(props)
	local children = {
		Notification = createElement(Notification, {
			Notification = props.Notification,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 1.07),
			Size = UDim2.fromScale(0.871, 0.0726),
			ZIndex = CONSTANTS.LAYER.RAISED
		}),
		BackgroundSound = createElement(BackgroundSound, {
			IsEnabled = props.IsOpen,
			SoundSettings = {}
		}),
		UISizeConstraint = createElement("UISizeConstraint", {
			MaxSize = Vector2.new(650, 650)
		}),
		Main = 0,
		UICorner = 0,
		UIStroke = 0,
		Title = 0,
		UIAspectRatioConstraint = 0
	}
	local v5 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0, 0.11846),
		Size = UDim2.fromScale(1, 0.88154),
		ZIndex = CONSTANTS.LAYER.RAISED
	}
	local v9 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.5, 0.423088),
		Size = UDim2.fromScale(1, 0.744718)
	}
	local bannerItem2

	if props.BannerItem ~= nil then
		bannerItem2 = createElement(bannerItem, {
			BannerItem = props.BannerItem
		})
	end

	children.Main = createElement("Frame", v5, {
		Content = createElement("Frame", v9, {
			BannerItem = bannerItem2,
			ColorFade = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://78338442764743",
				ImageTransparency = 0.67,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				ZIndex = -999
			}),
			Mythical = createElement(FruitIcon, {
				Rarity = "Mythical",
				Float = {
					Position = UDim2.fromScale(0.481982, 0.472973),
					Enabled = true
				},
				Shake = {
					Enabled = props.BannerItem == nil
				},
				Sparkle = {
					Enabled = props.BannerItem == nil
				},
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.861899, 0.50476),
				Size = UDim2.fromScale(0.333436, 0.964046),
				ZIndex = CONSTANTS.LAYER.OVERLAY
			}),
			Legendary = createElement(FruitIcon, {
				Rarity = "Legendary",
				Float = {
					Position = UDim2.fromScale(0.47, 0.472973),
					Speed = 0.25,
					Enabled = props.BannerItem == nil
				},
				Breathe = {
					Enabled = props.BannerItem ~= nil
				},
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.62, props.BannerItem and 0.57 or 0.5),
				Size = UDim2.fromScale(0.278387, 0.804888),
				ZIndex = 4
			}),
			Rare = createElement(FruitIcon, {
				Rarity = "Rare",
				Breathe = {
					Enabled = props.BannerItem == nil
				},
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.414, props.BannerItem and 0.61 or 0.5),
				Size = UDim2.fromScale(0.235921, 0.682108),
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			}),
			Uncommon = createElement(FruitIcon, {
				Rarity = "Uncommon",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.237, props.BannerItem and 0.63 or 0.5),
				Size = UDim2.fromScale(0.198174, 0.572971),
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			}),
			Common = createElement(FruitIcon, {
				Rarity = "Common",
				CrossOut = props.CommonsCrossedOut,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.079, props.BannerItem and 0.63 or 0.5),
				Size = UDim2.fromScale(0.177727, 0.513855),
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			}),
			PatternFade = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://81943835360193",
				ImageTransparency = 0.67,
				Position = UDim2.fromScale(0.5, 0.5),
				ScaleType = Enum.ScaleType.Crop,
				Size = UDim2.fromScale(1, 1),
				ZIndex = -999
			})
		}),
		Footer = createElement("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
			LayoutOrder = 2,
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(1, 0.204554)
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
			}),
			PurchaseButton = createElement(purchaseButton, props),
			Warning = createElement("Frame", {
				Visible = props.BannerItem ~= nil,
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(0.02, 0.51),
				Size = UDim2.fromScale(0.577678, 0.407766)
			}, {
				Icon = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Image = "rbxassetid://107002449361881",
					ImageTransparency = CONSTANTS.ALPHA.LIGHT,
					Position = UDim2.fromScale(0, 0.5),
					Size = UDim2.fromScale(0.0639386, 1)
				}, {
					UIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
				}),
				TextLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					Position = UDim2.fromScale(0.610649, 0.5),
					RichText = true,
					Size = UDim2.fromScale(1.06401, 1),
					Text = React.useMemo(function()
						if props.BannerItem then
							return (`<b><font color="#3ce63f">{props.BannerItem.Title:gsub("<", "&lt;"):gsub(">", "&gt;")}</font></b>`)
						end

						return ""
					end, { props.BannerItem }),
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left
				}),
				UIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0.015, 0),
					SortOrder = Enum.SortOrder.LayoutOrder
				})
			})
		})
	})
	children.UICorner = createElement("UICorner", {
		CornerRadius = UDim.new(0.02, 0)
	})
	children.UIStroke = createElement("UIStroke", {
		Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
	})
	children.Title = createElement("Frame", {
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		Size = UDim2.fromScale(1, 0.16318)
	}, {
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
		}),
		UIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		TextLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			Position = UDim2.fromScale(0.5, 0.55),
			Size = UDim2.fromScale(0.8, 0.75),
			Text = "Zioles' Gacha Box",
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true
		}, {
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
			}),
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.45),
				Size = UDim2.fromScale(1, 1),
				Text = "Zioles' Gacha Box",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
				})
			})
		}),
		Close = createElement(closeButton, props),
		UIGradient = createElement("UIGradient", {
			Color = colorSequence
		})
	})
	children.UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
		AspectRatio = 2
	})
	local ref = React.useRef(nil)
	React.useEffect(function()
		local v11 = nil
		local current = ref.current

		if current then
			if props.NoTween then
				if props.IsOpen then
					current.Position = uDim
				else
					current.Position = uDim2
				end

				if not props.IsOpen then
					props.OnCloseFinished()
				end
			elseif props.IsOpen then
				v11 = TweenService:Create(current, tweenInfo, {
					Position = uDim
				})
			else
				v11 = TweenService:Create(current, tweenInfo2, {
					Position = uDim2
				})
			end
		end

		if v11 then
			v11:Play()

			if not props.IsOpen then
				v11.Completed:Once(function(p)
					if p == Enum.PlaybackState.Completed then
						props.OnCloseFinished()
					end
				end)
			end
		end

		return function()
			if v11 then
				v11:Destroy()
			end
		end
	end, { props.IsOpen, ref.current })
	return createElement("Frame", RobloxTypes.mergeFrame({
		ref = ref,
		BackgroundColor3 = color3,
		BackgroundTransparency = 0.04
	}, props), children)
end