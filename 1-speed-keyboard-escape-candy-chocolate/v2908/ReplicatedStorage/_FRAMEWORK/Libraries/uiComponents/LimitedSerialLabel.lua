local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Vide = require(ReplicatedStorage.Packages.Vide)
local create = Vide.create
local rbxassetfontsfamiliesGothamSSmjson = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.new(1, 0.972549, 0.894118)),
	ColorSequenceKeypoint.new(0.240484, Color3.new(1, 0.970671, 0.814897)),
	ColorSequenceKeypoint.new(0.570934, Color3.new(1, 0.953769, 0.101907)),
	ColorSequenceKeypoint.new(1, Color3.new(1, 0.682353, 0.172549))
})

local function limitedSerialLabel(p)
	return create("TextLabel")({
		Name = "LimitedSerialLabel",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.fromScale(0.5, 1.075),
		Size = UDim2.fromScale(1, 0.8),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = rbxassetfontsfamiliesGothamSSmjson,
		LineHeight = 1,
		RichText = false,
		Text = `#{p.serial}`,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextScaled = true,
		TextSize = 8,
		TextStrokeColor3 = Color3.fromRGB(20, 16, 28),
		TextStrokeTransparency = 0.1,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 9,
		create("UIGradient")({
			Color = colorSequence,
			Rotation = 90
		}),
		create("UIStroke")({
			Color = Color3.fromRGB(70, 64, 16),
			StrokeSizingMode = Enum.StrokeSizingMode.FixedSize,
			Thickness = 1,
			Transparency = 0
		})
	})
end

return limitedSerialLabel