local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local React = require(shared.React)
local parent2 = script.Parent
local Enums = require(parent.Enums)
local State = require(parent.State)
local Util = require(parent.Util)
local ItemPage = require(parent2.ItemPage)
local SongList = require(parent2.SongList)
local ScrollFrame = require(parent2.ScrollFrame)
local PlaylistItem = require(parent2.PlaylistItem)
local hooks = parent.Hooks
local useSignal = require(hooks.useSignal)
local usePlaylists = require(hooks.usePlaylists)
local useFavorites = require(hooks.useFavorites)
local useBulkOwnership = require(hooks.useBulkOwnership)
local usePlaylistLockState = require(hooks.usePlaylistLockState)
local GamePasses = require(shared.GamePasses)
local MusicData = require(shared.MusicData)
local Ownership = require(shared.Ownership)

local function Playlists(data)
	local v = React.useContext(State.Context)
	local v2 = v.Status == Enums.UserStatus.BoomboxPurchased
	local v3 = usePlaylists()
	local v4 = useFavorites()
	local windowState = v.WindowState
	local position = data.Position
	local anchorPoint = data.AnchorPoint
	local size = data.Size
	local layoutOrder = data.LayoutOrder
	local ref = React.useRef(nil)
	useSignal(v.ReturnEvent, function()
		local current = ref.current

		if current and current.CanvasPosition.X > 0 then
			current.CanvasPosition = Vector2.zero
		end
	end)
	local v6 = useBulkOwnership((React.useMemo(function()
		return Ownership.BulkGet(v3, function(p)
			return p.Id
		end)
	end, { v3 })))
	local children = {}

	for _, playlist in v3 do
		if not data.ExcludeUnowned or v6[playlist.Id] or v2 and playlist.IsIncluded then
			children[playlist.Id] = React.createElement(PlaylistItem, {
				Index = playlist.SortPriority,
				Playlist = playlist,
				SetPlaylist = data.SetPlaylist or function(p)
					local widget = v.Widget

					local function PlaylistSongs()
						local sampleMode = usePlaylistLockState(p)
						local songIds = MusicData.GetSongIds(p)
						local limitedInfo = p.LimitedInfo
						local gamePass = GamePasses.FindGamePass(limitedInfo)

						if gamePass and gamePass.RelicsAssetType == "PLAYLIST" and sampleMode then
							return React.createElement(ItemPage, {
								Target = {
									Id = limitedInfo,
									Type = "PLAYLIST",
									GamePass = gamePass
								},
								Size = UDim2.fromScale(1, 1)
							})
						end

						return React.createElement(SongList, {
							[React.Tag] = "ofLibraryPage",
							Songs = songIds,
							SampleMode = sampleMode
						})
					end

					v.SetWidget({
						ReturnText = p.Name,
						Widget = function()
							return React.createElement(React.Fragment, {}, {
								SongList = React.createElement(PlaylistSongs)
							})
						end,
						ReturnFunc = function()
							v.SetWidget(widget)
						end
					})
				end
			})
		end
	end

	children.__favorites__ = React.createElement(PlaylistItem, {
		Index = 1000000,
		Playlist = {
			Id = "__favorites__",
			Name = "Favorites",
			SortPriority = 1000000,
			Image = "rbxassetid://120184804573917"
		},
		SetPlaylist = function()
			local widget = v.Widget
			v.SetWidget({
				ReturnText = "Favorites",
				Widget = function()
					local clone = table.clone(v4 or {})
					return React.createElement(React.Fragment, {}, {
						SongList = React.createElement(SongList, {
							[React.Tag] = "ofLibraryPage",
							Songs = clone
						})
					})
				end,
				ReturnFunc = function()
					v.SetWidget(widget)
				end
			})
		end
	})
	return React.createElement(ScrollFrame, {
		[React.Tag] = Util.ClassNames(
			"PlaylistsContainer",
			windowState == Enums.WindowState.Full and "isFull" or nil,
			data[React.Tag]
		),
		Position = position,
		AnchorPoint = anchorPoint,
		Size = size,
		LayoutOrder = layoutOrder,
		ScrollRef = ref,
		List = {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Left,
			SortOrder = Enum.SortOrder.LayoutOrder
		}
	}, children)
end

return Playlists