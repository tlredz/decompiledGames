local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Button = require(script.Parent.Button)
local StatRow = require(game.ReplicatedStorage.React.Components.Inventory.ItemCard.StatsList.StatRow)
local GlowGradient = require(game.ReplicatedStorage.React.Components.Inventory.ItemCard.Display.GlowGradient)
local useRace = require(game.ReplicatedStorage.React.Hooks.Player.useRace)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local useRaceRerolls = require(game.ReplicatedStorage.React.Hooks.Player.useRaceRerolls)
local useRacialStats = require(game.ReplicatedStorage.React.Hooks.Player.useRacialStats)
require(game.ReplicatedStorage.React.Components.StatsMenu.Types)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	Image = "rbxassetid://127503254560275",
	ImageRectOffset = Vector2.new(300, 0),
	ImageRectSize = Vector2.new(100, 100)
}
local v2 = {
	Image = "rbxassetid://127503254560275",
	ImageRectOffset = Vector2.new(400, 0),
	ImageRectSize = Vector2.new(100, 100)
}
local v3 = { IdMap.Race.Draco, IdMap.Race.Cyborg, IdMap.Race.Ghoul }
local v4 = ItemConfig.Query.select({
	Index = {
		IdType = "Race"
	}
})
local createElement = React.createElement

function changePageButton(p)
	local mergeImageButton = RobloxTypes.mergeImageButton({
		AutoButtonColor = false,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		ImageTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, p)
	local v10 = {
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundColor3 = CONSTANTS.COLOR.SECONDARY.BACKGROUND,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE
	}
	local v11 = {
		Outline = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = CONSTANTS.COLOR.SECONDARY.BORDER,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		InnerButton = 0
	}
	local v14 = {
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = CONSTANTS.COLOR.SECONDARY.HIGHLIGHT,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE
	}
	local v18 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = 0,
		ImageRectOffset = 0,
		ImageRectSize = 0,
		ScaleType = 0,
		Size = 0
	}
	local image

	if p.Direction == "Left" then
		image = v.Image
	else
		image = v2.Image
	end

	v18.Image = image
	local imageRectOffset

	if p.Direction == "Left" then
		imageRectOffset = v.ImageRectOffset
	else
		imageRectOffset = v2.ImageRectOffset
	end

	v18.ImageRectOffset = imageRectOffset
	local imageRectSize

	if p.Direction == "Left" then
		imageRectSize = v.ImageRectSize
	else
		imageRectSize = v2.ImageRectSize
	end

	v18.ImageRectSize = imageRectSize
	v18.ScaleType = Enum.ScaleType.Fit
	v18.Size = UDim2.fromScale(1, 1)
	v11.InnerButton = createElement("Frame", v14, {
		Icon = createElement("ImageLabel", v18, {}),
		UIGradient = createElement("UIGradient", {
			Rotation = 90,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.49, 0),
				NumberSequenceKeypoint.new(0.51, 1),
				NumberSequenceKeypoint.new(1, 1)
			})
		})
	})
	return createElement("ImageButton", mergeImageButton, {
		Content = createElement("Frame", v10, v11)
	})
end

function dot(p)
	return createElement("Frame", RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, p), {
		MarginPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 5),
			PaddingLeft = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5),
			PaddingTop = UDim.new(0, 5)
		}),
		Inner = createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = p.IsSelected and CONSTANTS.COLOR.PRIMARY.BACKGROUND or Color3.fromRGB(158, 158, 158),
			LayoutOrder = 2
		}, {
			Corner = createElement("UICorner", {
				BottomLeftRadius = UDim.new(0.5, 0),
				BottomRightRadius = UDim.new(0.5, 0),
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE,
				TopLeftRadius = UDim.new(0.5, 0),
				TopRightRadius = UDim.new(0.5, 0)
			})
		})
	})
end

function dotRow(p)
	local children = {}

	for k, page in p.Pages do
		children[`Page-{k}`] = createElement(dot, {
			IsSelected = p.CurrentPage == page,
			Size = UDim2.fromScale(0.065, 0.065),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			LayoutOrder = k
		})
	end

	return createElement("Frame", RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, p), {
		Dots = createElement(React.Fragment, {}, children),
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			ItemLineAlignment = Enum.ItemLineAlignment.Stretch,
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	})
end

return function(p)
	local v5 = useRace()
	local v7

	if v5 then
		v7 = v5.ItemId or nil
	end

	local v8 = useMatch(v7)
	local v9 = useRaceRerolls()
	local text = not (v8 and v5 and v5.Level) and "Race" or `Race V{v5.Level}`
	local font = Font.new(CONSTANTS.FONT.FAMILY.HIGHWAY_GOTHIC, Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	local stats = useRacialStats()
	local state, setState = React.useState(nil)
	local children = {}

	for k, statValue in stats do
		children[`stat-effect-{k}`] = createElement(StatRow, {
			Size = UDim2.new(1, 0, 0.15, 0),
			StatValue = statValue,
			LayoutOrder = k,
			SizeConstraint = Enum.SizeConstraint.RelativeXX
		})
	end

	local pages = { "RaceOptions" }

	if #stats > 0 then
		table.insert(pages, 1, "StatEffects")
	end

	if v8 and v8.Display.Description then
		table.insert(pages, 1, "Description")
	end

	local state2, setState2 = React.useState(pages[1])
	local children2 = {}

	for k, v13 in v4 do
		if not (not v5 or v13.Index.ItemId ~= v5.ItemId) or table.find(v3, v13.Index.ItemId) then
			continue
		end

		children2[`RaceOption-{k}`] = createElement("Frame", RobloxTypes.mergeFrame({
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BackgroundTransparency = CONSTANTS.ALPHA.LIGHT,
			BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			LayoutOrder = k,
			Size = UDim2.fromScale(1, 0.3)
		}, p), {
			UIGradient = createElement("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.298879, 0.24375),
					NumberSequenceKeypoint.new(0.500623, 0.075),
					NumberSequenceKeypoint.new(0.699875, 0.2375),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			UIListLayout = createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = UDim.new(0.025, 0)
			}),
			Label = createElement("TextLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Size = UDim2.fromScale(0, 0.65),
				AutomaticSize = Enum.AutomaticSize.X,
				Text = `{v13.Display.Name or v13.Index.StorageKey} - {math.round(100 / (#v4 - #v3 - (v5 and table.find(v3, v5.ItemId) and 0 or 1)))}%`,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextStrokeTransparency = CONSTANTS.ALPHA.MID,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextYAlignment = Enum.TextYAlignment.Center,
				LayoutOrder = 1,
				ZIndex = CONSTANTS.LAYER.OVERLAY
			}),
			Icon = v13.Display.Sprite and createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = v13.Display.Sprite.Image,
				ImageRectOffset = v13.Display.Sprite.ImageRectOffset,
				ImageRectSize = v13.Display.Sprite.ImageRectSize,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(1, 1),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				LayoutOrder = 0
			}) or nil
		})
	end

	local mergeFrame = RobloxTypes.mergeFrame({
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE
	}, p)
	local v15 = {
		UIStroke = createElement("UIStroke", {
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Thickness = 0.008
		}),
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XS
		}),
		ItemDisplay = 0,
		Title = 0,
		Body = 0,
		LeftButton = 0,
		RightButton = 0
	}
	local v18 = {
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		ClipsDescendants = true,
		Position = UDim2.fromScale(0, 0),
		Size = UDim2.fromScale(1, 0.337)
	}
	local itemImage

	if v8 and v8.Display.Sprite then
		itemImage = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = v8.Display.Sprite.Image,
			ImageRectOffset = v8.Display.Sprite.ImageRectOffset,
			ImageRectSize = v8.Display.Sprite.ImageRectSize,
			ScaleType = Enum.ScaleType.Fit,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.475771, 0.887674)
		}) or nil
	end

	v15.ItemDisplay = createElement("Frame", v18, {
		ItemImage = itemImage,
		RarityFadeBackdrop = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ScaleType = Enum.ScaleType.Stretch,
			Image = "http://www.roblox.com/asset/?id=14514122503",
			ImageRectSize = Vector2.new(0, 0),
			ImageRectOffset = Vector2.new(0, 0),
			ImageColor3 = v8 and v8.Display.BackgroundColor or Color3.fromRGB(255, 217, 65),
			Position = UDim2.fromScale(0.5, 1.03981),
			Size = UDim2.fromScale(1.06921, 1.05636),
			ZIndex = CONSTANTS.LAYER.BASE
		}, {
			GlowGradient = createElement(GlowGradient, {})
		}),
		Type = text and createElement("TextLabel", {
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = Font.new(CONSTANTS.FONT.FAMILY.HIGHWAY_GOTHIC),
			Position = UDim2.fromScale(0.964581, 0.954084),
			Size = UDim2.fromScale(0.555066, 0.172603),
			Text = text,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			UIStroke = createElement("UIStroke", {
				Thickness = 1.7
			})
		}) or nil
	})
	local v23 = {
		BackgroundColor3 = Color3.fromRGB(77, 77, 77),
		BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(-0.00439431, 0.335294),
		Size = UDim2.fromScale(1.00196, 0.096986)
	}
	local v24 = {
		UIGradient = createElement("UIGradient", {
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.298879, 0.24375),
				NumberSequenceKeypoint.new(0.500623, 0.075),
				NumberSequenceKeypoint.new(0.699875, 0.2375),
				NumberSequenceKeypoint.new(1, 1)
			})
		}),
		ItemName = 0
	}
	local itemName

	if v8 then
		itemName = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = font,
			Position = UDim2.fromScale(0.5, 0.565),
			Size = UDim2.fromScale(0.9, 0.75),
			Text = v8.Display.Name or v8.Index.StorageKey,
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true
		}, {
			UIStroke = createElement("UIStroke", {
				Thickness = 1.7
			}),
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = font,
				Position = UDim2.fromScale(0.5, 0.44),
				Size = UDim2.fromScale(1, 1),
				Text = v8.Display.Name or v8.Index.StorageKey,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = 1.7
				})
			})
		}) or nil
	end

	v24.ItemName = itemName
	v15.Title = createElement("Frame", v23, v24)
	local v28 = {
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		BackgroundTransparency = 0.999,
		BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 0.45),
		Size = UDim2.fromScale(0.95, 0.545)
	}
	local v29 = {
		UIListLayout = createElement("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			VerticalFlex = Enum.UIFlexAlignment.SpaceBetween,
			FillDirection = Enum.FillDirection.Vertical,
			Padding = UDim.new(0.025, 0)
		}),
		Description = 0,
		Stats = 0,
		Reroll = 0,
		DotRow = 0
	}
	local description

	if state2 == "Description" then
		description = v8 and v8.Display.Description and createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO, Enum.FontWeight.Regular, Enum.FontStyle.Italic),
			Position = UDim2.fromScale(0.5, -0),
			RichText = true,
			Size = UDim2.fromScale(0.87, 0.6769999999999999),
			Text = v8.Display.Description,
			TextColor3 = CONSTANTS.COLOR.PALETTE.GREY_400,
			TextScaled = true,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
			ZIndex = CONSTANTS.LAYER.OVERLAY,
			LayoutOrder = 1
		})
	else
		description = false
	end

	v29.Description = description

	if state2 == "StatEffects" then
		if stats then
			stats = createElement("ScrollingFrame", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(0.5, 0),
				Size = UDim2.fromScale(0.87, 0.85),
				CanvasSize = state and UDim2.fromOffset(0, state) or nil,
				ScrollBarThickness = CONSTANTS.THICKNESS.SCROLLBAR.THICK,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
				LayoutOrder = 1
			}, {
				UIListLayout = createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Top,
					FillDirection = Enum.FillDirection.Vertical,
					Padding = UDim.new(0.025, 0)
				}),
				Container = createElement("Frame", {
					Size = UDim2.fromScale(1, 0),
					AutomaticSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					[React.Change.AbsoluteSize] = function(p2)
						setState(p2.AbsoluteSize.Y)
					end
				}, {
					UIListLayout = createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						VerticalAlignment = Enum.VerticalAlignment.Top,
						FillDirection = Enum.FillDirection.Vertical,
						Padding = UDim.new(0.025, 0)
					}),
					Effects = createElement(React.Fragment, {}, children)
				})
			})
		end
	else
		stats = false
	end

	v29.Stats = stats
	local reroll

	if state2 == "RaceOptions" then
		reroll = createElement(React.Fragment, {}, {
			RateLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
				Size = UDim2.fromScale(0.7, 0.1),
				Text = "Rates",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextYAlignment = Enum.TextYAlignment.Top,
				LayoutOrder = 2
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = 1.7
				})
			}),
			RollOptions = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Size = UDim2.fromScale(0.87, 0),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				AutomaticSize = Enum.AutomaticSize.Y,
				LayoutOrder = 2
			}, {
				UIFlexItem = createElement("UIFlexItem", {
					FlexMode = Enum.UIFlexMode.Fill
				}),
				UIListLayout = createElement("UIListLayout", {
					VerticalAlignment = Enum.VerticalAlignment.Top,
					FillDirection = Enum.FillDirection.Vertical,
					VerticalFlex = Enum.UIFlexAlignment.Fill,
					Padding = CONSTANTS.SPACING.PADDING.SCALE.LG
				}),
				Options = createElement(React.Fragment, {}, children2)
			}),
			RerollsOwned = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = Font.new(CONSTANTS.FONT.FAMILY.HIGHWAY_GOTHIC),
				Size = UDim2.fromScale(0.7, 0.125),
				Text = `Rerolls owned: {v9}`,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextYAlignment = Enum.TextYAlignment.Top,
				ZIndex = CONSTANTS.LAYER.RAISED,
				LayoutOrder = 4
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = 1.7
				})
			}),
			RerollButton = createElement(Button, {
				AnchorPoint = Vector2.new(0.5, 1),
				HighlightVariant = "Centered",
				Label = "Reroll",
				LabelSize = UDim2.fromScale(0.95, 0.8),
				MinSize = Vector2.new(32, 32),
				Size = UDim2.fromOffset(97, 28),
				StrokeThickness = 1.5,
				Variant = "Yellow",
				ZIndex = CONSTANTS.LAYER.RAISED,
				LayoutOrder = 5,
				[React.Event.Activated] = function()
					p.OnAction({
						Type = "Reroll"
					})
				end
			})
		})
	else
		reroll = false
	end

	v29.Reroll = reroll
	v29.DotRow = createElement(dotRow, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(1, 0.125),
		CurrentPage = state2,
		Pages = pages,
		LayoutOrder = 10
	})
	v15.Body = createElement("Frame", v28, v29) or nil
	local leftButton

	if not (state2 == pages[1] or #pages == 1) then
		local changePageButton2 = changePageButton
		leftButton = createElement(changePageButton2, {
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.fromScale(0.1, 0.1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0, 0.6),
			Direction = "Left",
			[React.Event.Activated] = function()
				local index = table.find(pages, state2)

				if index then
					setState2(pages[index - 1])
				end
			end
		})
	end

	v15.LeftButton = leftButton
	local rightButton

	if not (state2 == pages[#pages] or #pages == 1) then
		local changePageButton2 = changePageButton
		rightButton = createElement(changePageButton2, {
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.fromScale(0.1, 0.1),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(1, 0.6),
			Direction = "Right",
			[React.Event.Activated] = function()
				local index = table.find(pages, state2)

				if index then
					setState2(pages[index + 1])
				end
			end
		})
	end

	v15.RightButton = rightButton
	return createElement("Frame", mergeFrame, v15)
end