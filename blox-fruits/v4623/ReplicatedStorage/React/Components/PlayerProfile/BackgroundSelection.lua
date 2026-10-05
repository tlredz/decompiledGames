local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileBackgrounds = require(ReplicatedStorage.Modules.ProfileBackgrounds)
local BackgroundOption = require(script.BackgroundOption)
local React = require(ReplicatedStorage.Packages.React)
require(ReplicatedStorage.React.Components.PlayerProfile.Types)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local state, setState = React.useState(props.LoadedPlayer.ProfileData.BackgroundIndex)
	local children = {}

	for k, name in ProfileBackgrounds.IdToNameMap do
		local v2 = ProfileBackgrounds.List[name]

		if not (v2 and (v2.SelectCriteria and v2.SelectCriteria(
			props.LoadedPlayer.UserId,
			props.LoadedPlayer.ProfileData
		) or props.LoadedPlayer.OwnedBackgrounds[name] == true)) then
			continue
		end

		table.insert(children, createElement(BackgroundOption, {
			Id = k,
			Name = name,
			Equipped = state == k,
			SetSelectedBackground = setState,
			ClearNewBackground = props.ClearNewBackground,
			LoadedPlayer = props.LoadedPlayer,
			SetLoadedPlayer = props.SetLoadedPlayer
		}))
	end

	return createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BackgroundTransparency = CONSTANTS.ALPHA.LIGHT,
		BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 999
	}, {
		modal = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BackgroundTransparency = CONSTANTS.ALPHA.HALF,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.85, 0.85),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			info = createElement("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
				LayoutOrder = 2,
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.fromScale(1, 0.12278)
			}, {
				uIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = CONSTANTS.SPACING.PADDING.SCALE.MD,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center
				}),
				confirm = createElement("TextButton", {
					BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
					BorderColor3 = CONSTANTS.COLOR.PRIMARY.BORDER,
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
					FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
					Position = UDim2.fromScale(0.454775, 0.15),
					Size = UDim2.fromScale(0.2107, 0.7),
					Text = "",
					TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					TextScaled = true,
					TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					ZIndex = 4,
					[React.Event.MouseButton1Click] = function()
						local v11, v12 = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpdatePlayerProfileValue"):InvokeServer(
							"Background",
							state
						)

						if v11 then
							props.PatchProfileData({
								BackgroundIndex = state
							})
						else
							print(v11, v12)
						end

						props.SetBackgroundSelectionVisible(false)
					end
				}, {
					trans = createElement("Frame", {
						BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT,
						BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
						Position = UDim2.fromOffset(2, 2),
						Size = UDim2.new(1, -4, 0.4, 0),
						ZIndex = CONSTANTS.LAYER.BASE
					}),
					textLabel = createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						FontFace = CONSTANTS.FONT.FACE.DISPLAY,
						Position = UDim2.fromScale(0.5, 0.55),
						Size = UDim2.fromScale(0.95, 0.75),
						Text = "Confirm",
						TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
						TextScaled = true,
						ZIndex = CONSTANTS.LAYER.RAISED
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
							Text = "Confirm",
							TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
							TextScaled = true,
							ZIndex = CONSTANTS.LAYER.RAISED_HIGH
						}, {
							uIStroke = createElement("UIStroke", {
								Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
							})
						})
					})
				}),
				cancel = createElement("TextButton", {
					AnchorPoint = Vector2.new(1, 1),
					BackgroundColor3 = CONSTANTS.COLOR.DANGER.BACKGROUND,
					BorderColor3 = CONSTANTS.COLOR.DANGER.BORDER,
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
					FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
					LayoutOrder = -999,
					Position = UDim2.new(0.499279, -2, 0.9452, -2),
					Size = UDim2.fromScale(0.192324, 0.7),
					Text = "",
					TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					TextScaled = true,
					TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					ZIndex = CONSTANTS.LAYER.RAISED,
					[React.Event.MouseButton1Click] = function()
						props.SetBackgroundSelectionVisible(false)
					end
				}, {
					trans = createElement("Frame", {
						BackgroundColor3 = CONSTANTS.COLOR.DANGER.HIGHLIGHT,
						BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
						Position = UDim2.fromOffset(2, 2),
						Size = UDim2.fromScale(0.972252, 0.4)
					}),
					textLabel = createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						FontFace = CONSTANTS.FONT.FACE.DISPLAY,
						Position = UDim2.fromScale(0.5, 0.55),
						Size = UDim2.fromScale(0.9, 0.8),
						Text = "Cancel",
						TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
						TextScaled = true,
						ZIndex = CONSTANTS.LAYER.RAISED_HIGH
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
							Text = "Cancel",
							TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
							TextScaled = true
						}, {
							uIStroke = createElement("UIStroke", {
								Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
							})
						})
					})
				}),
				uICorner = createElement("UICorner", {
					CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
				})
			}),
			uISizeConstraint = createElement("UISizeConstraint", {
				MaxSize = Vector2.new(1000, 550),
				MinSize = Vector2.new(475, 273)
			}),
			list = createElement("Frame", {
				BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
				BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
				BorderColor3 = Color3.fromRGB(255, 197, 20),
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.00126109, 0.112931),
				Size = UDim2.fromScale(1, 0.764289)
			}, {
				uIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = CONSTANTS.SPACING.PADDING.SCALE.MD,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Wraps = true
				}),
				frame = createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					LayoutOrder = -1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.new(1, 0, 0, 1)
				}),
				scrollingFrame = createElement("ScrollingFrame", {
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Position = UDim2.fromScale(0.514651, 0.973144),
					ScrollBarThickness = CONSTANTS.THICKNESS.SCROLLBAR.REGULAR,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					Selectable = false,
					Size = UDim2.fromScale(0.970699, 0.94)
				}, {
					uIPadding = createElement("UIPadding", {
						PaddingLeft = CONSTANTS.SPACING.PADDING.SCALE.XXS,
						PaddingTop = UDim.new(0.001, 0)
					}),
					uIListLayout = createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0.0175, 0),
						SortOrder = Enum.SortOrder.LayoutOrder,
						Wraps = true
					}),
					cards = createElement(React.Fragment, nil, children)
				})
			}),
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
				AspectRatio = 1.44167
			}),
			uICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XXS
			}),
			uIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			}),
			title = createElement("Frame", {
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
					Text = "Profile Backgrounds",
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
						Text = "Profile Backgrounds",
						TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
						TextScaled = true
					}, {
						uIStroke = createElement("UIStroke", {
							Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
						})
					})
				})
			})
		}),
		glow = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://117627212972326",
			ImageColor3 = Color3.fromRGB(255, 197, 20),
			ImageTransparency = 0.67,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1.2)
		})
	})
end