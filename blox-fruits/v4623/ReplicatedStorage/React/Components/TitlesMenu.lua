local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Padding = require(script.Padding)
local ItemId = require(ReplicatedStorage.Economy.ItemId)
local ItemConfig = require(ReplicatedStorage.ItemConfig)
local RegularTitleEntry = require(script.RegularTitleEntry)
local SpecialTitleEntry = require(script.SpecialTitleEntry)
local TitleColorEntry = require(script.TitleColorEntry)
local React = require(ReplicatedStorage.Packages.React)
require(script.Types)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local v = {}
local unwrapOr = ItemId.getId("Carp", "Fish"):unwrapOr(0)
local v2 = ItemConfig.tryGet(unwrapOr)

local function getSpecialData(p: string)
	local v3 = v[p]

	if v3 ~= nil then
		return v3
	end

	local unwrapOr2 = ItemId.getId(p, "Title"):unwrapOr(0)
	local v4

	if unwrapOr2 then
		v4 = ItemConfig.tryGet(unwrapOr2)
	end

	if not v4 or not v4.Display.Sprite or not v2 or not v2.Display.Sprite or v4.Display.Sprite.Image == v2.Display.Sprite.Image then
		v[p] = false
		return false
	end

	local v5 = {
		Image = v4.Display.Sprite.Image,
		ImageRectSize = v4.Display.Sprite.ImageRectSize or Vector2.zero,
		ImageRectOffset = v4.Display.Sprite.ImageRectOffset or Vector2.zero
	}
	v[p] = v5
	return v5
end

local createElement = React.createElement
return function(props)
	local children = {}
	local count = 0
	local count2 = 0
	local count3 = 0
	local count4 = 0
	local count5 = 0

	if props.IsOpen then
		children.StartPadding = createElement(Padding, {
			AspectRatio = 50,
			LayoutOrder = -999
		})

		if props.Category == "Titles" then
			for _, titleData in props.TitleList do
				if not (props.SearchTerm == "" or string.find(
					string.lower(titleData.Name),
					string.lower(props.SearchTerm)
				)) then
					continue
				end

				local v4 = nil
				local specialData = getSpecialData(titleData.InternalName) or getSpecialData(titleData.Name)

				if specialData then
					count3 += 1

					if props.FilterOption == "All" or props.FilterOption == "Special" then
						count5 += 1
						v4 = createElement(SpecialTitleEntry, {
							CurrentTitle = props.CurrentTitle,
							TitleData = titleData,
							SpecialData = specialData,
							UpdateFromServer = props.UpdateFromServer
						})

						if titleData.Unlocked then
							count += 1
						end
					end
				else
					count2 += 1

					if props.FilterOption == "All" or props.FilterOption == "Regular" then
						count5 += 1
						v4 = createElement(RegularTitleEntry, {
							CurrentTitle = props.CurrentTitle,
							TitleData = titleData,
							UpdateFromServer = props.UpdateFromServer
						})

						if titleData.Unlocked then
							count += 1
						end
					end
				end

				count4 += 1

				if not v4 then
					continue
				end

				children[titleData.InternalName] = v4
				children[`{titleData.InternalName}Padding`] = createElement(Padding, {
					AspectRatio = 50,
					LayoutOrder = titleData.Index * 2
				})
			end
		elseif props.Category == "Colors" then
			for k, colorData in props.TitleColorList do
				if not (props.SearchTerm == "" or string.find(
					string.lower(colorData.ColorName),
					string.lower(props.SearchTerm)
				)) then
					continue
				end

				children[k] = createElement(TitleColorEntry, {
					ColorData = colorData,
					CurrentTitleColor = props.CurrentTitleColor,
					Index = (tonumber(k) or -2) * 2 - 1,
					InternalName = k,
					UpdateFromServer = props.UpdateFromServer
				})
				children[`{k}Padding`] = createElement(Padding, {
					AspectRatio = 50,
					LayoutOrder = (tonumber(k) or -2) * 2
				})
			end
		end
	end

	if not props.IsOpen then
		return nil
	end

	local v5 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.8, 0.8),
		ZIndex = CONSTANTS.LAYER.RAISED
	}
	local children2 = {
		uISizeConstraint = createElement("UISizeConstraint", {
			MaxSize = Vector2.new(1000, 450),
			MinSize = Vector2.new(475, 273)
		}),
		content = 0,
		uIAspectRatioConstraint = 0,
		uICorner = 0,
		uIStroke = 0,
		title = 0,
		categoryNavigator = 0
	}
	local v8 = {
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		BorderColor3 = Color3.fromRGB(255, 197, 20),
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(-3.84876e-8, 0.112931),
		Size = UDim2.fromScale(1.00126, 0.887069)
	}
	local v9 = {
		scrollingFrame = createElement("ScrollingFrame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.5, 0.972419),
			ScrollBarThickness = CONSTANTS.THICKNESS.SCROLLBAR.REGULAR,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Selectable = false,
			Size = UDim2.fromScale(0.970699, 0.841719),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE
		}, {
			uIPadding = createElement("UIPadding", {
				PaddingLeft = CONSTANTS.SPACING.PADDING.SCALE.XXS
			}),
			uIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = CONSTANTS.SPACING.PADDING.NONE,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Wraps = true
			}),
			titleEntries = React.createElement(React.Fragment, nil, { children })
		}),
		filters = 0
	}
	local v12 = {
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		BackgroundTransparency = 0.999,
		BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.02, 0.025),
		Size = UDim2.fromScale(0.964025, 0.09),
		ZIndex = CONSTANTS.LAYER.RAISED
	}
	local v13 = {
		searchTextBox = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.INK_900,
			BackgroundTransparency = 0.2,
			Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
			ImageTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(1, 0.51),
			Size = UDim2.fromScale(0.296628, 1)
		}, {
			nameTextBox = createElement("TextBox", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				PlaceholderColor3 = CONSTANTS.COLOR.PALETTE.GREY_400,
				PlaceholderText = "Search",
				Position = UDim2.fromScale(0.571, 0.525),
				Size = UDim2.fromScale(0.765702, 0.75),
				Text = props.SearchTerm,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				[React.Event.FocusLost] = function(p, flag: boolean)
					if flag then
						props.SetSearchTerm(p.Text)
					end
				end
			}),
			uICorner = createElement("UICorner", {
				CornerRadius = UDim.new(0.15, 0)
			}),
			icon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://18195291644",
				ImageColor3 = CONSTANTS.COLOR.PALETTE.GREY_400,
				Position = UDim2.fromScale(0.035, 0.5),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.72, 0.72)
			}, {
				uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
			}),
			uIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
			})
		}),
		left = 0
	}
	local left

	if props.Category == "Titles" then
		left = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(4.39119e-8, 0),
			Size = UDim2.fromScale(0.690857, 1)
		}, {
			dropdownMenu = createElement("ImageButton", {
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.INK_900,
				BackgroundTransparency = 0.2,
				Position = UDim2.fromScale(8.45774e-8, 0),
				Size = UDim2.fromOffset(194, 35),
				[React.Event.MouseButton1Click] = function()
					props.SetFilterDropdownEnabled(not props.FilterDropdownEnabled)
				end
			}, {
				descriptionText = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					Position = UDim2.fromScale(0.035, 0.52),
					Size = UDim2.fromScale(0.908, 0.7),
					Text = props.FilterOption,
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = CONSTANTS.LAYER.RAISED
				}, {
					uIStroke = createElement("UIStroke")
				}),
				arrow = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Image = "rbxassetid://98374247587739",
					Position = UDim2.fromScale(0.92, 0.529),
					Rotation = props.FilterDropdownEnabled and 90 or -90,
					Size = UDim2.fromScale(0.0388, 0.5)
				}),
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
				}),
				uICorner = createElement("UICorner", {
					CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
				}),
				dropdownMenu = createElement("Frame", {
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Position = UDim2.fromScale(0, 1.2),
					Size = UDim2.fromScale(1, 3),
					Visible = props.FilterDropdownEnabled
				}, {
					all = createElement("ImageButton", {
						BackgroundColor3 = props.FilterOption == "All" and Color3.fromRGB(33, 36, 38) or CONSTANTS.COLOR.PALETTE.INK_900,
						BackgroundTransparency = 0.02,
						Size = UDim2.fromScale(1, 0.143),
						[React.Event.MouseButton1Click] = function()
							props.SetFilterDropdownEnabled(false)
							props.SetFilterOption("All")
						end
					}, {
						uICorner = createElement("UICorner", {
							CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
						}),
						descriptionText = createElement("TextLabel", {
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							FontFace = CONSTANTS.FONT.FACE.TITLE,
							Position = UDim2.fromScale(0.035, 0.52),
							Size = UDim2.fromScale(0.922, 0.7),
							Text = `All ({count4})`,
							TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
							TextScaled = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = CONSTANTS.LAYER.RAISED
						}, {
							uIStroke = createElement("UIStroke"),
							uITextSizeConstraint = createElement("UITextSizeConstraint", {
								MaxTextSize = 24
							})
						})
					}),
					uIListLayout = createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalFlex = Enum.UIFlexAlignment.Fill
					}),
					special = createElement("ImageButton", {
						BackgroundColor3 = props.FilterOption == "Special" and Color3.fromRGB(33, 36, 38) or CONSTANTS.COLOR.PALETTE.INK_900,
						BackgroundTransparency = 0.02,
						BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
						BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
						LayoutOrder = 1,
						Size = UDim2.fromScale(1, 0.143),
						[React.Event.MouseButton1Click] = function()
							props.SetFilterDropdownEnabled(false)
							props.SetFilterOption("Special")
						end
					}, {
						descriptionText = createElement("TextLabel", {
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							FontFace = CONSTANTS.FONT.FACE.TITLE,
							Position = UDim2.fromScale(0.035, 0.52),
							Size = UDim2.fromScale(0.922, 0.7),
							Text = `⭐Special ({count3})`,
							TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
							TextScaled = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = CONSTANTS.LAYER.RAISED
						}, {
							uIStroke = createElement("UIStroke"),
							uITextSizeConstraint = createElement("UITextSizeConstraint", {
								MaxTextSize = 24
							})
						})
					}),
					regular = createElement("ImageButton", {
						BackgroundColor3 = props.FilterOption == "Regular" and Color3.fromRGB(33, 36, 38) or CONSTANTS.COLOR.PALETTE.INK_900,
						BackgroundTransparency = 0.02,
						BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
						BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
						LayoutOrder = 2,
						Size = UDim2.fromScale(1, 0.143),
						[React.Event.MouseButton1Click] = function()
							props.SetFilterDropdownEnabled(false)
							props.SetFilterOption("Regular")
						end
					}, {
						descriptionText = createElement("TextLabel", {
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							FontFace = CONSTANTS.FONT.FACE.TITLE,
							Position = UDim2.fromScale(0.035, 0.52),
							Size = UDim2.fromScale(0.922, 0.7),
							Text = `Regular ({count2})`,
							TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
							TextScaled = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = CONSTANTS.LAYER.RAISED
						}, {
							uIStroke = createElement("UIStroke"),
							uITextSizeConstraint = createElement("UITextSizeConstraint", {
								MaxTextSize = 24
							})
						})
					}),
					uICorner = createElement("UICorner", {
						CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.SM
					}),
					uIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
					})
				})
			}),
			numberUnlocked = createElement("TextLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.297853, 0.163508),
				Size = UDim2.fromOffset(258, 26),
				Text = `{count}/{count5} Unlocked`,
				TextColor3 = CONSTANTS.COLOR.PALETTE.GREY_400,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			}),
			uIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				Padding = CONSTANTS.SPACING.PADDING.SCALE.SM,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center
			})
		})
	end

	v13.left = left
	v9.filters = createElement("Frame", v12, v13)
	children2.content = createElement("Frame", v8, v9)
	children2.uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
		AspectRatio = 1.6
	})
	children2.uICorner = createElement("UICorner", {
		CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XXS
	})
	children2.uIStroke = createElement("UIStroke", {
		Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
	})
	children2.title = createElement("Frame", {
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		Size = UDim2.fromScale(1, 0.112931)
	}, {
		uICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
		}),
		uIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		uIGradient = createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, CONSTANTS.COLOR.HEADER.BACKGROUND),
				ColorSequenceKeypoint.new(0.509499, CONSTANTS.COLOR.PALETTE.GOLD_450),
				ColorSequenceKeypoint.new(1, CONSTANTS.COLOR.HEADER.BACKGROUND)
			})
		}),
		textLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			Position = UDim2.fromScale(0.5, 0.55),
			Size = UDim2.fromScale(0.8, 0.75),
			Text = "TITLES",
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true
		}, {
			uIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			}),
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.45),
				Size = UDim2.fromScale(1, 1),
				Text = "TITLES",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				})
			})
		}),
		close = createElement("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = CONSTANTS.COLOR.DANGER.BACKGROUND,
			BorderColor3 = CONSTANTS.COLOR.DANGER.BORDER,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
			FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
			LayoutOrder = -999,
			Position = UDim2.fromScale(0.99, 0.5),
			Size = UDim2.fromScale(0.053031, 0.763532),
			Text = "",
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true,
			TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			ZIndex = CONSTANTS.LAYER.RAISED,
			[React.Event.MouseButton1Click] = function()
				props.SetIsOpen(false)
			end
		}, {
			trans = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = CONSTANTS.COLOR.DANGER.HIGHLIGHT,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.94, 0.47)
			}),
			icon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://127503254560275",
				ImageRectSize = Vector2.new(100, 100),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			})
		})
	})
	children2.categoryNavigator = createElement("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(64, 64, 64),
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		Position = UDim2.fromScale(0.00299996, 0.105),
		Size = UDim2.fromScale(0.098, 0.361805)
	}, {
		uICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
		}),
		uIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		selectedOverlay = createElement("Frame", {
			Active = true,
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
			Position = UDim2.fromScale(0.5, props.Category == "Titles" and 0 or 0.5),
			Selectable = true,
			Size = UDim2.fromScale(0.987648, 0.5),
			ZIndex = CONSTANTS.LAYER.BASE
		}, {
			trans = createElement("Frame", {
				BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromOffset(2, 2),
				Size = UDim2.new(1, -4, 0.5, 0)
			}),
			uICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
			}),
			uIStroke = createElement("UIStroke")
		}),
		titleTab = createElement("ImageButton", {
			Active = false,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ImageColor3 = CONSTANTS.COLOR.PALETTE.GREY_500,
			Position = UDim2.fromScale(0.486667, 0.208796),
			ScaleType = Enum.ScaleType.Fit,
			Selectable = false,
			Size = UDim2.fromScale(0.944706, 0.393152),
			[React.Event.MouseButton1Click] = function()
				props.SetCategory("Titles")
			end
		}, {
			icon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://109344024350428",
				ImageColor3 = props.Category == "Titles" and CONSTANTS.COLOR.PALETTE.WHITE or CONSTANTS.COLOR.PALETTE.GREY_500,
				Position = UDim2.fromScale(0.5, 0.551749),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(1, 1.0965)
			}),
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.499999, 1.01042),
				Size = UDim2.fromScale(1.3, 0.33),
				Text = "TITLES",
				TextColor3 = props.Category == "Titles" and CONSTANTS.COLOR.PALETTE.WHITE or CONSTANTS.COLOR.PALETTE.GREY_500,
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = 1.75
				})
			})
		}),
		colorTab = createElement("ImageButton", {
			Active = false,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ImageColor3 = CONSTANTS.COLOR.PALETTE.GREY_500,
			Position = UDim2.fromScale(0.486667, 0.722429),
			ScaleType = Enum.ScaleType.Fit,
			Selectable = false,
			Size = UDim2.fromScale(0.944706, 0.393152),
			[React.Event.MouseButton1Click] = function()
				props.SetCategory("Colors")
			end
		}, {
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.499999, 1.01042),
				Size = UDim2.fromScale(1.3, 0.33),
				Text = "Color",
				TextColor3 = props.Category == "Colors" and CONSTANTS.COLOR.PALETTE.WHITE or CONSTANTS.COLOR.PALETTE.GREY_500,
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = 1.75
				})
			}),
			icon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				Image = "rbxassetid://16229547803",
				ImageColor3 = props.Category == "Colors" and CONSTANTS.COLOR.PALETTE.WHITE or CONSTANTS.COLOR.PALETTE.GREY_500,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.75, 0.75)
			}, {
				uICorner = createElement("UICorner", {
					CornerRadius = UDim.new(1, 0)
				}),
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
				}),
				uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
			})
		})
	})
	return (createElement("Frame", v5, children2))
end