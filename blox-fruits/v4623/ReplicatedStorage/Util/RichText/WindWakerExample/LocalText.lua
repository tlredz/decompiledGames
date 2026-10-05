local module = require(script.Parent:FindFirstChild("RichText") or script.Parent.Parent)
script.Parent.Enabled = true
local TweenService = game:GetService("TweenService")
local dialogue = script.Parent.Dialogue
local textFrame = dialogue.TextFrame
local button = dialogue.Button
dialogue.Visible = false
button.Visible = false
local tween = TweenService:Create(button, TweenInfo.new(0.1), {
	ImageTransparency = 0
})
local tween2 = TweenService:Create(button, TweenInfo.new(0.1), {
	ImageTransparency = 1
})
local tween3 = TweenService:Create(button, TweenInfo.new(0.05, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
	Size = UDim2.new(0.25, 0, 0.25, 0)
})
local tween4 = TweenService:Create(dialogue, TweenInfo.new(0.4), {
	Size = dialogue.Size,
	ImageTransparency = 0
})
local tween5 = TweenService:Create(dialogue, TweenInfo.new(0.4), {
	ImageTransparency = 1
})

-- equivalent calls inferred from this helper; original call sites unknown
local function showButton()
	button.Size = UDim2.new(0.3, 0, 0.3, 0)
	button.Visible = true
	tween:Play()
	wait(tween.TweenInfo.Time)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function clickButton()
	tween3:Play()
	wait(tween3.TweenInfo.Time)
	tween2:Play()
	wait(tween2.TweenInfo.Time)
	button.Visible = false
end

-- equivalent calls inferred from this helper; original call sites unknown
local function showFrame()
	dialogue.Size = UDim2.new(0.4, 0, 0.1, 0)
	dialogue.ImageTransparency = 1
	dialogue.Visible = true
	tween4:Play()
	wait(tween4.TweenInfo.Time)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function hideFrame()
	tween5:Play()
	wait(tween5.TweenInfo.Time)
	dialogue.Visible = false
end

local function showDialogue(text, delay)
	local v = module:New(textFrame, text, {
		Font = "Cartoon"
	})
	v:Animate(true)
	showButton() -- equivalent call inferred; original call site unknown
	wait(delay)
	clickButton() -- equivalent call inferred; original call site unknown
	v:Hide()
end

wait(2)
showFrame() -- equivalent call inferred; original call site unknown

for _, v in pairs({
	{
		Text = [[
I just saw a <Color=Red>wild<Color=/>...a <AnimateStyle=Wiggle><Color=Red>wild pig🐷<Color=/>!<AnimateYield=1><AnimateStyle=/>
Ooh! See? Look! That black one there...<AnimateYield=1>
Don't you see him?]],
		Delay = 1.5
	},
	{
		Text = "<AnimateYield=0.3>This is perfect! My wife was just telling me how she really wanted a pet...",
		Delay = 2.7
	},
	{
		Text = [[
You ready to go grab it, Link?<AnimateYield=0.3>
 Now, you can't just run up on it!
Pigs are too alert to their surroundings for you to just jog up and capture one.]],
		Delay = 3.5
	},
	{
		Text = "If you want to get close to one, you have to hold <Img=1014975764> to crouch and tilt <Img=1014975761> to crawl slowly up behind it. <AnimateYield=1.5>Slow<AnimateYield=1>ly...",
		Delay = 3
	},
	{
		Text = "You could also distract it with bait, I guess.",
		Delay = 1.5
	}
}) do
	showDialogue(v.Text, v.Delay)
end

hideFrame() -- equivalent call inferred; original call site unknown