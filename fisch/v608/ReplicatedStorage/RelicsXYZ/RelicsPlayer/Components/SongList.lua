local parent = script.Parent
local parent2 = parent.Parent
local shared = parent2.Parent.Shared
local Util = require(parent2.Util)
local State = require(parent2.State)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local React = require(shared.React)
local MusicData = require(shared.MusicData)
local RunContext = require(shared.RunContext)
local Button = require(parent.Button)
local Upsell = require(parent.Upsell)
local ScrollFrame = require(parent.ScrollFrame)
local FavoriteButton = require(parent.FavoriteButton)
local hooks = parent2.Hooks
local useSignal = require(hooks.useSignal)
local useMetadata = require(hooks.useMetadata)
local useProductInfo = require(hooks.useProductInfo)
local useMutexOwnership = require(hooks.useMutexOwnership)

local function SongItem(data)
	local v = React.useContext(State.Context)
	local song = data.Song
	local state, setState = React.useState(function()
		return MusicData.GetSongById(song)
	end)
	React.useEffect(function()
		setState((MusicData.GetSongById(song)))
	end, { song })
	local _, v2 = useMutexOwnership(state, localPlayer.UserId)
	local v3 = useMetadata(song)
	local v4 = v.Song == song
	local v6 = useProductInfo((tonumber(song:match("%d+$") or 0)))
	local search = data.Search
	local v7 = state ~= nil
	local v8 = not v7 and (v6 == nil and RunContext.IsStudio or v6 and v6.AssetTypeId == 3) and true or v7

	if not React.useMemo(function()
		if not search or #search == 0 then
			return true
		end

		local lower = search:lower()
		local title = (v3.Title or ""):lower()
		local artist = (v3.Artist or ""):lower()
		local playlistName = (data.PlaylistName or ""):lower()

		if title:find(lower, 1, true) or artist:find(lower, 1, true) or playlistName:find(lower, 1, true) then
			return true
		end

		return math.min(
			Util.LevenshteinDistance(lower, title),
			Util.LevenshteinDistance(lower, artist),
			(Util.LevenshteinDistance(lower, playlistName))
		) <= 3
	end, {
		search,
		v3.Title,
		v3.Artist,
		data.PlaylistName
	}) then
		v8 = false
	end

	if not v8 then
		return nil
	end

	local createElement = React.createElement
	local v10 = {
		[React.Tag] = Util.ClassNames(
			data[React.Tag] or "",
			"SongItem",
			(data.Index % 2 == 0 and "MidPanel" or "ForePanel") .. (v4 and " Active" or ""),
			v2 and "" or "isLocked"
		)
	}
	local onActivated

	if v2 then
		onActivated = data.OnActivated
	end

	v10.OnActivated = onActivated
	v10.LayoutOrder = data.Index
	v10.HoverScale = 1
	v10.PressScale = 1
	local disabledOverlay = not v2

	if disabledOverlay then
		disabledOverlay = React.createElement("Frame", {
			[React.Tag] = "DisabledOverlay",
			Active = false
		}, {
			LockIcon = React.createElement("ImageLabel", {
				[React.Tag] = "LockIcon"
			}),
			LockInfo = React.createElement("TextLabel", {
				[React.Tag] = "LockInfo"
			})
		})
	end

	local v14 = not data.HideIndex

	if v14 then
		v14 = React.createElement("TextLabel", {
			[React.Tag] = "SongInfoIndex Index",
			Text = `{data.Index}.`
		})
	end

	local v12 = {
		DisabledOverlay = disabledOverlay,
		Index = v14,
		Song = React.createElement("CanvasGroup", {
			[React.Tag] = "SongInfoContainer Song"
		}, {
			Title = React.createElement("TextLabel", {
				[React.Tag] = "SongInfoTitle Title",
				Text = v3.Title or "..."
			}),
			Artist = React.createElement("TextLabel", {
				[React.Tag] = "SongInfoArtist Artist",
				Text = v3.Artist or "..."
			})
		}),
		Favorite = 0,
		SampleMode = 0
	}
	local favorite = v2 and not data.SampleMode

	if favorite then
		favorite = React.createElement(FavoriteButton, {
			[React.Tag] = "SongList",
			SongId = song
		})
	end

	v12.Favorite = favorite
	local sampleMode = data.SampleMode

	if sampleMode then
		sampleMode = React.createElement("TextLabel", {
			[React.Tag] = "SampleText"
		})
	end

	v12.SampleMode = sampleMode
	return (createElement(Button, v10, v12))
end

local function SongList(data)
	local ref = React.useRef(nil)
	local v = React.useContext(State.Context)
	local sampleMode = data.SampleMode and true or false
	local clone = table.clone(data.Songs)
	local search = data.Search
	local children = {}

	if search then
		local v3 = tonumber(search:match("%d+$"))

		if v3 and v3 > 0 then
			clone = {
				{
					Id = `rbxassetid://{v3}`
				}
			}
			search = ""
		end
	end

	if data.SampleMode and not data.IsGamePass then
		children.Upsell = React.createElement("Frame", {
			Size = UDim2.new(1, 0, 0, 180),
			BackgroundTransparency = 1
		}, { React.createElement(Upsell, {
				Size = UDim2.fromScale(1, 1),
				ReturnWhenPurchased = false
			}) })
	end

	for i, v3 in ipairs(clone) do
		local id

		if typeof(v3) == "table" then
			id = v3.Id
		else
			id = v3
		end

		local playlistName

		if typeof(v3) == "table" then
			playlistName = v3.PlaylistName
		end

		local formatted = `Song{i}`
		local createElement = React.createElement
		local v5 = {
			[React.Tag] = data[React.Tag],
			HideIndex = data.HideIndex,
			Index = i,
			Song = id,
			PlaylistName = playlistName,
			SampleMode = sampleMode,
			Size = data.ItemSize,
			Search = search
		}

		function v5.OnActivated()
			if data.OnSongSelected then
				data.OnSongSelected(id)
				return
			end

			local ids = {}

			for i2, id2 in ipairs(clone) do
				if typeof(id2) == "table" then
					id2 = id2.Id
				end

				table.insert(ids, id2)
			end

			if sampleMode then
				v.AddSongOverride("SampleSong", {
					Song = id,
					Priority = 2000,
					SampleMode = true,
					SuppressRemote = true
				})
				return
			end

			v.SetSongList(ids)
			v.SetSong(id)
			v.SetPlaying(true)
		end

		children[formatted] = createElement(SongItem, v5)
	end

	React.useEffect(function()
		if sampleMode or not v.SampleMode then
			return
		end

		local song = v.Song

		if not song then
			return
		end

		local flag = false

		for _, id in ipairs(clone) do
			if typeof(id) == "table" then
				id = id.Id
			end

			if id ~= song then
				continue
			end

			flag = true
			break
		end

		if flag then
			v.SetSampleMode(false)
		end
	end, {
		sampleMode,
		v.SampleMode,
		v.Song,
		clone
	})
	React.useEffect(function()
		if sampleMode then
			return function()
				v.RemoveSongOverride("SampleSong")
			end
		end
	end, { sampleMode })
	useSignal(v.ReturnEvent, function()
		local current = ref.current

		if current and current.CanvasPosition.Y > 0 then
			current.CanvasPosition = Vector2.zero
		else
			v.WidgetReturn()
		end
	end)
	return React.createElement(ScrollFrame, {
		[React.Tag] = Util.ClassNames("SongList", data[React.Tag]),
		ScrollRef = ref,
		List = {
			FillDirection = Enum.FillDirection.Vertical,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder
		}
	}, children)
end

return SongList