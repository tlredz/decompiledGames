local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local React = require(game.ReplicatedStorage.Packages.React)
local MaterialIconsHD = require(game.ReplicatedStorage.Packages.MaterialIconsHD)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Config = require(game.ReplicatedStorage.React.Components.Gacha.SceneEffect.Config)
local MathUtil = require(game.ReplicatedStorage.Modules.Util.MathUtil)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
require(game.ReplicatedStorage.React.Components.Gacha.ChromaticBanner.ChromaticTile)
local PurchaseButtons = require(game.ReplicatedStorage.React.Components.Gacha.PurchaseButtons)
local AnimatedTile = require(game.ReplicatedStorage.React.Components.Gacha.AnimatedTile)
local usePityTrack = require(game.ReplicatedStorage.React.Hooks.Gacha.usePityTrack)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local uDim = UDim2.fromScale(0, 0)
local uDim2 = UDim2.fromScale(0.1, 0)
local uDim3 = UDim2.fromScale(0.015, 0)
local uDim4 = UDim2.fromScale(0.875, 0.875)
local uDim5 = UDim2.fromScale(0.95, 0.95)
local tweenInfo = TweenInfo.new(0.2)
local tweenInfo2 = TweenInfo.new(0.1)
local tweenInfo3 = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local color = Color3.fromRGB(173, 173, 173)
local color2 = Color3.fromRGB(33, 33, 33)
local color3 = Color3.fromRGB(61, 61, 61)
local color4 = Color3.fromRGB(255, 219, 77)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.PALETTE.BLACK),
	ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.PALETTE.BLACK)
})
local createElement = React.createElement

function tileComponent(p)
	local v = assert(useMatch(p.Item.ItemId))
	local formatted = `{tostring(MathUtil.round(p.Item.Chance * 100, 1))}%`
	local v2 = math.min(p.Item.Pity, p.Item.RollGuarantee)
	local rollGuarantee = p.Item.RollGuarantee
	local visible = p.Item.IsPastItem == false
	local isNextItem = p.Item.IsNextItem
	local v4 = Config[p.Item.ItemId]
	local title = v.Display.Title or v.Display.Name or v.Index.StorageKey
	local v5

	if v4 then
		v5 = ItemConfig.match(v4.PhysicalMovesetItemId):unwrap()
	end

	local text = not v5 and "???" or v5.Display.Title or v5.Display.Name or v5.Index.StorageKey
	local sprite = v and v.Display and v.Display.Sprite or MaterialIconsHD.broken_image
	local color5 = RarityUtil.matchRarity(v.Quality.Rarity or "Common"):unwrap().Color
	local state, setState = React.useState(false)
	local text2 = assert(title:match("^(%S+)"))
	local v8 = p.Item.Index < 5 and 1 or 1.124
	local v9 = p.Item.Index < 5 and 0.104 or 0.117
	local colorSequence2 = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color5),
		ColorSequenceKeypoint.new(1, color5)
	})
	local ref = React.useRef(nil)
	local ref2 = React.useRef(0)
	React.useEffect(function()
		local heartbeatConnection

		if colorSequence2 and ref.current then
			heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
				ref2.current += dt * 150
				ref.current.Rotation = ref2.current
			end)
		else
			heartbeatConnection = nil
		end

		return function()
			if heartbeatConnection then
				heartbeatConnection:Disconnect()
			end
		end
	end, { colorSequence2, ref.current })
	local ref3 = React.useRef(nil)
	local v10 = React.useMemo(function()
		local v11 = {
			Shake = {
				Enabled = p.Item.IsNextItem == true
			},
			Resize = 0,
			AnchorPoint = 0,
			Image = 0,
			ImageRectOffset = 0,
			ImageRectSize = 0,
			Position = 0,
			ScaleType = 0,
			Size = 0
		}
		local size

		if state then
			size = uDim5
		else
			size = uDim4
		end

		v11.Resize = {
			Size = size,
			TweenInfo = tweenInfo
		}
		v11.AnchorPoint = Vector2.new(0.5, 0.5)
		v11.Image = sprite.Image
		v11.ImageRectOffset = sprite.ImageRectOffset
		v11.ImageRectSize = sprite.ImageRectSize
		v11.Position = UDim2.fromScale(0.5, 0.5)
		v11.ScaleType = Enum.ScaleType.Fit
		v11.Size = uDim4
		return v11
	end, { state, isNextItem, sprite })
	local v11 = 1 - p.Item.Index / 7
	local ref4 = React.useRef(tick() + 1)
	local state2, setState2 = React.useState(false)
	React.useEffect(function()
		local thread = task.spawn(function()
			while state2 == false do
				if tick() >= ref4.current then
					setState2(true)
					break
				else
					task.wait()
				end
			end
		end)
		return function()
			task.cancel(thread)
		end
	end, { state2 })
	React.useEffect(function()
		local v12 = nil

		if ref3.current then
			if state2 then
				if state2 and isNextItem == false then
					local current = ref3.current
					local position

					if state then
						position = uDim3
					else
						position = uDim
					end

					v12 = TweenService:Create(current, tweenInfo2, {
						Position = position
					})
					v12:Play()
				end
			else
				v12 = TweenService:Create(ref3.current, TweenInfo.new(v11), {
					Position = uDim
				})
				v12:Play()
			end
		end

		return function()
			if v12 then
				v12:Cancel()
			end
		end
	end, {
		ref3.current,
		state,
		state2,
		isNextItem
	})
	React.useEffect(function()
		local v12

		if isNextItem and ref3.current and state2 then
			if ref3.current.Position ~= uDim then
				ref3.current.Position = uDim
			end

			v12 = TweenService:Create(ref3.current, tweenInfo3, {
				Position = uDim3
			})
			v12:Play()
		else
			v12 = nil
		end

		return function()
			if v12 then
				v12:Cancel()
			end
		end
	end, { ref3.current, state2, isNextItem })
	local v14 = {
		Active = true,
		BackgroundColor3 = color,
		BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		LayoutOrder = p.Item.Index,
		Position = UDim2.fromScale(0, -0.0719297),
		Selectable = false,
		Size = UDim2.fromScale(v8, v9)
	}
	local color6

	if colorSequence2 then
		color6 = v4.BannerColor
	else
		color6 = colorSequence
	end

	local v15 = {
		UIGradient = createElement("UIGradient", {
			Color = color6,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0.2375),
				NumberSequenceKeypoint.new(0.499377, 0.45),
				NumberSequenceKeypoint.new(1, 1)
			})
		}),
		AnimationFrame = 0
	}
	local v22 = {
		ref = ref3,
		Text = "",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		TextScaled = true,
		Position = uDim2,
		[React.Event.Activated] = function()
			p.OnClick(p.Item.ItemId)
		end,
		[React.Event.MouseEnter] = function()
			if state2 and not p.Item.IsNextItem then
				setState(true)
			end
		end,
		[React.Event.MouseLeave] = function()
			if state2 and not p.Item.IsNextItem then
				setState(false)
			end
		end
	}
	local v23 = {
		TextLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.54, 0.2),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromScale(1.2, 0.4),
			Text = "Bonus",
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextYAlignment = Enum.TextYAlignment.Bottom,
			Visible = visible
		}, {
			UIStroke = createElement("UIStroke", {
				Thickness = 0.07,
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
			})
		}),
		SkinName = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			Position = UDim2.fromScale(0.385, 0.703),
			Size = UDim2.fromScale(0.421, 0.566796),
			Text = text2,
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = CONSTANTS.LAYER.BASE
		}, {
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.45),
				Size = UDim2.fromScale(1, 1),
				Text = text2,
				TextColor3 = Color3.fromRGB(254, 254, 254),
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = 0.034,
					StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
				}),
				UIGradient = createElement("UIGradient", {
					Color = v4.HeaderColor
				})
			}),
			UIStroke = createElement("UIStroke", {
				Thickness = 0.034,
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
			})
		}),
		FruitLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = UDim2.fromScale(0.39, 0.25),
			Size = UDim2.fromScale(0.416, 0.37),
			Text = text,
			TextColor3 = Color3.fromRGB(254, 254, 254),
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left
		}, {
			UIStroke = createElement("UIStroke", {
				Thickness = 0.06,
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
			})
		}),
		Button = 0,
		PityCounter = 0
	}
	local v26 = {
		Active = false,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = 0,
		BackgroundTransparency = 0,
		Position = 0,
		Selectable = false,
		Size = 0
	}
	local backgroundColor

	if state then
		backgroundColor = color3
	else
		backgroundColor = color2
	end

	v26.BackgroundColor3 = backgroundColor
	v26.BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE
	v26.Position = UDim2.fromScale(0.0503893, 0.5)
	v26.Size = UDim2.fromScale(0.30272, 1.32796)
	v23.Button = createElement("Frame", v26, {
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0.07, 0)
		}),
		RarityFade = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = color5,
			BackgroundTransparency = CONSTANTS.ALPHA.LIGHT,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
			ZIndex = -999
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0.07, 0)
			}),
			UIGradient = createElement("UIGradient", {
				Rotation = 90,
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(
						1,
						0
					) })
			})
		}),
		UIStroke = createElement("UIStroke", {
			Color = CONSTANTS.COLOR.PALETTE.WHITE,
			Thickness = 0.025,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			UIGradient = createElement("UIGradient", {
				Color = colorSequence2 or colorSequence,
				ref = ref
			})
		}),
		Odds = createElement("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BackgroundTransparency = 0.3,
			BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(-2.02909e-8, 0.98),
			Size = UDim2.fromScale(0.645, 0.3),
			ZIndex = 999
		}, {
			UIGradient = createElement("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.561644, 0),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.BODY_BOLD,
				Position = UDim2.fromScale(0.1, 0.45),
				Size = UDim2.fromScale(0.8, 0.9),
				Text = formatted,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			}, {
				UIStroke = createElement("UIStroke")
			})
		}),
		FruitIcon = createElement(AnimatedTile, v10, {
			UIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
		}),
		UIStroke2 = createElement("UIStroke", {
			Thickness = 0.045,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
		}),
		UIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
	})
	local pityCounter

	if visible == false then
		pityCounter = createElement("TextLabel", {
			Text = "Claimed",
			Size = UDim2.fromScale(0.3, 0.8),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.fromScale(0.9, 0.5),
			TextScaled = true,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			TextColor3 = color4,
			TextXAlignment = Enum.TextXAlignment.Left
		}, {
			UIStroke = createElement("UIStroke", {
				Thickness = 0.05,
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
			})
		})
	else
		pityCounter = createElement("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BackgroundTransparency = CONSTANTS.ALPHA.HALF,
			Position = UDim2.fromScale(0.85, 0.875),
			Size = UDim2.fromScale(v2 < 10 and 0.2 or 0.3, 0.489063)
		}, {
			Amount = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.9, 0.85),
				Text = `{v2}/{rollGuarantee}`,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			}),
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0.15, 0)
			})
		})
	end

	v23.PityCounter = pityCounter
	v15.AnimationFrame = createElement("TextButton", v22, v23)
	return createElement("Frame", v14, v15)
end

function header(p)
	local v = Config[p.Selected.Index.ItemId] or Config[1]
	local title = p.Selected.Display.Title or p.Selected.Display.Name or p.Selected.Index.StorageKey
	local category = p.Selected.Display.Category
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.5, 0.0175),
		Size = UDim2.fromScale(0.409903, 0.117817)
	}, {
		SkinName = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(0.8, 0.672),
			Text = title,
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true,
			ZIndex = CONSTANTS.LAYER.BASE
		}, {
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.45),
				Size = UDim2.fromScale(1, 1),
				Text = title,
				TextColor3 = Color3.fromRGB(254, 254, 254),
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = 0.034,
					StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
				}),
				UIGradient = createElement("UIGradient", {
					Color = v.BannerColor or v.TitleColor
				})
			}),
			UIStroke = createElement("UIStroke", {
				Thickness = 0.034,
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
			})
		}),
		Transformation = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = UDim2.fromScale(0.5, 1.05),
			Size = UDim2.fromScale(0.410372, 0.366379),
			Text = category,
			TextColor3 = Color3.fromRGB(254, 254, 254),
			TextScaled = true
		}, {
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
			})
		})
	})
end

function boxContents(props)
	local v = usePityTrack("PremiumChromaticMagnetGacha26")
	local v2 = React.useMemo(function()
		local result = {}

		for _, item in pairs(v.Items) do
			table.insert(result, {
				Data = item,
				Selected = props.Selected and props.Selected == item.ItemId and true or false
			})
		end

		return result
	end, { v, props.Selected })
	local children = {}

	for _, v3 in pairs(v2) do
		children[`{v3.Data.ItemId}`] = createElement(tileComponent, {
			Item = v3.Data,
			OnClick = props.SelectItem
		})
	end

	React.useEffect(function()
		if props.Visible and props.Selected == nil and v2[1] then
			for _, v3 in pairs(v2) do
				if not v3.Data.IsNextItem then
					continue
				end

				props.SelectItem(v3.Data.ItemId)
				return
			end
		end
	end, { props.Selected, v2, props.Visible })
	return createElement(React.Fragment, {}, children)
end

return function(props)
	React.useEffect(function()
		if props.Selected and props.PreviewFrameEffect then
			print((`preview frame effect:{props.Selected}`))
			return props.PreviewFrameEffect(props.Selected)
		end
	end, { props.Selected })
	local selected = React.useMemo(function()
		if props.Selected == nil then
			return nil
		end

		return (ItemConfig.match(props.Selected):unwrap())
	end, { props.Selected })
	local mergeFrame = RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, props)
	local header2

	if not (selected == nil or props.HeaderHidden == true) then
		header2 = createElement(header, {
			Selected = selected
		})
	end

	return createElement("Frame", mergeFrame, {
		Header = header2,
		CloseButton = createElement("ImageButton", {
			AnchorPoint = Vector2.new(1, 0),
			BackgroundColor3 = CONSTANTS.COLOR.DANGER.BACKGROUND,
			LayoutOrder = 2,
			Position = UDim2.fromScale(0.991722, 0.0156455),
			Size = UDim2.fromScale(0.0850629, 0.0662548),
			ZIndex = CONSTANTS.LAYER.RAISED,
			[React.Event.Activated] = props.OnClose
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new()
			}),
			UIStroke = createElement("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = CONSTANTS.COLOR.DANGER.BORDER,
				Thickness = 0.05,
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
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
						Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
					})
				}),
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
				})
			}),
			Trans = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = CONSTANTS.COLOR.DANGER.HIGHLIGHT,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.98, 0.45)
			})
		}),
		PurchaseButtons = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://106927136793796",
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromScale(1, 0.137723)
		}, {
			Frame = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.4),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.8, 0.5)
			}, {
				UIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = UDim.new(0.015, 0),
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				Buttons = createElement(PurchaseButtons, {
					OnPurchase = props.OnPurchase,
					DiscountBanner = {
						AnchorPoint = Vector2.new(0.11, 0.5),
						Size = UDim2.fromScale(0.3, 0.549358)
					}
				})
			})
		}),
		List = createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0, 0.435396),
			Size = UDim2.fromScale(0.169435, 0.627569)
		}, {
			UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
				AspectRatio = 0.48
			}),
			UIListLayout = createElement("UIListLayout", {
				Padding = UDim.new(0.06, 0),
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			}),
			Items = createElement(React.Fragment, {}, createElement(boxContents, props))
		})
	})
end