local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Audio = require(ReplicatedStorage.SharedUtils.Audio)
local MonsterMessageUI = {}
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
	ColorSequenceKeypoint.new(0.0967, Color3.new(0.923384, 0.923384, 0.923384)),
	ColorSequenceKeypoint.new(0.4162, Color3.new(0.943906, 0.943906, 0.943906)),
	ColorSequenceKeypoint.new(1, Color3.new(0.207843, 0.207843, 0.207843))
})
local numberSequence = NumberSequence.new(0, 0)
local rbxassetfontsfamiliesFredokaOnejson = Font.new(
	"rbxasset://fonts/families/FredokaOne.json",
	Enum.FontWeight.Regular,
	Enum.FontStyle.Normal
)

local function buildGradient(parent)
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Color = colorSequence
	uIGradient.Transparency = numberSequence
	uIGradient.Rotation = 90
	uIGradient.Parent = parent
	return uIGradient
end

function MonsterMessageUI.create(_)
	local textLabel = Instance.new("TextLabel")
	textLabel.Name = "MonsterMessage"
	textLabel.AnchorPoint = Vector2.new(0, 0)
	textLabel.Position = UDim2.new(0.246, 0, 0.773, 0)
	textLabel.Size = UDim2.new(0.5074, 0, 0.0545, 0)
	textLabel.BackgroundColor3 = Color3.new(0, 0, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.BorderSizePixel = 1
	textLabel.Text = ""
	textLabel.TextColor3 = Color3.new(1, 1, 1)
	textLabel.TextStrokeTransparency = 1
	textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel.TextScaled = true
	textLabel.FontFace = rbxassetfontsfamiliesFredokaOnejson
	textLabel.TextWrapped = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Center
	textLabel.TextYAlignment = Enum.TextYAlignment.Center
	textLabel.ZIndex = 10
	local uICorner = Instance.new("UICorner")
	uICorner.CornerRadius = UDim.new(0, 8)
	uICorner.Parent = textLabel
	local uIGradient = Instance.new("UIGradient")
	uIGradient.Color = colorSequence
	uIGradient.Transparency = numberSequence
	uIGradient.Rotation = 90
	uIGradient.Parent = textLabel
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Background"
	imageLabel.AnchorPoint = Vector2.new(0, 0)
	imageLabel.Position = UDim2.new(0, 0, 0, 0)
	imageLabel.Size = UDim2.new(1, 0, 1, 0)
	imageLabel.BackgroundTransparency = 1
	imageLabel.BorderSizePixel = 0
	imageLabel.Image = "rbxassetid://18823606580"
	imageLabel.ImageColor3 = Color3.new(1, 1, 1)
	imageLabel.ImageTransparency = 1
	imageLabel.ScaleType = Enum.ScaleType.Stretch
	imageLabel.ZIndex = 11
	imageLabel.Parent = textLabel
	local textLabel2 = Instance.new("TextLabel")
	textLabel2.Name = "Message"
	textLabel2.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel2.Position = UDim2.new(0.5, 0, 0.5, 0)
	textLabel2.Size = UDim2.new(1, 0, 0.85, 0)
	textLabel2.BackgroundColor3 = Color3.new(0, 0, 0)
	textLabel2.BackgroundTransparency = 1
	textLabel2.BorderSizePixel = 1
	textLabel2.Text = "This Is A Test"
	textLabel2.TextColor3 = Color3.new(1, 1, 1)
	textLabel2.TextStrokeTransparency = 0
	textLabel2.TextStrokeColor3 = Color3.new(0, 0, 0)
	textLabel2.TextScaled = true
	textLabel2.FontFace = rbxassetfontsfamiliesFredokaOnejson
	textLabel2.TextWrapped = true
	textLabel2.TextXAlignment = Enum.TextXAlignment.Center
	textLabel2.TextYAlignment = Enum.TextYAlignment.Center
	textLabel2.ZIndex = 12
	textLabel2.Parent = textLabel
	local uIGradient2 = Instance.new("UIGradient")
	uIGradient2.Color = colorSequence
	uIGradient2.Transparency = numberSequence
	uIGradient2.Rotation = 90
	uIGradient2.Parent = textLabel2
	return textLabel
end

function MonsterMessageUI:setText(instance, text: string)
	local message = instance:FindFirstChild("Message")

	if message and message:IsA("TextLabel") then
		message.Text = text
	end
end

local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tweenInfo2 = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelTween(instance)
	if instance then
		instance:Cancel()
		instance:Destroy()
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function cancelState(state)
	if not state then
		return
	end

	cancelTween(state.fadeIn) -- equivalent call inferred; original call site unknown
	cancelTween(state.fadeInBg) -- equivalent call inferred; original call site unknown
	cancelTween(state.fadeOut) -- equivalent call inferred; original call site unknown
	cancelTween(state.fadeOutBg) -- equivalent call inferred; original call site unknown
	state.fadeIn = nil
	state.fadeInBg = nil
	state.fadeOut = nil
	state.fadeOutBg = nil
end

function MonsterMessageUI.show(_, instance, p: string, options)
	local v2 = options or {}
	local duration = v2.duration or 3
	local color = v2.color
	local font = v2.font
	local fontFace = v2.fontFace
	local soundId = v2.soundId
	local soundVolume = v2.soundVolume or 1
	local soundPlaybackSpeed = v2.soundPlaybackSpeed or 1
	local message = instance:FindFirstChild("Message")
	local background = instance:FindFirstChild("Background")

	if not (message and message:IsA("TextLabel") and background and background:IsA("ImageLabel")) then
		warn("[MonsterMessageUI] show: label is missing Message/Background children")
		return
	end

	cancelState(v[instance]) -- equivalent call inferred; original call site unknown
	local v4 = {}
	v[instance] = v4

	if soundId then
		Audio:Play(soundId, {
			Volume = soundVolume,
			PlaybackSpeed = soundPlaybackSpeed,
			Parent = instance
		})
	end

	MonsterMessageUI:setText(instance, p)

	if color then
		message.TextColor3 = color
	end

	if fontFace then
		message.FontFace = fontFace
	elseif font then
		message.Font = font
	end

	message.TextTransparency = 1
	message.TextStrokeTransparency = 1
	background.ImageTransparency = 1
	v4.fadeIn = TweenService:Create(message, tweenInfo, {
		TextTransparency = 0,
		TextStrokeTransparency = 0
	})
	v4.fadeInBg = TweenService:Create(background, tweenInfo, {
		ImageTransparency = 0.2
	})
	v4.fadeIn:Play()
	v4.fadeInBg:Play()
	task.delay(duration, function()
		if v[instance] ~= v4 then
			return
		end

		cancelTween(v4.fadeIn) -- equivalent call inferred; original call site unknown
		cancelTween(v4.fadeInBg) -- equivalent call inferred; original call site unknown
		v4.fadeIn = nil
		v4.fadeInBg = nil
		v4.fadeOut = TweenService:Create(message, tweenInfo2, {
			TextTransparency = 1,
			TextStrokeTransparency = 1
		})
		v4.fadeOutBg = TweenService:Create(background, tweenInfo2, {
			ImageTransparency = 1
		})
		v4.fadeOut:Play()
		v4.fadeOutBg:Play()
	end)
end

return MonsterMessageUI