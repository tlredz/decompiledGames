local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CONSTANTS = require(script.Parent.CONSTANTS)
local StatusOption = require(script.StatusOption)
local React = require(ReplicatedStorage.Packages.React)
require(ReplicatedStorage.React.Components.PlayerProfile.Types)
local CONSTANTS2 = require(ReplicatedStorage.React.CONSTANTS)
local STATUS_LIST = CONSTANTS.STATUS_LIST
local createElement = React.createElement
return function(props)
	local state, setState = React.useState(props.LoadedPlayer.ProfileData.StatusId)
	local children = {}

	for k, v in STATUS_LIST do
		local v2 = v.FunctionalEmoji ~= nil
		children[k] = createElement(StatusOption, {
			Style = v2 and "Primary" or "Secondary",
			StatusText = `{not v2 and "" or `{v.FunctionalEmoji} ` or ""}{v.Text}`,
			Id = k,
			SelectedStatusId = state,
			SetSelectedStatusId = setState,
			Equipped = state == k,
			Color = v.Color
		})
	end

	return createElement("TextButton", {
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
		BackgroundTransparency = CONSTANTS2.ALPHA.LIGHT,
		BorderColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
		BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		ZIndex = 999,
		Active = true
	}, {
		modal = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
			BackgroundTransparency = CONSTANTS2.ALPHA.HALF,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.85, 0.85),
			ZIndex = CONSTANTS2.LAYER.RAISED
		}, {
			info = createElement("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
				BackgroundTransparency = CONSTANTS2.ALPHA.SUBTLE,
				LayoutOrder = 2,
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.fromScale(1, 0.12278)
			}, {
				uIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = CONSTANTS2.SPACING.PADDING.SCALE.MD,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center
				}),
				confirm = createElement("TextButton", {
					BackgroundColor3 = CONSTANTS2.COLOR.PRIMARY.BACKGROUND,
					BorderColor3 = CONSTANTS2.COLOR.PRIMARY.BORDER,
					BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.REGULAR,
					FontFace = Font.new(CONSTANTS2.FONT.FAMILY.SOURCE_SANS_PRO),
					Position = UDim2.fromScale(0.454775, 0.15),
					Size = UDim2.fromScale(0.2107, 0.7),
					Text = "",
					TextColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
					TextScaled = true,
					TextStrokeColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
					ZIndex = 4,
					[React.Event.Activated] = function()
						local v11, v12 = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpdatePlayerProfileValue"):InvokeServer(
							"Status",
							state
						)

						if v11 then
							local statusId = state == 0 and 9 or state
							props.PatchProfileData({
								StatusId = statusId,
								SubStatusId = 0
							})
						end

						print(v11, v12)
						props.SetStatusSelectionVisible(false)
					end
				}, {
					trans = createElement("Frame", {
						BackgroundColor3 = CONSTANTS2.COLOR.PRIMARY.HIGHLIGHT,
						BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.NONE,
						Position = UDim2.fromOffset(2, 2),
						Size = UDim2.new(1, -4, 0.4, 0),
						ZIndex = CONSTANTS2.LAYER.BASE
					}),
					textLabel = createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
						FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
						Position = UDim2.fromScale(0.5, 0.55),
						Size = UDim2.fromScale(0.95, 0.75),
						Text = "Confirm",
						TextColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
						TextScaled = true,
						ZIndex = CONSTANTS2.LAYER.RAISED
					}, {
						uIStroke = createElement("UIStroke", {
							Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
						}),
						textLabel = createElement("TextLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
							FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
							Position = UDim2.fromScale(0.5, 0.45),
							Size = UDim2.fromScale(1, 1),
							Text = "Confirm",
							TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
							TextScaled = true
						}, {
							uIStroke = createElement("UIStroke", {
								Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
							})
						})
					})
				}),
				cancel = createElement("TextButton", {
					AnchorPoint = Vector2.new(1, 1),
					BackgroundColor3 = CONSTANTS2.COLOR.DANGER.BACKGROUND,
					BorderColor3 = CONSTANTS2.COLOR.DANGER.BORDER,
					BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.REGULAR,
					FontFace = Font.new(CONSTANTS2.FONT.FAMILY.SOURCE_SANS_PRO),
					LayoutOrder = -999,
					Position = UDim2.new(0.499279, -2, 0.9452, -2),
					Size = UDim2.fromScale(0.192324, 0.7),
					Text = "",
					TextColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
					TextScaled = true,
					TextStrokeColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
					ZIndex = CONSTANTS2.LAYER.RAISED,
					[React.Event.Activated] = function()
						setState(props.LoadedPlayer.ProfileData.StatusId)
						props.SetStatusSelectionVisible(false)
					end
				}, {
					trans = createElement("Frame", {
						BackgroundColor3 = CONSTANTS2.COLOR.DANGER.HIGHLIGHT,
						BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.NONE,
						Position = UDim2.fromOffset(2, 2),
						Size = UDim2.fromScale(0.972252, 0.4)
					}),
					textLabel = createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
						FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
						Position = UDim2.fromScale(0.5, 0.55),
						Size = UDim2.fromScale(0.9, 0.8),
						Text = "Cancel",
						TextColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
						TextScaled = true,
						ZIndex = CONSTANTS2.LAYER.RAISED
					}, {
						uIStroke = createElement("UIStroke", {
							Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
						}),
						textLabel = createElement("TextLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
							FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
							Position = UDim2.fromScale(0.5, 0.45),
							Size = UDim2.fromScale(1, 1),
							Text = "Cancel",
							TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
							TextScaled = true
						}, {
							uIStroke = createElement("UIStroke", {
								Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
							})
						})
					})
				}),
				uICorner = createElement("UICorner", {
					CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.MD
				})
			}),
			uISizeConstraint = createElement("UISizeConstraint", {
				MaxSize = Vector2.new(1000, 550),
				MinSize = Vector2.new(475, 273)
			}),
			list = createElement("Frame", {
				BackgroundColor3 = CONSTANTS2.COLOR.PANEL.BACKGROUND,
				BackgroundTransparency = CONSTANTS2.ALPHA.SUBTLE,
				BorderColor3 = Color3.fromRGB(255, 197, 20),
				BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.00126109, 0.112931),
				Size = UDim2.fromScale(1, 0.764289)
			}, {
				uIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = CONSTANTS2.SPACING.PADDING.SCALE.MD,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Wraps = true
				}),
				frame = createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
					LayoutOrder = -1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.new(1, 0, 0, 1)
				}),
				scrollingFrame = createElement("ScrollingFrame", {
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
					Position = UDim2.fromScale(0.514651, 0.973144),
					ScrollBarThickness = CONSTANTS2.THICKNESS.SCROLLBAR.REGULAR,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					Selectable = false,
					Size = UDim2.fromScale(0.970699, 0.94),
					CanvasSize = UDim2.new(0, 0, 0, 0),
					AutomaticCanvasSize = Enum.AutomaticSize.Y
				}, {
					uIPadding = createElement("UIPadding", {
						PaddingLeft = CONSTANTS2.SPACING.PADDING.SCALE.XXS,
						PaddingTop = CONSTANTS2.SPACING.PADDING.SCALE.XXS
					}),
					uIListLayout = createElement("UIListLayout", {
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = UDim.new(0.015, 0),
						SortOrder = Enum.SortOrder.LayoutOrder,
						Wraps = true
					}),
					divider = createElement("Frame", {
						BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
						BackgroundTransparency = CONSTANTS2.ALPHA.HEAVY,
						BorderColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
						BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.NONE,
						Size = UDim2.new(0.98, 0, 0, 2),
						LayoutOrder = 2,
						ZIndex = CONSTANTS2.LAYER.RAISED
					}),
					functionalStatusBig = createElement("Frame", {
						BackgroundColor3 = CONSTANTS2.COLOR.SECONDARY.BACKGROUND,
						BackgroundTransparency = CONSTANTS2.ALPHA.HALF,
						BorderColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
						BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.NONE,
						LayoutOrder = -999,
						Size = UDim2.fromScale(0.98, 1)
					}, {
						uIGradient = createElement("UIGradient", {
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1),
								NumberSequenceKeypoint.new(0.100872, 1),
								NumberSequenceKeypoint.new(0.399751, 0),
								NumberSequenceKeypoint.new(0.699875, 0),
								NumberSequenceKeypoint.new(0.900374, 1),
								NumberSequenceKeypoint.new(1, 1)
							})
						}),
						ratio = createElement("UIAspectRatioConstraint", {
							AspectRatio = 22.727272727272727
						}),
						textLabel = createElement("TextLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
							FontFace = CONSTANTS2.FONT.FACE.TITLE,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(0.8, 0.8),
							Text = "Looking for...",
							TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
							TextScaled = true
						})
					}),
					miscStatusBig = createElement("Frame", {
						BackgroundColor3 = Color3.fromRGB(104, 104, 104),
						BackgroundTransparency = CONSTANTS2.ALPHA.HALF,
						BorderColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
						BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.NONE,
						LayoutOrder = 3,
						Size = UDim2.fromScale(0.98, 1)
					}, {
						ratio = createElement("UIAspectRatioConstraint", {
							AspectRatio = 22.727272727272727
						}),
						textLabel = createElement("TextLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
							FontFace = CONSTANTS2.FONT.FACE.TITLE,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(0.8, 0.8),
							Text = "Fun Statuses",
							TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
							TextScaled = true
						}),
						uIGradient = createElement("UIGradient", {
							Transparency = NumberSequence.new({
								NumberSequenceKeypoint.new(0, 1),
								NumberSequenceKeypoint.new(0.100872, 1),
								NumberSequenceKeypoint.new(0.399751, 0),
								NumberSequenceKeypoint.new(0.699875, 0),
								NumberSequenceKeypoint.new(0.900374, 1),
								NumberSequenceKeypoint.new(1, 1)
							})
						})
					}),
					statusObjects = createElement(React.Fragment, nil, children)
				})
			}),
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
				AspectRatio = 1.44167
			}),
			uICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.XXS
			}),
			uIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
			}),
			title = createElement("Frame", {
				BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
				BackgroundTransparency = CONSTANTS2.ALPHA.SUBTLE,
				Size = UDim2.fromScale(1, 0.112931)
			}, {
				uICorner = createElement("UICorner", {
					CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.MD
				}),
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
				}),
				uIGradient = createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, CONSTANTS2.COLOR.HEADER.BACKGROUND),
						ColorSequenceKeypoint.new(0.509499, CONSTANTS2.COLOR.PALETTE.GOLD_450),
						ColorSequenceKeypoint.new(1, CONSTANTS2.COLOR.HEADER.BACKGROUND)
					})
				}),
				textLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
					FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
					Position = UDim2.fromScale(0.5, 0.55),
					Size = UDim2.fromScale(0.8, 0.75),
					Text = "Profile Status",
					TextColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
					TextScaled = true
				}, {
					uIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
					}),
					textLabel = createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
						FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
						Position = UDim2.fromScale(0.5, 0.45),
						Size = UDim2.fromScale(1, 1),
						Text = "Profile Status",
						TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
						TextScaled = true
					}, {
						uIStroke = createElement("UIStroke", {
							Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
						})
					})
				})
			})
		}),
		glow = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			Image = "rbxassetid://117627212972326",
			ImageColor3 = Color3.fromRGB(255, 197, 20),
			ImageTransparency = 0.67,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1.2)
		})
	})
end