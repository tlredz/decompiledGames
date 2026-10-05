local parent = script.Parent
local parent2 = parent.Parent
local shared = parent2.Parent.Shared
local React = require(shared.React)
local Util = require(parent2.Util)
local State = require(parent2.State)
local SongList = require(parent.SongList)
local ScrollFrame = require(parent.ScrollFrame)
local PlaylistItem = require(parent.PlaylistItem)
local hooks = parent2.Hooks
local usePlaylists = require(hooks.usePlaylists)

local function PublicMusicGrid(p)
	local current2 = React.useContext(State.Context)
	local v2 = usePlaylists({
		PublicPlaylists = true
	})
	React.useEffect(function()
		local v3 = {}

		for _, v4 in ipairs(v2) do
			table.insert(v3, { v4.Name, v4.IsPublic })
		end
	end, { v2 })
	local ref = React.useRef(current2)
	ref.current = current2
	local v3 = React.useMemo(function()
		local children = {}

		for k, v4 in v2 do
			local playlist = {
				Id = v4.Id,
				Name = v4.Name,
				SortPriority = k,
				Image = v4.Image or "rbxassetid://120184804573917",
				IsFree = true
			}
			local v6 = v4
			children[v4.Id] = React.createElement(PlaylistItem, {
				Index = k,
				Playlist = playlist,
				IsPublic = true,
				SetPlaylist = function()
					local current = ref.current
					local widget = current.Widget
					current.SetWidget({
						ReturnText = v6.Name,
						Widget = function()
							local ids = {}

							for k2, song in v6.Songs do
								local id = song.Id

								if not id:match("^rbxassetid://") then
									id = "rbxassetid://" .. id
								end

								table.insert(ids, id)
							end

							return React.createElement(React.Fragment, {}, {
								SongList = React.createElement(SongList, {
									[React.Tag] = "ofLibraryPage",
									Songs = ids
								})
							})
						end,
						ReturnFunc = function()
							current.SetWidget(widget)
						end
					})
				end
			})
		end

		return children
	end, { v2 })
	return React.createElement(ScrollFrame, {
		[React.Tag] = Util.ClassNames("PlaylistsContainer ofPlaylistGrid", p[React.Tag]),
		Grid = {
			CellSize = UDim2.new(0, 120, 0, 120),
			CellPadding = UDim2.new(0, 5, 0, 5),
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			SortOrder = Enum.SortOrder.LayoutOrder,
			StartCorner = Enum.StartCorner.TopLeft
		}
	}, v3)
end

return PublicMusicGrid