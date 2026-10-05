local React = require(game.ReplicatedStorage.Packages.React)
local MaterialIconsHD = require(game.ReplicatedStorage.Packages.MaterialIconsHD)
local TableUtil = require(game.ReplicatedStorage.Packages.TableUtil)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local TimeUtil = require(game.ReplicatedStorage.Modules.Util.TimeUtil)
local IdMap = require(game.ReplicatedStorage.IdMap)
local SpriteMap = require(game.ReplicatedStorage.SpriteMap)
local EventConfig = require(game.ReplicatedStorage.EventConfig)
local Notification = require(game.ReplicatedStorage.React.Components.Gacha.Notification)
local FreeToPlay = require(game.ReplicatedStorage.React.Components.Gacha.ChromaticBanner.FreeToPlay)
local SimpleButton = require(game.ReplicatedStorage.React.Components.Gacha.Buttons.SimpleButton)
local Sunburst = require(game.ReplicatedStorage.React.Components.Gacha.Sunburst)
local useTime = require(game.ReplicatedStorage.React.Hooks.Animation.useTime)
local usePityTrack = require(game.ReplicatedStorage.React.Hooks.Gacha.usePityTrack)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(game.ReplicatedStorage.Modules.Gacha.SharedGachaTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local NO_MORE_GAMEPLAY_AT = EventConfig.MagnetEvent26.NO_MORE_GAMEPLAY_AT
local sharkCape = IdMap.Accessory["Shark Cape"]
local coralCrown = IdMap.Accessory["Coral Crown"]
local beach = IdMap.ProfileBackground.Beach
local doge = IdMap.ProfileFullArt.Doge
local color = Color3.fromRGB(0, 102, 145)
local color2 = Color3.new(255, 136, 0)
local color3 = Color3.fromRGB(215, 56, 59)
local vector = Vector2.new(256, 256)
local color4 = Color3.fromRGB(21, 21, 21)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.HEADER.BACKGROUND),
	ColorSequenceKeypoint.new(0.509499, CONSTANTS.COLOR.PALETTE.GOLD_450),
	ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.HEADER.BACKGROUND)
})
local v = {
	[sharkCape] = {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.7, 0.0120391),
		Rotation = 6,
		Size = UDim2.fromScale(0.514877, 0.799317),
		SunburstColor = color,
		Pity = {
			Rotation = -6
		}
	},
	[coralCrown] = {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.3, -0.0285488),
		Rotation = -6,
		Size = UDim2.fromScale(0.579457, 0.858327),
		SunburstColor = color,
		Pity = {
			Rotation = 6
		}
	},
	[beach] = {
		AnchorPoint = Vector2.new(0, 0),
		Position = UDim2.fromScale(0.049, 0.0503487),
		Rotation = -6,
		Size = UDim2.fromScale(0.414218, 0.725645),
		SunburstColor = color2,
		Pity = {
			Rotation = 6
		}
	},
	[doge] = {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0.064),
		Size = UDim2.fromScale(0.490657, 0.725645),
		SunburstColor = color2,
		Rotation = 0,
		Pity = {
			Rotation = 0
		}
	}
}
local createElement = React.createElement

function physicalFruits()
	return createElement("Frame", {
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.INK_900,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		Size = UDim2.fromScale(1, 1),
		ZIndex = CONSTANTS.LAYER.RAISED
	}, {
		ColorFade = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://133214984493997",
			ImageTransparency = 0.67,
			Position = UDim2.fromScale(0.5, 0.420204),
			Size = UDim2.fromScale(1, 0.840407),
			ZIndex = -999
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.SM
			})
		}),
		Frame = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.550000012),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1)
		}, {
			Common = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://122671367010704",
				ImageRectOffset = Vector2.new(256, 512),
				ImageRectSize = vector,
				LayoutOrder = 1,
				Position = UDim2.fromScale(0.0592174, 0.389204),
				Size = UDim2.fromScale(0.118473, 0.494708)
			}, {
				Cross = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Image = "rbxassetid://89565017712105",
					Position = UDim2.fromScale(0.453838, 0.534595),
					Size = UDim2.fromScale(0.8, 0.8)
				}),
				UIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
			}),
			Uncommon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://122671367010704",
				ImageRectOffset = Vector2.new(0, 512),
				ImageRectSize = vector,
				LayoutOrder = 2,
				Position = UDim2.fromScale(0.168042, 0.388953),
				Size = UDim2.fromScale(0.133809, 0.574385)
			}, {
				UIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
			}),
			Legendary = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://122671367010704",
				ImageRectOffset = Vector2.new(256, 256),
				ImageRectSize = vector,
				LayoutOrder = 3,
				Position = UDim2.fromScale(0.300922, 0.388952),
				Size = UDim2.fromScale(0.15248, 0.648499)
			}, {
				UIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
			}),
			Rare = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://122671367010704",
				ImageRectOffset = Vector2.new(0, 256),
				ImageRectSize = vector,
				LayoutOrder = 4,
				Position = UDim2.fromScale(0.455516, 0.382275),
				Size = UDim2.fromScale(0.162563, 0.729155)
			}, {
				UIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
			}),
			Mythical = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				LayoutOrder = 5,
				Position = UDim2.fromScale(0.638447, 0.419516),
				Size = UDim2.fromScale(0.253168, 0.979374),
				ZIndex = CONSTANTS.LAYER.OVERLAY
			}, {
				FruitIcon = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Image = "rbxassetid://122671367010704",
					ImageRectOffset = Vector2.new(256, 0),
					ImageRectSize = vector,
					Position = UDim2.fromScale(0.479154, 0.473009),
					Size = UDim2.fromScale(0.838686, 0.910475)
				}),
				UIAspectRatioConstraint = createElement("UIAspectRatioConstraint"),
				Sunburst1 = createElement(Sunburst, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					ImageColor3 = color3,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1.5, 1.5),
					ZIndex = CONSTANTS.LAYER.BASE
				})
			}),
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				Padding = CONSTANTS.SPACING.PADDING.SCALE.SM,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			})
		}),
		TextLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			Position = UDim2.fromScale(0.5, 0.96),
			Size = UDim2.fromScale(0.973, 0.15),
			Text = "Any Physical Fruit",
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			ZIndex = 10
		}, {
			UIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 29)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 238, 59)),
					ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.HEADER.BACKGROUND)
				})
			}),
			UIStroke = createElement("UIStroke")
		}),
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.SM
		}),
		UIStroke = createElement("UIStroke")
	})
end

function timerTextLabel()
	local v2 = NO_MORE_GAMEPLAY_AT:ToDateTimeUTC().UnixTimestamp - DateTime.now().UnixTimestamp
	local v3 = { (useTime(v2 > 0)) }
	local text = React.useMemo(function()
		if v2 <= 0 then
			return "Event has Ended"
		end

		return TimeUtil.format(v2, "short")
	end, v3)
	return createElement("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.DISPLAY,
		Position = UDim2.fromScale(0.5, 0.55),
		Size = UDim2.fromScale(0.95, 0.8),
		Text = text,
		ZIndex = CONSTANTS.LAYER.RAISED,
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
			Position = UDim2.fromScale(0.5, 0.425),
			Size = UDim2.fromScale(1, 1),
			Text = text,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true
		}, {
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
			})
		})
	})
end

function pityRewards()
	local v2 = usePityTrack("MagnetEventGacha26")
	local v3 = React.useMemo(function()
		local copy = TableUtil.deepCopy(v2.Items)
		copy[#copy + 1] = {
			Index = #copy + 1,
			Chance = 0,
			ItemId = doge,
			Pity = 0,
			RollGuarantee = 0,
			IsNextItem = false,
			IsPastItem = false
		}
		local result = {}

		for k, entry in pairs(copy) do
			local unwrapped = ItemConfig.match(entry.ItemId):unwrap()
			local sprite = unwrapped.Display and unwrapped.Display.Sprite or MaterialIconsHD.broken_image
			local formatted = `{math.min(entry.Pity, entry.RollGuarantee)}/{entry.RollGuarantee}`
			local mysteryItem = k == #copy

			if mysteryItem then
				sprite = SpriteMap.All["Hidden Profile Background"]
			end

			table.insert(result, {
				Index = k,
				ItemId = unwrapped.Index.ItemId,
				Entry = entry,
				Sprite = sprite,
				Text = formatted,
				MysteryItem = mysteryItem,
				Layout = v[unwrapped.Index.ItemId]
			})
		end

		return result
	end, { v2 })
	local v4 = {}

	for _, v5 in pairs(v3) do
		local index = v5.Index
		local entry = v5.Entry
		local sprite = v5.Sprite
		local text = v5.Text
		local mysteryItem = v5.MysteryItem
		local layout = v5.Layout
		local formatted = `{v5.ItemId}`
		local v8 = {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = layout.Position,
			Rotation = layout.Rotation,
			AnchorPoint = layout.AnchorPoint,
			Size = layout.Size,
			LayoutOrder = entry.RollGuarantee
		}
		local v12 = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			ImageColor3 = layout.SunburstColor,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = 0,
			ZIndex = 0
		}
		local size

		if index <= 3 then
			size = UDim2.fromScale(1, 1)
		else
			size = UDim2.fromScale(1.5, 1.5)
		end

		v12.Size = size
		v12.ZIndex = CONSTANTS.LAYER.BASE
		local v9 = {
			Sunburst1 = createElement(Sunburst, v12),
			ImageLabel = 0
		}
		local v16 = {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = sprite.Image,
			ImageRectOffset = sprite.ImageRectOffset,
			ImageRectSize = sprite.ImageRectSize,
			Size = UDim2.fromScale(1, 1),
			ScaleType = Enum.ScaleType.Fit
		}
		local secret

		if mysteryItem then
			secret = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(1, 1),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://75123115585160",
				ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				Position = UDim2.fromScale(1.10635, 1),
				Size = UDim2.fromScale(0.848709, 0.322527),
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				TextLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = Font.new(
						CONSTANTS.FONT.FAMILY.HIGHWAY_GOTHIC,
						Enum.FontWeight.Bold,
						Enum.FontStyle.Italic
					),
					Position = UDim2.fromScale(0.507447, 0.502673),
					RichText = true,
					Size = UDim2.fromScale(1, 0.7),
					Text = "SECRET!",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true
				}, {
					UIStroke = createElement("UIStroke", {
						Thickness = 0.06,
						StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
					})
				}),
				BrushStroke = createElement("ImageLabel", {
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Image = "rbxassetid://75123115585160",
					Position = UDim2.fromScale(-0.00208472, 0.0757617),
					Size = UDim2.fromScale(1.002, 0.8),
					ZIndex = -9999
				}, {
					UIGradient = createElement("UIGradient", {
						Color = colorSequence
					})
				})
			})
		end

		v9.ImageLabel = createElement("ImageLabel", v16, {
			Secret = secret,
			Pity = createElement("Frame", {
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BackgroundTransparency = 0.3,
				BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(index == 4 and 0.95 or 0.8, index == 4 and 1.05 or 1),
				AnchorPoint = Vector2.new(1, 1),
				Size = UDim2.fromScale(0.5, 0.22),
				ZIndex = 999,
				Rotation = layout.Pity.Rotation,
				Visible = mysteryItem == false
			}, {
				UIGradient = createElement("UIGradient", {
					Rotation = 180,
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 0),
						NumberSequenceKeypoint.new(0.561644, 0),
						NumberSequenceKeypoint.new(1, 1)
					})
				}),
				TextLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY,
					Position = UDim2.fromScale(0.9, 0.5),
					Size = UDim2.fromScale(1, 0.9),
					Text = text,
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Right
				}, {
					UIStroke = createElement("UIStroke")
				})
			})
		})
		v4[formatted] = createElement("Frame", v8, v9)
	end

	local element = createElement("Frame", {
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.INK_900,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		Position = UDim2.fromScale(0, 0.0027863),
		Size = UDim2.fromScale(0.58, 1)
	}, {
		Card1 = v4[`{sharkCape}`],
		Card2 = v4[`{coralCrown}`],
		ColorFade = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(0, 200, 255),
			BackgroundTransparency = CONSTANTS.ALPHA.HEAVY,
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(1, 0.873572),
			ZIndex = -999
		}, {
			UIGradient = createElement("UIGradient", {
				Rotation = 90,
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(
						1,
						1
					) })
			}),
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0.04, 0)
			})
		}),
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0.04, 0)
		}),
		UIStroke = createElement("UIStroke", {
			Thickness = 0.014,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
		}),
		TextLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = UDim2.fromScale(0.5, 0.97),
			Size = UDim2.fromScale(0.973, 0.18),
			Text = "Summer Accessories",
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			ZIndex = 10
		}, {
			UIStroke = createElement("UIStroke")
		})
	})
	local element2 = createElement("Frame", {
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.INK_900,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		Position = UDim2.fromScale(0.600734, 0.00299992),
		Size = UDim2.fromScale(0.399266, 1)
	}, {
		Card3 = v4[`{beach}`],
		Card4 = v4[`{doge}`],
		ColorFade = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(255, 136, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.HEAVY,
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(1, 0.873572),
			ZIndex = -999
		}, {
			UIGradient = createElement("UIGradient", {
				Rotation = 90,
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(
						1,
						1
					) })
			}),
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0.04, 0)
			})
		}),
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0.04, 0)
		}),
		UIStroke = createElement("UIStroke", {
			Thickness = 0.014,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
		}),
		TextLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = UDim2.fromScale(0.5, 0.97),
			Size = UDim2.fromScale(0.973, 0.18),
			Text = "Profile Backgrounds",
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			ZIndex = 10
		}, {
			UIStroke = createElement("UIStroke")
		})
	})
	return createElement("Frame", {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0, 0.721029),
		Size = UDim2.fromScale(1, 0.285),
		LayoutOrder = 3
	}, {
		Accessories = element,
		ProfileBackgrounds = element2
	})
end

function mainGachaUI(props)
	local ref = React.useRef(nil)
	React.useEffect(function()
		if ref.current and props.PreviewFrameEffect then
			return props.PreviewFrameEffect(IdMap.PhysicalMoveset["Arcsteel Magnet"], ref.current)
		end
	end, { ref.current })
	return createElement("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = color4,
		BackgroundTransparency = 0.04,
		Position = UDim2.fromScale(0.019, 0.5),
		Size = UDim2.fromScale(0.460047, 0.896638),
		ZIndex = CONSTANTS.LAYER.RAISED
	}, {
		Main = createElement("Frame", {
			ref = ref,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0, 0.11846),
			Size = UDim2.fromScale(1, 0.88154),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			Body = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(0.5, 0.432151),
				Size = UDim2.fromScale(1, 0.915223)
			}, {
				ColorFade = createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(0, 166, 255),
					BackgroundTransparency = 0.85,
					BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
					Position = UDim2.fromScale(0.5, 0.778319),
					Size = UDim2.fromScale(1, 0.477897),
					ZIndex = -999
				}, {
					UIGradient = createElement("UIGradient", {
						Rotation = -90,
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(1, 1)
						})
					})
				}),
				Content = createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Position = UDim2.fromScale(0.5, 0.495536),
					Size = UDim2.fromScale(0.96, 0.964824),
					ZIndex = CONSTANTS.LAYER.RAISED
				}, {
					UIListLayout = createElement("UIListLayout", {
						Padding = UDim.new(0.025, 0),
						SortOrder = Enum.SortOrder.LayoutOrder
					}),
					ChromaticBanner = createElement("Frame", {
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						Size = UDim2.fromScale(1, 0.375),
						ZIndex = CONSTANTS.LAYER.RAISED,
						LayoutOrder = 1
					}, {
						Component = createElement(FreeToPlay, {
							AnchorPoint = Vector2.new(0.5, 0.5),
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(1, 1),
							BoxName = "PremiumChromaticMagnetGacha26",
							OnItemSelected = props.OpenGacha and function()
								props.OpenGacha("PremiumChromaticMagnetGacha26")
							end or nil
						})
					}),
					PhysicalFruit = createElement("Frame", {
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						Position = UDim2.fromScale(0, 0.368918),
						Size = UDim2.fromScale(1, 0.306462),
						ZIndex = CONSTANTS.LAYER.RAISED,
						LayoutOrder = 2
					}, {
						Component = createElement(physicalFruits)
					}),
					PityRewards = createElement(pityRewards)
				})
			}),
			Footer = createElement("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BackgroundTransparency = CONSTANTS.ALPHA.OPAQUE,
				LayoutOrder = 2,
				Position = UDim2.fromScale(0, 0.999762),
				Size = UDim2.fromScale(1, 0.11),
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				UICorner = createElement("UICorner", {
					CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
				}),
				PurchaseButton = createElement(SimpleButton, {
					[React.Event.Activated] = props.TryPurchase,
					Variant = props.CanPurchase and "Yellow" or "Grey",
					Text = `{props.Cost.Formatted}`,
					TextLabelSize = UDim2.fromScale(0.7, 0.8),
					Position = UDim2.fromScale(0.985, 0.499998),
					Size = UDim2.fromScale(0.479765, 0.7),
					AnchorPoint = Vector2.new(1, 0.5),
					ZIndex = 10,
					Sprite = React.useMemo(function()
						local v12 = ItemConfig.tryGet(props.Cost.Name, "Material")

						if v12 then
							return v12.Display.Sprite
						end

						return nil
					end, { props.Cost })
				}),
				Timer = createElement("Frame", {
					Active = true,
					AnchorPoint = Vector2.new(1, 0.5),
					BackgroundColor3 = CONSTANTS.COLOR.DANGER.BACKGROUND,
					LayoutOrder = 2,
					Position = UDim2.fromScale(0.369776, 0.5),
					Selectable = true,
					Size = UDim2.fromScale(0.354, 0.68),
					ZIndex = CONSTANTS.LAYER.RAISED
				}, {
					Trans = createElement("Frame", {
						AnchorPoint = Vector2.new(0.5, 1),
						BackgroundColor3 = CONSTANTS.COLOR.DANGER.HIGHLIGHT,
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.98, 0.45)
					}, {
						UICorner = createElement("UICorner", {
							CornerRadius = UDim.new(0.3, 0)
						})
					}),
					TextLabel = createElement(timerTextLabel),
					UICorner = createElement("UICorner", {
						CornerRadius = UDim.new(0.15, 0)
					}),
					UIStroke = createElement("UIStroke", {
						ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
						Thickness = 1.2
					})
				})
			})
		}),
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0.02, 0)
		}),
		UIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		Title = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			Size = UDim2.fromScale(1, 0.0887951)
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
				Size = UDim2.fromScale(0.9, 0.8),
				Text = "🌊 Summer Magnet Gacha 🏖",
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
					Text = "Summer Magnet Gacha",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true
				}, {
					UIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
					})
				})
			}),
			UIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 162, 0)),
					ColorSequenceKeypoint.new(0.355786, Color3.fromRGB(255, 255, 32)),
					ColorSequenceKeypoint.new(0.658031, Color3.fromRGB(28, 225, 255)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 123, 255))
				})
			})
		}),
		UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 0.913
		})
	})
end

function closeButton(p)
	return createElement("ImageButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.DANGER.BACKGROUND,
		LayoutOrder = 2,
		Position = UDim2.fromScale(0.98, 0.101695),
		Size = UDim2.fromScale(0.102332, 0.0662548),
		ZIndex = CONSTANTS.LAYER.RAISED,
		[React.Event.Activated] = p.OnClose
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
				Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
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
					Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
				})
			})
		}),
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new()
		}),
		UIStroke = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = CONSTANTS.COLOR.DANGER.BORDER,
			Thickness = 1.2
		})
	})
end

return function(p)
	return createElement("Frame", RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, p), {
		MainGachaUI = createElement(mainGachaUI, p),
		Close = createElement(closeButton, p),
		Notification = createElement(Notification, {
			Notification = p.Notification,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.65, 0.95),
			Size = UDim2.fromScale(0.5, 0.05),
			ZIndex = CONSTANTS.LAYER.RAISED
		})
	})
end