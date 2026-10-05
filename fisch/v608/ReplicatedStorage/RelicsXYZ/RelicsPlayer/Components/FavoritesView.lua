local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local React = require(shared.React)
local Favorites = require(shared.Favorites)
require(shared.MusicData)
local components = parent.Components
local SongList = require(components.SongList)
local SongInfo = require(components.SongInfo)
local DraggableList = require(components.DraggableList)
local hooks = parent.Hooks
local usePlaylists = require(hooks.usePlaylists)

local function FavoritesView(props)
	local search = props.Search
	local favorites = props.Favorites
	local v = search and #search > 0
	local v2 = usePlaylists()
	local songs = React.useMemo(function()
		local v4 = {}
		local result = {}

		for _, v5 in ipairs(v2) do
			for k in pairs(v5.Songs) do
				if v4[k] then
					continue
				end

				table.insert(result, {
					Id = k,
					PlaylistName = v5.Name
				})
				v4[k] = true
			end
		end

		return result
	end, { v2 })
	local createElement = React.createElement
	local fragment = React.Fragment
	local v5 = {
		Search = React.createElement("Frame", {
			[React.Tag] = "Design SearchBar ofCustomizePage"
		}, {
			Icon = React.createElement("ImageLabel", {
				[React.Tag] = "SearchIcon"
			}),
			SearchBox = React.createElement("TextBox", {
				[React.Tag] = "SearchBox",
				[React.Change.Text] = props.OnSearchChanged,
				[React.Event.Focused] = props.OnSearchFocused
			})
		}),
		SearchResults = 0,
		List = 0
	}
	local searchResults

	if v then
		searchResults = React.createElement(SongList, {
			[React.Tag] = "SongItemsContainer ofCustomizePage",
			HideIndex = true,
			Songs = songs,
			Search = search
		})
	else
		searchResults = v
	end

	v5.SearchResults = searchResults
	local list = not v

	if list then
		list = React.createElement(DraggableList, {
			[React.Tag] = "SongItemsContainer ofCustomizePage",
			Items = favorites,
			RowHeight = 45,
			OnReorder = function(p)
				Favorites.Reorder(p)
			end,
			InnerComponent = SongInfo,
			InnerProps = {}
		})
	end

	v5.List = list
	return createElement(fragment, {}, v5)
end

return FavoritesView