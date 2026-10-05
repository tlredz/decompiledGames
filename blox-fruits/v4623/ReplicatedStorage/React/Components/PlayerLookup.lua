local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerLookupEntry = require(script.PlayerLookupEntry)
require(script.Types)
local React = require(ReplicatedStorage.Packages.React)
local NewBadge = require(ReplicatedStorage.React.Components.NewBadge)
local LoadingIcon = require(ReplicatedStorage.React.Components.LoadingIcon)
local Util = require(ReplicatedStorage.React.Util)
local tweenBinding = Util.tweenBinding
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local quad = Enum.EasingStyle.Quad
local out = Enum.EasingDirection.Out
local v = {
	Server = {
		Title = "Current Players",
		Description = "View players in your current server."
	},
	Global = {
		Title = "Global Players",
		Description = "View friends, or search globally."
	},
	Recent = {
		Title = "Recent Players",
		Description = "View players you recently interacted with."
	}
}
local createElement = React.createElement
return function(data)
	local defaultCategory = data.DefaultCategory
	local v2 = defaultCategory == "Server" and 1 or 0
	local v3 = defaultCategory == "Global" and 1 or 0
	local v4 = defaultCategory == "Recent" and 1 or 0
	local state, setState = React.useState(nil)
	local state2, setState2 = React.useState(defaultCategory)
	local state3, setState3 = React.useState("")
	local v5, v6 = React.useBinding(0)
	local state4, setState4 = React.useState(false)
	React.useEffect(function()
		local flag = false
		task.spawn(function()
			local v7, _, v8 = ReplicatedStorage.Remotes.GetProfileBackgroundList:InvokeServer()

			if flag then
				return
			end

			if v7 and typeof(v8) == "table" then
				setState4(next(v8) ~= nil)
			end
		end)
		return function()
			flag = true
		end
	end, {})
	local v7, v8 = React.useBinding(0)
	local v9, v10 = React.useBinding(v2)
	local v11, v12 = React.useBinding(v3)
	local v13, v14 = React.useBinding(v4)
	local children = {}
	local v15 = string.lower(state3)
	local v16 = data[state2]

	if state ~= nil then
		v16 = state
	end

	local v17

	if ({
		Server = data.ServerLoading,
		Global = data.GlobalLoading,
		Recent = data.RecentLoading
	})[state2] == true then
		v17 = state == nil
	else
		v17 = false
	end

	React.useEffect(function()
		setState2(defaultCategory)
	end, { data.Open })
	React.useEffect(function()
		setState(nil)
		setState3("")
	end, { state2 })

	for k, info in v16 do
		if not (v15 == "" or string.find(string.lower(info.Username), v15) ~= nil) then
			continue
		end

		children[tostring(info.UserId)] = createElement(PlayerLookupEntry, {
			Info = info,
			SetLookupOpen = data.SetOpen,
			LayoutOrder = k
		})
	end

	local image = Players.LocalPlayer == nil and "rbxthumb://type=AvatarHeadShot&id=1&w=150&h=150" or `rbxthumb://type=AvatarHeadShot&id={Players.LocalPlayer.UserId}&w=150&h=150`

	if not data.Open then
		return nil
	end

	local v21 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(21, 21, 21),
		BackgroundTransparency = 0.04,
		Position = UDim2.fromScale(0.512851, 0.499749),
		Size = UDim2.fromScale(0.368249, 0.857438),
		ZIndex = CONSTANTS.LAYER.RAISED
	}
	local children2 = {
		uICorner = createElement("UICorner", {
			BottomLeftRadius = UDim.new(0.01, 0),
			BottomRightRadius = UDim.new(0.01, 0),
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XXS,
			TopLeftRadius = UDim.new(0.01, 0),
			TopRightRadius = UDim.new(0.01, 0)
		}),
		uIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		title = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			Size = UDim2.fromScale(1, 0.0968421)
		}, {
			uICorner = createElement("UICorner", {
				BottomLeftRadius = UDim.new(0.1, 0),
				BottomRightRadius = UDim.new(0.1, 0),
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD,
				TopLeftRadius = UDim.new(0.1, 0),
				TopRightRadius = UDim.new(0.1, 0)
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
				Size = UDim2.fromScale(0.76, 0.75),
				Text = v[state2].Title,
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
					Text = v[state2].Title,
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
				Position = UDim2.fromScale(0.98, 0.5),
				Size = UDim2.fromScale(0.0880164, 0.694664),
				Text = "",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true,
				TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				ZIndex = CONSTANTS.LAYER.RAISED,
				[React.Event.MouseButton1Click] = function()
					data.SetOpen(false)
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
					Position = UDim2.fromScale(0.51, 0.51),
					Size = UDim2.fromScale(1, 1),
					ZIndex = CONSTANTS.LAYER.RAISED_HIGH
				}),
				uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
			})
		}),
		description = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = UDim2.fromScale(0.5, 0.139356),
			Size = UDim2.fromScale(0.95, 0.043),
			Text = v[state2].Description,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true
		}),
		searchBar = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = Color3.fromRGB(17, 17, 17),
			BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
			Position = UDim2.fromScale(0.510024, 0.25),
			Size = UDim2.fromScale(0.939952, 0.0673684)
		}, {
			uICorner = createElement("UICorner", {
				BottomLeftRadius = UDim.new(0.175, 0),
				BottomRightRadius = UDim.new(0.175, 0),
				CornerRadius = UDim.new(0.175, 0),
				TopLeftRadius = UDim.new(0.175, 0),
				TopRightRadius = UDim.new(0.175, 0)
			}),
			uIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			}),
			nameTextBox = createElement("TextBox", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				PlaceholderColor3 = CONSTANTS.COLOR.PALETTE.GREY_400,
				PlaceholderText = "Search",
				Position = UDim2.fromScale(0.528, 0.5),
				Size = UDim2.fromScale(0.852, 0.7),
				Text = "",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				[React.Event.FocusLost] = function(p, flag: boolean)
					if flag and state2 == "Global" then
						local userIdFromNameAsync = Players:GetUserIdFromNameAsync(p.Text)
						local isOnline, isFriend

						if Players.LocalPlayer then
							local success, result = pcall(
								Players.LocalPlayer.IsFriendsWith,
								Players.LocalPlayer,
								userIdFromNameAsync
							)
							isOnline = ReplicatedStorage.Remotes.GetPlayerLookupOnlineStatus:InvokeServer(userIdFromNameAsync)
							isFriend = success and result
						else
							isFriend = math.random() > 0.5

							if math.random() > 0.5 then
								isOnline = true
							else
								isOnline = false
							end
						end

						setState({
							{
								UserId = userIdFromNameAsync,
								Username = Players:GetNameFromUserIdAsync(userIdFromNameAsync),
								IsFriend = isFriend,
								IsOnline = isOnline,
								Context = "Found via search."
							}
						})
					end
				end,
				[React.Event.Changed] = function(p, p2)
					if p2 == "Text" then
						setState(nil)
						setState3(p.Text)
					end
				end
			}),
			icon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://18195291644",
				ImageColor3 = CONSTANTS.COLOR.PALETTE.GREY_400,
				Position = UDim2.fromScale(0.018, 0.49),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.7, 0.7)
			}, {
				uIAspectRatioConstraint = createElement("UIAspectRatioConstraint")
			})
		}),
		uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 0.764321
		}),
		uISizeConstraint = createElement("UISizeConstraint", {
			MaxSize = Vector2.new(1e999, 500)
		}),
		playerLookupScrollingFrame = createElement("ScrollingFrame", {
			Active = true,
			AutomaticCanvasSize = Enum.AutomaticSize.None,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			CanvasSize = v5:map(function(p)
				return UDim2.fromOffset(
					0,
					math.ceil(p) + CONSTANTS.SPACING.PADDING.OFFSET.XXS.Offset + CONSTANTS.SPACING.PADDING.OFFSET.MD.Offset
				)
			end),
			Position = UDim2.fromScale(0.0377994, 0.265108),
			ScrollBarThickness = CONSTANTS.THICKNESS.SCROLLBAR.THIN,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Size = UDim2.fromScale(0.940064, 0.719072)
		}, {
			uIListLayout = createElement("UIListLayout", {
				Padding = CONSTANTS.SPACING.PADDING.OFFSET.MD,
				SortOrder = Enum.SortOrder.LayoutOrder,
				[React.Change.AbsoluteContentSize] = function(p)
					v6(p.AbsoluteContentSize.Y)
				end
			}),
			uIPadding = createElement("UIPadding", {
				PaddingBottom = CONSTANTS.SPACING.PADDING.OFFSET.MD,
				PaddingLeft = CONSTANTS.SPACING.PADDING.SCALE.XXS,
				PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.XXS
			}),
			players = createElement(React.Fragment, {}, children)
		}),
		loadingIcon = 0,
		myProfileTab = 0,
		categoryNavigator = 0
	}
	local loadingIcon

	if v17 then
		loadingIcon = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.0377994, 0.265108),
			Size = UDim2.fromScale(0.940064, 0.719072)
		}, {
			icon = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.25, 0.25)
			}, {
				uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
					AspectRatio = 1
				}),
				loading = createElement(LoadingIcon, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1)
				})
			})
		})
	end

	children2.loadingIcon = loadingIcon
	local v39 = {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(64, 64, 64),
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		Position = UDim2.fromScale(0.00977638, 0.59346),
		Size = UDim2.fromScale(0.168, 0.144185)
	}
	local v40 = {
		uICorner = createElement("UICorner", {
			BottomLeftRadius = UDim.new(0.08, 0),
			BottomRightRadius = UDim.new(0.08, 0),
			CornerRadius = UDim.new(0.08, 0),
			TopLeftRadius = UDim.new(0.08, 0),
			TopRightRadius = UDim.new(0.08, 0)
		}),
		uIStroke = createElement("UIStroke", {
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Thickness = 0.024
		}),
		myProfileTan = createElement("ImageButton", {
			Active = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ImageColor3 = CONSTANTS.COLOR.PALETTE.GREY_500,
			Position = UDim2.fromScale(0.482844, 0.430004),
			ScaleType = Enum.ScaleType.Fit,
			Selectable = true,
			Size = UDim2.fromScale(0.996839, 0.818396),
			[React.Event.MouseButton1Click] = function()
				if Players.LocalPlayer then
					pcall(function()
						Players.LocalPlayer.PlayerGui.PlayerProfile.OpenPlayerProfile:Fire(Players.LocalPlayer.UserId)
					end)
				end

				data.SetOpen(false)
			end
		}, {
			icon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = image,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1)
			}),
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.499999, 1.01042),
				Size = UDim2.fromScale(1.3, 0.33),
				Text = "My Profile",
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				uIStroke = createElement("UIStroke", {
					StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
					Thickness = 0.08
				})
			})
		}),
		newBadge = 0
	}
	local newBadge

	if state4 then
		newBadge = createElement(NewBadge, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.95, 0.1),
			Size = UDim2.fromScale(0.55, 0.55),
			ZIndex = CONSTANTS.LAYER.OVERLAY
		})
	end

	v40.newBadge = newBadge
	children2.myProfileTab = createElement("Frame", v39, v40)
	children2.categoryNavigator = createElement("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(64, 64, 64),
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		Position = UDim2.fromScale(0.00977638, 0.11346),
		Size = UDim2.fromScale(0.168, 0.463588)
	}, {
		uICorner = createElement("UICorner", {
			BottomLeftRadius = UDim.new(0.08, 0),
			BottomRightRadius = UDim.new(0.08, 0),
			CornerRadius = UDim.new(0.08, 0),
			TopLeftRadius = UDim.new(0.08, 0),
			TopRightRadius = UDim.new(0.08, 0)
		}),
		uIStroke = createElement("UIStroke", {
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
			Thickness = 0.024
		}),
		selectedOverlay = createElement("Frame", {
			Active = true,
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
			Position = v7:map(function(p)
				return UDim2.fromScale(0.49842, p)
			end),
			Selectable = true,
			Size = UDim2.fromScale(0.981263, 0.314935),
			ZIndex = CONSTANTS.LAYER.BASE
		}, {
			trans = createElement("Frame", {
				BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromOffset(2, 2),
				Size = UDim2.new(1, -4, 0.5, 0)
			}),
			uICorner = createElement("UICorner", {
				BottomLeftRadius = UDim.new(0.1, 0),
				BottomRightRadius = UDim.new(0.1, 0),
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD,
				TopLeftRadius = UDim.new(0.1, 0),
				TopRightRadius = UDim.new(0.1, 0)
			}),
			uIStroke = createElement("UIStroke", {
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
				Thickness = 0.025
			})
		}),
		serverTab = createElement("ImageButton", {
			Active = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.49842, 0.138054),
			ScaleType = Enum.ScaleType.Fit,
			Selectable = true,
			Size = UDim2.fromScale(0.996839, 0.258851),
			[React.Event.MouseButton1Click] = function()
				setState2("Server")
				tweenBinding(v7, v8, 0, 0.1, quad, out)
				tweenBinding(v9, v10, 1, 0.1, quad, out)
				tweenBinding(v11, v12, 0, 0.1, quad, out)
				tweenBinding(v13, v14, 0, 0.1, quad, out)
			end
		}, {
			icon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://121464307483350",
				ImageColor3 = v9:map(function(p)
					return CONSTANTS.COLOR.PALETTE.GREY_500:Lerp(CONSTANTS.COLOR.PALETTE.WHITE, p)
				end),
				ImageRectSize = Vector2.new(128, 128),
				Position = UDim2.fromScale(0.519, 0.49),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.97, 0.97)
			}),
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.499999, 1.01042),
				Size = UDim2.fromScale(1.3, 0.33),
				Text = "Server",
				TextColor3 = v9:map(function(p)
					return CONSTANTS.COLOR.PALETTE.GREY_500:Lerp(CONSTANTS.COLOR.PALETTE.WHITE, p)
				end),
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				uIStroke = createElement("UIStroke", {
					StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
					Thickness = 0.08
				})
			})
		}),
		globalTab = createElement("ImageButton", {
			Active = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.482844, 0.478874),
			ScaleType = Enum.ScaleType.Fit,
			Selectable = true,
			Size = UDim2.fromScale(0.934537, 0.258851),
			[React.Event.MouseButton1Click] = function()
				setState2("Global")
				tweenBinding(v7, v8, 0.35, 0.1, quad, out)
				tweenBinding(v9, v10, 0, 0.1, quad, out)
				tweenBinding(v11, v12, 1, 0.1, quad, out)
				tweenBinding(v13, v14, 0, 0.1, quad, out)
			end
		}, {
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.499999, 1.01042),
				Size = UDim2.fromScale(1.3, 0.33),
				Text = "Global",
				TextColor3 = v11:map(function(p)
					return CONSTANTS.COLOR.PALETTE.GREY_500:Lerp(CONSTANTS.COLOR.PALETTE.WHITE, p)
				end),
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				uIStroke = createElement("UIStroke", {
					StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
					Thickness = 0.08
				})
			}),
			icon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://121464307483350",
				ImageColor3 = v11:map(function(p)
					return CONSTANTS.COLOR.PALETTE.GREY_500:Lerp(CONSTANTS.COLOR.PALETTE.WHITE, p)
				end),
				ImageRectOffset = Vector2.new(128, 0),
				ImageRectSize = Vector2.new(128, 128),
				Position = UDim2.fromScale(0.5, 0.49),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.92, 0.92)
			})
		}),
		recentTab = createElement("ImageButton", {
			Active = true,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0.482844, 0.819694),
			ScaleType = Enum.ScaleType.Fit,
			Selectable = true,
			Size = UDim2.fromScale(0.934537, 0.258851),
			[React.Event.MouseButton1Click] = function()
				setState2("Recent")
				tweenBinding(v7, v8, 0.685, 0.1, quad, out)
				tweenBinding(v9, v10, 0, 0.1, quad, out)
				tweenBinding(v11, v12, 0, 0.1, quad, out)
				tweenBinding(v13, v14, 1, 0.1, quad, out)
			end
		}, {
			icon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://12383318510",
				Position = UDim2.fromScale(0.5, 0.48),
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.88, 0.88),
				ImageColor3 = v13:map(function(p)
					return CONSTANTS.COLOR.PALETTE.GREY_500:Lerp(CONSTANTS.COLOR.PALETTE.WHITE, p)
				end)
			}),
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.499999, 1.01042),
				Size = UDim2.fromScale(1.2, 0.33),
				Text = "Recent",
				TextColor3 = v13:map(function(p)
					return CONSTANTS.COLOR.PALETTE.GREY_500:Lerp(CONSTANTS.COLOR.PALETTE.WHITE, p)
				end),
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				uIStroke = createElement("UIStroke", {
					StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
					Thickness = 0.08
				})
			})
		})
	})
	return (createElement("Frame", v21, children2))
end