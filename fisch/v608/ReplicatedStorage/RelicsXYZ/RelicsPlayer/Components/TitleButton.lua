local parent = script.Parent.Parent
local parent2 = parent.Parent
local components = parent.Components
local Button = require(components.Button)
local DisabledOverlay = require(components.DisabledOverlay)
local shared = parent2.Shared
local React = require(shared.React)
require(shared.MusicData)
local State = require(parent.State)
local Util = require(parent.Util)
local Enums = require(parent.Enums)
local hooks = parent.Hooks
local usePlaylistLockState = require(hooks.usePlaylistLockState)

local function TitleButton(data)
	local v = React.useContext(State.Context)
	local locked = usePlaylistLockState(data.Playlist)

	if not data.Playlist then
		locked = data.Locked
	end

	if data.Playlist then
		local playlist = data.Playlist
		locked = v.Status ~= Enums.UserStatus.BoomboxPurchased and not playlist.IsFree or locked
	end

	local createElement = React.createElement
	local v3 = {
		[React.Tag] = Util.ClassNames("TitleButton", data[React.Tag]),
		Size = data.Size
	}
	local layoutOrder

	if locked then
		layoutOrder = 1000 + (data.LayoutOrder or 0)
	else
		layoutOrder = data.LayoutOrder
	end

	v3.LayoutOrder = layoutOrder
	v3.Image = data.Image
	v3.ForegroundImage = data.ForegroundImage
	v3.ForegroundImageScale = data.ForegroundImageScale
	v3.StrokeColor = data.StrokeColor

	function v3.OnActivated()
		local widget = v.Widget
		v.SetWidget({
			Widget = data.Widget,
			ReturnText = data.Title,
			ReturnFunc = function()
				v.SetWidget(widget)
			end
		})
	end

	return createElement(Button, v3, {
		Title = React.createElement("TextLabel", {
			[React.Tag] = Util.ClassNames(string.find(string.upper(data.Title), "AURA") and "Aura" or nil),
			Text = data.Title
		}),
		DisabledOverlay = locked and React.createElement(DisabledOverlay, {
			Visible = locked
		})
	}, data.children)
end

return TitleButton