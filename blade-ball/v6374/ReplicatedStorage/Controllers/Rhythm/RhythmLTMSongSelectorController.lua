local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local v = require3("@game/ReplicatedStorage/Packages/Charm")
local v2 = require3("@game/ReplicatedStorage/Packages/Net")
local v3 = require3("@game/ReplicatedStorage/Packages/Replion")
local v4 = require3("@game/ReplicatedStorage/ClientGameModules/GuiHandler")
local v5 = require3("@game/ReplicatedStorage/ServerInfo")
local v6 = require3("@game/ReplicatedStorage/Common/Utils")
local v7 = require3("@game/ReplicatedStorage/SongCharts/SongLibrary")
local v8 = require3("@game/ReplicatedStorage/Shared/ReplionUtils")
local v9 = require3("@game/ReplicatedStorage/Shared/RhythmSongProducts")
local v10 = require3("./RhythmLTMController")
local v11 = require3("@game/ReplicatedStorage/Controllers/EncryptedAssetController")
local rhythmSongSelector = Players.LocalPlayer.PlayerGui.RhythmSongSelector
local left = rhythmSongSelector.Inner.Left
local songList = rhythmSongSelector.Inner.SongList
local songTemplate = songList.SongTemplate
local v12 = {
	"easy",
	"medium",
	"hard",
	"endless"
}
local v13 = {
	easy = 1,
	medium = 2,
	hard = 3,
	endless = 4
}
local atom = v.atom()
local atom2 = v.atom()
local atom3 = v.atom()
local atom4 = v.atom({})
local remoteEvent = v2:RemoteEvent("Rhythm/Favorite")
local remoteEvent2 = v2:RemoteEvent("Rhythm/PromptSongPurchase")
local v14 = {
	Favorited = "rbxassetid://127627371948787",
	Unfavorited = "rbxassetid://80651695175977"
}
local v15 = {
	Favorited = "rbxassetid://86622180002173",
	Unfavorited = "rbxassetid://94534783738904"
}
local color = Color3.new(1, 1, 1)
local color2 = Color3.fromRGB(215, 215, 215)
local color3 = Color3.fromRGB(135, 135, 135)

local function normalizeDifficulty(value)
	if typeof(value) ~= "string" then
		return nil
	end

	local v16 = string.lower(value)

	for _, v17 in v12 do
		if v16 == v17 then
			return v17
		end
	end

	return nil
end

local function getSongDifficulties(p)
	local result = {}
	local v16 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function addDifficulty(difficulty)
		local v17

		if typeof(difficulty) == "string" then
			local v18 = string.lower(difficulty)

			for _, v20 in v12 do
				if v18 ~= v20 then
					continue
				end

				v17 = v20
				break
			end
		end

		if v17 and not v16[v17] then
			v16[v17] = true
			table.insert(result, v17)
		end
	end

	local difficulties = p.Difficulties

	if typeof(difficulties) == "table" then
		for k, difficulty in difficulties do
			if typeof(k) == "string" and difficulty ~= false then
				local v17

				if typeof(k) == "string" then
					local v18 = string.lower(k)

					for _, v20 in v12 do
						if v18 ~= v20 then
							continue
						end

						v17 = v20
						break
					end
				end

				if v17 and not v16[v17] then
					v16[v17] = true
					table.insert(result, v17)
				end
			elseif typeof(difficulty) == "string" then
				local v17

				if typeof(difficulty) == "string" then
					local v18 = string.lower(difficulty)

					for _, v20 in v12 do
						if v18 ~= v20 then
							continue
						end

						v17 = v20
						break
					end
				end

				if v17 and not v16[v17] then
					v16[v17] = true
					table.insert(result, v17)
				end
			elseif typeof(difficulty) == "table" then
				local difficulty2 = difficulty.Difficulty
				local v17

				if typeof(difficulty2) == "string" then
					local v18 = string.lower(difficulty2)

					for _, v20 in v12 do
						if v18 ~= v20 then
							continue
						end

						v17 = v20
						break
					end
				end

				if v17 and not v16[v17] then
					v16[v17] = true
					table.insert(result, v17)
				end

				local name = difficulty.Name
				local v18

				if typeof(name) == "string" then
					local v19 = string.lower(name)

					for _, v21 in v12 do
						if v19 ~= v21 then
							continue
						end

						v18 = v21
						break
					end
				end

				if v18 and not v16[v18] then
					v16[v18] = true
					table.insert(result, v18)
				end
			end
		end
	end

	addDifficulty(p.Difficulty) -- equivalent call inferred; original call site unknown

	if #result == 0 then
		local v17 = string.lower("easy")
		local v18 = nil

		for _, v20 in v12 do
			if v17 ~= v20 then
				continue
			end

			v18 = v20
			break
		end

		if v18 and not v16[v18] then
			v16[v18] = true
			table.insert(result, v18)
		end
	end

	table.sort(result, function(a, b)
		return v13[a] < v13[b]
	end)
	return result
end

local function getDefaultDifficulty(p, songDifficulties)
	for _, v16 in { p.DefaultDifficulty, p.Difficulty } do
		local v17

		if typeof(v16) == "string" then
			local v18 = string.lower(v16)

			for _, v20 in v12 do
				if v18 ~= v20 then
					continue
				end

				v17 = v20
				break
			end
		end

		if v17 and table.find(songDifficulties, v17) then
			return v17
		end
	end

	return songDifficulties[1]
end

local function resolveSongVariant(p, p2: string?)
	if not p2 or typeof(p.Difficulties) ~= "table" then
		return p
	end

	for k, difficulty in p.Difficulties do
		local v16

		if typeof(k) == "string" then
			local v17 = string.lower(k)

			for _, v19 in v12 do
				if v17 ~= v19 then
					continue
				end

				v16 = v19
				break
			end
		end

		if v16 == p2 and typeof(difficulty) == "table" then
			return difficulty
		end
	end

	return p
end

local function getSongValue(p, p2: string?, p3: string)
	local songVariant = resolveSongVariant(p, p2)
	local selected

	if typeof(songVariant) == "table" then
		selected = songVariant[p3]
	end

	if selected == nil then
		return p[p3]
	end

	return selected
end

local function getThumbnailId(value, p: string)
	if typeof(value) == "number" then
		if value > 0 then
			return (`rbxassetid://{value}`)
		end

		return p
	else
		if typeof(value) ~= "string" or value == "" or value == "0" or string.match(value, "^rbxassetid://(%d+)$") == "0" then
			return p
		end

		return value
	end
end

local function getSongDisplayName(p: string, p2)
	local name

	if typeof(p2) == "table" then
		name = p2.Name
	end

	if name == nil then
		name = p2.Name
	end

	if typeof(name) == "string" and name ~= "" then
		return name
	end

	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isFavorited(list, k: string)
	return typeof(list) == "table" and (list[k] == true or table.find(list, k) ~= nil)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setFavoriteButton(p, p2, flag: boolean)
	local image

	if flag then
		image = p2.Favorited
	else
		image = p2.Unfavorited
	end

	p.Image = image
	local hoverImage

	if flag then
		hoverImage = p2.Unfavorited
	else
		hoverImage = p2.Favorited
	end

	p.HoverImage = hoverImage
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSongProgress(p, p2: string)
	if typeof(p) == "table" and typeof(p[p2]) == "table" then
		return p[p2]
	end

	return nil
end

local function isGated(value: string?)
	if typeof(value) ~= "string" then
		return false
	end

	local v16 = v9[value]
	return v16 ~= nil and v16.Gated
end

local function ownsSong(p, value: string?)
	local gated

	if typeof(value) == "string" then
		local v16 = v9[value]

		if v16 == nil then
			gated = false
		else
			gated = v16.Gated
		end
	else
		gated = false
	end

	return not gated or typeof(p) == "table" and p[value] == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isDifficultyCompleted(songProgress, k: string)
	if typeof(songProgress) == "table" and typeof(songProgress.Completed) == "table" then
		return songProgress.Completed[k] == true
	end

	return false
end

local function getHighScore(p, p2: string)
	if typeof(p) ~= "table" or typeof(p.Difficulties) ~= "table" then
		return 0
	end

	local difficulty = p.Difficulties[p2]

	if typeof(difficulty) == "number" and difficulty >= 0 then
		return difficulty
	end

	return 0
end

local function getSongIds()
	local result = {}

	for k, v16 in v7 do
		if not (typeof(k) == "string" and typeof(v16) == "table") then
			continue
		end

		table.insert(result, k)
	end

	table.sort(result, function(a, b)
		local v16 = v7[a]
		local name

		if typeof(v16) == "table" then
			name = v16.Name
		end

		if name == nil then
			name = v16.Name
		end

		if typeof(name) ~= "string" or name == "" then
			name = a
		end

		local v17 = string.lower(name)
		local v18 = v7[b]
		local name2

		if typeof(v18) == "table" then
			name2 = v18.Name
		end

		if name2 == nil then
			name2 = v18.Name
		end

		if typeof(name2) ~= "string" or name2 == "" then
			name2 = b
		end

		local v19 = string.lower(name2)

		if v17 == v19 then
			return a < b
		end

		return v17 < v19
	end)
	return result
end

local function selectSong(p: string)
	local v16 = v7[p]

	if typeof(v16) ~= "table" then
		return
	end

	local songDifficulties = getSongDifficulties(v16)
	local v17 = atom2()

	if not (v17 and table.find(songDifficulties, v17)) then
		v17 = getDefaultDifficulty(v16, songDifficulties)
	end

	atom(p)
	atom2(v17)
end

return {
	Start = function(_)
		if not v5.isRhythmServer() then
			return
		end

		local v16 = v3.Client:WaitReplion("Data")
		local atom5 = v8.atom(v16, { "RhythmLTM", "Songs" })
		local atom6 = v8.atom(v16, { "RhythmLTM", "PurchasedSongs" })
		local atom7 = v8.atom(v16, { "RhythmLTM", "Favorites" })
		local songIds = getSongIds()
		v4:Close(rhythmSongSelector.Name, true)
		local soundIdsBySongId = {}
		local soundIds = {}
		local songIds2 = {}
		local v17 = {}
		local v18 = {}
		local clones = {}

		for _, songId in songIds do
			local v19 = v7[songId]
			local soundId

			if typeof(v19) == "table" then
				soundId = v19.SoundId
			end

			if not (typeof(soundId) == "string" and soundId ~= "") then
				continue
			end

			soundIdsBySongId[songId] = soundId
			table.insert(soundIds, soundId)
		end

		pcall(function()
			v11:RequestAsset(soundIds)
		end)
		local v19 = {}

		for k, soundId in soundIdsBySongId do
			local sound = Instance.new("Sound")
			sound.SoundId = soundId
			sound.Parent = script
			v19[k] = sound
		end

		local clone = table.clone(soundIdsBySongId)
		local v20 = os.clock() + 3
		local v21 = {}

		while next(clone) ~= nil and os.clock() < v20 do
			for k, v22 in clone do
				local v23 = v22
				local success, result = pcall(function()
					return ContentProvider:GetAssetFetchStatus(v23)
				end)

				if success and result == Enum.AssetFetchStatus.Failure then
					v21[k] = true
					warn((`[rhythm] song audio denied, not listing: {k}`))
					clone[k] = nil
				elseif success and result == Enum.AssetFetchStatus.Success then
					clone[k] = nil
				end
			end

			task.wait(0.1)
		end

		for _, v22 in v19 do
			v22:Destroy()
		end

		for _, songId in songIds do
			if not v21[songId] then
				table.insert(songIds2, songId)
			end
		end

		if #songIds2 < #songIds then
			warn((`[rhythm] listing {#songIds2}/{#songIds} songs`))
		end

		local v22 = {
			easy = left.SongControlls.Easy,
			medium = left.SongControlls.Medium,
			hard = left.SongControlls.Hard,
			endless = left.SongControlls.Insane
		}
		local v23 = {}

		for k, v24 in v22 do
			v23[k] = {
				Normal = v24.Image,
				Selected = v24.HoverImage
			}
		end

		for _, child in songList:GetChildren() do
			if child:GetAttribute("RhythmSongEntry") then
				child:Destroy()
			end
		end

		songTemplate.Visible = false
		songTemplate.Active = false
		songTemplate.Interactable = false
		songTemplate.Selectable = false
		left.SongStats.PossibleRewards.Visible = false
		local image = left.SongDetails.SongLabel.Image

		for k, v24 in songIds2 do
			local v25 = v7[v24]
			local clone2 = songTemplate:Clone()
			local credits

			if typeof(v25) == "table" then
				credits = v25.Credits
			end

			if credits == nil then
				credits = v25.Credits
			end

			clone2.Name = `Song_{string.gsub(v24, "[^%w_]", "_")}`
			clone2:SetAttribute("RhythmSongEntry", true)
			clone2.LayoutOrder = k
			clone2.Visible = true
			clone2.Active = true
			clone2.Interactable = true
			clone2.Selectable = true
			local songName = clone2.SongName
			local name

			if typeof(v25) == "table" then
				name = v25.Name
			end

			if name == nil then
				name = v25.Name
			end

			if typeof(name) ~= "string" or name == "" then
				name = v24
			end

			songName.Text = name
			clone2.SongCredits.Text = typeof(credits) ~= "string" and "" or credits
			local songLabel = clone2.SongLabel
			local thumbnailId

			if typeof(v25) == "table" then
				thumbnailId = v25.ThumbnailId
			end

			if thumbnailId == nil then
				thumbnailId = v25.ThumbnailId
			end

			local image2 = clone2.SongLabel.Image

			if typeof(thumbnailId) == "number" then
				if thumbnailId > 0 then
					thumbnailId = `rbxassetid://{thumbnailId}`
				else
					thumbnailId = image2
				end
			elseif typeof(thumbnailId) == "string" and thumbnailId ~= "" and thumbnailId ~= "0" then
				if string.match(thumbnailId, "^rbxassetid://(%d+)$") == "0" then
					thumbnailId = image2
				end
			else
				thumbnailId = image2
			end

			songLabel.Image = thumbnailId
			local v26 = v24
			clone2.Activated:Connect(function()
				selectSong(v26)
			end)
			local v27 = v24
			clone2.Favourite.Activated:Connect(function()
				remoteEvent:FireServer(v27)
			end)
			v17[v24] = {
				Normal = clone2.Image,
				Selected = clone2.HoverImage
			}
			v18[v24] = k
			clones[v24] = clone2
			clone2.Parent = songList
		end

		if songIds2[1] then
			selectSong(songIds2[1])
		else
			atom(nil)
			atom2(nil)
		end

		local function markUnavailable(p: string)
			local clone2 = table.clone(atom4())
			clone2[p] = true
			atom4(clone2)
		end

		v10:OnSongUnavailable(markUnavailable)

		for k, v24 in v22 do
			local v25 = k
			v24.Activated:Connect(function()
				local v26 = atom()
				local v27

				if v26 then
					v27 = v7[v26]
				end

				if typeof(v27) ~= "table" then
					return
				end

				if table.find(getSongDifficulties(v27), v25) then
					atom2(v25)
				end
			end)
		end

		v.effect(function()
			local v24 = atom7()
			local v25 = atom()

			for k, v26 in clones do
				local favorited = isFavorited(v24, k) -- equivalent call inferred; original call site unknown
				setFavoriteButton(v26.Favourite, v15, favorited) -- equivalent call inferred; original call site unknown
				v26.LayoutOrder = v18[k] + (favorited and 0 or #songIds2)
			end

			setFavoriteButton(
				left.SongDetails.FavouriteSong,
				v14,
				v25 ~= nil and typeof(v24) == "table" and (v24[v25] == true or table.find(v24, v25) ~= nil)
			) -- equivalent call inferred; original call site unknown
		end)
		v.effect(function()
			local text = atom()
			local v25 = atom2()
			local v26 = atom3()
			local v27 = atom5()
			local v28 = atom6()
			local v29 = atom4()

			for k, v30 in clones do
				local v31 = v17[k]
				local v32 = k == text
				v30.Visible = v29[k] ~= true
				local image2

				if v32 then
					image2 = v31.Selected
				else
					image2 = v31.Normal
				end

				v30.Image = image2
				v30.HoverImage = v31.Selected
				local imageColor

				if v32 then
					imageColor = color
				else
					imageColor = color2
				end

				v30.ImageColor3 = imageColor
			end

			if text and v29[text] then
				for _, v30 in songIds2 do
					if v29[v30] then
						continue
					end

					selectSong(v30)
					return
				end
			end

			local v30

			if text then
				v30 = v7[text]
			end

			if typeof(v30) == "table" then
				local songDifficulties = getSongDifficulties(v30)

				if not (v25 and table.find(songDifficulties, v25)) then
					atom2((getDefaultDifficulty(v30, songDifficulties)))
					return
				end

				v10:SetPreviewSong(text)
				local songProgress = getSongProgress(v27, text) -- equivalent call inferred; original call site unknown
				local songVariant = resolveSongVariant(v30, v25)
				local credits

				if typeof(songVariant) == "table" then
					credits = songVariant.Credits
				end

				if credits == nil then
					credits = v30.Credits
				end

				local songVariant2 = resolveSongVariant(v30, v25)
				local BPM

				if typeof(songVariant2) == "table" then
					BPM = songVariant2.BPM
				end

				if BPM == nil then
					BPM = v30.BPM
				end

				local v31 = tonumber(BPM)
				local songVariant3 = resolveSongVariant(v30, v25)
				local timeLength

				if typeof(songVariant3) == "table" then
					timeLength = songVariant3.TimeLength
				end

				if timeLength == nil then
					timeLength = v30.TimeLength
				end

				local v32 = tonumber(timeLength) or 0
				local songName = left.SongDetails.SongName
				local name

				if typeof(v30) == "table" then
					name = v30.Name
				end

				if name == nil then
					name = v30.Name
				end

				if typeof(name) ~= "string" or name == "" then
					name = text
				end

				songName.Text = name
				left.SongDetails.SongCredits.Text = typeof(credits) ~= "string" and "" or credits
				local songLabel = left.SongDetails.SongLabel
				local songVariant4 = resolveSongVariant(v30, v25)
				local thumbnailId

				if typeof(songVariant4) == "table" then
					thumbnailId = songVariant4.ThumbnailId
				end

				if thumbnailId == nil then
					thumbnailId = v30.ThumbnailId
				end

				local image2 = image

				if typeof(thumbnailId) == "number" then
					if thumbnailId > 0 then
						thumbnailId = `rbxassetid://{thumbnailId}`
					else
						thumbnailId = image2
					end
				elseif typeof(thumbnailId) == "string" and thumbnailId ~= "" and thumbnailId ~= "0" then
					if string.match(thumbnailId, "^rbxassetid://(%d+)$") == "0" then
						thumbnailId = image2
					end
				else
					thumbnailId = image2
				end

				songLabel.Image = thumbnailId
				left.SongDetails.SongDetails.BPM.Value.Text = not v31 and "--" or string.format(
					"%d BPM",
					(math.round(v31))
				)
				left.SongDetails.SongDetails.Difficulty.Value.Text = string.upper(v25)
				left.SongDetails.SongDetails.Time.Value.Text = v6.ValueConvertor:FormatTime(v32)
				left.SongDetails.FavouriteSong.Interactable = true
				local count = 0
				local count2 = 0

				for k, v34 in v22 do
					local v35 = table.find(songDifficulties, k) ~= nil
					local v36 = v35 and k == v25
					local v37

					if v35 and typeof(songProgress) == "table" and typeof(songProgress.Difficulties) == "table" then
						local difficulty = songProgress.Difficulties[k]
						v37 = (typeof(difficulty) ~= "number" or not (difficulty >= 0)) and 0 or difficulty
					else
						v37 = 0
					end

					local v38 = v23[k]

					if v35 and k ~= "endless" then
						count += 1

						-- equivalent call inferred; original call site unknown
						if isDifficultyCompleted(songProgress, k) then
							count2 += 1
						end
					end

					local image3

					if v36 then
						image3 = v38.Selected
					else
						image3 = v38.Normal
					end

					v34.Image = image3
					local hoverImage

					if v35 then
						hoverImage = v38.Selected
					else
						hoverImage = v38.Normal
					end

					v34.HoverImage = hoverImage
					local imageColor

					if v36 then
						imageColor = color
					elseif v35 then
						imageColor = color2
					else
						imageColor = color3
					end

					v34.ImageColor3 = imageColor
					v34.ImageTransparency = v35 and 0 or 0.45
					v34.Active = v35 and not v26
					v34.Interactable = v35 and not v26
					v34.Selectable = v35 and not v26
					v34.AutoButtonColor = v35 and not v36
					v34.Title.TextTransparency = v35 and 0 or 0.45
					v34.Txt.TextTransparency = v35 and 0 or 0.45
					v34.HighScoreValue.Text = not v35 and "--" or v6.ValueConvertor:AddCommas((math.floor(v37)))
					v34.HighScoreValue.TextTransparency = v35 and 0 or 0.45
					v34.Icon.ImageTransparency = v35 and 0 or 0.45
				end

				local v34 = not (count > 0) and 0 or count2 / count
				left.SongStats.DifficultyCompletion.Bar.Progress.Text = `{count2}/{count}`
				left.SongStats.DifficultyCompletion.Bar.Fill.Size = UDim2.fromScale(v34, 1)
				left.SongStats.DifficultyCompletion.Bar.Fill.Position = UDim2.fromScale(v34 / 2, 0.5)
				local gated

				if typeof(text) == "string" then
					local v35 = v9[text]

					if v35 == nil then
						gated = false
					else
						gated = v35.Gated
					end
				else
					gated = false
				end

				local v35

				if typeof(v28) == "table" then
					v35 = v28[text] == true
				else
					v35 = false
				end

				local visible = gated and not v35
				local v37

				if v9[text] == nil then
					v37 = false
				else
					v37 = not v35
				end

				left.SongStats.PurchaseOptions.Visible = visible
				local songName2 = left.SongStats.PurchaseOptions.SongName
				local name2

				if typeof(v30) == "table" then
					name2 = v30.Name
				end

				if name2 == nil then
					name2 = v30.Name
				end

				if typeof(name2) == "string" and name2 ~= "" then
					text = name2
				end

				songName2.Text = text
				left.SongStats.Buy.Visible = not visible and v37
				left.SongStats.Play.Visible = not visible
				local v38 = not visible

				if v38 then
					if v26 == nil then
						v38 = table.find(songDifficulties, v25) ~= nil
					else
						v38 = false
					end
				end

				left.SongStats.Play.Interactable = v38
				left.SongStats.Play.AutoButtonColor = v38
				left.SongStats.Play.ImageTransparency = v38 and 0 or 0.45
				left.SongStats.Play.Txt.Text = v26 and "PLAYING..." or "PLAY"
			else
				left.SongDetails.SongName.Text = "No songs available"
				left.SongDetails.SongCredits.Text = ""
				left.SongDetails.SongLabel.Image = image
				left.SongDetails.SongDetails.BPM.Value.Text = "--"
				left.SongDetails.SongDetails.Difficulty.Value.Text = "--"
				left.SongDetails.SongDetails.Time.Value.Text = "--"
				left.SongDetails.FavouriteSong.Interactable = false
				left.SongStats.DifficultyCompletion.Bar.Progress.Text = "0/0"
				left.SongStats.DifficultyCompletion.Bar.Fill.Size = UDim2.fromScale(0, 1)
				left.SongStats.DifficultyCompletion.Bar.Fill.Position = UDim2.fromScale(0, 0.5)
				v10:SetPreviewSong(nil)
				left.SongStats.PurchaseOptions.Visible = false
				left.SongStats.Buy.Visible = false
				left.SongStats.Play.Visible = true
				left.SongStats.Play.Interactable = false
				left.SongStats.Play.AutoButtonColor = false
				left.SongStats.Play.ImageTransparency = 0.45

				for k, v31 in v22 do
					local v32 = v23[k]
					v31.Image = v32.Normal
					v31.HoverImage = v32.Normal
					v31.ImageColor3 = color3
					v31.ImageTransparency = 0.45
					v31.Active = false
					v31.Interactable = false
					v31.Selectable = false
					v31.Title.TextTransparency = 0.45
					v31.Txt.TextTransparency = 0.45
					v31.HighScoreValue.Text = "--"
					v31.HighScoreValue.TextTransparency = 0.45
					v31.Icon.ImageTransparency = 0.45
				end
			end
		end)

		local function promptPurchase()
			local v24 = atom()

			if not v24 then
				return
			end

			remoteEvent2:FireServer(v24)
		end

		left.SongStats.PurchaseOptions.Buy.Activated:Connect(promptPurchase)
		left.SongStats.Buy.Activated:Connect(promptPurchase)
		local v24 = false
		v.effect(function()
			local v25 = atom3() ~= nil

			if v25 then
				v4:Close(rhythmSongSelector.Name, true)
			elseif v24 then
				v4:Open(rhythmSongSelector.Name, true)
			end

			v24 = v25
		end)
		left.SongStats.Play.Activated:Connect(function()
			local v25 = atom()
			local v26 = atom2()
			local v27

			if v25 then
				v27 = v7[v25]
			end

			if not v25 or not v26 or atom3() or typeof(v27) ~= "table" or not table.find(getSongDifficulties(v27), v26) then
				return
			end

			local v28 = atom6()
			local gated

			if typeof(v25) == "string" then
				local v29 = v9[v25]

				if v29 == nil then
					gated = false
				else
					gated = v29.Gated
				end
			else
				gated = false
			end

			local v29

			if gated then
				if typeof(v28) == "table" then
					v29 = v28[v25] == true
				else
					v29 = false
				end
			else
				v29 = true
			end

			if not v29 or atom4()[v25] then
				return
			end

			atom3(v25)
			local success, result = pcall(function()
				v10:Play(v25, false, v26, function()
					atom3(nil)
				end)
			end)

			if not success then
				atom3(nil)
				warn((`Failed to play rhythm song {v25}: {result}`))
			end
		end)
		left.SongDetails.FavouriteSong.Activated:Connect(function()
			local v25 = atom()

			if v25 then
				remoteEvent:FireServer(v25)
			end
		end)
	end
}