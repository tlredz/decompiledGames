local parent = script.Parent
local parent2 = parent.Parent
local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local localPlayer = Players.LocalPlayer
local hooks = parent.Hooks
local shared = parent2.Shared
local components = parent.Components
local Util = require(parent.Util)
local ReactRoblox = require(shared.ReactRoblox)
local Marketplace = require(shared.Marketplace)
local MusicData = require(shared.MusicData)
local Boombox = require(shared.Boombox)
local Recents = require(shared.Recents)
local Signal = require(shared.Signal)
local React = require(shared.React)
local Tags = require(shared.Tags)
local Enums = require(parent.Enums)
local userStatus = Enums.UserStatus
local useClock = require(hooks.useClock)
local useSignal = require(hooks.useSignal)
local useStatus = require(hooks.useStatus)
local useTagged = require(hooks.useTagged)
local useChanged = require(hooks.useChanged)
local useRestore = require(hooks.useRestore)
local useSettings = require(hooks.useSettings)
local useFeatures = require(hooks.useFeatures)
local useTabOrder = require(hooks.useTabOrder)
local usePlaylists = require(hooks.usePlaylists)
require(hooks.useFormFactor)
local useBoomboxData = require(hooks.useBoomboxData)
local Auras = require(shared.Auras)
local RunContext = require(shared.RunContext)
local GameInfo = require(components.GameInfo)

local function createPorts()
	return {
		SetSong = Signal.new(),
		SetQueue = Signal.new(),
		SetVolume = Signal.new(),
		SetWidget = Signal.new(),
		SetLooped = Signal.new(),
		SetPlaying = Signal.new(),
		SetPosition = Signal.new(),
		SetShuffled = Signal.new(),
		SetSongList = Signal.new(),
		SetWindowTab = Signal.new(),
		SetVolumeMod = Signal.new(),
		SetJumpToTime = Signal.new(),
		SetWindowState = Signal.new(),
		SetEquipWheelOpen = Signal.new(),
		SongChanged = Signal.new(),
		QueueChanged = Signal.new(),
		VolumeChanged = Signal.new(),
		LoopedChanged = Signal.new(),
		PlayingChanged = Signal.new(),
		SongListChanged = Signal.new(),
		ShuffledChanged = Signal.new(),
		WindowTabChanged = Signal.new(),
		HasBoomboxChanged = Signal.new(),
		WindowStateChanged = Signal.new(),
		EquipWheelOpenChanged = Signal.new(),
		ActiveState = {},
		PendingState = {}
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getGlobalBoombox()
	local userId = Players.LocalPlayer.UserId
	return Boombox.FindServerAudio(userId)
end

local function listsEqual(list, list2)
	if #list ~= #list2 then
		return false
	end

	for i = 1, #list do
		if list[i] ~= list2[i] then
			return false
		end
	end

	return true
end

local context = React.createContext({})

local function isPlaylistLocked(data, flag: boolean)
	if not data.IsPublic and data.Name:upper() ~= "FAVORITES" and not flag and not data.IsFree then
		return true
	end

	for _, song in data.Songs do
		if MusicData.GetRequiresOwnership(song) and MusicData.IsSongLockedByBadge(song.Id) then
			if MusicData.UserHasUnlocked(song, Players.LocalPlayer.UserId) then
				return false
			end
		else
			return false
		end
	end

	return true
end

return table.freeze({
	Driver = function(p)
		local ports = p.Ports or createPorts()
		local boombox = useBoomboxData()
		local v2 = usePlaylists()
		local features = useFeatures()
		local status = useStatus()
		local v5 = status == Enums.UserStatus.BoomboxPurchased
		local v6 = useSettings()
		local proximityAudio = v6.ProximityAudio
		local globalMute = v6.GlobalMute
		local localMute = v6.LocalMute

		if RunContext.IsEdit then
			proximityAudio = false
		end

		if proximityAudio and status ~= userStatus.Freemium and status ~= userStatus.BoomboxPurchased then
			proximityAudio = false
		end

		local useState = React.useState
		local v7

		if ports.Playing == nil then
			v7 = features.AutoPlay
		else
			v7 = ports.Playing
		end

		local state, setState = useState(v7)
		useSignal(ports.SetPlaying, setState)
		ports.Playing = state
		React.useEffect(function()
			if features.AutoPlay then
				ports.SetPlaying:Fire(true)
			end
		end, { features.AutoPlay })
		local state2, setState2 = React.useState(nil)
		useSignal(ports.SetJumpToTime, setState2)
		local v8, setVolume = useRestore("Volume", ports.Volume == nil and 1 or ports.Volume, ports.VolumeChanged)
		useSignal(ports.SetVolume, setVolume)
		ports.Volume = v8
		local v12

		if ports.Looped == nil then
			v12 = false
		else
			v12 = ports.Looped
		end

		local looped, setLooped = useRestore("Looped", v12, ports.LoopedChanged)
		useSignal(ports.SetLooped, setLooped)
		ports.Looped = looped
		local v17

		if ports.Shuffled == nil then
			v17 = false
		else
			v17 = ports.Shuffled
		end

		local v18, setShuffled = useRestore("Shuffled", v17, ports.ShuffledChanged)
		useSignal(ports.SetShuffled, setShuffled)
		ports.Shuffled = v18
		local state3, setState3 = React.useState(nil)
		useSignal(ports.SetWidget, setState3)
		local windowTab, setWindowTab = useRestore(
			"WindowTab",
			ports.WindowTab or Enums.WindowTab.Collect,
			ports.WindowTabChanged
		)
		useSignal(ports.SetWindowTab, setWindowTab)
		ports.WindowTab = windowTab
		local songList, setSongList = useChanged(ports.SongList or {}, ports.SongListChanged)
		useSignal(ports.SetSongList, setSongList)
		ports.SongList = songList
		local v24, v25 = useChanged(ports.Queue or {}, ports.QueueChanged)
		local song2, setSong = useRestore("Song", ports.Song, ports.SongChanged)
		local setQueue = React.useCallback(function(list)
			if #list == 0 and #songList > 0 then
				return
			end

			local v29 = v24
			local v30

			if #v29 == #list then
				local flag = true

				for i = 1, #v29 do
					if v29[i] == list[i] then
						continue
					end

					v30 = false
					flag = false
					break
				end

				if flag then
					v30 = true
				end
			else
				v30 = false
			end

			if not v30 then
				v25(list)
			end
		end, { v24, songList })
		local state4, setState4 = React.useState({})
		local addSongOverride = React.useCallback(function(p2: string, data)
			setState4(function(p3)
				local v30 = p3[p2]

				if v30 and v30.Priority == data.Priority and v30.Song == data.Song and v30.SampleMode == data.SampleMode and v30.SuppressRemote == data.SuppressRemote and v30.Title == data.Title and v30.Artist == data.Artist then
					return p3
				end

				local clone = table.clone(p3)
				clone[p2] = {
					Song = data.Song,
					Priority = data.Priority,
					SampleMode = data.SampleMode,
					SuppressRemote = data.SuppressRemote,
					Title = data.Title,
					Artist = data.Artist
				}
				return clone
			end)
		end, {})
		local removeSongOverride = React.useCallback(function(p2: string)
			setState4(function(p3)
				local clone = table.clone(p3)

				if not clone[p2] then
					return p3
				end

				clone[p2] = nil
				return clone
			end)
		end, {})
		useSignal(ports.SetQueue, setQueue, { songList })
		useSignal(ports.SetSong, setSong)
		local queue = React.useMemo(function()
			if not song2 or #v24 <= 1 then
				return v24
			end

			local index = table.find(v24, song2)

			if not index then
				return v24
			end

			local result = {}

			for i = index, #v24 do
				table.insert(result, v24[i])
			end

			for i = 1, index - 1 do
				table.insert(result, v24[i])
			end

			return result
		end, { v24, song2 })
		ports.Queue = queue
		ports.Song = song2
		local v32 = useTabOrder()
		local libraryTab, setLibraryTab = useRestore("LibraryTab", "PLAYLISTS")
		local libraryCanvasX, setLibraryCanvasX = useRestore("LibraryCanvasX", 0)
		local customizeTab, setCustomizeTab = useRestore("CustomizeTab", v32[1]:upper())
		local state5, setState5 = React.useState(nil)
		local state6, setState6 = React.useState(false)
		local state7, setState7 = React.useState(false)
		React.useEffect(function()
			setCustomizeTab(v32[1]:upper())
		end, { v32 })
		local ref = React.useRef({})
		local ref2 = React.useRef(proximityAudio)
		ref2.current = proximityAudio
		local ref3 = React.useRef(globalMute)
		ref3.current = globalMute
		local ref4 = React.useRef(localMute)
		ref4.current = localMute
		local ref5 = React.useRef(v8)
		ref5.current = v8
		local useRef = React.useRef(state)
		useRef.current = state
		local ref6 = React.useRef(false)
		local ref7 = React.useRef(false)
		local priority = -1e999
		local flag = false
		local v39 = nil

		for _, v40 in state4 do
			if priority < v40.Priority then
				priority = v40.Priority
				v39 = v40
			end

			if v40.SuppressRemote then
				flag = true
			end
		end

		local ref8 = React.useRef(state7)
		ref6.current = flag
		local current4

		if v39 == nil then
			current4 = false
		else
			current4 = not flag
		end

		ref7.current = current4

		if flag then
			ref2.current = false
			proximityAudio = false
		end

		if v39 and v39.SampleMode then
			ref8.current = true
		else
			ref8.current = state7
		end

		local ref9 = React.useRef(nil)
		local ref10 = React.useRef(nil)
		local ref11 = React.useRef(nil)
		local ref12 = React.useRef(nil)
		local ref13 = React.useRef(nil)
		local ref14 = React.useRef(nil)
		local ref15 = React.useRef(nil)
		local ref16 = React.useRef(nil)
		local ref17 = React.useRef(nil)
		local v41 = React.useCallback(function()
			local current = ref10.current
			local current2 = ref9.current

			if not current then
				return
			end

			local current3 = tonumber(ref5.current) or 1
			local v42 = (ref4.current or ref2.current and not ref3.current) and 0 or current3
			local volume = 1

			for _, v44 in pairs(ref.current) do
				volume *= tonumber(v44) or 1
			end

			current.Volume = v42 * volume

			if current2 then
				if ref7.current and not ref2.current then
					current2.Volume = 0
				else
					current2.Volume = volume
				end
			end
		end, {})
		React.useEffect(function()
			local volumeMods = ports.VolumeMods
			local current = ref.current

			if volumeMods and current then
				for k, volumeMod in pairs(volumeMods) do
					current[k] = volumeMod
				end

				v41()
			end
		end, {})
		useSignal(ports.SetVolumeMod, function(p2, p3)
			ref.current[p2] = p3
			v41()
		end, {})
		React.useEffect(function()
			v41()
		end, { state4, proximityAudio })
		useSignal(Boombox.AudioPatchFeed, function(data)
			if data and data.SongId ~= nil then
				setSong(data.SongId)
			end

			if data and data.TimePosition ~= nil then
				setState2(data.TimePosition)
			end

			if data and data.Volume ~= nil then
				setVolume(data.Volume)
			end

			if data and data.Playing ~= nil then
				setState(data.Playing and true or false)
			end
		end, {})
		local ref18 = React.useRef(nil)
		local ref19 = React.useRef(nil)
		local ref20 = React.useRef(nil)
		local ref21 = React.useRef(nil)
		local ref22 = React.useRef(nil)
		local ref23 = React.useRef(nil)
		local ref24 = React.useRef(getGlobalBoombox())
		local ref25 = React.useRef(nil)
		local ref26 = React.useRef({})
		local ref27 = React.useRef(v18)
		local v42 = useTagged("RelicsEmoteAudio")
		local ref28 = React.useRef(0)
		React.useEffect(function()
			if #songList == 0 then
				ref26.current = {}
				ref27.current = v18
			else
				local current = ref26.current
				local v44 = songList
				local v45

				if #current == #v44 then
					local flag2 = true

					for i = 1, #current do
						if current[i] == v44[i] then
							continue
						end

						v45 = false
						flag2 = false
						break
					end

					if flag2 then
						v45 = true
					end
				else
					v45 = false
				end

				local v47 = ref27.current ~= v18

				if v45 and not v47 then
					return
				end

				ref26.current = table.clone(songList)
				ref27.current = v18

				if not v18 then
					setQueue(table.clone(songList))
					return
				end

				local v48 = {}
				local v49 = {}

				for i = 1, #songList do
					table.insert(v48, i)
				end

				while #v48 > 0 do
					local v50 = math.random(1, #v48)
					local v51 = v48[v50]
					table.insert(v49, songList[v51])
					table.remove(v48, v50)
				end

				setQueue(v49)
			end
		end, { songList, v18 })
		useClock(5, function()
			local current = ref14.current

			if not current then
				return
			end

			local v44 = 0

			for _, audioEmitter in v42 do
				if not audioEmitter:IsA("AudioEmitter") then
					continue
				end

				local v45 = audioEmitter:GetAudibilityFor(current) * 4

				if v44 < v45 then
					v44 = v45
				end
			end

			local current2 = math.round(v44 * 40) / 40

			if ref28.current ~= current2 then
				ref.current.__relicsEmoteVolume = math.clamp(1 - current2, 0, 1)
				ref28.current = current2
				v41()
			end
		end, { v42 })
		local v44 = React.useCallback(function()
			if song2 then
				return table.find(v24, song2)
			end

			return nil
		end, { v24, song2 })
		local goBack = React.useCallback(function()
			local current = ref11.current

			if #v24 == 0 then
				if current then
					current.TimePosition = 0
					Boombox.SendAudioPatch({
						TimePosition = 0
					})
				end
			else
				if not song2 then
					return
				end

				if current and current.TimePosition > 5 then
					current.TimePosition = 0
					Boombox.SendAudioPatch({
						TimePosition = 0
					})
				else
					local v46 = v44() or 1
					local v47

					if v46 <= 1 then
						v47 = #v24
					else
						v47 = #v24 < v46 and 1 or v46 - 1
					end

					setSong(v24[v47])
				end
			end
		end, { v24, song2 })
		local v46 = React.useCallback(function()
			ref25.current = ref11.current and ref11.current.Asset or song2

			if #v24 == 0 then
				local current = ref11.current

				if current then
					current.TimePosition = 0
					Boombox.SendAudioPatch({
						TimePosition = 0
					})
				end
			else
				local v47 = v44() or 0
				local v48

				if #v24 <= v47 then
					v48 = 1
				elseif v47 < 1 then
					v48 = #v24
				else
					v48 = v47 + 1
				end

				setSong(v24[v48])
			end
		end, { v24, song2 })
		local ref29 = React.useRef(v46)
		ref29.current = v46
		React.useEffect(function()
			local current = ref11.current
			local v47 = tonumber(v8) or 1
			local volume = (localMute or proximityAudio and not globalMute) and 0 or v47

			if current then
				Boombox.SendAudioPatch({
					Volume = volume
				})
			end

			v41()
		end, {
			v8,
			proximityAudio,
			localMute,
			globalMute
		})
		React.useEffect(function()
			if state2 then
				local current = ref11.current

				if current then
					current.TimePosition = state2
				end

				Boombox.SendAudioPatch({
					TimePosition = state2
				})
				setState2(nil)
			end
		end, { proximityAudio, state2 })
		useClock(30, function()
			if not ref24.current then
				ref24.current = getGlobalBoombox()
			end

			local current = ref24.current
			local audio = current and current.Audio
			local current2 = ref11.current
			local v47 = {}

			if ref8.current and current2 then
				local timeLength = current2.TimeLength
				local samplePreviewRange, v48 = Util.GetSamplePreviewRange(timeLength)
				local v49 = samplePreviewRange + v48
				local asset = current2.Asset

				if ref25.current ~= asset then
					ref25.current = nil
				end

				local timePosition = current2.TimePosition

				if timePosition < samplePreviewRange - 0.05 or v49 + 0.05 < timePosition then
					current2.TimePosition = samplePreviewRange
				elseif v49 < timePosition and ref25.current ~= asset then
					ref25.current = asset
					ref29.current()
				end
			end

			if ref6.current and audio then
				if audio.Volume ~= 0 then
					audio.Volume = 0
					v47.Volume = 0
				end

				if audio.IsPlaying then
					audio:Stop()
					v47.Playing = false
				end
			elseif ref2.current and current2 and audio then
				local timePosition = current2.TimePosition

				if math.abs(audio.TimePosition - timePosition) > 0.2 then
					v47.TimePosition = timePosition + 0.1
				end

				if ref3.current or ref4.current then
					audio.Volume = 0
				elseif audio.Volume ~= ref5.current then
					audio.Volume = ref5.current
					v47.Volume = ref5.current
				end

				if audio.Asset ~= current2.Asset then
					audio.Asset = current2.Asset

					if current2.Asset ~= "" then
						v47.SongId = current2.Asset
					end
				end

				if audio.IsPlaying ~= current2.IsPlaying then
					if current2.IsPlaying then
						audio:Play()
					else
						audio:Stop()
					end

					v47.Playing = current2.IsPlaying
				end
			end

			if next(v47) then
				Boombox.SendAudioPatch(v47)
			end
		end, {})
		useClock(40, function(p2)
			Auras.Update(v6.AuraToggle, p2)
		end, { v6 })
		React.useEffect(function()
			local v47 = {}
			local v48 = 0

			local function onBoneAdded(bone)
				if bone:IsA("Bone") then
					v47[bone] = true
				end
			end

			local function onBoneRemoved(bone)
				if bone:IsA("Bone") then
					v47[bone] = nil
				end
			end

			local thread = task.spawn(function()
				if RunContext.IsEdit then
					return
				end

				while task.wait(0.05) do
					local now = os.clock()
					local v49 = math.sin(now)
					local v50 = now - v48 > 0.5
					local character = localPlayer.Character
					local transform = CFrame.Angles(0, now % 6.28, 0) * CFrame.new(0, v49 / 8, 0)
					local v52 = false

					for k in v47 do
						local worldPosition = k.WorldPosition
						v52 = v50 and not v52 and character and (worldPosition - character:GetPivot().Position).Magnitude < 16 and true or v52
						k.Transform = transform
					end

					if not v50 then
						continue
					end

					localPlayer:SetAttribute("RELICSxyz_Trial", v52 and true or nil)
					v48 = now
				end
			end)
			local v49 = Tags.Bind("RelicsTrialMount", onBoneAdded, onBoneRemoved)
			return function()
				v49:Clean()
				task.cancel(thread)
			end
		end, {})
		local v47 = {}

		if Util.IsDemo() then
			for k, adornee in useTagged("RelicsTrialMount") do
				if adornee:HasTag("NoUI") then
					continue
				end

				local billboardGui = adornee:FindFirstChildOfClass("BillboardGui")

				if billboardGui and not billboardGui:HasTag("RelicsGameInfo") then
					billboardGui:Destroy()
				end

				v47[`Game{k}`] = ReactRoblox.createPortal({
					GameInfo = React.createElement(GameInfo, {
						Adornee = adornee
					})
				}, adornee)
			end
		end

		table.sort(v2, function(a, b)
			if a.RequiresPurchase == b.RequiresPurchase then
				return a.SortPriority < b.SortPriority
			end

			return not a.RequiresPurchase
		end)
		React.useEffect(function()
			local current = ref11.current

			if current and current.Asset ~= "" and current.IsPlaying then
				return
			end

			local v48 = nil

			for _, v50 in v2 do
				if isPlaylistLocked(v50, v5) then
					continue
				end

				v48 = v50
				break
			end

			local thread = task.spawn(function()
				if v48 == nil then
					return
				end

				local songs = v48.Songs

				while next(songs) == nil do
					v48.SongAdded:Wait()
				end

				local songIds = MusicData.GetSongIds(v48)
				setSongList(songIds)

				if not current or current.Asset == "" or not current.IsPlaying then
					local songId = songIds[1]
					setState(features.AutoPlay)
					setSong(songId)
				end
			end)
			return function()
				task.cancel(thread)
			end
		end, {
			status,
			v2,
			v5,
			features.AutoPlay
		})
		local windowState = ports.WindowState

		if not windowState then
			if features.StartActive then
				windowState = Enums.WindowState.Full
			else
				windowState = Enums.WindowState.Hidden
			end
		end

		local windowState2, setWindowState = useRestore("WindowState", windowState, ports.WindowStateChanged)
		useSignal(ports.SetWindowState, setWindowState)
		ports.WindowState = windowState2

		if windowState2 == Enums.WindowState.Hidden and RunContext.IsEdit then
			warn("cannot hide window in edit mode!")
			setWindowState(Enums.WindowState.Full)
		end

		local ref30 = React.useRef(nil)
		local ref31 = React.useRef(nil)
		React.useEffect(function()
			local current = ref11.current

			if not current then
				return
			end

			if windowState2 == Enums.WindowState.Hidden and status == Enums.UserStatus.None then
				setState(false)
			end

			local current3 = nil

			for _, v53 in state4 do
				if not current3 or v53.Priority > current3.Priority then
					current3 = v53
				end
			end

			local timePosition = nil
			local playing = nil

			if current3 then
				if not ref30.current then
					ref30.current = {
						Song = song2,
						TimePosition = current.TimePosition,
						Playing = state
					}
				end
			elseif ref30.current then
				local current2 = ref30.current
				timePosition = current2.TimePosition
				playing = current2.Playing
				ref30.current = nil
			end

			local song

			if current3 then
				song = current3.Song
			else
				song = song2
			end

			local sampleMode

			if current3 then
				sampleMode = current3.SampleMode or false
			else
				sampleMode = false
			end

			local v53

			if current3 == nil then
				v53 = false
			else
				v53 = current3.SuppressRemote == true
			end

			local v54 = current3 ~= ref31.current
			ref31.current = current3

			if current.Asset == song then
				if timePosition then
					current.TimePosition = timePosition
				elseif v54 and current3 then
					local timePosition2 = sampleMode and 15 or 0
					current.TimePosition = timePosition2

					if not v53 then
						Boombox.SendAudioPatch({
							SongId = song,
							TimePosition = timePosition2
						})
					end
				end
			else
				local timePosition2 = timePosition or (sampleMode or not current3 and state7) and 15 or 0
				current.TimePosition = timePosition2

				if song and song ~= "" and MusicData.ShouldSongBeEncrypted(song) then
					if MusicData.IsSecretRegistered(song) then
						current.Asset = song or ""
					else
						MusicData.WaitForSecretRegistered(song, 2):andThen(function()
							current.Asset = song or ""
						end):catch(function(p2)
							warn(`[RelicsXYZ.State] ✗ FAILED to wait for secret registration: {song2}`, p2)
							warn("[RelicsXYZ.State]   This song may not play correctly (Error 31 likely)")
							current.Asset = song or ""
						end)
					end
				else
					current.Asset = song or ""
				end

				if not v53 then
					if song and song ~= "" then
						Boombox.SendAudioPatch({
							SongId = song,
							TimePosition = timePosition2
						})
					else
						Boombox.SendAudioPatch({
							TimePosition = timePosition2
						})
					end
				end

				if song and song ~= "" and not (current3 or MusicData.IsSongOfEmote(song) or state7) then
					Recents.PushRecentSong(song)
				end
			end

			if current3 then
				playing = true
			elseif playing == nil then
				playing = state
			end

			if playing and not current.IsPlaying then
				current:Play()
			elseif not playing and current.IsPlaying then
				current:Stop()
			end

			local endedConnection = current.Ended:Connect(function()
				if current3 or looped then
					setState2(0)
					setState(true)
				else
					local count = #v24

					if (count == 0 and #songList or count) <= 1 then
						setState(false)
					else
						v46()
					end
				end
			end)

			if not v53 then
				local sendAudioPatch = Boombox.SendAudioPatch

				if not (proximityAudio or current3) then
					playing = false
				end

				sendAudioPatch({
					Playing = playing
				})
			end

			return function()
				endedConnection:Disconnect()
			end
		end, {
			song2,
			v24,
			looped,
			state,
			proximityAudio,
			songList,
			state2,
			windowState2,
			state4
		})
		local position, setPosition = useRestore("Position", ports.Position)
		useSignal(ports.SetPosition, setPosition)
		ports.Position = position
		local hasBoombox, v55 = useChanged(false, ports.HasBoomboxChanged)
		ports.WindowState = windowState2
		ports.HasBoombox = hasBoombox
		React.useEffect(function()
			v55(status == Enums.UserStatus.BoomboxPurchased or status == Enums.UserStatus.Freemium)

			if status == Enums.UserStatus.TrialMode then
				local v56 = Boombox.GetBoomboxConfigs()[1]
				local productId = v56 and v56.ProductId

				if productId then
					Marketplace.PromptPurchase(productId, Enum.InfoType.Asset)
				end
			end
		end, { status })
		local v57

		if ports.EquipWheelOpen == nil then
			v57 = false
		else
			v57 = ports.EquipWheelOpen
		end

		local equipWheelOpen, setEquipWheelOpen = useChanged(v57, ports.EquipWheelOpenChanged)
		ports.EquipWheelOpen = equipWheelOpen
		useSignal(ports.SetEquipWheelOpen, setEquipWheelOpen)
		local v60 = {
			Ports = ports,
			Status = status,
			Features = features,
			Boombox = boombox,
			GetAudioPlayer = React.useCallback(function()
				return ref11.current
			end, {}),
			GetSpectrogram = React.useCallback(function()
				return ref12.current
			end, {}),
			GoBack = goBack,
			GoForward = v46,
			Playing = state,
			SetPlaying = setState,
			Volume = v8,
			SetVolume = setVolume,
			Looped = looped,
			SetLooped = setLooped,
			Shuffled = v18,
			SetShuffled = setShuffled,
			Widget = state3,
			SetWidget = setState3,
			WindowTab = windowTab,
			SetWindowTab = setWindowTab,
			WindowState = windowState2,
			SetWindowState = setWindowState,
			Queue = queue,
			SetQueue = setQueue,
			Song = song2,
			SetSong = setSong,
			SongList = songList,
			SetSongList = setSongList,
			SampleMode = state7,
			SetSampleMode = setState7,
			Position = position,
			SetPosition = setPosition,
			JumpToTime = state2,
			SetJumpToTime = setState2,
			WidgetReturn = function()
				if state3 and state3.ReturnFunc then
					state3.ReturnFunc()
				end
			end,
			LibraryTab = libraryTab,
			SetLibraryTab = setLibraryTab,
			LibraryCanvasX = libraryCanvasX,
			SetLibraryCanvasX = setLibraryCanvasX,
			CustomizeTab = customizeTab,
			SetCustomizeTab = setCustomizeTab,
			EquipTargetSlot = state5,
			SetEquipTargetSlot = setState5,
			EquipReturnToWheel = state6,
			SetEquipReturnToWheel = setState6,
			EquipWheelOpen = equipWheelOpen,
			SetEquipWheelOpen = setEquipWheelOpen,
			ReturnEvent = React.useState(Signal.new),
			SongOverrides = state4,
			SetSongOverrides = setState4,
			AddSongOverride = addSongOverride,
			RemoveSongOverride = removeSongOverride
		}
		React.useEffect(function()
			if not song2 then
				return
			end

			local song = MusicData.GetSongById(song2)

			if not song then
				return
			end

			if MusicData.GetRequiresOwnership(song) and MusicData.IsSongLockedByBadge(song.Id) and not MusicData.UserHasUnlocked(
				song,
				Players.LocalPlayer.UserId
			) then
				v46()
			end
		end, { song2, v24 })
		return React.createElement(context.Provider, {
			value = v60
		}, p.children, {
			Turntable = React.createElement("Folder", {}, {
				Music = React.createElement("AudioPlayer", {
					[React.Tag] = "RelicsClientAudioPlayer",
					ref = ref11
				}),
				Volume = React.createElement("AudioFader", {
					ref = ref10
				}),
				Spectrogram = React.createElement("AudioAnalyzer", {
					[React.Tag] = "RelicsAudioAnalyzer_Loudness",
					WindowSize = Enum.AudioWindowSize.Small,
					ref = ref12
				}),
				Output = React.createElement("AudioDeviceOutput", {
					ref = ref13
				}),
				Bass = React.createElement("AudioAnalyzer", {
					[React.Tag] = "RelicsAudioAnalyzer_Bass",
					SpectrumEnabled = false,
					ref = ref19
				}, {
					BassFilter = React.createElement("AudioFilter", {
						FilterType = Enum.AudioFilterType.Lowpass24dB,
						Frequency = 100,
						Q = 2,
						ref = ref18
					})
				}),
				Treble = React.createElement("AudioAnalyzer", {
					[React.Tag] = "RelicsAudioAnalyzer_Treble",
					SpectrumEnabled = false,
					ref = ref21
				}, {
					TrebleFilter = React.createElement("AudioFilter", {
						ref = ref20,
						FilterType = Enum.AudioFilterType.Bandpass,
						Frequency = 1100,
						Q = 4
					})
				}),
				Percussion = React.createElement("AudioAnalyzer", {
					[React.Tag] = "RelicsAudioAnalyzer_Percussion",
					SpectrumEnabled = false,
					ref = ref23
				}, {
					PercussionFilter = React.createElement("AudioFilter", {
						FilterType = Enum.AudioFilterType.Highpass48dB,
						Frequency = 3000,
						Q = 0.5,
						ref = ref22
					})
				}),
				Wiring = React.createElement("Folder", nil, {
					MusicToVolume = React.createElement("Wire", {
						SourceInstance = ref11,
						TargetInstance = ref10
					}),
					VolumeToOutput = React.createElement("Wire", {
						SourceInstance = ref10,
						TargetInstance = ref13
					}),
					MusicToSpectrogram = React.createElement("Wire", {
						SourceInstance = ref11,
						TargetInstance = ref12
					}),
					MusicToBassFilter = React.createElement("Wire", {
						SourceInstance = ref11,
						TargetInstance = ref18
					}),
					BassFilterToBass = React.createElement("Wire", {
						SourceInstance = ref18,
						TargetInstance = ref19
					}),
					MusicToTrebleFilter = React.createElement("Wire", {
						SourceInstance = ref11,
						TargetInstance = ref20
					}),
					TrebleFilterToTreble = React.createElement("Wire", {
						SourceInstance = ref20,
						TargetInstance = ref21
					}),
					MusicToPercussionFilter = React.createElement("Wire", {
						SourceInstance = ref11,
						TargetInstance = ref22
					}),
					PercussionFilterToPercussion = React.createElement("Wire", {
						SourceInstance = ref22,
						TargetInstance = ref23
					})
				})
			}),
			Global_Camera = not globalMute and ReactRoblox.createPortal({
				AudioListener = React.createElement("AudioListener", {
					ref = ref14
				}, {
					Wire = React.createElement("Wire", {
						SourceInstance = ref14,
						TargetInstance = ref17
					})
				}),
				RELICSxyz_Listener = React.createElement("AudioListener", {
					AudioInteractionGroup = "RELICSxyz",
					ref = ref15
				}, {
					ListenerToFader = React.createElement("Wire", {
						SourceInstance = ref15,
						TargetInstance = ref9
					})
				}),
				RELICSxyz_Fader = React.createElement("AudioFader", {
					ref = ref9
				}, {
					FaderToOutput = React.createElement("Wire", {
						SourceInstance = ref9,
						TargetInstance = ref16
					})
				}),
				RELICSxyz_Output = React.createElement("AudioDeviceOutput", {
					ref = ref16
				})
			}, workspace.CurrentCamera),
			Global_SoundService = not globalMute and ReactRoblox.createPortal({
				AudioDeviceOutput = React.createElement("AudioDeviceOutput", {
					ref = ref17
				})
			}, SoundService),
			EmotePrompts = React.createElement(React.Fragment, {}, {}),
			GameInfoNodes = React.createElement(React.Fragment, {}, v47)
		})
	end,
	Context = context,
	CreatePorts = createPorts
})