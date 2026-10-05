local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)
require(ReplicatedStorage.React.Components.PlayerProfile.Types)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local font = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO)
local v = {
	SettingButtonNobody = CONSTANTS.COLOR.DANGER,
	SettingButtonFriendsOnly = CONSTANTS.COLOR.SECONDARY,
	SettingButtonEveryone = CONSTANTS.COLOR.PURCHASE
}
local v2 = {
	Nobody = "No One",
	FriendsOnly = "Friends Only",
	Everyone = "Everyone"
}
local v3 = {
	Everyone = "FriendsOnly",
	FriendsOnly = "Nobody",
	Nobody = "Everyone"
}
local createElement = React.createElement
return function(props)
	local v4 = props.LoadedPlayer.ProfileData.Settings[props.SettingName] or "Nobody"
	local v5 = v[`SettingButton{v4}`]
	return createElement("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = v5.BACKGROUND,
		BorderColor3 = v5.BORDER,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		FontFace = font,
		LayoutOrder = 3,
		Position = props.Position or UDim2.fromScale(0.99, 0.5),
		Size = props.Size or UDim2.fromScale(0.308, 0.92),
		Text = "",
		TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		TextScaled = true,
		TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		ZIndex = CONSTANTS.LAYER.RAISED,
		[React.Event.MouseButton1Click] = function()
			local v8 = v3[v4] or "Everyone"
			local v9, v10 = ReplicatedStorage.Remotes.UpdatePlayerProfileValue:InvokeServer(
				"Setting",
				props.SettingName,
				v8
			)

			if not v9 then
				print(v9, v10)
				return
			end

			local clone = table.clone(props.LoadedPlayer.ProfileData.Settings)
			clone[props.SettingName] = v8
			props.PatchProfileData({
				Settings = clone
			})
		end
	}, {
		trans = createElement("Frame", {
			BackgroundColor3 = v5.HIGHLIGHT,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromOffset(2, 2),
			Size = UDim2.fromScale(0.972252, 0.4),
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		}),
		textLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			Position = UDim2.fromScale(0.5, 0.525),
			Size = UDim2.fromScale(0.9, 0.8),
			Text = v2[v4],
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			ZIndex = 4
		}, {
			uIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
			})
		})
	})
end