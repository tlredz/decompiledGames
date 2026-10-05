local parent = script.Parent
local parent2 = parent.Parent
local Button = require(parent.Button)
local PlayButton = require(parent.PlayButton)
local shared = parent2.Parent.Shared
local React = require(shared.React)
local hooks = parent2.Hooks
local useCurrentSong = require(hooks.useCurrentSong)
local useStyleSheet = require(hooks.useStyleSheet)
local useMetadata = require(hooks.useMetadata)
local useSpring = require(hooks.useSpring)
local useClock = require(hooks.useClock)
local Util = require(parent2.Util)
local State = require(parent2.State)
local Enums = require(parent2.Enums)

local function SongInfo(_, _)
	local v = useCurrentSong()
	local song = v.Song
	local v2 = useMetadata(song)
	local ref = React.useRef(nil)
	local title = v2.Title
	local artist = v2.Artist

	if v.IsOverride then
		title = v.Title or title
		artist = v.Artist or artist
	end

	useClock(30, function(_)
		local v3 = math.sin(os.clock() / 2) / 2 + 0.5
		local current = ref.current

		if current then
			current.Position = UDim2.fromScale(v3, 0.5)
			current.AnchorPoint = Vector2.new(v3, 0.5)
		end
	end, {})
	local createElement = React.createElement
	local v4 = {
		[React.Tag] = "CustomSongInfoContainer"
	}
	local createElement2 = React.createElement
	local artist2

	if song then
		artist2 = React.createElement("TextLabel", {
			[React.Tag] = "SongInfoArtist ofHeaderBar",
			Text = artist
		})
	else
		artist2 = song
	end

	if song then
		song = React.createElement("TextLabel", {
			[React.Tag] = "SongInfoTitle ofHeaderBar",
			Text = title
		})
	end

	return createElement("Frame", v4, {
		Inside = createElement2("Frame", {
			ref = ref
		}, {
			Artist = artist2,
			Title = song
		})
	})
end

local function HeaderBar(state)
	local v = useStyleSheet("Tweaks")
	local v2 = React.useContext(State.Context)
	local v3 = v2.Status == Enums.UserStatus.TrialMode
	local v4 = v2.Status == Enums.UserStatus.Freemium
	local widget = v2.Widget
	local returnText = widget and widget.ReturnFunc and widget.ReturnText
	local v5, v6 = React.useBinding(0)
	local rotation = useSpring(v5)

	if state.MockBrand then
		state.Branding = {
			Image = "rbxassetid://17420381909",
			Size = UDim2.fromOffset(125, 28)
		}
	end

	local children = {}

	if v2.WindowState == Enums.WindowState.Minimized then
		local song = v2.Song
		children.PlayButton = React.createElement(PlayButton)
		children.ForwardButton = React.createElement(Button, {
			[React.Tag] = "ForwardButton ofHeaderBar",
			OnActivated = v2.GoForward
		})
		children.SongInfo = React.createElement(SongInfo, {
			Song = song or ""
		})
	else
		if not state.Branding and widget and (not widget.ReturnText or widget.HideArrow) then
			children.AppLogo = React.createElement("ImageLabel", {
				[React.Tag] = "Design AppLogoIcon"
			})
		end

		if returnText then
			v6(widget.ArrowRotation or 0)
			local returnButton = not widget.HideArrow

			if returnButton then
				returnButton = React.createElement(Button, {
					[React.Tag] = "ReturnButton",
					Rotation = rotation,
					OnActivated = function()
						if #v2.ReturnEvent:GetConnections() > 0 then
							v2.ReturnEvent:Fire()
						elseif widget.ReturnFunc then
							widget.ReturnFunc()
						end
					end
				})
			end

			children.ReturnButton = returnButton
			local createElement = React.createElement
			local returnAreaSoak = not widget.HideArrow

			if returnAreaSoak then
				returnAreaSoak = React.createElement("TextButton", {
					[React.Tag] = "ReturnButtonSoak",
					Size = UDim2.fromScale(0.5, 2),
					Position = UDim2.fromScale(0, 0.5),
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					ZIndex = 0,
					Text = "",
					[React.Event.Activated] = function()
						if #v2.ReturnEvent:GetConnections() > 0 then
							v2.ReturnEvent:Fire()
						elseif widget.ReturnFunc then
							widget.ReturnFunc()
						end
					end
				})
			end

			children.NoList = createElement("Folder", {}, {
				ReturnAreaSoak = returnAreaSoak
			})
			local returnText2 = widget.ReturnText

			if returnText2 then
				returnText2 = React.createElement("TextLabel", {
					[React.Tag] = "HeaderBarReturnButtonText",
					Text = widget.ReturnText,
					TextColor3 = widget.ReturnColor
				}, {})
			end

			children.ReturnText = returnText2
		elseif state.Branding then
			v6(0)
			children.Branding = React.createElement("ImageLabel", {
				[React.Tag] = "Design BrandingIcon"
			})
		else
			v6(0)
			children.Title = React.createElement("TextLabel", {
				[React.Tag] = "WindowTitleHeader",
				Text = "RELICSxyz Music Console" .. (v3 and " [Trial Mode]" or v4 and " [Free Mode]" or "")
			}, {})
		end
	end

	local compress = v("Tweak-ShowCollapseButton", nil)

	if compress then
		compress = React.createElement(Button, {
			[React.Tag] = "CompressButton",
			OnActivated = function()
				if v2.WindowState == Enums.WindowState.Minimized then
					v2.SetWindowState(Enums.WindowState.Full)
				else
					v2.SetWindowState(Enums.WindowState.Minimized)
				end
			end
		})
	end

	children.Compress = compress

	if v2.WindowState ~= Enums.WindowState.Minimized then
		local close = v("Tweak-ShowCloseButton", nil)

		if close then
			if v("Tweak-CloseButtonOffsetted", false) then
				close = React.createElement("Folder", nil, {
					Close = React.createElement(Button, {
						[React.Tag] = "CloseButton",
						OnActivated = function()
							v2.SetWindowState(Enums.WindowState.Hidden)
						end
					})
				})
			else
				close = React.createElement(Button, {
					[React.Tag] = "CloseButton",
					OnActivated = function()
						v2.SetWindowState(Enums.WindowState.Hidden)
					end
				})
			end
		end

		children.Close = close
	end

	return React.createElement("Frame", {
		[React.Tag] = Util.ClassNames(
			"HeaderBarContainer",
			state[React.Tag],
			v2.WindowState == Enums.WindowState.Minimized and "isMinimized" or "",
			returnText and "isReturnWidgetActive" or ""
		)
	}, children)
end

return HeaderBar