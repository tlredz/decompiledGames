local parent = script.Parent.Parent
local components = parent.Components
local Button = require(components.Button)
local SongInfo = require(components.SongInfo)
local PlayButton = require(components.PlayButton)
local TextButton = require(components.TextButton)
local VolumeSlider = require(components.VolumeSlider)
local DraggableList = require(components.DraggableList)
local DurationSlider = require(components.DurationSlider)
local FavoriteButton = require(components.FavoriteButton)
local SettingsWidget = require(components.SettingsWidget)
local Widgets = require(parent.Widgets)
local Enums = require(parent.Enums)
local State = require(parent.State)
local Util = require(parent.Util)
local shared = parent.Parent.Shared
local React = require(shared.React)
local Emotes = require(shared.Emotes)
local hooks = parent.Hooks
local useSpring = require(hooks.useSpring)
local useMetadata = require(hooks.useMetadata)
local useAttribute = require(hooks.useAttribute)
local useStyleSheet = require(hooks.useStyleSheet)
local useCurrentSong = require(hooks.useCurrentSong)
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function shuffleTailWithPinnedCurrent(list, song: string?)
	if #list <= 1 then
		return list
	end

	if not (song and table.find(list, song) and song) then
		song = list[1]
	end

	local v = false
	local v2 = {}

	for _, v3 in ipairs(list) do
		if v or v3 ~= song then
			table.insert(v2, v3)
		else
			v = true
		end
	end

	for i = #v2, 2, -1 do
		local v3 = math.random(1, i)
		local v4 = v2[v3]
		local v5 = v2[i]
		v2[i] = v4
		v2[v3] = v5
	end

	local result = { song }

	for _, v3 in ipairs(v2) do
		table.insert(result, v3)
	end

	return result
end

local function PlayWidget(props)
	local v = useStyleSheet("Palette", "Color3")
	local v2 = useStyleSheet("Icons", "string")
	local v3 = useStyleSheet("Sizes", "UDim2")
	local v4 = React.useContext(State.Context)
	local v5 = v4.WindowState == Enums.WindowState.Full
	local v6 = useCurrentSong()
	local isOverride = v6.IsOverride
	local song = v6.Song
	local v7 = useMetadata(song)
	local sampleMode = v6.SampleMode

	if isOverride then
		v7.Title = v6.Title or v7.Title
		v7.Artist = v6.Artist or v7.Artist
	end

	local stopEmote = useAttribute(localPlayer, Emotes.Mutex, function(value)
		return type(value) == "string" and value or nil
	end)
	local v9, v10 = React.useBinding(v4.Looped)
	v10(v4.Looped)
	local v11, v12 = React.useBinding(v4.Shuffled)
	v12(v4.Shuffled)
	local state, setState = React.useState(nil)
	local v13, v14 = React.useBinding(false)
	local v15, v16 = React.useBinding(false)
	local ref = React.useRef(nil)
	local promoImage = props.PromoImage
	local v17 = promoImage and `rbxassetid://{promoImage:match("%d+")}`
	local v18 = useSpring(v13:map(function(p)
		if p then
			return 1
		end

		return 0
	end), {
		tension = 300,
		friction = 30
	})
	local v19 = useSpring(v15:map(function(p)
		if p then
			return 1
		end

		return 0
	end), {
		tension = 300,
		friction = 30
	})
	local v20 = useSpring(v9:map(function(p)
		if p then
			return 1
		end

		return 0
	end), {
		tension = 800,
		friction = 30
	})
	local v21 = useSpring(v11:map(function(p)
		if p then
			return 1
		end

		return 0
	end), {
		tension = 800,
		friction = 30
	})
	local expanded = props.Expanded
	local v22, v23 = React.useBinding(expanded)
	local v24 = useSpring(v22:map(function(p)
		if p then
			return 1
		end

		return 0
	end), {
		tension = 600,
		friction = 50
	})

	if isOverride and state == "Queue" then
		setState(nil)
	end

	React.useEffect(function()
		v23(expanded)
	end, { expanded })
	React.useEffect(function()
		local widget = v4.Widget
		local current = props.HomeNode.current

		if not (widget and current) then
			return
		end

		if state == "Settings" then
			v4.SetWidget({
				ReturnText = "Music Settings",
				ReturnColor = v("Color-White"),
				Widget = current.Widget,
				HideArrow = true,
				ReturnFunc = function()
					setState(nil)
					v4.SetWidget(widget)
				end
			})
			v14(true)
			v16(false)
		elseif state == "Queue" then
			v4.SetWidget({
				ReturnText = "Music Queue",
				Widget = current.Widget,
				HideArrow = true,
				ReturnFunc = function()
					setState(nil)
					v4.SetWidget(current)
				end
			})
			v14(false)
			v16(true)
		elseif widget then
			if widget.ReturnFunc then
				widget.ReturnFunc()
			end

			v4.SetWidget(current)
			v14(false)
			v16(false)
		end
	end, { state })
	React.useEffect(function()
		local function onInput(p)
			if p.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end

			local current = ref.current

			if not current or state ~= "Queue" then
				return
			end

			local mouseLocation = UserInputService:GetMouseLocation()
			local absolutePosition = current.AbsolutePosition
			local absoluteSize = current.AbsoluteSize
			local v25 = mouseLocation.X < absolutePosition.X or mouseLocation.X > absolutePosition.X + absoluteSize.X or mouseLocation.Y < absolutePosition.Y or mouseLocation.Y > absolutePosition.Y + absoluteSize.Y
			local v26

			if mouseLocation.X >= absolutePosition.X and mouseLocation.X <= absolutePosition.X + absoluteSize.X and mouseLocation.Y >= absolutePosition.Y then
				v26 = mouseLocation.Y < absolutePosition.Y + 60
			else
				v26 = false
			end

			if v25 or v26 then
				setState(nil)
			end
		end

		UserInputService.InputBegan:Connect(onInput)
	end, { state })
	local createElement = React.createElement
	local fragment = React.Fragment
	local v26 = {
		SinkInput = expanded and React.createElement("TextButton", {
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = "",
			ZIndex = 3
		}),
		MusicPlayer = 0
	}
	local createElement2 = React.createElement
	local v28 = {
		[React.Tag] = "Design MusicPlayer",
		GroupTransparency = v24:map(function(p)
			return 1 - p
		end),
		Size = v24:map(function(p)
			return UDim2.new(1, -10, 0.15, 0):Lerp(v3("Size-PlayerFullSize"), p)
		end),
		Position = v24:map(function(p)
			return UDim2.fromOffset(5, 284):Lerp(UDim2.new(), p)
		end),
		Visible = v24:map(function(p)
			return p > 0
		end)
	}
	local createElement3 = React.createElement

	if expanded then
		if v17 then
			v17 = React.createElement(Button, {
				[React.Tag] = "Design PromoBanner",
				HoverScale = 1.02,
				PressScale = 0.98,
				Image = v17,
				OnActivated = function()
					v4.WidgetReturn()
					v4.SetWindowTab(Enums.WindowTab.Collect)
					v4.SetWidget({
						Widget = Widgets.Collect,
						Context = "OpenBundle"
					})
				end
			})
		end
	else
		v17 = expanded
	end

	local children2 = {
		PromoBanner = v17,
		Backdrop = React.createElement("Frame", {
			[React.Tag] = "Design Backdrop"
		}),
		Settings = 0,
		Queue = 0
	}
	local createElement5 = React.createElement
	local v33 = {
		[React.Tag] = "Design SettingsPanel",
		AnchorPoint = v18:map(function(p)
			return Vector2.new(1 - p, 1)
		end),
		Visible = v18:map(function(p)
			return p > 0
		end)
	}
	local widget2

	if state == "Settings" then
		widget2 = React.createElement(SettingsWidget, {
			[React.Tag] = "ofPlayer"
		})
	else
		widget2 = false
	end

	children2.Settings = createElement5("CanvasGroup", v33, {
		Widget = widget2,
		Close = React.createElement(Button, {
			[React.Tag] = "CloseSettings",
			ImageTransparency = v18:map(function(p)
				return 1 - p
			end),
			OnActivated = function()
				setState(nil)
			end
		}),
		Backdrop = React.createElement("Frame", {
			[React.Tag] = Util.ClassNames("Design", "Backdrop", "ofSettings")
		})
	})
	local queue = not isOverride

	if queue then
		queue = React.createElement("CanvasGroup", {
			[React.Tag] = "Design QueuePanel",
			AnchorPoint = v19:map(function(p)
				return Vector2.new(0, p)
			end),
			Visible = v19:map(function(p)
				return p > 0
			end),
			ref = ref
		}, {
			Collapse = React.createElement(Button, {
				[React.Tag] = "CollapseButton",
				OnActivated = function()
					setState(nil)
				end
			}),
			Songs = React.createElement(DraggableList, {
				[React.Tag] = "SongList",
				Items = v4.Queue,
				ActiveItem = v4.Song,
				DragMinCell = 2,
				OnReorder = function(p)
					if not v4.Shuffled then
						v4.SetQueue(p)
						return
					end

					local v44 = shuffleTailWithPinnedCurrent(p, v4.Song)
					v4.SetQueue(v44)
				end,
				InnerComponent = SongInfo
			})
		})
	end

	children2.Queue = queue
	local children = {
		NoList = createElement3("Folder", {}, children2),
		UpperBlock = 0,
		MiddleBlock = 0,
		LowerBlock = 0
	}
	local upperBlock

	if expanded then
		local createElement8 = React.createElement
		local v41 = {
			[React.Tag] = "UpperBlockContainer"
		}
		local createElement9 = React.createElement
		local v44 = {
			[React.Tag] = "SongInfoContainer ofPlayer"
		}
		local v45 = {
			List = React.createElement("UIListLayout", {
				Padding = UDim.new(),
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			Padding = React.createElement("UIPadding", {
				PaddingLeft = UDim.new(0, 15),
				PaddingRight = UDim.new(0, 15)
			}),
			Authorship = React.createElement("Frame", {
				[React.Tag] = "Authorship ofPlayer",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				LayoutOrder = 1
			}, {
				Flex = React.createElement("UIFlexItem", {
					FlexMode = Enum.UIFlexMode.Fill
				}),
				List = React.createElement("UIListLayout", {
					Padding = UDim.new(),
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Left,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				SongTitle = React.createElement("TextLabel", {
					[React.Tag] = "SongInfoTitle ofPlayer",
					Text = v7.Title .. (sampleMode and " [PREVIEW]" or "")
				}),
				SongArtist = React.createElement("TextLabel", {
					[React.Tag] = "SongInfoArtist ofPlayer",
					Text = v7.Artist
				})
			}),
			Actions = 0
		}
		local actions = not isOverride

		if actions then
			local createElement13 = React.createElement
			local v51 = {
				[React.Tag] = "Actions ofPlayer",
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(0, 1),
				AutomaticSize = Enum.AutomaticSize.X,
				LayoutOrder = 2
			}
			local v52 = {
				List = React.createElement("UIListLayout", {
					Padding = UDim.new(0, 10),
					FillDirection = Enum.FillDirection.Horizontal,
					HorizontalAlignment = Enum.HorizontalAlignment.Right,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder
				}),
				ShuffleButton = React.createElement(Button, {
					[React.Tag] = "ShuffleButton",
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -128, 0.5, 0),
					Size = UDim2.fromOffset(30, 30),
					AnchorPoint = Vector2.one / 2,
					Image = v2("Icon-Shuffle"),
					ImageColor3 = v21:map(function(p)
						return v("Color-Gray"):Lerp(v("Color-Active"), p)
					end),
					OnActivated = function()
						v4.SetShuffled(not v4.Shuffled)
					end
				}),
				FavoriteButton = song and not v4.SampleMode and React.createElement(FavoriteButton, {
					SongId = song
				}),
				LoopButton = 0
			}

			if song then
				song = React.createElement(Button, {
					[React.Tag] = "LoopButton",
					ImageColor3 = v20:map(function(p)
						return v("Color-Gray"):Lerp(v("Color-Active"), p)
					end),
					OnActivated = function()
						v4.SetLooped(not v4.Looped)
					end
				})
			end

			v52.LoopButton = song
			actions = createElement13("Frame", v51, v52)
		end

		v45.Actions = actions
		local v42 = {
			SongInfoContainer = createElement9("Frame", v44, v45),
			DurationSlider = 0
		}
		local durationSlider

		if v5 then
			durationSlider = React.createElement(DurationSlider, {
				[React.Tag] = "ofPlayer"
			})
		else
			durationSlider = v5
		end

		v42.DurationSlider = durationSlider
		upperBlock = createElement8("Frame", v41, v42, {
			List = React.createElement("UIListLayout", {
				Padding = UDim.new(0, 0),
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Top,
				SortOrder = Enum.SortOrder.LayoutOrder
			})
		})
	else
		upperBlock = expanded
	end

	children.UpperBlock = upperBlock

	if expanded then
		local createElement8 = React.createElement
		local v41 = {
			[React.Tag] = "MiddleBlockContainer"
		}
		local musicPlayerControls = not isOverride

		if musicPlayerControls then
			musicPlayerControls = React.createElement("Frame", {
				[React.Tag] = Util.ClassNames("MusicControlsContainer", v5 and "isFull" or nil)
			}, {
				Play = React.createElement(PlayButton, {
					[React.Tag] = "ofFullPlayer"
				}),
				Backward = React.createElement(Button, {
					[React.Tag] = "BackwardButton",
					OnActivated = v4.GoBack
				}),
				Forward = React.createElement(Button, {
					[React.Tag] = "ForwardButton",
					OnActivated = v4.GoForward
				})
			})
		end

		if stopEmote then
			stopEmote = React.createElement(TextButton, {
				[React.Tag] = "ItemInteractButton",
				Text = "STOP EMOTE",
				LayoutOrder = -1,
				OnActivated = function()
					local rELICSxyz_EmoteAnimation = localPlayer:GetAttribute("RELICSxyz_EmoteAnimation")
					local emote = Emotes.GetEmoteByAnimationId(rELICSxyz_EmoteAnimation)

					if emote then
						Emotes.PlayEmoteLocal(emote, v4)
					end
				end
			})
		end

		expanded = createElement8("Frame", v41, {
			MusicPlayerControls = musicPlayerControls,
			StopEmote = stopEmote,
			VolumeSlider = React.createElement(VolumeSlider, {
				[React.Tag] = "ofPlayer"
			})
		})
	end

	children.MiddleBlock = expanded
	local createElement8 = React.createElement
	local v41 = {
		[React.Tag] = "LowerBlockContainer"
	}
	local v42 = {
		SettingsButton = React.createElement(Button, {
			[React.Tag] = "SettingsButton",
			OnActivated = function()
				if state == "Settings" then
					setState(nil)
				else
					setState("Settings")
				end
			end
		}),
		QueueButton = 0
	}
	local queueButton = not isOverride

	if queueButton then
		queueButton = React.createElement(Button, {
			[React.Tag] = "QueueButton",
			OnActivated = function()
				if state == "Queue" then
					setState(nil)
				else
					setState("Queue")
				end
			end
		})
	end

	v42.QueueButton = queueButton
	children.LowerBlock = createElement8("Frame", v41, v42)
	v26.MusicPlayer = createElement2("CanvasGroup", v28, children)
	return createElement(fragment, nil, v26)
end

return PlayWidget