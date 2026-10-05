local React = require(game.ReplicatedStorage.Packages.React)
local useGiftCount = require(game.ReplicatedStorage.React.Hooks.Player.useGiftCount)
local usePeriod = require(game.ReplicatedStorage.React.Hooks.Animation.usePeriod)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement

function animatedGiftButton(p)
	local v = usePeriod(true, 2.5)
	return createElement("ImageButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.DISABLED.BORDER,
		BorderColor3 = Color3.fromRGB(255, 200, 0),
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		Position = UDim2.new(1, 4, 0.5, 0),
		Size = UDim2.fromScale(0.07, 0.07),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		ZIndex = CONSTANTS.LAYER.RAISED,
		[React.Event.Activated] = p.OnClick
	}, {
		ImageLabel = createElement("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://11332562153",
			ImageColor3 = Color3.fromRGB(255, 197, 20),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(0.8, 0.8)
		}),
		UIAspectRatioConstraint = createElement("UIAspectRatioConstraint"),
		UIGradient = createElement("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 225, 0)),
				ColorSequenceKeypoint.new(0.442142, Color3.fromRGB(255, 140, 0)),
				ColorSequenceKeypoint.new(0.482699, Color3.fromRGB(255, 140, 0)),
				ColorSequenceKeypoint.new(0.52677, Color3.fromRGB(255, 140, 0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 170, 0))
			}),
			Rotation = 360 * v,
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(0.428231, 1),
				NumberSequenceKeypoint.new(0.430613, 0),
				NumberSequenceKeypoint.new(0.667659, 0),
				NumberSequenceKeypoint.new(1, 0)
			})
		})
	})
end

return function(p)
	local v = useGiftCount()

	if not v or v <= 0 then
		return nil
	end

	local v4 = {
		AnchorPoint = Vector2.new(0, 0),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		LayoutOrder = -996,
		Size = UDim2.new(1, -6, 0.12, 0),
		Visible = v > 0,
		ZIndex = CONSTANTS.LAYER.RAISED_HIGH
	}
	local bannerImage

	if not (v <= 0) then
		bannerImage = createElement("ImageButton", {
			AnchorPoint = Vector2.new(0, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://111969951012172",
			Position = UDim2.new(0, 0, 0.23, 0),
			Size = UDim2.new(0.93, 0, 0.62, 0),
			[React.Event.Activated] = p.OnClick
		}, {
			Icon = createElement("ImageButton", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://127161493687958",
				Position = UDim2.fromScale(0, 0.5),
				Size = UDim2.fromScale(1, 1.7),
				[React.Event.Activated] = p.OnClick
			}, {
				UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
					AspectRatio = 1.23
				})
			})
		})
	end

	return createElement("ImageButton", v4, {
		BannerImage = bannerImage,
		GiftButton = createElement(animatedGiftButton, {
			OnClick = p.OnClick
		}),
		TextLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.BODY_BOLD,
			Position = UDim2.fromScale(0.15, 0.52),
			Size = UDim2.fromScale(0.6, 0.62),
			Text = `You have {v} UNCLAIMED gift{v == 1 and "" or "s"}!`,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextStrokeTransparency = CONSTANTS.ALPHA.OPAQUE,
			TextXAlignment = Enum.TextXAlignment.Left,
			Visible = true
		}),
		SinkBanner = createElement("TextButton", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
			Position = UDim2.fromScale(0.5, 0.5),
			SelectionOrder = 2,
			Size = UDim2.fromScale(0.85, 1),
			Text = "",
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextSize = 14
		})
	})
end