local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileBackgrounds = require(ReplicatedStorage.Modules.ProfileBackgrounds)
local React = require(ReplicatedStorage.Packages.React)
local DogeProfileFullArt = require(ReplicatedStorage.React.Components.PlayerProfile.ExtendedBackgrounds["Doge Profile Full Art"])
local VaporwaveFullArt = require(ReplicatedStorage.React.Components.PlayerProfile.ExtendedBackgrounds["Vaporwave Full Art"])
require(ReplicatedStorage.React.Components.PlayerProfile.Types)
local FishingContentFrame = require(script.FishingContentFrame)
local CONSTANTS = require(script.Parent.CONSTANTS)
local PlayerViewport = require(script.PlayerViewport)
local ProfileContentFrame = require(script.ProfileContentFrame)
local LoadingIcon = require(ReplicatedStorage.React.Components.LoadingIcon)

local function getSortedPlayerIndex(playerByUserId, p: number)
	local players = Players:GetPlayers()
	table.sort(players, function(a, b)
		return a.Name < b.Name
	end)
	local v = (table.find(players, playerByUserId) or 1) + p
	local v2

	if v < 1 then
		v2 = #players
	else
		v2 = #players < v and 1 or v
	end

	return players[v2]
end

local CONSTANTS2 = require(ReplicatedStorage.React.CONSTANTS)
local font = Font.new(CONSTANTS2.FONT.FAMILY.SOURCE_SANS_PRO)
local v = {
	["Doge Profile Full Art"] = DogeProfileFullArt,
	["Vaporwave Profile Full Art"] = VaporwaveFullArt
}
local createElement = React.createElement
return function(props)
	local v2 = React.useMemo(function()
		return props.LoadedPlayer.ProfileData.IsInCrew and CONSTANTS.isPermissionLevelMet(
			props.LoadedPlayer.UserId,
			props.LoadedPlayer.ProfileData.Settings.CrewVisible
		)
	end, { props.LoadedPlayer })
	local v4 = v[React.useMemo(function()
		return ProfileBackgrounds.IdToNameMap[props.LoadedPlayer.ProfileData.BackgroundIndex] or "Default"
	end, { props.LoadedPlayer })]
	local playerByUserId

	if #Players:GetPlayers() > 1 then
		playerByUserId = Players:GetPlayerByUserId(props.LoadedPlayer.UserId)
	else
		playerByUserId = nil
	end

	local v7 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS2.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS2.ALPHA.SUBTLE,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromScale(0.85, 0.85)
	}
	local extended

	if v4 ~= nil then
		extended = createElement(v4)
	end

	local leftPlayer

	if not (playerByUserId == nil or props.IsLoading) then
		leftPlayer = createElement("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = CONSTANTS2.COLOR.SECONDARY.BACKGROUND,
			BorderColor3 = CONSTANTS2.COLOR.SECONDARY.BORDER,
			BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.REGULAR,
			FontFace = Font.new(CONSTANTS2.FONT.FAMILY.SOURCE_SANS_PRO),
			Position = UDim2.fromScale(0.005, 0.5),
			Size = UDim2.fromScale(0.0565437, 0.096),
			Text = "",
			TextColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
			TextScaled = true,
			TextStrokeColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
			ZIndex = CONSTANTS2.LAYER.RAISED,
			[React.Event.MouseButton1Click] = function()
				local sortedPlayerIndex = getSortedPlayerIndex(playerByUserId, -1)

				if sortedPlayerIndex ~= playerByUserId then
					pcall(function()
						Players.LocalPlayer.PlayerGui.PlayerProfile.OpenPlayerProfile:Fire(sortedPlayerIndex.UserId)
					end)
				end
			end
		}, {
			trans = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = CONSTANTS2.COLOR.SECONDARY.HIGHLIGHT,
				BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.9, 0.45)
			}),
			icon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				Image = "rbxassetid://127503254560275",
				ImageRectOffset = Vector2.new(300, 0),
				ImageRectSize = Vector2.new(100, 100),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.95, 0.95),
				ZIndex = CONSTANTS2.LAYER.RAISED_HIGH
			})
		})
	end

	local rightPlayer

	if not (playerByUserId == nil or props.IsLoading) then
		rightPlayer = createElement("TextButton", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = CONSTANTS2.COLOR.SECONDARY.BACKGROUND,
			BorderColor3 = CONSTANTS2.COLOR.SECONDARY.BORDER,
			BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.REGULAR,
			FontFace = Font.new(CONSTANTS2.FONT.FAMILY.SOURCE_SANS_PRO),
			Position = UDim2.fromScale(0.995, 0.5),
			Size = UDim2.fromScale(0.0565437, 0.096),
			Text = "",
			TextColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
			TextScaled = true,
			TextStrokeColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
			ZIndex = CONSTANTS2.LAYER.RAISED,
			[React.Event.MouseButton1Click] = function()
				local sortedPlayerIndex = getSortedPlayerIndex(playerByUserId, 1)

				if sortedPlayerIndex ~= playerByUserId then
					pcall(function()
						Players.LocalPlayer.PlayerGui.PlayerProfile.OpenPlayerProfile:Fire(sortedPlayerIndex.UserId)
					end)
				end
			end
		}, {
			trans = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = CONSTANTS2.COLOR.SECONDARY.HIGHLIGHT,
				BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.9, 0.45)
			}),
			icon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				Image = "rbxassetid://127503254560275",
				ImageRectOffset = Vector2.new(400, 0),
				ImageRectSize = Vector2.new(100, 100),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.95, 0.95),
				ZIndex = CONSTANTS2.LAYER.RAISED_HIGH
			})
		})
	end

	local children = {
		extended = extended,
		giftButton = nil,
		leftPlayer = leftPlayer,
		rightPlayer = rightPlayer,
		playerViewport = createElement(PlayerViewport, {
			LoadedPlayer = props.LoadedPlayer,
			SetBackgroundSelectionVisible = props.SetBackgroundSelectionVisible
		}),
		profileContentFrame = createElement(ProfileContentFrame, {
			LoadedPlayer = props.LoadedPlayer,
			Category = props.Category,
			SetLoadedPlayer = props.SetLoadedPlayer,
			PatchProfileData = props.PatchProfileData,
			StatSelectionVisible = props.StatSelectionVisible,
			SetStatSelectionVisible = props.SetStatSelectionVisible,
			InventoryItems = props.InventoryItems,
			SetSelectedStatSlotId = props.SetSelectedStatSlotId,
			StatusSelectionVisible = props.StatusSelectionVisible,
			SetStatusSelectionVisible = props.SetStatusSelectionVisible
		}),
		fishingContentFrame = createElement(FishingContentFrame, {
			LoadedPlayer = props.LoadedPlayer,
			Category = props.Category
		}),
		uICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.XXS
		}),
		uIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
		}),
		header = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
			Position = UDim2.fromScale(0.5, 3.38207e-8),
			Size = UDim2.fromScale(1, 0.0898869)
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
				Text = "Player Profile",
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
					Text = "Player Profile",
					TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
					TextScaled = true
				}, {
					uIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
					})
				})
			}),
			previewButton = createElement("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = CONSTANTS2.COLOR.SECONDARY.BACKGROUND,
				BorderColor3 = CONSTANTS2.COLOR.SECONDARY.BORDER,
				BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.REGULAR,
				FontFace = Font.new(CONSTANTS2.FONT.FAMILY.SOURCE_SANS_PRO),
				LayoutOrder = 4,
				Position = UDim2.fromScale(0.88, 0.5),
				Size = UDim2.fromScale(0.0420017, 0.794626),
				Text = "",
				TextColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
				TextScaled = true,
				TextStrokeColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
				ZIndex = CONSTANTS2.LAYER.RAISED,
				Visible = props.LoadedPlayer.IsLocalPlayer,
				[React.Event.MouseButton1Click] = function()
					props.SetLoadedPlayer(nil, nil, true)
				end
			}, {
				trans = createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = CONSTANTS2.COLOR.SECONDARY.HIGHLIGHT,
					BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.NONE,
					Position = UDim2.new(0.5, 0, 0, 2),
					Size = UDim2.fromScale(0.97, 0.4)
				}),
				icon = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
					Image = "rbxassetid://138787594167133",
					Position = UDim2.fromScale(0.5, 0.528001),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.9, 0.9),
					ZIndex = CONSTANTS2.LAYER.RAISED_HIGH
				})
			}),
			settings = createElement("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = Color3.fromRGB(158, 158, 158),
				BorderColor3 = CONSTANTS2.COLOR.DISABLED.BORDER,
				BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.REGULAR,
				FontFace = font,
				LayoutOrder = 3,
				Position = UDim2.fromScale(0.935, 0.5),
				Size = UDim2.fromScale(0.0420017, 0.794626),
				Text = "",
				TextColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
				TextScaled = true,
				TextStrokeColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
				ZIndex = CONSTANTS2.LAYER.RAISED,
				Visible = props.LoadedPlayer.IsLocalPlayer,
				[React.Event.MouseButton1Click] = function()
					props.SetSettingsVisible(true)
				end
			}, {
				trans = createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = Color3.fromRGB(191, 191, 191),
					BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.NONE,
					Position = UDim2.new(0.5, 0, 0, 2),
					Size = UDim2.fromScale(0.97, 0.4),
					ZIndex = CONSTANTS2.LAYER.RAISED_HIGH
				}),
				icon = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
					Image = "rbxassetid://127503254560275",
					ImageRectOffset = Vector2.new(500, 0),
					ImageRectSize = Vector2.new(100, 100),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					ZIndex = 4
				})
			}),
			close = createElement("TextButton", {
				AnchorPoint = Vector2.new(1, 0.5),
				BackgroundColor3 = CONSTANTS2.COLOR.DANGER.BACKGROUND,
				BorderColor3 = CONSTANTS2.COLOR.DANGER.BORDER,
				BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.REGULAR,
				FontFace = font,
				LayoutOrder = -999,
				Position = UDim2.fromScale(0.99, 0.5),
				Size = UDim2.fromScale(0.0420017, 0.794626),
				Text = "",
				TextColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
				TextScaled = true,
				TextStrokeColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
				ZIndex = CONSTANTS2.LAYER.RAISED,
				[React.Event.Activated] = function()
					props.SetIsOpen(false)
					props.SetSettingsVisible(false)
					props.SetStatSelectionVisible(false)
					props.OnExit()
				end
			}, {
				trans = createElement("Frame", {
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundColor3 = CONSTANTS2.COLOR.DANGER.HIGHLIGHT,
					BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.NONE,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.94, 0.47),
					ZIndex = CONSTANTS2.LAYER.RAISED_HIGH
				}),
				icon = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
					Image = "rbxassetid://127503254560275",
					ImageRectSize = Vector2.new(100, 100),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					ZIndex = 4
				})
			})
		}),
		infoLabel = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = v2 and CONSTANTS2.COLOR.SECONDARY.BACKGROUND or Color3.fromRGB(81, 81, 81),
			BackgroundTransparency = CONSTANTS2.ALPHA.LIGHT,
			BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.154, 0.91),
			Size = UDim2.fromScale(0.265, 0.06)
		}, {
			statusTextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.524999976),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.55),
				Size = UDim2.fromScale(1, 0.8),
				Text = not v2 and "Not in Crew" or props.LoadedPlayer.ProfileData.CrewName or "Not in Crew",
				TextColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
				TextScaled = true,
				ZIndex = CONSTANTS2.LAYER.RAISED
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
				}),
				realText = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 1),
					BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
					FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
					Position = UDim2.fromScale(0.5, 0.95),
					Size = UDim2.fromScale(1, 1),
					Text = not v2 and "Not in Crew" or props.LoadedPlayer.ProfileData.CrewName or "Not in Crew",
					TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
					TextScaled = true,
					ZIndex = CONSTANTS2.LAYER.RAISED
				}, {
					uIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
					})
				})
			}),
			uIGradient = createElement("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 1),
					NumberSequenceKeypoint.new(0.235367, 0),
					NumberSequenceKeypoint.new(0.770859, 0),
					NumberSequenceKeypoint.new(1, 1)
				})
			}),
			realText = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				FontFace = CONSTANTS2.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.5, -0.1),
				Size = UDim2.fromScale(1, 0.65),
				Text = "Crew:",
				TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
				TextScaled = true,
				ZIndex = CONSTANTS2.LAYER.RAISED
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
				})
			})
		}),
		loadingOverlay = 0,
		uIAspectRatioConstraint = 0,
		uISizeConstraint = 0,
		categoryNavigator = 0
	}
	local loadingOverlay

	if props.IsLoading then
		loadingOverlay = createElement("Frame", {
			Active = true,
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = CONSTANTS2.COLOR.PANEL.BACKGROUND,
			BackgroundTransparency = 0.15,
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromScale(1, 0.91),
			ZIndex = 10
		}, {
			uICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.XXS
			}),
			loadingIcon = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.25, 0.25),
				ZIndex = 11
			}, {
				uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
					AspectRatio = 1
				}),
				icon = createElement(LoadingIcon, {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1, 1),
					ZIndex = 11
				})
			})
		})
	end

	children.loadingOverlay = loadingOverlay
	children.uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
		AspectRatio = 1.6978
	})
	children.uISizeConstraint = createElement("UISizeConstraint", {
		MaxSize = Vector2.new(1e999, 500)
	})
	children.categoryNavigator = createElement("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		BackgroundColor3 = Color3.fromRGB(64, 64, 64),
		BackgroundTransparency = CONSTANTS2.ALPHA.SUBTLE,
		Position = UDim2.fromScale(0.00273394, 0.0945595),
		Size = UDim2.fromScale(0.0880671, 0.321826),
		Visible = false
	}, {
		profileToggle = createElement("TextButton", {
			Size = UDim2.new(1, 0, 0.5, 0),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			Text = "",
			[React.Event.MouseButton1Click] = function()
				if props.Category ~= "Profile" then
					props.SetSelectedCategory("Profile")
				end
			end
		}),
		fishingToggle = createElement("TextButton", {
			Size = UDim2.new(1, 0, 0.5, 0),
			Position = UDim2.new(0, 0, 0.5, 0),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			Text = "",
			[React.Event.MouseButton1Click] = function()
				if props.Category ~= "FishIndex" then
					props.SetSelectedCategory("FishIndex")
				end
			end
		}),
		equipment = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			Image = "rbxassetid://140359094712203",
			ImageColor3 = props.Category == "Profile" and CONSTANTS2.COLOR.PALETTE.WHITE or CONSTANTS2.COLOR.PALETTE.GREY_500,
			Position = UDim2.new(0.49, 0, -2.84479e-7, 2),
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(0.951353, 0.416143)
		}, {
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.946548),
				Size = UDim2.fromScale(1.2, 0.33),
				Text = "Profile",
				TextColor3 = props.Category == "Profile" and CONSTANTS2.COLOR.PALETTE.WHITE or CONSTANTS2.COLOR.PALETTE.GREY_500,
				TextScaled = true,
				ZIndex = CONSTANTS2.LAYER.RAISED
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
				})
			})
		}),
		uICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.MD
		}),
		uIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
		}),
		fishingIndex = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			Image = "rbxassetid://112171744796785",
			Position = UDim2.new(0.49, 0, 0.950284, -2),
			ScaleType = Enum.ScaleType.Fit,
			ImageColor3 = props.Category == "FishIndex" and CONSTANTS2.COLOR.PALETTE.WHITE or CONSTANTS2.COLOR.PALETTE.GREY_500,
			Size = UDim2.fromScale(0.961988, 0.420795)
		}, {
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.947),
				Size = UDim2.fromScale(1.2, 0.33),
				Text = "Fishing",
				TextColor3 = props.Category == "FishIndex" and CONSTANTS2.COLOR.PALETTE.WHITE or CONSTANTS2.COLOR.PALETTE.GREY_500,
				TextScaled = true,
				ZIndex = CONSTANTS2.LAYER.RAISED
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
				})
			})
		}),
		selectedOverlay = createElement("Frame", {
			Active = true,
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = CONSTANTS2.COLOR.PRIMARY.BACKGROUND,
			Position = UDim2.fromScale(0.494, props.Category == "FishIndex" and 1 or 0.468),
			Selectable = true,
			Size = UDim2.fromScale(0.989, 0.468429),
			ZIndex = CONSTANTS2.LAYER.BASE
		}, {
			trans = createElement("Frame", {
				BackgroundColor3 = CONSTANTS2.COLOR.PRIMARY.HIGHLIGHT,
				BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromOffset(2, 2),
				Size = UDim2.new(1, -4, 0.4, 0)
			}),
			uICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.MD
			}),
			uIStroke = createElement("UIStroke")
		})
	})
	return createElement("Frame", v7, children)
end