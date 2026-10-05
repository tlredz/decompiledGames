local React = require(game.ReplicatedStorage.Packages.React)
local ShadowedText = require(script.Parent.ShadowedText)
local Icon = require(script.Parent.Icon)
local TextSizing = require(script.Parent.TextSizing)
local rbxassetfontsfamiliesHighwayGothicjson = Font.new(
	"rbxasset://fonts/families/HighwayGothic.json",
	Enum.FontWeight.Bold,
	Enum.FontStyle.Normal
)
local rbxassetfontsfamiliesHighwayGothicjson2 = Font.new("rbxasset://fonts/families/HighwayGothic.json")
local vector = Vector2.new(42, 25)
local vector2 = Vector2.new(0.8, 0.8)
local colorSequence = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 199, 29)),
	ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(255, 239, 60)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 199, 29))
})
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.442092, 0),
	NumberSequenceKeypoint.new(0.556662, 0),
	NumberSequenceKeypoint.new(1, 1)
})
local element = React.createElement("UICorner", {
	CornerRadius = UDim.new(0.1, 0)
})
local element2 = React.createElement("UIGradient", {
	Color = colorSequence,
	Transparency = numberSequence
})
local numberSequence2 = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1) })

local function subtitleDecor(flag: boolean)
	local createElement = React.createElement
	local imageRectOffset

	if not flag then
		imageRectOffset = Vector2.new(42, 0)
	end

	return createElement("ImageLabel", {
		BackgroundTransparency = 1,
		Image = "rbxassetid://80476070082988",
		ImageRectOffset = imageRectOffset,
		ImageRectSize = vector,
		ImageTransparency = 0.25,
		LayoutOrder = flag and -1 or 1,
		Position = UDim2.fromScale(0.259181, 0.19419),
		ScaleType = Enum.ScaleType.Fit,
		Size = UDim2.fromScale(0.0776628, 0.611622),
		ZIndex = 3
	}, {
		uIAspectRatioConstraint = React.createElement("UIAspectRatioConstraint", {
			AspectRatio = 1.68
		})
	})
end

local function subtitleLine(flag: boolean)
	return React.createElement("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.25,
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,
		LayoutOrder = flag and -9999 or 9999,
		Size = UDim2.fromScale(0.5, 0.04),
		ZIndex = 3
	}, {
		uIGradient = React.createElement("UIGradient", {
			Rotation = flag and 180 or 0,
			Transparency = numberSequence2
		})
	})
end

local function subtitle(subtitle2: string)
	return React.createElement("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = UDim2.fromScale(0.5, 1.1),
		Size = UDim2.fromScale(0.8, 0.621),
		ZIndex = 3
	}, {
		title = React.createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			FontFace = rbxassetfontsfamiliesHighwayGothicjson2,
			Position = UDim2.fromScale(0.5, 1.1),
			Size = UDim2.fromScale(0, 1),
			Text = subtitle2,
			TextColor3 = Color3.new(1, 1, 1),
			TextScaled = true,
			TextTransparency = 0.25,
			ZIndex = 3
		}),
		uIListLayout = React.createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(0.03, 0),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		decorLeft = subtitleDecor(true),
		decorRight = subtitleDecor(false),
		rightLine = subtitleLine(false),
		leftLine = subtitleLine(true)
	})
end

local function hasText(value: string?)
	return value ~= nil and string.find(value, "%S") ~= nil
end

local function sideSprite(props, flag: boolean, spriteGap: number, spriteSize: number)
	local sprite

	if flag then
		sprite = props.sprite
	else
		sprite = props.spriteRight or props.sprite
	end

	local createElement = React.createElement
	local v2 = {
		image = sprite.Image,
		imageRectOffset = sprite.ImageRectOffset,
		imageRectSize = sprite.ImageRectSize,
		anchorPoint = Vector2.new(flag and 1 or 0, 0.5),
		position = 0,
		size = 0,
		scaleType = 0,
		effect = 0,
		zIndex = 3
	}

	if flag then
		spriteGap = -spriteGap
	end

	v2.position = UDim2.new(0.5, spriteGap, 0.5, 0)
	v2.size = UDim2.fromOffset(spriteSize, spriteSize)
	v2.scaleType = Enum.ScaleType.Fit
	v2.effect = props.wiggle and "Wiggle" or nil
	return createElement(Icon, v2)
end

local function DialogueTitle(props)
	local ref = React.useRef(nil)
	local state, setState = React.useState(nil)
	local state2, setState2 = React.useState(TextSizing.preferenceKey())
	React.useEffect(function()
		local connection = TextSizing.onPreferenceChanged(function()
			setState2(TextSizing.preferenceKey())
		end)
		return function()
			if connection then
				connection:Disconnect()
			end
		end
	end, {})
	React.useEffect(function()
		local current = ref.current

		if not current then
			return
		end

		local v = false

		-- equivalent calls inferred from this helper; original call sites unknown
		local function update()
			local absoluteSize = current.AbsoluteSize

			if absoluteSize.X < 1 or absoluteSize.Y < 1 then
				return
			end

			task.spawn(function()
				local vector3 = Vector2.new(absoluteSize.X * vector2.X, absoluteSize.Y * vector2.Y)
				local fitTextSize = TextSizing.fitTextSize(
					props.name,
					rbxassetfontsfamiliesHighwayGothicjson,
					vector3,
					vector3.Y
				)
				local textSizeForMeasuredSize = TextSizing.renderTextSizeForMeasuredSize(
					fitTextSize,
					rbxassetfontsfamiliesHighwayGothicjson
				)
				local v2 = math.max(textSizeForMeasuredSize - fitTextSize, 0)
				local X = TextSizing.bounds(props.name, rbxassetfontsfamiliesHighwayGothicjson, fitTextSize, false).X
				local spriteSize = absoluteSize.Y * 0.96875 + v2
				local v4 = X / 2 + absoluteSize.Y * 0.3 + v2
				local v5 = 0.44 * absoluteSize.X - spriteSize

				if not v then
					setState({
						spriteGap = math.max(math.min(v4, v5), 0),
						spriteSize = spriteSize,
						textSize = textSizeForMeasuredSize
					})
				end
			end)
		end

		update() -- equivalent call inferred; original call site unknown
		local absoluteSizeChangedConnection = current:GetPropertyChangedSignal("AbsoluteSize"):Connect(update)
		return function()
			v = true
			absoluteSizeChangedConnection:Disconnect()
		end
	end, { props.name, state2 })
	local createElement = React.createElement
	local v2 = {
		ref = ref,
		AnchorPoint = Vector2.new(0.5, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		Position = UDim2.fromScale(0.499215, 0.0447011),
		Size = UDim2.fromScale(0.397698, 0.275657),
		ZIndex = 2
	}
	local v3 = {
		uICorner = element,
		backgroundFade = element2,
		subtitle = 0,
		name = 0,
		leftSprite = 0,
		rightSprite = 0
	}
	local subtitle2 = props.subtitle
	local v4

	if subtitle2 == nil then
		v4 = false
	else
		v4 = string.find(subtitle2, "%S") ~= nil
	end

	local subtitle3

	if v4 then
		subtitle3 = subtitle(props.subtitle)
	end

	v3.subtitle = subtitle3
	v3.name = React.createElement(ShadowedText, {
		text = props.name,
		textSize = state and state.textSize
	})
	local leftSprite

	if props.titleSprite and state then
		leftSprite = sideSprite(props.titleSprite, true, state.spriteGap, state.spriteSize) or nil
	end

	v3.leftSprite = leftSprite
	v3.rightSprite = props.titleSprite and state and sideSprite(
		props.titleSprite,
		false,
		state.spriteGap,
		state.spriteSize
	) or nil
	return createElement("Frame", v2, v3)
end

return React.memo(DialogueTitle)