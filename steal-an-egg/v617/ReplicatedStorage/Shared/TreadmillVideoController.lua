local createVector = vector.create
local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SocialService = game:GetService("SocialService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local ButtonHintStrip = require(ReplicatedStorage.Client.ButtonHintStrip)
local CommentsController = require(script.CommentsController)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local FeedSequencer = require(script.FeedSequencer)
local FriendLikesController = require(script.FriendLikesController)
local GUI = require(ReplicatedStorage.Client.GUI)
local GamepadBindings = require(ReplicatedStorage.Client.GamepadBindings)
local ImageColorPulse = require(ReplicatedStorage.Client.UI.VFX.ImageColorPulse)
local LikeController = require(script.LikeController)
local Log = require(ReplicatedStorage.Packages.Log)
local Media = require(script.Media)
local PlatformController = require(ReplicatedStorage.Client.PlatformController)
local Preload = require(ReplicatedStorage.Shared.Utils.Preload)
local warmAssets = Preload.WarmAssets
local Preload2 = require(ReplicatedStorage.Shared.Utils.Preload)
local warmSounds = Preload2.WarmSounds
local RecommendationFeedSource = require(script.RecommendationFeedSource)
local RecommendationFlags = require(script.RecommendationFlags)
local RecommendationSignals = require(script.RecommendationSignals)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Schema = require(script.Types.Schema)
local Signal = require(ReplicatedStorage.Packages.Signal)
local TouchTapTracker = require(ReplicatedStorage.Client.Input.TouchTapTracker)
local TreadmillMediaIdentity = require(ReplicatedStorage.Shared.Modules.TreadmillMediaIdentity)
local TreadmillMediaOverlay = require(ReplicatedStorage.Shared.Modules.TreadmillMediaOverlay)
local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(script.Types.Interface)
local VideoFramePool = require(script.VideoFramePool)
local TryCall = require(ReplicatedStorage.Shared.Utils.TryCall)
local tweenInfo = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false)
local value = Enum.ContextActionPriority.High.Value
local buttonL2 = Enum.KeyCode.ButtonL2
local buttonR2 = Enum.KeyCode.ButtonR2
local tweenInfo2 = TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local color = Color3.fromRGB(255, 0, 0)
local tweenInfo4 = TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true)
local tweenInfo5 = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo6 = TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo7 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
task.spawn(warmSounds, "rbxassetid://84371411600743", "rbxassetid://90908618020821")
local localPlayer = Players.LocalPlayer
local v = Log.new()
local surfaceGui = GUI.TreadmillScreenButtonSwapLeft()
assert(surfaceGui:IsA("SurfaceGui"), "Treadmill left swap GUI must be a SurfaceGui")
local surfaceGui2 = GUI.TreadmillScreenButtonSwapRight()
assert(surfaceGui2:IsA("SurfaceGui"), "Treadmill right swap GUI must be a SurfaceGui")
local surfaceGui3 = GUI.TreadmillScreenButtonShare()
assert(surfaceGui3:IsA("SurfaceGui"), "Treadmill share GUI must be a SurfaceGui")
local surfaceGui4 = GUI.TreadmillScreenSideButtons()
assert(surfaceGui4:IsA("SurfaceGui"), "Treadmill side buttons GUI must be a SurfaceGui")
local surfaceGui5 = GUI.TreadmillVideoSurfaceGui()
assert(surfaceGui5:IsA("SurfaceGui"), "Treadmill video GUI must be a SurfaceGui")
local buttonSwapLeft = surfaceGui.ButtonSwapLeft
assert(buttonSwapLeft:IsA("GuiButton"), "Treadmill left swap button must be a GuiButton")
local buttonSwapRight = surfaceGui2.ButtonSwapRight
assert(buttonSwapRight:IsA("ImageButton"), "Treadmill right swap button must be an ImageButton")
local gamepadGlyph = surfaceGui.ButtonSwapLeft.GamepadGlyph
assert(gamepadGlyph:IsA("GuiObject"), "Treadmill left swap glyph must be a GuiObject")
assert(gamepadGlyph:GetAttribute("GamepadKey") == "ButtonL1", "Treadmill left swap glyph must use ButtonL1")
local gamepadGlyph2 = surfaceGui2.ButtonSwapRight.GamepadGlyph
assert(gamepadGlyph2:IsA("GuiObject"), "Treadmill right swap glyph must be a GuiObject")
assert(gamepadGlyph2:GetAttribute("GamepadKey") == "ButtonR1", "Treadmill right swap glyph must use ButtonR1")
local shareButton = surfaceGui3.Frame.ShareButton
assert(shareButton:IsA("GuiButton"), "Treadmill share button must be a GuiButton")
local videoFrame = surfaceGui5.VideoFrame
assert(videoFrame:IsA("Frame"), "Treadmill video frame container must be a Frame")
local mainVideo = videoFrame.MainVideo
assert(mainVideo:IsA("VideoFrame"), "Treadmill main video must be a VideoFrame")
local stopPlay = videoFrame.StopPlay
assert(stopPlay:IsA("ImageLabel"), "Treadmill stop-play indicator must be an ImageLabel")
local musicImage = videoFrame.MusicImage
assert(musicImage:IsA("ImageLabel"), "Treadmill music image must be an ImageLabel")
local loading = videoFrame.Loading
assert(loading:IsA("GuiObject"), "Treadmill video loading frame must be a GuiObject")
local spin = loading.Spin
assert(spin:IsA("GuiObject"), "Treadmill video loading spinner must be a GuiObject")
local bar = videoFrame.Bar
assert(bar:IsA("GuiObject"), "Treadmill video bar must be a GuiObject")
local progress = bar.Progress
assert(progress:IsA("GuiObject"), "Treadmill video progress must be a GuiObject")
local goToNext = videoFrame.GoToNext
assert(goToNext:IsA("Frame"), "Treadmill VideoFrame.GoToNext must be a Frame")
local glow = goToNext.Glow
assert(glow:IsA("ImageLabel"), "Treadmill GoToNext.Glow must be an ImageLabel")
local arrow = goToNext.Arrow
assert(arrow:IsA("ImageLabel"), "Treadmill GoToNext.Arrow must be an ImageLabel")
local arrowShadow = goToNext.ArrowShadow
assert(arrowShadow:IsA("ImageLabel"), "Treadmill GoToNext.ArrowShadow must be an ImageLabel")
local label = goToNext.Label
assert(label:IsA("TextLabel"), "Treadmill GoToNext.Label must be a TextLabel")
local labelShadow = goToNext.LabelShadow
assert(labelShadow:IsA("TextLabel"), "Treadmill GoToNext.LabelShadow must be a TextLabel")
local position = arrow.Position
local position2 = arrowShadow.Position
local paused = videoFrame.Paused
assert(paused:IsA("Frame"), "Treadmill VideoFrame.Paused must be a Frame")
local glow2 = paused.Glow
assert(glow2:IsA("ImageLabel"), "Treadmill Paused.Glow must be an ImageLabel")
local stopPlay2 = paused.StopPlay
assert(stopPlay2:IsA("ImageLabel"), "Treadmill Paused.StopPlay must be an ImageLabel")
local enjoyFree = stopPlay2:FindFirstChild("EnjoyFree")
local videoCounter = videoFrame:FindFirstChild("VideoCounter")
local v2 = {
	{
		Instance = goToNext,
		Property = "BackgroundTransparency",
		Value = goToNext.BackgroundTransparency
	},
	{
		Instance = glow,
		Property = "ImageTransparency",
		Value = glow.ImageTransparency
	},
	{
		Instance = arrow,
		Property = "ImageTransparency",
		Value = arrow.ImageTransparency
	},
	{
		Instance = arrowShadow,
		Property = "ImageTransparency",
		Value = arrowShadow.ImageTransparency
	},
	{
		Instance = label,
		Property = "TextTransparency",
		Value = label.TextTransparency
	},
	{
		Instance = labelShadow,
		Property = "TextTransparency",
		Value = labelShadow.TextTransparency
	}
}
local v3 = {
	{
		Instance = paused,
		Property = "BackgroundTransparency",
		Value = paused.BackgroundTransparency
	},
	{
		Instance = glow2,
		Property = "ImageTransparency",
		Value = glow2.ImageTransparency
	},
	{
		Instance = stopPlay2,
		Property = "ImageTransparency",
		Value = stopPlay2.ImageTransparency
	}
}

if enjoyFree ~= nil and enjoyFree:IsA("TextLabel") then
	table.insert(v3, {
		Instance = enjoyFree,
		Property = "TextTransparency",
		Value = enjoyFree.TextTransparency
	})
end

local count = 0
local v4 = nil
local v5 = nil
local clone = table.clone(Media)

if Constants.IS_STUDIO then
	local treadmillMediaEntries, v6 = Schema.TreadmillMediaEntries(clone)
	assert(treadmillMediaEntries, (`Failed to validate treadmill video media entries: {v6}`))
end

TreadmillMediaOverlay.ApplyTo(clone)
task.spawn(function()
	RecommendationFlags.Enabled.Loaded:Wait()
	task.wait(math.random() * RecommendationFlags.PrefetchJitterSeconds:Get())
	RecommendationFeedSource.PrefetchFeed(clone)
end)
local TreadmillVideoController = {
	MediaChanged = Signal.new(),
	Stopped = Signal.new()
}

local function scaleUDim2(udim: UDim2, p: number)
	return UDim2.new(UDim.new(udim.X.Scale * p, udim.X.Offset * p), UDim.new(udim.Y.Scale * p, udim.Y.Offset * p))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelStopPlayTween(p)
	local stopPlayTween = p.StopPlayTween
	p.StopPlayTween = nil

	if stopPlayTween ~= nil then
		stopPlayTween:Cancel()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resetStopPlayIndicator(p)
	cancelStopPlayTween(p) -- equivalent call inferred; original call site unknown
	p.StopPlay.ImageTransparency = 0
	p.StopPlay.Size = p.StopPlayBaseSize
end

local function animateStopPlayIndicator(state, flag: boolean)
	cancelStopPlayTween(state) -- equivalent call inferred; original call site unknown
	local stopPlay3 = state.StopPlay
	stopPlay3.Visible = true
	stopPlay3.Image = flag and "rbxassetid://90908618020821" or "rbxassetid://84371411600743"
	stopPlay3.ImageTransparency = 0
	local stopPlayBaseSize = state.StopPlayBaseSize
	local v6 = flag and 1.24 or 0.76
	stopPlay3.Size = UDim2.new(
		UDim.new(stopPlayBaseSize.X.Scale * v6, stopPlayBaseSize.X.Offset * v6),
		UDim.new(stopPlayBaseSize.Y.Scale * v6, stopPlayBaseSize.Y.Offset * v6)
	)
	local tween = TweenService:Create(stopPlay3, tweenInfo2, {
		Size = state.StopPlayBaseSize
	})
	state.StopPlayTween = tween
	tween.Completed:Once(function()
		if state.StopPlayTween ~= tween then
			return
		end

		state.StopPlayTween = nil

		if not flag then
			return
		end

		local tween2 = TweenService:Create(stopPlay3, tweenInfo3, {
			ImageTransparency = 1
		})
		state.StopPlayTween = tween2
		tween2.Completed:Once(function()
			if state.StopPlayTween ~= tween2 then
				return
			end

			state.StopPlayTween = nil
			stopPlay3.Visible = false
			stopPlay3.ImageTransparency = 0
		end)
		tween2:Play()
	end)
	tween:Play()
end

local function playCardFadeIn(items, maid, tweenInfo8)
	for _, item in items do
		local instance = item.Instance
		instance[item.Property] = 1
		local v8 = TweenService:Create(item.Instance, tweenInfo8, {
			[item.Property] = item.Value
		})
		local v11 = item
		maid:Add(function()
			v8:Cancel()
			instance[v11.Property] = v11.Value
		end)
		v8:Play()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hidePausedCard(state)
	local pausedCardTrove = state.PausedCardTrove
	state.PausedCardTrove = nil

	if pausedCardTrove ~= nil then
		pausedCardTrove:Destroy()
	end

	paused.Visible = false

	if state.MusicSound ~= nil then
		state.MusicImage.Visible = true
	end

	local pausedPreviewFrame = state.PausedPreviewFrame
	local pausedPreviewBaseSize = state.PausedPreviewBaseSize
	state.PausedPreviewFrame = nil
	state.PausedPreviewBaseSize = nil

	if pausedPreviewFrame ~= nil and pausedPreviewBaseSize ~= nil then
		pausedPreviewFrame.Size = pausedPreviewBaseSize
	end
end

local function showPausedCard(state)
	if state.PausedCardTrove ~= nil or state.EndCardTrove ~= nil then
		return
	end

	local pausedCardTrove = Trove.new()
	state.PausedCardTrove = pausedCardTrove
	playCardFadeIn(v3, pausedCardTrove, tweenInfo7)

	if enjoyFree ~= nil and enjoyFree:IsA("TextLabel") then
		enjoyFree.Visible = not state.HasPlayedMedia
	end

	paused.Visible = true
	state.MusicImage.Visible = false
	local activeFrame = state.VideoFramePool.GetActiveFrame()

	if activeFrame.TimePosition <= 0 and not activeFrame.Playing then
		pcall(function()
			activeFrame:Play()
			activeFrame:Pause()
			activeFrame.TimePosition = 0
		end)
	end

	local size = activeFrame.Size
	local v7 = math.max(
		not (size.X.Scale > 0) and 1 or 1 / size.X.Scale,
		not (size.Y.Scale > 0) and 1 or 1 / size.Y.Scale
	)

	if v7 > 1 then
		state.PausedPreviewFrame = activeFrame
		state.PausedPreviewBaseSize = size
		activeFrame.Size = UDim2.new(
			UDim.new(size.X.Scale * v7, size.X.Offset * v7),
			UDim.new(size.Y.Scale * v7, size.Y.Offset * v7)
		)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideGoToNext(data)
	local endCardTrove = data.EndCardTrove
	data.EndCardTrove = nil

	if endCardTrove ~= nil then
		endCardTrove:Destroy()
	end

	goToNext.Visible = false
end

local function spawnGoToNextPulse(maid)
	local clone2 = arrow:Clone()
	clone2.Name = "ArrowPulse"
	clone2.ZIndex = math.max(arrow.ZIndex - 1, 0)
	clone2.ImageTransparency = 0.35
	clone2.Parent = goToNext
	maid:Add(clone2)
	local size = arrow.Size
	local v9 = TweenService:Create(clone2, tweenInfo6, {
		Size = UDim2.new(
			UDim.new(size.X.Scale * 2.2, size.X.Offset * 2.2),
			UDim.new(size.Y.Scale * 2.2, size.Y.Offset * 2.2)
		),
		ImageTransparency = 1
	})
	v9.Completed:Once(function()
		clone2:Destroy()
	end)
	v9:Play()
end

local function showGoToNext(state)
	if state.EndCardTrove ~= nil then
		return
	end

	hidePausedCard(state) -- equivalent call inferred; original call site unknown
	local maid = Trove.new()
	state.EndCardTrove = maid
	state.StopPlay.Visible = false
	state.SideButtonsSurfaceGui.Enabled = false
	state.ShareSurfaceGui.Enabled = false
	playCardFadeIn(v2, maid, tweenInfo5)
	goToNext.Visible = true
	local swaySeconds = goToNext:GetAttribute("SwaySeconds") or 1.2
	local swayScale = goToNext:GetAttribute("SwayScale") or 0.02
	local lastTime = os.clock()
	local v6 = 0
	maid:BindToRenderStep("TreadmillGoToNextCard", Enum.RenderPriority.Last.Value, function()
		local v7 = os.clock() - lastTime
		local v8 = math.sin(v7 * 3.141592653589793 * 2 / swaySeconds) * swayScale
		local uDim = UDim2.fromScale(v8, 0)
		arrow.Position = position + uDim
		arrowShadow.Position = position2 + uDim
		local v9 = math.floor(v7 / swaySeconds + 0.75)

		if v6 < v9 then
			v6 = v9
			spawnGoToNextPulse(maid)
		end
	end)
	maid:Add(function()
		arrow.Position = position
		arrowShadow.Position = position2
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setSoundPlaying(object, flag: boolean)
	if not flag then
		object:Pause()
	elseif object.TimePosition > 0 then
		object:Resume()
	else
		object:Play()
	end
end

local function setMediaPlaying(state, flag: boolean, flag2: boolean?)
	local musicSound = state.MusicSound

	if musicSound == nil then
		if flag then
			state.VideoFramePool.GetActiveFrame():Play()
			local videoBackgroundMusicSound = state.VideoBackgroundMusicSound

			if videoBackgroundMusicSound ~= nil then
				setSoundPlaying(videoBackgroundMusicSound, true) -- equivalent call inferred; original call site unknown
			end
		else
			state.VideoFramePool.GetActiveFrame():Pause()
			local videoBackgroundMusicSound = state.VideoBackgroundMusicSound

			if videoBackgroundMusicSound ~= nil then
				videoBackgroundMusicSound:Pause()
			end
		end
	elseif flag then
		setSoundPlaying(musicSound, true) -- equivalent call inferred; original call site unknown
	else
		musicSound:Pause()
	end

	if flag then
		state.HasPlayedMedia = true
		hidePausedCard(state) -- equivalent call inferred; original call site unknown
	else
		showPausedCard(state)
	end

	if flag2 ~= false then
		animateStopPlayIndicator(state, flag)
		return
	end

	resetStopPlayIndicator(state) -- equivalent call inferred; original call site unknown
	state.StopPlay.Visible = not flag
end

local function getSurfaceHitScale(videoScreenPart, face, position3: Vector3)
	local vector2 = face == Enum.NormalId.Front and createVector(0, 0, -1) or face == Enum.NormalId.Back and createVector(
		0,
		0,
		1
	) or face == Enum.NormalId.Right and createVector(1, 0, 0) or face == Enum.NormalId.Left and createVector(-1, 0, 0) or face == Enum.NormalId.Top and createVector(
		0,
		1,
		0
	) or createVector(0, -1, 0)
	local unit = vector2:Cross(math.abs(vector2.Y) == 1 and createVector(0, 0, 1) or createVector(0, 1, 0)).Unit
	local unit2 = unit:Cross(vector2).Unit
	local pointToObjectSpace = videoScreenPart.CFrame:PointToObjectSpace(position3)
	local v6 = videoScreenPart.Size * 0.5
	local v7 = math.abs(vector2.X) * v6.X + math.abs(vector2.Y) * v6.Y + math.abs(vector2.Z) * v6.Z
	local v8 = math.abs(unit.X) * v6.X + math.abs(unit.Y) * v6.Y + math.abs(unit.Z) * v6.Z
	local v9 = math.abs(unit2.X) * v6.X + math.abs(unit2.Y) * v6.Y + math.abs(unit2.Z) * v6.Z
	local vector3 = pointToObjectSpace - vector2 * v7
	return Vector2.new(
		math.clamp(0.5 - vector3:Dot(unit) / (v8 * 2), 0, 1),
		(math.clamp(0.5 - vector3:Dot(unit2) / (v9 * 2), 0, 1))
	)
end

local function getVideoScreenTapScale(data, point: Vector2)
	local currentCamera = Workspace.CurrentCamera

	if currentCamera == nil then
		return nil
	end

	local screenPointToRay = currentCamera:ScreenPointToRay(point.X, point.Y)
	local raycastResult = Workspace:Raycast(
		screenPointToRay.Origin,
		screenPointToRay.Direction * 1000,
		data.VideoScreenRaycastParams
	)

	if raycastResult == nil or raycastResult.Instance ~= data.VideoScreenPart then
		return nil
	end

	return getSurfaceHitScale(data.VideoScreenPart, data.VideoSurfaceGui.Face, raycastResult.Position)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toggleMediaPlaying(p)
	local musicSound = p.MusicSound

	if musicSound == nil then
		setMediaPlaying(p, not p.VideoFramePool.GetActiveFrame().Playing)
	else
		setMediaPlaying(p, not musicSound.IsPlaying)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function setVideoProgress(data, value2: number)
	local size = data.Progress.Size
	data.Progress.Size = UDim2.new(math.clamp(value2, 0, 1), 0, size.Y.Scale, size.Y.Offset)
end

local function updateMediaProgress(data)
	local musicSound = data.MusicSound

	if musicSound == nil then
		local activeFrame = data.VideoFramePool.GetActiveFrame()
		local timeLength = activeFrame.TimeLength

		if timeLength <= 0 then
			local size = data.Progress.Size
			data.Progress.Size = UDim2.new(0, 0, size.Y.Scale, size.Y.Offset)
		else
			setVideoProgress(data, activeFrame.TimePosition / timeLength) -- equivalent call inferred; original call site unknown
		end
	else
		local timeLength = musicSound.TimeLength

		if timeLength <= 0 then
			local size = data.Progress.Size
			data.Progress.Size = UDim2.new(0, 0, size.Y.Scale, size.Y.Offset)
		else
			setVideoProgress(data, musicSound.TimePosition / timeLength) -- equivalent call inferred; original call site unknown
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getWatchedFraction(p)
	local musicSound = p.MusicSound

	if musicSound == nil then
		local activeFrame = p.VideoFramePool.GetActiveFrame()
		local timeLength = activeFrame.TimeLength

		if timeLength <= 0 then
			return nil
		end

		return activeFrame.TimePosition / timeLength
	else
		local timeLength = musicSound.TimeLength

		if timeLength <= 0 then
			return nil
		end

		return musicSound.TimePosition / timeLength
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideLoading(state)
	local loadingTween = state.LoadingTween
	state.LoadingTween = nil

	if loadingTween ~= nil then
		loadingTween:Cancel()
	end

	state.Loading.Visible = false
	state.LoadingSpin.Rotation = 0
end

local function showLoading(state)
	hideLoading(state) -- equivalent call inferred; original call site unknown
	state.Loading.Visible = true
	state.ShareSurfaceGui.Enabled = false
	state.SideButtonsSurfaceGui.Enabled = false
	local tween = TweenService:Create(state.LoadingSpin, tweenInfo, {
		Rotation = 360
	})
	state.LoadingTween = tween
	tween:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearMusicImage(state)
	state.MusicImage.Visible = false
	state.MusicImage.Image = ""
	local musicSound = state.MusicSound
	state.MusicSound = nil

	if musicSound == nil then
		return
	end

	musicSound:Stop()
	musicSound:Destroy()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clearVideoBackgroundMusic(data)
	local videoBackgroundMusicSound = data.VideoBackgroundMusicSound
	data.VideoBackgroundMusicSound = nil

	if videoBackgroundMusicSound == nil then
		return
	end

	videoBackgroundMusicSound:Stop()
	videoBackgroundMusicSound:Destroy()
end

local function unloadVideo(data)
	data.VideoTrove:Clean()
	hideGoToNext(data) -- equivalent call inferred; original call site unknown
	hidePausedCard(data) -- equivalent call inferred; original call site unknown
	hideLoading(data) -- equivalent call inferred; original call site unknown
	clearMusicImage(data) -- equivalent call inferred; original call site unknown
	clearVideoBackgroundMusic(data) -- equivalent call inferred; original call site unknown
	data.VideoFramePool.ClearActive()
	data.MainVideo.Size = data.MainVideoBaseSize
	data.MainVideo.Volume = 1
	data.MainVideo.Video = ""
	resetStopPlayIndicator(data) -- equivalent call inferred; original call site unknown
	data.StopPlay.Visible = true
	local size = data.Progress.Size
	data.Progress.Size = UDim2.new(0, 0, size.Y.Scale, size.Y.Offset)
end

local function wrapVideoIndex(p: number)
	if p < 1 then
		return #clone
	end

	if #clone < p then
		return 1
	end

	return p
end

local function preloadMediaIndices(p, list)
	local v6 = {}
	local v7 = {}

	for _, mediaIndex in ipairs(list) do
		local mediaEntry = clone[mediaIndex]

		if mediaEntry.Kind == "Video" then
			table.insert(v7, {
				MediaEntry = mediaEntry,
				MediaIndex = mediaIndex
			})
			local music = mediaEntry.Music

			if music then
				table.insert(v6, music.SoundId)
			end
		elseif mediaEntry.Kind == "MusicImage" then
			table.insert(v6, mediaEntry.Image)
			table.insert(v6, mediaEntry.SoundId)
		end
	end

	p.VideoFramePool.Preload(v7)

	if #v6 > 0 then
		task.spawn(warmAssets, v6)
	end
end

local function preloadDirectionalAssets(state, videoIndex: number, p: number)
	if p < 0 then
		return
	end

	local v6 = {}
	local v7 = videoIndex + p * 1
	local v8

	if v7 < 1 then
		v8 = #clone
	else
		v8 = #clone < v7 and 1 or v7
	end

	table.insert(v6, v8)
	local v9 = videoIndex + p * 2
	local v10

	if v9 < 1 then
		v10 = #clone
	else
		v10 = #clone < v9 and 1 or v9
	end

	table.insert(v6, v10)
	local v11 = videoIndex + p * 3
	local v12

	if v11 < 1 then
		v12 = #clone
	else
		v12 = #clone < v11 and 1 or v11
	end

	table.insert(v6, v12)
	preloadMediaIndices(state, v6)
end

local function loadVideoBackgroundMusic(state, music)
	local sound = Instance.new("Sound")
	sound.Name = "TreadmillVideoBackgroundMusic"
	sound.SoundId = music.SoundId
	sound.Volume = music.Volume
	sound.Looped = true
	sound.Parent = state.MainVideo
	state.VideoBackgroundMusicSound = sound
	state.VideoTrove:Add(function()
		if state.VideoBackgroundMusicSound == sound then
			state.VideoBackgroundMusicSound = nil
		end

		if sound.Parent ~= nil then
			sound:Stop()
			sound:Destroy()
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function resetVideoBackgroundMusic(data)
	local videoBackgroundMusicSound = data.VideoBackgroundMusicSound

	if videoBackgroundMusicSound == nil then
		return
	end

	videoBackgroundMusicSound:Stop()
	videoBackgroundMusicSound.TimePosition = 0
end

local function loadVideoMedia(data, p, videoSerial: number)
	local v6 = data.VideoFramePool.Activate(data.VideoIndex, p)
	v6.Size = p.Size or data.MainVideoBaseSize
	local size = data.Progress.Size
	data.Progress.Size = UDim2.new(0, 0, size.Y.Scale, size.Y.Offset)
	local music = p.Music

	if music ~= nil then
		loadVideoBackgroundMusic(data, music)
	end

	data.VideoTrove:Add(v6.Ended:Connect(function()
		if count ~= data.Token or data.VideoSerial ~= videoSerial then
			return
		end

		RecommendationSignals.MarkEnded()
		resetVideoBackgroundMusic(data) -- equivalent call inferred; original call site unknown
		showGoToNext(data)
	end))

	if v6.IsLoaded then
		hideLoading(data) -- equivalent call inferred; original call site unknown
		data.ShareSurfaceGui.Enabled = true
		data.SideButtonsSurfaceGui.Enabled = true
		setMediaPlaying(data, data.HasPlayedMedia, false)
	else
		data.StopPlay.Visible = false
		showLoading(data)
		local loadedConnection = nil
		loadedConnection = v6.Loaded:Connect(function()
			if count ~= data.Token or data.VideoSerial ~= videoSerial then
				return
			end

			loadedConnection:Disconnect()
			hideLoading(data) -- equivalent call inferred; original call site unknown
			data.ShareSurfaceGui.Enabled = true
			data.SideButtonsSurfaceGui.Enabled = true
			setMediaPlaying(data, data.HasPlayedMedia, false)
		end)
		data.VideoTrove:Add(loadedConnection)
	end
end

local function loadMusicImageMedia(state, data, videoSerial: number)
	state.VideoFramePool.ClearActive()
	state.MainVideo.Video = ""
	state.MusicImage.Image = data.Image
	state.MusicImage.Visible = true
	local size = state.Progress.Size
	state.Progress.Size = UDim2.new(0, 0, size.Y.Scale, size.Y.Offset)
	local sound = Instance.new("Sound")
	sound.Name = "TreadmillMusicImageSound"
	sound.SoundId = data.SoundId
	sound.Volume = data.Volume
	sound.Parent = state.MainVideo
	sound.Looped = false
	state.MusicSound = sound
	state.VideoTrove:Add(function()
		if state.MusicSound == sound then
			state.MusicSound = nil
		end

		if sound.Parent ~= nil then
			sound:Stop()
			sound:Destroy()
		end
	end)
	state.VideoTrove:Add(sound.Ended:Connect(function()
		if count ~= state.Token or state.VideoSerial ~= videoSerial then
			return
		end

		RecommendationSignals.MarkEnded()
		showGoToNext(state)
	end))

	if sound.IsLoaded then
		hideLoading(state) -- equivalent call inferred; original call site unknown
		state.ShareSurfaceGui.Enabled = true
		state.SideButtonsSurfaceGui.Enabled = true
		setMediaPlaying(state, state.HasPlayedMedia, false)
	else
		state.StopPlay.Visible = false
		showLoading(state)
		local loadedConnection = nil
		loadedConnection = sound.Loaded:Connect(function()
			if count ~= state.Token or state.VideoSerial ~= videoSerial then
				return
			end

			loadedConnection:Disconnect()
			hideLoading(state) -- equivalent call inferred; original call site unknown
			state.ShareSurfaceGui.Enabled = true
			state.SideButtonsSurfaceGui.Enabled = true
			setMediaPlaying(state, state.HasPlayedMedia, false)
		end)
		state.VideoTrove:Add(loadedConnection)
	end
end

local function loadVideo(state, p: number, p2, p3: number, p4)
	state.VideoSerial += 1
	local videoSerial = state.VideoSerial
	local videoIndex

	if p < 1 then
		videoIndex = #clone
	else
		videoIndex = #clone < p and 1 or p
	end

	state.VideoIndex = videoIndex

	if RecommendationSignals.HasActiveView() then
		local endView = RecommendationSignals.EndView
		local watchedFraction = getWatchedFraction(state) -- equivalent call inferred; original call site unknown
		endView(watchedFraction)
	end

	if p4 == nil then
		if p2 ~= nil then
			Remotes.Treadmill.RefreshClipCursor:FireServer(p2)
		end
	else
		Remotes.Treadmill.SubmitClipView:FireServer(p4.MediaKey)
		RecommendationSignals.BeginView(p4)
	end

	unloadVideo(state)
	state.LikeController:UpdatePresentation()
	state.FriendLikesController:HandleMediaChanged()
	local v7 = clone[state.VideoIndex]
	TreadmillVideoController.MediaChanged:Fire(v7, state.VideoScreenPart)

	if v7.Kind == "Video" then
		loadVideoMedia(state, v7, videoSerial)
	else
		loadMusicImageMedia(state, v7, videoSerial)
	end

	if p4 == nil then
		preloadDirectionalAssets(state, state.VideoIndex, p3)
	else
		preloadMediaIndices(state, RecommendationFeedSource.PeekAhead(3))
	end
end

local function cleanupRuntime()
	count += 1
	TreadmillVideoController.Stopped:Fire()
	local v6 = v4
	v4 = nil

	if v6 ~= nil then
		v6:Destroy()
	end

	local v7 = v5
	v5 = nil

	if v7 == nil then
		return
	end

	if RecommendationSignals.HasActiveView() then
		local endView = RecommendationSignals.EndView
		local watchedFraction = getWatchedFraction(v7) -- equivalent call inferred; original call site unknown
		endView(watchedFraction)
	end

	unloadVideo(v7)
	v7.LikeController:Destroy()
	v7.FriendLikesController:Destroy()
	v7.StopPlay.Visible = true
	v7.LeftSurfaceGui.Enabled = false
	v7.RightSurfaceGui.Enabled = false
	v7.ShareSurfaceGui.Enabled = false
	v7.SideButtonsSurfaceGui.Enabled = false
	v7.VideoSurfaceGui.Enabled = false
	v7.Trove:Destroy()
end

local function projectConsoleSwapMarker(guiObject, p: string)
	guiObject.Visible = PlatformController.IsConsole() and guiObject:GetAttribute("ManualVisibility") ~= true

	if not PlatformController.IsConsole() then
		return
	end

	if guiObject:IsA("ImageLabel") then
		guiObject.Image = GamepadBindings.GlyphFor(p)
	elseif guiObject:IsA("ImageButton") then
		guiObject.Image = GamepadBindings.GlyphFor(p)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function projectConsoleSwapMarkers()
	projectConsoleSwapMarker(gamepadGlyph, "ButtonL1")
	projectConsoleSwapMarker(gamepadGlyph2, "ButtonR1")
end

local function isExcludedMediaIndex(p: number)
	local v6 = clone[p]
	return v6 ~= nil and TreadmillMediaOverlay.IsExcluded(TreadmillMediaIdentity.GetMediaKey(v6))
end

local function updateVideoCounter()
	if videoCounter == nil or not videoCounter:IsA("TextLabel") then
		return
	end

	local count2 = 0

	for k in clone do
		local v6 = clone[k]
		local v7

		if v6 == nil then
			v7 = false
		else
			v7 = TreadmillMediaOverlay.IsExcluded(TreadmillMediaIdentity.GetMediaKey(v6))
		end

		if not v7 then
			count2 += 1
		end
	end

	videoCounter.Text = `TOTAL VIDEOS: {count2}`
end

local function sequencerNextSkippingExcluded(p)
	local next, v6 = FeedSequencer.Next(p.Feed)

	for _ = 1, #clone do
		local v7 = clone[next]
		local v8

		if v7 == nil then
			v8 = false
		else
			v8 = TreadmillMediaOverlay.IsExcluded(TreadmillMediaIdentity.GetMediaKey(v7))
		end

		if not v8 then
			break
		end

		Remotes.Treadmill.RefreshClipCursor:FireServer(v6)
		next, v6 = FeedSequencer.Next(p.Feed)
	end

	return next, v6
end

local function sequencerPreviousSkippingExcluded(p)
	local previous, v6, v7 = FeedSequencer.Previous(p.Feed)

	if not v7 then
		return previous, v6, false
	end

	for _ = 1, #clone do
		local v8 = clone[previous]
		local v9

		if v8 == nil then
			v9 = false
		else
			v9 = TreadmillMediaOverlay.IsExcluded(TreadmillMediaIdentity.GetMediaKey(v8))
		end

		if not v9 then
			return previous, v6, true
		end

		Remotes.Treadmill.RefreshClipCursor:FireServer(v6)
		local v10
		previous, v6, v10 = FeedSequencer.Previous(p.Feed)

		if v10 then
			continue
		end

		local v11, v12 = sequencerNextSkippingExcluded(p)
		return v11, v12, true
	end

	return previous, v6, true
end

local function bindVideoRuntime(tool, p: string, p2, token: number)
	if token ~= count then
		return
	end

	local videoPresentationParts, adornee, adornee2 = TreadmillUtil.FindVideoPresentationParts(tool)

	if videoPresentationParts == nil or adornee == nil or adornee2 == nil then
		v:AtTrace():Log((`[TreadmillVideoController] Skipped video presentation for {p}`))
		return
	end

	if token ~= count then
		return
	end

	local maid = Trove.new()
	local extended = maid:Extend()
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Include
	raycastParams.FilterDescendantsInstances = { videoPresentationParts }
	local runtime = FeedSequencer.CreateRuntime(clone, p2, localPlayer.UserId)
	RecommendationFeedSource.PrefetchFeed(clone)
	local readyItem = RecommendationFeedSource.GetReadyItem()
	local videoFramePool = VideoFramePool.new(mainVideo)
	local v9 = nil
	local likeController = LikeController.new(function()
		local v11 = v9

		if v11 == nil then
			return 1
		end

		return v11.VideoIndex
	end, function()
		local v11 = v9
		assert(v11 ~= nil, "Treadmill runtime must exist before handling like single tap")
		local requestNext = v11.RequestNext

		if v11.EndCardTrove ~= nil and requestNext ~= nil then
			requestNext()
			return
		end

		toggleMediaPlaying(v11) -- equivalent call inferred; original call site unknown
	end, clone, maid, videoFrame, videoPresentationParts)
	local v11 = {
		EndCardTrove = nil,
		Feed = runtime,
		FriendLikesController = FriendLikesController.new(function()
			local v12 = v9

			if v12 == nil then
				return 1
			end

			return v12.VideoIndex
		end, function()
			likeController:SuppressScreenTap()
		end, clone, maid, videoPresentationParts),
		HasPlayedMedia = false,
		LeftSurfaceGui = surfaceGui,
		LikeController = likeController,
		Loading = loading,
		LoadingTween = nil,
		PausedCardTrove = nil,
		PausedPreviewBaseSize = nil,
		PausedPreviewFrame = nil,
		RequestNext = nil,
		LoadingSpin = spin,
		MainVideo = mainVideo,
		MainVideoBaseSize = mainVideo.Size,
		MusicImage = musicImage,
		MusicSound = nil,
		Progress = progress,
		RecommendationActive = readyItem ~= nil,
		RightSurfaceGui = surfaceGui2,
		ShareSurfaceGui = surfaceGui3,
		SideButtonsSurfaceGui = surfaceGui4,
		StopPlay = stopPlay,
		StopPlayBaseSize = stopPlay.Size,
		StopPlayTween = nil,
		Token = token,
		Trove = maid,
		VideoBackgroundMusicSound = nil,
		VideoFrame = videoFrame,
		VideoIndex = 1,
		VideoScreenPart = videoPresentationParts,
		VideoScreenRaycastParams = raycastParams,
		VideoSerial = 0,
		VideoSurfaceGui = surfaceGui5,
		VideoTrove = extended,
		VideoFramePool = videoFramePool
	}
	v9 = v11
	maid:Add(videoFramePool.Destroy)

	if token ~= count then
		maid:Destroy()
		return
	end

	v5 = v11
	surfaceGui.Adornee = adornee
	surfaceGui2.Adornee = adornee2
	surfaceGui3.Adornee = videoPresentationParts
	surfaceGui4.Adornee = videoPresentationParts
	surfaceGui5.Adornee = videoPresentationParts
	surfaceGui.Enabled = true
	surfaceGui2.Enabled = true
	surfaceGui3.Enabled = true
	surfaceGui4.Enabled = true
	surfaceGui5.Enabled = true
	videoFrame.Active = true
	mainVideo.Active = true
	local v12

	if v11.Feed.HasSwappedRight then
		v12 = nil
	else
		v12 = ImageColorPulse.Start(buttonSwapRight, color, tweenInfo4)
		maid:Add(function()
			local v13 = v12

			if v13 ~= nil then
				v13()
				v12 = nil
			end
		end)
	end

	local function swapLeft()
		if v11.RecommendationActive then
			local previous, v13 = RecommendationFeedSource.Previous()

			if previous == nil then
				v11.RecommendationActive = false
			else
				if v13 then
					loadVideo(v11, previous.MediaIndex, nil, -1, previous)
				end

				return
			end
		end

		local v13, v14, v15 = sequencerPreviousSkippingExcluded(v11)

		if not v15 then
			return
		end

		loadVideo(v11, v13, v14, -1)
	end

	local function swapRight()
		local v13 = v12

		if v13 ~= nil then
			v13()
			v12 = nil
		end

		if v11.RecommendationActive then
			local next = RecommendationFeedSource.Next()

			if next == nil then
				v11.RecommendationActive = false
			else
				loadVideo(v11, next.MediaIndex, nil, 1, next)
				return
			end
		end

		local v14, v15 = sequencerNextSkippingExcluded(v11)
		loadVideo(v11, v14, v15, 1)
	end

	v11.RequestNext = swapRight
	maid:Add(ButtonFX(buttonSwapLeft, nil, swapLeft))
	maid:Add(ButtonFX(buttonSwapRight, nil, swapRight))
	projectConsoleSwapMarkers() -- equivalent call inferred; original call site unknown
	maid:Add(PlatformController.Changed:Connect(projectConsoleSwapMarkers))
	ContextActionService:BindActionAtPriority("TreadmillVideoActions", function(_: string, p4, p5)
		if p4 ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Sink
		end

		local keyCode = p5.KeyCode

		if keyCode == Enum.KeyCode.ButtonL1 then
			swapLeft()
		elseif keyCode == Enum.KeyCode.ButtonR1 then
			swapRight()
		elseif keyCode == Enum.KeyCode.ButtonL2 then
			likeController:Toggle()
		elseif keyCode == Enum.KeyCode.ButtonR2 then
			CommentsController.Toggle()
		end

		return Enum.ContextActionResult.Sink
	end, false, value, Enum.KeyCode.ButtonL1, Enum.KeyCode.ButtonR1, Enum.KeyCode.ButtonL2, Enum.KeyCode.ButtonR2)
	maid:Add(function()
		ContextActionService:UnbindAction("TreadmillVideoActions")
	end)
	ButtonHintStrip.PinLeft(0.2)
	ButtonHintStrip.Present("TreadmillLike", buttonL2, "Like")

	if CommentsController.IsAvailable() then
		ButtonHintStrip.Present("TreadmillComments", buttonR2, "Comments")
	end

	maid:Add(function()
		ButtonHintStrip.Retract("TreadmillLike")
		ButtonHintStrip.Retract("TreadmillComments")
		ButtonHintStrip.PinLeft(nil)
	end)
	maid:Add(ButtonFX(shareButton, nil, function()
		v11.LikeController:SuppressScreenTap()
		local v13, v14 = TryCall(SocialService.CanSendGameInviteAsync, SocialService, localPlayer)

		if v13 and v14 then
			SocialService:PromptGameInvite(localPlayer)
			RecommendationSignals.NotifyShared()
		end
	end))
	local v13 = TouchTapTracker.new()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function handleVideoScreenTap(p4)
		local videoScreenTapScale = getVideoScreenTapScale(v11, Vector2.new(p4.Position.X, p4.Position.Y))

		if videoScreenTapScale == nil then
			return
		end

		v11.FriendLikesController:HandleScreenTap()
		v11.LikeController:HandleScreenTap(videoScreenTapScale)
	end

	maid:Connect(UserInputService.InputBegan, function(p4, flag: boolean)
		if flag then
			return
		end

		if p4.UserInputType == Enum.UserInputType.Touch then
			v13:Begin(p4)
		elseif p4.UserInputType == Enum.UserInputType.MouseButton1 and not UserInputService.TouchEnabled then
			handleVideoScreenTap(p4) -- equivalent call inferred; original call site unknown
		end
	end)
	maid:Connect(UserInputService.InputChanged, function(p4)
		if p4.UserInputType == Enum.UserInputType.Touch and v13:IsTrackingInput(p4) then
			v13:Update(p4)
		end
	end)
	maid:Connect(UserInputService.InputEnded, function(p4, flag: boolean)
		if p4.UserInputType == Enum.UserInputType.Touch and v13:IsTrackingInput(p4) and v13:Evaluate(p4, flag) then
			handleVideoScreenTap(p4) -- equivalent call inferred; original call site unknown
		end
	end)
	maid:Add(function()
		v13:Reset()
	end)
	maid:BindToRenderStep("TreadmillVideoProgress", Enum.RenderPriority.Last.Value, function()
		if count == v11.Token then
			updateMediaProgress(v11)
		end
	end)
	maid:Add(function()
		unloadVideo(v11)
		v11.LikeController:Destroy()
		v11.FriendLikesController:Destroy()
		stopPlay.Visible = true
		surfaceGui.Enabled = false
		surfaceGui2.Enabled = false
		surfaceGui3.Enabled = false
		surfaceGui4.Enabled = false
		surfaceGui5.Enabled = false
	end)

	if readyItem == nil then
		local current, v14 = FeedSequencer.Current(v11.Feed)
		local v15 = clone[current]
		local v16

		if v15 == nil then
			v16 = false
		else
			v16 = TreadmillMediaOverlay.IsExcluded(TreadmillMediaIdentity.GetMediaKey(v15))
		end

		if v16 then
			Remotes.Treadmill.RefreshClipCursor:FireServer(v14)
			current, v14 = sequencerNextSkippingExcluded(v11)
		end

		loadVideo(v11, current, v14, 1)
	else
		loadVideo(v11, readyItem.MediaIndex, nil, 1, readyItem)
	end

	local v14 = v11.RecommendationActive and "recommendation" or "sequencer"
	v:AtTrace():Log((`[TreadmillVideoController] Started treadmill video for {p} ({v14} feed)`))
end

local function findActiveTreadmill(p: string)
	for _, v6 in CollectionService:GetTagged("ActiveTreadmill") do
		if v6:GetAttribute("ActiveTreadmillId") == p then
			return v6
		end
	end

	return nil
end

local function bindVideoRuntimeWhenReady(p: string, p2, count2: number)
	local maid = Trove.new()
	v4 = maid
	local v6 = false

	local function bindIfCurrent(tool)
		if v6 or tool == nil or count2 ~= count or v4 ~= maid then
			return
		end

		assert(tool:IsA("Tool"), (`Runtime treadmill "{p}" must be a Tool`))
		v6 = true
		v4 = nil
		maid:Destroy()
		bindVideoRuntime(tool, p, p2, count2)
	end

	maid:Add(CollectionService:GetInstanceAddedSignal("ActiveTreadmill"):Connect(function(instance)
		if instance:GetAttribute("ActiveTreadmillId") == p then
			bindIfCurrent(instance)
		end
	end))
	bindIfCurrent(findActiveTreadmill(p))
end

function TreadmillVideoController.Start(p: string, p2)
	cleanupRuntime()
	count += 1
	bindVideoRuntimeWhenReady(p, p2, count)
end

function TreadmillVideoController.GetStoppedIconImage()
	return "rbxassetid://84371411600743"
end

function TreadmillVideoController.ResolveCoverImage(data)
	if data.Kind == "Video" then
		return data.CoverImage or ""
	end

	return data.Image
end

function TreadmillVideoController.GetCurrentMediaEntry(p)
	local releaseTrackingState = FeedSequencer.ResolveReleaseTrackingState(
		p,
		localPlayer.UserId,
		p.HasSwappedRight == true
	)
	local runtime = FeedSequencer.CreateRuntime(clone, releaseTrackingState, localPlayer.UserId)
	return clone[FeedSequencer.Current(runtime)]
end

local v6 = nil

function TreadmillVideoController.GetMediaEntryByKey(p: string)
	local v7 = v6

	if v7 ~= nil then
		return v7[p]
	end

	v7 = {}

	for _, v8 in ipairs(clone) do
		local mediaKey = TreadmillMediaIdentity.GetMediaKey(v8)

		if v7[mediaKey] == nil then
			v7[mediaKey] = v8
		end
	end

	v6 = v7
	return v7[p]
end

function TreadmillVideoController.GetActiveMediaEntry()
	local v7 = v5

	if v7 == nil then
		return nil
	end

	return clone[v7.VideoIndex]
end

function TreadmillVideoController.Stop()
	cleanupRuntime()
end

function TreadmillVideoController.SuppressScreenTap()
	local v7 = v5

	if v7 ~= nil then
		v7.LikeController:SuppressScreenTap()
	end
end

function TreadmillVideoController.SetShareButtonVisible(visible: boolean)
	shareButton.Visible = visible
end

TreadmillMediaOverlay.Changed:Connect(function()
	TreadmillMediaOverlay.ApplyTo(clone)
	v6 = nil
	updateVideoCounter()
end)
updateVideoCounter()

Remotes.Treadmill.GaugeClipLength.OnClientInvoke = function(p: number)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TreadmillDurationProbe"
	screenGui.ResetOnSpawn = false
	local videoFrame2 = Instance.new("VideoFrame")
	videoFrame2.Size = UDim2.fromOffset(1, 1)
	videoFrame2.BackgroundTransparency = 1
	videoFrame2.Volume = 0
	videoFrame2.Video = `rbxassetid://{p}`
	videoFrame2.Parent = screenGui
	screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
	local v7 = os.clock() + 20

	while os.clock() < v7 and not (videoFrame2.IsLoaded and videoFrame2.TimeLength > 0) do
		task.wait(0.25)
	end

	local timeLength = videoFrame2.TimeLength
	screenGui:Destroy()

	if timeLength <= 0 then
		return nil
	end

	return timeLength
end

CommentsController.Start({
	MediaChanged = TreadmillVideoController.MediaChanged,
	SetShareButtonVisible = TreadmillVideoController.SetShareButtonVisible,
	Stopped = TreadmillVideoController.Stopped,
	SuppressScreenTap = TreadmillVideoController.SuppressScreenTap
})
return TreadmillVideoController