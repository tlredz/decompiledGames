local ReplicatedStorage = game:GetService("ReplicatedStorage")
local tweenHelpers = require(ReplicatedStorage.SharedUtils.tweenHelpers)
local color = Color3.fromRGB(10, 32, 74)
local color2 = Color3.fromRGB(18, 54, 124)
local color3 = Color3.fromRGB(6, 18, 40)
local color4 = Color3.fromRGB(104, 180, 255)
local color5 = Color3.fromRGB(234, 244, 255)
local color6 = Color3.fromRGB(160, 196, 240)
local color7 = Color3.fromRGB(190, 226, 255)
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

local Blue = {}

function Blue.apply(data)
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

function Blue.onHoldBegan(p)
	if p.background then
		tweenHelpers.playTween(p.background, tweenInfo, {
			BackgroundColor3 = color2
		})
	end
end

function Blue.onHoldEnded(p)
	if p.background then
		tweenHelpers.playTween(p.background, tweenInfo, {
			BackgroundColor3 = color
		})
	end
end

function Blue.onTriggered(p)
	if p.background then
		p.background.BackgroundColor3 = color7
		tweenHelpers.playTween(p.background, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
			BackgroundColor3 = color
		})
	end
end

return Blue