local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local GUI = require(ReplicatedStorage.Client.GUI)
local Identity = require(ReplicatedStorage.Shared.Utils.Identity)
local displayName = Identity.DisplayName
local Identity2 = require(ReplicatedStorage.Shared.Utils.Identity)
local thumbnail = Identity2.Thumbnail
local Log = require(ReplicatedStorage.Packages.Log)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local TreadmillMediaIdentity = require(ReplicatedStorage.Shared.Modules.TreadmillMediaIdentity)
local Schema = require(ReplicatedStorage.Shared.Types.TreadmillMediaLike.Types.Schema)
require(ReplicatedStorage.Shared.Types.TreadmillMediaLike.Types.Interface)
local Trove = require(ReplicatedStorage.Packages.Trove)
local t = require(ReplicatedStorage.Packages.t)
require(script.Parent.Types.Interface)
local TryCall = require(ReplicatedStorage.Shared.Utils.TryCall)
local FriendLikesController = {}
FriendLikesController.__index = FriendLikesController
FriendLikesController.__class = "FriendLikesController"
local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
local tweenInfo3 = TweenInfo.new(2.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local vector = Vector2.new(0.13, 0.13)
local v = Log.new()
local surfaceGui = GUI.TreadmillScreenFriendLikes()
assert(surfaceGui:IsA("SurfaceGui"), "Treadmill friend-like GUI must be a SurfaceGui")
local frame = surfaceGui.Frame
local main = frame.Main
local template = main.Template
assert(template:IsA("Frame"), "Treadmill friend-like template must be a Frame")
assert(template.Button:IsA("ImageButton"), "Treadmill friend-like template button must be an ImageButton")
local profile = frame.Profile
assert(profile:IsA("Frame"), "Treadmill friend-like profile must be a Frame")
local position = profile.Position
local playerIcon = profile.Main.Icon.PlayerIcon
assert(playerIcon:IsA("ImageLabel"), "Treadmill friend-like profile icon must be an ImageLabel")
local textLabel = profile.Main.TextLabel
assert(textLabel:IsA("TextLabel"), "Treadmill friend-like profile label must be a TextLabel")

function FriendLikesController.new(getActiveVideoIndex, interactionCallback, mediaEntries, object, p)
	t.strict(t.callback)(getActiveVideoIndex)
	t.strict(t.callback)(interactionCallback)
	t.strict(t.table)(mediaEntries)
	t.strict(t.table)(object)
	t.strict(t.instanceIsA("BasePart"))(p)
	local self = setmetatable({}, FriendLikesController)
	self._destroyed = false
	self._friendLikeUserIdsByMediaLikeKey = {}
	self._getActiveVideoIndex = getActiveVideoIndex
	self._interactionCallback = interactionCallback
	self._mediaEntries = mediaEntries
	self._profile = profile
	self._profilePlayerIcon = playerIcon
	self._profileTextLabel = textLabel
	self._profileTween = nil
	self._profileVisiblePosition = position
	self._rowsContainer = main
	self._rowsTrove = Trove.new()
	self._rowTemplate = template
	self._screenTapSuppressUntil = 0
	self._snapshotRequestSerial = 0
	self._surfaceGui = surfaceGui
	self._trove = object:Extend()
	self:_init(p)
	return self
end

local function escapeRichText(value: string)
	return value:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub("\"", "&quot;"):gsub("'", "&apos;")
end

local function getRandomFloatPosition(object)
	return UDim2.fromScale(0.5 + object:NextNumber(-vector.X, vector.X), 0.5 + object:NextNumber(-vector.Y, vector.Y))
end

local function startButtonFloat(button, maid)
	local random = Random.new()
	local v2 = nil
	local v3 = false
	button.AnchorPoint = Vector2.new(0.5, 0.5)
	button.Position = UDim2.fromScale(0.5, 0.5)
	local playNext

	playNext = function()
		if v3 or button.Parent == nil then
			return
		end

		local v8 = random
		local v9 = TweenService:Create(button, tweenInfo3, {
			Position = UDim2.fromScale(
				0.5 + v8:NextNumber(-vector.X, vector.X),
				0.5 + v8:NextNumber(-vector.Y, vector.Y)
			)
		})
		v2 = v9
		v9.Completed:Once(function()
			if v2 ~= v9 then
				return
			end

			v2 = nil
			playNext()
		end)
		v9:Play()
	end

	maid:Add(function()
		v3 = true

		if v2 ~= nil then
			v2:Cancel()
			v2 = nil
		end
	end)
	playNext()
end

function FriendLikesController:_isAlive()
	return not self._destroyed
end

function FriendLikesController:_getMediaKey()
	local _getActiveVideoIndex = self._getActiveVideoIndex()
	local _mediaEntry = self._mediaEntries[_getActiveVideoIndex]
	assert(_mediaEntry ~= nil, (`Missing treadmill media entry for index {_getActiveVideoIndex}`))
	return TreadmillMediaIdentity.GetMediaKey(_mediaEntry)
end

function FriendLikesController:_getProfileHiddenPosition()
	local _profileVisiblePosition = self._profileVisiblePosition
	return UDim2.new(
		_profileVisiblePosition.X.Scale,
		_profileVisiblePosition.X.Offset,
		2,
		_profileVisiblePosition.Y.Offset
	)
end

function FriendLikesController:_cancelProfileTween()
	local _profileTween = self._profileTween
	self._profileTween = nil

	if _profileTween ~= nil then
		_profileTween:Cancel()
	end
end

function FriendLikesController:_hideProfileImmediate()
	self:_cancelProfileTween()
	self._profile.Visible = false
	self._profile.Position = self:_getProfileHiddenPosition()
end

function FriendLikesController:_clearRows()
	self._rowsTrove:Destroy()
	self._rowsTrove = Trove.new()
end

function FriendLikesController:_getRequestedMediaKeys()
	local _getActiveVideoIndex = self._getActiveVideoIndex()
	local v2 = {}
	local mediaKeys = {}

	for _, v3 in ipairs({ _getActiveVideoIndex, _getActiveVideoIndex + 1, _getActiveVideoIndex - 1 }) do
		local _mediaEntry = self._mediaEntries[v3]

		if _mediaEntry == nil then
			continue
		end

		local mediaKey = TreadmillMediaIdentity.GetMediaKey(_mediaEntry)

		if v2[mediaKey] then
			continue
		end

		v2[mediaKey] = true
		table.insert(mediaKeys, mediaKey)
	end

	return mediaKeys
end

function FriendLikesController:_requestFriendLikeSnapshot(p: number)
	local v2, v3 = TryCall(function()
		return Remotes.Treadmill.AskFriendFavourSnapshot:InvokeServer({
			MediaKeys = self:_getRequestedMediaKeys()
		})
	end)

	if not v2 then
		v:AtError():Log((`Failed to load treadmill friend-like snapshot: {v3}`))
		return
	end

	if not Schema.FriendLikeSnapshot(v3) then
		v:AtError():Log("Invalid treadmill friend-like snapshot payload")
		return
	end

	if not self:_isAlive() or p ~= self._snapshotRequestSerial then
		return
	end

	self._friendLikeUserIdsByMediaLikeKey = table.clone(v3.FriendLikeUserIdsByMediaLikeKey)
	self:UpdatePresentation()
end

function FriendLikesController:_requestFriendLikeSnapshotAsync()
	self._snapshotRequestSerial += 1
	local _snapshotRequestSerial = self._snapshotRequestSerial
	task.spawn(function()
		if not self:_isAlive() then
			return
		end

		self:_requestFriendLikeSnapshot(_snapshotRequestSerial)
	end)
end

function FriendLikesController:_resolveDisplayName(p: number)
	local playerByUserId = Players:GetPlayerByUserId(p)

	if playerByUserId == nil then
		return displayName(p)
	end

	return playerByUserId.DisplayName
end

function FriendLikesController:_showProfilePreview(p: number, image: string)
	self:_cancelProfileTween()
	local _resolveDisplayName = self:_resolveDisplayName(p)

	if not self:_isAlive() then
		return
	end

	self._profilePlayerIcon.Image = image
	self._profileTextLabel.RichText = true
	local v2 = p == Constants.OWNER_ID and " (OWNER)" or ""
	self._profileTextLabel.Text = `<b>{escapeRichText(_resolveDisplayName)}{v2}</b> liked this video`
	self._profile.Position = self:_getProfileHiddenPosition()
	self._profile.Visible = true

	if image == "" then
		task.spawn(function()
			local v3 = thumbnail(p, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
			local image2 = v3 == nil and "" or v3

			if self:_isAlive() and self._profile.Visible then
				self._profilePlayerIcon.Image = image2
			end
		end)
	end

	local tween = TweenService:Create(self._profile, tweenInfo, {
		Position = self._profileVisiblePosition
	})
	self._profileTween = tween
	tween.Completed:Once(function()
		if self._profileTween ~= tween then
			return
		end

		self._profileTween = nil
	end)
	tween:Play()
end

function FriendLikesController:_startRefreshLoop()
	task.spawn(function()
		while self:_isAlive() do
			task.wait(180)

			if not self:_isAlive() then
				break
			end

			self:_requestFriendLikeSnapshotAsync()
		end
	end)
end

function FriendLikesController:_init(adornee)
	self._surfaceGui.Adornee = adornee
	self._surfaceGui.Enabled = true
	self._rowTemplate.Visible = false
	self._profileTextLabel.RichText = true
	self:_hideProfileImmediate()
	self:UpdatePresentation()
	self:_requestFriendLikeSnapshotAsync()
	self:_startRefreshLoop()
end

function FriendLikesController:UpdatePresentation()
	if not self:_isAlive() then
		return
	end

	self:_clearRows()
	local _getMediaKey = self:_getMediaKey()
	local v2 = self._friendLikeUserIdsByMediaLikeKey[_getMediaKey]

	if v2 == nil or #v2 == 0 then
		return
	end

	for i, v3 in ipairs(v2) do
		local clone = self._rowTemplate:Clone()
		local button = clone.Button
		clone.Name = `FriendLike_{v3}`
		clone.Visible = true
		clone.LayoutOrder = i
		button.PlayerIcon.Image = ""
		clone.Parent = self._rowsContainer
		local maid = self._rowsTrove:Extend()
		startButtonFloat(button, maid)
		local v4 = v3
		maid:Add(ButtonFX(button, nil, function()
			self:SuppressScreenTap()
			self._interactionCallback()
			self:_showProfilePreview(v4, button.PlayerIcon.Image)
		end))
		maid:Add(clone)
		local v6 = v3
		local button2 = button
		task.spawn(function()
			local v9 = thumbnail(v6, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180)
			local image = v9 == nil and "" or v9

			if not self:_isAlive() or clone.Parent == nil then
				return
			end

			button2.PlayerIcon.Image = image
		end)
	end
end

function FriendLikesController:HandleScreenTap()
	if not self:_isAlive() or os.clock() < self._screenTapSuppressUntil then
		return
	end

	self:HideProfilePreview()
end

function FriendLikesController:SuppressScreenTap()
	self._screenTapSuppressUntil = os.clock() + 0.12
end

function FriendLikesController:HandleMediaChanged()
	if not self:_isAlive() then
		return
	end

	self:HideProfilePreview()
	self:UpdatePresentation()
	self:_requestFriendLikeSnapshotAsync()
end

function FriendLikesController:HideProfilePreview()
	if not self:_isAlive() then
		return
	end

	self:_cancelProfileTween()

	if not self._profile.Visible then
		self._profile.Position = self:_getProfileHiddenPosition()
		return
	end

	local tween = TweenService:Create(self._profile, tweenInfo2, {
		Position = self:_getProfileHiddenPosition()
	})
	self._profileTween = tween
	tween.Completed:Once(function()
		if self._profileTween ~= tween then
			return
		end

		self._profileTween = nil
		self._profile.Visible = false
	end)
	tween:Play()
end

function FriendLikesController:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	self:_clearRows()
	self:_hideProfileImmediate()
	self._surfaceGui.Enabled = false
	self._trove:Destroy()
end

return FriendLikesController