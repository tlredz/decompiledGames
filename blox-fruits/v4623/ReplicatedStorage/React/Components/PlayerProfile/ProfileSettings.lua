local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
require(ReplicatedStorage.React.Components.PlayerProfile.Types)
local ProfileSettingButton = require(script.ProfileSettingButton)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local font = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO)
local createElement = React.createElement
return function(props)
	return createElement("TextButton", {
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BackgroundTransparency = CONSTANTS.ALPHA.LIGHT,
		BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(1, 1),
		Active = true,
		ZIndex = 999
	}, {
		modal = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BackgroundTransparency = CONSTANTS.ALPHA.HALF,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.9, 0.9),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			info = createElement("Frame", {
				AnchorPoint = Vector2.new(0, 1),
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
				LayoutOrder = 2,
				Position = UDim2.fromScale(0, 1),
				Size = UDim2.fromScale(1, 0.0954103)
			}, {
				uIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = CONSTANTS.SPACING.PADDING.SCALE.MD,
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center
				}),
				cancel = createElement("TextButton", {
					AnchorPoint = Vector2.new(1, 1),
					BackgroundColor3 = CONSTANTS.COLOR.DANGER.BACKGROUND,
					BorderColor3 = CONSTANTS.COLOR.DANGER.BORDER,
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
					FontFace = font,
					LayoutOrder = -999,
					Position = UDim2.new(0.499279, -2, 0.9452, -2),
					Size = UDim2.fromScale(0.192324, 0.7),
					Text = "",
					TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					TextScaled = true,
					TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					ZIndex = CONSTANTS.LAYER.RAISED,
					[React.Event.MouseButton1Click] = function()
						props.SetSettingsVisible(false)
					end
				}, {
					trans = createElement("Frame", {
						BackgroundColor3 = CONSTANTS.COLOR.DANGER.HIGHLIGHT,
						BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
						Position = UDim2.fromOffset(2, 2),
						Size = UDim2.fromScale(0.972252, 0.4),
						ZIndex = CONSTANTS.LAYER.BASE
					}),
					textLabel = createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						FontFace = CONSTANTS.FONT.FACE.DISPLAY,
						Position = UDim2.fromScale(0.5, 0.55),
						Size = UDim2.fromScale(0.9, 0.8),
						Text = "Close",
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
							Text = "Close",
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
				MaxSize = Vector2.new(1e999, 550),
				MinSize = Vector2.new(475, 273)
			}),
			list = createElement("Frame", {
				BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
				BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
				BorderColor3 = Color3.fromRGB(255, 197, 20),
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(-0.00166675, 0.0886315),
				Size = UDim2.fromScale(1, 0.815958)
			}, {
				uIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					Padding = CONSTANTS.SPACING.PADDING.SCALE.MD,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Wraps = true
				}),
				scrollingframe = createElement("ScrollingFrame", {
					AnchorPoint = Vector2.new(0.5, 1),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					CanvasSize = UDim2.new(),
					Position = UDim2.fromScale(0.514651, 0.973144),
					ScrollBarThickness = CONSTANTS.THICKNESS.SCROLLBAR.REGULAR,
					Selectable = false,
					Size = UDim2.fromScale(0.95, 0.94)
				}, {
					uIPadding = createElement("UIPadding", {
						PaddingLeft = CONSTANTS.SPACING.PADDING.SCALE.XXS,
						PaddingTop = CONSTANTS.SPACING.PADDING.SCALE.XXS
					}),
					uIListLayout = createElement("UIListLayout", {
						Padding = UDim.new(0.025, 0),
						SortOrder = Enum.SortOrder.LayoutOrder
					}),
					joinPermissions = createElement("Frame", {
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						LayoutOrder = -2,
						Position = UDim2.fromScale(-1.083e-7, -1.03282e-7),
						Size = UDim2.fromScale(0.97, 0.0867708)
					}, {
						headerTextLabel = createElement("TextLabel", {
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							FontFace = CONSTANTS.FONT.FACE.TITLE,
							LayoutOrder = 2,
							Position = UDim2.fromScale(0.025, 0.5),
							Size = UDim2.fromScale(0.660932, 0.7),
							Text = "Who can join my server",
							TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
							TextScaled = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = CONSTANTS.LAYER.RAISED
						}, {
							uIStroke = createElement("UIStroke")
						}),
						button = createElement(ProfileSettingButton, {
							LoadedPlayer = props.LoadedPlayer,
							SettingName = "JoinServer",
							SetLoadedPlayer = props.SetLoadedPlayer,
							PatchProfileData = props.PatchProfileData
						})
					}),
					buildVisibility = createElement("Frame", {
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						LayoutOrder = 3,
						Position = UDim2.fromScale(2.69429e-8, 0.126771),
						Size = UDim2.fromScale(0.97, 0.858825)
					}, {
						headerTextLabel = createElement("TextLabel", {
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							FontFace = CONSTANTS.FONT.FACE.TITLE,
							LayoutOrder = -999,
							Position = UDim2.fromScale(0.0852868, 0.0110407),
							Size = UDim2.fromScale(0.664254, 0.0685577),
							Text = "Who can see my...",
							TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
							TextScaled = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = CONSTANTS.LAYER.RAISED
						}, {
							uIStroke = createElement("UIStroke"),
							uIPadding = createElement("UIPadding", {
								PaddingLeft = UDim.new(0.035, 0)
							})
						}),
						level = createElement("Frame", {
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							Position = UDim2.fromScale(6.79613e-8, 0.108558),
							Size = UDim2.fromScale(0.999903, 0.0924039)
						}, {
							headerTextLabel = createElement("TextLabel", {
								AnchorPoint = Vector2.new(0, 0.5),
								BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
								FontFace = CONSTANTS.FONT.FACE.TITLE,
								LayoutOrder = 2,
								Position = UDim2.fromScale(0.0496807, 0.5),
								Size = UDim2.fromScale(0.597893, 0.75),
								Text = "Player level",
								TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
								TextScaled = true,
								TextTransparency = CONSTANTS.ALPHA.LIGHT,
								TextXAlignment = Enum.TextXAlignment.Left,
								ZIndex = CONSTANTS.LAYER.RAISED
							}, {
								uIStroke = createElement("UIStroke")
							}),
							button = createElement(ProfileSettingButton, {
								LoadedPlayer = props.LoadedPlayer,
								SettingName = "LevelVisible",
								SetLoadedPlayer = props.SetLoadedPlayer,
								PatchProfileData = props.PatchProfileData
							})
						}),
						race = createElement("Frame", {
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							Position = UDim2.fromScale(6.79613e-8, 0.241518),
							Size = UDim2.fromScale(0.999903, 0.0924039)
						}, {
							headerTextLabel = createElement("TextLabel", {
								AnchorPoint = Vector2.new(0, 0.5),
								BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
								FontFace = CONSTANTS.FONT.FACE.TITLE,
								LayoutOrder = 2,
								Position = UDim2.fromScale(0.0496807, 0.5),
								Size = UDim2.fromScale(0.597893, 0.75),
								Text = "Race",
								TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
								TextScaled = true,
								TextTransparency = CONSTANTS.ALPHA.LIGHT,
								TextXAlignment = Enum.TextXAlignment.Left,
								ZIndex = CONSTANTS.LAYER.RAISED
							}, {
								uIStroke = createElement("UIStroke")
							}),
							button = createElement(ProfileSettingButton, {
								LoadedPlayer = props.LoadedPlayer,
								SettingName = "RaceVisible",
								SetLoadedPlayer = props.SetLoadedPlayer,
								PatchProfileData = props.PatchProfileData
							})
						}),
						accessories = createElement("Frame", {
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							Position = UDim2.fromScale(6.79613e-8, 0.374479),
							Size = UDim2.fromScale(0.999903, 0.0924039)
						}, {
							headerTextLabel = createElement("TextLabel", {
								AnchorPoint = Vector2.new(0, 0.5),
								BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
								FontFace = CONSTANTS.FONT.FACE.TITLE,
								LayoutOrder = 2,
								Position = UDim2.fromScale(0.0496807, 0.5),
								Size = UDim2.fromScale(0.597893, 0.75),
								Text = "Accessories",
								TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
								TextScaled = true,
								TextTransparency = CONSTANTS.ALPHA.LIGHT,
								TextXAlignment = Enum.TextXAlignment.Left,
								ZIndex = CONSTANTS.LAYER.RAISED
							}, {
								uIStroke = createElement("UIStroke")
							}),
							button = createElement(ProfileSettingButton, {
								LoadedPlayer = props.LoadedPlayer,
								SettingName = "AccessoriesVisible",
								SetLoadedPlayer = props.SetLoadedPlayer,
								PatchProfileData = props.PatchProfileData
							})
						}),
						combatTools = createElement("Frame", {
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							Position = UDim2.fromScale(6.79613e-8, 0.50744),
							Size = UDim2.fromScale(0.999903, 0.0924039)
						}, {
							headerTextLabel = createElement("TextLabel", {
								AnchorPoint = Vector2.new(0, 0.5),
								BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
								FontFace = CONSTANTS.FONT.FACE.TITLE,
								LayoutOrder = 2,
								Position = UDim2.fromScale(0.0496807, 0.5),
								Size = UDim2.fromScale(0.597893, 0.75),
								Text = "Combat tools",
								TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
								TextScaled = true,
								TextTransparency = CONSTANTS.ALPHA.LIGHT,
								TextXAlignment = Enum.TextXAlignment.Left,
								ZIndex = CONSTANTS.LAYER.RAISED
							}, {
								uIStroke = createElement("UIStroke")
							}),
							button = createElement(ProfileSettingButton, {
								LoadedPlayer = props.LoadedPlayer,
								SettingName = "CombatToolsVisible",
								SetLoadedPlayer = props.SetLoadedPlayer,
								PatchProfileData = props.PatchProfileData
							})
						}),
						profileShowcase = createElement("Frame", {
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							Position = UDim2.fromScale(6.79613e-8, 0.640401),
							Size = UDim2.fromScale(0.999903, 0.0924039)
						}, {
							headerTextLabel = createElement("TextLabel", {
								AnchorPoint = Vector2.new(0, 0.5),
								BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
								FontFace = CONSTANTS.FONT.FACE.TITLE,
								LayoutOrder = 2,
								Position = UDim2.fromScale(0.0496807, 0.5),
								Size = UDim2.fromScale(0.597893, 0.75),
								Text = "Profile showcase",
								TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
								TextScaled = true,
								TextTransparency = CONSTANTS.ALPHA.LIGHT,
								TextXAlignment = Enum.TextXAlignment.Left,
								ZIndex = CONSTANTS.LAYER.RAISED
							}, {
								uIStroke = createElement("UIStroke")
							}),
							button = createElement(ProfileSettingButton, {
								LoadedPlayer = props.LoadedPlayer,
								SettingName = "ShowcaseVisible",
								SetLoadedPlayer = props.SetLoadedPlayer,
								PatchProfileData = props.PatchProfileData
							})
						}),
						crew = createElement("Frame", {
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							Position = UDim2.fromScale(6.79613e-8, 0.773362),
							Size = UDim2.fromScale(0.999903, 0.0924039)
						}, {
							headerTextLabel = createElement("TextLabel", {
								AnchorPoint = Vector2.new(0, 0.5),
								BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
								FontFace = CONSTANTS.FONT.FACE.TITLE,
								LayoutOrder = 2,
								Position = UDim2.fromScale(0.0496807, 0.5),
								Size = UDim2.fromScale(0.597893, 0.75),
								Text = "Crew",
								TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
								TextScaled = true,
								TextTransparency = CONSTANTS.ALPHA.LIGHT,
								TextXAlignment = Enum.TextXAlignment.Left,
								ZIndex = CONSTANTS.LAYER.RAISED
							}, {
								uIStroke = createElement("UIStroke")
							}),
							button = createElement(ProfileSettingButton, {
								LoadedPlayer = props.LoadedPlayer,
								SettingName = "CrewVisible",
								SetLoadedPlayer = props.SetLoadedPlayer,
								PatchProfileData = props.PatchProfileData
							})
						}),
						fishIndex = createElement("Frame", {
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							Position = UDim2.fromScale(6.79613e-8, 0.906323),
							Size = UDim2.fromScale(0.999903, 0.0924039),
							Visible = false
						}, {
							headerTextLabel = createElement("TextLabel", {
								AnchorPoint = Vector2.new(0, 0.5),
								BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
								FontFace = CONSTANTS.FONT.FACE.TITLE,
								LayoutOrder = 2,
								Position = UDim2.fromScale(0.0496807, 0.5),
								Size = UDim2.fromScale(0.597893, 0.75),
								Text = "Fish Index",
								TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
								TextScaled = true,
								TextTransparency = CONSTANTS.ALPHA.LIGHT,
								TextXAlignment = Enum.TextXAlignment.Left,
								ZIndex = CONSTANTS.LAYER.RAISED
							}, {
								uIStroke = createElement("UIStroke")
							})
						}),
						uIListLayout = createElement("UIListLayout", {
							Padding = CONSTANTS.SPACING.PADDING.SCALE.MD,
							SortOrder = Enum.SortOrder.LayoutOrder
						})
					}),
					giftingPermissions = createElement("Frame", {
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						LayoutOrder = -2,
						Position = UDim2.fromScale(-1.083e-7, -1.03282e-7),
						Size = UDim2.fromScale(0.97, 0.0867708),
						Visible = false
					}, {
						headerTextLabel = createElement("TextLabel", {
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							FontFace = CONSTANTS.FONT.FACE.TITLE,
							LayoutOrder = 2,
							Position = UDim2.fromScale(0.025, 0.5),
							Size = UDim2.fromScale(0.660932, 0.7),
							Text = "Who can send me gifts",
							TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
							TextScaled = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = CONSTANTS.LAYER.RAISED
						}, {
							uIStroke = createElement("UIStroke")
						}),
						button = createElement(ProfileSettingButton, {
							LoadedPlayer = props.LoadedPlayer,
							SettingName = "CanReceiveGifts",
							SetLoadedPlayer = props.SetLoadedPlayer,
							PatchProfileData = props.PatchProfileData
						})
					}),
					recommendedTab = createElement("Frame", {
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						Position = UDim2.fromScale(-3.89547e-8, 0.0898191),
						Size = UDim2.fromScale(0.97, 0.120824)
					}, {
						headerTextLabel = createElement("TextLabel", {
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							FontFace = CONSTANTS.FONT.FACE.TITLE,
							LayoutOrder = 2,
							Position = UDim2.fromScale(0.025, 0.5),
							Size = UDim2.fromScale(0.661, 1),
							Text = "Who can find me in the recommended tab",
							TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
							TextScaled = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = CONSTANTS.LAYER.RAISED
						}, {
							uIStroke = createElement("UIStroke")
						}),
						button = createElement(ProfileSettingButton, {
							LoadedPlayer = props.LoadedPlayer,
							SettingName = "FindInRecent",
							SetLoadedPlayer = props.SetLoadedPlayer,
							PatchProfileData = props.PatchProfileData,
							Size = UDim2.fromScale(0.307032, 0.647442),
							Position = UDim2.fromScale(0.989326, 0.491746)
						})
					}),
					invitePermissions = createElement("Frame", {
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						LayoutOrder = -2,
						Position = UDim2.fromScale(-1.083e-7, -1.03282e-7),
						Size = UDim2.fromScale(0.97, 0.0867708),
						Visible = false
					}, {
						headerTextLabel = createElement("TextLabel", {
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							FontFace = CONSTANTS.FONT.FACE.TITLE,
							LayoutOrder = 2,
							Position = UDim2.fromScale(0.025, 0.5),
							Size = UDim2.fromScale(0.660932, 0.7),
							Text = "Who can invite me",
							TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
							TextScaled = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = CONSTANTS.LAYER.RAISED
						}, {
							uIStroke = createElement("UIStroke")
						})
					}),
					header = createElement("Frame", {
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						LayoutOrder = -1,
						Position = UDim2.fromScale(-3.89547e-8, 0.284813),
						Size = UDim2.fromScale(0.274334, 0.0636348)
					}, {
						imageLabel = createElement("ImageLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							Image = "rbxassetid://13472538818",
							ImageColor3 = CONSTANTS.COLOR.SECONDARY.HIGHLIGHT,
							ImageTransparency = 0.37,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(1.2, 1.3)
						}),
						textLabel = createElement("TextLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							FontFace = CONSTANTS.FONT.FACE.DISPLAY,
							Position = UDim2.fromScale(0.5, 0.45),
							Size = UDim2.fromScale(1, 1),
							Text = "👁️ Visibility",
							TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
							TextScaled = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = CONSTANTS.LAYER.RAISED
						}, {
							uIStroke = createElement("UIStroke", {
								Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
							})
						})
					}),
					header2 = createElement("Frame", {
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						LayoutOrder = -3,
						Position = UDim2.fromScale(-3.89547e-8, 0.00167054),
						Size = UDim2.fromScale(0.335306, 0.0631297)
					}, {
						imageLabel = createElement("ImageLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							Image = "rbxassetid://13472538818",
							ImageColor3 = Color3.fromRGB(119, 178, 85),
							ImageTransparency = 0.23,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(1.2, 1.3)
						}),
						textLabel = createElement("TextLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							FontFace = CONSTANTS.FONT.FACE.DISPLAY,
							Position = UDim2.fromScale(0.5, 0.45),
							Size = UDim2.fromScale(1, 1),
							Text = "✅ Permissions",
							TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
							TextScaled = true,
							TextXAlignment = Enum.TextXAlignment.Left,
							ZIndex = CONSTANTS.LAYER.RAISED
						}, {
							uIStroke = createElement("UIStroke", {
								Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
							})
						})
					}),
					pADDINGFIX = createElement("Frame", {
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						LayoutOrder = 999999999,
						Position = UDim2.fromScale(-3.89547e-8, 0.509406),
						Size = UDim2.fromOffset(100, 4)
					})
				}),
				frame = createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					LayoutOrder = -1,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.new(1, 0, 0, 1)
				})
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
				Size = UDim2.fromScale(1, 0.08571)
			}, {
				uICorner = createElement("UICorner", {
					CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
				}),
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
				}),
				uIGradient = createElement("UIGradient", {
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(158, 158, 158)),
						ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(217, 217, 217)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(158, 158, 158))
					})
				}),
				textLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY,
					Position = UDim2.fromScale(0.5, 0.55),
					Size = UDim2.fromScale(0.8, 0.75),
					Text = "Settings",
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
						Text = "Settings",
						TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
						TextScaled = true
					}, {
						uIStroke = createElement("UIStroke", {
							Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
						})
					})
				})
			}),
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
				AspectRatio = 0.930031
			})
		}),
		glow = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://117627212972326",
			ImageColor3 = Color3.fromRGB(220, 220, 220),
			ImageTransparency = 0.67,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.738, 1.2)
		})
	})
end