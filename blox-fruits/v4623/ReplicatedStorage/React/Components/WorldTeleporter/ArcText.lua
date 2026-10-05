local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local useTransitionAlpha = require(game.ReplicatedStorage.React.Hooks.WorldTeleporter.useTransitionAlpha)
local useTheme = require(game.ReplicatedStorage.React.Hooks.WorldTeleporter.useTheme)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local rbxassetid12187368843 = Font.new("rbxassetid://12187368843")
local createElement = React.createElement

local function solveCharacters(text: string, state: number?, characterSize: UDim2, padding: UDim?, repeats: number?, flipText: boolean?)
	local v = text:len()
	local v2 = repeats or 1

	if not state or v <= 0 or v2 < 1 then
		return table.freeze({})
	end

	local v3 = 3.141592653589793 * state
	local vector = Vector2.new(
		characterSize.X.Scale * state + characterSize.X.Offset,
		characterSize.Y.Scale * state + characterSize.Y.Offset
	)
	local v4 = not padding and 0 or padding.Scale * v3 + padding.Offset
	local v5 = vector.X * v + (v - 1) * v4
	local v6 = (v3 - v5 * v2) / v2
	local v7 = math.max(vector.X, vector.Y)

	if flipText then
		text = text:reverse()
	end

	local v8 = -v5 / 2
	local result = {}

	for _ = 1, v2 do
		for i = 1, v do
			table.insert(result, table.freeze({
				Character = text:sub(i, i),
				RotationOffset = 360 * ((v8 + vector.X / 2) / v3),
				Size = UDim2.fromOffset(v7, v7)
			}))
			v8 += vector.X

			if i < v then
				v8 += v4
			end
		end

		v8 += v6
	end

	table.freeze(result)
	return result
end

return function(props)
	local v = useTheme()
	local rotation = props.RotateCounterClockwise and 90 or -90
	local state, setState = React.useState(nil)
	local v3 = React.useMemo(function()
		return solveCharacters(props.Text, state, props.CharacterSize, props.Padding, props.Repeats, props.FlipText)
	end, {
		state,
		props.CharacterSize,
		props.Padding,
		props.Text,
		props.FlipText,
		props.Repeats
	})
	local v4 = state or 0
	local v5

	if props.Radius then
		v5 = props.Radius.Scale * v4 / 2 + props.Radius.Offset
	else
		v5 = v4 / 2
	end

	local v6 = useTransitionAlpha(props.IsIslandSelected == true)
	local v7 = props.HasDoubleRing and 0.75 or 0.65
	local glowColor3 = props.GlowColor3 or v.Primary
	local v8 = {}

	for k, v9 in v3 do
		local rotationOffset = math.rad(v9.RotationOffset)
		local formatted = `Char{k}`
		local v10

		if v6 > 0 then
			v10 = createElement("TextLabel", {
				TextColor3 = v.Text,
				FontFace = rbxassetid12187368843,
				Text = v9.Character,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Active = false,
				TextScaled = true,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Rotation = math.deg(rotationOffset) + 90 + (props.RotationOffset or 0) + (props.FlipText and 180 or 0),
				Size = v9.Size:Lerp(UDim2.new(v9.Size.X, UDim.new(0, 0)), 1 - v6),
				Position = UDim2.fromOffset(
					(1 - v7) * math.cos(rotationOffset) * v5 + v4 / 2,
					(1 - v7) * math.sin(rotationOffset) * v5 + v4 / 2
				)
			}, {
				UICorner = createElement("UICorner", {
					CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
				}),
				Glow = createElement("UIShadow", {
					Color = glowColor3,
					BlurRadius = UDim.new(1, 0),
					Transparency = 0.4 + 0.6 * (1 - v6)
				})
			})
		else
			v10 = false
		end

		v8[formatted] = v10
	end

	return createElement("Frame", RobloxTypes.mergeFrame({
		Rotation = rotation,
		[React.Change.AbsoluteSize] = function(p)
			setState((math.min(p.AbsoluteSize.X, p.AbsoluteSize.Y)))
		end
	}, props), {
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
		}),
		Letters = createElement(React.Fragment, {}, v8)
	})
end