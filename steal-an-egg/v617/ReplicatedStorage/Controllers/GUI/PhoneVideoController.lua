local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")
local TweenService = game:GetService("TweenService")
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local FeedSequencer = require(ReplicatedStorage.Shared.TreadmillVideoController.FeedSequencer)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local Log = require(ReplicatedStorage.Packages.Log)
local Media = require(ReplicatedStorage.Shared.TreadmillVideoController.Media)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Save = require(ReplicatedStorage.Shared.Save)
local TreadmillFlags = require(ReplicatedStorage.Shared.Flags.TreadmillFlags)
local TreadmillMediaIdentity = require(ReplicatedStorage.Shared.Modules.TreadmillMediaIdentity)
local Schema = require(ReplicatedStorage.Shared.Types.TreadmillMediaLike.Types.Schema)
local TreadmillMediaOverlay = require(ReplicatedStorage.Shared.Modules.TreadmillMediaOverlay)
require(ReplicatedStorage.Shared.TreadmillVideoController.Types.Interface)
local Trove = require(ReplicatedStorage.Packages.Trove)
local TryCall = require(ReplicatedStorage.Shared.Utils.TryCall)
local VideoComments = require(ReplicatedStorage.Client.VideoComments)
local color = Color3.fromRGB(255, 92, 122)
local tweenInfo = TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo4 = TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1)
local tweenInfo5 = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo6 = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
return {
	Start = function()
		local localPlayer = Players.LocalPlayer
		local v = Log.new()
		local v2 = nil
		local v3 = nil
		local v4 = nil
		local flag = false
		local v5 = nil
		local Main = require(script.Parent.BackpackController.Main)
		local v6 = nil
		local v7 = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function dismissEquipHint()
			local v8 = v6
			v6 = nil

			if v8 ~= nil then
				v8:Destroy()
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function warnMissingUi(formatted: string)
			if flag then
				return
			end

			flag = true
			warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
		end

		local function findTyped(instance, childName: string, className: string, flag2: boolean?)
			local child = instance:FindFirstChild(childName, flag2 == true)

			if child ~= nil and child:IsA(className) then
				return child
			end

			warnMissingUi(`{instance:GetFullName()}.{childName} ({className})`) -- equivalent call inferred; original call site unknown
			return nil
		end

		local function resolvePhoneUi()
			local v8 = v2

			if v8 ~= nil and v8.Gui.Parent ~= nil then
				return v8
			end

			v2 = nil
			local playerGui = localPlayer:FindFirstChildOfClass("PlayerGui")
			local phoneVideoUI = playerGui and playerGui:FindFirstChild("PhoneVideoUI")

			if phoneVideoUI == nil or not phoneVideoUI:IsA("ScreenGui") then
				if not flag then
					flag = true
					warn("[PhoneVideoController] PlayerGui.PhoneVideoUI is missing. The PhoneVideoUI ScreenGui is incomplete.")
				end

				return nil
			else
				local phone = phoneVideoUI:FindFirstChild("Phone", false)

				if phone == nil or not phone:IsA("Frame") then
					local formatted = `{phoneVideoUI:GetFullName()}.Phone (Frame)`

					if not flag then
						flag = true
						warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
					end

					phone = nil
				end

				if phone == nil then
					return nil
				end

				local mainVideo = phone:FindFirstChild("MainVideo", true)

				if mainVideo == nil or not mainVideo:IsA("VideoFrame") then
					local formatted = `{phone:GetFullName()}.MainVideo (VideoFrame)`

					if not flag then
						flag = true
						warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
					end

					mainVideo = nil
				end

				local bar = phone:FindFirstChild("Bar", false)

				if bar == nil or not bar:IsA("Frame") then
					local formatted = `{phone:GetFullName()}.Bar (Frame)`

					if not flag then
						flag = true
						warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
					end

					bar = nil
				end

				local progress

				if bar then
					progress = bar:FindFirstChild("Progress", false)

					if progress == nil or not progress:IsA("GuiObject") then
						local formatted = `{bar:GetFullName()}.Progress (GuiObject)`

						if not flag then
							flag = true
							warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
						end

						progress = nil
					end
				else
					progress = bar
				end

				local loading = phone:FindFirstChild("Loading", false)

				if loading == nil or not loading:IsA("GuiObject") then
					local formatted = `{phone:GetFullName()}.Loading (GuiObject)`

					if not flag then
						flag = true
						warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
					end

					loading = nil
				end

				local spin

				if loading then
					spin = loading:FindFirstChild("Spin", false)

					if spin == nil or not spin:IsA("GuiObject") then
						local formatted = `{loading:GetFullName()}.Spin (GuiObject)`

						if not flag then
							flag = true
							warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
						end

						spin = nil
					end
				else
					spin = loading
				end

				local goToNext = phone:FindFirstChild("GoToNext", false)

				if goToNext == nil or not goToNext:IsA("CanvasGroup") then
					local formatted = `{phone:GetFullName()}.GoToNext (CanvasGroup)`

					if not flag then
						flag = true
						warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
					end

					goToNext = nil
				end

				local arrow

				if goToNext then
					arrow = goToNext:FindFirstChild("Arrow", false)

					if arrow == nil or not arrow:IsA("ImageLabel") then
						local formatted = `{goToNext:GetFullName()}.Arrow (ImageLabel)`

						if not flag then
							flag = true
							warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
						end

						arrow = nil
					end
				else
					arrow = goToNext
				end

				local arrowShadow

				if goToNext then
					arrowShadow = goToNext:FindFirstChild("ArrowShadow", false)

					if arrowShadow == nil or not arrowShadow:IsA("ImageLabel") then
						local formatted = `{goToNext:GetFullName()}.ArrowShadow (ImageLabel)`

						if not flag then
							flag = true
							warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
						end

						arrowShadow = nil
					end
				else
					arrowShadow = goToNext
				end

				local paused = phone:FindFirstChild("Paused", false)

				if paused == nil or not paused:IsA("CanvasGroup") then
					local formatted = `{phone:GetFullName()}.Paused (CanvasGroup)`

					if not flag then
						flag = true
						warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
					end

					paused = nil
				end

				local tapCatcher = phone:FindFirstChild("TapCatcher", false)

				if tapCatcher == nil or not tapCatcher:IsA("GuiButton") then
					local formatted = `{phone:GetFullName()}.TapCatcher (GuiButton)`

					if not flag then
						flag = true
						warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
					end

					tapCatcher = nil
				end

				local close = phone:FindFirstChild("Close", false)

				if close == nil or not close:IsA("GuiButton") then
					local formatted = `{phone:GetFullName()}.Close (GuiButton)`

					if not flag then
						flag = true
						warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
					end

					close = nil
				end

				local buttonSwapLeft = phone:FindFirstChild("ButtonSwapLeft", true)

				if buttonSwapLeft == nil or not buttonSwapLeft:IsA("GuiButton") then
					local formatted = `{phone:GetFullName()}.ButtonSwapLeft (GuiButton)`

					if not flag then
						flag = true
						warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
					end

					buttonSwapLeft = nil
				end

				local buttonSwapRight = phone:FindFirstChild("ButtonSwapRight", true)

				if buttonSwapRight == nil or not buttonSwapRight:IsA("GuiButton") then
					local formatted = `{phone:GetFullName()}.ButtonSwapRight (GuiButton)`

					if not flag then
						flag = true
						warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
					end

					buttonSwapRight = nil
				end

				local share = phone:FindFirstChild("Share", false)

				if share == nil or not share:IsA("GuiObject") then
					local formatted = `{phone:GetFullName()}.Share (GuiObject)`

					if not flag then
						flag = true
						warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
					end

					share = nil
				end

				local shareButton

				if share then
					shareButton = share:FindFirstChild("ShareButton", true)

					if shareButton == nil or not shareButton:IsA("GuiButton") then
						local formatted = `{share:GetFullName()}.ShareButton (GuiButton)`

						if not flag then
							flag = true
							warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
						end

						shareButton = nil
					end
				else
					shareButton = share
				end

				local sideButtons = phone:FindFirstChild("SideButtons", false)

				if sideButtons == nil or not sideButtons:IsA("GuiObject") then
					local formatted = `{phone:GetFullName()}.SideButtons (GuiObject)`

					if not flag then
						flag = true
						warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
					end

					sideButtons = nil
				end

				local likeButton

				if sideButtons then
					likeButton = sideButtons:FindFirstChild("LikeButton", true)

					if likeButton == nil or not likeButton:IsA("ImageButton") then
						local formatted = `{sideButtons:GetFullName()}.LikeButton (ImageButton)`

						if not flag then
							flag = true
							warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
						end

						likeButton = nil
					end
				else
					likeButton = sideButtons
				end

				local likeCount

				if likeButton then
					likeCount = likeButton:FindFirstChild("LikeCount", false)

					if likeCount == nil or not likeCount:IsA("TextLabel") then
						local formatted = `{likeButton:GetFullName()}.LikeCount (TextLabel)`

						if not flag then
							flag = true
							warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
						end

						likeCount = nil
					end
				else
					likeCount = likeButton
				end

				local commentsButton

				if sideButtons then
					commentsButton = sideButtons:FindFirstChild("CommentsButton", true)

					if commentsButton == nil or not commentsButton:IsA("GuiButton") then
						local formatted = `{sideButtons:GetFullName()}.CommentsButton (GuiButton)`

						if not flag then
							flag = true
							warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
						end

						commentsButton = nil
					end
				else
					commentsButton = sideButtons
				end

				local commentsCount

				if commentsButton then
					commentsCount = commentsButton:FindFirstChild("CommentsCount", false)

					if commentsCount == nil or not commentsCount:IsA("TextLabel") then
						local formatted = `{commentsButton:GetFullName()}.CommentsCount (TextLabel)`

						if not flag then
							flag = true
							warn((`[PhoneVideoController] {formatted} is missing. The PhoneVideoUI ScreenGui is incomplete.`))
						end

						commentsCount = nil
					end
				else
					commentsCount = commentsButton
				end

				if mainVideo == nil or progress == nil or loading == nil or spin == nil or goToNext == nil or arrow == nil or arrowShadow == nil or paused == nil or tapCatcher == nil or close == nil or buttonSwapLeft == nil or buttonSwapRight == nil or share == nil or shareButton == nil or sideButtons == nil or likeButton == nil or likeCount == nil or commentsButton == nil or commentsCount == nil then
					return nil
				end

				local enjoyFree = paused:FindFirstChild("EnjoyFree", true)
				local videoCounter = phone:FindFirstChild("VideoCounter")

				for _, folder in { phone } do
					for _, guiObject in folder:GetDescendants() do
						if guiObject.Name == "GamepadGlyph" and guiObject:IsA("GuiObject") then
							guiObject.Visible = false
						end
					end
				end

				if enjoyFree == nil or not enjoyFree:IsA("TextLabel") then
					enjoyFree = nil
				end

				if videoCounter == nil or not videoCounter:IsA("TextLabel") then
					videoCounter = nil
				end

				local comments = phone:FindFirstChild("Comments")

				if comments == nil or not comments:IsA("GuiObject") then
					comments = nil
				end

				local v9 = {
					Gui = phoneVideoUI,
					Phone = phone,
					Video = mainVideo,
					Progress = progress,
					Loading = loading,
					LoadingSpin = spin,
					GoToNext = goToNext,
					Arrow = arrow,
					ArrowShadow = arrowShadow,
					Paused = paused,
					EnjoyFreeLabel = enjoyFree,
					VideoCounter = videoCounter,
					TapCatcher = tapCatcher,
					Close = close,
					SwapLeftButton = buttonSwapLeft,
					SwapRightButton = buttonSwapRight,
					ShareContainer = share,
					ShareButton = shareButton,
					SideButtonsContainer = sideButtons,
					LikeButton = likeButton,
					LikeCountLabel = likeCount,
					CommentsButton = commentsButton,
					CommentsCountLabel = commentsCount,
					CommentsPanel = comments,
					ArrowBasePosition = arrow.Position,
					ArrowShadowBasePosition = arrowShadow.Position,
					VideoBaseSize = mainVideo.Size,
					OnscreenPosition = phone.Position,
					OffscreenPosition = UDim2.new(phone.Position.X.Scale, 0, 2, 0)
				}
				v2 = v9
				return v9
			end
		end

		local clone = table.clone(Media)
		TreadmillMediaOverlay.ApplyTo(clone)

		local function isSkippedMediaIndex(p: number)
			local v8 = clone[p]

			if v8 == nil or v8.Kind ~= "Video" or v8.Disabled == true then
				return true
			end

			return TreadmillMediaOverlay.IsExcluded(TreadmillMediaIdentity.GetMediaKey(v8))
		end

		local function countPlayableVideos()
			local count = 0

			for k in clone do
				local v8 = clone[k]

				if v8 == nil or v8.Kind ~= "Video" or v8.Disabled == true or TreadmillMediaOverlay.IsExcluded(TreadmillMediaIdentity.GetMediaKey(v8)) then
					continue
				end

				count += 1
			end

			return count
		end

		local function sequencerNextSkippingUnplayable(p)
			local next, v8 = FeedSequencer.Next(p.Feed)

			for _ = 1, #clone do
				local v9 = clone[next]

				if v9 ~= nil and v9.Kind == "Video" and v9.Disabled ~= true and not TreadmillMediaOverlay.IsExcluded(TreadmillMediaIdentity.GetMediaKey(v9)) then
					break
				end

				Remotes.Treadmill.RefreshClipCursor:FireServer(v8)
				next, v8 = FeedSequencer.Next(p.Feed)
			end

			return next, v8
		end

		local function sequencerPreviousSkippingUnplayable(p)
			local previous, v8, v9 = FeedSequencer.Previous(p.Feed)

			if not v9 then
				return previous, v8, false
			end

			for _ = 1, #clone do
				local v10 = clone[previous]

				if v10 ~= nil and v10.Kind == "Video" and v10.Disabled ~= true and not TreadmillMediaOverlay.IsExcluded(TreadmillMediaIdentity.GetMediaKey(v10)) then
					return previous, v8, true
				end

				Remotes.Treadmill.RefreshClipCursor:FireServer(v8)
				local v11
				previous, v8, v11 = FeedSequencer.Previous(p.Feed)

				if v11 then
					continue
				end

				local v12, v13 = sequencerNextSkippingUnplayable(p)
				return v12, v13, true
			end

			return previous, v8, true
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function currentMediaKey(p)
			return TreadmillMediaIdentity.GetMediaKey(clone[p.Index])
		end

		local function formatCompactCount(p: number)
			return Simple.FormatCompact(math.max(p, 0), ".#")
		end

		local function updateSocialPresentation(data, p)
			local v8 = currentMediaKey(p) -- equivalent call inferred; original call site unknown
			local v9 = p.LikedByMediaKey[v8] == true
			local likeButton = data.LikeButton
			local imageColor

			if v9 then
				imageColor = color
			else
				imageColor = Color3.new(1, 1, 1)
			end

			likeButton.ImageColor3 = imageColor
			data.LikeButton.Image = v9 and "rbxassetid://90146064998908" or "rbxassetid://123761405635833"
			local likeCountLabel = data.LikeCountLabel
			local v11 = p.LikeCountsByMediaKey[v8] or 0
			likeCountLabel.Text = Simple.FormatCompact(math.max(v11, 0), ".#")
			data.CommentsButton.Visible = not TreadmillFlags.CommentsDisabled:Get()
			local commentsCountLabel = data.CommentsCountLabel
			local v12 = VideoComments.GetCachedCommentCount(v8) or 0
			commentsCountLabel.Text = Simple.FormatCompact(math.max(v12, 0), ".#")
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function requestLikeSnapshot(phoneUi, p)
			task.spawn(function()
				local v8, v9 = TryCall(function()
					return Remotes.Treadmill.AskFavourSnapshot:InvokeServer()
				end)

				if not (v8 and Schema.LikeSnapshot(v9)) then
					v:AtWarning():Log("[PhoneVideoController] Could not load the media like snapshot")
					return
				end

				if v3 ~= p then
					return
				end

				p.LikeCountsByMediaKey = table.clone(v9.CountsByMediaLikeKey)
				p.LikedByMediaKey = table.clone(v9.LikedTreadmillMedia)
				updateSocialPresentation(phoneUi, p)
			end)
		end

		local function toggleLike(phoneUi, state)
			if state.LikeBusy then
				return
			end

			state.LikeBusy = true
			local v8 = currentMediaKey(state) -- equivalent call inferred; original call site unknown
			local v9 = state.LikedByMediaKey[v8] == true
			local v10 = state.LikeCountsByMediaKey[v8] or 0
			local v11 = not v9
			state.LikedByMediaKey[v8] = v11
			state.LikeCountsByMediaKey[v8] = math.max(v10 + (v11 and 1 or -1), 0)
			updateSocialPresentation(phoneUi, state)
			task.spawn(function()
				local v12, v13 = TryCall(function()
					return Remotes.Treadmill.AskClipFavour:InvokeServer(v8, v11)
				end)

				if v3 ~= state then
					return
				end

				state.LikeBusy = false

				if v12 and Schema.LikeToggleResult(v13) and v13.Ok == true then
					state.LikedByMediaKey[v8] = v13.Liked == true

					if type(v13.Count) == "number" then
						state.LikeCountsByMediaKey[v8] = v13.Count
					end

					updateSocialPresentation(phoneUi, state)
				else
					state.LikedByMediaKey[v8] = v9
					state.LikeCountsByMediaKey[v8] = v10
					updateSocialPresentation(phoneUi, state)
					v:AtWarning():Log("[PhoneVideoController] Media like update was rejected")
				end
			end)
		end

		local function fadeInCard(maid, p, tweenInfo7)
			p.GroupTransparency = 1
			p.Visible = true
			local tween = TweenService:Create(p, tweenInfo7, {
				GroupTransparency = 0
			})
			maid:Add(function()
				tween:Cancel()
			end)
			tween:Play()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function hidePausedCard(p, state)
			local pausedCardTrove = state.PausedCardTrove
			state.PausedCardTrove = nil

			if pausedCardTrove ~= nil then
				pausedCardTrove:Destroy()
			end

			p.Paused.Visible = false
			local previewBaseSize = state.PreviewBaseSize
			state.PreviewBaseSize = nil

			if previewBaseSize ~= nil then
				p.Video.Size = previewBaseSize
			end
		end

		local function showPausedCard(data, state)
			if state.PausedCardTrove ~= nil or state.EndCardTrove ~= nil then
				return
			end

			local pausedCardTrove = Trove.new()
			state.PausedCardTrove = pausedCardTrove
			local enjoyFreeLabel = data.EnjoyFreeLabel

			if enjoyFreeLabel ~= nil then
				enjoyFreeLabel.Visible = not state.HasPlayed
			end

			fadeInCard(pausedCardTrove, data.Paused, tweenInfo3)

			if data.Video.TimePosition <= 0 and not data.Video.Playing then
				pcall(function()
					data.Video:Play()
					data.Video:Pause()
					data.Video.TimePosition = 0
				end)
			end

			local previewBaseSize = state.PreviewBaseSize

			if previewBaseSize ~= nil then
				state.PreviewBaseSize = nil
				data.Video.Size = previewBaseSize
			end

			local size = data.Video.Size
			local v9 = math.max(
				not (size.X.Scale > 0) and 1 or 1 / size.X.Scale,
				not (size.Y.Scale > 0) and 1 or 1 / size.Y.Scale
			)

			if v9 > 1 then
				state.PreviewBaseSize = size
				data.Video.Size = UDim2.new(
					size.X.Scale * v9,
					size.X.Offset * v9,
					size.Y.Scale * v9,
					size.Y.Offset * v9
				)
			end
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function hideEndCard(p, p2)
			local endCardTrove = p2.EndCardTrove
			p2.EndCardTrove = nil

			if endCardTrove ~= nil then
				endCardTrove:Destroy()
			end

			p.GoToNext.Visible = false
		end

		local function spawnArrowPulse(data, maid)
			local clone2 = data.Arrow:Clone()
			clone2.Name = "ArrowPulse"
			clone2.ZIndex = math.max(data.Arrow.ZIndex - 1, 0)
			clone2.ImageTransparency = 0.35
			clone2.Parent = data.GoToNext
			maid:Add(clone2)
			local tween = TweenService:Create(clone2, tweenInfo, {
				Size = UDim2.new(data.Arrow.Size.X.Scale * 2.2, 0, data.Arrow.Size.Y.Scale * 2.2, 0),
				ImageTransparency = 1
			})
			tween.Completed:Once(function()
				clone2:Destroy()
			end)
			tween:Play()
		end

		local function showEndCard(phoneUi, state)
			if state.EndCardTrove ~= nil then
				return
			end

			hidePausedCard(phoneUi, state) -- equivalent call inferred; original call site unknown
			local maid = Trove.new()
			state.EndCardTrove = maid
			phoneUi.ShareContainer.Visible = false
			phoneUi.SideButtonsContainer.Visible = false
			fadeInCard(maid, phoneUi.GoToNext, tweenInfo2)
			local swaySeconds = phoneUi.GoToNext:GetAttribute("SwaySeconds") or 1.2
			local swayScale = phoneUi.GoToNext:GetAttribute("SwayScale") or 0.02
			local lastTime = os.clock()
			local v8 = 0
			maid:Connect(RunService.RenderStepped, function()
				local v9 = os.clock() - lastTime
				local v10 = math.sin(v9 * 3.141592653589793 * 2 / swaySeconds) * swayScale
				local uDim = UDim2.fromScale(v10, 0)
				phoneUi.Arrow.Position = phoneUi.ArrowBasePosition + uDim
				phoneUi.ArrowShadow.Position = phoneUi.ArrowShadowBasePosition + uDim
				local v11 = math.floor(v9 / swaySeconds + 0.75)

				if v8 < v11 then
					v8 = v11
					spawnArrowPulse(phoneUi, maid)
				end
			end)
			maid:Add(function()
				phoneUi.Arrow.Position = phoneUi.ArrowBasePosition
				phoneUi.ArrowShadow.Position = phoneUi.ArrowShadowBasePosition
			end)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function playVideo(p, state)
			state.HasPlayed = true
			hidePausedCard(p, state) -- equivalent call inferred; original call site unknown
			p.Video:Play()
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function pauseVideo(p, p2)
			p.Video:Pause()
			showPausedCard(p, p2)
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function stopLoading(p, p2)
			local loadingTween = p2.LoadingTween
			p2.LoadingTween = nil

			if loadingTween ~= nil then
				loadingTween:Cancel()
			end

			p.Loading.Visible = false
			p.LoadingSpin.Rotation = 0
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function finishLoad(p, p2)
			stopLoading(p, p2) -- equivalent call inferred; original call site unknown
			p.ShareContainer.Visible = true
			p.SideButtonsContainer.Visible = true
			updateSocialPresentation(p, p2)

			if not p2.HasPlayed then
				showPausedCard(p, p2)
				return
			end

			playVideo(p, p2) -- equivalent call inferred; original call site unknown
		end

		local function loadVideo(phoneUi, state, p: number, p2)
			local v8 = clone[p]

			if v8 == nil or v8.Kind ~= "Video" then
				v:AtWarning():Log((`[PhoneVideoController] Media index {p} is not a playable video`))
				return
			end

			state.LoadToken += 1
			local loadToken = state.LoadToken
			hideEndCard(phoneUi, state) -- equivalent call inferred; original call site unknown
			hidePausedCard(phoneUi, state) -- equivalent call inferred; original call site unknown
			local commentsPanel = phoneUi.CommentsPanel

			if commentsPanel ~= nil then
				commentsPanel.Visible = false
			end

			state.Index = p
			Remotes.Treadmill.RefreshClipCursor:FireServer(p2)
			v5 = p2
			phoneUi.Video:Pause()
			phoneUi.Video.Size = v8.Size or phoneUi.VideoBaseSize
			phoneUi.Video.Volume = v8.Volume or 1
			phoneUi.Video.Video = v8.Video
			phoneUi.Video.TimePosition = 0
			local size = phoneUi.Progress.Size
			phoneUi.Progress.Size = UDim2.new(0, 0, size.Y.Scale, size.Y.Offset)

			if phoneUi.Video.IsLoaded then
				finishLoad(phoneUi, state) -- equivalent call inferred; original call site unknown
			else
				phoneUi.ShareContainer.Visible = false
				phoneUi.SideButtonsContainer.Visible = false
				stopLoading(phoneUi, state) -- equivalent call inferred; original call site unknown
				phoneUi.Loading.Visible = true
				local tween = TweenService:Create(phoneUi.LoadingSpin, tweenInfo4, {
					Rotation = 360
				})
				state.LoadingTween = tween
				tween:Play()
				local loadedConnection = nil
				loadedConnection = phoneUi.Video.Loaded:Connect(function()
					loadedConnection:Disconnect()

					if v3 ~= state or state.LoadToken ~= loadToken then
						return
					end

					finishLoad(phoneUi, state) -- equivalent call inferred; original call site unknown
				end)
				state.Trove:Add(loadedConnection)
			end
		end

		local function closePhone()
			local v8 = v3
			v3 = nil

			if v8 == nil then
				return
			end

			local phoneUi = resolvePhoneUi()
			v8.Trove:Destroy()

			if phoneUi == nil then
				return
			end

			phoneUi.Video:Pause()

			if v4 ~= nil then
				v4:Cancel()
			end

			local tween = TweenService:Create(phoneUi.Phone, tweenInfo6, {
				Position = phoneUi.OffscreenPosition
			})
			v4 = tween
			tween.Completed:Once(function()
				if v3 == nil then
					phoneUi.Gui.Enabled = false
				end
			end)
			tween:Play()
		end

		local function openPhone()
			v7 = true
			dismissEquipHint() -- equivalent call inferred; original call site unknown

			if v3 ~= nil then
				return
			end

			local phoneUi = resolvePhoneUi()

			if phoneUi == nil then
				return
			end

			local v8 = Save.Await()

			if v8 == nil then
				v:AtWarning():Log("[PhoneVideoController] Save data is not loaded yet")
				return
			end

			local count = 0

			for k in clone do
				local v9 = clone[k]

				if v9 == nil or v9.Kind ~= "Video" or v9.Disabled == true or TreadmillMediaOverlay.IsExcluded(TreadmillMediaIdentity.GetMediaKey(v9)) then
					continue
				end

				count += 1
			end

			if count == 0 then
				v:AtWarning():Log("[PhoneVideoController] No treadmill videos are available")
				return
			end

			local v9 = {
				Trove = Trove.new(),
				EndCardTrove = nil,
				PausedCardTrove = nil,
				LoadingTween = nil,
				Feed = FeedSequencer.CreateRuntime(clone, v5 or v8.TreadmillMediaFeedState, localPlayer.UserId),
				HasPlayed = false,
				Index = 1,
				LoadToken = 0,
				PreviewBaseSize = nil,
				LikedByMediaKey = {},
				LikeCountsByMediaKey = {},
				LikeBusy = false
			}
			v3 = v9
			v9.Trove:Add(function()
				hideEndCard(phoneUi, v9) -- equivalent call inferred; original call site unknown
				hidePausedCard(phoneUi, v9) -- equivalent call inferred; original call site unknown
				stopLoading(phoneUi, v9) -- equivalent call inferred; original call site unknown
			end)

			-- equivalent calls inferred from this helper; original call sites unknown
			local function goToNextVideo()
				local v10, v11 = sequencerNextSkippingUnplayable(v9)
				loadVideo(phoneUi, v9, v10, v11)
			end

			local videoCounter = phoneUi.VideoCounter

			if videoCounter ~= nil then
				local count2 = 0

				for k in clone do
					local v11 = clone[k]

					if v11 == nil or v11.Kind ~= "Video" or v11.Disabled == true or TreadmillMediaOverlay.IsExcluded(TreadmillMediaIdentity.GetMediaKey(v11)) then
						continue
					end

					count2 += 1
				end

				videoCounter.Text = `Total Videos: {count2}`
			end

			v9.Trove:Add(ButtonFX(phoneUi.Close, nil, function()
				local character = localPlayer.Character
				local humanoid

				if character ~= nil then
					humanoid = character:FindFirstChildOfClass("Humanoid")
				end

				if humanoid == nil then
					closePhone()
				else
					humanoid:UnequipTools()
				end
			end))
			v9.Trove:Add(ButtonFX(phoneUi.SwapLeftButton, nil, function()
				local v10, v11, v12 = sequencerPreviousSkippingUnplayable(v9)

				if v12 then
					loadVideo(phoneUi, v9, v10, v11)
				end
			end))
			v9.Trove:Add(ButtonFX(phoneUi.SwapRightButton, nil, goToNextVideo))
			v9.Trove:Add(ButtonFX(phoneUi.ShareButton, nil, function()
				local v10, v11 = TryCall(SocialService.CanSendGameInviteAsync, SocialService, localPlayer)

				if v10 and v11 then
					SocialService:PromptGameInvite(localPlayer)
				end
			end))
			v9.Trove:Add(ButtonFX(phoneUi.LikeButton, nil, function()
				toggleLike(phoneUi, v9)
			end))
			v9.Trove:Add(ButtonFX(phoneUi.CommentsButton, nil, function()
				local commentsPanel = phoneUi.CommentsPanel

				if commentsPanel ~= nil then
					commentsPanel.Visible = not commentsPanel.Visible
				end
			end))
			v9.Trove:Add(function()
				local commentsPanel = phoneUi.CommentsPanel

				if commentsPanel ~= nil then
					commentsPanel.Visible = false
				end
			end)
			requestLikeSnapshot(phoneUi, v9) -- equivalent call inferred; original call site unknown
			v9.Trove:Connect(phoneUi.TapCatcher.Activated, function()
				if v9.EndCardTrove == nil then
					if phoneUi.Video.Playing then
						pauseVideo(phoneUi, v9) -- equivalent call inferred; original call site unknown
					else
						playVideo(phoneUi, v9) -- equivalent call inferred; original call site unknown
					end
				else
					goToNextVideo() -- equivalent call inferred; original call site unknown
				end
			end)
			v9.Trove:Connect(phoneUi.Video.Ended, function()
				if v3 == v9 then
					showEndCard(phoneUi, v9)
				end
			end)
			v9.Trove:Connect(RunService.RenderStepped, function()
				local timeLength = phoneUi.Video.TimeLength

				if timeLength > 0 then
					local size = phoneUi.Progress.Size
					phoneUi.Progress.Size = UDim2.new(
						math.clamp(phoneUi.Video.TimePosition / timeLength, 0, 1),
						0,
						size.Y.Scale,
						size.Y.Offset
					)
				end
			end)
			phoneUi.Video.Looped = false

			if v4 ~= nil then
				v4:Cancel()
			end

			phoneUi.Phone.Position = phoneUi.OffscreenPosition
			phoneUi.Gui.Enabled = true
			local tween = TweenService:Create(phoneUi.Phone, tweenInfo5, {
				Position = phoneUi.OnscreenPosition
			})
			v4 = tween
			tween:Play()
			local current, v10 = FeedSequencer.Current(v9.Feed)
			local v11 = clone[current]

			if v11 == nil or v11.Kind ~= "Video" or v11.Disabled == true or TreadmillMediaOverlay.IsExcluded(TreadmillMediaIdentity.GetMediaKey(v11)) then
				Remotes.Treadmill.RefreshClipCursor:FireServer(v10)
				current, v10 = sequencerNextSkippingUnplayable(v9)
			end

			loadVideo(phoneUi, v9, current, v10)
		end

		local function isPhoneEnabled()
			return TreadmillFlags.PhoneEnabled:Get()
		end

		local function bindPhoneTool(tool)
			if not tool:IsA("Tool") then
				return
			end

			tool.Equipped:Connect(function()
				if TreadmillFlags.PhoneEnabled:Get() and tool.Parent == localPlayer.Character then
					openPhone()
				end
			end)
			tool.Unequipped:Connect(closePhone)

			if TreadmillFlags.PhoneEnabled:Get() and localPlayer.Character ~= nil and tool.Parent == localPlayer.Character then
				openPhone()
			end
		end

		CollectionService:GetInstanceAddedSignal("PhoneTool"):Connect(bindPhoneTool)

		for _, v8 in CollectionService:GetTagged("PhoneTool") do
			bindPhoneTool(v8)
		end

		localPlayer.CharacterRemoving:Connect(function()
			dismissEquipHint() -- equivalent call inferred; original call site unknown
			closePhone()
		end)

		local function buildEquipHintArrow(object)
			local frame = Instance.new("Frame")
			frame.Name = "PhoneEquipHint"
			frame.AnchorPoint = Vector2.new(0.5, 1)
			frame.BackgroundTransparency = 1
			frame.Size = UDim2.fromScale(0.7, 0.7)
			frame.Visible = false
			frame.ZIndex = 30
			object:Add(frame)
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Arrow"
			imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
			imageLabel.Position = UDim2.fromScale(0.5, 0.5)
			imageLabel.Size = UDim2.fromScale(1, 1)
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = "rbxassetid://107875622740177"
			imageLabel.ScaleType = Enum.ScaleType.Fit
			imageLabel.Rotation = 90
			imageLabel.ZIndex = 31
			imageLabel.Parent = frame
			local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
			uIAspectRatioConstraint.Parent = imageLabel
			return frame
		end

		local function showEquipHint()
			if not (v6 == nil and TreadmillFlags.PhoneEnabled:Get() and resolvePhoneUi() ~= nil) then
				return
			end

			local v8 = Trove.new()
			v6 = v8
			local equipHintArrow = buildEquipHintArrow(v8)
			v8:Connect(RunService.RenderStepped, function()
				local phoneSlotFrame = Main:GetPhoneSlotFrame()

				if phoneSlotFrame == nil then
					equipHintArrow.Visible = false
					return
				end

				if equipHintArrow.Parent ~= phoneSlotFrame then
					equipHintArrow.Parent = phoneSlotFrame
				end

				equipHintArrow.Visible = true
				local v9 = math.sin(os.clock() * 3.141592653589793 * 2 / 0.9) * 6
				equipHintArrow.Position = UDim2.new(0.5, 0, 0, v9 - 10)
			end)
		end

		TreadmillFlags.PhoneEnabled.Changed:Connect(function(flag2: boolean)
			if not flag2 then
				dismissEquipHint() -- equivalent call inferred; original call site unknown
				closePhone()
			end
		end)
		Remotes.Treadmill.AssignedBeltShifted.OnClientEvent:Connect(function(p: string?)
			if p == nil then
				dismissEquipHint() -- equivalent call inferred; original call site unknown
			else
				local v8 = Save.Await()

				if v7 or v8 == nil or v8.HasRiddenTreadmill ~= true or v8.HasEquippedPhone == true then
					return
				end

				showEquipHint()
			end
		end)
	end
}