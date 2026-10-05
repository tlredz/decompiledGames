local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local React = require(game.ReplicatedStorage.Packages.React)
local Sparkles = require(game.ReplicatedStorage.React.Components.Gacha.Sparkles)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	Min = 0,
	Max = 0.2,
	Speed = 0.3
}
local v2 = {
	Duration = 1,
	Shakes = 6,
	Speed = 1,
	Angle = 5,
	ShakeTimer = NumberRange.new(3, 5)
}
local _ = {
	Distance = 0.03,
	Speed = 0.3
}
local vector = Vector2.new(0.5, 0.5)
local uDim = UDim2.fromScale(0.5, 0.489749)
local uDim2 = UDim2.fromScale(0.9, 0.9)
local createElement = React.createElement

local function applyBreathing(data, p: number, p2)
	local speed = data.Speed or 0.3
	local min = data.Min or 0
	local max = data.Max or 0.2
	local v3 = math.sin(p * speed * 3.141592653589793 * 2) + 1
	p2.ImageTransparency = min + (max - min) * v3
end

local function applyFloat(float, current: number, current2)
	local speed = float.Speed or not float.SpeedMod and 0.3 or float.SpeedMod * 0.3 or 0.3
	local distance = float.Distance or 0.03
	local v3 = math.sin(current * speed * 3.141592653589793 * 2) * distance
	current2.Position = UDim2.new(
		float.Position.X.Scale,
		float.Position.X.Offset,
		float.Position.Y.Scale + v3,
		float.Position.Y.Offset
	)
end

local function applyShake(shake, current, data, dt: number)
	local shakes = shake.Shakes or v2.Shakes
	local angle = shake.Angle or v2.Angle
	local duration = shake.Duration or v2.Duration
	local shakeTimer = shake.ShakeTimer or v2.ShakeTimer

	if data.nextShake.current == nil then
		local nextShake = data.nextShake
		local current2

		if data.isFirstShake.current then
			current2 = tick() + 1
		else
			current2 = tick() + math.random(shakeTimer.Min, shakeTimer.Max)
		end

		nextShake.current = current2
		data.shaking.current = false
		data.shakingElapsed.current = 0
		data.isFirstShake.current = false
	end

	if not data.shaking.current and data.nextShake.current and tick() > data.nextShake.current then
		data.shaking.current = true
	end

	if data.shaking.current then
		if data.shakingElapsed.current < duration then
			local v3 = 1 - data.shakingElapsed.current / duration
			current.Rotation = math.sin(data.shakingElapsed.current * shakes * 3.141592653589793 * 2) * angle * v3
		else
			data.nextShake.current = nil
		end

		data.shakingElapsed.current += dt
	end
end

local function applySlide(slide, current, dt: number)
	local v3 = 1 - math.exp(dt * -10)
	current.Position = (slide.StartPosition or current.Position):Lerp(
		UDim2.new(
			slide.EndPosition.X.Scale,
			slide.EndPosition.X.Offset,
			slide.EndPosition.Y.Scale,
			slide.EndPosition.Y.Offset
		),
		v3
	)
end

local function sparkleProperties(sparkle)
	local mergeImageLabel = RobloxTypes.mergeImageLabel(sparkle or {}, {
		AnchorPoint = vector,
		Position = uDim,
		Size = uDim2,
		ZIndex = 99999
	})
	local enabled

	if sparkle then
		enabled = sparkle.Enabled
	else
		enabled = false
	end

	mergeImageLabel.Enabled = enabled
	local speed

	if sparkle then
		speed = sparkle.Speed
	end

	mergeImageLabel.Speed = speed
	return mergeImageLabel
end

return function(props)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(true)
	local ref3 = React.useRef(0)
	local ref4 = React.useRef(nil)
	local ref5 = React.useRef(false)
	local ref6 = React.useRef(0)
	React.useEffect(function()
		local v3

		if props.Resize and ref.current then
			v3 = TweenService:Create(ref.current, props.Resize.TweenInfo, {
				Size = props.Resize.Size
			})
			v3:Play()
		else
			v3 = nil
		end

		return function()
			if v3 then
				v3:Destroy()
			end
		end
	end, { props.Resize, ref.current })
	React.useEffect(function()
		local heartbeatConnection = RunService.Heartbeat:Connect(function(dt: number)
			if ref.current then
				if props.Float and props.Float.Enabled then
					applyFloat(props.Float, ref6.current, ref.current)
				end

				if props.Breathe and props.Breathe.Enabled then
					local breathe = props.Breathe
					local current = ref6.current
					local current2 = ref.current
					local speed = breathe.Speed or v.Speed
					local min = breathe.Min or v.Min
					local max = breathe.Max or v.Max
					local v3 = math.sin(current * speed * 3.141592653589793 * 2) + 1
					current2.ImageTransparency = min + (max - min) * v3
				end

				if props.Shake and props.Shake.Enabled then
					applyShake(props.Shake, ref.current, {
						isFirstShake = ref2,
						shakingElapsed = ref3,
						nextShake = ref4,
						shaking = ref5
					}, dt)
				end

				if props.Slide and props.Slide.Enabled then
					applySlide(props.Slide, ref.current, dt)
				end

				ref6.current += dt
			end
		end)
		return function()
			heartbeatConnection:Disconnect()
		end
	end, { ref.current, props })
	React.useEffect(function()
		if ref.current then
			if props.Position and (props.Float == nil or props.Float.Enabled == false) then
				ref.current.Position = props.Position
			end

			if props.Breathe == nil or props.Breathe.Enabled == false then
				ref.current.ImageTransparency = props.ImageTransparency or 0
			end

			if props.Shake == nil or props.Shake.Enabled == false then
				ref.current.Rotation = props.Rotation or 0
			end
		end
	end, {
		props.Float,
		props.Shake,
		props.Breathe,
		ref.current
	})
	return createElement("ImageLabel", RobloxTypes.mergeImageLabel({
		ref = ref,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, props), {
		Children = createElement(React.Fragment, {}, props.children),
		SparkleImage = createElement(Sparkles, (sparkleProperties(props.Sparkle)))
	})
end