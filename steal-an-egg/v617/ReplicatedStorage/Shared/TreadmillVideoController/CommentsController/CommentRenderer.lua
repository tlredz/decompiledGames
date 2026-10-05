local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextService = game:GetService("TextService")
local ButtonFX = require(ReplicatedStorage.Client.UI.VFX.ButtonFX)
local Constants = require(ReplicatedStorage.Shared.Globals.Constants)
local Identity = require(ReplicatedStorage.Shared.Utils.Identity)
local displayName = Identity.DisplayName
local Identity2 = require(ReplicatedStorage.Shared.Utils.Identity)
local thumbnail = Identity2.Thumbnail
local Log = require(ReplicatedStorage.Packages.Log)
local Simple = require(ReplicatedStorage.Packages.FormatNumber.Simple)
local Trove = require(ReplicatedStorage.Packages.Trove)
require(script.Parent.Types.Interface)
require(ReplicatedStorage.Client.VideoComments.Types.Interface)
local color = Color3.fromRGB(232, 68, 86)
local color2 = Color3.fromRGB(255, 255, 255)
local v = Log.new()

local function formatPostedAt(createdAt: number)
	local v2 = math.max(0, os.time() - createdAt)

	if v2 < 60 then
		return "just now"
	end

	if v2 < 3600 then
		return (`{math.floor(v2 / 60)}m ago`)
	end

	if v2 < 86400 then
		return (`{math.floor(v2 / 3600)}h ago`)
	end

	return (`{math.floor(v2 / 86400)}d ago`)
end

local function fitDisplayName(displayName2, text: string)
	displayName2.Text = text
	displayName2.AutomaticSize = Enum.AutomaticSize.X
	displayName2.TextTruncate = Enum.TextTruncate.AtEnd
	local v2 = math.min(
		math.ceil(TextService:GetTextSize(
			text,
			displayName2.TextSize,
			displayName2.Font,
			Vector2.new(1e999, displayName2.AbsoluteSize.Y)
		).X) + 2,
		140
	)
	displayName2.Size = UDim2.new(0, v2, displayName2.Size.Y.Scale, displayName2.Size.Y.Offset)
end

local function configureDynamicLayout(clone)
	clone.AutomaticSize = Enum.AutomaticSize.Y
	clone.Size = UDim2.fromScale(1, 0)
	clone.Content.AutomaticSize = Enum.AutomaticSize.Y
	clone.Content.Size = UDim2.new(clone.Content.Size.X.Scale, clone.Content.Size.X.Offset, 0, 0)
	clone.Content.Comment.AutomaticSize = Enum.AutomaticSize.Y
	clone.Content.Comment.Size = UDim2.fromScale(1, 0)
	clone.Content.Comment.TextWrapped = true
end

local function configureOwnerPresentation(p, flag: boolean, textColor: Color3)
	local displayName2 = p.Content.User.DisplayName
	p.Content.User.OwnerTag.Visible = flag
	displayName2.OwnerGradient.Enabled = flag
	displayName2.OwnerStroke.Enabled = flag

	if flag then
		textColor = color2
	end

	displayName2.TextColor3 = textColor
end

local function loadUserPresentation(clone, userId: number)
	fitDisplayName(clone.Content.User.DisplayName, "Loading...")
	task.spawn(function()
		local success, result = pcall(displayName, userId)

		if clone.Parent == nil then
			return
		end

		if not success then
			v:AtTrace():Log((`Failed to resolve comment display name for user {userId}`))
			return
		end

		if userId == Constants.OWNER_ID then
			result = `{result}`
		end

		fitDisplayName(clone.Content.User.DisplayName, result)
	end)
	task.spawn(function()
		local success, result = pcall(thumbnail, userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)

		if clone.Parent == nil then
			return
		end

		if success and result ~= nil then
			clone.Avatar.Image = result
		else
			v:AtTrace():Log((`Failed to resolve comment avatar for user {userId}`))
		end
	end)
end

return {
	Create = function(instance, parent, data, layoutOrder: number, callback)
		local clone = instance:Clone()
		clone.Name = `Comment_{data.Id}`
		clone.LayoutOrder = layoutOrder
		clone.Visible = true
		clone.Parent = parent
		local content = clone.Content
		local postedAt = content.Actions.Left.PostedAt
		local like = content.Actions.Right.Like
		local icon = like.Icon
		local textColor3 = icon.TextColor3
		local fontFace = icon.FontFace
		local textColor32 = content.User.DisplayName.TextColor3
		local maid = Trove.new()
		postedAt.LayoutOrder = content.User.DisplayName.LayoutOrder + 1
		content.Comment.Text = data.Message
		postedAt.Text = formatPostedAt(data.CreatedAt)
		configureDynamicLayout(clone)
		local v2 = data.UserId == Constants.OWNER_ID
		local displayName2 = clone.Content.User.DisplayName
		clone.Content.User.OwnerTag.Visible = v2
		displayName2.OwnerGradient.Enabled = v2
		displayName2.OwnerStroke.Enabled = v2

		if v2 then
			textColor32 = color2
		end

		displayName2.TextColor3 = textColor32

		if data.ImageAssetId == nil then
			content.Photo.Visible = false
		else
			content.Photo.Visible = true
			content.Photo.Container.Image.Image = `rbxassetid://{data.ImageAssetId}`
			content.Photo.Container.Image.ScaleType = Enum.ScaleType.Crop
		end

		local function updateLike(flag: boolean, p: number)
			local icon2 = icon
			local textColor

			if flag then
				textColor = color
			else
				textColor = textColor3
			end

			icon2.TextColor3 = textColor
			local icon3 = icon
			local fontFace2

			if flag then
				fontFace2 = Font.new(fontFace.Family, Enum.FontWeight.Bold, fontFace.Style)
			else
				fontFace2 = fontFace
			end

			icon3.FontFace = fontFace2
			like.Label.Text = Simple.FormatCompact(math.max(0, p), ".#")
		end

		local likedByViewer = data.LikedByViewer
		local likeCount = data.LikeCount

		if likedByViewer then
			textColor3 = color
		end

		icon.TextColor3 = textColor3

		if likedByViewer then
			fontFace = Font.new(fontFace.Family, Enum.FontWeight.Bold, fontFace.Style)
		end

		icon.FontFace = fontFace
		like.Label.Text = Simple.FormatCompact(math.max(0, likeCount), ".#")
		loadUserPresentation(clone, data.UserId)
		maid:Add(ButtonFX(like, nil, function()
			callback(data.Id)
		end))
		maid:Add(clone)
		return {
			Row = clone,
			UpdateLike = updateLike,
			Destroy = function()
				maid:Destroy()
			end
		}
	end
}