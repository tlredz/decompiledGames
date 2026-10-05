local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local ItemRewardUISystem = {}

if not RunService:IsClient() then
	return ItemRewardUISystem
end

local BadgeInfoCache = require(ReplicatedStorage._FRAMEWORK.Libraries.BadgeInfoCache)
local Items = require(ReplicatedStorage:WaitForChild("FeatureConfigs"):WaitForChild("Items"))
local emphasizedStar = ReplicatedStorage:WaitForChild("Templates"):WaitForChild("EmphasizedStar")
local v = {}
local onQueueProcesseds = {}
local v2 = false
local v3 = false
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local rewardGui = playerGui:WaitForChild("RewardGui", 60)
local itemReward = rewardGui.ItemReward
local badgeReward = rewardGui.BadgeReward

local function captureView(root, nameLabel, tierFrame)
	local iconWrap = root.IconWrap
	local glowTexture = iconWrap.GlowTexture
	local position = root.Position
	return {
		root = root,
		iconWrap = iconWrap,
		topText = root.TopText,
		glow = iconWrap.Glow,
		glowTexture = glowTexture,
		shine = iconWrap.Shine,
		icon = iconWrap.Icon,
		nameLabel = nameLabel,
		tierFrame = tierFrame,
		restRootPosition = position,
		offBottomPosition = UDim2.new(position.X.Scale, 0, 1.3, 0),
		restIconWrapSize = iconWrap.Size,
		restGlowTextureSize = glowTexture.Size
	}
end

local view2 = captureView(itemReward, itemReward.IconWrap.ItemName, itemReward.IconWrap.TierFrame)
local view3 = captureView(badgeReward, badgeReward.IconWrap.BadgeName, nil)

-- equivalent calls inferred from this helper; original call sites unknown
local function bindSkip(p)
	p.Visible = false
	p.Active = true
	p.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			v3 = true
		end
	end)
end

bindSkip(itemReward) -- equivalent call inferred; original call site unknown
bindSkip(badgeReward) -- equivalent call inferred; original call site unknown
UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.ButtonA then
		v3 = true
	end
end)
local sound = Instance.new("Sound")
sound.Name = "ItemRewardSoundTemplate"
sound.SoundId = "rbxassetid://113890702074571"
sound.Volume = 3
sound.RollOffMaxDistance = 10
sound.Parent = SoundService
local sound2 = Instance.new("Sound")
sound2.Name = "ItemRewardSweepOutSoundTemplate"
sound2.SoundId = "rbxassetid://93030066468333"
sound2.Volume = 2
sound2.RollOffMaxDistance = 10
sound2.Parent = SoundService

-- equivalent calls inferred from this helper; original call sites unknown
local function ensureSoundLoaded(p)
	if not p.IsLoaded then
		pcall(function()
			ContentProvider:PreloadAsync({ p })
		end)

		if not p.IsLoaded then
			p.Loaded:Wait()
		end
	end
end

task.spawn(function()
	ensureSoundLoaded(sound) -- equivalent call inferred; original call site unknown
	ensureSoundLoaded(sound2) -- equivalent call inferred; original call site unknown
end)

-- equivalent calls inferred from this helper; original call sites unknown
local function playSoundTemplate(sound3)
	local clone = sound3:Clone()
	clone.Parent = SoundService
	clone:Play()
	clone.Ended:Connect(function()
		clone:Destroy()
	end)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playRewardSound()
	playSoundTemplate(sound) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function playSweepOutSound()
	playSoundTemplate(sound2) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startShineLoop(uIGradient, uIGradient2, uIGradient3)
	if uIGradient or uIGradient2 or uIGradient3 then
		local total = 0
		return RunService.RenderStepped:Connect(function(dt)
			total += dt

			if uIGradient then
				uIGradient.Rotation = total * 110 % 360
			end

			if uIGradient3 then
				uIGradient3.Rotation = total * -80 % 360
			end

			if uIGradient2 then
				uIGradient2.Offset = Vector2.new(total * 1.4 % 2 - 1, total * 0.35 % 2 - 1)
			end
		end)
	else
		return nil
	end
end

local function multiplySize(udim: UDim2, p: number)
	return UDim2.new(udim.X.Scale * p, udim.X.Offset * p, udim.Y.Scale * p, udim.Y.Offset * p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function startGlowTextureLoop(data)
	local total = 0
	return RunService.RenderStepped:Connect(function(dt)
		total += dt
		data.glowTexture.Rotation = total * 48 % 360
		local v6 = math.sin(total * 1.5) * 0.5 + 0.5
		data.glowTexture.ImageTransparency = v6 * 0.33999999999999997 + 0.08
		local v7 = v6 * 0.2400000000000001 + 0.88
		local glowTexture = data.glowTexture
		local restGlowTextureSize = data.restGlowTextureSize
		glowTexture.Size = UDim2.new(
			restGlowTextureSize.X.Scale * v7,
			restGlowTextureSize.X.Offset * v7,
			restGlowTextureSize.Y.Scale * v7,
			restGlowTextureSize.Y.Offset * v7
		)
	end)
end

local function setTransparency(guiObject, p: number)
	if guiObject:IsA("ImageLabel") or guiObject:IsA("ImageButton") then
		guiObject.ImageTransparency = p
	elseif guiObject:IsA("TextLabel") or guiObject:IsA("TextButton") then
		guiObject.TextTransparency = p
	elseif guiObject:IsA("Frame") then
		guiObject.BackgroundTransparency = p
	end

	local uIStroke = guiObject:FindFirstChildOfClass("UIStroke")

	if uIStroke then
		uIStroke.Transparency = p
	end
end

local function prepareHidden(data)
	data.root.Position = data.restRootPosition
	data.root.Visible = true
	data.iconWrap.Size = UDim2.fromScale(0, 0)
	data.icon.ImageTransparency = 1
	data.glow.BackgroundTransparency = 1
	data.glowTexture.ImageTransparency = 1
	data.glowTexture.Rotation = 0
	data.glowTexture.Size = data.restGlowTextureSize
	data.shine.BackgroundTransparency = 1
	setTransparency(data.nameLabel, 1)
	setTransparency(data.topText, 1)
end

local function fillStars(tierFrame, emphasizedStar2, p)
	local layoutContainer = tierFrame.LayoutContainer

	for _, guiObject in ipairs(layoutContainer:GetChildren()) do
		if guiObject:IsA("GuiObject") then
			guiObject:Destroy()
		end
	end

	for _ = 1, p do
		local clone = emphasizedStar2:Clone()
		clone.Visible = true
		clone.Parent = layoutContainer
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyTopText(p, p2)
	local topText = p2.topText

	if type(topText) ~= "string" or topText == "" then
		p.topText.Visible = false
		return
	end

	p.topText.Text = topText
	p.topText.Visible = true
end

local function applyItemContent(view, data)
	view.nameLabel.Text = data.itemName or "Item"
	view.nameLabel.TextColor3 = data.nameColor or Color3.fromRGB(255, 255, 255)
	view.icon.Image = data.icon or ""
	local v6 = math.clamp(math.floor(data.tier or 0), 0, Items.MAX_TIER)
	fillStars(view.tierFrame, emphasizedStar, v6)
	applyTopText(view, data) -- equivalent call inferred; original call site unknown
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyBadgeContent(view, p, async)
	view.nameLabel.Text = async.Name
	view.nameLabel.TextColor3 = p.nameColor or Color3.fromRGB(255, 255, 255)
	view.icon.Image = "rbxassetid://" .. async.IconImageId
	applyTopText(view, p) -- equivalent call inferred; original call site unknown
end

local function tweenFadeIn(data, tweenInfo, uIStroke, uIStroke2)
	TweenService:Create(data.iconWrap, TweenInfo.new(1.35, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
		Size = data.restIconWrapSize
	}):Play()
	TweenService:Create(data.icon, tweenInfo, {
		ImageTransparency = 0
	}):Play()
	TweenService:Create(data.glow, tweenInfo, {
		BackgroundTransparency = 0.25
	}):Play()
	TweenService:Create(data.glowTexture, tweenInfo, {
		ImageTransparency = 0.08
	}):Play()
	TweenService:Create(data.shine, tweenInfo, {
		BackgroundTransparency = 0
	}):Play()
	TweenService:Create(data.nameLabel, tweenInfo, {
		TextTransparency = 0
	}):Play()

	if uIStroke then
		TweenService:Create(uIStroke, tweenInfo, {
			Transparency = 0
		}):Play()
	end

	if data.topText.Visible then
		TweenService:Create(data.topText, tweenInfo, {
			TextTransparency = 0
		}):Play()

		if uIStroke2 then
			TweenService:Create(uIStroke2, tweenInfo, {
				Transparency = 0
			}):Play()
		end
	end
end

local function tweenFadeOut(data, tweenInfo, uIStroke, uIStroke2)
	TweenService:Create(data.root, tweenInfo, {
		Position = data.offBottomPosition
	}):Play()
	TweenService:Create(data.icon, tweenInfo, {
		ImageTransparency = 1
	}):Play()
	TweenService:Create(data.glow, tweenInfo, {
		BackgroundTransparency = 1
	}):Play()
	TweenService:Create(data.glowTexture, tweenInfo, {
		ImageTransparency = 1,
		Size = data.restGlowTextureSize
	}):Play()
	TweenService:Create(data.shine, tweenInfo, {
		BackgroundTransparency = 1
	}):Play()
	TweenService:Create(data.nameLabel, tweenInfo, {
		TextTransparency = 1
	}):Play()

	if uIStroke then
		TweenService:Create(uIStroke, tweenInfo, {
			Transparency = 1
		}):Play()
	end

	if data.topText.Visible then
		TweenService:Create(data.topText, tweenInfo, {
			TextTransparency = 1
		}):Play()

		if uIStroke2 then
			TweenService:Create(uIStroke2, tweenInfo, {
				Transparency = 1
			}):Play()
		end
	end
end

local function presentResolved(view, p)
	prepareHidden(view)
	local uIGradient = view.icon:FindFirstChildOfClass("UIGradient")
	local uIGradient2 = view.shine:FindFirstChildOfClass("UIGradient")
	local uIGradient3 = view.glow:FindFirstChildOfClass("UIGradient")
	local uIStroke = view.nameLabel:FindFirstChildOfClass("UIStroke")
	local uIStroke2 = view.topText:FindFirstChildOfClass("UIStroke")
	local connection = startShineLoop(uIGradient, uIGradient2, uIGradient3) -- equivalent call inferred; original call site unknown
	local tweenInfo = TweenInfo.new(1.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	v3 = false
	playRewardSound() -- equivalent call inferred; original call site unknown
	tweenFadeIn(view, tweenInfo, uIStroke, uIStroke2)
	local connection2 = startGlowTextureLoop(view) -- equivalent call inferred; original call site unknown
	local v6 = os.clock() + (p.expiry or 4.85)

	while os.clock() < v6 and not v3 do
		task.wait()
	end

	if view.root.Parent then
		local tweenInfo2 = TweenInfo.new(0.85, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		playSweepOutSound() -- equivalent call inferred; original call site unknown
		tweenFadeOut(view, tweenInfo2, uIStroke, uIStroke2)
		task.wait(0.85)
		view.root.Visible = false
		view.root.Position = view.restRootPosition
	end

	if connection then
		connection:Disconnect()
	end

	if connection2 then
		connection2:Disconnect()
	end

	task.wait(0.1)
end

local function runPresentation(p)
	local view = p.view

	if p.badgeId then
		local async = BadgeInfoCache.GetAsync(p.badgeId)

		if async then
			applyBadgeContent(view, p, async) -- equivalent call inferred; original call site unknown
			presentResolved(view, p)
		end
	else
		applyItemContent(view, p)
		presentResolved(view, p)
	end
end

local function processQueue()
	if not v2 then
		v2 = true

		while #v > 0 do
			runPresentation(table.remove(v, 1))
		end

		v2 = false
		local v6 = onQueueProcesseds
		onQueueProcesseds = {}

		for _, v7 in v6 do
			v7()
		end
	end
end

function ItemRewardUISystem.playBootSound()
	playRewardSound() -- equivalent call inferred; original call site unknown
end

function ItemRewardUISystem.play(options)
	local v6 = options or {}

	if v6.view == nil then
		v6.view = view2
	end

	table.insert(v, v6)
	local onQueueProcessed = v6.onQueueProcessed

	if onQueueProcessed then
		table.insert(onQueueProcesseds, onQueueProcessed)
	end

	if not v2 then
		task.spawn(processQueue)
	end
end

function ItemRewardUISystem.playForItemKey(p: string, topText: string?, value: number?, expiry: number?, onQueueProcessed)
	local v6 = Items.ITEMS[p]

	if v6 then
		ItemRewardUISystem.play({
			view = view2,
			icon = v6.icon,
			itemName = v6.name,
			topText = topText,
			nameColor = Items.RARITY_COLORS[v6.rarity],
			tier = value or 0,
			expiry = expiry,
			onQueueProcessed = onQueueProcessed
		})
	elseif onQueueProcessed then
		table.insert(onQueueProcesseds, onQueueProcessed)

		if not v2 then
			task.spawn(processQueue)
		end
	end
end

function ItemRewardUISystem.playForBadge(badgeId: number, value: string?, expiry: number?, onQueueProcessed)
	ItemRewardUISystem.play({
		view = view3,
		badgeId = badgeId,
		topText = value or "BADGE AWARDED!",
		expiry = expiry,
		onQueueProcessed = onQueueProcessed
	})
end

ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ItemAction").OnClientEvent:Connect(function(p, data)
	if p == "ItemReward" and type(data) == "table" and type(data.Key) == "string" then
		task.spawn(function()
			while playerGui:FindFirstChild("Loading") do
				task.wait(0.2)
			end

			task.wait(0.3)
			ItemRewardUISystem.playForItemKey(data.Key, data.TopText, data.Tier, data.Expiry)
		end)
	end
end)
return ItemRewardUISystem