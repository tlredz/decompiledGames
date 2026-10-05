local createVector = vector.create
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local GUI = require(ReplicatedStorage.Client.GUI)
local HiddenUIHandler = require(ReplicatedStorage.Client.HiddenUIHandler)
local LightVsDarkness = require(ReplicatedStorage.Data.LightVsDarkness)
local Remotes = require(ReplicatedStorage.Shared.Remotes)
require(ReplicatedStorage.Packages.Trove)
local color = Color3.fromRGB(255, 245, 190)
local color2 = Color3.fromRGB(255, 150, 150)
local color3 = Color3.fromRGB(85, 85, 85)
local color4 = Color3.fromRGB(71, 255, 0)
local uDim = UDim2.fromScale(1.03563285, 1.58552635)
local uDim2 = UDim2.fromScale(-0.470256448, 1.16447556)
local uDim3 = UDim2.fromScale(1.13319373, 1.7348907)
local uDim4 = UDim2.fromScale(-0.519036949, 1.16447568)
local tweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(0.34, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo3 = TweenInfo.new(0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local tweenInfo4 = TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local vector2 = Vector2.new(12, 8)
local back = Enum.EasingStyle.Back
local v = Enum.EasingDirection.In
local vector3 = Vector2.new(14, 10)
local localPlayer = Players.LocalPlayer
local v2 = nil
local v3 = nil
local v4 = nil
local flag = false
local v5 = 0
local v6 = 0
local v7 = 0
local v8 = 0
local v9 = 0
local v10 = -1
local v11 = -1
local total = 0
local v12 = ""
local v13 = 0.5
local v14 = 0.5
local v15 = 0
local total2 = 0
local v16 = 0
local v17 = 0.5
local v18 = 0
local v19 = 0
local v20 = {
	p = 0,
	v = 0
}
local v21 = {
	p = 0,
	v = 0
}
local v22 = {
	p = 0,
	v = 0
}
local v23 = 0
local v24 = ""
local v25 = false
local v26 = false
local v27 = nil
local v28 = false
local v29 = {}
local v30 = nil
local v31 = nil
local random = Random.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function spring()
	return {
		p = 0,
		v = 0
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stepSpring(state, p: number)
	state.v += (state.p * -260 - state.v * 14) * p
	state.p += state.v * p
end

local function uiChild(instance, childName: string, className: string)
	local child = instance:FindFirstChild(childName)
	assert(child and child:IsA(className), (`{instance:GetFullName()}.{childName} must be a {className}`))
	return child
end

local function resolveUi()
	local v32 = v2

	if v32 then
		return v32
	end

	local screenGui = GUI.LightVsDarknessUI()
	assert(screenGui:IsA("ScreenGui"), "LightVsDarknessUI must be a ScreenGui")
	local scoreBar = screenGui:FindFirstChild("ScoreBar")
	assert(scoreBar and scoreBar:IsA("Frame"), (`{screenGui:GetFullName()}.ScoreBar must be a Frame`))
	local barHolder = scoreBar:FindFirstChild("BarHolder")
	assert(barHolder and barHolder:IsA("Frame"), (`{scoreBar:GetFullName()}.BarHolder must be a Frame`))
	local barBG = barHolder:FindFirstChild("BarBG")
	assert(barBG and barBG:IsA("GuiObject"), (`{barHolder:GetFullName()}.BarBG must be a GuiObject`))
	local lightBar = barBG:FindFirstChild("LightBar")
	assert(lightBar and lightBar:IsA("Frame"), (`{barBG:GetFullName()}.LightBar must be a Frame`))
	local darkBar = barBG:FindFirstChild("DarkBar")
	assert(darkBar and darkBar:IsA("Frame"), (`{barBG:GetFullName()}.DarkBar must be a Frame`))
	local vSIcon = barHolder:FindFirstChild("VSIcon")
	assert(vSIcon and vSIcon:IsA("ImageLabel"), (`{barHolder:GetFullName()}.VSIcon must be a ImageLabel`))
	local vSText = barHolder:FindFirstChild("VSText")
	assert(vSText and vSText:IsA("GuiObject"), (`{barHolder:GetFullName()}.VSText must be a GuiObject`))
	local lightAmount = scoreBar:FindFirstChild("LightAmount")
	assert(lightAmount and lightAmount:IsA("TextLabel"), (`{scoreBar:GetFullName()}.LightAmount must be a TextLabel`))
	local darknessAmount = scoreBar:FindFirstChild("DarknessAmount")
	assert(
		darknessAmount and darknessAmount:IsA("TextLabel"),
		(`{scoreBar:GetFullName()}.DarknessAmount must be a TextLabel`)
	)
	local barSpan = lightBar.Size.X.Scale + darkBar.Size.X.Scale
	local personalRingMilestone = screenGui:FindFirstChild("PersonalRingMilestone")
	assert(
		personalRingMilestone and personalRingMilestone:IsA("Frame"),
		(`{screenGui:GetFullName()}.PersonalRingMilestone must be a Frame`)
	)
	local progressBar = personalRingMilestone:FindFirstChild("ProgressBar")
	assert(
		progressBar and progressBar:IsA("Frame"),
		(`{personalRingMilestone:GetFullName()}.ProgressBar must be a Frame`)
	)
	local ringScoreHolder = personalRingMilestone:FindFirstChild("RingScoreHolder")
	assert(
		ringScoreHolder and ringScoreHolder:IsA("Frame"),
		(`{personalRingMilestone:GetFullName()}.RingScoreHolder must be a Frame`)
	)
	local ringScoreHolder2 = ringScoreHolder:FindFirstChild("RingScoreHolder")
	assert(
		ringScoreHolder2 and ringScoreHolder2:IsA("Frame"),
		(`{ringScoreHolder:GetFullName()}.RingScoreHolder must be a Frame`)
	)
	local milestones = {}

	for k, v35 in LightVsDarkness.MILESTONES do
		local frame = v35.Frame
		local frame2 = progressBar:FindFirstChild(frame)
		assert(frame2 and frame2:IsA("Frame"), (`{progressBar:GetFullName()}.{frame} must be a Frame`))
		local claimButton = frame2:FindFirstChild("ClaimButton")
		assert(
			claimButton and claimButton:IsA("ImageButton"),
			(`{frame2:GetFullName()}.ClaimButton must be a ImageButton`)
		)
		local claimedOverlay = claimButton:FindFirstChild("ClaimedOverlay")
		assert(
			claimedOverlay and claimedOverlay:IsA("ImageLabel"),
			(`{claimButton:GetFullName()}.ClaimedOverlay must be a ImageLabel`)
		)
		local completedCheckmark = claimedOverlay:FindFirstChild("CompletedCheckmark")
		assert(
			completedCheckmark and completedCheckmark:IsA("ImageLabel"),
			(`{claimedOverlay:GetFullName()}.CompletedCheckmark must be a ImageLabel`)
		)
		local rewardIcon = claimButton:FindFirstChild("RewardIcon")
		assert(
			rewardIcon and rewardIcon:IsA("ImageLabel"),
			(`{claimButton:GetFullName()}.RewardIcon must be a ImageLabel`)
		)
		local quantityLabel = rewardIcon:FindFirstChild("QuantityLabel")
		milestones[k] = {
			Index = k,
			Rings = v35.Rings,
			Frame = frame2,
			BaseSize = frame2.Size,
			Button = claimButton,
			RewardIcon = rewardIcon,
			AuthoredIcon = rewardIcon.Image,
			Overlay = claimedOverlay,
			Checkmark = completedCheckmark,
			CheckSize = completedCheckmark.Size,
			Quantity = quantityLabel,
			QuantityText = not quantityLabel and "" or quantityLabel.Text,
			UnlockedDecor = frame2:FindFirstChild("UnlockedDecor"),
			LockedDecor = frame2:FindFirstChild("NotUnlockedDecor"),
			Tweens = {},
			State = nil,
			FillPoint = 0
		}
	end

	local teamSelection = screenGui:FindFirstChild("TeamSelection")
	assert(teamSelection and teamSelection:IsA("Frame"), (`{screenGui:GetFullName()}.TeamSelection must be a Frame`))
	local angelWing = scoreBar:FindFirstChild("AngelWing")
	assert(angelWing and angelWing:IsA("ImageLabel"), (`{scoreBar:GetFullName()}.AngelWing must be a ImageLabel`))
	local demonWing = scoreBar:FindFirstChild("DemonWing")
	assert(demonWing and demonWing:IsA("ImageLabel"), (`{scoreBar:GetFullName()}.DemonWing must be a ImageLabel`))
	local bossName = scoreBar:FindFirstChild("BossName")
	assert(bossName and bossName:IsA("TextLabel"), (`{scoreBar:GetFullName()}.BossName must be a TextLabel`))
	local v35 = {
		Gui = screenGui,
		ScoreBar = scoreBar,
		MilestonePanel = personalRingMilestone,
		TeamPanel = teamSelection,
		Holder = barHolder,
		LightBar = lightBar,
		DarkBar = darkBar,
		VsIcon = vSIcon,
		VsText = vSText,
		AngelWing = angelWing,
		DemonWing = demonWing,
		LightLabel = lightAmount,
		DarkLabel = darknessAmount,
		Timer = bossName,
		BarSpan = barSpan,
		SeamPad = (1 - barSpan) * 0.5,
		HolderPos = barHolder.Position,
		IconPos = vSIcon.Position,
		IconSize = vSIcon.Size,
		TextPos = vSText.Position,
		TextSize = vSText.Size,
		LightLabelSize = lightAmount.Size,
		DarkLabelSize = darknessAmount.Size,
		LightLabelColor = lightAmount.TextColor3,
		DarkLabelColor = darknessAmount.TextColor3
	}
	local lightYourTeam = scoreBar:FindFirstChild("LightYourTeam")
	assert(
		lightYourTeam and lightYourTeam:IsA("TextLabel"),
		(`{scoreBar:GetFullName()}.LightYourTeam must be a TextLabel`)
	)
	v35.LightYourTeam = lightYourTeam
	local darknessYourTeam = scoreBar:FindFirstChild("DarknessYourTeam")
	assert(
		darknessYourTeam and darknessYourTeam:IsA("TextLabel"),
		(`{scoreBar:GetFullName()}.DarknessYourTeam must be a TextLabel`)
	)
	v35.DarknessYourTeam = darknessYourTeam
	v35.MilestoneBar = progressBar
	local progressBar2 = progressBar:FindFirstChild("ProgressBar")
	assert(progressBar2 and progressBar2:IsA("Frame"), (`{progressBar:GetFullName()}.ProgressBar must be a Frame`))
	v35.MilestoneFill = progressBar2
	v35.ScoreHolder = ringScoreHolder
	v35.ScoreHolderSize = ringScoreHolder.Size
	v35.ScoreRow = ringScoreHolder2
	local ringScoreLabel = ringScoreHolder2:FindFirstChild("RingScoreLabel")
	assert(
		ringScoreLabel and ringScoreLabel:IsA("TextLabel"),
		(`{ringScoreHolder2:GetFullName()}.RingScoreLabel must be a TextLabel`)
	)
	v35.RingScore = ringScoreLabel
	v35.Milestones = milestones
	v2 = v35
	return v35
end

local function takeOverSprite(instance)
	local vector4 = Vector2.new(8, 4)
	local FPS = 24
	local playSprite = instance:FindFirstChild("PlaySprite")

	if playSprite and playSprite:IsA("LocalScript") then
		vector4 = playSprite:GetAttribute("Cells") or vector4
		FPS = playSprite:GetAttribute("FPS") or FPS
		playSprite.Disabled = true
	else
		playSprite = nil
	end

	return {
		image = instance,
		player = playSprite,
		columns = vector4.X,
		frames = vector4.X * vector4.Y,
		baseFps = FPS,
		fps = FPS,
		frame = 0,
		accum = 0,
		baseSize = instance.Size,
		punch = spring()
	}
end

-- equivalent calls inferred from this helper; original call sites unknown
local function releaseSprite(data)
	data.image.Size = data.baseSize
	data.image.Rotation = 0

	if data.player then
		data.player.Disabled = false
	end
end

local function advanceSprite(state, p: number)
	state.accum += p
	local v32 = 1 / state.fps
	local flag2 = false

	while v32 <= state.accum do
		state.accum -= v32
		state.frame = (state.frame + 1) % state.frames
		flag2 = true
	end

	if flag2 then
		local imageRectSize = state.image.ImageRectSize
		state.image.ImageRectOffset = Vector2.new(
			imageRectSize.X * (state.frame % state.columns),
			imageRectSize.Y * math.floor(state.frame / state.columns)
		)
	end

	stepSpring(state.punch, p) -- equivalent call inferred; original call site unknown
	local v33 = state.punch.p + 1
	local baseSize = state.baseSize
	state.image.Size = UDim2.new(baseSize.X.Scale * v33, baseSize.X.Offset, baseSize.Y.Scale * v33, baseSize.Y.Offset)
	state.image.Rotation = state.punch.p * 40
end

local function comma(p: number)
	local v32 = tostring((math.floor(p + 0.5)))

	repeat
		local v33
		v32, v33 = v32:gsub("^(-?%d+)(%d%d%d)", "%1,%2")
	until v33 == 0

	return v32
end

-- equivalent calls inferred from this helper; original call sites unknown
local function formatTimer(p: number)
	local v32 = math.max(math.ceil(p), 0)
	return string.format("%d:%02d", v32 // 60, v32 % 60)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function intensity()
	if Workspace:GetAttribute("LvdFinalClash") == true then
		return 2
	end

	return 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function ratioOf(p: number, p2: number)
	local v32 = p + p2

	if v32 <= 0 then
		return 0.5
	end

	return (math.clamp(p / v32, 0.12, 0.88))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function applyRatio(data, p: number)
	data.LightBar.Size = UDim2.new(data.BarSpan * p, 0, 1, 0)
	data.DarkBar.Size = UDim2.new(data.BarSpan * (1 - p), 0, 1, 0)
end

local function clash(p: number, flag2: boolean)
	local v32 = intensity() -- equivalent call inferred; original call site unknown
	v18 = math.min(v32 * 7, v18 + p * 7 * v32)
	v20.v += p * 9 * v32
	v19 += (flag2 and 1 or -1) * 26 * p * v32
	local v34 = v3
	local v35 = v4

	if flag2 and v34 then
		v34.punch.v += p * 7 * v32
	elseif v35 then
		v35.punch.v += p * 7 * v32
	end
end

local function applyScore(p: number, p2: number, flag2: boolean)
	local v32 = v13
	v6 = p
	v7 = p2
	v13 = ratioOf(p, p2)

	if flag2 then
		v8 = p
		v9 = p2
		v14 = v13
		v15 = 0
		v16 = 0
		local v33 = v2

		if v33 then
			v17 = v33.BarSpan * v14 + v33.SeamPad
			applyRatio(v33, v14) -- equivalent call inferred; original call site unknown
		end
	else
		local v33 = v13 - v32

		if v33 == 0 then
			return
		end

		local v34 = math.clamp(math.abs(v33) / 0.05, 0.15, 1)
		local v35 = v33 > 0
		v16 = (v35 and 1 or -1) * 0.22 * v34
		clash(v34, v35)
	end
end

local function stepLabels(data, p: number)
	local v32 = 1 - math.exp(p * -6)
	v8 += (v6 - v8) * v32
	v9 += (v7 - v9) * v32
	stepSpring(v21, p) -- equivalent call inferred; original call site unknown
	stepSpring(v22, p) -- equivalent call inferred; original call site unknown
	total += p

	if total >= 0.08333333333333333 then
		total = 0
		local v35 = math.floor(v8 + 0.5)
		local v36 = math.floor(v9 + 0.5)
		local v37 = math.max(v35 + v36, 1)

		if v10 >= 0 and v10 < v35 then
			v21.v += math.min((v35 - v10) / v37 * 60, 1) * 5
		end

		if v11 >= 0 and v11 < v36 then
			v22.v += math.min((v36 - v11) / v37 * 60, 1) * 5
		end

		v10 = v35
		v11 = v36
		local text = comma(v35)
		local text2 = comma(v36)

		if data.LightLabel.Text ~= text then
			data.LightLabel.Text = text
		end

		if data.DarkLabel.Text ~= text2 then
			data.DarkLabel.Text = text2
		end
	end

	local v35 = v21.p * 0.5 + 1
	local lightLabelSize = data.LightLabelSize
	data.LightLabel.Size = UDim2.new(
		lightLabelSize.X.Scale * v35,
		lightLabelSize.X.Offset,
		lightLabelSize.Y.Scale * v35,
		lightLabelSize.Y.Offset
	)
	data.LightLabel.TextColor3 = data.LightLabelColor:Lerp(color, (math.clamp(v21.p * 4, 0, 1)))
	local v36 = v22.p * 0.5 + 1
	local darkLabelSize = data.DarkLabelSize
	data.DarkLabel.Size = UDim2.new(
		darkLabelSize.X.Scale * v36,
		darkLabelSize.X.Offset,
		darkLabelSize.Y.Scale * v36,
		darkLabelSize.Y.Offset
	)
	data.DarkLabel.TextColor3 = data.DarkLabelColor:Lerp(color2, (math.clamp(v22.p * 4, 0, 1)))
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelTweens(p)
	for k, tween in p.Tweens do
		tween:Cancel()
		p.Tweens[k] = nil
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function play(p, p2: string, p3, p4, p5)
	local tween = p.Tweens[p2]

	if tween then
		tween:Cancel()
	end

	local tween2 = TweenService:Create(p3, p4, p5)
	p.Tweens[p2] = tween2
	tween2:Play()
end

local function punch(state)
	local baseSize = state.BaseSize
	state.Frame.Size = UDim2.new(
		baseSize.X.Scale,
		baseSize.X.Offset + vector2.X,
		baseSize.Y.Scale,
		baseSize.Y.Offset + vector2.Y
	)
	play(state, "punch", state.Frame, tweenInfo2, {
		Size = baseSize
	}) -- equivalent call inferred; original call site unknown
end

local function setMilestoneState(milestone, state: string, flag2: boolean)
	if milestone.State == state then
		return
	end

	milestone.State = state
	cancelTweens(milestone) -- equivalent call inferred; original call site unknown
	local visible = state ~= "Locked"

	if milestone.UnlockedDecor then
		milestone.UnlockedDecor.Visible = visible
	end

	if milestone.LockedDecor then
		milestone.LockedDecor.Visible = not visible
	end

	milestone.Frame.Size = milestone.BaseSize

	if flag2 then
		local frame = milestone.Frame
		local backgroundColor

		if visible then
			backgroundColor = color4
		else
			backgroundColor = color3
		end

		play(milestone, "bg", frame, tweenInfo, {
			BackgroundColor3 = backgroundColor
		}) -- equivalent call inferred; original call site unknown
	else
		local frame = milestone.Frame
		local backgroundColor

		if visible then
			backgroundColor = color4
		else
			backgroundColor = color3
		end

		frame.BackgroundColor3 = backgroundColor
	end

	local button = milestone.Button
	button.Image = visible and "rbxassetid://73951419137281" or "rbxassetid://111037630886814"
	local position

	if visible then
		position = uDim2
	else
		position = uDim4
	end

	button.Position = position
	local size

	if visible then
		size = uDim
	else
		size = uDim3
	end

	button.Size = size
	button.Active = state == "Ready"
	milestone.Overlay.Visible = state == "Claimed"

	if state == "Claimed" then
		if flag2 then
			milestone.Overlay.ImageTransparency = 1
			play(milestone, "overlay", milestone.Overlay, tweenInfo, {
				ImageTransparency = 0.64
			}) -- equivalent call inferred; original call site unknown
			milestone.Checkmark.ImageTransparency = 1
			milestone.Checkmark.Size = UDim2.fromScale(
				milestone.CheckSize.X.Scale * 0.2,
				milestone.CheckSize.Y.Scale * 0.2
			)
			play(milestone, "check", milestone.Checkmark, tweenInfo3, {
				Size = milestone.CheckSize,
				ImageTransparency = 0
			}) -- equivalent call inferred; original call site unknown
			punch(milestone)
		else
			milestone.Overlay.ImageTransparency = 0.64
			milestone.Checkmark.ImageTransparency = 0
			milestone.Checkmark.Size = milestone.CheckSize
		end
	else
		if flag2 then
			punch(milestone)
		end

		if state == "Ready" then
			button.Size = uDim
			play(milestone, "pulse", button, tweenInfo4, {
				Size = UDim2.fromScale(uDim.X.Scale * 1.07, uDim.Y.Scale * 1.07)
			}) -- equivalent call inferred; original call site unknown
		end
	end
end

local function measureFillPoints(p)
	local Y = p.MilestoneBar.AbsolutePosition.Y
	local Y2 = p.MilestoneBar.AbsoluteSize.Y

	if Y2 <= 0 then
		return false
	end

	for _, milestone in p.Milestones do
		milestone.FillPoint = math.clamp(
			(milestone.Frame.AbsolutePosition.Y + milestone.Frame.AbsoluteSize.Y * 0.5 - Y) / Y2,
			0,
			1
		)
	end

	return true
end

local function fillScaleFor(p, p2: number)
	local rings = 0
	local fillPoint = 0

	for _, milestone in p.Milestones do
		if p2 <= milestone.Rings then
			local v32 = milestone.Rings - rings
			local v33 = not (v32 > 0) and 1 or (p2 - rings) / v32
			return fillPoint + (milestone.FillPoint - fillPoint) * v33
		else
			rings = milestone.Rings
			fillPoint = milestone.FillPoint
		end
	end

	return fillPoint
end

-- equivalent calls inferred from this helper; original call sites unknown
local function readRings()
	local lvdRingsCollected = localPlayer:GetAttribute("LvdRingsCollected")

	if type(lvdRingsCollected) == "number" then
		return lvdRingsCollected
	end

	return 0
end

local function stepYourTeam(data)
	local lvdTeam = localPlayer:GetAttribute("LvdTeam")
	data.LightYourTeam.Visible = lvdTeam == "Light"
	data.DarknessYourTeam.Visible = lvdTeam == "Darkness"

	if type(lvdTeam) ~= "string" then
		lvdTeam = nil
	end

	if v28 and v27 == lvdTeam then
		return
	end

	v28 = true
	v27 = lvdTeam

	for k, milestone in data.Milestones do
		milestone.RewardIcon.Image = LightVsDarkness.MilestoneIcon(k, lvdTeam) or milestone.AuthoredIcon
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isClaimed(p: number)
	return localPlayer:GetAttribute(LightVsDarkness.MilestoneAttribute(p)) == true
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stepRingCount(p, p2: number)
	local rings = readRings() -- equivalent call inferred; original call site unknown
	v23 += (rings - v23) * (1 - math.exp(p2 * -6))

	if math.abs(rings - v23) < 0.5 then
		v23 = rings
	end

	local text = comma(math.floor(v23))

	if text ~= v24 then
		v24 = text
		p.RingScore.Text = text
	end
end

local function stepMilestones(p, _: number)
	if not v25 then
		v25 = measureFillPoints(p)

		if not v25 then
			return
		end
	end

	local v32 = v26
	v26 = true
	local rings = readRings() -- equivalent call inferred; original call site unknown
	p.MilestoneFill.Size = UDim2.new(1, 0, fillScaleFor(p, v23), 0)

	for k, milestone in p.Milestones do
		setMilestoneState(
			milestone,
			isClaimed(k) and "Claimed" or milestone.Rings <= rings and "Ready" or "Locked",
			v32
		)
	end
end

local function flyerLayer(p)
	local v32 = v30

	if v32 ~= nil and v32.Parent == p.Gui then
		return v32
	end

	if v32 ~= nil then
		v32:Destroy()
	end

	local frame = Instance.new("Frame")
	frame.Name = "RingFlight"
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromScale(1, 1)
	frame.ZIndex = 50
	frame.Parent = p.Gui
	v30 = frame
	return frame
end

-- equivalent calls inferred from this helper; original call sites unknown
local function counterTarget(p)
	return p.ScoreRow.AbsolutePosition + p.ScoreRow.AbsoluteSize * 0.5 - p.Gui.AbsolutePosition
end

local function punchCounter(p)
	local scoreHolderSize = p.ScoreHolderSize
	p.ScoreHolder.Size = UDim2.new(
		scoreHolderSize.X.Scale,
		scoreHolderSize.X.Offset + vector3.X,
		scoreHolderSize.Y.Scale,
		scoreHolderSize.Y.Offset + vector3.Y
	)
	local v32 = v31

	if v32 ~= nil then
		v32:Cancel()
	end

	local tween = TweenService:Create(p.ScoreHolder, tweenInfo2, {
		Size = scoreHolderSize
	})
	v31 = tween
	tween:Play()
end

-- equivalent calls inferred from this helper; original call sites unknown
local function dropFlyer(p: number)
	local v32 = table.remove(v29, p)

	if v32 ~= nil then
		v32.Frame:Destroy()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function arriveFlyer(p, i: number)
	dropFlyer(i) -- equivalent call inferred; original call site unknown
	punchCounter(p)
end

local function stepFlyers()
	local v32 = v2

	if v32 == nil or #v29 == 0 then
		return
	end

	local now = os.clock()
	local v33 = counterTarget(v32) -- equivalent call inferred; original call site unknown

	for i = #v29, 1, -1 do
		local v34 = v29[i]

		if v34.Frame.Parent == nil then
			table.remove(v29, i)
		else
			local v35 = (now - v34.StartAt) / 0.55

			if v35 >= 1 then
				arriveFlyer(v32, i) -- equivalent call inferred; original call site unknown
			else
				v34.Frame.Rotation = (now * 140 + v34.Phase) % 360

				if not (v35 < 0) then
					local value = TweenService:GetValue(v35, back, v)
					local v36 = 1 - value
					local v37 = v34.From * v36 * v36 + v34.Control * 2 * v36 * value + v33 * value * value
					v34.Frame.Position = UDim2.fromOffset(v37.X, v37.Y)
					local v38 = 1 - math.clamp(value, 0, 1) * 0.4
					v34.Frame.Size = UDim2.fromOffset(v38 * 46, v38 * 46)
				end
			end
		end
	end
end

local function ringArrived(_: number, vector4: Vector3)
	local v32 = v2

	if not flag or v32 == nil or not v32.Gui.Enabled then
		return
	end

	local icon = v32.ScoreRow:FindFirstChild("Icon")

	if icon == nil or not icon:IsA("ImageLabel") then
		return
	end

	local currentCamera = Workspace.CurrentCamera

	if currentCamera == nil then
		return
	end

	local worldToViewportPoint, v33 = currentCamera:WorldToViewportPoint(vector4 + createVector(0, 1.5, 0))
	local viewportSize = currentCamera.ViewportSize
	local v34

	if v33 then
		v34 = Vector2.new(worldToViewportPoint.X, worldToViewportPoint.Y)
	else
		v34 = Vector2.new(viewportSize.X * 0.5, viewportSize.Y * 0.62)
	end

	local from = v34 + Vector2.new(random:NextNumber(-70, 70), random:NextNumber(-70, 70) * 0.7) - v32.Gui.AbsolutePosition
	local v36 = counterTarget(v32) -- equivalent call inferred; original call site unknown
	local v37 = v36 - from
	local v38

	if v37.Magnitude > 1 then
		v38 = Vector2.new(-v37.Y, v37.X).Unit
	else
		v38 = Vector2.new(0, -1)
	end

	local control = (from + v36) * 0.5 + v38 * random:NextNumber(-0.3, 0.3) * v37.Magnitude + Vector2.new(
		0,
		-random:NextNumber(10, 60)
	)

	while #v29 >= 24 do
		arriveFlyer(v32, 1) -- equivalent call inferred; original call site unknown
	end

	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "RingFlyer"
	imageLabel.BackgroundTransparency = 1
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Size = UDim2.fromOffset(46, 46)
	imageLabel.Position = UDim2.fromOffset(from.X, from.Y)
	imageLabel.Image = icon.Image
	imageLabel.ImageColor3 = icon.ImageColor3
	imageLabel.ImageRectOffset = icon.ImageRectOffset
	imageLabel.ImageRectSize = icon.ImageRectSize
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Parent = flyerLayer(v32)
	table.insert(v29, {
		Frame = imageLabel,
		From = from,
		Control = control,
		StartAt = os.clock() + random:NextNumber(0, 0.12),
		Phase = random:NextNumber(0, 360)
	})
end

local function step(p: number)
	local v32 = v2
	local v33 = v3
	local v34 = v4

	if not flag or v32 == nil or v33 == nil or v34 == nil then
		return
	end

	if HiddenUIHandler.IsHidden() then
		v32.Gui.Enabled = false
		return
	end

	v32.Gui.Enabled = true
	local visible = v32.TeamPanel.Visible
	v32.ScoreBar.Visible = not visible
	v32.MilestonePanel.Visible = not visible
	stepRingCount(v32, math.min(p, 0.1)) -- equivalent call inferred; original call site unknown

	if visible then
		return
	end

	local v36 = math.min(p, 0.1)
	local v37 = intensity() -- equivalent call inferred; original call site unknown
	v16 -= v16 * math.min(v36 * 1.6, 1)
	local v38 = math.clamp(v13 + v16, 0.12, 0.88)
	v15 += (v38 - v14) * 55 * v36
	v15 *= math.exp(v36 * -7)
	v14 = math.clamp(v14 + v15 * v36, 0.05, 0.95)
	applyRatio(v32, v14) -- equivalent call inferred; original call site unknown
	total2 += (v15 - total2) * (1 - math.exp(v36 * -8))
	local v40 = math.clamp(total2 / 0.5, -1, 1)
	v33.fps = v33.baseFps + (90 - v33.baseFps) * math.max(v40, 0)
	v34.fps = v34.baseFps + (90 - v34.baseFps) * math.max(-v40, 0)
	advanceSprite(v33, v36)
	advanceSprite(v34, v36)
	local v41 = v32.BarSpan * v14 + v32.SeamPad
	v17 += (v41 - v17) * (1 - math.exp(v36 * -22))
	stepSpring(v20, v36) -- equivalent call inferred; original call site unknown
	v19 -= v19 * math.min(v36 * 6, 1)
	local v43 = v20.p + 1
	local rotation = v40 * 10 * v37 + v19
	v32.VsIcon.Position = UDim2.new(v17, v32.IconPos.X.Offset, v32.IconPos.Y.Scale, v32.IconPos.Y.Offset)
	v32.VsIcon.Size = UDim2.new(
		v32.IconSize.X.Scale * v43,
		v32.IconSize.X.Offset,
		v32.IconSize.Y.Scale * v43,
		v32.IconSize.Y.Offset
	)
	v32.VsIcon.Rotation = rotation
	v32.VsText.Position = UDim2.new(v17, v32.TextPos.X.Offset, v32.TextPos.Y.Scale, v32.TextPos.Y.Offset)
	v32.VsText.Size = UDim2.new(
		v32.TextSize.X.Scale * v43,
		v32.TextSize.X.Offset,
		v32.TextSize.Y.Scale * v43,
		v32.TextSize.Y.Offset
	)
	v32.VsText.Rotation = rotation
	v18 -= v18 * math.min(v36 * 6, 1)

	if v37 > 1 then
		v18 = math.max(v18, 1.5)
	end

	local holderPos = v32.HolderPos

	if v18 > 0.05 then
		v32.Holder.Position = UDim2.new(
			holderPos.X.Scale,
			holderPos.X.Offset + (math.random() - 0.5) * 2 * v18,
			holderPos.Y.Scale,
			holderPos.Y.Offset + (math.random() - 0.5) * v18
		)
	elseif v32.Holder.Position ~= holderPos then
		v32.Holder.Position = holderPos
	end

	stepLabels(v32, v36)
	stepMilestones(v32, v36)
	stepYourTeam(v32)
	local text = formatTimer(v5 - Workspace:GetServerTimeNow()) -- equivalent call inferred; original call site unknown

	if text ~= v12 then
		v12 = text
		v32.Timer.Text = text
	end
end

local function stop()
	if not flag then
		return
	end

	flag = false

	for i = #v29, 1, -1 do
		dropFlyer(i) -- equivalent call inferred; original call site unknown
	end

	local v32 = v31
	v31 = nil

	if v32 ~= nil then
		v32:Cancel()
	end

	local v33 = v30
	v30 = nil

	if v33 ~= nil then
		v33:Destroy()
	end

	local v34 = v2

	if v34 then
		v34.Gui.Enabled = false
		v34.ScoreHolder.Size = v34.ScoreHolderSize
		v34.ScoreBar.Visible = true
		v34.MilestonePanel.Visible = true
		v34.Holder.Position = v34.HolderPos
		v34.VsIcon.Position = v34.IconPos
		v34.VsIcon.Size = v34.IconSize
		v34.VsIcon.Rotation = 0
		v34.VsText.Position = v34.TextPos
		v34.VsText.Size = v34.TextSize
		v34.VsText.Rotation = 0
		v34.LightLabel.Size = v34.LightLabelSize
		v34.DarkLabel.Size = v34.DarkLabelSize
		v34.LightLabel.TextColor3 = v34.LightLabelColor
		v34.DarkLabel.TextColor3 = v34.DarkLabelColor
		v34.LightYourTeam.Visible = false
		v34.DarknessYourTeam.Visible = false

		for _, milestone in v34.Milestones do
			cancelTweens(milestone) -- equivalent call inferred; original call site unknown
			milestone.State = nil

			if milestone.State ~= "Locked" then
				milestone.State = "Locked"
				cancelTweens(milestone) -- equivalent call inferred; original call site unknown

				if milestone.UnlockedDecor then
					milestone.UnlockedDecor.Visible = false
				end

				if milestone.LockedDecor then
					milestone.LockedDecor.Visible = true
				end

				milestone.Frame.Size = milestone.BaseSize
				milestone.Frame.BackgroundColor3 = color3
				local button = milestone.Button
				button.Image = "rbxassetid://111037630886814"
				button.Position = uDim4
				button.Size = uDim3
				button.Active = false
				milestone.Overlay.Visible = false
			end

			milestone.Frame.Size = milestone.BaseSize
			milestone.RewardIcon.Image = milestone.AuthoredIcon
			local quantity = milestone.Quantity

			if not quantity then
				continue
			end

			quantity.Visible = true
			quantity.Text = milestone.QuantityText
		end
	end

	local v35 = v3
	local v36 = v4
	v3 = nil
	v4 = nil

	if v35 then
		releaseSprite(v35) -- equivalent call inferred; original call site unknown
	end

	if v36 then
		releaseSprite(v36) -- equivalent call inferred; original call site unknown
	end
end

local function start(maid, p: number)
	stop()
	local ui = resolveUi()
	flag = true
	v5 = p
	v6 = 0
	v7 = 0
	v8 = 0
	v9 = 0
	v10 = -1
	v11 = -1
	total = 0
	v12 = ""
	v13 = 0.5
	v14 = 0.5
	v15 = 0
	total2 = 0
	v16 = 0
	v17 = ui.BarSpan * 0.5 + ui.SeamPad
	v18 = 0
	v19 = 0
	v20 = spring()
	v21 = spring()
	v22 = spring()
	v3 = takeOverSprite(ui.AngelWing)
	v4 = takeOverSprite(ui.DemonWing)
	applyRatio(ui, v14) -- equivalent call inferred; original call site unknown
	ui.LightLabel.Text = "0"
	ui.DarkLabel.Text = "0"
	v23 = readRings()
	v24 = ""
	v25 = false
	v26 = false
	v28 = false

	for k, milestone in ui.Milestones do
		milestone.State = nil
		local quantity = milestone.Quantity

		if quantity then
			local milestoneQuantity = LightVsDarkness.MilestoneQuantity(k)
			quantity.Visible = milestoneQuantity ~= nil
			quantity.Text = milestoneQuantity or quantity.Text
		end

		local v33 = milestone
		local v34 = k
		GUI.OnActivated(milestone.Button, function()
			if flag and v33.State == "Ready" then
				Remotes.LightVsDarkness.AskClaimMilestone:FireServer(v34)
			end
		end)
		local valueHolder = milestone.Frame:FindFirstChild("ValueHolder")

		if valueHolder then
			valueHolder.Title.Text = `{milestone.Rings}`
		end
	end

	stepYourTeam(ui)
	local rings = readRings() -- equivalent call inferred; original call site unknown
	v23 += (rings - v23) * 0.4511883639059736

	if math.abs(rings - v23) < 0.5 then
		v23 = rings
	end

	local text = comma(math.floor(v23))

	if text ~= v24 then
		v24 = text
		ui.RingScore.Text = text
	end

	stepMilestones(ui, 0.1)
	maid:Connect(Remotes.LightVsDarkness.ScoreChanged.OnClientEvent, function(p2: number, p3: number)
		if flag then
			local v35 = v13
			v6 = p2
			v7 = p3
			v13 = ratioOf(p2, p3)
			local v36 = v13 - v35

			if v36 == 0 then
				return
			end

			local v37 = math.clamp(math.abs(v36) / 0.05, 0.15, 1)
			local v38 = v36 > 0
			v16 = (v38 and 1 or -1) * 0.22 * v37
			clash(v37, v38)
		end
	end)
	maid:Connect(RunService.PreRender, step)
	maid:Connect(RunService.PreRender, stepFlyers)
	maid:Add(stop)
	maid:Add(task.spawn(function()
		local v35, v36 = Remotes.LightVsDarkness.FetchScore:InvokeServer()

		if flag and type(v35) == "number" and type(v36) == "number" and v6 == 0 and v7 == 0 then
			v6 = v35
			v7 = v36
			v13 = ratioOf(v35, v36)
			v8 = v35
			v9 = v36
			v14 = v13
			v15 = 0
			v16 = 0
			local v37 = v2

			if v37 then
				v17 = v37.BarSpan * v14 + v37.SeamPad
				applyRatio(v37, v14) -- equivalent call inferred; original call site unknown
			end
		end
	end))
end

return {
	Start = start,
	Stop = stop,
	RingArrived = ringArrived
}