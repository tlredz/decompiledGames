local TweenService = game:GetService("TweenService")
local React = require(game.ReplicatedStorage.Packages.React)
local Util = require(script.Parent.Util)

local function getRatio(data)
	if data.Ratio ~= nil then
		return Util.clamp01(data.Ratio)
	end

	if data.Current == nil or data.Max == nil or not (data.Max > 0) then
		return 0
	end

	return Util.clamp01(data.Current / data.Max)
end

local function ProgressBar(props)
	local v

	if props.Ratio == nil then
		v = (props.Current == nil or props.Max == nil or not (props.Max > 0)) and 0 or Util.clamp01(props.Current / props.Max)
	else
		v = Util.clamp01(props.Ratio)
	end

	local state, setState = React.useState(v)
	local ref = React.useRef(state)
	React.useEffect(function()
		ref.current = state
		return function() end
	end, { state })
	React.useEffect(function()
		local valueOrDefault = Util.valueOrDefault(props.TweenDuration, 0.25)

		if valueOrDefault <= 0 then
			setState(v)
			return function() end
		end

		local numberValue = Instance.new("NumberValue")
		numberValue.Value = ref.current
		local changedConnection = numberValue.Changed:Connect(function(p: number)
			setState(Util.clamp01(p))
		end)
		local tween = TweenService:Create(
			numberValue,
			TweenInfo.new(
				valueOrDefault,
				props.TweenEasingStyle or Enum.EasingStyle.Quad,
				props.TweenEasingDirection or Enum.EasingDirection.Out
			),
			{
				Value = v
			}
		)
		tween:Play()
		return function()
			tween:Cancel()
			changedConnection:Disconnect()
			numberValue:Destroy()
		end
	end, {
		v,
		props.TweenDuration,
		props.TweenEasingStyle,
		props.TweenEasingDirection
	})
	local mergeProps = Util.mergeProps({
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = props.FillColor or Color3.fromRGB(255, 230, 53),
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromScale(state, 1)
	}, props.FillProps)
	mergeProps.Size = UDim2.fromScale(state, 1)
	return React.createElement("Frame", Util.mergeProps({
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = props.BackgroundColor or Color3.fromRGB(255, 230, 53),
		BackgroundTransparency = 0.65,
		BorderColor3 = Color3.new(),
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.151449, 0.617031),
		Size = UDim2.fromScale(0.690984, 0.0781052)
	}, props.RootProps), {
		progressBar = React.createElement("Frame", mergeProps)
	})
end

return React.memo(ProgressBar)