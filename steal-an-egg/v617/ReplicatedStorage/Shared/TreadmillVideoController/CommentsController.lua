local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")
local TweenService = game:GetService("TweenService")
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local CommentRenderer = require(script.CommentRenderer)
local GUI = require(ReplicatedStorage.Client.GUI)
local Log = require(ReplicatedStorage.Packages.Log)
local Media = require(script.Parent.Media)
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local PhotoInputController = require(script.PhotoInputController)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local TreadmillFlags = require(ReplicatedStorage.Shared.Flags.TreadmillFlags)
local TreadmillMediaCommentsConfig = require(ReplicatedStorage.Shared.Modules.TreadmillMediaCommentsConfig)
local TreadmillMediaIdentity = require(ReplicatedStorage.Shared.Modules.TreadmillMediaIdentity)
require(ReplicatedStorage.Shared.TreadmillVideoController.Types.Interface)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(script.Types.Interface)
require(ReplicatedStorage.Client.VideoComments.Types.Interface)
local VideoComments = require(ReplicatedStorage.Client.VideoComments)
local TryCall = require(ReplicatedStorage.Shared.Utils.TryCall)
local color = Color3.fromRGB(232, 158, 158)
local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local uDim = UDim2.fromScale(0.98, 0.65)
local v = Log.new()
local v2 = {}
local surfaceGui = nil
local content = nil
local backgroundColor3 = nil
local v3 = false
local v4 = {}
local textInput = nil
local v5 = nil
local flag = false
local v6 = false
local v7 = false
local v8 = ""
local nextCursor = nil
local v9 = 1
local v10 = 0
local noComments = nil
local v11 = {}
local v12 = nil
local v13 = {}
local count = 0
local comment_01 = nil

local function fn(_: boolean) end

local commentsCount = nil
local commentsTemplate = nil
local v14 = 0
local v15 = nil

local function fn2() end

local CommentsController = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function trim(text: string)
	return text:match("^%s*(.-)%s*$") or ""
end

-- equivalent calls inferred from this helper; original call sites unknown
local function characterCount(text: string)
	local v16 = utf8.len(text)
	assert(v16 ~= nil, "Comment text must contain valid UTF-8")
	return v16
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showTooLongNotification()
	Toast.Show({
		Lane = "Banner",
		Text = "Your message is too long, please make it shorter!",
		Seconds = 3,
		Color = Color3.new(1, 1, 1),
		ShowShadow = true
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showAlreadyCommentedNotification()
	Toast.Show({
		Lane = "Banner",
		Text = "You already commented this video.",
		Seconds = 3,
		Color = Color3.new(1, 1, 1),
		ShowShadow = true
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showInvalidImageNotification()
	Toast.Show({
		Lane = "Banner",
		Text = "Invalid image, please upload another image.",
		Seconds = 3,
		Color = Color3.new(1, 1, 1),
		ShowShadow = true
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showImageLookupFailedNotification()
	Toast.Show({
		Lane = "Banner",
		Text = "Something went wrong, please try again later.",
		Seconds = 3,
		Color = Color3.new(1, 1, 1),
		ShowShadow = true
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showPostRateLimitNotification()
	Toast.Show({
		Lane = "Banner",
		Text = "You're doing this too fast, please wait a bit.",
		Seconds = 3,
		Color = Color3.new(1, 1, 1),
		ShowShadow = true
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showFilteredCommentNotification()
	Toast.Show({
		Lane = "Banner",
		Text = "Your comment was filtered, please try another message!",
		Seconds = 3,
		Color = Color3.new(1, 1, 1),
		ShowShadow = true
	})
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isRateLimitError(p: string?)
	return p == "You're doing that too fast!" or p == "You're on cooldown. Please try again later."
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatCommentsTitle(p: number)
	if p == 1 then
		return "1 comment"
	end

	return (`{Simple.FormatCompact(p, ".#")} comments`)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function projectCount(p: number)
	v14 = math.max(0, p)
	commentsCount.Text = Simple.FormatCompact(v14, ".#")
	local title = commentsTemplate.Sheet.Header.Content.SubContent.Title
	title.Text = formatCommentsTitle(v14)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function updateEmptyState()
	local visible

	if next(v13) == nil then
		visible = not v6
	else
		visible = false
	end

	content.Visible = not visible
	noComments.Visible = visible
end

local function clearRows()
	for k, v16 in v13 do
		v16.Destroy()
		v13[k] = nil
	end

	table.clear(v2)
	table.clear(v11)
	v9 = 1
	v10 = 0
	content.CanvasPosition = Vector2.zero
end

-- equivalent calls inferred from this helper; original call sites unknown
local function renderComment(comment, p: number)
	if v13[comment.Id] ~= nil then
		return
	end

	v2[comment.Id] = comment
	v13[comment.Id] = CommentRenderer.Create(comment_01, content, comment, p, CommentsController.ToggleLike)
end

local function requestPage()
	if not flag or v6 or not v3 or nextCursor == nil or v8 == "" then
		return
	end

	v6 = true
	updateEmptyState() -- equivalent call inferred; original call site unknown
	local v16 = nextCursor
	local v17 = count
	local v18 = v8
	task.spawn(function()
		local commentPage = VideoComments.RequestCommentPage(v18, v16, TreadmillMediaCommentsConfig.COMMENT_PAGE_SIZE)

		if not flag or v17 ~= count then
			return
		end

		v6 = false

		if commentPage.Ok then
			VideoComments.ReconcileCommentCount(v18, commentPage.TotalCreatedCount)

			for _, comment in commentPage.Comments do
				renderComment(comment, v9) -- equivalent call inferred; original call site unknown
				v9 += 1
			end

			nextCursor = commentPage.NextCursor
			v3 = commentPage.NextCursor ~= nil
			updateEmptyState() -- equivalent call inferred; original call site unknown
		else
			v3 = false
			nextCursor = nil
			updateEmptyState() -- equivalent call inferred; original call site unknown
			v:AtTrace():Log((`Unable to load treadmill comments: {commentPage.Error}`))
		end
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function requestInitialPage()
	count += 1
	nextCursor = 0
	v3 = true
	v6 = false
	requestPage()
end

local function updateInputLimitPresentation()
	local text = textInput.Text
	local v16 = utf8.len(text)
	assert(v16 ~= nil, "Comment text must contain valid UTF-8")
	local backgroundColor

	if TreadmillMediaCommentsConfig.MAX_COMMENT_CHARACTERS <= v16 then
		backgroundColor = color
	else
		backgroundColor = backgroundColor3
	end

	if v5 ~= nil then
		v5:Cancel()
	end

	local tween = TweenService:Create(textInput, tweenInfo, {
		BackgroundColor3 = backgroundColor
	})
	v5 = tween
	tween:Play()
end

local function postComment()
	if v7 or v8 == "" then
		return
	end

	if v4[v8] then
		showAlreadyCommentedNotification() -- equivalent call inferred; original call site unknown
		return
	end

	fn2()
	local text = textInput.Text
	local v16 = characterCount(text) -- equivalent call inferred; original call site unknown

	if TreadmillMediaCommentsConfig.MAX_COMMENT_CHARACTERS < v16 then
		showTooLongNotification() -- equivalent call inferred; original call site unknown
		return
	end

	local v17 = trim(text) -- equivalent call inferred; original call site unknown
	local imageAssetId = v12:GetImageAssetId()

	if v17 == "" and imageAssetId == nil then
		return
	end

	v7 = true
	local v18 = count
	local v19 = v8
	task.spawn(function()
		local v20 = VideoComments.PostComment(v19, v17, imageAssetId)

		if v18 ~= count then
			return
		end

		v7 = false

		if v20.Ok then
			v4[v19] = true
			textInput.Text = ""
			v12:Reset()
			v10 -= 1
			renderComment(v20.Comment, v10) -- equivalent call inferred; original call site unknown
			VideoComments.ReconcileCommentCount(v19, v14 + 1)
			updateEmptyState() -- equivalent call inferred; original call site unknown
			content.CanvasPosition = Vector2.zero
		else
			if v20.Error == "AlreadyCommented" then
				v4[v19] = true
				showAlreadyCommentedNotification() -- equivalent call inferred; original call site unknown
			elseif v20.Error == "MessageFiltered" then
				showFilteredCommentNotification() -- equivalent call inferred; original call site unknown
			elseif v20.Error == "InvalidImageAssetId" then
				showInvalidImageNotification() -- equivalent call inferred; original call site unknown
			elseif v20.Error == "ImageAssetLookupFailed" then
				showImageLookupFailedNotification() -- equivalent call inferred; original call site unknown
			elseif isRateLimitError(v20.Error) then
				showPostRateLimitNotification() -- equivalent call inferred; original call site unknown
			end

			v:AtTrace():Log((`Unable to post treadmill comment: {v20.Error}`))
		end
	end)
end

local function open()
	if flag or v8 == "" or TreadmillFlags.CommentsDisabled:Get() then
		return
	end

	fn2()
	flag = true
	commentsTemplate.Visible = true
	fn(false)
	clearRows()
	updateEmptyState() -- equivalent call inferred; original call site unknown
	requestInitialPage() -- equivalent call inferred; original call site unknown
end

local function handleScroll()
	if flag and v3 and content.AbsoluteCanvasSize.Y - content.CanvasPosition.Y - content.AbsoluteWindowSize.Y <= 64 then
		requestPage()
	end
end

local function handleMediaChanged(p, adornee)
	local mediaKey = TreadmillMediaIdentity.GetMediaKey(p)
	CommentsController.Close()
	surfaceGui.Adornee = adornee
	surfaceGui.Enabled = not TreadmillFlags.CommentsDisabled:Get()
	v8 = mediaKey
	projectCount(VideoComments.GetCachedCommentCount(mediaKey) or 0) -- equivalent call inferred; original call site unknown
end

function CommentsController.ToggleLike(p: string)
	if v11[p] then
		return
	end

	local v16 = v2[p]
	local v17 = v13[p]
	local v18

	if v16 == nil then
		v18 = false
	else
		v18 = v17 ~= nil
	end

	assert(v18, (`Missing rendered comment {p}`))
	fn2()
	v11[p] = true
	local likedByViewer = v16.LikedByViewer
	local likeCount = v16.LikeCount
	local likedByViewer2 = not likedByViewer
	v16.LikedByViewer = likedByViewer2
	v16.LikeCount = math.max(0, likeCount + (likedByViewer2 and 1 or -1))
	v17.UpdateLike(v16.LikedByViewer, v16.LikeCount)
	local v20 = count
	local v21 = v8
	task.spawn(function()
		local v22 = VideoComments.SetCommentLike(v21, p, likedByViewer2)

		if v20 ~= count then
			return
		end

		v11[p] = nil
		local v23 = v2[p]
		local v24 = v13[p]

		if v23 == nil or v24 == nil then
			return
		end

		if v22.Ok then
			v23.LikedByViewer = v22.Liked
			v23.LikeCount = math.max(0, v22.LikeCount)
		else
			v23.LikedByViewer = likedByViewer
			v23.LikeCount = likeCount
		end

		v24.UpdateLike(v23.LikedByViewer, v23.LikeCount)
	end)
end

function CommentsController.Close()
	count += 1
	flag = false
	v6 = false
	v7 = false
	v3 = false
	nextCursor = nil
	commentsTemplate.Visible = false
	fn(true)
	textInput.Text = ""
	v12:Reset()
	clearRows()
	updateEmptyState() -- equivalent call inferred; original call site unknown
end

function CommentsController.IsAvailable()
	return v15 ~= nil and not TreadmillFlags.CommentsDisabled:Get()
end

function CommentsController.Toggle()
	if v15 == nil then
		return
	end

	if flag then
		fn2()
		CommentsController.Close()
	elseif not flag and v8 ~= "" then
		if TreadmillFlags.CommentsDisabled:Get() then
			return
		end

		fn2()
		flag = true
		commentsTemplate.Visible = true
		fn(false)
		clearRows()
		updateEmptyState() -- equivalent call inferred; original call site unknown
		requestInitialPage() -- equivalent call inferred; original call site unknown
	end
end

function CommentsController.Deactivate()
	CommentsController.Close()
	v8 = ""
	surfaceGui.Enabled = false
	v14 = 0
	commentsCount.Text = Simple.FormatCompact(v14, ".#")
	local title = commentsTemplate.Sheet.Header.Content.SubContent.Title
	title.Text = formatCommentsTitle(v14)
end

function CommentsController.Start(data)
	assert(v15 == nil, "Treadmill comments controller must only start once")
	local commentsButton = GUI.TreadmillScreenSideButtons().Frame.Buttons.CommentsButton
	local surfaceGui2 = GUI.TreadmillScreenButtonShare()
	assert(surfaceGui2:IsA("SurfaceGui"), "Treadmill share GUI must be a SurfaceGui")
	local shareButton = surfaceGui2.Frame.ShareButton
	assert(commentsButton:IsA("GuiButton"), "Treadmill comments button must be a GuiButton")
	assert(shareButton:IsA("GuiButton"), "Treadmill share button must be a GuiButton")
	local v16, v17 = TryCall(TextChatService.CanUserChatAsync, TextChatService, Players.LocalPlayer.UserId)
	commentsButton.Visible = v16 and v17 == true

	if not commentsButton.Visible then
		shareButton.Position = uDim
		return
	end

	fn = data.SetShareButtonVisible
	fn2 = data.SuppressScreenTap
	surfaceGui = GUI.TreadmillScreenComments()
	commentsTemplate = surfaceGui.Frame.CommentsTemplate
	content = commentsTemplate.Sheet.Content
	comment_01 = content.Comment_01
	textInput = commentsTemplate.Sheet.Actions.Content.TextInputWrapper.TextInput
	assert(surfaceGui:IsA("SurfaceGui"), "Treadmill comments GUI must be a SurfaceGui")
	assert(content:IsA("ScrollingFrame"), "Treadmill comments content must be a ScrollingFrame")
	assert(comment_01:IsA("Frame"), "Treadmill comments row template must be a Frame")
	assert(commentsButton.CommentsCount:IsA("TextLabel"), "Treadmill comments count must be a TextLabel")
	backgroundColor3 = textInput.BackgroundColor3
	noComments = commentsTemplate.Sheet.NoComments
	v12 = PhotoInputController.new(commentsTemplate, fn2)
	commentsCount = commentsButton.CommentsCount
	v15 = Trove.new()

	for _, frame in content:GetChildren() do
		if not (frame:IsA("Frame") and frame.Name:match("^Comment_%d+$")) then
			continue
		end

		if frame.Name == "Comment_01" then
			frame.Visible = false
		else
			frame:Destroy()
		end
	end

	content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	surfaceGui.Enabled = false
	commentsTemplate.Visible = false
	commentsTemplate.Overlay.Active = true
	commentsTemplate.AddPhoto.Visible = false
	local maid = v15
	assert(maid ~= nil, "Treadmill comments trove must exist after startup")
	maid:Add(ButtonFX(commentsButton, nil, open))
	maid:Add(ButtonFX(commentsTemplate.Sheet.Header.Content.Close, nil, function()
		fn2()
		CommentsController.Close()
	end))
	maid:Connect(commentsTemplate.Overlay.InputBegan, function(p)
		if (p.UserInputType == Enum.UserInputType.MouseButton1 or p.UserInputType == Enum.UserInputType.Touch) and p.Position.Y < commentsTemplate.Sheet.AbsolutePosition.Y then
			fn2()
			CommentsController.Close()
		end
	end)
	maid:Add(ButtonFX(commentsTemplate.Sheet.Actions.Content.Send, nil, postComment))
	maid:Connect(textInput:GetPropertyChangedSignal("Text"), updateInputLimitPresentation)
	maid:Connect(content:GetPropertyChangedSignal("CanvasPosition"), handleScroll)
	maid:Add(data.MediaChanged:Connect(handleMediaChanged))
	maid:Add(data.Stopped:Connect(CommentsController.Deactivate))
	maid:Add(VideoComments.CommentCountChanged:Connect(function(p: string, p2: number)
		if p == v8 then
			projectCount(p2) -- equivalent call inferred; original call site unknown
		end
	end))
	local position = shareButton.Position

	local function applyCommentsDisabledFlag()
		local v18 = TreadmillFlags.CommentsDisabled:Get()
		commentsButton.Visible = not v18
		local shareButton2 = shareButton
		local position2

		if v18 then
			position2 = uDim
		else
			position2 = position
		end

		shareButton2.Position = position2

		if v18 then
			CommentsController.Close()
			surfaceGui.Enabled = false
		elseif v8 ~= "" then
			surfaceGui.Enabled = true
		end
	end

	maid:Add(TreadmillFlags.CommentsDisabled.Changed:Connect(applyCommentsDisabledFlag))
	local v18 = TreadmillFlags.CommentsDisabled:Get()
	commentsButton.Visible = not v18

	if v18 then
		position = uDim
	end

	shareButton.Position = position

	if v18 then
		CommentsController.Close()
		surfaceGui.Enabled = false
	elseif v8 ~= "" then
		surfaceGui.Enabled = true
	end

	local mediaKeys = TreadmillMediaIdentity.BuildMediaKeys(Media)
	VideoComments.StartCommentCountCache(mediaKeys)
	v14 = 0
	commentsCount.Text = Simple.FormatCompact(v14, ".#")
	local title = commentsTemplate.Sheet.Header.Content.SubContent.Title
	title.Text = formatCommentsTitle(v14)
	updateEmptyState() -- equivalent call inferred; original call site unknown
end

return CommentsController