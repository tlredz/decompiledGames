local parent = script.Parent
local parent2 = parent.Parent
local Button = require(parent.Button)
local PlayButton = require(parent.PlayButton)
local PlayWidget = require(parent.PlayWidget)
local Spectrogram = require(parent.Spectrogram)
local FavoriteButton = require(parent.FavoriteButton)
local hooks = parent2.Hooks
local useSignal = require(hooks.useSignal)
local useMetadata = require(hooks.useMetadata)
local useCurrentSong = require(hooks.useCurrentSong)
local shared = parent2.Parent.Shared
local State = require(parent2.State)
local React = require(shared.React)
local GameInfo = require(shared.GameInfo)

local function MiniPlayer(p)
	local v = React.useContext(State.Context)
	local state, setState = React.useState(false)
	local onActivated = React.useCallback(function()
		setState(function(p2)
			return not p2
		end)
	end, {})
	local v3 = useCurrentSong()
	local isOverride = v3.IsOverride
	local sampleMode = v3.SampleMode
	local song = v3.Song
	local v4 = useMetadata(song)
	local title = not v4 and "" or v4.Title or ""
	local artist = v4 and v4.Artist or ""

	if isOverride then
		title = v3.Title or title
		artist = v3.Artist or artist
	end

	local ref = React.useRef(nil)
	local features = v.Features
	React.useEffect(function()
		local widget = v.Widget

		if not (widget and state) then
			return
		end

		local current = {
			Widget = widget.Widget,
			ReturnText = "Minimize Player",
			ArrowRotation = -90,
			ReturnFunc = function()
				setState(false)
				v.SetWidget(widget)
			end
		}
		ref.current = current
		v.SetWidget(current)
	end, { state })
	React.useEffect(function()
		return function()
			local current = ref.current

			if current and current.ReturnFunc then
				current.ReturnFunc()
			end
		end
	end, {})
	local state2, setState2 = React.useState(GameInfo.GetFeaturedImageId)
	useSignal(GameInfo.GameInfoUpdated, function()
		setState2(GameInfo.GetFeaturedImageId)
	end, {})
	local createElement = React.createElement
	local fragment = React.Fragment
	local createElement2 = React.createElement
	local v7 = {
		[React.Tag] = "MiniPlayerContainer"
	}
	local createElement3 = React.createElement
	local v9 = {
		[React.Tag] = "BodyRenderContainer"
	}
	local children3 = {
		Scale = p.Scale and React.createElement("UIScale", {
			Scale = p.Scale
		}),
		Toggle = React.createElement(Button, {
			[React.Tag] = "ToggleButton",
			OnActivated = onActivated
		}),
		SongInfo = React.createElement("Frame", {
			[React.Tag] = "CustomSongInfoContainer ofMiniPlayer"
		}, {
			SongTitle = React.createElement("TextLabel", {
				[React.Tag] = "SongInfoTitle ofMiniPlayer",
				Text = title .. (sampleMode and " [PREVIEW]" or "")
			}),
			SongArtist = React.createElement("TextLabel", {
				[React.Tag] = "SongInfoArtist ofMiniPlayer",
				Text = artist
			})
		}),
		NoList = React.createElement("Folder", {}, {
			AreaSoak = React.createElement("TextButton", {
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				ZIndex = 0,
				Text = "",
				[React.Event.Activated] = onActivated
			})
		}),
		Play = 0,
		Forward = 0,
		Favorite = 0
	}
	local play = not isOverride

	if play then
		play = React.createElement(PlayButton, {
			[React.Tag] = "ofMiniPlayer"
		})
	end

	children3.Play = play
	local forward = not isOverride

	if forward then
		forward = React.createElement(Button, {
			[React.Tag] = "ForwardButton ofMiniPlayer",
			OnActivated = v.GoForward
		})
	end

	children3.Forward = forward
	local favorite = not isOverride and song and not sampleMode

	if favorite then
		favorite = React.createElement("Frame", {
			[React.Tag] = "FavoriteButtonWrapper"
		}, {
			Button = React.createElement(FavoriteButton, {
				[React.Tag] = "ofMiniPlayer",
				SongId = song
			})
		})
	end

	children3.Favorite = favorite
	local children2 = {
		Render = createElement3("Frame", v9, children3),
		Backdrop = React.createElement("Frame", {
			[React.Tag] = "Design Backdrop ofMiniPlayer"
		}, {}),
		Spectrogram = 0
	}
	local spectrogram

	if features.Spectrogram and not state then
		spectrogram = React.createElement(Spectrogram, {
			[React.Tag] = "Design Spectrogram ofMiniPlayer"
		}, {})
	end

	children2.Spectrogram = spectrogram
	local children = {
		MiniPlayer = createElement2("Frame", v7, children2),
		FullPlayer = 0
	}
	local createElement11 = React.createElement
	local spectrogram2

	if features.Spectrogram and state and not state2 then
		spectrogram2 = React.createElement(Spectrogram, {
			[React.Tag] = "Design Spectrogram ofPlayer"
		}, {})
	end

	children.FullPlayer = createElement11("Folder", {}, {
		Spectrogram = spectrogram2,
		Widget = React.createElement(PlayWidget, {
			Expanded = state,
			SetExpanded = setState,
			HomeNode = ref,
			PromoImage = state2
		})
	})
	return createElement(fragment, nil, children)
end

return MiniPlayer