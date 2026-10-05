local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tweenHelpers = require(ReplicatedStorage.SharedUtils.tweenHelpers)
local color = Color3.fromRGB(72, 12, 16)
local color2 = Color3.fromRGB(122, 20, 26)
local color3 = Color3.fromRGB(38, 6, 8)
local color4 = Color3.fromRGB(255, 96, 96)
local color5 = Color3.fromRGB(255, 236, 236)
local color6 = Color3.fromRGB(238, 168, 168)
local color7 = Color3.fromRGB(255, 190, 190)
local tweenInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function paintRing(holdRing, color8)
	if not holdRing then
		return
	end

	for _, child in ipairs(holdRing:GetChildren()) do
		local fill = child:FindFirstChild("Fill")

		if fill then
			fill.BackgroundColor3 = color8
		end
	end
end

local Red = {}

function Red.apply(data)
	if data.background then
		data.background.BackgroundColor3 = color
		data.background.BackgroundTransparency = 0.25
	end

	if data.keyBackground then
		data.keyBackground.BackgroundColor3 = color3
	end

	if data.actionText then
		data.actionText.TextColor3 = color5
	end

	if data.objectText then
		data.objectText.TextColor3 = color6
	end

	if data.buttonText then
		data.buttonText.TextColor3 = color5
	end

	paintRing(data.holdRing, color4)
end

function Red.onHoldBegan(p)
	if p.background then
		tweenHelpers.playTween(p.background, tweenInfo, {
			BackgroundColor3 = color2
		})
	end
end

function Red.onHoldEnded(p)
	if p.background then
		tweenHelpers.playTween(p.background, tweenInfo, {
			BackgroundColor3 = color
		})
	end
end

function Red.onTriggered(p)
	if p.background then
		p.background.BackgroundColor3 = color7
		tweenHelpers.playTween(p.background, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			BackgroundColor3 = color
		})
	end
end

return Red