local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local GUI = require(ReplicatedStorage.Client.GUI)
local TryLock = require(ReplicatedStorage.Shared.Utils.TryLock)
local RecommendationSignals = require(script.Parent.RecommendationSignals)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
local TreadmillMediaIdentity = require(ReplicatedStorage.Shared.Modules.TreadmillMediaIdentity)
local Schema = require(ReplicatedStorage.Shared.Types.TreadmillMediaLike.Types.Schema)
require(ReplicatedStorage.Shared.Types.TreadmillMediaLike.Types.Interface)
local t = require(ReplicatedStorage.Packages.t)
local TryCall = require(ReplicatedStorage.Shared.Utils.TryCall)
local intersection = t.intersection(t.numberMinExclusive(-1e999), t.numberMaxExclusive(1e999))

local function fn(p)
	return typeof(p) == "Vector2" and intersection(p.X) and intersection(p.Y)
end

require(ReplicatedStorage.Shared.Globals.Constants)
local Log = require(ReplicatedStorage.Packages.Log)
local Preload = require(ReplicatedStorage.Shared.Utils.Preload)
local warmAssets = Preload.WarmAssets
require(ReplicatedStorage.Packages.Trove)
require(script.Parent.Types.Interface)
local LikeController = {}
LikeController.__index = LikeController
LikeController.__class = "LikeController"
local color = Color3.fromRGB(255, 92, 122)
local v = Log.new()
task.spawn(function()
	local v2 = {}

	for _, image in { "rbxassetid://90146064998908", "rbxassetid://123761405635833" } do
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Image = image
		table.insert(v2, imageLabel)
	end

	warmAssets(v2)

	for _, v3 in v2 do
		v3:Destroy()
	end
end)
local surfaceGui = GUI.TreadmillScreenSideButtons()
assert(surfaceGui:IsA("SurfaceGui"), "Treadmill like GUI must be a SurfaceGui")
local likeButton = surfaceGui.Frame.Buttons.LikeButton
assert(likeButton:IsA("ImageButton"), "Treadmill like button must be an ImageButton")
local likeCount = likeButton.LikeCount
assert(likeCount:IsA("TextLabel"), "Treadmill like count label must be a TextLabel")

function LikeController.new(getActiveVideoIndex, onSingleTap, mediaEntries, object, videoFrame, p)
	t.strict(t.callback)(getActiveVideoIndex)
	t.strict(t.callback)(onSingleTap)
	t.strict(t.table)(mediaEntries)
	t.strict(t.table)(object)
	t.strict(t.Instance)(videoFrame)
	t.strict(t.instanceIsA("BasePart"))(p)
	local self = setmetatable({}, LikeController)
	self._countsByMediaLikeKey = {}
	self._defaultLikeButtonColor = likeButton.ImageColor3
	self._destroyed = false
	self._getActiveVideoIndex = getActiveVideoIndex
	self._lastScreenTapPosition = nil
	self._lastScreenTapTime = nil
	self._likeButton = likeButton
	self._likeCountLabel = likeCount
	self._likeRequestLocks = {}
	self._likeSurfaceGui = surfaceGui
	self._likedTreadmillMedia = {}
	self._mediaEntries = mediaEntries
	self._onSingleTap = onSingleTap
	self._pendingSingleTapSerial = 0
	self._snapshotRequestSerial = 0
	self._screenTapSuppressUntil = 0
	self._trove = object:Extend()
	self._videoFrame = videoFrame
	self:_init(p)
	return self
end

local function formatLikeCount(p: number)
	return Simple.FormatCompact(math.max(p, 0), ".#")
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSquareHeartSize(point: Vector2, p: number)
	local v2 = math.min(point.X, point.Y)
	return UDim2.fromScale(v2 / point.X * p, v2 / point.Y * p)
end

function LikeController:_isAlive()
	return not self._destroyed
end

function LikeController:_getMediaKey()
	local _getActiveVideoIndex = self._getActiveVideoIndex()
	local _mediaEntry = self._mediaEntries[_getActiveVideoIndex]
	assert(_mediaEntry ~= nil, (`Missing treadmill media entry for index {_getActiveVideoIndex}`))
	return TreadmillMediaIdentity.GetMediaKey(_mediaEntry)
end

function LikeController:_setRuntimeLikedState(p2: string, flag: boolean)
	if flag then
		self._likedTreadmillMedia[p2] = true
	else
		self._likedTreadmillMedia[p2] = nil
	end
end

function LikeController:_applyLocalLikedState(p: string, flag: boolean)
	if self._likedTreadmillMedia[p] == true == flag then
		return
	end

	self:_setRuntimeLikedState(p, flag)
	self._countsByMediaLikeKey[p] = math.max((self._countsByMediaLikeKey[p] or 0) + (flag and 1 or -1), 0)
	self:UpdatePresentation()
end

function LikeController:_reconcileLikedState(p: string, p2)
	self:_setRuntimeLikedState(p, p2.Liked == true)

	if typeof(p2.Count) == "number" then
		self._countsByMediaLikeKey[p] = p2.Count
	end

	self:UpdatePresentation()
end

function LikeController:_requestLikeSnapshot(p: number)
	local v2, v3 = TryCall(function()
		return Remotes.Treadmill.AskFavourSnapshot:InvokeServer()
	end)

	if not v2 then
		v:AtError():Log((`Failed to load treadmill media like snapshot: {v3}`))
		return
	end

	if not Schema.LikeSnapshot(v3) then
		v:AtError():Log("Invalid treadmill media like snapshot payload")
		return
	end

	if not self:_isAlive() or p ~= self._snapshotRequestSerial then
		return
	end

	self._countsByMediaLikeKey = table.clone(v3.CountsByMediaLikeKey)
	self._likedTreadmillMedia = table.clone(v3.LikedTreadmillMedia)
	self:UpdatePresentation()
end

function LikeController:_requestLikeSnapshotAsync()
	self._snapshotRequestSerial += 1
	local _snapshotRequestSerial = self._snapshotRequestSerial
	task.spawn(function()
		if not self:_isAlive() then
			return
		end

		self:_requestLikeSnapshot(_snapshotRequestSerial)
	end)
end

function LikeController:_setLikedState(flag: boolean)
	local _getMediaKey = self:_getMediaKey()
	local _likeRequestLock = self._likeRequestLocks[_getMediaKey]

	if _likeRequestLock == nil then
		_likeRequestLock = TryLock()
		self._likeRequestLocks[_getMediaKey] = _likeRequestLock
	end

	_likeRequestLock(function()
		self._snapshotRequestSerial += 1
		local v3 = self._likedTreadmillMedia[_getMediaKey] == true
		local v4 = self._countsByMediaLikeKey[_getMediaKey] or 0
		self:_applyLocalLikedState(_getMediaKey, flag)
		local v5, v6 = TryCall(function()
			return Remotes.Treadmill.AskClipFavour:InvokeServer(_getMediaKey, flag)
		end)

		if v5 then
			if Schema.LikeToggleResult(v6) then
				if v6.Ok == true then
					if not self:_isAlive() then
						return
					end

					self:_reconcileLikedState(_getMediaKey, v6)
					RecommendationSignals.NotifyLikeResult(_getMediaKey, v6.Liked == true)
				else
					if not self:_isAlive() then
						return
					end

					self:_setRuntimeLikedState(_getMediaKey, v3)
					self._countsByMediaLikeKey[_getMediaKey] = v4
					self:UpdatePresentation()
					v:AtError():Log((`Rejected treadmill media like state update: {tostring(v6.Error)}`))
				end
			else
				if not self:_isAlive() then
					return
				end

				self:_setRuntimeLikedState(_getMediaKey, v3)
				self._countsByMediaLikeKey[_getMediaKey] = v4
				self:UpdatePresentation()
				v:AtError():Log("Rejected treadmill media like state update: Invalid like toggle response")
			end
		else
			if not self:_isAlive() then
				return
			end

			self:_setRuntimeLikedState(_getMediaKey, v3)
			self._countsByMediaLikeKey[_getMediaKey] = v4
			self:UpdatePresentation()
			v:AtError():Log((`Failed to update treadmill media like state: {v6}`))
		end
	end)
end

function LikeController:_spawnHeartAnimation(point: Vector2)
	t.strict(fn)(point)
	local _videoFrame = self._videoFrame
	local absoluteSize = _videoFrame.AbsoluteSize
	local v2

	if absoluteSize.X > 0 then
		v2 = absoluteSize.Y > 0
	else
		v2 = false
	end

	assert(v2, "Treadmill like animation requires a non-zero video frame size")
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "TreadmillLikeHeart"
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = "rbxassetid://90146064998908"
	imageLabel.ImageColor3 = color
	imageLabel.ImageTransparency = 0
	imageLabel.Position = UDim2.fromScale(point.X, point.Y)
	imageLabel.Size = UDim2.fromScale(0.15, 0.08)
	imageLabel.ZIndex = self._likeButton.ZIndex + 10
	imageLabel.Parent = _videoFrame
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.Parent = imageLabel
	local random = Random.new()
	local number = random:NextNumber(-0.08, 0.08)
	local v3 = -random:NextNumber(0.24, 0.34)
	local vector = Vector2.new(math.clamp(point.X + number, 0.05, 0.95), (math.clamp(point.Y + v3, 0.05, 0.95)))
	local vector2 = Vector2.new(
		math.clamp(point.X + number * 0.55, 0.05, 0.95),
		(math.clamp(point.Y + v3 * 0.45, 0.05, 0.95))
	)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function bezier(value: number)
		return point:Lerp(vector2, value):Lerp(vector2:Lerp(vector, value), value)
	end

	local preRenderConnection = nil
	local flag = false

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cleanupHeart()
		if flag then
			return
		end

		flag = true
		local connection = preRenderConnection
		preRenderConnection = nil

		if connection ~= nil then
			connection:Disconnect()
		end

		if imageLabel.Parent ~= nil then
			imageLabel:Destroy()
		end
	end

	local v4 = 0
	preRenderConnection = RunService.PreRender:Connect(function(dt: number)
		if self:_isAlive() and imageLabel.Parent ~= nil then
			v4 = math.min(v4 + dt, 0.65)
			local v5 = v4 / 0.65
			local v6 = bezier(TweenService:GetValue(v5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)) -- equivalent call inferred; original call site unknown
			local v7

			if v5 <= 0.18 then
				v7 = 0.6 + -0.19999999999999996 * TweenService:GetValue(
					v5 / 0.18,
					Enum.EasingStyle.Back,
					Enum.EasingDirection.Out
				)
			else
				v7 = 0.4 + -0.32 * TweenService:GetValue(
					(v5 - 0.18) / 0.82,
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.In
				)
			end

			imageLabel.Position = UDim2.fromScale(v6.X, v6.Y)
			imageLabel.Size = getSquareHeartSize(absoluteSize, v7)
			imageLabel.ImageTransparency = math.clamp((v5 - 0.35) / 0.65, 0, 1)

			if v5 >= 1 then
				cleanupHeart() -- equivalent call inferred; original call site unknown
			end
		else
			cleanupHeart() -- equivalent call inferred; original call site unknown
		end
	end)
	self._trove:Add(cleanupHeart)
end

function LikeController:_handleDoubleTap(point: Vector2)
	t.strict(fn)(point)
	self:_spawnHeartAnimation(point)
	local _getMediaKey = self:_getMediaKey()

	if self._likedTreadmillMedia[_getMediaKey] == true then
		return
	end

	self:_setLikedState(true)
end

function LikeController:_startRefreshLoop()
	task.spawn(function()
		while self:_isAlive() do
			task.wait(180)

			if not self:_isAlive() then
				break
			end

			self:_requestLikeSnapshotAsync()
		end
	end)
end

function LikeController:_init(adornee)
	self._likeSurfaceGui.Adornee = adornee
	self._likeSurfaceGui.Enabled = true
	self:UpdatePresentation()
	self._trove:Add(ButtonFX(self._likeButton, nil, function()
		self:Toggle()
	end))
	self:_requestLikeSnapshotAsync()
	self:_startRefreshLoop()
end

function LikeController:UpdatePresentation()
	if not self:_isAlive() then
		return
	end

	local _getMediaKey = self:_getMediaKey()
	local v2 = self._likedTreadmillMedia[_getMediaKey] == true
	local v3 = self._countsByMediaLikeKey[_getMediaKey] or 0
	local _likeButton = self._likeButton
	local imageColor

	if v2 then
		imageColor = color
	else
		imageColor = Color3.fromRGB(255, 255, 255)
	end

	_likeButton.ImageColor3 = imageColor
	self._likeButton.Image = v2 and "rbxassetid://90146064998908" or "rbxassetid://123761405635833"
	self._likeCountLabel.Text = Simple.FormatCompact(math.max(v3, 0), ".#")
end

function LikeController:SuppressScreenTap()
	self._screenTapSuppressUntil = os.clock() + 0.12
end

function LikeController:Toggle()
	if not self:_isAlive() then
		return
	end

	self:SuppressScreenTap()
	local _getMediaKey = self:_getMediaKey()
	self:_setLikedState(self._likedTreadmillMedia[_getMediaKey] ~= true)
end

function LikeController:HandleScreenTap(lastScreenTapPosition: Vector2)
	t.strict(fn)(lastScreenTapPosition)

	if not self:_isAlive() or os.clock() < self._screenTapSuppressUntil then
		return
	end

	local now = os.clock()
	local absoluteSize = self._videoFrame.AbsoluteSize
	local v2

	if absoluteSize.X > 0 then
		v2 = absoluteSize.Y > 0
	else
		v2 = false
	end

	assert(v2, "Treadmill like tap handling requires a non-zero video frame size")

	if self._lastScreenTapTime == nil or self._lastScreenTapPosition == nil or not (now - self._lastScreenTapTime <= 0.25 and Vector2.new(
		(lastScreenTapPosition.X - self._lastScreenTapPosition.X) * absoluteSize.X,
		(lastScreenTapPosition.Y - self._lastScreenTapPosition.Y) * absoluteSize.Y
	).Magnitude <= 36) then
		self._pendingSingleTapSerial += 1
		local _pendingSingleTapSerial = self._pendingSingleTapSerial
		self._lastScreenTapTime = now
		self._lastScreenTapPosition = lastScreenTapPosition
		task.delay(0.25, function()
			if not self:_isAlive() or self._pendingSingleTapSerial ~= _pendingSingleTapSerial then
				return
			end

			self._lastScreenTapTime = nil
			self._lastScreenTapPosition = nil
			self._onSingleTap()
		end)
	else
		self._pendingSingleTapSerial += 1
		self._lastScreenTapTime = nil
		self._lastScreenTapPosition = nil
		self:_handleDoubleTap(lastScreenTapPosition)
	end
end

function LikeController:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	self._pendingSingleTapSerial += 1
	self._likeSurfaceGui.Enabled = false
	self._trove:Destroy()
end

return LikeController