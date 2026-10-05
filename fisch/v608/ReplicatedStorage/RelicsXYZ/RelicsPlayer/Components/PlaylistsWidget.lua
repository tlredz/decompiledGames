local parent = script.Parent.Parent
local State = require(parent.State)
local Enums = require(parent.Enums)
local shared = parent.Parent.Shared
local React = require(shared.React)
local MusicData = require(shared.MusicData)
local hooks = parent.Hooks
local useSpring = require(hooks.useSpring)
local useSignal = require(hooks.useSignal)
local components = parent.Components
local Upsell = require(components.Upsell)
local SongList = require(components.SongList)
local Playlists = require(components.Playlists)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local function PlaylistsWidget()
	local v, v2 = useSpring(0.75)
	local state, setState = React.useState("")
	local ref = React.useRef(nil)
	local v3 = React.useContext(State.Context)
	local v4 = v3.Status == Enums.UserStatus.BoomboxPurchased
	useSignal(UserInputService.InputBegan, function(p)
		if p.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		local current = ref.current

		if not current then
			return
		end

		local mouseLocation = UserInputService:GetMouseLocation()
		local absolutePosition = current.AbsolutePosition
		local absoluteSize = current.AbsoluteSize
		local v5

		if mouseLocation.X >= absolutePosition.X and mouseLocation.X <= absolutePosition.X + absoluteSize.X and mouseLocation.Y >= absolutePosition.Y then
			v5 = mouseLocation.Y <= absolutePosition.Y + absoluteSize.Y
		else
			v5 = false
		end

		if not v5 then
			v2:spring(0.75, {
				tension = 400,
				friction = 40
			})
		end
	end, {})
	local songs = React.useMemo(function()
		local userId = Players.LocalPlayer.UserId
		local v6 = {}
		local result = {}

		for _, v7 in MusicData.GetPlaylists() do
			for k, song in v7.Songs do
				if v6[k] or not (not MusicData.GetRequiresOwnership(song) or not MusicData.IsSongLockedByBadge(song.Id) or MusicData.UserHasUnlocked(
					song,
					userId
				)) then
					continue
				end

				table.insert(result, {
					Id = k,
					PlaylistName = v7.Name
				})
				v6[k] = true
			end
		end

		return result
	end, {})
	local createElement = React.createElement
	local v7 = {
		[React.Tag] = "PlaylistsAndSearchContainer"
	}
	local createElement2 = React.createElement
	local v9 = {
		[React.Tag] = "BodyContentContainer"
	}
	local createElement3 = React.createElement
	local v11 = state == "" and Playlists or SongList
	local v12

	if state == "" then
		v12 = {}
		v12[React.Tag] = "ofLibraryPage ofPlaylistsPage"
		v12.ExcludeUnowned = true

		if not v12 then
			v12 = {
				Songs = songs,
				Search = state
			}
			v12[React.Tag] = "ofLibraryPage ofRecentsTab"
		end
	else
		v12 = {
			Songs = songs,
			Search = state
		}
		v12[React.Tag] = "ofLibraryPage ofRecentsTab"
	end

	return createElement("CanvasGroup", v7, {
		Buttons = createElement2("Frame", v9, { createElement3(v11, v12) }),
		Search = React.createElement("Frame", {
			[React.Tag] = "Design Search",
			BackgroundTransparency = v:map(function(p: number)
				return p / 0.75
			end),
			Position = v:map(function(p: number)
				return UDim2.fromScale(0, p)
			end),
			ref = ref
		}, {
			SearchBarFrame = React.createElement("Frame", {
				[React.Tag] = "SearchBarWrapper"
			}, {
				SearchBar = React.createElement("Frame", {
					[React.Tag] = "Design SearchBar"
				}, {
					Icon = React.createElement("ImageLabel", {
						[React.Tag] = "SearchIcon"
					}),
					SearchBox = React.createElement("TextBox", {
						[React.Tag] = "SearchBox",
						Text = state,
						[React.Event.Focused] = function()
							if v4 then
								v2:spring(0, {
									tension = 400,
									friction = 40
								})
								return
							end

							local widget = v3.Widget
							v3.SetWidget({
								Widget = Upsell,
								ReturnText = "Your Library",
								ReturnFunc = function()
									v3.SetWidget(widget)
								end
							})
						end,
						[React.Change.Text] = function(p)
							if v4 then
								setState(p.Text)
							else
								p.Text = state
							end
						end
					})
				})
			}),
			SongResults = React.createElement(SongList, {
				[React.Tag] = "SongResults ofLibraryPage",
				Songs = songs,
				Search = state
			})
		})
	})
end

return PlaylistsWidget