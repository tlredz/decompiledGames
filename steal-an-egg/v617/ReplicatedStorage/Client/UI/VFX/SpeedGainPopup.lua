local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Audio = require(ReplicatedStorage.Shared.Audio)
local GUI = require(ReplicatedStorage.Client.GUI)
local Player = require(ReplicatedStorage.Shared.Player)
local TreadmillUtil = require(ReplicatedStorage.Shared.Util.TreadmillUtil)
local v = {
	popInfo = TweenInfo.new(0.28, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out),
	popFromScale = 0.7,
	pulseSeconds = 0.25,
	pulsePeak = 1.06,
	pulseOutInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	pulseInInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
}
local v2 = {
	growInfo = TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	riseInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	fadeInfo = TweenInfo.new(0.3),
	fadeDelay = 0.5,
	clearDelay = 0.35,
	icon = "rbxassetid://78137530993637",
	sink = createVector(0, -1, 0),
	baseTint = Color3.fromRGB(178, 233, 255),
	tintLadder = {
		{
			from = 100,
			isInclusive = true,
			tint = Color3.fromRGB(255, 0, 0)
		},
		{
			from = 25,
			isInclusive = true,
			tint = Color3.fromRGB(255, 67, 199)
		},
		{
			from = 9,
			isInclusive = true,
			tint = Color3.fromRGB(0, 255, 255)
		},
		{
			from = 1,
			isInclusive = false,
			tint = Color3.fromRGB(255, 238, 0)
		}
	}
}
local v3 = {
	seconds = 0.85,
	fadeStart = 0.72,
	startScale = 0.72,
	scaleWave = 0.18,
	lift = NumberRange.new(100, 150),
	bend = NumberRange.new(90, 120),
	touchDivisor = 2.5,
	launchXFraction = 0.25,
	cloneName = "SpeedGainPopup",
	spawnSoundId = nil,
	landingSoundId = nil,
	playbackSpeed = 1
}
local v4 = {
	TextLabel = "TextTransparency",
	ImageLabel = "ImageTransparency",
	UIStroke = "Transparency"
}
local SpeedGainPopup = {}
local localPlayer = Players.LocalPlayer
local random = Random.new()
local v5 = {}

local function build(className: string, items, parent)
	local instance = Instance.new(className)

	for k, item in items do
		instance[k] = item
	end

	instance.Parent = parent
	return instance
end

-- equivalent calls inferred from this helper; original call sites unknown
local function scaleFor(parent)
	local uIScale = parent:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	uIScale.Parent = parent
	return uIScale
end

local function headlineScale(p)
	local parent = p.Parent

	if parent == nil or not parent:IsA("GuiObject") then
		return nil
	end

	return scaleFor(parent)
end

local function popHeadline(p)
	local parent = p.Parent
	local uIScale

	if not (parent == nil or not parent:IsA("GuiObject")) then
		uIScale = parent:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
		uIScale.Parent = parent
	end

	if uIScale ~= nil then
		uIScale.Scale = v.popFromScale
		TweenService:Create(uIScale, v.popInfo, {
			Scale = 1
		}):Play()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function paintAlpha(folder, p: number)
	for _, descendant in folder:GetDescendants() do
		local v6 = v4[descendant.ClassName]

		if v6 ~= nil then
			descendant[v6] = p
		end
	end
end

local function ladderTint(p: number)
	for _, v6 in v2.tintLadder do
		if v6.isInclusive and v6.from <= p or v6.from < p then
			return v6.tint
		end
	end

	return v2.baseTint
end

-- equivalent calls inferred from this helper; original call sites unknown
local function spread(lift: NumberRange, p: number)
	return random:NextNumber(lift.Min * p, lift.Max * p)
end

local function arcSampler(point: Vector2, point2: Vector2)
	local v6 = not UserInputService.TouchEnabled and 1 or 1 / v3.touchDivisor
	local bend = v3.bend
	local v7 = random:NextNumber(bend.Min * v6, bend.Max * v6) * (point2.X >= point.X and -1 or 1)
	local v8 = spread(v3.lift, v6) -- equivalent call inferred; original call site unknown
	local v9 = (point + point2) * 0.5 + Vector2.new(v7, -v8)
	return function(p: number)
		local v10 = 1 - p
		return point * (v10 * v10) + v9 * (v10 * 2 * p) + point2 * (p * p)
	end
end

local function raiseBadge(p, text: string, value: number?, color: Color3?, callback)
	local rootPart = Player.FindRootPart(localPlayer)

	if rootPart == nil then
		return
	end

	local v6 = {
		AlwaysOnTop = true,
		Adornee = rootPart,
		Name = "PlusOne",
		Size = UDim2.new(4.5, 0, 1.5, 0),
		StudsOffset = createVector(0, 1, 0)
	}
	local playerGui = GUI.PlayerGui()
	local billboardGui = Instance.new("BillboardGui")

	for k, v7 in v6 do
		billboardGui[k] = v7
	end

	billboardGui.Parent = playerGui
	local v7 = {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 0, 0, 0)
	}
	local frame = Instance.new("Frame")

	for k, v8 in v7 do
		frame[k] = v8
	end

	frame.Parent = billboardGui
	local v8 = {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = UDim.new(0.05, 0),
		VerticalAlignment = Enum.VerticalAlignment.Center
	}
	local uIListLayout = Instance.new("UIListLayout")

	for k, v9 in v8 do
		uIListLayout[k] = v9
	end

	uIListLayout.Parent = frame
	local v9 = {
		BackgroundTransparency = 1,
		Image = v2.icon,
		Size = UDim2.new(0.3, 0, 0.8, 0)
	}
	local imageLabel = Instance.new("ImageLabel")

	for k, v10 in v9 do
		imageLabel[k] = v10
	end

	imageLabel.Parent = frame
	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")

	for k, v10 in {
		AspectRatio = 1
	} do
		uIAspectRatioConstraint[k] = v10
	end

	uIAspectRatioConstraint.Parent = imageLabel
	local v10 = {
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBlack,
		Size = UDim2.new(0.6, 0, 0.9, 0),
		Text = text,
		TextColor3 = color or ladderTint(value or 1),
		TextScaled = true
	}
	local textLabel = Instance.new("TextLabel")

	for k, v11 in v10 do
		textLabel[k] = v11
	end

	textLabel.Parent = frame
	local uIStroke = Instance.new("UIStroke")

	for k, v11 in {
		Thickness = 2
	} do
		uIStroke[k] = v11
	end

	uIStroke.Parent = textLabel
	local vector2 = Vector3.new(random:NextInteger(-4, 4), random:NextInteger(3, 5), random:NextInteger(-2, 2))
	TweenService:Create(frame, v2.growInfo, {
		Size = UDim2.new(1, 0, 1, 0)
	}):Play()
	TweenService:Create(billboardGui, v2.riseInfo, {
		StudsOffset = vector2
	}):Play()

	if callback ~= nil then
		callback()
	end

	task.delay(v2.fadeDelay, function()
		for _, v11 in {
			{
				textLabel,
				{
					TextTransparency = 1
				}
			},
			{
				imageLabel,
				{
					ImageTransparency = 1
				}
			},
			{
				uIStroke,
				{
					Transparency = 1
				}
			},
			{
				billboardGui,
				{
					StudsOffset = vector2 + v2.sink
				}
			}
		} do
			TweenService:Create(v11[1], v2.fadeInfo, v11[2]):Play()
		end

		task.delay(v2.clearDelay, function()
			popHeadline(p)
			billboardGui:Destroy()
		end)
	end)
end

local function flyToHeadline(p, p2: number, text: string, point: Vector2?, callback)
	local function finish()
		if callback ~= nil then
			callback()
		end
	end

	local currentCamera = workspace.CurrentCamera

	if p2 <= 0 or currentCamera == nil then
		if callback ~= nil then
			callback()
		end
	else
		local screenGui = GUI.SpeedGainAnimation()
		assert(screenGui:IsA("ScreenGui"), "speed gain host is not a ScreenGui")
		local frame = screenGui.Frame
		assert(frame:IsA("Frame"), "speed gain host is missing its Frame template")
		local clone = frame:Clone()
		clone.Name = v3.cloneName
		clone.Visible = true
		clone.AnchorPoint = Vector2.new(0.5, 0.5)
		local currentBoost = clone.CurrentBoost
		assert(currentBoost:IsA("TextLabel"), "speed gain template has no CurrentBoost label")
		local uIScale = scaleFor(currentBoost) -- equivalent call inferred; original call site unknown
		currentBoost.Text = text
		uIScale.Scale = v3.startScale
		local viewportSize = currentCamera.ViewportSize
		local v7 = point or Vector2.new(viewportSize.X * v3.launchXFraction, viewportSize.Y)
		local v8 = arcSampler(v7, p.AbsolutePosition + p.AbsoluteSize * 0.5)
		clone.Position = UDim2.fromOffset(v7.X, v7.Y)
		clone.Parent = screenGui
		paintAlpha(clone, 0) -- equivalent call inferred; original call site unknown

		if v3.spawnSoundId then
			Audio.Play(v3.spawnSoundId, script, {
				PlaybackSpeed = v3.playbackSpeed
			})
		end

		local lastTime = os.clock()
		local v9 = 0

		while v9 < 1 and clone.Parent ~= nil do
			v9 = math.min((os.clock() - lastTime) / v3.seconds, 1)
			local v10 = v8(v9)
			clone.Position = UDim2.fromOffset(v10.X, v10.Y)
			uIScale.Scale = v3.startScale + math.sin(v9 * 3.141592653589793) * v3.scaleWave
			paintAlpha(clone, math.clamp((v9 - v3.fadeStart) / (1 - v3.fadeStart), 0, 1)) -- equivalent call inferred; original call site unknown
			RunService.RenderStepped:Wait()
		end

		if clone.Parent ~= nil then
			if v3.landingSoundId then
				Audio.Play(v3.landingSoundId, script)
			end

			popHeadline(p)
			clone:Destroy()
		end

		if callback ~= nil then
			callback()
		end
	end
end

function SpeedGainPopup.PlayWalk(p, p2: number, color: Color3?, callback)
	SpeedGainPopup.ShowGainBadge(p, p2, color, callback)
end

function SpeedGainPopup.ShowGainBadge(p, p2: number, color: Color3?, callback)
	if p2 <= 0 then
		if callback ~= nil then
			callback()
		end
	else
		raiseBadge(p, "+" .. TreadmillUtil.FormatSpeedPower((math.round(p2))), p2, color, callback)
	end
end

function SpeedGainPopup.Play(p, p2: number, point: Vector2?, callback)
	flyToHeadline(p, p2, "+" .. TreadmillUtil.FormatSpeedPower(p2) .. " Speed", point, callback)
end

function SpeedGainPopup.SetHeadlinePulsing(p, isActive: boolean)
	local parent = p.Parent
	local uIScale

	if parent == nil or not parent:IsA("GuiObject") then
		uIScale = nil
	else
		uIScale = parent:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
		uIScale.Parent = parent
	end

	if uIScale == nil then
		return
	end

	local v6 = v5[uIScale]

	if v6 ~= nil and v6.isActive == isActive then
		return
	end

	local token = (not v6 and 0 or v6.token) + 1
	v5[uIScale] = {
		isActive = isActive,
		token = token
	}

	if isActive then
		task.spawn(function()
			local function isStillOurs()
				local v8 = v5[uIScale]
				return v8 ~= nil and v8.token == token and uIScale:IsDescendantOf(game)
			end

			local v8 = {
				{
					info = v.pulseOutInfo,
					scale = v.pulsePeak
				},
				{
					info = v.pulseInInfo,
					scale = 1
				}
			}

			while true do
				local v9 = v5[uIScale]
				local v10

				if v9 == nil or v9.token ~= token then
					v10 = false
				else
					v10 = uIScale:IsDescendantOf(game)
				end

				if not v10 then
					break
				end

				for _, v11 in v8 do
					local v12 = v5[uIScale]
					local v13

					if v12 == nil or v12.token ~= token then
						v13 = false
					else
						v13 = uIScale:IsDescendantOf(game)
					end

					if not v13 then
						return
					end

					TweenService:Create(uIScale, v11.info, {
						Scale = v11.scale
					}):Play()
					task.wait(v.pulseSeconds)
				end
			end
		end)
	else
		TweenService:Create(uIScale, v.pulseInInfo, {
			Scale = 1
		}):Play()
	end
end

function SpeedGainPopup.HideSource()
	local screenGui = GUI.SpeedGainAnimation()
	assert(screenGui:IsA("ScreenGui"), "speed gain host is not a ScreenGui")
	local frame = screenGui.Frame
	assert(frame:IsA("Frame"), "speed gain host is missing its Frame template")
	frame.Visible = false
end

return SpeedGainPopup