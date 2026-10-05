local CollectionService = game:GetService("CollectionService")
local ContentProvider = game:GetService("ContentProvider")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientState = require(ReplicatedStorage.ClientState)
local Config = require(ReplicatedStorage:WaitForChild("Config"))

-- equivalent calls inferred from this helper; original call sites unknown
local function getTrophyImage()
	return Config.GetWinsIcon() or "rbxassetid://15540211845"
end

local WinsTrophyFlyEffect = {}
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer and localPlayer:WaitForChild("PlayerGui")
local v = nil
local v2 = nil
local v3 = 0
local v4 = 1
local total = 1
local v5 = 0
local count = 0
local heartbeatConnection = nil
local random = Random.new()
local sound = Instance.new("Sound")
sound.Name = "WinsTrophyArrivalTemplate"
sound.SoundId = "rbxassetid://123722118372704"
sound.Volume = 0.2
sound.RollOffMaxDistance = 0
sound.Parent = SoundService

local function ensureArrivalSoundLoaded()
	if not sound.IsLoaded then
		pcall(function()
			ContentProvider:PreloadAsync({ sound })
		end)

		if not sound.IsLoaded then
			sound.Loaded:Wait()
		end
	end
end

task.spawn(ensureArrivalSoundLoaded)

local function updatePlaybackSpeed(p: number)
	if v5 == 0 then
		v4 = math.max(1, v4 - p * 0.3)
	end

	local v6 = math.min(1, p * 6)
	total += (v4 - total) * v6
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ensurePlaybackSpeedUpdater()
	if not heartbeatConnection then
		heartbeatConnection = RunService.Heartbeat:Connect(updatePlaybackSpeed)
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getOverlay()
	if v and v.Parent then
		return v
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "WinsTrophyFly"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 20
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = playerGui
	v = screenGui
	return screenGui
end

local function getWinsFlyTarget()
	for _, guiObject in ipairs(CollectionService:GetTagged("WinsFlyTarget")) do
		if guiObject:IsA("GuiObject") and guiObject:IsDescendantOf(playerGui) then
			return guiObject
		end
	end

	return nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getGuiCenter(p)
	return p.AbsolutePosition + p.AbsoluteSize / 2 + GuiService:GetGuiInset()
end

local function randomSpawnPosition()
	local v6 = 0.5 + random:NextNumber(-1, 1) * 0.4
	local v7 = 0.5 + random:NextNumber(-1, 1) * 0.4
	return UDim2.new(v6, random:NextInteger(-50, 50), v7, random:NextInteger(-40, 40))
end

local function getSpawnCount(p: number)
	if p > 20 then
		p = math.max(p * 0.25, 20)
	end

	return (math.clamp(math.floor(p), 1, 200))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getSizeScale(p: number)
	if p <= 200 then
		return 1
	end

	return (math.min((p - 200) / 150000 + 1, 1.25))
end

local function ensureBaseSize(instance)
	if instance:GetAttribute("WinsTrophyBaseCaptured") then
		return UDim2.new(
			instance:GetAttribute("WinsTrophyBaseSX"),
			instance:GetAttribute("WinsTrophyBaseOX"),
			instance:GetAttribute("WinsTrophyBaseSY"),
			(instance:GetAttribute("WinsTrophyBaseOY"))
		)
	end

	local size = instance.Size
	instance:SetAttribute("WinsTrophyBaseSX", size.X.Scale)
	instance:SetAttribute("WinsTrophyBaseOX", size.X.Offset)
	instance:SetAttribute("WinsTrophyBaseSY", size.Y.Scale)
	instance:SetAttribute("WinsTrophyBaseOY", size.Y.Offset)
	instance:SetAttribute("WinsTrophyBaseCaptured", true)
	return size
end

local function multiplySize(udim: UDim2, p: number)
	return UDim2.new(udim.X.Scale * p, udim.X.Offset * p, udim.Y.Scale * p, udim.Y.Offset * p)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function sizeFactor(size: UDim2, baseSize: UDim2)
	if baseSize.X.Offset > 0 and size.X.Offset > 0 then
		return size.X.Offset / baseSize.X.Offset
	end

	if baseSize.X.Scale > 0 and size.X.Scale > 0 then
		return size.X.Scale / baseSize.X.Scale
	end

	return 1
end

local function pulseWinsFlyTarget(winsFlyTarget)
	local baseSize = ensureBaseSize(winsFlyTarget)

	if v2 then
		v2:Cancel()
		v2 = nil
	end

	local v6 = sizeFactor(winsFlyTarget.Size, baseSize) -- equivalent call inferred; original call site unknown
	local v7 = math.min(v6 + 0.12, 4.5)
	winsFlyTarget.Size = UDim2.new(
		baseSize.X.Scale * v7,
		baseSize.X.Offset * v7,
		baseSize.Y.Scale * v7,
		baseSize.Y.Offset * v7
	)
	winsFlyTarget.Rotation = random:NextNumber(-20, 20)
	local tween = TweenService:Create(
		winsFlyTarget,
		TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
		{
			Size = baseSize
		}
	)
	local tween2 = TweenService:Create(
		winsFlyTarget,
		TweenInfo.new(0.4, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
		{
			Rotation = 0
		}
	)
	v2 = tween
	tween.Completed:Connect(function()
		if v2 == tween then
			v2 = nil
		end
	end)
	tween:Play()
	tween2:Play()
end

local function playArrivalSound()
	local now = tick()

	if now - v3 >= 0.01 then
		v3 = now
		v4 = math.min(1.5, v4 + 0.01)
		local clone = sound:Clone()
		clone.PlaybackSpeed = total + random:NextNumber(-0.05, 0.05)
		clone.Parent = SoundService
		clone:Play()
		clone.Ended:Connect(function()
			clone:Destroy()
		end)
	end
end

local function spawnFlyingTrophy(zIndex: number, p: number, point: Vector2)
	local overlay = getOverlay() -- equivalent call inferred; original call site unknown
	local v6 = p * 44
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "FlyTrophy"
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Rotation = random:NextNumber(-60, 60)
	imageLabel.Position = randomSpawnPosition()
	imageLabel.Size = UDim2.fromOffset(v6, v6)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = getTrophyImage()
	imageLabel.ImageTransparency = 1
	imageLabel.ZIndex = zIndex
	imageLabel.Parent = overlay
	local tween = TweenService:Create(
		imageLabel,
		TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{
			ImageTransparency = 0
		}
	)
	tween.Completed:Once(function(p2)
		if p2 == Enum.PlaybackState.Completed then
			TweenService:Create(imageLabel, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				ImageTransparency = 0.25,
				Size = UDim2.fromOffset(v6 / 2, v6 / 2)
			}):Play()
		end
	end)
	tween:Play()
	task.delay(0.3, function()
		if imageLabel.Parent then
			local tween2 = TweenService:Create(
				imageLabel,
				TweenInfo.new(1.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
				{
					Position = UDim2.fromOffset(point.X, point.Y),
					Rotation = 0,
					ImageTransparency = 0,
					Size = UDim2.fromOffset(v6, v6)
				}
			)
			tween2.Completed:Connect(function()
				playArrivalSound()
				local winsFlyTarget = getWinsFlyTarget()

				if winsFlyTarget then
					pulseWinsFlyTarget(winsFlyTarget)
				end

				if imageLabel.Parent then
					imageLabel:Destroy()
				end
			end)
			tween2:Play()
		end
	end)
end

local function runSpawnLoop(p: number, p2: number, p3: number)
	for i = 1, p2 do
		local v6 = count == p and ClientState.WinsTrophyAnimationsEnabled ~= false and getWinsFlyTarget()

		if not v6 then
			break
		end

		spawnFlyingTrophy(i, p3, getGuiCenter(v6))

		if i < p2 then
			task.wait(0.02)
		end
	end

	v5 = math.max(0, v5 - 1)
end

local function runFlyingTrophies(p: number)
	local v6 = tonumber(p) or 0
	local winsFlyTarget = getWinsFlyTarget()

	if v6 > 0 and winsFlyTarget then
		local v7

		if v6 > 20 then
			v7 = math.max(v6 * 0.25, 20)
		else
			v7 = v6
		end

		local v8 = math.clamp(math.floor(v7), 1, 200)
		local sizeScale = getSizeScale(v6) -- equivalent call inferred; original call site unknown
		task.spawn(ensureArrivalSoundLoaded)
		ensurePlaybackSpeedUpdater() -- equivalent call inferred; original call site unknown
		v5 += 1
		local v9 = count
		task.spawn(runSpawnLoop, v9, v8, sizeScale)
	end
end

function WinsTrophyFlyEffect.clearOngoing()
	count += 1
	v5 = 0
	v4 = 1
	total = 1

	if v2 then
		v2:Cancel()
		v2 = nil
	end

	local winsFlyTarget = getWinsFlyTarget()

	if winsFlyTarget then
		winsFlyTarget.Size = ensureBaseSize(winsFlyTarget)
		winsFlyTarget.Rotation = 0
	end

	if v and v.Parent then
		for _, child in v:GetChildren() do
			if child.Name == "FlyTrophy" then
				child:Destroy()
			end
		end
	end

	for _, image in playerGui:GetDescendants() do
		if image:IsA("ImageLabel") and image.Name == "WinNotificationTrophy" then
			image:Destroy()
		end
	end
end

local function createNotificationTrophyIcon(parent)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "WinNotificationTrophy"
	imageLabel.Size = UDim2.new(0.15, 0, 0.9, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.Image = getTrophyImage()
	imageLabel.Rotation = -20
	imageLabel.Parent = parent
	Instance.new("UIAspectRatioConstraint", imageLabel)
	return imageLabel
end

local function tweenNotificationTrophyIn(notificationTrophyIcon)
	TweenService:Create(notificationTrophyIcon, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Rotation = 0
	}):Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function tweenNotificationTrophyOut(p, p2)
	TweenService:Create(p, p2, {
		ImageTransparency = 1
	}):Play()
end

function WinsTrophyFlyEffect.playWinEffects(p: number, parent)
	if ClientState.WinsTrophyAnimationsEnabled == false then
		return nil
	end

	runFlyingTrophies(p)

	if not parent then
		return nil
	end

	local notificationTrophyIcon = createNotificationTrophyIcon(parent)
	tweenNotificationTrophyIn(notificationTrophyIcon)
	return notificationTrophyIcon
end

function WinsTrophyFlyEffect.fadeNotificationIcon(p, p2)
	if p then
		tweenNotificationTrophyOut(p, p2) -- equivalent call inferred; original call site unknown
	end
end

return WinsTrophyFlyEffect