local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local spr = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Utils"):WaitForChild("spr"))
local v = nil
pcall(function()
	local CharacterInfo = require(ReplicatedStorage:WaitForChild("StoryScripts"):WaitForChild("CharacterInfo"))
	v = CharacterInfo
end)
local v2 = {
	MAX_NOTIFICATIONS = 4,
	NOTIFICATION_DURATION = 3,
	NOTIFICATION_SPACING = 10,
	SIDE_PADDING = 12,
	TOP_PADDING = 140,
	PLACEMENT = "Right",
	SHOW_BACKGROUND = true,
	USE_CHARACTER_COLOR = true,
	USE_GRADIENT = true,
	USE_IMAGE_OVERLAY = true,
	BACKGROUND_COLOR = Color3.fromRGB(30, 30, 35),
	BACKGROUND_TRANSPARENCY = 0.5,
	CORNER_RADIUS = 8,
	SHOW_PORTRAIT = true,
	PORTRAIT_SIZE = 60,
	PORTRAIT_BG_DARKEN = 0.5,
	SHOW_STICKER_ICON = true,
	STICKER_ICON_SIZE = 64,
	STICKER_ON_LEFT = false,
	ANIMATE_STICKER_ICON = true,
	STICKER_ANIMATION_TYPE = "wiggle",
	NOTIFICATION_WIDTH = 280,
	NOTIFICATION_HEIGHT = 70,
	USERNAME_TEXT_SIZE = 16,
	SPEECH_TEXT_SIZE = 14,
	USERNAME_POSITION = "inside",
	PORTRAIT_VERTICAL_OFFSET = 0,
	USE_ROBLOX_BLOCKED = true,
	SYSTEM_EVENTS_ENABLED = false
}
local result = {}
local StickerNotificationUI = {}
local v3 = {
	"Right",
	"Left",
	"TopRight",
	"TopLeft",
	"BottomRight",
	"BottomLeft"
}

for k, v4 in pairs(v2) do
	result[k] = v4
end

local screenGui = nil
local frame = nil
local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}
local sharedData = ReplicatedStorage:FindFirstChild("SharedData")
local towerData = sharedData and sharedData:FindFirstChild("TowerData") or ReplicatedStorage:FindFirstChild("TowerData")
local v8 = {}
local notif = nil
pcall(function()
	local UI = ReplicatedStorage:FindFirstChild("UI")

	if UI then
		notif = UI:FindFirstChild("Notif")
	end
end)

local function RefreshBlockedUsers()
	local localPlayer = Players.LocalPlayer

	if not localPlayer or localPlayer.UserId <= 0 then
		return
	end

	local success, result2 = pcall(function()
		return StarterGui:GetCore("GetBlockedUserIds")
	end)

	if success and result2 then
		v6 = {}

		for _, v9 in ipairs(result2) do
			v6[v9] = true
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function IsBlocked(p)
	if result.USE_ROBLOX_BLOCKED then
		return v6[p] == true
	end

	return false
end

local function GetCharacterIcon(childName)
	if not (result.SHOW_PORTRAIT and childName) then
		return nil
	end

	if v8[childName] then
		return v8[childName].Icon
	end

	local child = towerData and towerData:FindFirstChild(childName)

	if not child and sharedData then
		local towerData2 = ReplicatedStorage:FindFirstChild("TowerData")
		child = towerData2 and towerData2:FindFirstChild(childName)
	end

	if not child then
		return nil
	end

	local success, result2 = pcall(require, child)

	if success and result2 then
		v8[childName] = result2
		return result2.Icon
	end

	return nil
end

local function GetCharacterColor(p)
	if result.USE_CHARACTER_COLOR and p and v and v[p] then
		return v[p].Color
	end

	return result.BACKGROUND_COLOR
end

-- equivalent calls inferred from this helper; original call sites unknown
local function DarkenColor(BACKGROUND_COLOR, PORTRAIT_BG_DARKEN)
	local HSV, v9, v10 = BACKGROUND_COLOR:ToHSV()
	return Color3.fromHSV(HSV, v9, v10 * PORTRAIT_BG_DARKEN)
end

local function GetPlacementConfig()
	local PLACEMENT = result.PLACEMENT or "Right"
	local v9 = {
		Right = {
			position = UDim2.new(1, 0, 0, 0),
			anchor = Vector2.new(1, 0),
			slideIn = -result.SIDE_PADDING,
			slideOut = result.NOTIFICATION_WIDTH + 50,
			rotation = 2,
			exitRotation = -3
		},
		Left = {
			position = UDim2.new(0, 0, 0, 0),
			anchor = Vector2.new(0, 0),
			slideIn = result.SIDE_PADDING,
			slideOut = -(result.NOTIFICATION_WIDTH + 50),
			rotation = -2,
			exitRotation = 3
		},
		TopRight = {
			position = UDim2.new(1, 0, 0, 0),
			anchor = Vector2.new(1, 0),
			slideIn = -result.SIDE_PADDING,
			slideOut = result.NOTIFICATION_WIDTH + 50,
			rotation = 2,
			exitRotation = -3
		},
		TopLeft = {
			position = UDim2.new(0, 0, 0, 0),
			anchor = Vector2.new(0, 0),
			slideIn = result.SIDE_PADDING,
			slideOut = -(result.NOTIFICATION_WIDTH + 50),
			rotation = -2,
			exitRotation = 3
		},
		BottomRight = {
			position = UDim2.new(1, 0, 1, 0),
			anchor = Vector2.new(1, 1),
			slideIn = -result.SIDE_PADDING,
			slideOut = result.NOTIFICATION_WIDTH + 50,
			rotation = 2,
			exitRotation = -3
		},
		BottomLeft = {
			position = UDim2.new(0, 0, 1, 0),
			anchor = Vector2.new(0, 1),
			slideIn = result.SIDE_PADDING,
			slideOut = -(result.NOTIFICATION_WIDTH + 50),
			rotation = -2,
			exitRotation = 3
		}
	}
	return v9[PLACEMENT] or v9.Right
end

-- equivalent calls inferred from this helper; original call sites unknown
local function GetViewportScale()
	local currentCamera = workspace.CurrentCamera

	if not currentCamera then
		return 1
	end

	local viewportSize = currentCamera.ViewportSize
	return (math.clamp(math.min(viewportSize.X / 1920, viewportSize.Y / 1080), 0.5, 1.2))
end

local uIScale = nil

local function GetMaxNotifications()
	if UserInputService.TouchEnabled then
		return 5
	end

	return 8
end

local function EnsureUI()
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return false
	end

	local playerGui = localPlayer:FindFirstChild("PlayerGui")

	if not playerGui then
		return false
	end

	if screenGui and screenGui.Parent then
		return true
	end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "StickerNotifications"
	screenGui.ResetOnSpawn = false
	screenGui.DisplayOrder = 50
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui
	local placementConfig = GetPlacementConfig()
	frame = Instance.new("Frame")
	frame.Name = "Container"
	frame.Size = UDim2.new(0, result.NOTIFICATION_WIDTH + 20, 1, 0)
	frame.Position = placementConfig.position
	frame.AnchorPoint = placementConfig.anchor
	frame.BackgroundTransparency = 1
	frame.Parent = screenGui
	uIScale = Instance.new("UIScale")
	local v10 = uIScale
	local scale = GetViewportScale() -- equivalent call inferred; original call site unknown
	v10.Scale = scale
	uIScale.Parent = frame
	local currentCamera = workspace.CurrentCamera

	if currentCamera then
		currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			if uIScale and uIScale.Parent then
				local v12 = uIScale
				local scale2 = GetViewportScale() -- equivalent call inferred; original call site unknown
				v12.Scale = scale2
			end
		end)
	end

	return true
end

local function RepositionNotifications()
	local placementConfig = GetPlacementConfig()
	local PLACEMENT = result.PLACEMENT or "Right"
	local v10 = PLACEMENT == "BottomRight" or PLACEMENT == "BottomLeft"
	local NOTIFICATION_HEIGHT = result.NOTIFICATION_HEIGHT

	for i, v11 in ipairs(v4) do
		local v12

		if v10 then
			v12 = -result.TOP_PADDING - (i - 1) * (NOTIFICATION_HEIGHT + result.NOTIFICATION_SPACING) - NOTIFICATION_HEIGHT
		else
			v12 = result.TOP_PADDING + (i - 1) * (NOTIFICATION_HEIGHT + result.NOTIFICATION_SPACING)
		end

		spr.target(v11, 0.5, 1.8, {
			Position = UDim2.new(0, placementConfig.slideIn, 0, v12)
		})
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function UpdateContainerPlacement()
	if not frame then
		return
	end

	local placementConfig = GetPlacementConfig()
	frame.Position = placementConfig.position
	frame.AnchorPoint = placementConfig.anchor
	RepositionNotifications()
end

local function RemoveNotification(p)
	for i, v9 in ipairs(v4) do
		if v9 ~= p then
			continue
		end

		table.remove(v4, i)
		break
	end

	RepositionNotifications()
end

local v9 = {
	"bounce",
	"pulse",
	"wiggle",
	"none"
}
local v10 = { "inside", "overlap", "above" }

function StickerNotificationUI.GetAnimationTypes()
	return v9
end

function StickerNotificationUI.GetUsernamePositionOptions()
	return v10
end

local function StartStickerAnimation(stickerIcon, stickerScale)
	if not result.ANIMATE_STICKER_ICON or result.STICKER_ANIMATION_TYPE == "none" then
		return nil
	end

	local STICKER_ANIMATION_TYPE = result.STICKER_ANIMATION_TYPE

	if STICKER_ANIMATION_TYPE == "bounce" then
		local position = stickerIcon.Position
		local uDim = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset - 3)
		local goUp

		goUp = function()
			if stickerIcon and stickerIcon.Parent then
				spr.target(stickerIcon, 0.5, 1.5, {
					Position = uDim
				})
				spr.completed(stickerIcon, function()
					if stickerIcon and stickerIcon.Parent then
						spr.target(stickerIcon, 0.5, 1.5, {
							Position = position
						})
						spr.completed(stickerIcon, goUp)
					end
				end)
			end
		end

		goUp()
		return function()
			spr.stop(stickerIcon, "Position")
		end
	elseif STICKER_ANIMATION_TYPE == "pulse" then
		local growUp

		growUp = function()
			if stickerScale and stickerScale.Parent then
				spr.target(stickerScale, 0.6, 1.2, {
					Scale = 1.08
				})
				spr.completed(stickerScale, function()
					if stickerScale and stickerScale.Parent then
						spr.target(stickerScale, 0.6, 1.2, {
							Scale = 0.95
						})
						spr.completed(stickerScale, growUp)
					end
				end)
			end
		end

		growUp()
		return function()
			spr.stop(stickerScale, "Scale")
		end
	else
		if STICKER_ANIMATION_TYPE ~= "wiggle" then
			return nil
		end

		local wiggleRight

		wiggleRight = function()
			if stickerIcon and stickerIcon.Parent then
				spr.target(stickerIcon, 0.25, 2, {
					Rotation = 8
				})
				spr.completed(stickerIcon, function()
					if stickerIcon and stickerIcon.Parent then
						spr.target(stickerIcon, 0.25, 2, {
							Rotation = -8
						})
						spr.completed(stickerIcon, wiggleRight)
					end
				end)
			end
		end

		wiggleRight()
		return function()
			spr.stop(stickerIcon, "Rotation")
		end
	end
end

local function CreateNotificationFromTemplate(text, image, value, p, p2, enabled)
	local clone = notif:Clone()
	clone.Name = "Notif"
	clone.Position = UDim2.new(0, result.NOTIFICATION_WIDTH + 50, 0, result.TOP_PADDING)
	local background = clone:FindFirstChild("Background")
	local portrait = clone:FindFirstChild("Portrait")
	local stickerIcon = clone:FindFirstChild("StickerIcon")
	local stickerIconShadow = clone:FindFirstChild("StickerIconShadow")
	local name = clone:FindFirstChild("Name")
	local speech = clone:FindFirstChild("Speech")
	local BACKGROUND_COLOR = p2 and result.BACKGROUND_COLOR

	if not BACKGROUND_COLOR then
		if result.USE_CHARACTER_COLOR and p then
			if v and v[p] then
				BACKGROUND_COLOR = v[p].Color
			else
				BACKGROUND_COLOR = result.BACKGROUND_COLOR
			end
		else
			BACKGROUND_COLOR = result.BACKGROUND_COLOR
		end
	end

	local image2 = GetCharacterIcon(p)

	if background then
		background.ImageColor3 = BACKGROUND_COLOR
		background.Visible = result.SHOW_BACKGROUND
	end

	if portrait then
		if result.SHOW_PORTRAIT and image2 then
			portrait.Image = image2
			portrait.Visible = true
			portrait.BackgroundTransparency = 0
			portrait.BackgroundColor3 = DarkenColor(BACKGROUND_COLOR, result.PORTRAIT_BG_DARKEN)
		else
			portrait.Visible = false
		end
	end

	local v12 = result.SHOW_STICKER_ICON and image and image ~= ""

	if stickerIcon then
		if v12 then
			stickerIcon.Image = image
			stickerIcon.Visible = true

			if enabled then
				stickerIcon.ImageRectSize = Vector2.new(256, 256)
				stickerIcon.ImageRectOffset = Vector2.new(0, 0)
			end
		else
			stickerIcon.Visible = false
		end
	end

	if stickerIconShadow then
		if v12 then
			stickerIconShadow.Image = image
			stickerIconShadow.Visible = true

			if enabled then
				stickerIconShadow.ImageRectSize = Vector2.new(256, 256)
				stickerIconShadow.ImageRectOffset = Vector2.new(0, 0)
			end
		else
			stickerIconShadow.Visible = false
		end
	end

	if name then
		name.Text = text
	end

	if speech then
		speech.Text = value or ""
	end

	return clone
end

local function CreateNotificationProgrammatic(p, image, value, p2, p3, enabled)
	local NOTIFICATION_WIDTH = result.NOTIFICATION_WIDTH
	local NOTIFICATION_HEIGHT = result.NOTIFICATION_HEIGHT
	local PORTRAIT_SIZE = result.PORTRAIT_SIZE
	local STICKER_ICON_SIZE = result.STICKER_ICON_SIZE
	local USERNAME_TEXT_SIZE = result.USERNAME_TEXT_SIZE
	local SPEECH_TEXT_SIZE = result.SPEECH_TEXT_SIZE
	local BACKGROUND_COLOR = p3 and result.BACKGROUND_COLOR

	if not BACKGROUND_COLOR then
		if result.USE_CHARACTER_COLOR and p2 then
			if v and v[p2] then
				BACKGROUND_COLOR = v[p2].Color
			else
				BACKGROUND_COLOR = result.BACKGROUND_COLOR
			end
		else
			BACKGROUND_COLOR = result.BACKGROUND_COLOR
		end
	end

	local image2 = GetCharacterIcon(p2)
	local frame2 = Instance.new("Frame")
	frame2.Name = "Notif"
	frame2.Size = UDim2.new(0, NOTIFICATION_WIDTH, 0, NOTIFICATION_HEIGHT)
	frame2.Position = UDim2.new(0, NOTIFICATION_WIDTH + 50, 0, result.TOP_PADDING)
	frame2.BackgroundColor3 = BACKGROUND_COLOR
	frame2.BackgroundTransparency = result.SHOW_BACKGROUND and result.BACKGROUND_TRANSPARENCY or 1
	frame2.BorderSizePixel = 0
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, result.CORNER_RADIUS)
	uICorner.Parent = frame2

	if result.USE_GRADIENT and result.SHOW_BACKGROUND and not p3 then
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Rotation = 90
		uIGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(109, 109, 109))
		})
		uIGradient.Parent = frame2
	end

	if result.USE_IMAGE_OVERLAY and result.SHOW_BACKGROUND and not p3 then
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "Overlay"
		imageLabel.Size = UDim2.new(1, 0, 1, 0)
		imageLabel.BackgroundTransparency = 1
		imageLabel.Image = "rbxassetid://6794283750"
		imageLabel.ImageTransparency = 0.95
		imageLabel.ScaleType = Enum.ScaleType.Tile
		imageLabel.TileSize = UDim2.new(0, 64, 0, 64)
		imageLabel.ZIndex = 1
		imageLabel.Parent = frame2
		local uICorner2 = Instance.new("UICorner")
		uICorner2.CornerRadius = UDim.new(0, result.CORNER_RADIUS)
		uICorner2.Parent = imageLabel
	end

	local v12 = result.SHOW_PORTRAIT and image2
	local v13 = result.SHOW_STICKER_ICON and image and image ~= ""
	local v14 = 8
	local v15 = 10

	if result.STICKER_ON_LEFT then
		if v13 then
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "StickerIcon"
			imageLabel.Size = UDim2.new(0, STICKER_ICON_SIZE, 0, STICKER_ICON_SIZE)
			imageLabel.Position = UDim2.new(0, 6, 0.5, 0)
			imageLabel.AnchorPoint = Vector2.new(0, 0.5)
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = image
			imageLabel.ScaleType = Enum.ScaleType.Fit

			if enabled then
				imageLabel.ImageRectSize = Vector2.new(256, 256)
				imageLabel.ImageRectOffset = Vector2.new(0, 0)
			end

			imageLabel.Parent = frame2
			local uIScale2 = Instance.new("UIScale")
			uIScale2.Name = "StickerScale"
			uIScale2.Scale = 0.9
			uIScale2.Parent = imageLabel
			v15 = 6 + STICKER_ICON_SIZE + 8
		end

		if v12 then
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Portrait"
			imageLabel.Size = UDim2.new(0, PORTRAIT_SIZE, 0, PORTRAIT_SIZE)
			imageLabel.Position = UDim2.new(1, -v14, 0.5, result.PORTRAIT_VERTICAL_OFFSET)
			imageLabel.AnchorPoint = Vector2.new(1, 0.5)
			imageLabel.BackgroundTransparency = 0
			imageLabel.BackgroundColor3 = DarkenColor(BACKGROUND_COLOR, result.PORTRAIT_BG_DARKEN)
			imageLabel.Image = image2
			imageLabel.ScaleType = Enum.ScaleType.Fit
			imageLabel.Parent = frame2
			local uICorner2 = Instance.new("UICorner")
			uICorner2.CornerRadius = UDim.new(0, 8)
			uICorner2.Parent = imageLabel
			local uIScale2 = Instance.new("UIScale")
			uIScale2.Name = "PortraitScale"
			uIScale2.Scale = 0.9
			uIScale2.Parent = imageLabel
			v14 = v14 + PORTRAIT_SIZE + 6
		end
	else
		if v12 then
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "Portrait"
			imageLabel.Size = UDim2.new(0, PORTRAIT_SIZE, 0, PORTRAIT_SIZE)
			imageLabel.Position = UDim2.new(0, 6, 0.5, result.PORTRAIT_VERTICAL_OFFSET)
			imageLabel.AnchorPoint = Vector2.new(0, 0.5)
			imageLabel.BackgroundTransparency = 0
			imageLabel.BackgroundColor3 = DarkenColor(BACKGROUND_COLOR, result.PORTRAIT_BG_DARKEN)
			imageLabel.Image = image2
			imageLabel.ScaleType = Enum.ScaleType.Fit
			imageLabel.Parent = frame2
			local uICorner2 = Instance.new("UICorner")
			uICorner2.CornerRadius = UDim.new(0, 8)
			uICorner2.Parent = imageLabel
			local uIScale2 = Instance.new("UIScale")
			uIScale2.Name = "PortraitScale"
			uIScale2.Scale = 0.9
			uIScale2.Parent = imageLabel
			v15 = 6 + PORTRAIT_SIZE + 8
		end

		if v13 then
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Name = "StickerIcon"
			imageLabel.Size = UDim2.new(0, STICKER_ICON_SIZE, 0, STICKER_ICON_SIZE)
			imageLabel.Position = UDim2.new(1, -v14, 0.5, 0)
			imageLabel.AnchorPoint = Vector2.new(1, 0.5)
			imageLabel.BackgroundTransparency = 1
			imageLabel.Image = image
			imageLabel.ScaleType = Enum.ScaleType.Fit

			if enabled then
				imageLabel.ImageRectSize = Vector2.new(256, 256)
				imageLabel.ImageRectOffset = Vector2.new(0, 0)
			end

			imageLabel.Parent = frame2
			local uIScale2 = Instance.new("UIScale")
			uIScale2.Name = "StickerScale"
			uIScale2.Scale = 0.9
			uIScale2.Parent = imageLabel
			v14 = v14 + STICKER_ICON_SIZE + 6
		end
	end

	local v16 = result.USERNAME_POSITION == "overlap" and -6 or result.USERNAME_POSITION == "above" and -18 or 6
	local v17 = USERNAME_TEXT_SIZE + 8
	local textButton = Instance.new("TextButton")
	textButton.Name = "Name"
	textButton.Size = UDim2.new(1, -v15 - v14, 0, v17)
	textButton.Position = UDim2.new(0, v15, 0, v16)
	textButton.BackgroundTransparency = 1
	textButton.RichText = true
	textButton.Text = string.format("<stroke thickness=\"2\" color=\"#141420\"><b>%s</b></stroke>", p)
	textButton.TextColor3 = Color3.fromRGB(200, 200, 210)
	textButton.TextSize = USERNAME_TEXT_SIZE
	textButton.Font = Enum.Font.GothamBold
	textButton.TextXAlignment = Enum.TextXAlignment.Left
	textButton.TextYAlignment = Enum.TextYAlignment.Center
	textButton.TextScaled = true
	textButton.AutoButtonColor = false
	textButton.Parent = frame2
	local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
	uITextSizeConstraint.MaxTextSize = USERNAME_TEXT_SIZE
	uITextSizeConstraint.MinTextSize = 8
	uITextSizeConstraint.Parent = textButton
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "Speech"
	textLabel.Size = UDim2.new(1, -v15 - v14, 0, 22)
	textLabel.Position = UDim2.new(0, v15, 0, 26)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = value or ""
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextSize = SPEECH_TEXT_SIZE
	textLabel.Font = Enum.Font.GothamBold
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextTruncate = Enum.TextTruncate.AtEnd
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.Parent = frame2
	return frame2
end

local function CreateNotificationFrame(text, p2, p3, p4, p5, p6)
	local v11

	if p3 == nil then
		v11 = p4 == nil
	else
		v11 = false
	end

	if not v11 then
		p5 = p2
		p2 = p3
	end

	local enabled = p6 and p6.enabled

	if notif then
		return (CreateNotificationFromTemplate(text, p5, p2, p4, v11, enabled))
	end

	return (CreateNotificationProgrammatic(text, p5, p2, p4, v11, enabled))
end

function StickerNotificationUI.ShowNotification(text, p2, p3, p4, p5, p6)
	if not EnsureUI() then
		return
	end

	local localPlayer = Players.LocalPlayer

	if localPlayer and localPlayer:GetAttribute("StickerChatEnabled") == false or v5[text] then
		return
	end

	if p2 then
		-- equivalent call inferred; original call site unknown
		if IsBlocked(p2) then
			return
		end
	end

	while #v4 >= (UserInputService.TouchEnabled and 5 or 8) do
		local v11 = table.remove(v4, 1)

		if not (v11 and v11.Parent) then
			continue
		end

		if v7[v11] then
			pcall(v7[v11])
			v7[v11] = nil
		end

		v11:Destroy()
	end

	local notificationFrame = CreateNotificationFrame(text, p3, p4, p5, p2, p6)
	notificationFrame.Parent = frame
	table.insert(v4, notificationFrame)
	local placementConfig = GetPlacementConfig()
	local PLACEMENT = result.PLACEMENT or "Right"
	local v13 = PLACEMENT == "BottomRight" or PLACEMENT == "BottomLeft"
	local NOTIFICATION_HEIGHT = result.NOTIFICATION_HEIGHT
	local v14

	if v13 then
		v14 = -result.TOP_PADDING - (#v4 - 1) * (NOTIFICATION_HEIGHT + result.NOTIFICATION_SPACING) - NOTIFICATION_HEIGHT
	else
		v14 = result.TOP_PADDING + (#v4 - 1) * (NOTIFICATION_HEIGHT + result.NOTIFICATION_SPACING)
	end

	local portrait = notificationFrame:FindFirstChild("Portrait")
	local portraitScale = portrait and portrait:FindFirstChild("PortraitScale")
	local stickerIcon = notificationFrame:FindFirstChild("StickerIcon")
	local stickerScale = stickerIcon and stickerIcon:FindFirstChild("StickerScale")
	notificationFrame.Position = UDim2.new(0, placementConfig.slideOut, 0, v14)
	spr.target(notificationFrame, 0.6, 1.2, {
		Position = UDim2.new(0, placementConfig.slideIn, 0, v14)
	})

	if portraitScale then
		task.delay(0.05, function()
			spr.target(portraitScale, 0.5, 1.8, {
				Scale = 1.05
			})
			task.delay(0.15, function()
				spr.target(portraitScale, 0.4, 1.5, {
					Scale = 1
				})
			end)
		end)
	end

	if stickerScale and stickerIcon then
		task.delay(0.08, function()
			spr.target(stickerScale, 0.5, 1.8, {
				Scale = 1.08
			})
			task.delay(0.15, function()
				spr.target(stickerScale, 0.4, 1.5, {
					Scale = 1
				})
				task.delay(0.2, function()
					if stickerIcon and stickerIcon.Parent then
						v7[notificationFrame] = StartStickerAnimation(stickerIcon, stickerScale)
					end
				end)
			end)
		end)
	end

	RepositionNotifications()
	task.delay(result.NOTIFICATION_DURATION, function()
		if notificationFrame and notificationFrame.Parent then
			spr.target(notificationFrame, 0.3, 1, {
				Position = UDim2.new(0, placementConfig.slideOut, 0, notificationFrame.Position.Y.Offset)
			})
			task.delay(0.25, function()
				if notificationFrame and notificationFrame.Parent then
					if v7[notificationFrame] then
						pcall(v7[notificationFrame])
						v7[notificationFrame] = nil
					end

					RemoveNotification(notificationFrame)
					notificationFrame:Destroy()
				end
			end)
		end
	end)
	return notificationFrame
end

function StickerNotificationUI.ShowSystemNotification(data)
	if type(data) ~= "table" or type(data.text) ~= "string" then
		warn("[StickerNotificationUI] ShowSystemNotification needs a table with a text field")
		return nil
	end

	if result.SYSTEM_EVENTS_ENABLED then
		return StickerNotificationUI.ShowNotification(
			data.playerName or "",
			data.userId,
			data.icon or "",
			data.text,
			data.characterName
		)
	end

	return nil
end

function StickerNotificationUI.ClearAll()
	for _, v11 in ipairs(v4) do
		if not (v11 and v11.Parent) then
			continue
		end

		if v7[v11] then
			pcall(v7[v11])
			v7[v11] = nil
		end

		v11:Destroy()
	end

	v4 = {}
end

function StickerNotificationUI.MutePlayer(p)
	v5[p] = true
end

function StickerNotificationUI.UnmutePlayer(p)
	v5[p] = nil
end

function StickerNotificationUI.IsMuted(p)
	return v5[p] == true
end

function StickerNotificationUI.GetMutedPlayers()
	local result2 = {}

	for k in pairs(v5) do
		table.insert(result2, k)
	end

	return result2
end

function StickerNotificationUI.UnmuteAll()
	v5 = {}
end

function StickerNotificationUI.GetConfig()
	return result
end

function StickerNotificationUI.SetConfig(p, p2)
	if result[p] ~= nil then
		result[p] = p2

		if p == "PLACEMENT" then
			UpdateContainerPlacement() -- equivalent call inferred; original call site unknown
		end
	end
end

function StickerNotificationUI.ResetToDefaults()
	for k, v11 in pairs(v2) do
		result[k] = v11
	end

	UpdateContainerPlacement() -- equivalent call inferred; original call site unknown
	print("[StickerNotificationUI] Config reset to defaults")
end

function StickerNotificationUI.GetPlacementOptions()
	return v3
end

local function LoadPersistedSettings()
	local localPlayer = Players.LocalPlayer

	if not localPlayer then
		return
	end

	task.wait(0.5)
	local stickerChatPlacement = localPlayer:GetAttribute("StickerChatPlacement")

	if stickerChatPlacement and typeof(stickerChatPlacement) == "string" then
		result.PLACEMENT = stickerChatPlacement
	end

	local stickerChatShowPortrait = localPlayer:GetAttribute("StickerChatShowPortrait")

	if stickerChatShowPortrait ~= nil then
		result.SHOW_PORTRAIT = stickerChatShowPortrait
	end

	local stickerChatShowBackground = localPlayer:GetAttribute("StickerChatShowBackground")

	if stickerChatShowBackground ~= nil then
		result.SHOW_BACKGROUND = stickerChatShowBackground
	end

	local stickerChatShowIcon = localPlayer:GetAttribute("StickerChatShowIcon")

	if stickerChatShowIcon ~= nil then
		result.SHOW_STICKER_ICON = stickerChatShowIcon
	end

	local stickerChatDuration = localPlayer:GetAttribute("StickerChatDuration")

	if stickerChatDuration and typeof(stickerChatDuration) == "number" then
		result.NOTIFICATION_DURATION = stickerChatDuration
	end

	UpdateContainerPlacement() -- equivalent call inferred; original call site unknown
end

task.spawn(function()
	task.wait(1)
	EnsureUI()
	RefreshBlockedUsers()
	LoadPersistedSettings()

	while true do
		task.wait(30)
		RefreshBlockedUsers()
	end
end)
return StickerNotificationUI