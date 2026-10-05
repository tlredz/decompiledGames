local color = Color3.fromRGB(0, 170, 255)
local color2 = Color3.fromRGB(0, 120, 180)
local color3 = Color3.fromRGB(255, 255, 255)
return {
	action = {
		resizeInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back),
		repositionInfo = TweenInfo.new(0.2, Enum.EasingStyle.Back)
	},
	toggleable = {
		deselected = {
			iconGradientColor = ColorSequence.new(color, color2),
			iconGradientRotation = 90,
			noticeCircleColor = color,
			noticeCircleImage = "http://www.roblox.com/asset/?id=4882430005",
			noticeTextColor = color3,
			captionOverlineColor = color
		},
		selected = {
			iconBackgroundColor = Color3.fromRGB(255, 255, 255),
			iconBackgroundTransparency = 0.1,
			iconGradientColor = ColorSequence.new(color, color2),
			iconGradientRotation = 90,
			iconImageColor = Color3.fromRGB(255, 255, 255),
			iconTextColor = Color3.fromRGB(255, 255, 255),
			noticeCircleColor = color3,
			noticeTextColor = color
		}
	},
	other = {}
}