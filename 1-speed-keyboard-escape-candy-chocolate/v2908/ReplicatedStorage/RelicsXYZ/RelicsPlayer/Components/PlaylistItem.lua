local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local parent2 = script.Parent
local Button = require(parent2.Button)
local DisabledOverlay = require(parent2.DisabledOverlay)
local hooks = parent.Hooks
local useStyleSheet = require(hooks.useStyleSheet)
local usePlaylistLockState = require(hooks.usePlaylistLockState)
local State = require(parent.State)
local Enums = require(parent.Enums)
local Marketplace = require(shared.Marketplace)
local React = require(shared.React)
local Upsell = require(parent2.Upsell)
require(shared.MusicData)

local function Playlist(props)
	local v = useStyleSheet("Icons", "string")
	local index = props.Index
	local v2 = React.useContext(State.Context)
	local status = v2.Status
	local isPublic = props.IsPublic or false
	local v3 = status == Enums.UserStatus.BoomboxPurchased
	local playlist = props.Playlist
	local v4 = (isPublic or playlist.Name:upper() == "FAVORITES" or v3) and true or playlist.IsFree
	local visible, v6, v7 = usePlaylistLockState(playlist)
	local createElement = React.createElement
	local v9 = {
		[React.Tag] = "PlaylistWrapper"
	}

	if playlist.IsFree then
		index = index + -1000 or index
	end

	v9.LayoutOrder = index
	local createElement2 = React.createElement
	local v12 = {
		[React.Tag] = "Playlist"
	}
	local image

	if v4 then
		image = playlist.Image
	else
		image = v("Image-LockedPlaylist")
	end

	v12.Image = image
	v12.HoverScale = 1.025
	v12.PressScale = 0.925

	function v12.OnActivated()
		local widget = v2.Widget

		if v4 then
			props.SetPlaylist(playlist)
		else
			v2.SetWidget({
				Widget = Upsell,
				ReturnText = "Collect",
				ReturnFunc = function()
					v2.SetWindowTab(Enums.WindowTab.Collect)
					v2.SetWidget(widget)
				end
			})
		end
	end

	return createElement("Frame", v9, {
		Button = createElement2(Button, v12, {
			Title = v4 and React.createElement("TextLabel", {
				Text = playlist.Name:upper()
			}),
			DisabledOverlay = React.createElement(DisabledOverlay, {
				Visible = visible,
				OnPurchase = playlist.RequiresPurchase and v6 and function()
					Marketplace.PromptPurchase(v6, v7)
				end
			})
		})
	})
end

return Playlist