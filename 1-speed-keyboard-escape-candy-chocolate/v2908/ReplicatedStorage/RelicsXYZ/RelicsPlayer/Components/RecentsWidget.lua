local parent = script.Parent.Parent
local shared = parent.Parent.Shared
local React = require(shared.React)
local Auras = require(shared.Auras)
local Emotes = require(shared.Emotes)
local Boombox = require(shared.Boombox)
local Util = require(parent.Util)
local State = require(parent.State)
local components = parent.Components
local hooks = parent.Hooks
local useAuras = require(hooks.useAuras)
local useEmotes = require(hooks.useEmotes)
local useMetadata = require(hooks.useMetadata)
local useUgcSkins = require(hooks.useUgcSkins)
local useAuraData = require(hooks.useAuraData)
local usePlayerData = require(hooks.usePlayerData)
local useProductInfo = require(hooks.useProductInfo)
local Button = require(components.Button)
local SongList = require(components.SongList)
local ScrollFrame = require(components.ScrollFrame)
local RunContext = require(shared.RunContext)
local MusicData = require(shared.MusicData)

local function RecentSongItem(props)
	local recentInfo = props.RecentInfo
	local v = useMetadata(recentInfo.Id)
	local v3 = useProductInfo((tonumber(recentInfo.Id:match("%d+$") or 0)))

	if (v3 ~= nil or not RunContext.IsStudio) and (not v3 or v3.AssetTypeId ~= 3) then
		return nil
	end

	return React.createElement(Button, {
		[React.Tag] = Util.ClassNames("SongItem", props.Index % 2 == 0 and "MidPanel" or "ForePanel"),
		OnActivated = function()
			props.OnSongClick(recentInfo.Id, false)
		end,
		LayoutOrder = props.Index,
		HoverScale = 1,
		PressScale = 1
	}, {
		Index = React.createElement("TextLabel", {
			[React.Tag] = "SongInfoIndex ofRecentsPage",
			Text = `{props.Index}.`
		}),
		Song = React.createElement("CanvasGroup", {
			[React.Tag] = "SongInfoContainer ofRecentsPage"
		}, {
			Title = React.createElement("TextLabel", {
				[React.Tag] = "SongInfoTitle ofRecentsPage",
				Text = v.Title or "..."
			}),
			Artist = React.createElement("TextLabel", {
				[React.Tag] = "SongInfoArtist ofRecentsPage",
				Text = v.Artist or "..."
			})
		}),
		RightSide = React.createElement("Frame", {
			[React.Tag] = "TrialModeTextContainer"
		}, {
			SampleText = React.createElement("TextLabel", {
				[React.Tag] = "SongTrialMode"
			})
		})
	})
end

local function RecentAuraItem(p)
	local recentInfo = p.RecentInfo
	local v = useAuraData()
	local v2 = useAuras()[recentInfo.Id]
	local v3 = v.Aura == recentInfo.Id
	local name

	if v2 then
		name = v2.Name or recentInfo.Id
	else
		name = recentInfo.Id
	end

	return React.createElement(Button, {
		[React.Tag] = Util.ClassNames(
			"SongItem",
			"RecentAuraItem",
			p.Index % 2 == 0 and "MidPanel" or "ForePanel",
			v3 and "Active" or ""
		),
		OnActivated = function()
			if v3 then
				Auras.EquipAura(nil)
			else
				Auras.EquipAura(recentInfo.Id)
			end
		end,
		LayoutOrder = p.Index,
		HoverScale = 1,
		PressScale = 1
	}, {
		Index = React.createElement("TextLabel", {
			[React.Tag] = "SongInfoIndex ofRecentsPage",
			Text = `{p.Index}.`
		}),
		Song = React.createElement("CanvasGroup", {
			[React.Tag] = "SongInfoContainer ofRecentsPage"
		}, {
			Title = React.createElement("TextLabel", {
				[React.Tag] = "SongInfoTitle ofRecentsPage",
				Text = name
			}),
			Artist = React.createElement("TextLabel", {
				[React.Tag] = "SongInfoArtist ofRecentsPage",
				Text = ""
			})
		}),
		RightSide = React.createElement("Frame", {
			[React.Tag] = "TrialModeTextContainer"
		}, {
			SampleText = React.createElement("TextLabel", {
				[React.Tag] = "SongTrialMode ofAura",
				Text = "AURA"
			})
		})
	})
end

local function RecentEmoteItem(p)
	local recentInfo = p.RecentInfo
	local v = useEmotes()
	local v2 = React.useContext(State.Context)
	local v3 = v[recentInfo.Id]
	local name

	if v3 then
		name = v3.Name or recentInfo.Id
	else
		name = recentInfo.Id
	end

	return React.createElement(Button, {
		[React.Tag] = Util.ClassNames("SongItem", "RecentEmoteItem", p.Index % 2 == 0 and "MidPanel" or "ForePanel"),
		OnActivated = function()
			Emotes.PlayEmoteLocal(v3, v2)
		end,
		LayoutOrder = p.Index,
		HoverScale = 1,
		PressScale = 1
	}, {
		Index = React.createElement("TextLabel", {
			[React.Tag] = "SongInfoIndex ofRecentsPage",
			Text = `{p.Index}.`
		}),
		Song = React.createElement("CanvasGroup", {
			[React.Tag] = "SongInfoContainer ofRecentsPage"
		}, {
			Title = React.createElement("TextLabel", {
				[React.Tag] = "SongInfoTitle ofRecentsPage",
				Text = name
			}),
			Artist = React.createElement("TextLabel", {
				[React.Tag] = "SongInfoArtist ofRecentsPage",
				Text = ""
			})
		}),
		RightSide = React.createElement("Frame", {
			[React.Tag] = "TrialModeTextContainer"
		}, {
			SampleText = React.createElement("TextLabel", {
				[React.Tag] = "SongTrialMode ofEmote",
				Text = "EMOTE"
			})
		})
	})
end

local function RecentSkinItem(p)
	local recentInfo = p.RecentInfo
	local v = useUgcSkins()
	local v2 = usePlayerData("UGCSkin")
	local v3 = recentInfo.Id == "Default"
	local skin = v2.UGCSkin.Skin
	local v4 = v and v[recentInfo.Id]
	local v5

	if v3 then
		v5 = skin == nil
	else
		v5 = skin == recentInfo.Id
	end

	local displayName

	if v4 then
		displayName = v4.DisplayName or recentInfo.Id
	else
		displayName = v3 and "Default Skin" or recentInfo.Id
	end

	return React.createElement(Button, {
		[React.Tag] = Util.ClassNames(
			"SongItem",
			"RecentSkinItem",
			p.Index % 2 == 0 and "MidPanel" or "ForePanel",
			v5 and "Active" or ""
		),
		OnActivated = function()
			if v3 then
				Boombox.EquipSkin(nil)
			elseif v5 then
				Boombox.EquipSkin(nil)
			else
				Boombox.EquipSkin(recentInfo.Id)
			end
		end,
		LayoutOrder = p.Index,
		HoverScale = 1,
		PressScale = 1
	}, {
		Index = React.createElement("TextLabel", {
			[React.Tag] = "SongInfoIndex ofRecentsPage",
			Text = `{p.Index}.`
		}),
		Song = React.createElement("CanvasGroup", {
			[React.Tag] = "SongInfoContainer ofRecentsPage"
		}, {
			Title = React.createElement("TextLabel", {
				[React.Tag] = "SongInfoTitle ofRecentsPage",
				Text = displayName
			}),
			Artist = React.createElement("TextLabel", {
				[React.Tag] = "SongInfoArtist ofRecentsPage",
				Text = ""
			})
		}),
		RightSide = React.createElement("Frame", {
			[React.Tag] = "TrialModeTextContainer"
		}, {
			SampleText = React.createElement("TextLabel", {
				[React.Tag] = "SongTrialMode ofSkin",
				Text = "SKIN"
			})
		})
	})
end

local function RecentsWidget()
	local recents = usePlayerData("Recents").Recents
	local v = React.useContext(State.Context)
	local ref = React.useRef(0)
	local ref2 = React.useRef(nil)
	local ref3 = React.useRef(nil)

	local function handleSongClick(current: string, _: boolean)
		local now = tick()
		local v2 = now - ref.current

		if ref3.current then
			ref3.current()
			ref3.current = nil
		end

		if ref2.current == current and v2 < 0.25 then
			ref.current = 0
			ref2.current = nil
			local playlists = MusicData.GetPlaylists()

			for _, playlist in playlists do
				local songs = playlist.Songs

				if not (songs and songs[current]) then
					continue
				end

				local songs2 = {}

				for k, _ in pairs(songs) do
					table.insert(songs2, {
						Id = k,
						PlaylistName = playlist.Name
					})
				end

				local widget = v.Widget
				v.SetWidget({
					ReturnText = playlist.Name,
					Widget = function()
						return React.createElement(React.Fragment, {}, {
							SongList = React.createElement(SongList, {
								Songs = songs2
							})
						})
					end,
					ReturnFunc = function()
						v.SetWidget(widget)
					end
				})
				return
			end
		else
			local flag = false
			ref.current = now
			ref2.current = current

			function ref3.current()
				flag = true
			end

			task.delay(0.25, function()
				if flag then
					return
				end

				local song = MusicData.GetSongById(current)
				local playlist = song and song.Playlist

				if playlist then
					local songIds = MusicData.GetSongIds(playlist)

					if #songIds > 0 then
						v.SetSongList(songIds)
						v.SetQueue(table.clone(songIds))
					else
						v.SetSongList({ current })
						v.SetQueue({ current })
					end
				else
					v.SetSongList({ current })
					v.SetQueue({ current })
				end

				v.SetSong(current)
				v.SetPlaying(true)
			end)
		end
	end

	local children = {}

	for i, recent in ipairs(recents) do
		local formatted = `Recent{i}`

		if recent.Type == "SONG" then
			children[formatted] = React.createElement(RecentSongItem, {
				Index = i,
				RecentInfo = recent,
				OnSongClick = handleSongClick
			})
		elseif recent.Type == "AURA" then
			children[formatted] = React.createElement(RecentAuraItem, {
				Index = i,
				RecentInfo = recent
			})
		elseif recent.Type == "EMOTE" then
			children[formatted] = React.createElement(RecentEmoteItem, {
				Index = i,
				RecentInfo = recent
			})
		elseif recent.Type == "SKIN" then
			children[formatted] = React.createElement(RecentSkinItem, {
				Index = i,
				RecentInfo = recent
			})
		end
	end

	return React.createElement(ScrollFrame, {
		List = {
			FillDirection = Enum.FillDirection.Vertical,
			VerticalAlignment = Enum.VerticalAlignment.Top,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder
		},
		[React.Tag] = "RecentSongItemsContainer"
	}, children)
end

return RecentsWidget