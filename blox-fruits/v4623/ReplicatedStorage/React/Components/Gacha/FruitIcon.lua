local React = require(game.ReplicatedStorage.Packages.React)
local RarityUtil = require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local AnimatedTile = require(game.ReplicatedStorage.React.Components.Gacha.AnimatedTile)
local Sunburst = require(game.ReplicatedStorage.React.Components.Gacha.Sunburst)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local vector = Vector2.new(256, 256)
local uDim = UDim2.fromScale(0.481982, 0.472973)
local uDim2 = UDim2.fromScale(0.9, 0.9)
local uDim3 = UDim2.fromScale(1.2, 1.2)
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.24533, 0),
	NumberSequenceKeypoint.new(0.738481, 0),
	NumberSequenceKeypoint.new(1, 1)
})
local v = {
	Common = {
		Text = "Common",
		ImageRectOffset = Vector2.new(256, 512),
		NamePosition = UDim2.fromScale(0.5, 0.912),
		NameSize = UDim2.fromScale(0.794486, 0.17357),
		HasSunburst = false
	},
	Uncommon = {
		Text = "Uncommon",
		ImageRectOffset = Vector2.new(0, 512),
		NamePosition = UDim2.fromScale(0.5, 0.912),
		NameSize = UDim2.fromScale(0.794486, 0.17357),
		HasSunburst = false
	},
	Rare = {
		Text = "Rare",
		ImageRectOffset = Vector2.new(256, 256),
		NamePosition = UDim2.fromScale(0.5, 0.9),
		NameSize = UDim2.fromScale(0.583, 0.15),
		HasSunburst = false
	},
	Legendary = {
		Text = "Legendary",
		ImageRectOffset = Vector2.new(0, 256),
		NamePosition = UDim2.fromScale(0.5, 0.9),
		NameSize = UDim2.fromScale(0.748, 0.13),
		HasSunburst = false
	},
	Mythical = {
		Text = "Mythical",
		ImageRectOffset = Vector2.new(256, 0),
		NamePosition = UDim2.fromScale(0.5, 0.89),
		NameSize = UDim2.fromScale(0.647436, 0.128205),
		HasSunburst = true
	}
}
local createElement = React.createElement

function cross()
	return createElement("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		Image = "rbxassetid://89565017712105",
		Position = UDim2.fromScale(0.5, 0.55),
		Size = UDim2.fromScale(0.8, 0.8),
		ZIndex = CONSTANTS.LAYER.RAISED,
		Visible = true
	})
end

function sunburst(p)
	return createElement(Sunburst, {
		Direction = p.Direction,
		AnchorPoint = Vector2.new(0.5, 0.5),
		ImageColor3 = RarityUtil.matchRarity(p.Rarity):unwrap().Color,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = uDim3,
		ZIndex = CONSTANTS.LAYER.BASE
	})
end

return function(props)
	local v2 = v[props.Rarity]

	if v2 == nil then
		error((`unknown={props.Rarity}`))
	end

	local mergeFrame = RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, props)
	local v5 = {
		Children = createElement(React.Fragment, {}, props.children),
		Icon = createElement(AnimatedTile, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = "rbxassetid://122671367010704",
			ImageRectOffset = v2.ImageRectOffset,
			ImageRectSize = vector,
			Position = uDim,
			Size = uDim2,
			Shake = props.Shake,
			Breathe = props.Breathe,
			Float = props.Float,
			Sparkle = props.Sparkle,
			Slide = props.Slide
		}),
		Sunburst1 = 0,
		Sunburst2 = 0,
		Cross = 0,
		Name = 0
	}
	local sunburst2

	if v2.HasSunburst then
		sunburst2 = createElement(sunburst, {
			Rarity = props.Rarity,
			Direction = 1
		})
	end

	v5.Sunburst1 = sunburst2
	local sunburst3

	if v2.HasSunburst then
		sunburst3 = createElement(sunburst, {
			Rarity = props.Rarity,
			Direction = -1
		})
	end

	v5.Sunburst2 = sunburst3
	local cross2

	if props.CrossOut == true then
		cross2 = createElement(cross)
	end

	v5.Cross = cross2
	v5.Name = createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		BorderColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = v2.NamePosition,
		Size = v2.NameSize,
		ZIndex = CONSTANTS.LAYER.RAISED_HIGH
	}, {
		TextLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 0.875),
			Text = v2.Text,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true
		}),
		UIGradient = createElement("UIGradient", {
			Transparency = numberSequence
		})
	})
	return createElement("Frame", mergeFrame, v5)
end