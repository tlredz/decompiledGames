local parent = script.Parent
local Button = require(parent.Button)
local parent2 = parent.Parent
local hooks = parent2.Hooks
local Util = require(parent2.Util)
local shared = parent2.Parent.Shared
local React = require(shared.React)
local Favorites = require(shared.Favorites)
local useFavorites = require(hooks.useFavorites)
local useSpring = require(hooks.useSpring)
local Enums = require(parent2.Enums)
local State = require(parent2.State)

local function FavoriteButton(p)
	local v = React.useContext(State.Context)
	local features = v.Features
	local status = v.Status
	local v2 = useFavorites()
	local songId = p.SongId
	local v3 = songId and table.find(v2, songId) ~= nil
	local v4 = status == Enums.UserStatus.BoomboxPurchased or status == Enums.UserStatus.Freemium

	if not v4 then
		v3 = false
	end

	local v5 = v3 and 0 or 1
	local imageTransparency, v7 = useSpring(v5, {
		tension = 800,
		friction = 30
	})
	v7:spring(v5)
	local favorites = features.Favorites

	if not favorites then
		return favorites
	end

	favorites = React.createElement(Button, {
		[React.Tag] = Util.ClassNames("FavoriteButton", p[React.Tag]),
		OnActivated = p.SongId and function()
			if v4 then
				local v10

				if v3 then
					v10 = Favorites.Remove
				else
					v10 = Favorites.Add
				end

				v10(p.SongId)
			else
				local widget = v.Widget
				v.SetWidget({
					Widget = Upsell,
					ReturnText = "Return",
					ReturnFunc = function()
						v.SetWidget(widget)
					end
				})
			end
		end,
		ImageTransparency = imageTransparency:map(function(p2: number)
			return 1 - p2
		end)
	}, {
		Overlay = React.createElement("ImageLabel", {
			[React.Tag] = "Design FavoriteOverlay",
			ImageTransparency = imageTransparency
		})
	})
	return favorites
end

return FavoriteButton