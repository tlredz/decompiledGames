local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local Marketplace = require(ReplicatedStorage.Shared.Utils.Marketplace)
local info = Marketplace.Info
local Toast = require(ReplicatedStorage.Client.Notifications.Toast)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(script.Parent.Types.Interface)
local t = require(ReplicatedStorage.Packages.t)
local TryCall = require(ReplicatedStorage.Shared.Utils.TryCall)
local PhotoInputController = {}
PhotoInputController.__index = PhotoInputController
PhotoInputController.__class = "PhotoInputController"
local interface = t.interface({
	AssetTypeId = t.number
})

function PhotoInputController.new(p, onInteraction)
	local addPhoto = p.AddPhoto
	local content = p.Sheet.Actions.Content
	local object = setmetatable({}, PhotoInputController)
	object._addButton = addPhoto.Frame.Buttons.Add
	object._attachment = content.TextInputWrapper.AddedPhoto
	object._cancelButton = addPhoto.Frame.Buttons.Cancel
	object._composerAddPhotoButton = content.AddPhoto
	object._destroyed = false
	object._imageAssetId = nil
	object._input = addPhoto.Frame.TextInputWrapper.TextInput
	object._onInteraction = onInteraction
	object._overlay = addPhoto
	object._removeButton = object._attachment.RemoveButton
	object._requestSerial = 0
	object._textInputWrapper = content.TextInputWrapper
	object._trove = Trove.new()
	object:_init()
	return object
end

local function parseImageAssetId(text: string)
	local v = text:match("^%s*(.-)%s*$") or ""
	local match = v:match("^%d+$")

	if match == nil then
		match = string.lower(v):match("^rbxassetid://(%d+)$")
	end

	local selected

	if match ~= nil then
		selected = tonumber(match)
	end

	if selected == nil or selected <= 0 or selected % 1 ~= 0 then
		return nil
	end

	return selected
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

local function isImageAsset(p: number)
	local v, v2 = TryCall(info, p, Enum.InfoType.Asset)

	if not (v and interface(v2)) then
		return false, "ImageAssetLookupFailed"
	end

	local assetTypeId = v2.AssetTypeId

	if assetTypeId == Enum.AssetType.Image.Value or assetTypeId == Enum.AssetType.Decal.Value then
		return true, nil
	end

	return false, "InvalidImageAssetId"
end

function PhotoInputController:_setAttachment(imageAssetId: number?)
	self._imageAssetId = imageAssetId
	self._attachment.Visible = imageAssetId ~= nil

	if imageAssetId == nil then
		self._attachment.Icon.Image = ""
	else
		self._attachment.Icon.Image = `rbxassetid://{imageAssetId}`
	end
end

function PhotoInputController:_closeOverlay()
	self._requestSerial += 1
	self._addButton.Active = true
	self._overlay.Visible = false
	self._input.Text = ""
end

function PhotoInputController:GetImageAssetId()
	return self._imageAssetId
end

function PhotoInputController:Reset()
	self:_closeOverlay()
	self:_setAttachment(nil)
end

function PhotoInputController:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	self:Reset()
	self._trove:Destroy()
end

function PhotoInputController:_init()
	local v = Players.LocalPlayer.UserId == Constants.OWNER_ID
	self._overlay.Visible = false
	self._attachment.Visible = false
	self._composerAddPhotoButton.Visible = v
	self._composerAddPhotoButton.Active = v
	self._composerAddPhotoButton.Selectable = v
	local _textInputWrapper = self._textInputWrapper
	local size

	if v then
		size = UDim2.new(1, -105, 0, 48)
	else
		size = UDim2.new(1, -50, 0, 48)
	end

	_textInputWrapper.Size = size

	if not v then
		return
	end

	self._trove:Add(ButtonFX(self._composerAddPhotoButton, nil, function()
		self._onInteraction()
		self._overlay.Visible = true
		self._input:CaptureFocus()
	end))
	self._trove:Add(ButtonFX(self._cancelButton, 1.08, function()
		self._onInteraction()
		self:_closeOverlay()
	end))
	self._trove:Add(ButtonFX(self._removeButton, nil, function()
		self._onInteraction()
		self:_setAttachment(nil)
	end))
	self._trove:Add(ButtonFX(self._addButton, 1.08, function()
		self._onInteraction()
		local v3 = parseImageAssetId(self._input.Text)

		if v3 == nil then
			showInvalidImageNotification() -- equivalent call inferred; original call site unknown
			return
		end

		self._requestSerial += 1
		local _requestSerial = self._requestSerial
		self._addButton.Active = false
		task.spawn(function()
			local imageAsset, v5 = isImageAsset(v3)

			if self._destroyed or _requestSerial ~= self._requestSerial then
				return
			end

			self._addButton.Active = true

			if imageAsset then
				self:_setAttachment(v3)
				self:_closeOverlay()
			elseif v5 == "ImageAssetLookupFailed" then
				showImageLookupFailedNotification() -- equivalent call inferred; original call site unknown
			else
				showInvalidImageNotification() -- equivalent call inferred; original call site unknown
			end
		end)
	end))
end

return PhotoInputController