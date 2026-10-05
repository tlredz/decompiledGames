local parent = script.Parent.Parent
local State = require(parent.State)
local Enums = require(parent.Enums)
local shared = parent.Parent.Shared
local React = require(shared.React)
local hooks = parent.Hooks
local useFavorites = require(hooks.useFavorites)
local components = parent.Components
local FavoritesView = require(components.FavoritesView)

local function FavoritesWidget(_)
	local state2 = React.useContext(State.Context)
	local state, setState = React.useState("")
	local status = state2.Status
	local features = state2.Features
	local favorites = useFavorites()
	local v3 = status == Enums.UserStatus.BoomboxPurchased

	if features.Favorites then
		return React.createElement(FavoritesView, {
			State = state2,
			Favorites = favorites,
			Search = state,
			SetSearch = setState,
			OnSearchFocused = function(object)
				if v3 then
					return
				end

				object:ReleaseFocus(false)
				state2.SetWindowTab(Enums.WindowTab.Upsell)
			end,
			OnSearchChanged = function(p)
				if v3 then
					setState(p.Text:lower())
				end
			end
		})
	end

	state2.SetWindowTab(Enums.WindowTab.Collect)
	return nil
end

return FavoritesWidget