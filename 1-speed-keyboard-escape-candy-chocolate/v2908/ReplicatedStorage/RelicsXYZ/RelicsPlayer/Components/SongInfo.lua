local parent = script.Parent
local parent2 = parent.Parent
local hooks = parent2.Hooks
local useMetadata = require(hooks.useMetadata)
local shared = parent2.Parent.Shared
local React = require(shared.React)
local MusicData = require(shared.MusicData)
local FavoriteButton = require(parent.FavoriteButton)

local function SongInfo(props)
	local v = useMetadata(props.Id)
	local v2 = tonumber(props.Id:match("%d+$") or "0") or 0
	local v3 = props.TaggedSongMap and props.TaggedSongMap[v2]
	local v4 = nil
	local name

	if v3 then
		name = v3.Name
		local artist = v3:GetAttribute("Artist")

		if type(artist) == "string" then
			v4 = artist
		end
	end

	local song = MusicData.GetSongById(props.Id)
	local text = name or song and song.Title or v.Title or "..."
	local text2 = v4 or song and song.Artist or v.Artist or "..."

	if (text == "Unknown Song" or text == "...") and v2 > 0 then
		text = "#" .. tostring(v2) or text
	end

	return React.createElement(React.Fragment, {}, {
		Shadow = props.Dragging and React.createElement("Frame"),
		Index = React.createElement("TextLabel", {
			[React.Tag] = "SongInfoIndex",
			Text = string.format("%d.", props.DisplayIndex)
		}),
		Song = React.createElement("CanvasGroup", {}, {
			Title = React.createElement("TextLabel", {
				[React.Tag] = "SongInfoTitle Title",
				Text = text
			}),
			Artist = React.createElement("TextLabel", {
				[React.Tag] = "SongInfoArtist Artist",
				Text = text2
			})
		}),
		Favorite = not props.Dragging and React.createElement(FavoriteButton, {
			SongId = props.Id
		})
	})
end

return SongInfo