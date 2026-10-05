local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FriendInvite = require(ReplicatedStorage.Modules.FriendInvite)
require(script.Parent.Types)
local React = require(ReplicatedStorage.Packages.React)
local useCanSendInvite = require(ReplicatedStorage.React.Hooks.Player.useCanSendInvite)
local useIsFriend = require(ReplicatedStorage.React.Hooks.Player.useIsFriend)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(props)
	local v = useIsFriend(props.Info.UserId)
	local v2 = useCanSendInvite(props.Info.UserId)
	local v3 = Players:GetPlayerByUserId(props.Info.UserId) ~= nil
	local v4 = props.Info.IsOnline and props.Info.IsFriend and not v3
	local v5 = not props.Info.IsOnline and props.Info.IsFriend and not v3 and v2
	local v8 = {
		Active = true,
		BackgroundColor3 = Color3.fromRGB(17, 17, 17),
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		LayoutOrder = props.LayoutOrder,
		Position = UDim2.fromScale(8.72251e-8, 0.00206953),
		Selectable = true,
		Size = UDim2.fromScale(0.965, 0.198),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		Text = "",
		TextScaled = true,
		[React.Event.MouseButton1Click] = function()
			if Players.LocalPlayer == nil then
				return
			end

			pcall(function()
				game.Players.LocalPlayer.PlayerGui.PlayerProfile.OpenPlayerProfile:Fire(props.Info.UserId)
			end)
			props.SetLookupOpen(false)
		end
	}
	local children = {
		uIStroke = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
		}),
		uICorner = createElement("UICorner", {
			BottomLeftRadius = UDim.new(0.06, 0),
			BottomRightRadius = UDim.new(0.06, 0),
			CornerRadius = UDim.new(0.06, 0),
			TopLeftRadius = UDim.new(0.06, 0),
			TopRightRadius = UDim.new(0.06, 0)
		}),
		uIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 5.37434
		}),
		fade = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
			BackgroundTransparency = CONSTANTS.ALPHA.HALF,
			Position = UDim2.fromScale(6.87204e-8, -7.38655e-7),
			Size = UDim2.fromScale(0.263128, 1),
			Visible = false,
			ZIndex = CONSTANTS.LAYER.BASE
		}, {
			uIGradient = createElement("UIGradient", {
				Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(
						1,
						1
					) })
			}),
			uICorner = createElement("UICorner", {
				BottomLeftRadius = UDim.new(0.07, 0),
				BottomRightRadius = UDim.new(0.07, 0),
				CornerRadius = UDim.new(0.07, 0),
				TopLeftRadius = UDim.new(0.07, 0),
				TopRightRadius = UDim.new(0.07, 0)
			})
		}),
		friendIcon = 0,
		icon = 0,
		displayName = 0,
		username = 0,
		joinButton = 0,
		inviteButton = 0
	}
	local friendIcon

	if v then
		friendIcon = createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://12195213824",
			Position = UDim2.fromScale(0.014, 0.06),
			Size = UDim2.fromScale(0.0495403, 0.266247)
		})
	end

	children.friendIcon = friendIcon
	children.icon = createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = `rbxthumb://type=AvatarHeadShot&id={props.Info.UserId}&w=150&h=150`,
		Position = UDim2.fromScale(2.71166e-7, 0.499999),
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromScale(0.207278, 1)
	}, {
		uIAspectRatioConstraint = createElement("UIAspectRatioConstraint"),
		uICorner = createElement("UICorner", {
			BottomLeftRadius = UDim.new(0.06, 0),
			BottomRightRadius = UDim.new(0.06, 0),
			CornerRadius = UDim.new(0.06, 0),
			TopLeftRadius = UDim.new(0.06, 0),
			TopRightRadius = UDim.new(0.06, 0)
		})
	})
	children.displayName = createElement("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.478459, 0.353422),
		Size = UDim2.fromScale(0.550775, 0.43),
		Text = props.Info.Username,
		TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left
	}, {
		uIStroke = createElement("UIStroke")
	})
	children.username = createElement("TextLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		FontFace = CONSTANTS.FONT.FACE.TITLE,
		Position = UDim2.fromScale(0.478098, 0.734082),
		Size = UDim2.fromScale(0.551, 0.27),
		Text = props.Info.Context,
		TextColor3 = CONSTANTS.COLOR.PALETTE.GREY_400,
		TextScaled = true,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	local joinButton

	if v4 then
		joinButton = createElement("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
			BorderColor3 = CONSTANTS.COLOR.PRIMARY.BORDER,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
			FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
			LayoutOrder = 1,
			Position = UDim2.fromScale(0.975, 0.5),
			Size = UDim2.fromScale(0.193403, 0.529872),
			Text = "",
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true,
			TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			ZIndex = CONSTANTS.LAYER.RAISED,
			[React.Event.MouseButton1Click] = function()
				ReplicatedStorage.Remotes.JoinPlayerFromProfile:FireServer(props.Info.UserId)
			end
		}, {
			trans = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.96, 0.45)
			}),
			uISizeConstraint = createElement("UISizeConstraint", {
				MinSize = Vector2.new(24, 24)
			}),
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.56),
				Size = UDim2.fromScale(0.95, 0.8),
				Text = "Join",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
				}),
				textLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY,
					Position = UDim2.fromScale(0.5, 0.425),
					Size = UDim2.fromScale(1, 1),
					Text = "Join",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					ZIndex = 4
				}, {
					uIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
					})
				})
			})
		})
	end

	children.joinButton = joinButton
	local inviteButton

	if v5 then
		inviteButton = createElement("TextButton", {
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3 = CONSTANTS.COLOR.SECONDARY.BACKGROUND,
			BorderColor3 = CONSTANTS.COLOR.SECONDARY.BORDER,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
			FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
			LayoutOrder = 1,
			Position = UDim2.fromScale(0.975, 0.5),
			Size = UDim2.fromScale(0.221402, 0.529872),
			Text = "",
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true,
			TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			ZIndex = CONSTANTS.LAYER.RAISED,
			[React.Event.MouseButton1Click] = function()
				FriendInvite.PromptForUserId(props.Info.UserId)
			end
		}, {
			trans = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = CONSTANTS.COLOR.SECONDARY.HIGHLIGHT,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.96, 0.45)
			}),
			uISizeConstraint = createElement("UISizeConstraint", {
				MinSize = Vector2.new(24, 24)
			}),
			textLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.56),
				Size = UDim2.fromScale(0.95, 0.8),
				Text = "Invite",
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true,
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			}, {
				uIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
				}),
				textLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY,
					Position = UDim2.fromScale(0.5, 0.425),
					Size = UDim2.fromScale(1, 1),
					Text = "Invite",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					ZIndex = 4
				}, {
					uIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN
					})
				})
			})
		})
	end

	children.inviteButton = inviteButton
	return createElement("TextButton", v8, children)
end