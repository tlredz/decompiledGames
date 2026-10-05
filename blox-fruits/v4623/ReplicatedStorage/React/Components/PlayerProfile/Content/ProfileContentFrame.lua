local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserService = game:GetService("UserService")
local FriendInvite = require(ReplicatedStorage.Modules.FriendInvite)
local IslandLocationLookup = require(ReplicatedStorage.Modules.IslandLocationLookup)
local React = require(ReplicatedStorage.Packages.React)
local CONSTANTS = require(ReplicatedStorage.React.Components.PlayerProfile.CONSTANTS)
require(ReplicatedStorage.React.Components.PlayerProfile.Types)
local Showcase = require(script.Showcase)
local CONSTANTS2 = require(ReplicatedStorage.React.CONSTANTS)
local v = {
	Username = "N/A",
	DisplayName = "N/A",
	IsVerified = false,
	IsFriend = false
}
local v2 = {}
local STATUS_LIST = CONSTANTS.STATUS_LIST
local createElement = React.createElement

local function getCachedUserInfoAsync(userId: number)
	local v3 = v2[userId]

	if v3 then
		return v3
	end

	local success, userInfosByUserIdsAsync = pcall(UserService.GetUserInfosByUserIdsAsync, UserService, { userId })

	if not success then
		warn((`UserService::GetUserInfosByUserIdsAsync failed because {userInfosByUserIdsAsync}`))
		return nil
	end

	for _, v4 in userInfosByUserIdsAsync do
		if v4.Id ~= userId then
			continue
		end

		local result

		if Players.LocalPlayer then
			local success2
			success2, result = pcall(Players.LocalPlayer.IsFriendsWith, Players.LocalPlayer, userId)

			if not success2 then
				result = nil
			end
		else
			result = true
		end

		local v5 = {
			Username = v4.Username,
			DisplayName = v4.DisplayName,
			IsVerified = v4.HasVerifiedBadge,
			IsFriend = result
		}
		v2[userId] = v5
		return v5
	end

	return nil
end

return function(props)
	local loadedPlayer = props.LoadedPlayer
	local v3 = getCachedUserInfoAsync(loadedPlayer.UserId) or v
	local v4 = React.useMemo(function()
		local lastLocation = loadedPlayer.ProfileData.LastLocation
		return not CONSTANTS.isPermissionLevelMet(
			props.LoadedPlayer.UserId,
			props.LoadedPlayer.ProfileData.Settings.LocationVisible
		) and 0 or lastLocation
	end, { props.LoadedPlayer })
	local v5 = React.useMemo(function()
		return IslandLocationLookup.IdToValue[v4] or "Unknown"
	end, { props.LoadedPlayer })
	local v6 = React.useMemo(function()
		return Players:GetPlayerByUserId(props.LoadedPlayer.UserId) ~= nil
	end, { props.LoadedPlayer })
	local v7 = STATUS_LIST[props.LoadedPlayer.ProfileData.StatusId]
	local v8 = React.useMemo(function()
		if v7 == nil or #v7.Options == 0 then
			return ""
		end

		return v7.Options[props.LoadedPlayer.ProfileData.SubStatusId] or ""
	end)
	local v9 = React.useMemo(function()
		if v7 == nil then
			return ""
		end

		local v10 = v7.FunctionalEmoji ~= nil and `{v7.FunctionalEmoji} Looking for ` or ""
		local v11 = (props.LoadedPlayer.IsLocalPlayer == false or props.LoadedPlayer.IsPreviewMode) and `{v8 == "" and "" or ": "}{v8}`
		return (`{v10} {v7.Text}{v11}`)
	end, { props.LoadedPlayer })
	local v10 = React.useMemo(function()
		return v7 and v7.Color or CONSTANTS2.COLOR.PALETTE.WHITE
	end, { props.LoadedPlayer })
	local colorSequence = ColorSequence.new({
		ColorSequenceKeypoint.new(0, v10),
		ColorSequenceKeypoint.new(0.759931, Color3.fromRGB(250, 250, 250)),
		ColorSequenceKeypoint.new(1, CONSTANTS2.COLOR.PALETTE.WHITE)
	})
	local state, setState = React.useState(false)
	local v11 = {}
	local v12

	if v7 then
		v12 = #v7.Options

		if v12 > 0 then
			local clone = table.clone(v7.Options)
			table.insert(clone, 1, "<Any>")
			v12 += 1

			for k, text in clone do
				local v15 = {
					BackgroundColor3 = Color3.fromRGB(33, 36, 38),
					BackgroundTransparency = 0.02,
					Size = UDim2.fromScale(1, 1 / v12),
					LayoutOrder = k
				}
				local v16 = text

				v15[React.Event.MouseButton1Click] = function()
					setState(false)
					local index = table.find(v7.Options, v16) or 0
					local v17, v18 = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UpdatePlayerProfileValue"):InvokeServer(
						"SubStatus",
						index
					)

					if v17 then
						props.PatchProfileData({
							SubStatusId = index
						})
					else
						print(v17, v18)
					end
				end

				v11[k] = createElement("ImageButton", v15, {
					uICorner = createElement("UICorner", {
						CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.MD
					}),
					descriptionText = createElement("TextLabel", {
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
						FontFace = CONSTANTS2.FONT.FACE.TITLE,
						Position = UDim2.fromScale(0.035, 0.52),
						Size = UDim2.fromScale(0.922, 0.7),
						Text = text,
						TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = CONSTANTS2.LAYER.RAISED
					}, {
						uIStroke = createElement("UIStroke"),
						uITextSizeConstraint = createElement("UITextSizeConstraint", {
							MaxTextSize = 24
						})
					})
				})
			end
		end
	else
		v12 = 0
	end

	local online = CONSTANTS.isPermissionLevelMet(
		props.LoadedPlayer.UserId,
		props.LoadedPlayer.ProfileData.Settings.JoinServer
	) and not v6 and props.LoadedPlayer.ProfileData.Online
	local visible = not v6 and v3.IsFriend and FriendInvite.CanSendInviteToUserId(props.LoadedPlayer.UserId)
	local v16 = {
		Active = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
		ClipsDescendants = true,
		Position = UDim2.fromScale(0.651458, 0.545906),
		Selectable = true,
		SelectionGroup = true,
		Size = UDim2.fromScale(0.678562, 0.860079),
		Visible = props.Category == "Profile"
	}
	local children = {
		uIListLayout = createElement("UIListLayout", {
			Padding = CONSTANTS2.SPACING.PADDING.SCALE.MD,
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		playerInfo = 0,
		uIPadding = 0,
		lastSeen = 0,
		dividerLine = 0,
		showcase = 0
	}
	local v19 = {
		BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
		LayoutOrder = -2,
		Position = UDim2.fromScale(0, 7.37229e-8),
		Size = UDim2.fromScale(0.964867, 0.207755),
		ZIndex = 50
	}
	local children2 = {
		titleText = createElement("TextLabel", {
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
			Position = UDim2.fromScale(0.184771, 0.0700003),
			Size = UDim2.fromScale(0.813573, 0.25328),
			Text = loadedPlayer.ProfileData.TitleText,
			TextColor3 = loadedPlayer.ProfileData.TitleColor,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = CONSTANTS2.LAYER.RAISED
		}, {
			uIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
			})
		}),
		editStatus = createElement("ImageButton", {
			Active = true,
			AnchorPoint = Vector2.new(0, 1),
			BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.INK_900,
			BackgroundTransparency = 0.2,
			Position = UDim2.fromScale(0.19, 1.1),
			Selectable = true,
			Size = UDim2.fromScale(0.814, 0.35),
			Visible = props.LoadedPlayer.IsLocalPlayer and not props.LoadedPlayer.IsPreviewMode,
			[React.Event.MouseButton1Click] = function()
				if props.LoadedPlayer.IsLocalPlayer and not props.LoadedPlayer.IsPreviewMode then
					props.SetStatusSelectionVisible(true)
				end
			end
		}, {
			addStatusTextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				FontFace = CONSTANTS2.FONT.FACE.BODY_ITALIC,
				Position = UDim2.fromScale(0.015, 0.49),
				Size = UDim2.fromScale(0.908, 0.8),
				Text = v9 == "" and "+ Add Status" or "",
				TextColor3 = CONSTANTS2.COLOR.PALETTE.GREY_400,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = CONSTANTS2.LAYER.RAISED
			}, {
				uIStroke = createElement("UIStroke")
			}),
			uIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS2.THICKNESS.OUTLINE.THIN
			}),
			uICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.MD
			}),
			content = createElement("Frame", {
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(0.01, 0.6),
				Size = UDim2.fromScale(1, 1),
				ZIndex = CONSTANTS2.LAYER.RAISED
			}, {
				uIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Horizontal,
					Padding = UDim.new(0.015, 0),
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				dropdownMenu = createElement("ImageButton", {
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.INK_900,
					BackgroundTransparency = 0.2,
					LayoutOrder = 2,
					Position = UDim2.fromScale(0.272, 0.5),
					Size = UDim2.fromScale(0.343, 1),
					ZIndex = 9999,
					Visible = v12 > 0,
					[React.Event.MouseButton1Click] = function()
						setState(not state)
					end
				}, {
					descriptionText = createElement("TextLabel", {
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
						FontFace = CONSTANTS2.FONT.FACE.TITLE,
						Position = UDim2.fromScale(0.035, 0.52),
						Size = UDim2.fromScale(0.908, 0.7),
						Text = v8 == "" and "Any" or v8,
						TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = CONSTANTS2.LAYER.RAISED
					}, {
						uIStroke = createElement("UIStroke")
					}),
					arrow = createElement("ImageLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
						Image = "rbxassetid://98374247587739",
						Position = UDim2.fromScale(0.92, 0.529),
						Rotation = state and 90 or -90,
						Size = UDim2.fromScale(0.0388, 0.5)
					}),
					uIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS2.THICKNESS.OUTLINE.THIN
					}),
					uICorner = createElement("UICorner", {
						CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.MD
					}),
					dropdownMenu = createElement("Frame", {
						BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
						Position = UDim2.fromScale(0, 1.2),
						Size = UDim2.fromScale(1, v12),
						Visible = state,
						ZIndex = 10000
					}, {
						uIListLayout = createElement("UIListLayout", {
							SortOrder = Enum.SortOrder.LayoutOrder,
							VerticalFlex = Enum.UIFlexAlignment.Fill
						}),
						uICorner = createElement("UICorner", {
							CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.XXS
						}),
						uIStroke = createElement("UIStroke", {
							Thickness = CONSTANTS2.THICKNESS.OUTLINE.THIN
						}),
						options = createElement(React.Fragment, nil, v11)
					})
				}),
				lookingForTextLabel = createElement("TextLabel", {
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
					FontFace = CONSTANTS2.FONT.FACE.BODY,
					LayoutOrder = -999,
					Position = UDim2.fromScale(1.35451e-7, 0),
					Size = UDim2.fromScale(0, 0.8),
					Text = `{(v7 == nil or not v7.FunctionalEmoji) and "" or `{v7.FunctionalEmoji} ` or ""}{v7 == nil and "" or v7.FunctionalEmoji ~= nil and "Looking for" or v7.Text}`,
					TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
					TextScaled = true
				}, {
					uIGradient = createElement("UIGradient", {
						Color = colorSequence,
						Rotation = 90
					})
				}),
				selectionTextLabel = createElement("TextLabel", {
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
					FontFace = CONSTANTS2.FONT.FACE.BODY,
					LayoutOrder = -998,
					Size = UDim2.fromScale(0, 0.8),
					Text = not v7 and "" or v7.Text or "",
					TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
					TextScaled = true,
					Visible = v7 ~= nil and v7.FunctionalEmoji ~= nil
				}, {
					uIGradient = createElement("UIGradient", {
						Color = colorSequence,
						Rotation = 90
					})
				})
			})
		}),
		playerImage = createElement("ImageLabel", {
			BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
			BackgroundTransparency = CONSTANTS2.ALPHA.HALF,
			Image = `rbxthumb://type=AvatarHeadShot&id={loadedPlayer.UserId}&w=150&h=150`,
			Position = UDim2.fromScale(-2.26961e-7, 0),
			Size = UDim2.fromScale(1, 1)
		}, {
			uIAspectRatioConstraint = createElement("UIAspectRatioConstraint"),
			uICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.SM
			}),
			statusIndicator = createElement("Frame", {
				AnchorPoint = Vector2.new(1, 1),
				BackgroundColor3 = Color3.fromRGB(2, 183, 87),
				Position = UDim2.fromScale(1.05, 1.05),
				Size = UDim2.fromScale(0.209302, 0.209302),
				Visible = loadedPlayer.ProfileData.Online
			}, {
				uICorner = createElement("UICorner", {
					CornerRadius = UDim.new(1, 0)
				}),
				uIStroke = createElement("UIStroke")
			})
		}),
		statusText = 0,
		nameFrame = 0
	}
	local v36 = {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
		FontFace = CONSTANTS2.FONT.FACE.BODY_ITALIC,
		Position = UDim2.fromScale(0.185, 1.05),
		Size = UDim2.fromScale(0.812596, 0.267442),
		Text = (v9 == "" or not v9) and "I <3 Blox Fruits!" or v9,
		TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
		TextScaled = true,
		TextTransparency = CONSTANTS2.ALPHA.OPAQUE,
		TextXAlignment = Enum.TextXAlignment.Left,
		Visible = loadedPlayer.IsLocalPlayer == false or loadedPlayer.IsPreviewMode,
		ZIndex = CONSTANTS2.LAYER.RAISED
	}
	local uiGradient

	if v10:ToHex() ~= "ffffff" then
		uiGradient = createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, v10),
				ColorSequenceKeypoint.new(0.759931, Color3.fromRGB(250, 250, 250)),
				ColorSequenceKeypoint.new(1, CONSTANTS2.COLOR.PALETTE.WHITE)
			}),
			Rotation = 90
		})
	end

	children2.statusText = createElement("TextLabel", v36, {
		uiGradient = uiGradient
	})
	children2.nameFrame = createElement("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
		Position = UDim2.fromScale(0.185, 0.77),
		Size = UDim2.fromScale(0.814, 0.396)
	}, {
		nameTextShadow = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			FontFace = CONSTANTS2.FONT.FACE.TITLE,
			Position = UDim2.fromScale(0.085, 0.55),
			RichText = true,
			Size = UDim2.fromScale(1, 1),
			Text = `<b>{v3.DisplayName}</b> @{v3.Username}`,
			TextColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = CONSTANTS2.LAYER.RAISED
		}, {
			uIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
			}),
			realText = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				FontFace = CONSTANTS2.FONT.FACE.TITLE,
				Position = UDim2.fromScale(0.5, 0.92),
				RichText = true,
				Size = UDim2.fromScale(1, 1),
				Text = `<b>{v3.DisplayName}</b> <font color="#c5c5c5">@{v3.Username}</font>`,
				TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
				TextScaled = true,
				TextXAlignment = Enum.TextXAlignment.Left
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
				})
			})
		}),
		verifiedBadge = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			Image = "rbxassetid://100068420577413",
			ImageRectOffset = Vector2.new(128, 0),
			ImageRectSize = Vector2.new(64, 64),
			LayoutOrder = -997,
			Position = UDim2.fromScale(0, 0.420779),
			Size = UDim2.fromScale(0.0660754, 0.841558),
			Visible = v3.IsVerified
		}),
		developerBadge = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			Image = "rbxassetid://100068420577413",
			ImageRectOffset = Vector2.new(64, 0),
			ImageRectSize = Vector2.new(64, 64),
			LayoutOrder = -999,
			Position = UDim2.fromScale(0, 0.420779),
			Size = UDim2.fromScale(0.0660754, 0.841558),
			Visible = props.LoadedPlayer.ProfileData.IsDeveloper
		}),
		starBadge = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			Image = "rbxassetid://100068420577413",
			ImageRectOffset = Vector2.new(0, 0),
			ImageRectSize = Vector2.new(64, 64),
			LayoutOrder = -999,
			Position = UDim2.fromScale(0, 0.420779),
			Size = UDim2.fromScale(0.0660754, 0.841558),
			Visible = props.LoadedPlayer.ProfileData.IsStarCreator
		}),
		uIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = CONSTANTS2.SPACING.PADDING.SCALE.XS,
			SortOrder = Enum.SortOrder.LayoutOrder
		})
	})
	children.playerInfo = createElement("Frame", v19, children2)
	children.uIPadding = createElement("UIPadding", {
		PaddingLeft = UDim.new(0.002, 0),
		PaddingRight = UDim.new(0.002, 0)
	})
	children.lastSeen = createElement("Frame", {
		BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
		BackgroundTransparency = CONSTANTS2.ALPHA.HALF,
		LayoutOrder = -1,
		Position = UDim2.fromScale(-2.48234e-8, 0.292996),
		Size = UDim2.fromScale(0.975688, 0.0869671),
		Visible = true
	}, {
		uIStroke = createElement("UIStroke"),
		uICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.MD
		}),
		inviteButton = createElement("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = CONSTANTS2.COLOR.SECONDARY.BACKGROUND,
			BorderColor3 = CONSTANTS2.COLOR.SECONDARY.BORDER,
			BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.REGULAR,
			FontFace = Font.new(CONSTANTS2.FONT.FAMILY.SOURCE_SANS_PRO),
			LayoutOrder = 1,
			Position = UDim2.fromScale(online and 0.785 or 0.975, 0.5),
			Size = UDim2.fromScale(0.221402, 0.529872),
			Text = "",
			TextColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
			TextScaled = true,
			TextStrokeColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
			ZIndex = CONSTANTS2.LAYER.RAISED,
			Visible = visible,
			[React.Event.MouseButton1Click] = function()
				FriendInvite.PromptForUserId(props.LoadedPlayer.UserId)
			end
		}, {
			trans = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = CONSTANTS2.COLOR.SECONDARY.HIGHLIGHT,
				BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.96, 0.45)
			}),
			uISizeConstraint = createElement("UISizeConstraint", {
				MinSize = Vector2.new(24, 24)
			}),
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.56),
				Size = UDim2.fromScale(0.95, 0.8),
				Text = "Invite",
				TextColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
				TextScaled = true,
				ZIndex = CONSTANTS2.LAYER.RAISED_HIGH
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS2.THICKNESS.OUTLINE.THIN
				}),
				textLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
					FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
					Position = UDim2.fromScale(0.5, 0.425),
					Size = UDim2.fromScale(1, 1),
					Text = "Invite",
					TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
					TextScaled = true,
					ZIndex = 4
				}, {
					uIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS2.THICKNESS.OUTLINE.THIN
					})
				})
			})
		}),
		joinButton = createElement("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = CONSTANTS2.COLOR.PRIMARY.BACKGROUND,
			BorderColor3 = CONSTANTS2.COLOR.PRIMARY.BORDER,
			FontFace = CONSTANTS2.FONT.FACE.BODY_LIGHT,
			Position = UDim2.fromScale(0.988151, 0.5),
			Size = UDim2.fromScale(0.186468, 0.714957),
			Text = "",
			TextColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
			TextScaled = true,
			TextStrokeColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
			Visible = online,
			[React.Event.MouseButton1Click] = function()
				ReplicatedStorage.Remotes.JoinPlayerFromProfile:FireServer(props.LoadedPlayer.UserId)
			end
		}, {
			trans = createElement("Frame", {
				BackgroundColor3 = CONSTANTS2.COLOR.PRIMARY.HIGHLIGHT,
				BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromOffset(2, 2),
				Size = UDim2.new(1, -4, 0.4, 0),
				ZIndex = CONSTANTS2.LAYER.RAISED
			}),
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
				FontFace = CONSTANTS2.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.55),
				Size = UDim2.fromScale(0.95, 0.75),
				Text = "Join",
				TextColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
				TextScaled = true,
				ZIndex = CONSTANTS2.LAYER.RAISED_HIGH
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
					Text = "Join",
					TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
					TextScaled = true,
					ZIndex = 4
				}, {
					uIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
					})
				})
			})
		}),
		realText = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = CONSTANTS2.ALPHA.INVISIBLE,
			FontFace = CONSTANTS2.FONT.FACE.TITLE,
			Position = UDim2.fromScale(0.0186692, 0.5),
			RichText = true,
			Size = UDim2.fromScale(0.766701, 0.65),
			Text = `Last Seen: <b>{v5}</b>`,
			TextColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = CONSTANTS2.LAYER.RAISED
		}, {
			uIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS2.THICKNESS.OUTLINE.REGULAR
			})
		}),
		statusColorGlow = createElement("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = props.LoadedPlayer.ProfileData.Online and Color3.fromRGB(2, 183, 87) or Color3.fromRGB(
				81,
				81,
				81
			),
			BackgroundTransparency = CONSTANTS2.ALPHA.HALF,
			Position = UDim2.fromScale(0, 0.5),
			Size = UDim2.fromScale(1, 1)
		}, {
			uICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS2.SPACING.CORNER_RADIUS.SCALE.MD
			}),
			uIGradient = createElement("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.28269, 1),
					NumberSequenceKeypoint.new(1, 1)
				})
			})
		})
	})
	children.dividerLine = createElement("Frame", {
		BackgroundColor3 = CONSTANTS2.COLOR.PALETTE.WHITE,
		BackgroundTransparency = CONSTANTS2.ALPHA.HEAVY,
		BorderColor3 = CONSTANTS2.COLOR.PALETTE.BLACK,
		BorderSizePixel = CONSTANTS2.THICKNESS.OUTLINE.NONE,
		LayoutOrder = 2,
		Position = UDim2.fromScale(-2.48234e-8, 0.359035),
		Size = UDim2.fromOffset(541, 1)
	})
	children.showcase = createElement(Showcase, {
		LoadedPlayer = loadedPlayer,
		InventoryItems = props.InventoryItems,
		StatSelectionVisible = props.StatSelectionVisible,
		SetStatSelectionVisible = props.SetStatSelectionVisible,
		SetLoadedPlayer = props.SetLoadedPlayer,
		PatchProfileData = props.PatchProfileData,
		SetSelectedStatSlotId = props.SetSelectedStatSlotId
	})
	return createElement("Frame", v16, children)
end